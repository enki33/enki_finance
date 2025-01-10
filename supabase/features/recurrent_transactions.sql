-- #################################################
-- Gestión de Transacciones Recurrentes
-- #################################################

-- Este script implementa la funcionalidad de transacciones recurrentes,
-- incluyendo la programación, ejecución y notificaciones.

-- #################################################
-- TIPOS Y TABLAS DE SOPORTE
-- #################################################

-- Tipo: Estado de procesamiento de transacciones recurrentes
CREATE TYPE public.recurring_process_result AS (
    transactions_created integer,
    notifications_sent integer,
    errors_encountered integer
);

-- #################################################
-- FUNCIONES DE VALIDACIÓN
-- #################################################

-- Función: Validar fecha de próxima ejecución
CREATE OR REPLACE FUNCTION public.calculate_next_execution_date(
    p_frequency varchar(20),
    p_start_date date,
    p_last_execution date DEFAULT NULL
)
RETURNS date AS $$
DECLARE
    v_next_date date;
BEGIN
    -- Si no hay última ejecución, usar fecha de inicio
    IF p_last_execution IS NULL THEN
        v_next_date := p_start_date;
    ELSE
        -- Calcular siguiente fecha según frecuencia
        CASE p_frequency
            WHEN 'WEEKLY' THEN
                v_next_date := p_last_execution + INTERVAL '1 week';
            WHEN 'MONTHLY' THEN
                v_next_date := p_last_execution + INTERVAL '1 month';
            WHEN 'YEARLY' THEN
                v_next_date := p_last_execution + INTERVAL '1 year';
            ELSE
                RAISE EXCEPTION 'Frecuencia no válida: %', p_frequency;
        END CASE;
    END IF;

    RETURN v_next_date;
END;
$$ LANGUAGE plpgsql;

-- Función: Validar transacción recurrente
CREATE OR REPLACE FUNCTION public.validate_recurring_transaction(
    p_user_id uuid,
    p_amount numeric,
    p_transaction_type_id uuid,
    p_account_id uuid,
    p_jar_id uuid DEFAULT NULL
)
RETURNS boolean AS $$
DECLARE
    v_transaction_type_code text;
    v_current_balance numeric;
BEGIN
    -- Obtener tipo de transacción
    SELECT code INTO v_transaction_type_code
    FROM public.transaction_type
    WHERE id = p_transaction_type_id;

    -- Para gastos, validar saldo disponible
    IF v_transaction_type_code = 'EXPENSE' THEN
        -- Validar saldo en jarra si aplica
        IF p_jar_id IS NOT NULL THEN
            SELECT current_balance INTO v_current_balance
            FROM public.jar_balance
            WHERE user_id = p_user_id AND jar_id = p_jar_id;

            IF v_current_balance < p_amount THEN
                RETURN false;
            END IF;
        END IF;

        -- Validar saldo en cuenta
        SELECT current_balance INTO v_current_balance
        FROM public.account
        WHERE id = p_account_id AND user_id = p_user_id;

        IF v_current_balance < p_amount THEN
            RETURN false;
        END IF;
    END IF;

    RETURN true;
END;
$$ LANGUAGE plpgsql;

-- #################################################
-- FUNCIONES PRINCIPALES
-- #################################################

-- Función: Procesar transacciones recurrentes
CREATE OR REPLACE FUNCTION public.process_recurring_transactions(
    p_date date DEFAULT CURRENT_DATE
)
RETURNS public.recurring_process_result AS $$
DECLARE
    v_result public.recurring_process_result;
    v_record record;
    v_valid boolean;
