-- #################################################
-- Extensión de Funcionalidades para Tarjetas de Crédito
-- #################################################

-- Este script extiende la funcionalidad del sistema para soportar
-- características específicas de tarjetas de crédito.

-- #################################################
-- NUEVAS TABLAS
-- #################################################

-- Tabla: credit_card_details
-- Propósito: Almacena detalles específicos de tarjetas de crédito
CREATE TABLE public.credit_card_details (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    account_id uuid NOT NULL REFERENCES public.account(id),
    credit_limit numeric(15,2) NOT NULL CHECK (credit_limit > 0),
    current_interest_rate numeric(5,2) NOT NULL CHECK (current_interest_rate >= 0),
    cut_off_day integer NOT NULL CHECK (cut_off_day BETWEEN 1 AND 31),
    payment_due_day integer NOT NULL CHECK (payment_due_day BETWEEN 1 AND 31),
    minimum_payment_percentage numeric(5,2) NOT NULL CHECK (minimum_payment_percentage > 0),
    created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modified_at timestamptz,
    CONSTRAINT unique_account_credit_card UNIQUE (account_id),
    CONSTRAINT valid_days_order CHECK (payment_due_day > cut_off_day OR payment_due_day < cut_off_day)
);

-- Tabla: credit_card_interest_history
-- Propósito: Mantiene historial de cambios en tasas de interés
CREATE TABLE public.credit_card_interest_history (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    credit_card_id uuid NOT NULL REFERENCES public.credit_card_details(id),
    old_rate numeric(5,2) NOT NULL CHECK (old_rate >= 0),
    new_rate numeric(5,2) NOT NULL CHECK (new_rate >= 0),
    change_date timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    reason text,
    created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Tabla: credit_card_statement
-- Propósito: Almacena estados de cuenta mensuales
CREATE TABLE public.credit_card_statement (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    credit_card_id uuid NOT NULL REFERENCES public.credit_card_details(id),
    statement_date date NOT NULL,
    cut_off_date date NOT NULL,
    due_date date NOT NULL,
    previous_balance numeric(15,2) NOT NULL,
    purchases_amount numeric(15,2) NOT NULL DEFAULT 0,
    payments_amount numeric(15,2) NOT NULL DEFAULT 0,
    interests_amount numeric(15,2) NOT NULL DEFAULT 0,
    ending_balance numeric(15,2) NOT NULL,
    minimum_payment numeric(15,2) NOT NULL,
    remaining_credit numeric(15,2) NOT NULL,
    status varchar(20) NOT NULL CHECK (
        status IN ('PENDING', 'PAID_MINIMUM', 'PAID_FULL')
    ),
    created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modified_at timestamptz,
    CONSTRAINT valid_dates CHECK (
        statement_date <= cut_off_date AND
        cut_off_date < due_date
    ),
    CONSTRAINT unique_statement_period UNIQUE (credit_card_id, statement_date)
);

-- Tabla: installment_purchase
-- Propósito: Gestiona compras a meses sin intereses
CREATE TABLE public.installment_purchase (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    transaction_id uuid NOT NULL REFERENCES public.transaction(id),
    credit_card_id uuid NOT NULL REFERENCES public.credit_card_details(id),
    total_amount numeric(15,2) NOT NULL CHECK (total_amount > 0),
    number_of_installments integer NOT NULL CHECK (number_of_installments > 0),
    installment_amount numeric(15,2) NOT NULL CHECK (installment_amount > 0),
    remaining_installments integer NOT NULL,
    next_installment_date date NOT NULL,
    status varchar(20) NOT NULL CHECK (
        status IN ('ACTIVE', 'COMPLETED', 'CANCELLED')
    ),
    created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modified_at timestamptz
);

-- #################################################
-- MODIFICACIONES A TABLAS EXISTENTES
-- #################################################

-- Agregar columna para MSI en transacciones
ALTER TABLE public.transaction
ADD COLUMN installment_purchase_id uuid REFERENCES public.installment_purchase(id);

-- Agregar nuevo tipo de notificación para tarjetas
ALTER TABLE public.notification
ALTER COLUMN notification_type TYPE varchar(50);

-- Actualizar el CHECK constraint para incluir nuevos tipos
ALTER TABLE public.notification
DROP CONSTRAINT notification_notification_type_check;

ALTER TABLE public.notification
ADD CONSTRAINT notification_notification_type_check CHECK (
    notification_type IN (
        'RECURRING_TRANSACTION',
        'INSUFFICIENT_FUNDS',
        'GOAL_PROGRESS',
        'SYNC_ERROR',
        'SYSTEM',
        'CREDIT_CARD_DUE_DATE',
        'CREDIT_CARD_CUT_OFF',
        'CREDIT_CARD_LIMIT',
        'CREDIT_CARD_MINIMUM_PAYMENT'
    )
);

-- #################################################
-- FUNCIONES DE VALIDACIÓN Y CÁLCULO
-- #################################################

-- Función: Calcular fecha de corte
CREATE OR REPLACE FUNCTION public.calculate_next_cut_off_date(
    p_cut_off_day integer,
    p_from_date date DEFAULT CURRENT_DATE
)
RETURNS date AS $$
DECLARE
    v_next_date date;
BEGIN
    -- Calcular próxima fecha de corte
    v_next_date := date_trunc('month', p_from_date) + 
                   (p_cut_off_day - 1 || ' days')::interval;
    
    -- Si la fecha ya pasó, ir al siguiente mes
    IF v_next_date <= p_from_date THEN
        v_next_date := date_trunc('month', p_from_date + interval '1 month') + 
                       (p_cut_off_day - 1 || ' days')::interval;
    END IF;
    
    RETURN v_next_date;
END;
$$ LANGUAGE plpgsql;

-- Función: Calcular siguiente fecha de pago
CREATE OR REPLACE FUNCTION public.calculate_next_payment_date(
    p_payment_day integer,
    p_cut_off_date date
)
RETURNS date AS $$
DECLARE
    v_next_date date;
BEGIN
    -- Calcular próxima fecha de pago después del corte
    v_next_date := date_trunc('month', p_cut_off_date) + 
                   (p_payment_day - 1 || ' days')::interval;
    
    -- Si la fecha es antes del corte, ir al siguiente mes
    IF v_next_date <= p_cut_off_date THEN
        v_next_date := date_trunc('month', p_cut_off_date + interval '1 month') + 
                       (p_payment_day - 1 || ' days')::interval;
    END IF;
    
    RETURN v_next_date;
END;
$$ LANGUAGE plpgsql;

-- Función: Validar límite de crédito disponible
CREATE OR REPLACE FUNCTION public.validate_credit_limit(
    p_account_id uuid,
    p_amount numeric
)
RETURNS boolean AS $$
DECLARE
    v_current_balance numeric;
    v_credit_limit numeric;
BEGIN
    -- Obtener balance actual y límite de crédito
    SELECT 
        a.current_balance,
        cc.credit_limit INTO v_current_balance, v_credit_limit
    FROM public.account a
    JOIN public.credit_card_details cc ON cc.account_id = a.id
    WHERE a.id = p_account_id;
    
    -- Validar si hay suficiente crédito disponible
    RETURN (v_credit_limit + v_current_balance) >= p_amount;
END;
$$ LANGUAGE plpgsql;

-- #################################################
-- FUNCIONES DE GESTIÓN DE ESTADOS DE CUENTA
-- #################################################

-- Función: Generar estado de cuenta
CREATE OR REPLACE FUNCTION public.generate_credit_card_statement(
    p_credit_card_id uuid,
    p_statement_date date DEFAULT CURRENT_DATE
)
RETURNS uuid AS $$
DECLARE
    v_card record;
    v_previous_balance numeric(15,2);
    v_purchases numeric(15,2);
    v_payments numeric(15,2);
    v_interests numeric(15,2);
    v_ending_balance numeric(15,2);
    v_minimum_payment numeric(15,2);
    v_statement_id uuid;
    v_cut_off_date date;
    v_due_date date;
BEGIN
    -- Obtener información de la tarjeta
    SELECT 
        cc.*,
        a.current_balance
    INTO v_card
    FROM public.credit_card_details cc
    JOIN public.account a ON a.id = cc.account_id
    WHERE cc.id = p_credit_card_id;
    
    -- Calcular fechas importantes
    v_cut_off_date := public.calculate_next_cut_off_date(v_card.cut_off_day, p_statement_date);
    v_due_date := public.calculate_next_payment_date(v_card.payment_due_day, v_cut_off_date);
    
    -- Obtener balance del estado de cuenta anterior
    SELECT COALESCE(ending_balance, 0) INTO v_previous_balance
    FROM public.credit_card_statement
    WHERE credit_card_id = p_credit_card_id
    ORDER BY statement_date DESC
    LIMIT 1;
    
    -- Si no hay estado anterior, usar el balance actual
    IF v_previous_balance IS NULL THEN
        v_previous_balance := v_card.current_balance;
    END IF;
    
    -- Calcular movimientos del período
    SELECT COALESCE(SUM(amount), 0) INTO v_purchases
    FROM public.transaction
    WHERE account_id = v_card.account_id
    AND transaction_date BETWEEN p_statement_date AND v_cut_off_date
    AND transaction_type_id = (SELECT id FROM public.transaction_type WHERE code = 'EXPENSE');
    
    SELECT COALESCE(SUM(amount), 0) INTO v_payments
    FROM public.transaction
    WHERE account_id = v_card.account_id
    AND transaction_date BETWEEN p_statement_date AND v_cut_off_date
    AND transaction_type_id = (SELECT id FROM public.transaction_type WHERE code = 'INCOME');
    
    -- Calcular intereses si aplican
    IF v_previous_balance > 0 THEN
        v_interests := ROUND(
            (v_previous_balance * v_card.current_interest_rate / 100) / 12,
            2
        );
    ELSE
        v_interests := 0;
    END IF;
    
    -- Calcular balance final
    v_ending_balance := v_previous_balance + v_purchases - v_payments + v_interests;
    
    -- Calcular pago mínimo
    v_minimum_payment := GREATEST(
        ROUND(v_ending_balance * v_card.minimum_payment_percentage / 100, 2),
        500 -- Mínimo absoluto de 500
    );
    
    -- Crear nuevo estado de cuenta
    INSERT INTO public.credit_card_statement (
        credit_card_id,
        statement_date,
        cut_off_date,
        due_date,
        previous_balance,
        purchases_amount,
        payments_amount,
        interests_amount,
        ending_balance,
        minimum_payment,
        remaining_credit,
        status
    ) VALUES (
        p_credit_card_id,
        p_statement_date,
        v_cut_off_date,
        v_due_date,
        v_previous_balance,
        v_purchases,
        v_payments,
        v_interests,
        v_ending_balance,
        v_minimum_payment,
        v_card.credit_limit - v_ending_balance,
        'PENDING'
    ) RETURNING id INTO v_statement_id;
    
    RETURN v_statement_id;
END;
$$ LANGUAGE plpgsql;

-- #################################################
-- FUNCIONES DE NOTIFICACIÓN
-- #################################################

-- Función: Notificar eventos de tarjeta de crédito
CREATE OR REPLACE FUNCTION public.notify_credit_card_events()
RETURNS void AS $$
DECLARE
    v_record record;
BEGIN
    -- Notificar fechas de corte próximas (3 días antes)
    FOR v_record IN 
        SELECT 
            cc.id as credit_card_id,
            a.user_id,
            a.name as account_name,
            public.calculate_next_cut_off_date(cc.cut_off_day) as next_cut_off
        FROM public.credit_card_details cc
        JOIN public.account a ON a.id = cc.account_id
        WHERE public.calculate_next_cut_off_date(cc.cut_off_day) = CURRENT_DATE + interval '3 days'
    LOOP
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
            'Próxima fecha de corte',
            format('Tu tarjeta %s tendrá fecha de corte el %s',
                v_record.account_name,
                to_char(v_record.next_cut_off, 'DD/MM/YYYY')
            ),
            'CREDIT_CARD_CUT_OFF',
            'HIGH',
            'credit_card_details',
            v_record.credit_card_id
        );
    END LOOP;
    
    -- Notificar límite de crédito cercano (90% utilizado)
    FOR v_record IN 
        SELECT 
            cc.id as credit_card_id,
            a.user_id,
            a.name as account_name,
            cc.credit_limit,
            a.current_balance,
            round((a.current_balance::numeric / cc.credit_limit::numeric) * 100, 2) as utilization
        FROM public.credit_card_details cc
        JOIN public.account a ON a.id = cc.account_id
        WHERE a.current_balance::numeric / cc.credit_limit::numeric >= 0.9
    LOOP
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
            'Límite de crédito cercano',
            format('Tu tarjeta %s está al %s%% de su límite de crédito',
                v_record.account_name,
                v_record.utilization
            ),
            'CREDIT_CARD_LIMIT',
            'HIGH',
            'credit_card_details',
            v_record.credit_card_id
        );
    END LOOP;

    -- Notificar pagos mínimos pendientes
    FOR v_record IN 
        SELECT 
            cs.id as statement_id,
            cc.id as credit_card_id,
            a.user_id,
            a.name as account_name,
            cs.minimum_payment,
            cs.due_date
        FROM public.credit_card_statement cs
        JOIN public.credit_card_details cc ON cc.id = cs.credit_card_id
        JOIN public.account a ON a.id = cc.account_id
        WHERE cs.status = 'PENDING'
        AND cs.due_date = CURRENT_DATE + interval '5 days'
    LOOP
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
            'Pago mínimo pendiente',
            format('Tu tarjeta %s requiere un pago mínimo de %s antes del %s',
                v_record.account_name,
                to_char(v_record.minimum_payment, 'FM999,999,999.00'),
                to_char(v_record.due_date, 'DD/MM/YYYY')
            ),
            'CREDIT_CARD_MINIMUM_PAYMENT',
            'HIGH',
            'credit_card_statement',
            v_record.statement_id
        );
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- #################################################
-- TRIGGERS Y FUNCIONES DE MANTENIMIENTO
-- #################################################

