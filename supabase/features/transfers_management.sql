-- #################################################
-- Gestión de Transferencias
-- #################################################

-- Este script implementa la funcionalidad de transferencias entre
-- cuentas y jarras, incluyendo validaciones y registro histórico.

-- #################################################
-- TIPOS Y FUNCIONES DE VALIDACIÓN
-- #################################################

-- Tipo: Resultado de validación de transferencia
CREATE TYPE public.transfer_validation_result AS (
    is_valid boolean,
    error_message text,
    source_balance numeric(15,2),
    target_balance numeric(15,2)
);

-- Función: Validar transferencia entre cuentas
CREATE OR REPLACE FUNCTION public.validate_account_transfer(
    p_user_id uuid,
    p_from_account_id uuid,
    p_to_account_id uuid,
    p_amount numeric,
    p_exchange_rate numeric DEFAULT 1
)
RETURNS public.transfer_validation_result AS $$
DECLARE
    v_result public.transfer_validation_result;
    v_from_currency varchar(3);
    v_to_currency varchar(3);
BEGIN
    -- Inicializar resultado
    v_result.is_valid := false;
    
    -- Verificar que las cuentas son diferentes
    IF p_from_account_id = p_to_account_id THEN
        v_result.error_message := 'No se puede transferir a la misma cuenta';
        RETURN v_result;
    END IF;

    -- Obtener monedas y balances de las cuentas
    SELECT 
        a.current_balance,
        c.code INTO v_result.source_balance, v_from_currency
    FROM public.account a
    JOIN public.currency c ON c.id = a.currency_id
    WHERE a.id = p_from_account_id AND a.user_id = p_user_id;

    SELECT 
        a.current_balance,
        c.code INTO v_result.target_balance, v_to_currency
    FROM public.account a
    JOIN public.currency c ON c.id = a.currency_id
    WHERE a.id = p_to_account_id AND a.user_id = p_user_id;

    -- Validar que existen las cuentas
    IF v_result.source_balance IS NULL OR v_result.target_balance IS NULL THEN
        v_result.error_message := 'Cuenta no encontrada o sin acceso';
        RETURN v_result;
    END IF;

    -- Validar saldo suficiente
    IF v_result.source_balance < p_amount THEN
        v_result.error_message := format(
            'Saldo insuficiente. Disponible: %s %s, Requerido: %s %s',
            v_from_currency, v_result.source_balance, v_from_currency, p_amount
        );
        RETURN v_result;
    END IF;

    -- Validar tipo de cambio si las monedas son diferentes
    IF v_from_currency != v_to_currency AND p_exchange_rate <= 0 THEN
        v_result.error_message := 'Tipo de cambio inválido para transferencia entre diferentes monedas';
        RETURN v_result;
    END IF;

    -- Si todo está bien
    v_result.is_valid := true;
    RETURN v_result;
END;
$$ LANGUAGE plpgsql;

-- Función: Validar transferencia entre jarras
CREATE OR REPLACE FUNCTION public.validate_jar_transfer(
    p_user_id uuid,
    p_from_jar_id uuid,
    p_to_jar_id uuid,
    p_amount numeric
)
RETURNS public.transfer_validation_result AS $$
DECLARE
    v_result public.transfer_validation_result;
BEGIN
    -- Inicializar resultado
    v_result.is_valid := false;
    
    -- Verificar que las jarras son diferentes
    IF p_from_jar_id = p_to_jar_id THEN
        v_result.error_message := 'No se puede transferir a la misma jarra';
        RETURN v_result;
    END IF;

    -- Obtener balances de las jarras
    SELECT current_balance INTO v_result.source_balance
    FROM public.jar_balance
    WHERE jar_id = p_from_jar_id AND user_id = p_user_id;

    SELECT current_balance INTO v_result.target_balance
    FROM public.jar_balance
    WHERE jar_id = p_to_jar_id AND user_id = p_user_id;

    -- Validar que existen las jarras
    IF v_result.source_balance IS NULL OR v_result.target_balance IS NULL THEN
        v_result.error_message := 'Jarra no encontrada o sin acceso';
        RETURN v_result;
    END IF;

    -- Validar saldo suficiente
    IF v_result.source_balance < p_amount THEN
        v_result.error_message := format(
            'Saldo insuficiente en jarra. Disponible: %s, Requerido: %s',
            v_result.source_balance, p_amount
        );
        RETURN v_result;
    END IF;

    -- Si todo está bien
    v_result.is_valid := true;
    RETURN v_result;