BEGIN
    -- Inicializar resultado
    v_result.transactions_created := 0;
    v_result.notifications_sent := 0;
    v_result.errors_encountered := 0;

    -- Procesar cada transacción recurrente activa
    FOR v_record IN 
        SELECT r.*, u.notification_advance_days
        FROM public.recurring_transaction r
        JOIN public.app_user u ON u.id = r.user_id
        WHERE r.is_active = true
        AND r.next_execution_date <= p_date
        AND (r.end_date IS NULL OR r.end_date >= p_date)
    LOOP
        -- Validar si la transacción puede ejecutarse
        v_valid := public.validate_recurring_transaction(
            v_record.user_id,
            v_record.amount,
            v_record.transaction_type_id,
            v_record.account_id,
            v_record.jar_id
        );

        IF v_valid THEN
            BEGIN
                -- Crear la transacción
                INSERT INTO public.transaction (
                    user_id,
                    transaction_date,
                    amount,
                    transaction_type_id,
                    category_id,
                    subcategory_id,
                    account_id,
                    jar_id,
                    transaction_medium_id,
                    description,
                    is_recurring,
                    parent_recurring_id
                ) VALUES (
                    v_record.user_id,
                    p_date,
                    v_record.amount,
                    v_record.transaction_type_id,
                    v_record.category_id,
                    v_record.subcategory_id,
                    v_record.account_id,
                    v_record.jar_id,
                    v_record.transaction_medium_id,
                    v_record.description || ' (Recurrente)',
                    true,
                    v_record.id
                );

                -- Actualizar fechas en plantilla
                UPDATE public.recurring_transaction
                SET 
                    last_execution_date = p_date,
                    next_execution_date = public.calculate_next_execution_date(
                        frequency,
                        start_date,
                        p_date
                    ),
                    modified_at = CURRENT_TIMESTAMP
                WHERE id = v_record.id;

                v_result.transactions_created := v_result.transactions_created + 1;

            EXCEPTION WHEN OTHERS THEN
                v_result.errors_encountered := v_result.errors_encountered + 1;
                
                -- Registrar error
                INSERT INTO public.notification (
                    user_id,
                    title,
                    message,
                    notification_type,
                    urgency_level,
                    related_entity_type,
                    related_entity_id
                ) VALUES (
                    v_record.user_id,
                    'Error en transacción recurrente',
                    'Error al procesar la transacción recurrente: ' || v_record.name || '. Error: ' || SQLERRM,
                    'RECURRING_TRANSACTION',
                    'HIGH',
                    'recurring_transaction',
                    v_record.id
                );
            END;
        ELSE
            -- Notificar saldo insuficiente
            INSERT INTO public.notification (
                user_id,
                title,
                message,
                notification_type,
                urgency_level,
                related_entity_type,
                related_entity_id
            ) VALUES (
                v_record.user_id,
                'Saldo insuficiente para transacción recurrente',
                'No hay saldo suficiente para procesar la transacción recurrente: ' || v_record.name,
                'INSUFFICIENT_FUNDS',
                'HIGH',
                'recurring_transaction',
                v_record.id
            );

            v_result.notifications_sent := v_result.notifications_sent + 1;
        END IF;
    END LOOP;

    -- Generar notificaciones de próximas transacciones
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
        r.user_id,
        'Próxima transacción recurrente',
        'La transacción ' || r.name || ' está programada para el ' || 
        to_char(r.next_execution_date, 'DD/MM/YYYY'),
        'RECURRING_TRANSACTION',
        'MEDIUM',
        'recurring_transaction',
        r.id
    FROM public.recurring_transaction r
    JOIN public.app_user u ON u.id = r.user_id
    WHERE r.is_active = true
    AND r.next_execution_date = p_date + u.notification_advance_days
    AND NOT EXISTS (
        SELECT 1 FROM public.notification n
        WHERE n.related_entity_id = r.id
        AND n.notification_type = 'RECURRING_TRANSACTION'
        AND n.created_at >= CURRENT_DATE
    );

    RETURN v_result;
END;
$$ LANGUAGE plpgsql;

-- #################################################
-- AUTOMATIZACIÓN
-- #################################################

-- Crear trabajo programado para procesar transacciones recurrentes
SELECT cron.schedule(
    'process-recurring-transactions',
    '0 1 * * *',  -- Ejecutar diariamente a la 1:00 AM
    $$
    SELECT public.process_recurring_transactions();
    $$
);

-- #################################################
-- FUNCIONES DE UTILIDAD
-- #################################################

-- Función: Obtener próximas transacciones recurrentes
CREATE OR REPLACE FUNCTION public.get_upcoming_recurring_transactions(
    p_user_id uuid,
    p_days integer DEFAULT 7
)
RETURNS TABLE (
    id uuid,
    name text,
    next_execution_date date,
    amount numeric,
    description text,
    days_until integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        r.id,
        r.name,
        r.next_execution_date,
        r.amount,
        r.description,
        r.next_execution_date - CURRENT_DATE as days_until
    FROM public.recurring_transaction r
    WHERE r.user_id = p_user_id
    AND r.is_active = true
    AND r.next_execution_date <= CURRENT_DATE + p_days
    ORDER BY r.next_execution_date;
END;
$$ LANGUAGE plpgsql;

-- Función: Reactivar transacción recurrente
CREATE OR REPLACE FUNCTION public.reactivate_recurring_transaction(
    p_transaction_id uuid,
    p_new_start_date date DEFAULT CURRENT_DATE
)
RETURNS void AS $$
BEGIN
    UPDATE public.recurring_transaction
    SET 
        is_active = true,
        start_date = p_new_start_date,
        next_execution_date = p_new_start_date,
        modified_at = CURRENT_TIMESTAMP
    WHERE id = p_transaction_id;

    -- Notificar reactivación
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
        user_id,
        'Transacción recurrente reactivada',
        'La transacción ' || name || ' ha sido reactivada y comenzará el ' || 
        to_char(p_new_start_date, 'DD/MM/YYYY'),
        'RECURRING_TRANSACTION',
        'MEDIUM',
        'recurring_transaction',
        id
    FROM public.recurring_transaction
    WHERE id = p_transaction_id;
END;
$$ LANGUAGE plpgsql;