-- Función: Validar y registrar cambios de tasa de interés
CREATE OR REPLACE FUNCTION public.track_interest_rate_changes()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.current_interest_rate != NEW.current_interest_rate THEN
        INSERT INTO public.credit_card_interest_history (
            credit_card_id,
            old_rate,
            new_rate,
            reason
        ) VALUES (
            NEW.id,
            OLD.current_interest_rate,
            NEW.current_interest_rate,
            'Actualización manual de tasa'
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger: Seguimiento de cambios en tasas
CREATE TRIGGER track_interest_rate_changes_trigger
    AFTER UPDATE OF current_interest_rate ON public.credit_card_details
    FOR EACH ROW
    EXECUTE FUNCTION public.track_interest_rate_changes();

-- Función: Validar transacciones de tarjeta de crédito
CREATE OR REPLACE FUNCTION public.validate_credit_card_transaction()
RETURNS TRIGGER AS $$
DECLARE
    v_account_type text;
    v_transaction_type text;
    v_available_credit numeric;
BEGIN
    -- Obtener tipo de cuenta
    SELECT at.code INTO v_account_type
    FROM public.account a
    JOIN public.account_type at ON at.id = a.account_type_id
    WHERE a.id = NEW.account_id;

    -- Si no es tarjeta de crédito, permitir la transacción
    IF v_account_type != 'CREDIT_CARD' THEN
        RETURN NEW;
    END IF;

    -- Obtener tipo de transacción
    SELECT code INTO v_transaction_type
    FROM public.transaction_type
    WHERE id = NEW.transaction_type_id;

    -- Para gastos, validar límite de crédito
    IF v_transaction_type = 'EXPENSE' THEN
        IF NOT public.validate_credit_limit(NEW.account_id, NEW.amount) THEN
            RAISE EXCEPTION 'La transacción excede el límite de crédito disponible';
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger: Validación de transacciones
CREATE TRIGGER validate_credit_card_transaction_trigger
    BEFORE INSERT ON public.transaction
    FOR EACH ROW
    EXECUTE FUNCTION public.validate_credit_card_transaction();

-- Función: Actualizar MSI
CREATE OR REPLACE FUNCTION public.update_installment_purchases()
RETURNS void AS $$
DECLARE
    v_record record;
BEGIN
    FOR v_record IN 
        SELECT ip.*
        FROM public.installment_purchase ip
        WHERE ip.status = 'ACTIVE'
        AND ip.next_installment_date <= CURRENT_DATE
    LOOP
        -- Registrar cargo de mensualidad
        INSERT INTO public.transaction (
            user_id,
            transaction_date,
            description,
            amount,
            transaction_type_id,
            category_id,
            subcategory_id,
            account_id,
            installment_purchase_id
        )
        SELECT 
            t.user_id,
            CURRENT_DATE,
            'Mensualidad MSI: ' || t.description,
            v_record.installment_amount,
            t.transaction_type_id,
            t.category_id,
            t.subcategory_id,
            t.account_id,
            v_record.id
        FROM public.transaction t
        WHERE t.id = v_record.transaction_id;

        -- Actualizar registro de MSI
        UPDATE public.installment_purchase
        SET 
            remaining_installments = remaining_installments - 1,
            next_installment_date = next_installment_date + interval '1 month',
            status = CASE 
                WHEN remaining_installments - 1 = 0 THEN 'COMPLETED'
                ELSE 'ACTIVE'
            END,
            modified_at = CURRENT_TIMESTAMP
        WHERE id = v_record.id;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- #################################################
-- FUNCIONES DE REPORTE
-- #################################################

-- Función: Obtener resumen de tarjeta de crédito
CREATE OR REPLACE FUNCTION public.get_credit_card_summary(
    p_account_id uuid
)
RETURNS TABLE (
    credit_limit numeric,
    current_balance numeric,
    available_credit numeric,
    current_interest_rate numeric,
    next_cut_off_date date,
    next_payment_date date,
    active_installment_purchases bigint,
    total_installment_amount numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        cc.credit_limit,
        a.current_balance,
        cc.credit_limit + a.current_balance as available_credit,
        cc.current_interest_rate,
        public.calculate_next_cut_off_date(cc.cut_off_day) as next_cut_off_date,
        public.calculate_next_payment_date(
            cc.payment_due_day, 
            public.calculate_next_cut_off_date(cc.cut_off_day)
        ) as next_payment_date,
        COUNT(ip.id) as active_installment_purchases,
        COALESCE(SUM(ip.remaining_installments * ip.installment_amount), 0) as total_installment_amount
    FROM public.credit_card_details cc
    JOIN public.account a ON a.id = cc.account_id
    LEFT JOIN public.installment_purchase ip ON ip.credit_card_id = cc.id 
        AND ip.status = 'ACTIVE'
    WHERE cc.account_id = p_account_id
    GROUP BY cc.credit_limit, a.current_balance, cc.current_interest_rate, 
             cc.cut_off_day, cc.payment_due_day;
END;
$$ LANGUAGE plpgsql;

-- Función: Obtener historial de estados de cuenta
CREATE OR REPLACE FUNCTION public.get_credit_card_statements(
    p_account_id uuid,
    p_months integer DEFAULT 12
)
RETURNS TABLE (
    statement_date date,
    cut_off_date date,
    due_date date,
    previous_balance numeric,
    purchases_amount numeric,
    payments_amount numeric,
    interests_amount numeric,
    ending_balance numeric,
    minimum_payment numeric,
    status text
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        cs.statement_date,
        cs.cut_off_date,
        cs.due_date,
        cs.previous_balance,
        cs.purchases_amount,
        cs.payments_amount,
        cs.interests_amount,
        cs.ending_balance,
        cs.minimum_payment,
        cs.status
    FROM public.credit_card_statement cs
    JOIN public.credit_card_details cc ON cc.id = cs.credit_card_id
    WHERE cc.account_id = p_account_id
    AND cs.statement_date >= CURRENT_DATE - (p_months || ' months')::interval
    ORDER BY cs.statement_date DESC;
END;
$$ LANGUAGE plpgsql;

-- #################################################
-- TAREAS PROGRAMADAS
-- #################################################

-- Programar generación de estados de cuenta
SELECT cron.schedule(
    'generate-credit-card-statements',
    '0 1 * * *',  -- Ejecutar diariamente a la 1:00 AM
    $$
    DO 
    $do$
    DECLARE
        v_record record;
    BEGIN
        FOR v_record IN 
            SELECT cc.id
            FROM public.credit_card_details cc
            WHERE public.calculate_next_cut_off_date(cc.cut_off_day) = CURRENT_DATE
        LOOP
            PERFORM public.generate_credit_card_statement(v_record.id);
        END LOOP;
    END
    $do$;
    $$
);

-- Programar actualización de MSI
SELECT cron.schedule(
    'update-installment-purchases',
    '0 2 * * *',  -- Ejecutar diariamente a las 2:00 AM
    $$
    SELECT public.update_installment_purchases();
    $$
);

-- Programar notificaciones
SELECT cron.schedule(
    'credit-card-notifications',
    '0 8 * * *',  -- Ejecutar diariamente a las 8:00 AM
    $$
    SELECT public.notify_credit_card_events();
    $$
);

-- #################################################
-- POLÍTICAS DE SEGURIDAD
-- #################################################

-- Habilitar RLS para nuevas tablas
ALTER TABLE public.credit_card_details ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.credit_card_interest_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.credit_card_statement ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.installment_purchase ENABLE ROW LEVEL SECURITY;

-- Políticas para credit_card_details
CREATE POLICY "Usuarios pueden ver sus tarjetas" ON public.credit_card_details
    FOR SELECT USING (
        auth.uid() = (
            SELECT user_id FROM public.account WHERE id = account_id
        )
    );

CREATE POLICY "Usuarios pueden actualizar sus tarjetas" ON public.credit_card_details
    FOR UPDATE USING (
        auth.uid() = (
            SELECT user_id FROM public.account WHERE id = account_id
        )
    );

-- Políticas para credit_card_interest_history
CREATE POLICY "Usuarios pueden ver historial de sus tarjetas" ON public.credit_card_interest_history
    FOR SELECT USING (
        auth.uid() = (
            SELECT a.user_id 
            FROM public.account a
            JOIN public.credit_card_details cc ON cc.account_id = a.id
            WHERE cc.id = credit_card_id
        )
    );

-- Políticas para credit_card_statement
CREATE POLICY "Usuarios pueden ver estados de cuenta" ON public.credit_card_statement
    FOR SELECT USING (
        auth.uid() = (
            SELECT a.user_id 
            FROM public.account a
            JOIN public.credit_card_details cc ON cc.account_id = a.id
            WHERE cc.id = credit_card_id
        )
    );

-- Políticas para installment_purchase
CREATE POLICY "Usuarios pueden ver sus MSI" ON public.installment_purchase
    FOR SELECT USING (
        auth.uid() = (
            SELECT a.user_id 
            FROM public.account a
            JOIN public.credit_card_details cc ON cc.account_id = a.id
            WHERE cc.id = credit_card_id
        )
    );

-- #################################################
-- ÍNDICES
-- #################################################

-- Índices para credit_card_details
CREATE INDEX idx_credit_card_details_account ON public.credit_card_details(account_id);
CREATE INDEX idx_credit_card_cut_off ON public.credit_card_details(cut_off_day);

-- Índices para credit_card_statement
CREATE INDEX idx_credit_card_statement_dates ON public.credit_card_statement(credit_card_id, statement_date);
CREATE INDEX idx_credit_card_statement_due ON public.credit_card_statement(credit_card_id, due_date)
    WHERE status = 'PENDING';

-- Índices para installment_purchase
CREATE INDEX idx_installment_purchase_active ON public.installment_purchase(credit_card_id, next_installment_date)
    WHERE status = 'ACTIVE';




-- First, drop the existing constraint
ALTER TABLE public.account_type 
DROP CONSTRAINT valid_system_account_types;

-- Now we can insert the new type
INSERT INTO public.account_type (
    code,
    name,
    description,
    is_system
) VALUES (
    'LOAN',
    'Préstamos',
    'Préstamos y créditos bancarios',
    true
);

-- #################################################
-- FIN DEL SCRIPT
-- #################################################