END;
$$ LANGUAGE plpgsql;

-- #################################################
-- FUNCIONES DE PROCESAMIENTO
-- #################################################

-- Función: Ejecutar transferencia entre cuentas
CREATE OR REPLACE FUNCTION public.execute_account_transfer(
    p_user_id uuid,
    p_from_account_id uuid,
    p_to_account_id uuid,
    p_amount numeric,
    p_exchange_rate numeric DEFAULT 1,
    p_description text DEFAULT NULL
)
RETURNS uuid AS $$
DECLARE
    v_validation public.transfer_validation_result;
    v_transfer_id uuid;
BEGIN
    -- Validar la transferencia
    v_validation := public.validate_account_transfer(
        p_user_id,
        p_from_account_id,
        p_to_account_id,
        p_amount,
        p_exchange_rate
    );

    IF NOT v_validation.is_valid THEN
        RAISE EXCEPTION '%', v_validation.error_message;
    END IF;

    -- Crear registro de transferencia
    INSERT INTO public.transfer (
        user_id,
        transfer_type,
        amount,
        exchange_rate,
        from_account_id,
        to_account_id,
        description
    ) VALUES (
        p_user_id,
        'ACCOUNT_TO_ACCOUNT',
        p_amount,
        p_exchange_rate,
        p_from_account_id,
        p_to_account_id,
        p_description
    ) RETURNING id INTO v_transfer_id;

    -- Actualizar balances
    UPDATE public.account
    SET 
        current_balance = current_balance - p_amount,
        modified_at = CURRENT_TIMESTAMP
    WHERE id = p_from_account_id;

    UPDATE public.account
    SET 
        current_balance = current_balance + (p_amount * p_exchange_rate),
        modified_at = CURRENT_TIMESTAMP
    WHERE id = p_to_account_id;

    -- Registrar en historial
    INSERT INTO public.balance_history (
        user_id,
        account_id,
        old_balance,
        new_balance,
        change_amount,
        change_type,
        reference_type,
        reference_id
    ) VALUES
    (
        p_user_id,
        p_from_account_id,
        v_validation.source_balance,
        v_validation.source_balance - p_amount,
        p_amount,
        'TRANSFER',
        'transfer',
        v_transfer_id
    ),
    (
        p_user_id,
        p_to_account_id,
        v_validation.target_balance,
        v_validation.target_balance + (p_amount * p_exchange_rate),
        p_amount * p_exchange_rate,
        'TRANSFER',
        'transfer',
        v_transfer_id
    );

    RETURN v_transfer_id;
END;
$$ LANGUAGE plpgsql;

-- Función: Ejecutar transferencia entre jarras
CREATE OR REPLACE FUNCTION public.execute_jar_transfer(
    p_user_id uuid,
    p_from_jar_id uuid,
    p_to_jar_id uuid,
    p_amount numeric,
    p_description text DEFAULT NULL,
    p_is_rollover boolean DEFAULT false
)
RETURNS uuid AS $$
DECLARE
    v_validation public.transfer_validation_result;
    v_transfer_id uuid;
BEGIN
    -- Validar la transferencia
    v_validation := public.validate_jar_transfer(
        p_user_id,
        p_from_jar_id,
        p_to_jar_id,
        p_amount
    );

    IF NOT v_validation.is_valid THEN
        RAISE EXCEPTION '%', v_validation.error_message;
    END IF;

    -- Crear registro de transferencia
    INSERT INTO public.transfer (
        user_id,
        transfer_type,
        amount,
        from_jar_id,
        to_jar_id,
        description
    ) VALUES (
        p_user_id,
        CASE WHEN p_is_rollover THEN 'PERIOD_ROLLOVER' ELSE 'JAR_TO_JAR' END,
        p_amount,
        p_from_jar_id,
        p_to_jar_id,
        p_description
    ) RETURNING id INTO v_transfer_id;

    -- Actualizar balances
    UPDATE public.jar_balance
    SET 
        current_balance = current_balance - p_amount,
        modified_at = CURRENT_TIMESTAMP
    WHERE jar_id = p_from_jar_id AND user_id = p_user_id;

    UPDATE public.jar_balance
    SET 
        current_balance = current_balance + p_amount,
        modified_at = CURRENT_TIMESTAMP
    WHERE jar_id = p_to_jar_id AND user_id = p_user_id;

    -- Registrar en historial
    INSERT INTO public.balance_history (
        user_id,
        jar_id,
        old_balance,
        new_balance,
        change_amount,
        change_type,
        reference_type,
        reference_id
    ) VALUES
    (
        p_user_id,
        p_from_jar_id,
        v_validation.source_balance,
        v_validation.source_balance - p_amount,
        p_amount,
        CASE WHEN p_is_rollover THEN 'ROLLOVER' ELSE 'TRANSFER' END,
        'transfer',
        v_transfer_id
    ),
    (
        p_user_id,
        p_to_jar_id,
        v_validation.target_balance,
        v_validation.target_balance + p_amount,
        p_amount,
        CASE WHEN p_is_rollover THEN 'ROLLOVER' ELSE 'TRANSFER' END,
        'transfer',
        v_transfer_id
    );

    RETURN v_transfer_id;
END;
$$ LANGUAGE plpgsql;

-- #################################################
-- FUNCIONES DE ROLLOVER AUTOMÁTICO
-- #################################################

-- Función: Procesar rollover de saldos no utilizados
CREATE OR REPLACE FUNCTION public.process_jar_rollover(
    p_user_id uuid
)
RETURNS TABLE (
    jar_code text,
    amount_rolled numeric(15,2)
) AS $$
DECLARE
    v_jar record;
    v_savings_jar_id uuid;
    v_investment_jar_id uuid;
    v_amount numeric(15,2);
    v_transfer_id uuid;
BEGIN
    -- Obtener IDs de jarras de ahorro e inversión
    SELECT id INTO v_savings_jar_id
    FROM public.jar WHERE code = 'SAVINGS';

    SELECT id INTO v_investment_jar_id
    FROM public.jar WHERE code = 'INVESTMENT';

    -- Procesar cada jarra excepto ahorro e inversión
    FOR v_jar IN 
        SELECT j.*, jb.current_balance
        FROM public.jar j
        JOIN public.jar_balance jb ON jb.jar_id = j.id
        WHERE j.code NOT IN ('SAVINGS', 'INVESTMENT')
        AND jb.user_id = p_user_id
        AND jb.current_balance > 0
    LOOP
        -- Calcular monto a transferir (50% a cada jarra)
        v_amount := v_jar.current_balance / 2;

        -- Transferir a ahorro
        IF v_amount > 0 THEN
            v_transfer_id := public.execute_jar_transfer(
                p_user_id,
                v_jar.id,
                v_savings_jar_id,
                v_amount,
                'Rollover automático a ahorro',
                true
            );

            jar_code := v_jar.code;
            amount_rolled := v_amount;
            RETURN NEXT;
        END IF;

        -- Transferir a inversión
        IF v_amount > 0 THEN
            v_transfer_id := public.execute_jar_transfer(
                p_user_id,
                v_jar.id,
                v_investment_jar_id,
                v_amount,
                'Rollover automático a inversión',
                true
            );
        END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- #################################################
-- VISTAS DE ANÁLISIS
-- #################################################

-- Vista: Resumen de transferencias
CREATE OR REPLACE VIEW public.transfer_summary AS
SELECT 
    t.user_id,
    t.transfer_type,
    t.transfer_date,
    t.amount,
    t.exchange_rate,
    CASE 
        WHEN t.transfer_type = 'ACCOUNT_TO_ACCOUNT' THEN
            (SELECT name FROM public.account WHERE id = t.from_account_id)
        ELSE
            (SELECT name FROM public.jar WHERE id = t.from_jar_id)
    END as source_name,
    CASE 
        WHEN t.transfer_type = 'ACCOUNT_TO_ACCOUNT' THEN
            (SELECT name FROM public.account WHERE id = t.to_account_id)
        ELSE
            (SELECT name FROM public.jar WHERE id = t.to_jar_id)
    END as target_name,
    CASE 
        WHEN t.transfer_type = 'ACCOUNT_TO_ACCOUNT' THEN
            t.amount * t.exchange_rate
        ELSE
            t.amount
    END as converted_amount,
    t.description,
    t.sync_status,
    t.created_at
FROM public.transfer t;

-- Vista: Análisis de transferencias por período
CREATE OR REPLACE VIEW public.transfer_analysis AS
WITH monthly_stats AS (
    SELECT 
        user_id,
        date_trunc('month', transfer_date) as month,
        transfer_type,
        count(*) as transfer_count,
        sum(converted_amount) as total_amount,
        avg(converted_amount) as avg_amount
    FROM public.transfer_summary
    GROUP BY user_id, date_trunc('month', transfer_date), transfer_type
)
SELECT 
    ms.*,
    lag(total_amount) OVER (
        PARTITION BY user_id, transfer_type 
        ORDER lag(total_amount) OVER (
        PARTITION BY user_id, transfer_type 
        ORDER BY month
    ) as prev_month_amount,
    round(
        (total_amount - lag(total_amount) OVER (
            PARTITION BY user_id, transfer_type 
            ORDER BY month
        )) / nullif(lag(total_amount) OVER (
            PARTITION BY user_id, transfer_type 
            ORDER BY month
        ), 0) * 100,
        2
    ) as month_over_month_change
FROM monthly_stats;

-- #################################################
-- FUNCIONES DE REPORTE
-- #################################################

-- Función: Obtener historial de transferencias
CREATE OR REPLACE FUNCTION public.get_transfer_history(
    p_user_id uuid,
    p_start_date date DEFAULT NULL,
    p_end_date date DEFAULT NULL,
    p_transfer_type text DEFAULT NULL,
    p_limit integer DEFAULT 100
)
RETURNS TABLE (
    transfer_id uuid,
    transfer_date date,
    transfer_type text,
    source_name text,
    target_name text,
    amount numeric,
    converted_amount numeric,
    description text
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        t.id as transfer_id,
        t.transfer_date,
        t.transfer_type::text,
        s.source_name,
        s.target_name,
        t.amount,
        s.converted_amount,
        t.description
    FROM public.transfer t
    JOIN public.transfer_summary s ON s.transfer_id = t.id
    WHERE t.user_id = p_user_id
    AND (p_start_date IS NULL OR t.transfer_date >= p_start_date)
    AND (p_end_date IS NULL OR t.transfer_date <= p_end_date)
    AND (p_transfer_type IS NULL OR t.transfer_type::text = p_transfer_type)
    ORDER BY t.transfer_date DESC
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

-- Función: Obtener resumen de transferencias por período
CREATE OR REPLACE FUNCTION public.get_transfer_summary_by_period(
    p_user_id uuid,
    p_start_date date,
    p_end_date date
)
RETURNS TABLE (
    period date,
    account_transfers_count integer,
    account_transfers_amount numeric,
    jar_transfers_count integer,
    jar_transfers_amount numeric,
    rollover_count integer,
    rollover_amount numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        date_trunc('month', t.transfer_date)::date as period,
        count(*) FILTER (WHERE t.transfer_type = 'ACCOUNT_TO_ACCOUNT') as account_transfers_count,
        coalesce(sum(s.converted_amount) FILTER (WHERE t.transfer_type = 'ACCOUNT_TO_ACCOUNT'), 0) as account_transfers_amount,
        count(*) FILTER (WHERE t.transfer_type = 'JAR_TO_JAR') as jar_transfers_count,
        coalesce(sum(t.amount) FILTER (WHERE t.transfer_type = 'JAR_TO_JAR'), 0) as jar_transfers_amount,
        count(*) FILTER (WHERE t.transfer_type = 'PERIOD_ROLLOVER') as rollover_count,
        coalesce(sum(t.amount) FILTER (WHERE t.transfer_type = 'PERIOD_ROLLOVER'), 0) as rollover_amount
    FROM public.transfer t
    JOIN public.transfer_summary s ON s.transfer_id = t.id
    WHERE t.user_id = p_user_id
    AND t.transfer_date BETWEEN p_start_date AND p_end_date
    GROUP BY date_trunc('month', t.transfer_date)
    ORDER BY period;
END;
$$ LANGUAGE plpgsql;

-- #################################################
-- TRIGGERS DE NOTIFICACIÓN
-- #################################################

-- Función: Generar notificación de transferencia
CREATE OR REPLACE FUNCTION public.notify_transfer()
RETURNS TRIGGER AS $$
BEGIN
    -- Insertar notificación
    INSERT INTO public.notification (
        user_id,
        title,
        message,
        notification_type,
        urgency_level,
        related_entity_type,
        related_entity_id
    )
    SELECT
        NEW.user_id,
        CASE NEW.transfer_type
            WHEN 'ACCOUNT_TO_ACCOUNT' THEN 'Transferencia entre cuentas'
            WHEN 'JAR_TO_JAR' THEN 'Transferencia entre jarras'
            ELSE 'Rollover de período'
        END,
        CASE NEW.transfer_type
            WHEN 'ACCOUNT_TO_ACCOUNT' THEN 
                format('Transferencia de %s realizada desde %s a %s',
                    to_char(NEW.amount, 'FM999,999,999.00'),
                    (SELECT name FROM public.account WHERE id = NEW.from_account_id),
                    (SELECT name FROM public.account WHERE id = NEW.to_account_id)
                )
            ELSE
                format('Transferencia de %s realizada desde %s a %s',
                    to_char(NEW.amount, 'FM999,999,999.00'),
                    (SELECT name FROM public.jar WHERE id = NEW.from_jar_id),
                    (SELECT name FROM public.jar WHERE id = NEW.to_jar_id)
                )
        END,
        'TRANSFER',
        'LOW',
        'transfer',
        NEW.id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger: Notificación después de transferencia
CREATE TRIGGER after_transfer_notification
    AFTER INSERT ON public.transfer
    FOR EACH ROW
    EXECUTE FUNCTION public.notify_transfer();

-- #################################################
-- FUNCIONES DE UTILIDAD
-- #################################################

-- Función: Validar saldo disponible para transferencia
CREATE OR REPLACE FUNCTION public.check_available_balance_for_transfer(
    p_user_id uuid,
    p_account_id uuid DEFAULT NULL,
    p_jar_id uuid DEFAULT NULL
)
RETURNS numeric AS $$
DECLARE
    v_balance numeric(15,2);
BEGIN
    IF p_account_id IS NOT NULL THEN
        SELECT current_balance INTO v_balance
        FROM public.account
        WHERE id = p_account_id AND user_id = p_user_id;
    ELSIF p_jar_id IS NOT NULL THEN
        SELECT current_balance INTO v_balance
        FROM public.jar_balance
        WHERE jar_id = p_jar_id AND user_id = p_user_id;
    ELSE
        RAISE EXCEPTION 'Debe especificar una cuenta o jarra';
    END IF;

    RETURN COALESCE(v_balance, 0);
END;
$$ LANGUAGE plpgsql;

-- #################################################
-- FIN DEL SCRIPT
-- #################################################