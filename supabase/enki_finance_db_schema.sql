--
-- PostgreSQL database dump
--

-- Dumped from database version 15.8
-- Dumped by pg_dump version 17.3

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: enki_finance; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA enki_finance;


ALTER SCHEMA enki_finance OWNER TO postgres;

--
-- Name: goal_progress_status; Type: TYPE; Schema: enki_finance; Owner: postgres
--

CREATE TYPE enki_finance.goal_progress_status AS (
	percentage_complete numeric(5,2),
	amount_remaining numeric(15,2),
	days_remaining integer,
	is_on_track boolean,
	required_daily_amount numeric(15,2)
);


ALTER TYPE enki_finance.goal_progress_status OWNER TO postgres;

--
-- Name: recurring_process_result; Type: TYPE; Schema: enki_finance; Owner: postgres
--

CREATE TYPE enki_finance.recurring_process_result AS (
	transactions_created integer,
	notifications_sent integer,
	errors_encountered integer
);


ALTER TYPE enki_finance.recurring_process_result OWNER TO postgres;

--
-- Name: archive_completed_goals(integer); Type: FUNCTION; Schema: enki_finance; Owner: postgres
--

CREATE FUNCTION enki_finance.archive_completed_goals(p_days_threshold integer DEFAULT 30) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_archived_count integer;
BEGIN
    UPDATE enki_finance.financial_goal
    SET is_active = false
    WHERE status = 'COMPLETED'
    AND modified_at < CURRENT_DATE - p_days_threshold
    AND is_active = true;

    GET DIAGNOSTICS v_archived_count = ROW_COUNT;
    RETURN v_archived_count;
END;
$$;


ALTER FUNCTION enki_finance.archive_completed_goals(p_days_threshold integer) OWNER TO postgres;

--
-- Name: calculate_goal_progress(numeric, numeric, date, date); Type: FUNCTION; Schema: enki_finance; Owner: postgres
--

CREATE FUNCTION enki_finance.calculate_goal_progress(p_current_amount numeric, p_target_amount numeric, p_start_date date, p_target_date date) RETURNS enki_finance.goal_progress_status
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_result enki_finance.goal_progress_status;
    v_total_days integer;
    v_elapsed_days integer;
    v_expected_amount numeric(15,2);
BEGIN
    -- Calcular porcentaje completado
    v_result.percentage_complete := round(
        (p_current_amount / NULLIF(p_target_amount, 0)) * 100,
        2
    );

    -- Calcular monto restante
    v_result.amount_remaining := p_target_amount - p_current_amount;

    -- Calcular días restantes
    v_result.days_remaining := p_target_date - CURRENT_DATE;

    -- Calcular si está en camino
    v_total_days := p_target_date - p_start_date;
    v_elapsed_days := CURRENT_DATE - p_start_date;
    
    -- Calcular monto esperado según el tiempo transcurrido
    v_expected_amount := (p_target_amount / v_total_days) * v_elapsed_days;
    
    -- Determinar si está en camino
    v_result.is_on_track := p_current_amount >= v_expected_amount;

    -- Calcular monto diario requerido para alcanzar la meta
    IF v_result.days_remaining > 0 THEN
        v_result.required_daily_amount := round(
            v_result.amount_remaining / v_result.days_remaining,
            2
        );
    ELSE
        v_result.required_daily_amount := 0;
    END IF;

    RETURN v_result;
END;
$$;


ALTER FUNCTION enki_finance.calculate_goal_progress(p_current_amount numeric, p_target_amount numeric, p_start_date date, p_target_date date) OWNER TO postgres;

--
-- Name: calculate_next_cut_off_date(integer, date); Type: FUNCTION; Schema: enki_finance; Owner: postgres
--

CREATE FUNCTION enki_finance.calculate_next_cut_off_date(p_cut_off_day integer, p_from_date date DEFAULT CURRENT_DATE) RETURNS date
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION enki_finance.calculate_next_cut_off_date(p_cut_off_day integer, p_from_date date) OWNER TO postgres;

--
-- Name: calculate_next_execution_date(character varying, date, date); Type: FUNCTION; Schema: enki_finance; Owner: postgres
--

CREATE FUNCTION enki_finance.calculate_next_execution_date(p_frequency character varying, p_start_date date, p_last_execution date DEFAULT NULL::date) RETURNS date
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION enki_finance.calculate_next_execution_date(p_frequency character varying, p_start_date date, p_last_execution date) OWNER TO postgres;

--
-- Name: calculate_next_payment_date(integer, date); Type: FUNCTION; Schema: enki_finance; Owner: postgres
--

CREATE FUNCTION enki_finance.calculate_next_payment_date(p_payment_day integer, p_cut_off_date date) RETURNS date
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION enki_finance.calculate_next_payment_date(p_payment_day integer, p_cut_off_date date) OWNER TO postgres;

--
-- Name: check_connection(); Type: FUNCTION; Schema: enki_finance; Owner: postgres
--

CREATE FUNCTION enki_finance.check_connection() RETURNS boolean
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
begin
  return true;
end;
$$;


ALTER FUNCTION enki_finance.check_connection() OWNER TO postgres;

--
-- Name: export_transactions_to_excel(uuid, date, date); Type: FUNCTION; Schema: enki_finance; Owner: postgres
--

CREATE FUNCTION enki_finance.export_transactions_to_excel(p_user_id uuid, p_start_date date, p_end_date date) RETURNS TABLE(transaction_date date, transaction_type text, category text, subcategory text, amount numeric, account_name text, jar_name text, description text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        t.transaction_date,
        tt.name as transaction_type,
        c.name as category,
        sc.name as subcategory,
        t.amount,
        a.name as account_name,
        j.name as jar_name,
        t.description
    FROM enki_finance.transaction t
    JOIN enki_finance.transaction_type tt ON tt.id = t.transaction_type_id
    JOIN enki_finance.category c ON c.id = t.category
    JOIN enki_finance.subcategory sc ON sc.id = t.sub_category
    JOIN enki_finance.account a ON a.id = t.account
    LEFT JOIN enki_finance.jar j ON j.id = t.jar_id
    WHERE t.user_id = p_user_id
    AND t.transaction_date BETWEEN p_start_date AND p_end_date
    ORDER BY t.transaction_date DESC;
END;
$$;


ALTER FUNCTION enki_finance.export_transactions_to_excel(p_user_id uuid, p_start_date date, p_end_date date) OWNER TO postgres;

--
-- Name: generate_credit_card_statement(uuid, date); Type: FUNCTION; Schema: enki_finance; Owner: postgres
--

CREATE FUNCTION enki_finance.generate_credit_card_statement(p_credit_card_id uuid, p_statement_date date DEFAULT CURRENT_DATE) RETURNS uuid
    LANGUAGE plpgsql
    AS $$DECLARE
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
    FROM enki_finance.credit_card_details cc
    JOIN enki_finance.account a ON a.id = cc.account_id
    WHERE cc.id = p_credit_card_id;
    
    -- Calcular fechas importantes
    v_cut_off_date := enki_finance.calculate_next_cut_off_date(v_card.cut_off_day, p_statement_date);
    v_due_date := enki_finance.calculate_next_payment_date(v_card.payment_due_day, v_cut_off_date);
    
    -- Obtener balance del estado de cuenta anterior
    SELECT COALESCE(ending_balance, 0) INTO v_previous_balance
    FROM enki_finance.credit_card_statement
    WHERE credit_card_id = p_credit_card_id
    ORDER BY statement_date DESC
    LIMIT 1;
    
    -- Si no hay estado anterior, usar el balance actual
    IF v_previous_balance IS NULL THEN
        v_previous_balance := v_card.current_balance;
    END IF;
    
    -- Calcular movimientos del período
    SELECT COALESCE(SUM(amount), 0) INTO v_purchases
    FROM enki_finance.transaction
    WHERE account_id = v_card.account_id
    AND transaction_date BETWEEN p_statement_date AND v_cut_off_date
    AND transaction_type_id = (SELECT id FROM enki_finance.transaction_type WHERE code = 'EXPENSE');
    
    SELECT COALESCE(SUM(amount), 0) INTO v_payments
    FROM enki_finance.transaction
    WHERE account_id = v_card.account_id
    AND transaction_date BETWEEN p_statement_date AND v_cut_off_date
    AND transaction_type_id = (SELECT id FROM enki_finance.transaction_type WHERE code = 'INCOME');
    
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
    INSERT INTO enki_finance.credit_card_statement (
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
END;$$;


ALTER FUNCTION enki_finance.generate_credit_card_statement(p_credit_card_id uuid, p_statement_date date) OWNER TO postgres;

--
-- Name: get_credit_card_statements(uuid, integer); Type: FUNCTION; Schema: enki_finance; Owner: postgres
--

CREATE FUNCTION enki_finance.get_credit_card_statements(p_account_id uuid, p_months integer DEFAULT 12) RETURNS TABLE(statement_date date, cut_off_date date, due_date date, previous_balance numeric, purchases_amount numeric, payments_amount numeric, interests_amount numeric, ending_balance numeric, minimum_payment numeric, status text)
    LANGUAGE plpgsql
    AS $$
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
    FROM enki_finance.credit_card_statement cs
    JOIN enki_finance.credit_card_details cc ON cc.id = cs.credit_card_id
    WHERE cc.account_id = p_account_id
    AND cs.statement_date >= CURRENT_DATE - (p_months || ' months')::interval
    ORDER BY cs.statement_date DESC;
END;
$$;


ALTER FUNCTION enki_finance.get_credit_card_statements(p_account_id uuid, p_months integer) OWNER TO postgres;

--
-- Name: get_transfer_history(uuid, date, date, text, integer); Type: FUNCTION; Schema: enki_finance; Owner: postgres
--

CREATE FUNCTION enki_finance.get_transfer_history(p_user_id uuid, p_start_date date DEFAULT NULL::date, p_end_date date DEFAULT NULL::date, p_transfer_type text DEFAULT NULL::text, p_limit integer DEFAULT 100) RETURNS TABLE(transfer_id uuid, transfer_date date, transfer_type text, source_name text, target_name text, amount numeric, converted_amount numeric, description text)
    LANGUAGE plpgsql
    AS $$
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
    FROM enki_finance.transfer t
    JOIN enki_finance.transfer_summary s ON s.transfer_id = t.id
    WHERE t.user_id = p_user_id
    AND (p_start_date IS NULL OR t.transfer_date >= p_start_date)
    AND (p_end_date IS NULL OR t.transfer_date <= p_end_date)
    AND (p_transfer_type IS NULL OR t.transfer_type::text = p_transfer_type)
    ORDER BY t.transfer_date DESC
    LIMIT p_limit;
END;
$$;


ALTER FUNCTION enki_finance.get_transfer_history(p_user_id uuid, p_start_date date, p_end_date date, p_transfer_type text, p_limit integer) OWNER TO postgres;

--
-- Name: get_upcoming_recurring_transactions(uuid, integer); Type: FUNCTION; Schema: enki_finance; Owner: postgres
--

CREATE FUNCTION enki_finance.get_upcoming_recurring_transactions(p_user_id uuid, p_days integer DEFAULT 7) RETURNS TABLE(id uuid, name text, next_execution_date date, amount numeric, description text, days_until integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        r.id,
        r.name,
        r.next_execution_date,
        r.amount,
        r.description,
        r.next_execution_date - CURRENT_DATE as days_until
    FROM enki_finance.recurring_transaction r
    WHERE r.user_id = p_user_id
    AND r.is_active = true
    AND r.next_execution_date <= CURRENT_DATE + p_days
    ORDER BY r.next_execution_date;
END;
$$;


ALTER FUNCTION enki_finance.get_upcoming_recurring_transactions(p_user_id uuid, p_days integer) OWNER TO postgres;

--
-- Name: handle_new_user(); Type: FUNCTION; Schema: enki_finance; Owner: postgres
--

CREATE FUNCTION enki_finance.handle_new_user() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$DECLARE
    default_currency_id uuid;
BEGIN
    -- Get the default currency (MXN)
    SELECT id INTO default_currency_id
    FROM enki_finance.currency
    WHERE code = 'MXN';

    -- Insert the new user into enki_finance.app_user
    INSERT INTO enki_finance.app_user (
        id,
        email,
        first_name,
        last_name,
        default_currency_id
    )
    VALUES (
        NEW.id,
        NEW.email,
        NEW.raw_user_meta_data->>'first_name',
        NEW.raw_user_meta_data->>'last_name',
        default_currency_id
    );

    -- Create default jar balances for the user
    INSERT INTO enki_finance.jar_balance (user_id, jar_id, current_balance)
    SELECT 
        NEW.id,
        j.id,
        0
    FROM enki_finance.jar j;

    RETURN NEW;
END;$$;


ALTER FUNCTION enki_finance.handle_new_user() OWNER TO postgres;

--
-- Name: notify_credit_card_events(); Type: FUNCTION; Schema: enki_finance; Owner: postgres
--

CREATE FUNCTION enki_finance.notify_credit_card_events() RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_record record;
BEGIN
    -- Notificar fechas de corte próximas (3 días antes)
    FOR v_record IN 
        SELECT 
            cc.id as credit_card_id,
            a.user_id,
            a.name as account_name,
            enki_finance.calculate_next_cut_off_date(cc.cut_off_day) as next_cut_off
        FROM enki_finance.credit_card_details cc
        JOIN enki_finance.account a ON a.id = cc.account_id
        WHERE enki_finance.calculate_next_cut_off_date(cc.cut_off_day) = CURRENT_DATE + interval '3 days'
    LOOP
        INSERT INTO enki_finance.notification (
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
        FROM enki_finance.credit_card_details cc
        JOIN enki_finance.account a ON a.id = cc.account_id
        WHERE a.current_balance::numeric / cc.credit_limit::numeric >= 0.9
    LOOP
        INSERT INTO enki_finance.notification (
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
        FROM enki_finance.credit_card_statement cs
        JOIN enki_finance.credit_card_details cc ON cc.id = cs.credit_card_id
        JOIN enki_finance.account a ON a.id = cc.account_id
        WHERE cs.status = 'PENDING'
        AND cs.due_date = CURRENT_DATE + interval '5 days'
    LOOP
        INSERT INTO enki_finance.notification (
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
$$;


ALTER FUNCTION enki_finance.notify_credit_card_events() OWNER TO postgres;

--
-- Name: notify_transfer(); Type: FUNCTION; Schema: enki_finance; Owner: postgres
--

CREATE FUNCTION enki_finance.notify_transfer() RETURNS trigger
    LANGUAGE plpgsql
    AS $$BEGIN
    -- Insertar notificación
    INSERT INTO enki_finance.notification (
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
                    (SELECT name FROM enki_finance.account WHERE id = NEW.from_account_id),
                    (SELECT name FROM enki_finance.account WHERE id = NEW.to_account_id)
                )
            ELSE
                format('Transferencia de %s realizada desde %s a %s',
                    to_char(NEW.amount, 'FM999,999,999.00'),
                    (SELECT name FROM enki_finance.jar WHERE id = NEW.from_jar_id),
                    (SELECT name FROM enki_finance.jar WHERE id = NEW.to_jar_id)
                )
        END,
        'TRANSFER',
        'LOW',
        'transfer',
        NEW.id;

    RETURN NEW;
END;$$;


ALTER FUNCTION enki_finance.notify_transfer() OWNER TO postgres;

--
-- Name: process_recurring_transactions(date); Type: FUNCTION; Schema: enki_finance; Owner: postgres
--

CREATE FUNCTION enki_finance.process_recurring_transactions(p_date date DEFAULT CURRENT_DATE) RETURNS enki_finance.recurring_process_result
    LANGUAGE plpgsql
    AS $$DECLARE
    v_result enki_finance.recurring_process_result;
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
        FROM enki_finance.recurring_transaction r
        JOIN enki_finance.app_user u ON u.id = r.user_id
        WHERE r.is_active = true
        AND r.next_execution_date <= p_date
        AND (r.end_date IS NULL OR r.end_date >= p_date)
    LOOP
        -- Validar si la transacción puede ejecutarse
        v_valid := enki_finance.validate_recurring_transaction(
            v_record.user_id,
            v_record.amount,
            v_record.transaction_type_id,
            v_record.account_id,
            v_record.jar_id
        );

        IF v_valid THEN
            BEGIN
                -- Crear la transacción
                INSERT INTO enki_finance.transaction (
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
                UPDATE enki_finance.recurring_transaction
                SET 
                    last_execution_date = p_date,
                    next_execution_date = enki_finance.calculate_next_execution_date(
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
                INSERT INTO enki_finance.notification (
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
            INSERT INTO enki_finance.notification (
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
    INSERT INTO enki_finance.notification (
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
    FROM enki_finance.recurring_transaction r
    JOIN enki_finance.app_user u ON u.id = r.user_id
    WHERE r.is_active = true
    AND r.next_execution_date = p_date + u.notification_advance_days
    AND NOT EXISTS (
        SELECT 1 FROM enki_finance.notification n
        WHERE n.related_entity_id = r.id
        AND n.notification_type = 'RECURRING_TRANSACTION'
        AND n.created_at >= CURRENT_DATE
    );

    RETURN v_result;
END;$$;


ALTER FUNCTION enki_finance.process_recurring_transactions(p_date date) OWNER TO postgres;

--
-- Name: reactivate_recurring_transaction(uuid, date); Type: FUNCTION; Schema: enki_finance; Owner: postgres
--

CREATE FUNCTION enki_finance.reactivate_recurring_transaction(p_transaction_id uuid, p_new_start_date date DEFAULT CURRENT_DATE) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE enki_finance.recurring_transaction
    SET 
        is_active = true,
        start_date = p_new_start_date,
        next_execution_date = p_new_start_date,
        modified_at = CURRENT_TIMESTAMP
    WHERE id = p_transaction_id;

    -- Notificar reactivación
    INSERT INTO enki_finance.notification (
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
    FROM enki_finance.recurring_transaction
    WHERE id = p_transaction_id;
END;
$$;


ALTER FUNCTION enki_finance.reactivate_recurring_transaction(p_transaction_id uuid, p_new_start_date date) OWNER TO postgres;

--
-- Name: record_balance_history(); Type: FUNCTION; Schema: enki_finance; Owner: postgres
--

CREATE FUNCTION enki_finance.record_balance_history() RETURNS trigger
    LANGUAGE plpgsql
    AS $$BEGIN
    IF TG_TABLE_NAME = 'transaction' THEN
        -- Registrar cambio en cuenta
        INSERT INTO enki_finance.balance_history (
            user_id, 
            account_id,
            old_balance,
            new_balance,
            change_amount,
            change_type,
            reference_type,
            reference_id
        )
        VALUES (
            NEW.user_id,
            NEW.account_id,
            (SELECT current_balance FROM enki_finance.account WHERE id = NEW.account_id),
            (SELECT current_balance FROM enki_finance.account WHERE id = NEW.account_id) + 
                CASE 
                    WHEN EXISTS (
                        SELECT 1 FROM enki_finance.transaction_type t 
                        WHERE t.id = NEW.transaction_type_id AND t.code = 'EXPENSE'
                    ) THEN -NEW.amount
                    ELSE NEW.amount
                END,
            NEW.amount,
            'TRANSACTION',
            'transaction',
            NEW.id
        );

        -- Si es un gasto, registrar cambio en jarra
        IF EXISTS (
            SELECT 1 FROM enki_finance.transaction_type t 
            WHERE t.id = NEW.transaction_type_id AND t.code = 'EXPENSE'
        ) THEN
            INSERT INTO enki_finance.balance_history (
                user_id,
                jar_id,
                old_balance,
                new_balance,
                change_amount,
                change_type,
                reference_type,
                reference_id
            )
            VALUES (
                NEW.user_id,
                NEW.jar_id,
                (SELECT current_balance FROM enki_finance.jar_balance WHERE jar_id = NEW.jar_id AND user_id = NEW.user_id),
                (SELECT current_balance FROM enki_finance.jar_balance WHERE jar_id = NEW.jar_id AND user_id = NEW.user_id) - NEW.amount,
                NEW.amount,
                'TRANSACTION',
                'transaction',
                NEW.id
            );
        END IF;

    ELSIF TG_TABLE_NAME = 'transfer' THEN
        IF NEW.transfer_type = 'ACCOUNT_TO_ACCOUNT' THEN
            -- Registrar cambio en cuenta origen
            INSERT INTO enki_finance.balance_history (
                user_id,
                account_id,
                old_balance,
                new_balance,
                change_amount,
                change_type,
                reference_type,
                reference_id
            )
            VALUES (
                NEW.user_id,
                NEW.from_account_id,
                (SELECT current_balance FROM enki_finance.account WHERE id = NEW.from_account_id),
                (SELECT current_balance FROM enki_finance.account WHERE id = NEW.from_account_id) - NEW.amount,
                NEW.amount,
                'TRANSFER',
                'transfer',
                NEW.id
            );

            -- Registrar cambio en cuenta destino
            INSERT INTO enki_finance.balance_history (
                user_id,
                account_id,
                old_balance,
                new_balance,
                change_amount,
                change_type,
                reference_type,
                reference_id
            )
            VALUES (
                NEW.user_id,
                NEW.to_account_id,
                (SELECT current_balance FROM enki_finance.account WHERE id = NEW.to_account_id),
                (SELECT current_balance FROM enki_finance.account WHERE id = NEW.to_account_id) + (NEW.amount * NEW.exchange_rate),
                NEW.amount * NEW.exchange_rate,
                'TRANSFER',
                'transfer',
                NEW.id
            );

        ELSE
            -- Registrar cambio en jarra origen
            INSERT INTO enki_finance.balance_history (
                user_id,
                jar_id,
                old_balance,
                new_balance,
                change_amount,
                change_type,
                reference_type,
                reference_id
            )
            VALUES (
                NEW.user_id,
                NEW.from_jar_id,
                (SELECT current_balance FROM enki_finance.jar_balance WHERE jar_id = NEW.from_jar_id AND user_id = NEW.user_id),
                (SELECT current_balance FROM enki_finance.jar_balance WHERE jar_id = NEW.from_jar_id AND user_id = NEW.user_id) - NEW.amount,
                NEW.amount,
                CASE NEW.transfer_type
                    WHEN 'JAR_TO_JAR' THEN 'TRANSFER'
                    ELSE 'ROLLOVER'
                END,
                'transfer',
                NEW.id
            );

            -- Registrar cambio en jarra destino
            INSERT INTO enki_finance.balance_history (
                user_id,
                jar_id,
                old_balance,
                new_balance,
                change_amount,
                change_type,
                reference_type,
                reference_id
            )
            VALUES (
                NEW.user_id,
                NEW.to_jar_id,
                (SELECT current_balance FROM enki_finance.jar_balance WHERE jar_id = NEW.to_jar_id AND user_id = NEW.user_id),
                (SELECT current_balance FROM enki_finance.jar_balance WHERE jar_id = NEW.to_jar_id AND user_id = NEW.user_id) + NEW.amount,
                NEW.amount,
                CASE NEW.transfer_type
                    WHEN 'JAR_TO_JAR' THEN 'TRANSFER'
                    ELSE 'ROLLOVER'
                END,
                'transfer',
                NEW.id
            );
        END IF;
    END IF;

    RETURN NEW;
END;$$;


ALTER FUNCTION enki_finance.record_balance_history() OWNER TO postgres;

--
-- Name: remove_transaction_tag(uuid, text); Type: FUNCTION; Schema: enki_finance; Owner: postgres
--

CREATE FUNCTION enki_finance.remove_transaction_tag(p_transaction_id uuid, p_tag text) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE enki_finance.transaction
    SET tags = (
        SELECT jsonb_agg(value)
        FROM jsonb_array_elements(tags) AS t(value)
        WHERE value::text != p_tag::text
    )
    WHERE id = p_transaction_id;
END;
$$;


ALTER FUNCTION enki_finance.remove_transaction_tag(p_transaction_id uuid, p_tag text) OWNER TO postgres;

--
-- Name: search_transactions_by_notes(uuid, text); Type: FUNCTION; Schema: enki_finance; Owner: postgres
--

CREATE FUNCTION enki_finance.search_transactions_by_notes(p_user_id uuid, p_search_text text) RETURNS TABLE(id uuid, transaction_date date, description text, amount numeric, tags jsonb, notes text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        t.id,
        t.transaction_date,
        t.description,
        t.amount,
        t.tags,
        t.notes
    FROM enki_finance.transaction t
    WHERE t.user_id = p_user_id
    AND to_tsvector('spanish', COALESCE(t.notes, '')) @@ to_tsquery('spanish', p_search_text)
    ORDER BY t.transaction_date DESC;
END;
$$;


ALTER FUNCTION enki_finance.search_transactions_by_notes(p_user_id uuid, p_search_text text) OWNER TO postgres;

--
-- Name: search_transactions_by_tags(uuid, text[]); Type: FUNCTION; Schema: enki_finance; Owner: postgres
--

CREATE FUNCTION enki_finance.search_transactions_by_tags(p_user_id uuid, p_tags text[]) RETURNS TABLE(id uuid, transaction_date date, description text, amount numeric, tags jsonb, notes text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        t.id,
        t.transaction_date,
        t.description,
        t.amount,
        t.tags,
        t.notes
    FROM enki_finance.transaction t
    WHERE t.user_id = p_user_id
    AND t.tags @> jsonb_array_to_jsonb(p_tags::jsonb[])
    ORDER BY t.transaction_date DESC;
END;
$$;


ALTER FUNCTION enki_finance.search_transactions_by_tags(p_user_id uuid, p_tags text[]) OWNER TO postgres;

--
-- Name: track_interest_rate_changes(); Type: FUNCTION; Schema: enki_finance; Owner: postgres
--

CREATE FUNCTION enki_finance.track_interest_rate_changes() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF OLD.current_interest_rate != NEW.current_interest_rate THEN
        INSERT INTO enki_finance.credit_card_interest_history (
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
$$;


ALTER FUNCTION enki_finance.track_interest_rate_changes() OWNER TO postgres;

--
-- Name: update_installment_purchases(); Type: FUNCTION; Schema: enki_finance; Owner: postgres
--

CREATE FUNCTION enki_finance.update_installment_purchases() RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_record record;
BEGIN
    FOR v_record IN 
        SELECT ip.*
        FROM enki_finance.installment_purchase ip
        WHERE ip.status = 'ACTIVE'
        AND ip.next_installment_date <= CURRENT_DATE
    LOOP
        -- Registrar cargo de mensualidad
        INSERT INTO enki_finance.transaction (
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
        FROM enki_finance.transaction t
        WHERE t.id = v_record.transaction_id;

        -- Actualizar registro de MSI
        UPDATE enki_finance.installment_purchase
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
$$;


ALTER FUNCTION enki_finance.update_installment_purchases() OWNER TO postgres;

--
-- Name: update_modified_timestamp(); Type: FUNCTION; Schema: enki_finance; Owner: postgres
--

CREATE FUNCTION enki_finance.update_modified_timestamp() RETURNS trigger
    LANGUAGE plpgsql
    AS $$BEGIN
    NEW.modified_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;$$;


ALTER FUNCTION enki_finance.update_modified_timestamp() OWNER TO postgres;

--
-- Name: validate_recurring_transaction(uuid, numeric, uuid, uuid, uuid); Type: FUNCTION; Schema: enki_finance; Owner: postgres
--

CREATE FUNCTION enki_finance.validate_recurring_transaction(p_user_id uuid, p_amount numeric, p_transaction_type_id uuid, p_account_id uuid, p_jar_id uuid DEFAULT NULL::uuid) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_transaction_type_code text;
    v_current_balance numeric;
BEGIN
    -- Obtener tipo de transacción
    SELECT code INTO v_transaction_type_code
    FROM enki_finance.transaction_type
    WHERE id = p_transaction_type_id;

    -- Para gastos, validar saldo disponible
    IF v_transaction_type_code = 'EXPENSE' THEN
        -- Validar saldo en jarra si aplica
        IF p_jar_id IS NOT NULL THEN
            SELECT current_balance INTO v_current_balance
            FROM enki_finance.jar_balance
            WHERE user_id = p_user_id AND jar_id = p_jar_id;

            IF v_current_balance < p_amount THEN
                RETURN false;
            END IF;
        END IF;

        -- Validar saldo en cuenta
        SELECT current_balance INTO v_current_balance
        FROM enki_finance.account
        WHERE id = p_account_id AND user_id = p_user_id;

        IF v_current_balance < p_amount THEN
            RETURN false;
        END IF;
    END IF;

    RETURN true;
END;
$$;


ALTER FUNCTION enki_finance.validate_recurring_transaction(p_user_id uuid, p_amount numeric, p_transaction_type_id uuid, p_account_id uuid, p_jar_id uuid) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: account; Type: TABLE; Schema: enki_finance; Owner: postgres
--

CREATE TABLE enki_finance.account (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    account_type_id uuid NOT NULL,
    name text NOT NULL,
    description text,
    currency_id uuid NOT NULL,
    current_balance numeric(15,2) DEFAULT 0 NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    modified_at timestamp with time zone
);


ALTER TABLE enki_finance.account OWNER TO postgres;

--
-- Name: TABLE account; Type: COMMENT; Schema: enki_finance; Owner: postgres
--

COMMENT ON TABLE enki_finance.account IS 'Cuentas financieras de los usuarios';


--
-- Name: account_type; Type: TABLE; Schema: enki_finance; Owner: postgres
--

CREATE TABLE enki_finance.account_type (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    description text,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    modified_at timestamp with time zone
);


ALTER TABLE enki_finance.account_type OWNER TO postgres;

--
-- Name: TABLE account_type; Type: COMMENT; Schema: enki_finance; Owner: postgres
--

COMMENT ON TABLE enki_finance.account_type IS 'Tipos de cuenta soportados';


--
-- Name: app_user; Type: TABLE; Schema: enki_finance; Owner: postgres
--

CREATE TABLE enki_finance.app_user (
    id uuid NOT NULL,
    email text NOT NULL,
    first_name text,
    last_name text,
    default_currency_id uuid NOT NULL,
    notifications_enabled boolean DEFAULT true,
    notification_advance_days integer DEFAULT 1,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    modified_at timestamp with time zone,
    CONSTRAINT notification_advance_days_check CHECK (((notification_advance_days >= 0) AND (notification_advance_days <= 30))),
    CONSTRAINT valid_notification_days CHECK ((notification_advance_days > 0))
);


ALTER TABLE enki_finance.app_user OWNER TO postgres;

--
-- Name: TABLE app_user; Type: COMMENT; Schema: enki_finance; Owner: postgres
--

COMMENT ON TABLE enki_finance.app_user IS 'Stores user settings and preferences. Settings validation is now handled in the application domain layer.';


--
-- Name: COLUMN app_user.notification_advance_days; Type: COMMENT; Schema: enki_finance; Owner: postgres
--

COMMENT ON COLUMN enki_finance.app_user.notification_advance_days IS 'Días de anticipación para notificaciones recurrentes';


--
-- Name: balance_history; Type: TABLE; Schema: enki_finance; Owner: postgres
--

CREATE TABLE enki_finance.balance_history (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    account_id uuid,
    jar_id uuid,
    old_balance numeric(15,2) NOT NULL,
    new_balance numeric(15,2) NOT NULL,
    change_amount numeric(15,2) NOT NULL,
    change_type character varying(50) NOT NULL,
    reference_type character varying(50) NOT NULL,
    reference_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT balance_history_change_type_check CHECK (((change_type)::text = ANY ((ARRAY['TRANSACTION'::character varying, 'TRANSFER'::character varying, 'ADJUSTMENT'::character varying, 'ROLLOVER'::character varying])::text[]))),
    CONSTRAINT valid_target CHECK ((((account_id IS NOT NULL) AND (jar_id IS NULL)) OR ((account_id IS NULL) AND (jar_id IS NOT NULL))))
);


ALTER TABLE enki_finance.balance_history OWNER TO postgres;

--
-- Name: TABLE balance_history; Type: COMMENT; Schema: enki_finance; Owner: postgres
--

COMMENT ON TABLE enki_finance.balance_history IS 'Historial de cambios en balances';


--
-- Name: category; Type: TABLE; Schema: enki_finance; Owner: postgres
--

CREATE TABLE enki_finance.category (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    description text,
    transaction_type_id uuid NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    modified_at timestamp with time zone
);


ALTER TABLE enki_finance.category OWNER TO postgres;

--
-- Name: TABLE category; Type: COMMENT; Schema: enki_finance; Owner: postgres
--

COMMENT ON TABLE enki_finance.category IS 'Categorías para clasificación de transacciones';


--
-- Name: credit_card_details; Type: TABLE; Schema: enki_finance; Owner: postgres
--

CREATE TABLE enki_finance.credit_card_details (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    account_id uuid NOT NULL,
    credit_limit numeric(15,2) NOT NULL,
    current_interest_rate numeric(5,2) NOT NULL,
    cut_off_day integer NOT NULL,
    payment_due_day integer NOT NULL,
    minimum_payment_percentage numeric(5,2) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    modified_at timestamp with time zone,
    CONSTRAINT credit_card_details_credit_limit_check CHECK ((credit_limit > (0)::numeric)),
    CONSTRAINT credit_card_details_current_interest_rate_check CHECK ((current_interest_rate >= (0)::numeric)),
    CONSTRAINT credit_card_details_cut_off_day_check CHECK (((cut_off_day >= 1) AND (cut_off_day <= 31))),
    CONSTRAINT credit_card_details_minimum_payment_percentage_check CHECK ((minimum_payment_percentage > (0)::numeric)),
    CONSTRAINT credit_card_details_payment_due_day_check CHECK (((payment_due_day >= 1) AND (payment_due_day <= 31))),
    CONSTRAINT valid_days_order CHECK (((payment_due_day > cut_off_day) OR (payment_due_day < cut_off_day)))
);


ALTER TABLE enki_finance.credit_card_details OWNER TO postgres;

--
-- Name: credit_card_interest_history; Type: TABLE; Schema: enki_finance; Owner: postgres
--

CREATE TABLE enki_finance.credit_card_interest_history (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    credit_card_id uuid NOT NULL,
    old_rate numeric(5,2) NOT NULL,
    new_rate numeric(5,2) NOT NULL,
    change_date timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    reason text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT credit_card_interest_history_new_rate_check CHECK ((new_rate >= (0)::numeric)),
    CONSTRAINT credit_card_interest_history_old_rate_check CHECK ((old_rate >= (0)::numeric))
);


ALTER TABLE enki_finance.credit_card_interest_history OWNER TO postgres;

--
-- Name: credit_card_statement; Type: TABLE; Schema: enki_finance; Owner: postgres
--

CREATE TABLE enki_finance.credit_card_statement (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    credit_card_id uuid NOT NULL,
    statement_date date NOT NULL,
    cut_off_date date NOT NULL,
    due_date date NOT NULL,
    previous_balance numeric(15,2) NOT NULL,
    purchases_amount numeric(15,2) DEFAULT 0 NOT NULL,
    payments_amount numeric(15,2) DEFAULT 0 NOT NULL,
    interests_amount numeric(15,2) DEFAULT 0 NOT NULL,
    ending_balance numeric(15,2) NOT NULL,
    minimum_payment numeric(15,2) NOT NULL,
    remaining_credit numeric(15,2) NOT NULL,
    status character varying(20) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    modified_at timestamp with time zone,
    CONSTRAINT credit_card_statement_status_check CHECK (((status)::text = ANY ((ARRAY['PENDING'::character varying, 'PAID_MINIMUM'::character varying, 'PAID_FULL'::character varying])::text[]))),
    CONSTRAINT valid_dates CHECK (((statement_date <= cut_off_date) AND (cut_off_date < due_date)))
);


ALTER TABLE enki_finance.credit_card_statement OWNER TO postgres;

--
-- Name: currency; Type: TABLE; Schema: enki_finance; Owner: postgres
--

CREATE TABLE enki_finance.currency (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    code character varying(3) NOT NULL,
    name text NOT NULL,
    symbol character varying(5),
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    modified_at timestamp with time zone
);


ALTER TABLE enki_finance.currency OWNER TO postgres;

--
-- Name: TABLE currency; Type: COMMENT; Schema: enki_finance; Owner: postgres
--

COMMENT ON TABLE enki_finance.currency IS 'Catálogo de monedas soportadas';


--
-- Name: transaction; Type: TABLE; Schema: enki_finance; Owner: postgres
--

CREATE TABLE enki_finance.transaction (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    transaction_date date DEFAULT CURRENT_DATE NOT NULL,
    description text,
    amount numeric(15,2) NOT NULL,
    transaction_type_id uuid NOT NULL,
    category_id uuid NOT NULL,
    subcategory_id uuid NOT NULL,
    account_id uuid NOT NULL,
    transaction_medium_id uuid,
    currency_id uuid NOT NULL,
    exchange_rate numeric(10,6) DEFAULT 1 NOT NULL,
    is_recurring boolean DEFAULT false,
    parent_recurring_id uuid,
    sync_status character varying(20) DEFAULT 'PENDING'::character varying NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    modified_at timestamp with time zone,
    installment_purchase_id uuid,
    tags jsonb DEFAULT '[]'::jsonb,
    notes text,
    CONSTRAINT transaction_amount_check CHECK ((amount <> (0)::numeric)),
    CONSTRAINT transaction_sync_status_check CHECK (((sync_status)::text = ANY ((ARRAY['PENDING'::character varying, 'SYNCED'::character varying, 'ERROR'::character varying])::text[]))),
    CONSTRAINT transaction_tags_is_array CHECK ((jsonb_typeof(tags) = 'array'::text)),
    CONSTRAINT valid_exchange_rate CHECK ((exchange_rate > (0)::numeric))
);


ALTER TABLE enki_finance.transaction OWNER TO postgres;

--
-- Name: TABLE transaction; Type: COMMENT; Schema: enki_finance; Owner: postgres
--

COMMENT ON TABLE enki_finance.transaction IS 'Registro de todas las transacciones financieras';


--
-- Name: COLUMN transaction.tags; Type: COMMENT; Schema: enki_finance; Owner: postgres
--

COMMENT ON COLUMN enki_finance.transaction.tags IS 'Array of tags for transaction classification and searching';


--
-- Name: COLUMN transaction.notes; Type: COMMENT; Schema: enki_finance; Owner: postgres
--

COMMENT ON COLUMN enki_finance.transaction.notes IS 'Additional notes and details about the transaction';


--
-- Name: transaction_type; Type: TABLE; Schema: enki_finance; Owner: postgres
--

CREATE TABLE enki_finance.transaction_type (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    description text,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    modified_at timestamp with time zone
);


ALTER TABLE enki_finance.transaction_type OWNER TO postgres;

--
-- Name: TABLE transaction_type; Type: COMMENT; Schema: enki_finance; Owner: postgres
--

COMMENT ON TABLE enki_finance.transaction_type IS 'Tipos de transacciones soportadas';


--
-- Name: expense_trends_analysis; Type: VIEW; Schema: enki_finance; Owner: postgres
--

CREATE VIEW enki_finance.expense_trends_analysis AS
 WITH monthly_expenses AS (
         SELECT t.user_id,
            date_trunc('month'::text, (t.transaction_date)::timestamp with time zone) AS month,
            c.name AS category_name,
            sum(t.amount) AS total_amount,
            count(*) AS transaction_count
           FROM ((enki_finance.transaction t
             JOIN enki_finance.transaction_type tt ON ((tt.id = t.transaction_type_id)))
             JOIN enki_finance.category c ON ((c.id = t.category_id)))
          WHERE (tt.name = 'Gasto'::text)
          GROUP BY t.user_id, (date_trunc('month'::text, (t.transaction_date)::timestamp with time zone)), c.name
        )
 SELECT monthly_expenses.user_id,
    monthly_expenses.month,
    monthly_expenses.category_name,
    monthly_expenses.total_amount,
    monthly_expenses.transaction_count,
    lag(monthly_expenses.total_amount) OVER (PARTITION BY monthly_expenses.user_id, monthly_expenses.category_name ORDER BY monthly_expenses.month) AS prev_month_amount,
    round((((monthly_expenses.total_amount - lag(monthly_expenses.total_amount) OVER (PARTITION BY monthly_expenses.user_id, monthly_expenses.category_name ORDER BY monthly_expenses.month)) / NULLIF(lag(monthly_expenses.total_amount) OVER (PARTITION BY monthly_expenses.user_id, monthly_expenses.category_name ORDER BY monthly_expenses.month), (0)::numeric)) * (100)::numeric), 2) AS month_over_month_change,
    avg(monthly_expenses.total_amount) OVER (PARTITION BY monthly_expenses.user_id, monthly_expenses.category_name ORDER BY monthly_expenses.month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS three_month_moving_avg
   FROM monthly_expenses;


ALTER VIEW enki_finance.expense_trends_analysis OWNER TO postgres;

--
-- Name: financial_goal; Type: TABLE; Schema: enki_finance; Owner: postgres
--

CREATE TABLE enki_finance.financial_goal (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    name text NOT NULL,
    description text,
    target_amount numeric(15,2) NOT NULL,
    current_amount numeric(15,2) DEFAULT 0 NOT NULL,
    start_date date NOT NULL,
    target_date date NOT NULL,
    jar_id uuid,
    status character varying(20) DEFAULT 'IN_PROGRESS'::character varying NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    modified_at timestamp with time zone,
    CONSTRAINT financial_goal_status_check CHECK (((status)::text = ANY ((ARRAY['IN_PROGRESS'::character varying, 'COMPLETED'::character varying, 'CANCELLED'::character varying])::text[]))),
    CONSTRAINT financial_goal_target_amount_check CHECK ((target_amount > (0)::numeric)),
    CONSTRAINT valid_amounts CHECK ((current_amount <= target_amount)),
    CONSTRAINT valid_dates CHECK ((target_date > start_date))
);


ALTER TABLE enki_finance.financial_goal OWNER TO postgres;

--
-- Name: TABLE financial_goal; Type: COMMENT; Schema: enki_finance; Owner: postgres
--

COMMENT ON TABLE enki_finance.financial_goal IS 'Metas financieras de ahorro e inversión';


--
-- Name: foreign_keys; Type: VIEW; Schema: enki_finance; Owner: postgres
--

CREATE VIEW enki_finance.foreign_keys AS
 SELECT pg_constraint.conrelid AS table_id,
    pg_constraint.confrelid AS referenced_table_id,
    pg_constraint.conname AS fk_name
   FROM pg_constraint
  WHERE (pg_constraint.contype = 'f'::"char");


ALTER VIEW enki_finance.foreign_keys OWNER TO postgres;

--
-- Name: jar; Type: TABLE; Schema: enki_finance; Owner: postgres
--

CREATE TABLE enki_finance.jar (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    description text,
    target_percentage numeric(5,2) NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    modified_at timestamp with time zone,
    CONSTRAINT jar_target_percentage_check CHECK (((target_percentage >= (0)::numeric) AND (target_percentage <= (100)::numeric))),
    CONSTRAINT valid_percentage CHECK (((target_percentage > (0)::numeric) AND (target_percentage <= (100)::numeric)))
);


ALTER TABLE enki_finance.jar OWNER TO postgres;

--
-- Name: TABLE jar; Type: COMMENT; Schema: enki_finance; Owner: postgres
--

COMMENT ON TABLE enki_finance.jar IS 'Jarras según metodología de T. Harv Eker';


--
-- Name: COLUMN jar.target_percentage; Type: COMMENT; Schema: enki_finance; Owner: postgres
--

COMMENT ON COLUMN enki_finance.jar.target_percentage IS 'Porcentaje que debe recibir la jarra de los ingresos';


--
-- Name: goal_progress_summary; Type: VIEW; Schema: enki_finance; Owner: postgres
--

CREATE VIEW enki_finance.goal_progress_summary AS
 WITH goal_progress AS (
         SELECT g_1.id,
            g_1.user_id,
            g_1.name,
            g_1.description,
            g_1.target_amount,
            g_1.current_amount,
            g_1.start_date,
            g_1.target_date,
            g_1.jar_id,
            g_1.status,
            g_1.is_active,
            g_1.created_at,
            g_1.modified_at,
            enki_finance.calculate_goal_progress(g_1.current_amount, g_1.target_amount, g_1.start_date, g_1.target_date) AS progress
           FROM enki_finance.financial_goal g_1
          WHERE (g_1.is_active = true)
        )
 SELECT g.user_id,
    g.id AS goal_id,
    g.name,
    g.target_amount,
    g.current_amount,
    (g.progress).percentage_complete AS percentage_complete,
    (g.progress).amount_remaining AS amount_remaining,
    (g.progress).days_remaining AS days_remaining,
    (g.progress).is_on_track AS is_on_track,
    (g.progress).required_daily_amount AS required_daily_amount,
    j.name AS jar_name,
    g.status,
    g.start_date,
    g.target_date,
    g.created_at,
    g.modified_at
   FROM (goal_progress g
     LEFT JOIN enki_finance.jar j ON ((j.id = g.jar_id)));


ALTER VIEW enki_finance.goal_progress_summary OWNER TO postgres;

--
-- Name: installment_purchase; Type: TABLE; Schema: enki_finance; Owner: postgres
--

CREATE TABLE enki_finance.installment_purchase (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    transaction_id uuid NOT NULL,
    credit_card_id uuid NOT NULL,
    total_amount numeric(15,2) NOT NULL,
    number_of_installments integer NOT NULL,
    installment_amount numeric(15,2) NOT NULL,
    remaining_installments integer NOT NULL,
    next_installment_date date NOT NULL,
    status character varying(20) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    modified_at timestamp with time zone,
    CONSTRAINT installment_purchase_installment_amount_check CHECK ((installment_amount > (0)::numeric)),
    CONSTRAINT installment_purchase_number_of_installments_check CHECK ((number_of_installments > 0)),
    CONSTRAINT installment_purchase_status_check CHECK (((status)::text = ANY ((ARRAY['ACTIVE'::character varying, 'COMPLETED'::character varying, 'CANCELLED'::character varying])::text[]))),
    CONSTRAINT installment_purchase_total_amount_check CHECK ((total_amount > (0)::numeric))
);


ALTER TABLE enki_finance.installment_purchase OWNER TO postgres;

--
-- Name: jar_balance; Type: TABLE; Schema: enki_finance; Owner: postgres
--

CREATE TABLE enki_finance.jar_balance (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    jar_id uuid NOT NULL,
    current_balance numeric(15,2) DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    modified_at timestamp with time zone
);


ALTER TABLE enki_finance.jar_balance OWNER TO postgres;

--
-- Name: TABLE jar_balance; Type: COMMENT; Schema: enki_finance; Owner: postgres
--

COMMENT ON TABLE enki_finance.jar_balance IS 'Balance actual de cada jarra por usuario';


--
-- Name: notification; Type: TABLE; Schema: enki_finance; Owner: postgres
--

CREATE TABLE enki_finance.notification (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    title text NOT NULL,
    message text NOT NULL,
    notification_type character varying(50) NOT NULL,
    urgency_level character varying(20) NOT NULL,
    related_entity_type character varying(50),
    related_entity_id uuid,
    is_read boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    read_at timestamp with time zone,
    CONSTRAINT notification_notification_type_check CHECK (((notification_type)::text = ANY ((ARRAY['RECURRING_TRANSACTION'::character varying, 'INSUFFICIENT_FUNDS'::character varying, 'GOAL_PROGRESS'::character varying, 'SYNC_ERROR'::character varying, 'SYSTEM'::character varying, 'CREDIT_CARD_DUE_DATE'::character varying, 'CREDIT_CARD_CUT_OFF'::character varying, 'CREDIT_CARD_LIMIT'::character varying, 'CREDIT_CARD_MINIMUM_PAYMENT'::character varying])::text[]))),
    CONSTRAINT notification_urgency_level_check CHECK (((urgency_level)::text = ANY ((ARRAY['LOW'::character varying, 'MEDIUM'::character varying, 'HIGH'::character varying])::text[])))
);


ALTER TABLE enki_finance.notification OWNER TO postgres;

--
-- Name: TABLE notification; Type: COMMENT; Schema: enki_finance; Owner: postgres
--

COMMENT ON TABLE enki_finance.notification IS 'Registro de notificaciones del sistema';


--
-- Name: recurring_transaction; Type: TABLE; Schema: enki_finance; Owner: postgres
--

CREATE TABLE enki_finance.recurring_transaction (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    name text NOT NULL,
    description text,
    amount numeric(15,2) NOT NULL,
    transaction_type_id uuid NOT NULL,
    category_id uuid NOT NULL,
    subcategory_id uuid NOT NULL,
    account_id uuid NOT NULL,
    jar_id uuid,
    transaction_medium_id uuid,
    frequency character varying(20) NOT NULL,
    start_date date NOT NULL,
    end_date date,
    last_execution_date date,
    next_execution_date date,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    modified_at timestamp with time zone,
    CONSTRAINT recurring_transaction_amount_check CHECK ((amount <> (0)::numeric)),
    CONSTRAINT recurring_transaction_frequency_check CHECK (((frequency)::text = ANY ((ARRAY['WEEKLY'::character varying, 'MONTHLY'::character varying, 'YEARLY'::character varying])::text[]))),
    CONSTRAINT valid_dates CHECK ((((end_date IS NULL) OR (end_date >= start_date)) AND ((next_execution_date IS NULL) OR (next_execution_date >= CURRENT_DATE))))
);


ALTER TABLE enki_finance.recurring_transaction OWNER TO postgres;

--
-- Name: TABLE recurring_transaction; Type: COMMENT; Schema: enki_finance; Owner: postgres
--

COMMENT ON TABLE enki_finance.recurring_transaction IS 'Configuración de transacciones recurrentes';


--
-- Name: schema_migrations; Type: TABLE; Schema: enki_finance; Owner: postgres
--

CREATE TABLE enki_finance.schema_migrations (
    version text NOT NULL
);


ALTER TABLE enki_finance.schema_migrations OWNER TO postgres;

--
-- Name: subcategory; Type: TABLE; Schema: enki_finance; Owner: postgres
--

CREATE TABLE enki_finance.subcategory (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    description text,
    category_id uuid NOT NULL,
    jar_id uuid,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    modified_at timestamp with time zone
);


ALTER TABLE enki_finance.subcategory OWNER TO postgres;

--
-- Name: TABLE subcategory; Type: COMMENT; Schema: enki_finance; Owner: postgres
--

COMMENT ON TABLE enki_finance.subcategory IS 'Subcategorías para clasificación detallada';


--
-- Name: COLUMN subcategory.jar_id; Type: COMMENT; Schema: enki_finance; Owner: postgres
--

COMMENT ON COLUMN enki_finance.subcategory.jar_id IS 'Jarra asociada, requerida solo para gastos';


--
-- Name: transaction_medium; Type: TABLE; Schema: enki_finance; Owner: postgres
--

CREATE TABLE enki_finance.transaction_medium (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    description text,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    modified_at timestamp with time zone
);


ALTER TABLE enki_finance.transaction_medium OWNER TO postgres;

--
-- Name: TABLE transaction_medium; Type: COMMENT; Schema: enki_finance; Owner: postgres
--

COMMENT ON TABLE enki_finance.transaction_medium IS 'Medios de pago soportados';


--
-- Name: transfer; Type: TABLE; Schema: enki_finance; Owner: postgres
--

CREATE TABLE enki_finance.transfer (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    transfer_date date DEFAULT CURRENT_DATE NOT NULL,
    description text,
    amount numeric(15,2) NOT NULL,
    transfer_type character varying(20) NOT NULL,
    from_account_id uuid,
    to_account_id uuid,
    from_jar_id uuid,
    to_jar_id uuid,
    exchange_rate numeric(10,6) DEFAULT 1 NOT NULL,
    notes text,
    sync_status character varying(20) DEFAULT 'PENDING'::character varying NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    modified_at timestamp with time zone,
    CONSTRAINT different_endpoints CHECK ((((from_account_id IS NULL) OR (from_account_id <> to_account_id)) AND ((from_jar_id IS NULL) OR (from_jar_id <> to_jar_id)))),
    CONSTRAINT transfer_amount_check CHECK ((amount > (0)::numeric)),
    CONSTRAINT transfer_sync_status_check CHECK (((sync_status)::text = ANY ((ARRAY['PENDING'::character varying, 'SYNCED'::character varying, 'ERROR'::character varying])::text[]))),
    CONSTRAINT transfer_transfer_type_check CHECK (((transfer_type)::text = ANY ((ARRAY['ACCOUNT_TO_ACCOUNT'::character varying, 'JAR_TO_JAR'::character varying, 'PERIOD_ROLLOVER'::character varying])::text[]))),
    CONSTRAINT valid_transfer_endpoints CHECK (((((transfer_type)::text = 'ACCOUNT_TO_ACCOUNT'::text) AND (from_account_id IS NOT NULL) AND (to_account_id IS NOT NULL) AND (from_jar_id IS NULL) AND (to_jar_id IS NULL)) OR (((transfer_type)::text = 'JAR_TO_JAR'::text) AND (from_jar_id IS NOT NULL) AND (to_jar_id IS NOT NULL) AND (from_account_id IS NULL) AND (to_account_id IS NULL)) OR (((transfer_type)::text = 'PERIOD_ROLLOVER'::text) AND (from_jar_id IS NOT NULL) AND (to_jar_id IS NOT NULL) AND (from_account_id IS NULL) AND (to_account_id IS NULL))))
);


ALTER TABLE enki_finance.transfer OWNER TO postgres;

--
-- Name: TABLE transfer; Type: COMMENT; Schema: enki_finance; Owner: postgres
--

COMMENT ON TABLE enki_finance.transfer IS 'Registro de transferencias entre cuentas y jarras';


--
-- Name: COLUMN transfer.transfer_type; Type: COMMENT; Schema: enki_finance; Owner: postgres
--

COMMENT ON COLUMN enki_finance.transfer.transfer_type IS 'ACCOUNT_TO_ACCOUNT: entre cuentas, JAR_TO_JAR: entre jarras, PERIOD_ROLLOVER: rollover de periodo';


--
-- Name: transfer_summary; Type: VIEW; Schema: enki_finance; Owner: postgres
--

CREATE VIEW enki_finance.transfer_summary AS
 SELECT t.user_id,
    t.transfer_type,
    t.transfer_date,
    t.amount,
    t.exchange_rate,
        CASE
            WHEN ((t.transfer_type)::text = 'ACCOUNT_TO_ACCOUNT'::text) THEN ( SELECT account.name
               FROM enki_finance.account
              WHERE (account.id = t.from_account_id))
            ELSE ( SELECT jar.name
               FROM enki_finance.jar
              WHERE (jar.id = t.from_jar_id))
        END AS source_name,
        CASE
            WHEN ((t.transfer_type)::text = 'ACCOUNT_TO_ACCOUNT'::text) THEN ( SELECT account.name
               FROM enki_finance.account
              WHERE (account.id = t.to_account_id))
            ELSE ( SELECT jar.name
               FROM enki_finance.jar
              WHERE (jar.id = t.to_jar_id))
        END AS target_name,
        CASE
            WHEN ((t.transfer_type)::text = 'ACCOUNT_TO_ACCOUNT'::text) THEN (t.amount * t.exchange_rate)
            ELSE t.amount
        END AS converted_amount,
    t.description,
    t.sync_status,
    t.created_at
   FROM enki_finance.transfer t;


ALTER VIEW enki_finance.transfer_summary OWNER TO postgres;

--
-- Name: transfer_analysis; Type: VIEW; Schema: enki_finance; Owner: postgres
--

CREATE VIEW enki_finance.transfer_analysis AS
 WITH monthly_stats AS (
         SELECT transfer_summary.user_id,
            date_trunc('month'::text, (transfer_summary.transfer_date)::timestamp with time zone) AS month,
            transfer_summary.transfer_type,
            count(*) AS transfer_count,
            sum(transfer_summary.converted_amount) AS total_amount,
            avg(transfer_summary.converted_amount) AS avg_amount
           FROM enki_finance.transfer_summary
          GROUP BY transfer_summary.user_id, (date_trunc('month'::text, (transfer_summary.transfer_date)::timestamp with time zone)), transfer_summary.transfer_type
        ), monthly_changes AS (
         SELECT monthly_stats.user_id,
            monthly_stats.month,
            monthly_stats.transfer_type,
            monthly_stats.transfer_count,
            monthly_stats.total_amount,
            monthly_stats.avg_amount,
            lag(monthly_stats.total_amount) OVER (PARTITION BY monthly_stats.user_id, monthly_stats.transfer_type ORDER BY monthly_stats.month) AS prev_month_amount
           FROM monthly_stats
        )
 SELECT monthly_changes.user_id,
    monthly_changes.month,
    monthly_changes.transfer_type,
    monthly_changes.transfer_count,
    monthly_changes.total_amount,
    monthly_changes.avg_amount,
    monthly_changes.prev_month_amount,
    round((((monthly_changes.total_amount - monthly_changes.prev_month_amount) / NULLIF(monthly_changes.prev_month_amount, (0)::numeric)) * (100)::numeric), 2) AS month_over_month_change
   FROM monthly_changes;


ALTER VIEW enki_finance.transfer_analysis OWNER TO postgres;

--
-- Name: account account_pkey; Type: CONSTRAINT; Schema: enki_finance; Owner: postgres
--

ALTER TABLE ONLY enki_finance.account
    ADD CONSTRAINT account_pkey PRIMARY KEY (id);


--
-- Name: account_type account_type_name_unique; Type: CONSTRAINT; Schema: enki_finance; Owner: postgres
--

ALTER TABLE ONLY enki_finance.account_type
    ADD CONSTRAINT account_type_name_unique UNIQUE (name);


--
-- Name: account_type account_type_pkey; Type: CONSTRAINT; Schema: enki_finance; Owner: postgres
--

ALTER TABLE ONLY enki_finance.account_type
    ADD CONSTRAINT account_type_pkey PRIMARY KEY (id);


--
-- Name: app_user app_user_pkey; Type: CONSTRAINT; Schema: enki_finance; Owner: postgres
--

ALTER TABLE ONLY enki_finance.app_user
    ADD CONSTRAINT app_user_pkey PRIMARY KEY (id);


--
-- Name: balance_history balance_history_pkey; Type: CONSTRAINT; Schema: enki_finance; Owner: postgres
--

ALTER TABLE ONLY enki_finance.balance_history
    ADD CONSTRAINT balance_history_pkey PRIMARY KEY (id);


--
-- Name: category category_pkey; Type: CONSTRAINT; Schema: enki_finance; Owner: postgres
--

ALTER TABLE ONLY enki_finance.category
    ADD CONSTRAINT category_pkey PRIMARY KEY (id);


--
-- Name: credit_card_details credit_card_details_pkey; Type: CONSTRAINT; Schema: enki_finance; Owner: postgres
--

ALTER TABLE ONLY enki_finance.credit_card_details
    ADD CONSTRAINT credit_card_details_pkey PRIMARY KEY (id);


--
-- Name: credit_card_interest_history credit_card_interest_history_pkey; Type: CONSTRAINT; Schema: enki_finance; Owner: postgres
--

ALTER TABLE ONLY enki_finance.credit_card_interest_history
    ADD CONSTRAINT credit_card_interest_history_pkey PRIMARY KEY (id);


--
-- Name: credit_card_statement credit_card_statement_pkey; Type: CONSTRAINT; Schema: enki_finance; Owner: postgres
--

ALTER TABLE ONLY enki_finance.credit_card_statement
    ADD CONSTRAINT credit_card_statement_pkey PRIMARY KEY (id);


--
-- Name: currency currency_code_key; Type: CONSTRAINT; Schema: enki_finance; Owner: postgres
--

ALTER TABLE ONLY enki_finance.currency
    ADD CONSTRAINT currency_code_key UNIQUE (code);


--
-- Name: currency currency_pkey; Type: CONSTRAINT; Schema: enki_finance; Owner: postgres
--

ALTER TABLE ONLY enki_finance.currency
    ADD CONSTRAINT currency_pkey PRIMARY KEY (id);


--
-- Name: financial_goal financial_goal_pkey; Type: CONSTRAINT; Schema: enki_finance; Owner: postgres
--

ALTER TABLE ONLY enki_finance.financial_goal
    ADD CONSTRAINT financial_goal_pkey PRIMARY KEY (id);


--
-- Name: installment_purchase installment_purchase_pkey; Type: CONSTRAINT; Schema: enki_finance; Owner: postgres
--

ALTER TABLE ONLY enki_finance.installment_purchase
    ADD CONSTRAINT installment_purchase_pkey PRIMARY KEY (id);


--
-- Name: jar_balance jar_balance_pkey; Type: CONSTRAINT; Schema: enki_finance; Owner: postgres
--

ALTER TABLE ONLY enki_finance.jar_balance
    ADD CONSTRAINT jar_balance_pkey PRIMARY KEY (id);


--
-- Name: jar jar_name_unique; Type: CONSTRAINT; Schema: enki_finance; Owner: postgres
--

ALTER TABLE ONLY enki_finance.jar
    ADD CONSTRAINT jar_name_unique UNIQUE (name);


--
-- Name: jar jar_pkey; Type: CONSTRAINT; Schema: enki_finance; Owner: postgres
--

ALTER TABLE ONLY enki_finance.jar
    ADD CONSTRAINT jar_pkey PRIMARY KEY (id);


--
-- Name: notification notification_pkey; Type: CONSTRAINT; Schema: enki_finance; Owner: postgres
--

ALTER TABLE ONLY enki_finance.notification
    ADD CONSTRAINT notification_pkey PRIMARY KEY (id);


--
-- Name: recurring_transaction recurring_transaction_pkey; Type: CONSTRAINT; Schema: enki_finance; Owner: postgres
--

ALTER TABLE ONLY enki_finance.recurring_transaction
    ADD CONSTRAINT recurring_transaction_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: enki_finance; Owner: postgres
--

ALTER TABLE ONLY enki_finance.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: subcategory subcategory_pkey; Type: CONSTRAINT; Schema: enki_finance; Owner: postgres
--

ALTER TABLE ONLY enki_finance.subcategory
    ADD CONSTRAINT subcategory_pkey PRIMARY KEY (id);


--
-- Name: transaction_medium transaction_medium_name_unique; Type: CONSTRAINT; Schema: enki_finance; Owner: postgres
--

ALTER TABLE ONLY enki_finance.transaction_medium
    ADD CONSTRAINT transaction_medium_name_unique UNIQUE (name);


--
-- Name: transaction_medium transaction_medium_pkey; Type: CONSTRAINT; Schema: enki_finance; Owner: postgres
--

ALTER TABLE ONLY enki_finance.transaction_medium
    ADD CONSTRAINT transaction_medium_pkey PRIMARY KEY (id);


--
-- Name: transaction transaction_pkey; Type: CONSTRAINT; Schema: enki_finance; Owner: postgres
--

ALTER TABLE ONLY enki_finance.transaction
    ADD CONSTRAINT transaction_pkey PRIMARY KEY (id);


--
-- Name: transaction_type transaction_type_name_unique; Type: CONSTRAINT; Schema: enki_finance; Owner: postgres
--

ALTER TABLE ONLY enki_finance.transaction_type
    ADD CONSTRAINT transaction_type_name_unique UNIQUE (name);


--
-- Name: transaction_type transaction_type_pkey; Type: CONSTRAINT; Schema: enki_finance; Owner: postgres
--

ALTER TABLE ONLY enki_finance.transaction_type
    ADD CONSTRAINT transaction_type_pkey PRIMARY KEY (id);


--
-- Name: transfer transfer_pkey; Type: CONSTRAINT; Schema: enki_finance; Owner: postgres
--

ALTER TABLE ONLY enki_finance.transfer
    ADD CONSTRAINT transfer_pkey PRIMARY KEY (id);


--
-- Name: credit_card_details unique_account_credit_card; Type: CONSTRAINT; Schema: enki_finance; Owner: postgres
--

ALTER TABLE ONLY enki_finance.credit_card_details
    ADD CONSTRAINT unique_account_credit_card UNIQUE (account_id);


--
-- Name: account unique_account_name_per_user; Type: CONSTRAINT; Schema: enki_finance; Owner: postgres
--

ALTER TABLE ONLY enki_finance.account
    ADD CONSTRAINT unique_account_name_per_user UNIQUE (user_id, name);


--
-- Name: jar_balance unique_jar_per_user; Type: CONSTRAINT; Schema: enki_finance; Owner: postgres
--

ALTER TABLE ONLY enki_finance.jar_balance
    ADD CONSTRAINT unique_jar_per_user UNIQUE (user_id, jar_id);


--
-- Name: credit_card_statement unique_statement_period; Type: CONSTRAINT; Schema: enki_finance; Owner: postgres
--

ALTER TABLE ONLY enki_finance.credit_card_statement
    ADD CONSTRAINT unique_statement_period UNIQUE (credit_card_id, statement_date);


--
-- Name: idx_account_active; Type: INDEX; Schema: enki_finance; Owner: postgres
--

CREATE INDEX idx_account_active ON enki_finance.account USING btree (id) WHERE (is_active = true);


--
-- Name: idx_account_type; Type: INDEX; Schema: enki_finance; Owner: postgres
--

CREATE INDEX idx_account_type ON enki_finance.account USING btree (account_type_id);


--
-- Name: idx_account_user; Type: INDEX; Schema: enki_finance; Owner: postgres
--

CREATE INDEX idx_account_user ON enki_finance.account USING btree (user_id);


--
-- Name: idx_app_user_active; Type: INDEX; Schema: enki_finance; Owner: postgres
--

CREATE INDEX idx_app_user_active ON enki_finance.app_user USING btree (id) WHERE (is_active = true);


--
-- Name: idx_app_user_email; Type: INDEX; Schema: enki_finance; Owner: postgres
--

CREATE INDEX idx_app_user_email ON enki_finance.app_user USING btree (email);


--
-- Name: idx_balance_history_account; Type: INDEX; Schema: enki_finance; Owner: postgres
--

CREATE INDEX idx_balance_history_account ON enki_finance.balance_history USING btree (account_id) WHERE (account_id IS NOT NULL);


--
-- Name: idx_balance_history_jar; Type: INDEX; Schema: enki_finance; Owner: postgres
--

CREATE INDEX idx_balance_history_jar ON enki_finance.balance_history USING btree (jar_id) WHERE (jar_id IS NOT NULL);


--
-- Name: idx_balance_history_reference; Type: INDEX; Schema: enki_finance; Owner: postgres
--

CREATE INDEX idx_balance_history_reference ON enki_finance.balance_history USING btree (reference_type, reference_id);


--
-- Name: idx_balance_history_user; Type: INDEX; Schema: enki_finance; Owner: postgres
--

CREATE INDEX idx_balance_history_user ON enki_finance.balance_history USING btree (user_id);


--
-- Name: idx_category_active; Type: INDEX; Schema: enki_finance; Owner: postgres
--

CREATE INDEX idx_category_active ON enki_finance.category USING btree (id) WHERE (is_active = true);


--
-- Name: idx_category_type; Type: INDEX; Schema: enki_finance; Owner: postgres
--

CREATE INDEX idx_category_type ON enki_finance.category USING btree (transaction_type_id);


--
-- Name: idx_credit_card_cut_off; Type: INDEX; Schema: enki_finance; Owner: postgres
--

CREATE INDEX idx_credit_card_cut_off ON enki_finance.credit_card_details USING btree (cut_off_day);


--
-- Name: idx_credit_card_details_account; Type: INDEX; Schema: enki_finance; Owner: postgres
--

CREATE INDEX idx_credit_card_details_account ON enki_finance.credit_card_details USING btree (account_id);


--
-- Name: idx_credit_card_statement_dates; Type: INDEX; Schema: enki_finance; Owner: postgres
--

CREATE INDEX idx_credit_card_statement_dates ON enki_finance.credit_card_statement USING btree (credit_card_id, statement_date);


--
-- Name: idx_credit_card_statement_due; Type: INDEX; Schema: enki_finance; Owner: postgres
--

CREATE INDEX idx_credit_card_statement_due ON enki_finance.credit_card_statement USING btree (credit_card_id, due_date) WHERE ((status)::text = 'PENDING'::text);


--
-- Name: idx_currency_code; Type: INDEX; Schema: enki_finance; Owner: postgres
--

CREATE INDEX idx_currency_code ON enki_finance.currency USING btree (code);


--
-- Name: idx_currency_name; Type: INDEX; Schema: enki_finance; Owner: postgres
--

CREATE INDEX idx_currency_name ON enki_finance.currency USING btree (name);


--
-- Name: idx_financial_goal_active; Type: INDEX; Schema: enki_finance; Owner: postgres
--

CREATE INDEX idx_financial_goal_active ON enki_finance.financial_goal USING btree (id) WHERE (is_active = true);


--
-- Name: idx_financial_goal_dates; Type: INDEX; Schema: enki_finance; Owner: postgres
--

CREATE INDEX idx_financial_goal_dates ON enki_finance.financial_goal USING btree (start_date, target_date);


--
-- Name: idx_financial_goal_status; Type: INDEX; Schema: enki_finance; Owner: postgres
--

CREATE INDEX idx_financial_goal_status ON enki_finance.financial_goal USING btree (status);


--
-- Name: idx_financial_goal_user; Type: INDEX; Schema: enki_finance; Owner: postgres
--

CREATE INDEX idx_financial_goal_user ON enki_finance.financial_goal USING btree (user_id);


--
-- Name: idx_installment_purchase_active; Type: INDEX; Schema: enki_finance; Owner: postgres
--

CREATE INDEX idx_installment_purchase_active ON enki_finance.installment_purchase USING btree (credit_card_id, next_installment_date) WHERE ((status)::text = 'ACTIVE'::text);


--
-- Name: idx_jar_active; Type: INDEX; Schema: enki_finance; Owner: postgres
--

CREATE INDEX idx_jar_active ON enki_finance.jar USING btree (id) WHERE (is_active = true);


--
-- Name: idx_jar_balance_jar; Type: INDEX; Schema: enki_finance; Owner: postgres
--

CREATE INDEX idx_jar_balance_jar ON enki_finance.jar_balance USING btree (jar_id);


--
-- Name: idx_jar_balance_user; Type: INDEX; Schema: enki_finance; Owner: postgres
--

CREATE INDEX idx_jar_balance_user ON enki_finance.jar_balance USING btree (user_id);


--
-- Name: idx_jar_name; Type: INDEX; Schema: enki_finance; Owner: postgres
--

CREATE INDEX idx_jar_name ON enki_finance.jar USING btree (name);


--
-- Name: idx_notification_entity; Type: INDEX; Schema: enki_finance; Owner: postgres
--

CREATE INDEX idx_notification_entity ON enki_finance.notification USING btree (related_entity_type, related_entity_id) WHERE (related_entity_id IS NOT NULL);


--
-- Name: idx_notification_type; Type: INDEX; Schema: enki_finance; Owner: postgres
--

CREATE INDEX idx_notification_type ON enki_finance.notification USING btree (notification_type);


--
-- Name: idx_notification_unread; Type: INDEX; Schema: enki_finance; Owner: postgres
--

CREATE INDEX idx_notification_unread ON enki_finance.notification USING btree (id) WHERE (NOT is_read);


--
-- Name: idx_notification_user; Type: INDEX; Schema: enki_finance; Owner: postgres
--

CREATE INDEX idx_notification_user ON enki_finance.notification USING btree (user_id);


--
-- Name: idx_recurring_transaction_next_no_end; Type: INDEX; Schema: enki_finance; Owner: postgres
--

CREATE INDEX idx_recurring_transaction_next_no_end ON enki_finance.recurring_transaction USING btree (next_execution_date) WHERE ((is_active = true) AND (end_date IS NULL));


--
-- Name: idx_recurring_transaction_next_with_end; Type: INDEX; Schema: enki_finance; Owner: postgres
--

CREATE INDEX idx_recurring_transaction_next_with_end ON enki_finance.recurring_transaction USING btree (next_execution_date, end_date) WHERE (is_active = true);


--
-- Name: idx_recurring_transaction_user; Type: INDEX; Schema: enki_finance; Owner: postgres
--

CREATE INDEX idx_recurring_transaction_user ON enki_finance.recurring_transaction USING btree (user_id);


--
-- Name: idx_subcategory_active; Type: INDEX; Schema: enki_finance; Owner: postgres
--

CREATE INDEX idx_subcategory_active ON enki_finance.subcategory USING btree (id) WHERE (is_active = true);


--
-- Name: idx_subcategory_category; Type: INDEX; Schema: enki_finance; Owner: postgres
--

CREATE INDEX idx_subcategory_category ON enki_finance.subcategory USING btree (category_id);


--
-- Name: idx_subcategory_jar; Type: INDEX; Schema: enki_finance; Owner: postgres
--

CREATE INDEX idx_subcategory_jar ON enki_finance.subcategory USING btree (jar_id);


--
-- Name: idx_transaction_account; Type: INDEX; Schema: enki_finance; Owner: postgres
--

CREATE INDEX idx_transaction_account ON enki_finance.transaction USING btree (account_id);


--
-- Name: idx_transaction_category_analysis; Type: INDEX; Schema: enki_finance; Owner: postgres
--

CREATE INDEX idx_transaction_category_analysis ON enki_finance.transaction USING btree (user_id, category_id, transaction_date);


--
-- Name: idx_transaction_date; Type: INDEX; Schema: enki_finance; Owner: postgres
--

CREATE INDEX idx_transaction_date ON enki_finance.transaction USING btree (transaction_date);


--
-- Name: idx_transaction_date_analysis; Type: INDEX; Schema: enki_finance; Owner: postgres
--

CREATE INDEX idx_transaction_date_analysis ON enki_finance.transaction USING btree (user_id, transaction_date) INCLUDE (amount);


--
-- Name: idx_transaction_notes_search; Type: INDEX; Schema: enki_finance; Owner: postgres
--

CREATE INDEX idx_transaction_notes_search ON enki_finance.transaction USING gin (to_tsvector('spanish'::regconfig, COALESCE(notes, ''::text)));


--
-- Name: idx_transaction_recurring; Type: INDEX; Schema: enki_finance; Owner: postgres
--

CREATE INDEX idx_transaction_recurring ON enki_finance.transaction USING btree (parent_recurring_id) WHERE (parent_recurring_id IS NOT NULL);


--
-- Name: idx_transaction_sync; Type: INDEX; Schema: enki_finance; Owner: postgres
--

CREATE INDEX idx_transaction_sync ON enki_finance.transaction USING btree (sync_status);


--
-- Name: idx_transaction_tags; Type: INDEX; Schema: enki_finance; Owner: postgres
--

CREATE INDEX idx_transaction_tags ON enki_finance.transaction USING gin (tags);


--
-- Name: idx_transaction_type; Type: INDEX; Schema: enki_finance; Owner: postgres
--

CREATE INDEX idx_transaction_type ON enki_finance.transaction USING btree (transaction_type_id);


--
-- Name: idx_transaction_type_active; Type: INDEX; Schema: enki_finance; Owner: postgres
--

CREATE INDEX idx_transaction_type_active ON enki_finance.transaction_type USING btree (id) WHERE (is_active = true);


--
-- Name: idx_transaction_type_name; Type: INDEX; Schema: enki_finance; Owner: postgres
--

CREATE INDEX idx_transaction_type_name ON enki_finance.transaction_type USING btree (name);


--
-- Name: idx_transaction_user; Type: INDEX; Schema: enki_finance; Owner: postgres
--

CREATE INDEX idx_transaction_user ON enki_finance.transaction USING btree (user_id);


--
-- Name: idx_transfer_accounts; Type: INDEX; Schema: enki_finance; Owner: postgres
--

CREATE INDEX idx_transfer_accounts ON enki_finance.transfer USING btree (from_account_id, to_account_id) WHERE ((transfer_type)::text = 'ACCOUNT_TO_ACCOUNT'::text);


--
-- Name: idx_transfer_date; Type: INDEX; Schema: enki_finance; Owner: postgres
--

CREATE INDEX idx_transfer_date ON enki_finance.transfer USING btree (transfer_date);


--
-- Name: idx_transfer_jars; Type: INDEX; Schema: enki_finance; Owner: postgres
--

CREATE INDEX idx_transfer_jars ON enki_finance.transfer USING btree (from_jar_id, to_jar_id) WHERE ((transfer_type)::text = ANY ((ARRAY['JAR_TO_JAR'::character varying, 'PERIOD_ROLLOVER'::character varying])::text[]));


--
-- Name: idx_transfer_sync; Type: INDEX; Schema: enki_finance; Owner: postgres
--

CREATE INDEX idx_transfer_sync ON enki_finance.transfer USING btree (sync_status);


--
-- Name: idx_transfer_user; Type: INDEX; Schema: enki_finance; Owner: postgres
--

CREATE INDEX idx_transfer_user ON enki_finance.transfer USING btree (user_id);


--
-- Name: jar_balance_jar_id_idx; Type: INDEX; Schema: enki_finance; Owner: postgres
--

CREATE INDEX jar_balance_jar_id_idx ON enki_finance.jar_balance USING btree (jar_id);


--
-- Name: transfer after_transfer_notification; Type: TRIGGER; Schema: enki_finance; Owner: postgres
--

CREATE TRIGGER after_transfer_notification AFTER INSERT ON enki_finance.transfer FOR EACH ROW EXECUTE FUNCTION enki_finance.notify_transfer();


--
-- Name: transaction record_transaction_history; Type: TRIGGER; Schema: enki_finance; Owner: postgres
--

CREATE TRIGGER record_transaction_history AFTER INSERT ON enki_finance.transaction FOR EACH ROW EXECUTE FUNCTION enki_finance.record_balance_history();


--
-- Name: transfer record_transfer_history; Type: TRIGGER; Schema: enki_finance; Owner: postgres
--

CREATE TRIGGER record_transfer_history AFTER INSERT ON enki_finance.transfer FOR EACH ROW EXECUTE FUNCTION enki_finance.record_balance_history();


--
-- Name: credit_card_details track_interest_rate_changes_trigger; Type: TRIGGER; Schema: enki_finance; Owner: postgres
--

CREATE TRIGGER track_interest_rate_changes_trigger AFTER UPDATE OF current_interest_rate ON enki_finance.credit_card_details FOR EACH ROW EXECUTE FUNCTION enki_finance.track_interest_rate_changes();


--
-- Name: account update_modified_timestamp; Type: TRIGGER; Schema: enki_finance; Owner: postgres
--

CREATE TRIGGER update_modified_timestamp BEFORE UPDATE ON enki_finance.account FOR EACH ROW EXECUTE FUNCTION enki_finance.update_modified_timestamp();


--
-- Name: account_type update_modified_timestamp; Type: TRIGGER; Schema: enki_finance; Owner: postgres
--

CREATE TRIGGER update_modified_timestamp BEFORE UPDATE ON enki_finance.account_type FOR EACH ROW EXECUTE FUNCTION enki_finance.update_modified_timestamp();


--
-- Name: app_user update_modified_timestamp; Type: TRIGGER; Schema: enki_finance; Owner: postgres
--

CREATE TRIGGER update_modified_timestamp BEFORE UPDATE ON enki_finance.app_user FOR EACH ROW EXECUTE FUNCTION enki_finance.update_modified_timestamp();


--
-- Name: category update_modified_timestamp; Type: TRIGGER; Schema: enki_finance; Owner: postgres
--

CREATE TRIGGER update_modified_timestamp BEFORE UPDATE ON enki_finance.category FOR EACH ROW EXECUTE FUNCTION enki_finance.update_modified_timestamp();


--
-- Name: currency update_modified_timestamp; Type: TRIGGER; Schema: enki_finance; Owner: postgres
--

CREATE TRIGGER update_modified_timestamp BEFORE UPDATE ON enki_finance.currency FOR EACH ROW EXECUTE FUNCTION enki_finance.update_modified_timestamp();


--
-- Name: financial_goal update_modified_timestamp; Type: TRIGGER; Schema: enki_finance; Owner: postgres
--

CREATE TRIGGER update_modified_timestamp BEFORE UPDATE ON enki_finance.financial_goal FOR EACH ROW EXECUTE FUNCTION enki_finance.update_modified_timestamp();


--
-- Name: jar update_modified_timestamp; Type: TRIGGER; Schema: enki_finance; Owner: postgres
--

CREATE TRIGGER update_modified_timestamp BEFORE UPDATE ON enki_finance.jar FOR EACH ROW EXECUTE FUNCTION enki_finance.update_modified_timestamp();


--
-- Name: jar_balance update_modified_timestamp; Type: TRIGGER; Schema: enki_finance; Owner: postgres
--

CREATE TRIGGER update_modified_timestamp BEFORE UPDATE ON enki_finance.jar_balance FOR EACH ROW EXECUTE FUNCTION enki_finance.update_modified_timestamp();


--
-- Name: recurring_transaction update_modified_timestamp; Type: TRIGGER; Schema: enki_finance; Owner: postgres
--

CREATE TRIGGER update_modified_timestamp BEFORE UPDATE ON enki_finance.recurring_transaction FOR EACH ROW EXECUTE FUNCTION enki_finance.update_modified_timestamp();


--
-- Name: subcategory update_modified_timestamp; Type: TRIGGER; Schema: enki_finance; Owner: postgres
--

CREATE TRIGGER update_modified_timestamp BEFORE UPDATE ON enki_finance.subcategory FOR EACH ROW EXECUTE FUNCTION enki_finance.update_modified_timestamp();


--
-- Name: transaction update_modified_timestamp; Type: TRIGGER; Schema: enki_finance; Owner: postgres
--

CREATE TRIGGER update_modified_timestamp BEFORE UPDATE ON enki_finance.transaction FOR EACH ROW EXECUTE FUNCTION enki_finance.update_modified_timestamp();


--
-- Name: transaction_medium update_modified_timestamp; Type: TRIGGER; Schema: enki_finance; Owner: postgres
--

CREATE TRIGGER update_modified_timestamp BEFORE UPDATE ON enki_finance.transaction_medium FOR EACH ROW EXECUTE FUNCTION enki_finance.update_modified_timestamp();


--
-- Name: transaction_type update_modified_timestamp; Type: TRIGGER; Schema: enki_finance; Owner: postgres
--

CREATE TRIGGER update_modified_timestamp BEFORE UPDATE ON enki_finance.transaction_type FOR EACH ROW EXECUTE FUNCTION enki_finance.update_modified_timestamp();


--
-- Name: transfer update_modified_timestamp; Type: TRIGGER; Schema: enki_finance; Owner: postgres
--

CREATE TRIGGER update_modified_timestamp BEFORE UPDATE ON enki_finance.transfer FOR EACH ROW EXECUTE FUNCTION enki_finance.update_modified_timestamp();


--
-- Name: account account_account_type_id_fkey; Type: FK CONSTRAINT; Schema: enki_finance; Owner: postgres
--

ALTER TABLE ONLY enki_finance.account
    ADD CONSTRAINT account_account_type_id_fkey FOREIGN KEY (account_type_id) REFERENCES enki_finance.account_type(id);


--
-- Name: account account_currency_id_fkey; Type: FK CONSTRAINT; Schema: enki_finance; Owner: postgres
--

ALTER TABLE ONLY enki_finance.account
    ADD CONSTRAINT account_currency_id_fkey FOREIGN KEY (currency_id) REFERENCES enki_finance.currency(id);


--
-- Name: account account_user_id_fkey; Type: FK CONSTRAINT; Schema: enki_finance; Owner: postgres
--

ALTER TABLE ONLY enki_finance.account
    ADD CONSTRAINT account_user_id_fkey FOREIGN KEY (user_id) REFERENCES enki_finance.app_user(id);


--
-- Name: app_user app_user_default_currency_id_fkey; Type: FK CONSTRAINT; Schema: enki_finance; Owner: postgres
--

ALTER TABLE ONLY enki_finance.app_user
    ADD CONSTRAINT app_user_default_currency_id_fkey FOREIGN KEY (default_currency_id) REFERENCES enki_finance.currency(id);


--
-- Name: app_user app_user_id_fkey; Type: FK CONSTRAINT; Schema: enki_finance; Owner: postgres
--

ALTER TABLE ONLY enki_finance.app_user
    ADD CONSTRAINT app_user_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id);


--
-- Name: balance_history balance_history_account_id_fkey; Type: FK CONSTRAINT; Schema: enki_finance; Owner: postgres
--

ALTER TABLE ONLY enki_finance.balance_history
    ADD CONSTRAINT balance_history_account_id_fkey FOREIGN KEY (account_id) REFERENCES enki_finance.account(id);


--
-- Name: balance_history balance_history_jar_id_fkey; Type: FK CONSTRAINT; Schema: enki_finance; Owner: postgres
--

ALTER TABLE ONLY enki_finance.balance_history
    ADD CONSTRAINT balance_history_jar_id_fkey FOREIGN KEY (jar_id) REFERENCES enki_finance.jar(id);


--
-- Name: balance_history balance_history_user_id_fkey; Type: FK CONSTRAINT; Schema: enki_finance; Owner: postgres
--

ALTER TABLE ONLY enki_finance.balance_history
    ADD CONSTRAINT balance_history_user_id_fkey FOREIGN KEY (user_id) REFERENCES enki_finance.app_user(id);


--
-- Name: category category_transaction_type_id_fkey; Type: FK CONSTRAINT; Schema: enki_finance; Owner: postgres
--

ALTER TABLE ONLY enki_finance.category
    ADD CONSTRAINT category_transaction_type_id_fkey FOREIGN KEY (transaction_type_id) REFERENCES enki_finance.transaction_type(id);


--
-- Name: credit_card_details credit_card_details_account_id_fkey; Type: FK CONSTRAINT; Schema: enki_finance; Owner: postgres
--

ALTER TABLE ONLY enki_finance.credit_card_details
    ADD CONSTRAINT credit_card_details_account_id_fkey FOREIGN KEY (account_id) REFERENCES enki_finance.account(id);


--
-- Name: credit_card_interest_history credit_card_interest_history_credit_card_id_fkey; Type: FK CONSTRAINT; Schema: enki_finance; Owner: postgres
--

ALTER TABLE ONLY enki_finance.credit_card_interest_history
    ADD CONSTRAINT credit_card_interest_history_credit_card_id_fkey FOREIGN KEY (credit_card_id) REFERENCES enki_finance.credit_card_details(id);


--
-- Name: credit_card_statement credit_card_statement_credit_card_id_fkey; Type: FK CONSTRAINT; Schema: enki_finance; Owner: postgres
--

ALTER TABLE ONLY enki_finance.credit_card_statement
    ADD CONSTRAINT credit_card_statement_credit_card_id_fkey FOREIGN KEY (credit_card_id) REFERENCES enki_finance.credit_card_details(id);


--
-- Name: financial_goal financial_goal_jar_id_fkey; Type: FK CONSTRAINT; Schema: enki_finance; Owner: postgres
--

ALTER TABLE ONLY enki_finance.financial_goal
    ADD CONSTRAINT financial_goal_jar_id_fkey FOREIGN KEY (jar_id) REFERENCES enki_finance.jar(id);


--
-- Name: financial_goal financial_goal_user_id_fkey; Type: FK CONSTRAINT; Schema: enki_finance; Owner: postgres
--

ALTER TABLE ONLY enki_finance.financial_goal
    ADD CONSTRAINT financial_goal_user_id_fkey FOREIGN KEY (user_id) REFERENCES enki_finance.app_user(id);


--
-- Name: installment_purchase installment_purchase_credit_card_id_fkey; Type: FK CONSTRAINT; Schema: enki_finance; Owner: postgres
--

ALTER TABLE ONLY enki_finance.installment_purchase
    ADD CONSTRAINT installment_purchase_credit_card_id_fkey FOREIGN KEY (credit_card_id) REFERENCES enki_finance.credit_card_details(id);


--
-- Name: jar_balance jar_balance_jar_id_fkey; Type: FK CONSTRAINT; Schema: enki_finance; Owner: postgres
--

ALTER TABLE ONLY enki_finance.jar_balance
    ADD CONSTRAINT jar_balance_jar_id_fkey FOREIGN KEY (jar_id) REFERENCES enki_finance.jar(id);


--
-- Name: jar_balance jar_balance_user_id_fkey; Type: FK CONSTRAINT; Schema: enki_finance; Owner: postgres
--

ALTER TABLE ONLY enki_finance.jar_balance
    ADD CONSTRAINT jar_balance_user_id_fkey FOREIGN KEY (user_id) REFERENCES enki_finance.app_user(id);


--
-- Name: notification notification_user_id_fkey; Type: FK CONSTRAINT; Schema: enki_finance; Owner: postgres
--

ALTER TABLE ONLY enki_finance.notification
    ADD CONSTRAINT notification_user_id_fkey FOREIGN KEY (user_id) REFERENCES enki_finance.app_user(id);


--
-- Name: recurring_transaction recurring_transaction_account_id_fkey; Type: FK CONSTRAINT; Schema: enki_finance; Owner: postgres
--

ALTER TABLE ONLY enki_finance.recurring_transaction
    ADD CONSTRAINT recurring_transaction_account_id_fkey FOREIGN KEY (account_id) REFERENCES enki_finance.account(id);


--
-- Name: recurring_transaction recurring_transaction_category_id_fkey; Type: FK CONSTRAINT; Schema: enki_finance; Owner: postgres
--

ALTER TABLE ONLY enki_finance.recurring_transaction
    ADD CONSTRAINT recurring_transaction_category_id_fkey FOREIGN KEY (category_id) REFERENCES enki_finance.category(id);


--
-- Name: recurring_transaction recurring_transaction_jar_id_fkey; Type: FK CONSTRAINT; Schema: enki_finance; Owner: postgres
--

ALTER TABLE ONLY enki_finance.recurring_transaction
    ADD CONSTRAINT recurring_transaction_jar_id_fkey FOREIGN KEY (jar_id) REFERENCES enki_finance.jar(id);


--
-- Name: recurring_transaction recurring_transaction_subcategory_id_fkey; Type: FK CONSTRAINT; Schema: enki_finance; Owner: postgres
--

ALTER TABLE ONLY enki_finance.recurring_transaction
    ADD CONSTRAINT recurring_transaction_subcategory_id_fkey FOREIGN KEY (subcategory_id) REFERENCES enki_finance.subcategory(id);


--
-- Name: recurring_transaction recurring_transaction_transaction_medium_id_fkey; Type: FK CONSTRAINT; Schema: enki_finance; Owner: postgres
--

ALTER TABLE ONLY enki_finance.recurring_transaction
    ADD CONSTRAINT recurring_transaction_transaction_medium_id_fkey FOREIGN KEY (transaction_medium_id) REFERENCES enki_finance.transaction_medium(id);


--
-- Name: recurring_transaction recurring_transaction_transaction_type_id_fkey; Type: FK CONSTRAINT; Schema: enki_finance; Owner: postgres
--

ALTER TABLE ONLY enki_finance.recurring_transaction
    ADD CONSTRAINT recurring_transaction_transaction_type_id_fkey FOREIGN KEY (transaction_type_id) REFERENCES enki_finance.transaction_type(id);


--
-- Name: recurring_transaction recurring_transaction_user_id_fkey; Type: FK CONSTRAINT; Schema: enki_finance; Owner: postgres
--

ALTER TABLE ONLY enki_finance.recurring_transaction
    ADD CONSTRAINT recurring_transaction_user_id_fkey FOREIGN KEY (user_id) REFERENCES enki_finance.app_user(id);


--
-- Name: subcategory subcategory_category_id_fkey; Type: FK CONSTRAINT; Schema: enki_finance; Owner: postgres
--

ALTER TABLE ONLY enki_finance.subcategory
    ADD CONSTRAINT subcategory_category_id_fkey FOREIGN KEY (category_id) REFERENCES enki_finance.category(id);


--
-- Name: subcategory subcategory_jar_id_fkey; Type: FK CONSTRAINT; Schema: enki_finance; Owner: postgres
--

ALTER TABLE ONLY enki_finance.subcategory
    ADD CONSTRAINT subcategory_jar_id_fkey FOREIGN KEY (jar_id) REFERENCES enki_finance.jar(id);


--
-- Name: transaction transaction_account_id_fkey; Type: FK CONSTRAINT; Schema: enki_finance; Owner: postgres
--

ALTER TABLE ONLY enki_finance.transaction
    ADD CONSTRAINT transaction_account_id_fkey FOREIGN KEY (account_id) REFERENCES enki_finance.account(id);


--
-- Name: transaction transaction_category_id_fkey; Type: FK CONSTRAINT; Schema: enki_finance; Owner: postgres
--

ALTER TABLE ONLY enki_finance.transaction
    ADD CONSTRAINT transaction_category_id_fkey FOREIGN KEY (category_id) REFERENCES enki_finance.category(id);


--
-- Name: transaction transaction_currency_id_fkey; Type: FK CONSTRAINT; Schema: enki_finance; Owner: postgres
--

ALTER TABLE ONLY enki_finance.transaction
    ADD CONSTRAINT transaction_currency_id_fkey FOREIGN KEY (currency_id) REFERENCES enki_finance.currency(id);


--
-- Name: transaction transaction_subcategory_id_fkey; Type: FK CONSTRAINT; Schema: enki_finance; Owner: postgres
--

ALTER TABLE ONLY enki_finance.transaction
    ADD CONSTRAINT transaction_subcategory_id_fkey FOREIGN KEY (subcategory_id) REFERENCES enki_finance.subcategory(id);


--
-- Name: transaction transaction_transaction_medium_id_fkey; Type: FK CONSTRAINT; Schema: enki_finance; Owner: postgres
--

ALTER TABLE ONLY enki_finance.transaction
    ADD CONSTRAINT transaction_transaction_medium_id_fkey FOREIGN KEY (transaction_medium_id) REFERENCES enki_finance.transaction_medium(id);


--
-- Name: transaction transaction_transaction_type_id_fkey; Type: FK CONSTRAINT; Schema: enki_finance; Owner: postgres
--

ALTER TABLE ONLY enki_finance.transaction
    ADD CONSTRAINT transaction_transaction_type_id_fkey FOREIGN KEY (transaction_type_id) REFERENCES enki_finance.transaction_type(id);


--
-- Name: transaction transaction_user_id_fkey; Type: FK CONSTRAINT; Schema: enki_finance; Owner: postgres
--

ALTER TABLE ONLY enki_finance.transaction
    ADD CONSTRAINT transaction_user_id_fkey FOREIGN KEY (user_id) REFERENCES enki_finance.app_user(id);


--
-- Name: transfer transfer_from_account_id_fkey; Type: FK CONSTRAINT; Schema: enki_finance; Owner: postgres
--

ALTER TABLE ONLY enki_finance.transfer
    ADD CONSTRAINT transfer_from_account_id_fkey FOREIGN KEY (from_account_id) REFERENCES enki_finance.account(id);


--
-- Name: transfer transfer_from_jar_id_fkey; Type: FK CONSTRAINT; Schema: enki_finance; Owner: postgres
--

ALTER TABLE ONLY enki_finance.transfer
    ADD CONSTRAINT transfer_from_jar_id_fkey FOREIGN KEY (from_jar_id) REFERENCES enki_finance.jar(id);


--
-- Name: transfer transfer_to_account_id_fkey; Type: FK CONSTRAINT; Schema: enki_finance; Owner: postgres
--

ALTER TABLE ONLY enki_finance.transfer
    ADD CONSTRAINT transfer_to_account_id_fkey FOREIGN KEY (to_account_id) REFERENCES enki_finance.account(id);


--
-- Name: transfer transfer_to_jar_id_fkey; Type: FK CONSTRAINT; Schema: enki_finance; Owner: postgres
--

ALTER TABLE ONLY enki_finance.transfer
    ADD CONSTRAINT transfer_to_jar_id_fkey FOREIGN KEY (to_jar_id) REFERENCES enki_finance.jar(id);


--
-- Name: transfer transfer_user_id_fkey; Type: FK CONSTRAINT; Schema: enki_finance; Owner: postgres
--

ALTER TABLE ONLY enki_finance.transfer
    ADD CONSTRAINT transfer_user_id_fkey FOREIGN KEY (user_id) REFERENCES enki_finance.app_user(id);


--
-- Name: account_type Usuarios autenticados pueden leer; Type: POLICY; Schema: enki_finance; Owner: postgres
--

CREATE POLICY "Usuarios autenticados pueden leer" ON enki_finance.account_type FOR SELECT USING ((auth.role() = 'authenticated'::text));


--
-- Name: category Usuarios autenticados pueden leer; Type: POLICY; Schema: enki_finance; Owner: postgres
--

CREATE POLICY "Usuarios autenticados pueden leer" ON enki_finance.category FOR SELECT USING ((auth.role() = 'authenticated'::text));


--
-- Name: currency Usuarios autenticados pueden leer; Type: POLICY; Schema: enki_finance; Owner: postgres
--

CREATE POLICY "Usuarios autenticados pueden leer" ON enki_finance.currency FOR SELECT USING ((auth.role() = 'authenticated'::text));


--
-- Name: jar Usuarios autenticados pueden leer; Type: POLICY; Schema: enki_finance; Owner: postgres
--

CREATE POLICY "Usuarios autenticados pueden leer" ON enki_finance.jar FOR SELECT USING ((auth.role() = 'authenticated'::text));


--
-- Name: subcategory Usuarios autenticados pueden leer; Type: POLICY; Schema: enki_finance; Owner: postgres
--

CREATE POLICY "Usuarios autenticados pueden leer" ON enki_finance.subcategory FOR SELECT USING ((auth.role() = 'authenticated'::text));


--
-- Name: transaction_medium Usuarios autenticados pueden leer; Type: POLICY; Schema: enki_finance; Owner: postgres
--

CREATE POLICY "Usuarios autenticados pueden leer" ON enki_finance.transaction_medium FOR SELECT USING ((auth.role() = 'authenticated'::text));


--
-- Name: transaction_type Usuarios autenticados pueden leer; Type: POLICY; Schema: enki_finance; Owner: postgres
--

CREATE POLICY "Usuarios autenticados pueden leer" ON enki_finance.transaction_type FOR SELECT USING ((auth.role() = 'authenticated'::text));


--
-- Name: category Usuarios pueden actualizar categorías; Type: POLICY; Schema: enki_finance; Owner: postgres
--

CREATE POLICY "Usuarios pueden actualizar categorías" ON enki_finance.category FOR UPDATE USING ((auth.role() = 'authenticated'::text));


--
-- Name: app_user Usuarios pueden actualizar su perfil; Type: POLICY; Schema: enki_finance; Owner: postgres
--

CREATE POLICY "Usuarios pueden actualizar su perfil" ON enki_finance.app_user FOR UPDATE USING ((auth.uid() = id));


--
-- Name: subcategory Usuarios pueden actualizar subcategorías; Type: POLICY; Schema: enki_finance; Owner: postgres
--

CREATE POLICY "Usuarios pueden actualizar subcategorías" ON enki_finance.subcategory FOR UPDATE USING ((auth.role() = 'authenticated'::text));


--
-- Name: jar_balance Usuarios pueden actualizar sus balances; Type: POLICY; Schema: enki_finance; Owner: postgres
--

CREATE POLICY "Usuarios pueden actualizar sus balances" ON enki_finance.jar_balance FOR UPDATE USING ((auth.uid() = user_id));


--
-- Name: account Usuarios pueden actualizar sus cuentas; Type: POLICY; Schema: enki_finance; Owner: postgres
--

CREATE POLICY "Usuarios pueden actualizar sus cuentas" ON enki_finance.account FOR UPDATE USING ((auth.uid() = user_id));


--
-- Name: financial_goal Usuarios pueden actualizar sus metas; Type: POLICY; Schema: enki_finance; Owner: postgres
--

CREATE POLICY "Usuarios pueden actualizar sus metas" ON enki_finance.financial_goal FOR UPDATE USING ((auth.uid() = user_id));


--
-- Name: notification Usuarios pueden actualizar sus notificaciones; Type: POLICY; Schema: enki_finance; Owner: postgres
--

CREATE POLICY "Usuarios pueden actualizar sus notificaciones" ON enki_finance.notification FOR UPDATE USING ((auth.uid() = user_id));


--
-- Name: credit_card_details Usuarios pueden actualizar sus tarjetas; Type: POLICY; Schema: enki_finance; Owner: postgres
--

CREATE POLICY "Usuarios pueden actualizar sus tarjetas" ON enki_finance.credit_card_details FOR UPDATE USING ((auth.uid() = ( SELECT account.user_id
   FROM enki_finance.account
  WHERE (account.id = credit_card_details.account_id))));


--
-- Name: transaction Usuarios pueden actualizar sus transacciones; Type: POLICY; Schema: enki_finance; Owner: postgres
--

CREATE POLICY "Usuarios pueden actualizar sus transacciones" ON enki_finance.transaction FOR UPDATE USING ((auth.uid() = user_id));


--
-- Name: recurring_transaction Usuarios pueden actualizar sus transacciones recurrentes; Type: POLICY; Schema: enki_finance; Owner: postgres
--

CREATE POLICY "Usuarios pueden actualizar sus transacciones recurrentes" ON enki_finance.recurring_transaction FOR UPDATE USING ((auth.uid() = user_id));


--
-- Name: transfer Usuarios pueden actualizar sus transferencias; Type: POLICY; Schema: enki_finance; Owner: postgres
--

CREATE POLICY "Usuarios pueden actualizar sus transferencias" ON enki_finance.transfer FOR UPDATE USING ((auth.uid() = user_id));


--
-- Name: jar_balance Usuarios pueden crear balances; Type: POLICY; Schema: enki_finance; Owner: postgres
--

CREATE POLICY "Usuarios pueden crear balances" ON enki_finance.jar_balance FOR INSERT WITH CHECK ((auth.uid() = user_id));


--
-- Name: category Usuarios pueden crear categorías; Type: POLICY; Schema: enki_finance; Owner: postgres
--

CREATE POLICY "Usuarios pueden crear categorías" ON enki_finance.category FOR INSERT WITH CHECK ((auth.role() = 'authenticated'::text));


--
-- Name: account Usuarios pueden crear cuentas; Type: POLICY; Schema: enki_finance; Owner: postgres
--

CREATE POLICY "Usuarios pueden crear cuentas" ON enki_finance.account FOR INSERT WITH CHECK ((auth.uid() = user_id));


--
-- Name: financial_goal Usuarios pueden crear metas; Type: POLICY; Schema: enki_finance; Owner: postgres
--

CREATE POLICY "Usuarios pueden crear metas" ON enki_finance.financial_goal FOR INSERT WITH CHECK ((auth.uid() = user_id));


--
-- Name: balance_history Usuarios pueden crear registros históricos; Type: POLICY; Schema: enki_finance; Owner: postgres
--

CREATE POLICY "Usuarios pueden crear registros históricos" ON enki_finance.balance_history FOR INSERT WITH CHECK ((auth.uid() = user_id));


--
-- Name: subcategory Usuarios pueden crear subcategorías; Type: POLICY; Schema: enki_finance; Owner: postgres
--

CREATE POLICY "Usuarios pueden crear subcategorías" ON enki_finance.subcategory FOR INSERT WITH CHECK ((auth.role() = 'authenticated'::text));


--
-- Name: transaction Usuarios pueden crear transacciones; Type: POLICY; Schema: enki_finance; Owner: postgres
--

CREATE POLICY "Usuarios pueden crear transacciones" ON enki_finance.transaction FOR INSERT WITH CHECK ((auth.uid() = user_id));


--
-- Name: recurring_transaction Usuarios pueden crear transacciones recurrentes; Type: POLICY; Schema: enki_finance; Owner: postgres
--

CREATE POLICY "Usuarios pueden crear transacciones recurrentes" ON enki_finance.recurring_transaction FOR INSERT WITH CHECK ((auth.uid() = user_id));


--
-- Name: transfer Usuarios pueden crear transferencias; Type: POLICY; Schema: enki_finance; Owner: postgres
--

CREATE POLICY "Usuarios pueden crear transferencias" ON enki_finance.transfer FOR INSERT WITH CHECK ((auth.uid() = user_id));


--
-- Name: category Usuarios pueden eliminar categorías; Type: POLICY; Schema: enki_finance; Owner: postgres
--

CREATE POLICY "Usuarios pueden eliminar categorías" ON enki_finance.category FOR DELETE USING ((auth.role() = 'authenticated'::text));


--
-- Name: subcategory Usuarios pueden eliminar subcategorías; Type: POLICY; Schema: enki_finance; Owner: postgres
--

CREATE POLICY "Usuarios pueden eliminar subcategorías" ON enki_finance.subcategory FOR DELETE USING ((auth.role() = 'authenticated'::text));


--
-- Name: credit_card_statement Usuarios pueden ver estados de cuenta; Type: POLICY; Schema: enki_finance; Owner: postgres
--

CREATE POLICY "Usuarios pueden ver estados de cuenta" ON enki_finance.credit_card_statement FOR SELECT USING ((auth.uid() = ( SELECT a.user_id
   FROM (enki_finance.account a
     JOIN enki_finance.credit_card_details cc ON ((cc.account_id = a.id)))
  WHERE (cc.id = credit_card_statement.credit_card_id))));


--
-- Name: credit_card_interest_history Usuarios pueden ver historial de sus tarjetas; Type: POLICY; Schema: enki_finance; Owner: postgres
--

CREATE POLICY "Usuarios pueden ver historial de sus tarjetas" ON enki_finance.credit_card_interest_history FOR SELECT USING ((auth.uid() = ( SELECT a.user_id
   FROM (enki_finance.account a
     JOIN enki_finance.credit_card_details cc ON ((cc.account_id = a.id)))
  WHERE (cc.id = credit_card_interest_history.credit_card_id))));


--
-- Name: balance_history Usuarios pueden ver su historial; Type: POLICY; Schema: enki_finance; Owner: postgres
--

CREATE POLICY "Usuarios pueden ver su historial" ON enki_finance.balance_history FOR SELECT USING ((auth.uid() = user_id));


--
-- Name: app_user Usuarios pueden ver su perfil; Type: POLICY; Schema: enki_finance; Owner: postgres
--

CREATE POLICY "Usuarios pueden ver su perfil" ON enki_finance.app_user FOR SELECT USING ((auth.uid() = id));


--
-- Name: installment_purchase Usuarios pueden ver sus MSI; Type: POLICY; Schema: enki_finance; Owner: postgres
--

CREATE POLICY "Usuarios pueden ver sus MSI" ON enki_finance.installment_purchase FOR SELECT USING ((auth.uid() = ( SELECT a.user_id
   FROM (enki_finance.account a
     JOIN enki_finance.credit_card_details cc ON ((cc.account_id = a.id)))
  WHERE (cc.id = installment_purchase.credit_card_id))));


--
-- Name: jar_balance Usuarios pueden ver sus balances; Type: POLICY; Schema: enki_finance; Owner: postgres
--

CREATE POLICY "Usuarios pueden ver sus balances" ON enki_finance.jar_balance FOR SELECT USING ((auth.uid() = user_id));


--
-- Name: account Usuarios pueden ver sus cuentas; Type: POLICY; Schema: enki_finance; Owner: postgres
--

CREATE POLICY "Usuarios pueden ver sus cuentas" ON enki_finance.account FOR SELECT USING ((auth.uid() = user_id));


--
-- Name: financial_goal Usuarios pueden ver sus metas; Type: POLICY; Schema: enki_finance; Owner: postgres
--

CREATE POLICY "Usuarios pueden ver sus metas" ON enki_finance.financial_goal FOR SELECT USING ((auth.uid() = user_id));


--
-- Name: notification Usuarios pueden ver sus notificaciones; Type: POLICY; Schema: enki_finance; Owner: postgres
--

CREATE POLICY "Usuarios pueden ver sus notificaciones" ON enki_finance.notification FOR SELECT USING ((auth.uid() = user_id));


--
-- Name: credit_card_details Usuarios pueden ver sus tarjetas; Type: POLICY; Schema: enki_finance; Owner: postgres
--

CREATE POLICY "Usuarios pueden ver sus tarjetas" ON enki_finance.credit_card_details FOR SELECT USING ((auth.uid() = ( SELECT account.user_id
   FROM enki_finance.account
  WHERE (account.id = credit_card_details.account_id))));


--
-- Name: transaction Usuarios pueden ver sus transacciones; Type: POLICY; Schema: enki_finance; Owner: postgres
--

CREATE POLICY "Usuarios pueden ver sus transacciones" ON enki_finance.transaction FOR SELECT USING ((auth.uid() = user_id));


--
-- Name: recurring_transaction Usuarios pueden ver sus transacciones recurrentes; Type: POLICY; Schema: enki_finance; Owner: postgres
--

CREATE POLICY "Usuarios pueden ver sus transacciones recurrentes" ON enki_finance.recurring_transaction FOR SELECT USING ((auth.uid() = user_id));


--
-- Name: transfer Usuarios pueden ver sus transferencias; Type: POLICY; Schema: enki_finance; Owner: postgres
--

CREATE POLICY "Usuarios pueden ver sus transferencias" ON enki_finance.transfer FOR SELECT USING ((auth.uid() = user_id));


--
-- Name: account; Type: ROW SECURITY; Schema: enki_finance; Owner: postgres
--

ALTER TABLE enki_finance.account ENABLE ROW LEVEL SECURITY;

--
-- Name: account_type; Type: ROW SECURITY; Schema: enki_finance; Owner: postgres
--

ALTER TABLE enki_finance.account_type ENABLE ROW LEVEL SECURITY;

--
-- Name: app_user; Type: ROW SECURITY; Schema: enki_finance; Owner: postgres
--

ALTER TABLE enki_finance.app_user ENABLE ROW LEVEL SECURITY;

--
-- Name: balance_history; Type: ROW SECURITY; Schema: enki_finance; Owner: postgres
--

ALTER TABLE enki_finance.balance_history ENABLE ROW LEVEL SECURITY;

--
-- Name: category; Type: ROW SECURITY; Schema: enki_finance; Owner: postgres
--

ALTER TABLE enki_finance.category ENABLE ROW LEVEL SECURITY;

--
-- Name: credit_card_details; Type: ROW SECURITY; Schema: enki_finance; Owner: postgres
--

ALTER TABLE enki_finance.credit_card_details ENABLE ROW LEVEL SECURITY;

--
-- Name: credit_card_interest_history; Type: ROW SECURITY; Schema: enki_finance; Owner: postgres
--

ALTER TABLE enki_finance.credit_card_interest_history ENABLE ROW LEVEL SECURITY;

--
-- Name: credit_card_statement; Type: ROW SECURITY; Schema: enki_finance; Owner: postgres
--

ALTER TABLE enki_finance.credit_card_statement ENABLE ROW LEVEL SECURITY;

--
-- Name: currency; Type: ROW SECURITY; Schema: enki_finance; Owner: postgres
--

ALTER TABLE enki_finance.currency ENABLE ROW LEVEL SECURITY;

--
-- Name: financial_goal; Type: ROW SECURITY; Schema: enki_finance; Owner: postgres
--

ALTER TABLE enki_finance.financial_goal ENABLE ROW LEVEL SECURITY;

--
-- Name: installment_purchase; Type: ROW SECURITY; Schema: enki_finance; Owner: postgres
--

ALTER TABLE enki_finance.installment_purchase ENABLE ROW LEVEL SECURITY;

--
-- Name: jar; Type: ROW SECURITY; Schema: enki_finance; Owner: postgres
--

ALTER TABLE enki_finance.jar ENABLE ROW LEVEL SECURITY;

--
-- Name: jar_balance; Type: ROW SECURITY; Schema: enki_finance; Owner: postgres
--

ALTER TABLE enki_finance.jar_balance ENABLE ROW LEVEL SECURITY;

--
-- Name: notification; Type: ROW SECURITY; Schema: enki_finance; Owner: postgres
--

ALTER TABLE enki_finance.notification ENABLE ROW LEVEL SECURITY;

--
-- Name: recurring_transaction; Type: ROW SECURITY; Schema: enki_finance; Owner: postgres
--

ALTER TABLE enki_finance.recurring_transaction ENABLE ROW LEVEL SECURITY;

--
-- Name: subcategory; Type: ROW SECURITY; Schema: enki_finance; Owner: postgres
--

ALTER TABLE enki_finance.subcategory ENABLE ROW LEVEL SECURITY;

--
-- Name: transaction; Type: ROW SECURITY; Schema: enki_finance; Owner: postgres
--

ALTER TABLE enki_finance.transaction ENABLE ROW LEVEL SECURITY;

--
-- Name: transaction_medium; Type: ROW SECURITY; Schema: enki_finance; Owner: postgres
--

ALTER TABLE enki_finance.transaction_medium ENABLE ROW LEVEL SECURITY;

--
-- Name: transaction_type; Type: ROW SECURITY; Schema: enki_finance; Owner: postgres
--

ALTER TABLE enki_finance.transaction_type ENABLE ROW LEVEL SECURITY;

--
-- Name: transfer; Type: ROW SECURITY; Schema: enki_finance; Owner: postgres
--

ALTER TABLE enki_finance.transfer ENABLE ROW LEVEL SECURITY;

--
-- Name: SCHEMA enki_finance; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA enki_finance TO anon;
GRANT USAGE ON SCHEMA enki_finance TO authenticated;
GRANT USAGE ON SCHEMA enki_finance TO service_role;


--
-- Name: FUNCTION archive_completed_goals(p_days_threshold integer); Type: ACL; Schema: enki_finance; Owner: postgres
--

GRANT ALL ON FUNCTION enki_finance.archive_completed_goals(p_days_threshold integer) TO anon;
GRANT ALL ON FUNCTION enki_finance.archive_completed_goals(p_days_threshold integer) TO authenticated;
GRANT ALL ON FUNCTION enki_finance.archive_completed_goals(p_days_threshold integer) TO service_role;


--
-- Name: FUNCTION calculate_goal_progress(p_current_amount numeric, p_target_amount numeric, p_start_date date, p_target_date date); Type: ACL; Schema: enki_finance; Owner: postgres
--

GRANT ALL ON FUNCTION enki_finance.calculate_goal_progress(p_current_amount numeric, p_target_amount numeric, p_start_date date, p_target_date date) TO anon;
GRANT ALL ON FUNCTION enki_finance.calculate_goal_progress(p_current_amount numeric, p_target_amount numeric, p_start_date date, p_target_date date) TO authenticated;
GRANT ALL ON FUNCTION enki_finance.calculate_goal_progress(p_current_amount numeric, p_target_amount numeric, p_start_date date, p_target_date date) TO service_role;


--
-- Name: FUNCTION calculate_next_cut_off_date(p_cut_off_day integer, p_from_date date); Type: ACL; Schema: enki_finance; Owner: postgres
--

GRANT ALL ON FUNCTION enki_finance.calculate_next_cut_off_date(p_cut_off_day integer, p_from_date date) TO anon;
GRANT ALL ON FUNCTION enki_finance.calculate_next_cut_off_date(p_cut_off_day integer, p_from_date date) TO authenticated;
GRANT ALL ON FUNCTION enki_finance.calculate_next_cut_off_date(p_cut_off_day integer, p_from_date date) TO service_role;


--
-- Name: FUNCTION calculate_next_execution_date(p_frequency character varying, p_start_date date, p_last_execution date); Type: ACL; Schema: enki_finance; Owner: postgres
--

GRANT ALL ON FUNCTION enki_finance.calculate_next_execution_date(p_frequency character varying, p_start_date date, p_last_execution date) TO anon;
GRANT ALL ON FUNCTION enki_finance.calculate_next_execution_date(p_frequency character varying, p_start_date date, p_last_execution date) TO authenticated;
GRANT ALL ON FUNCTION enki_finance.calculate_next_execution_date(p_frequency character varying, p_start_date date, p_last_execution date) TO service_role;


--
-- Name: FUNCTION calculate_next_payment_date(p_payment_day integer, p_cut_off_date date); Type: ACL; Schema: enki_finance; Owner: postgres
--

GRANT ALL ON FUNCTION enki_finance.calculate_next_payment_date(p_payment_day integer, p_cut_off_date date) TO anon;
GRANT ALL ON FUNCTION enki_finance.calculate_next_payment_date(p_payment_day integer, p_cut_off_date date) TO authenticated;
GRANT ALL ON FUNCTION enki_finance.calculate_next_payment_date(p_payment_day integer, p_cut_off_date date) TO service_role;


--
-- Name: FUNCTION check_connection(); Type: ACL; Schema: enki_finance; Owner: postgres
--

GRANT ALL ON FUNCTION enki_finance.check_connection() TO anon;
GRANT ALL ON FUNCTION enki_finance.check_connection() TO authenticated;
GRANT ALL ON FUNCTION enki_finance.check_connection() TO service_role;


--
-- Name: FUNCTION export_transactions_to_excel(p_user_id uuid, p_start_date date, p_end_date date); Type: ACL; Schema: enki_finance; Owner: postgres
--

GRANT ALL ON FUNCTION enki_finance.export_transactions_to_excel(p_user_id uuid, p_start_date date, p_end_date date) TO anon;
GRANT ALL ON FUNCTION enki_finance.export_transactions_to_excel(p_user_id uuid, p_start_date date, p_end_date date) TO authenticated;
GRANT ALL ON FUNCTION enki_finance.export_transactions_to_excel(p_user_id uuid, p_start_date date, p_end_date date) TO service_role;


--
-- Name: FUNCTION generate_credit_card_statement(p_credit_card_id uuid, p_statement_date date); Type: ACL; Schema: enki_finance; Owner: postgres
--

GRANT ALL ON FUNCTION enki_finance.generate_credit_card_statement(p_credit_card_id uuid, p_statement_date date) TO anon;
GRANT ALL ON FUNCTION enki_finance.generate_credit_card_statement(p_credit_card_id uuid, p_statement_date date) TO authenticated;
GRANT ALL ON FUNCTION enki_finance.generate_credit_card_statement(p_credit_card_id uuid, p_statement_date date) TO service_role;


--
-- Name: FUNCTION get_credit_card_statements(p_account_id uuid, p_months integer); Type: ACL; Schema: enki_finance; Owner: postgres
--

GRANT ALL ON FUNCTION enki_finance.get_credit_card_statements(p_account_id uuid, p_months integer) TO anon;
GRANT ALL ON FUNCTION enki_finance.get_credit_card_statements(p_account_id uuid, p_months integer) TO authenticated;
GRANT ALL ON FUNCTION enki_finance.get_credit_card_statements(p_account_id uuid, p_months integer) TO service_role;


--
-- Name: FUNCTION get_transfer_history(p_user_id uuid, p_start_date date, p_end_date date, p_transfer_type text, p_limit integer); Type: ACL; Schema: enki_finance; Owner: postgres
--

GRANT ALL ON FUNCTION enki_finance.get_transfer_history(p_user_id uuid, p_start_date date, p_end_date date, p_transfer_type text, p_limit integer) TO anon;
GRANT ALL ON FUNCTION enki_finance.get_transfer_history(p_user_id uuid, p_start_date date, p_end_date date, p_transfer_type text, p_limit integer) TO authenticated;
GRANT ALL ON FUNCTION enki_finance.get_transfer_history(p_user_id uuid, p_start_date date, p_end_date date, p_transfer_type text, p_limit integer) TO service_role;


--
-- Name: FUNCTION get_upcoming_recurring_transactions(p_user_id uuid, p_days integer); Type: ACL; Schema: enki_finance; Owner: postgres
--

GRANT ALL ON FUNCTION enki_finance.get_upcoming_recurring_transactions(p_user_id uuid, p_days integer) TO anon;
GRANT ALL ON FUNCTION enki_finance.get_upcoming_recurring_transactions(p_user_id uuid, p_days integer) TO authenticated;
GRANT ALL ON FUNCTION enki_finance.get_upcoming_recurring_transactions(p_user_id uuid, p_days integer) TO service_role;


--
-- Name: FUNCTION handle_new_user(); Type: ACL; Schema: enki_finance; Owner: postgres
--

GRANT ALL ON FUNCTION enki_finance.handle_new_user() TO anon;
GRANT ALL ON FUNCTION enki_finance.handle_new_user() TO authenticated;
GRANT ALL ON FUNCTION enki_finance.handle_new_user() TO service_role;


--
-- Name: FUNCTION notify_credit_card_events(); Type: ACL; Schema: enki_finance; Owner: postgres
--

GRANT ALL ON FUNCTION enki_finance.notify_credit_card_events() TO anon;
GRANT ALL ON FUNCTION enki_finance.notify_credit_card_events() TO authenticated;
GRANT ALL ON FUNCTION enki_finance.notify_credit_card_events() TO service_role;


--
-- Name: FUNCTION notify_transfer(); Type: ACL; Schema: enki_finance; Owner: postgres
--

GRANT ALL ON FUNCTION enki_finance.notify_transfer() TO anon;
GRANT ALL ON FUNCTION enki_finance.notify_transfer() TO authenticated;
GRANT ALL ON FUNCTION enki_finance.notify_transfer() TO service_role;


--
-- Name: FUNCTION process_recurring_transactions(p_date date); Type: ACL; Schema: enki_finance; Owner: postgres
--

GRANT ALL ON FUNCTION enki_finance.process_recurring_transactions(p_date date) TO anon;
GRANT ALL ON FUNCTION enki_finance.process_recurring_transactions(p_date date) TO authenticated;
GRANT ALL ON FUNCTION enki_finance.process_recurring_transactions(p_date date) TO service_role;


--
-- Name: FUNCTION reactivate_recurring_transaction(p_transaction_id uuid, p_new_start_date date); Type: ACL; Schema: enki_finance; Owner: postgres
--

GRANT ALL ON FUNCTION enki_finance.reactivate_recurring_transaction(p_transaction_id uuid, p_new_start_date date) TO anon;
GRANT ALL ON FUNCTION enki_finance.reactivate_recurring_transaction(p_transaction_id uuid, p_new_start_date date) TO authenticated;
GRANT ALL ON FUNCTION enki_finance.reactivate_recurring_transaction(p_transaction_id uuid, p_new_start_date date) TO service_role;


--
-- Name: FUNCTION record_balance_history(); Type: ACL; Schema: enki_finance; Owner: postgres
--

GRANT ALL ON FUNCTION enki_finance.record_balance_history() TO anon;
GRANT ALL ON FUNCTION enki_finance.record_balance_history() TO authenticated;
GRANT ALL ON FUNCTION enki_finance.record_balance_history() TO service_role;


--
-- Name: FUNCTION remove_transaction_tag(p_transaction_id uuid, p_tag text); Type: ACL; Schema: enki_finance; Owner: postgres
--

GRANT ALL ON FUNCTION enki_finance.remove_transaction_tag(p_transaction_id uuid, p_tag text) TO anon;
GRANT ALL ON FUNCTION enki_finance.remove_transaction_tag(p_transaction_id uuid, p_tag text) TO authenticated;
GRANT ALL ON FUNCTION enki_finance.remove_transaction_tag(p_transaction_id uuid, p_tag text) TO service_role;


--
-- Name: FUNCTION search_transactions_by_notes(p_user_id uuid, p_search_text text); Type: ACL; Schema: enki_finance; Owner: postgres
--

GRANT ALL ON FUNCTION enki_finance.search_transactions_by_notes(p_user_id uuid, p_search_text text) TO anon;
GRANT ALL ON FUNCTION enki_finance.search_transactions_by_notes(p_user_id uuid, p_search_text text) TO authenticated;
GRANT ALL ON FUNCTION enki_finance.search_transactions_by_notes(p_user_id uuid, p_search_text text) TO service_role;


--
-- Name: FUNCTION search_transactions_by_tags(p_user_id uuid, p_tags text[]); Type: ACL; Schema: enki_finance; Owner: postgres
--

GRANT ALL ON FUNCTION enki_finance.search_transactions_by_tags(p_user_id uuid, p_tags text[]) TO anon;
GRANT ALL ON FUNCTION enki_finance.search_transactions_by_tags(p_user_id uuid, p_tags text[]) TO authenticated;
GRANT ALL ON FUNCTION enki_finance.search_transactions_by_tags(p_user_id uuid, p_tags text[]) TO service_role;


--
-- Name: FUNCTION track_interest_rate_changes(); Type: ACL; Schema: enki_finance; Owner: postgres
--

GRANT ALL ON FUNCTION enki_finance.track_interest_rate_changes() TO anon;
GRANT ALL ON FUNCTION enki_finance.track_interest_rate_changes() TO authenticated;
GRANT ALL ON FUNCTION enki_finance.track_interest_rate_changes() TO service_role;


--
-- Name: FUNCTION update_installment_purchases(); Type: ACL; Schema: enki_finance; Owner: postgres
--

GRANT ALL ON FUNCTION enki_finance.update_installment_purchases() TO anon;
GRANT ALL ON FUNCTION enki_finance.update_installment_purchases() TO authenticated;
GRANT ALL ON FUNCTION enki_finance.update_installment_purchases() TO service_role;


--
-- Name: FUNCTION update_modified_timestamp(); Type: ACL; Schema: enki_finance; Owner: postgres
--

GRANT ALL ON FUNCTION enki_finance.update_modified_timestamp() TO anon;
GRANT ALL ON FUNCTION enki_finance.update_modified_timestamp() TO authenticated;
GRANT ALL ON FUNCTION enki_finance.update_modified_timestamp() TO service_role;


--
-- Name: FUNCTION validate_recurring_transaction(p_user_id uuid, p_amount numeric, p_transaction_type_id uuid, p_account_id uuid, p_jar_id uuid); Type: ACL; Schema: enki_finance; Owner: postgres
--

GRANT ALL ON FUNCTION enki_finance.validate_recurring_transaction(p_user_id uuid, p_amount numeric, p_transaction_type_id uuid, p_account_id uuid, p_jar_id uuid) TO anon;
GRANT ALL ON FUNCTION enki_finance.validate_recurring_transaction(p_user_id uuid, p_amount numeric, p_transaction_type_id uuid, p_account_id uuid, p_jar_id uuid) TO authenticated;
GRANT ALL ON FUNCTION enki_finance.validate_recurring_transaction(p_user_id uuid, p_amount numeric, p_transaction_type_id uuid, p_account_id uuid, p_jar_id uuid) TO service_role;


--
-- Name: TABLE account; Type: ACL; Schema: enki_finance; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE enki_finance.account TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE enki_finance.account TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE enki_finance.account TO service_role;


--
-- Name: TABLE account_type; Type: ACL; Schema: enki_finance; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE enki_finance.account_type TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE enki_finance.account_type TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE enki_finance.account_type TO service_role;


--
-- Name: TABLE app_user; Type: ACL; Schema: enki_finance; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE enki_finance.app_user TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE enki_finance.app_user TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE enki_finance.app_user TO service_role;


--
-- Name: TABLE balance_history; Type: ACL; Schema: enki_finance; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE enki_finance.balance_history TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE enki_finance.balance_history TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE enki_finance.balance_history TO service_role;


--
-- Name: TABLE category; Type: ACL; Schema: enki_finance; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE enki_finance.category TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE enki_finance.category TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE enki_finance.category TO service_role;


--
-- Name: TABLE credit_card_details; Type: ACL; Schema: enki_finance; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE enki_finance.credit_card_details TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE enki_finance.credit_card_details TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE enki_finance.credit_card_details TO service_role;


--
-- Name: TABLE credit_card_interest_history; Type: ACL; Schema: enki_finance; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE enki_finance.credit_card_interest_history TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE enki_finance.credit_card_interest_history TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE enki_finance.credit_card_interest_history TO service_role;


--
-- Name: TABLE credit_card_statement; Type: ACL; Schema: enki_finance; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE enki_finance.credit_card_statement TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE enki_finance.credit_card_statement TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE enki_finance.credit_card_statement TO service_role;


--
-- Name: TABLE currency; Type: ACL; Schema: enki_finance; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE enki_finance.currency TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE enki_finance.currency TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE enki_finance.currency TO service_role;


--
-- Name: TABLE transaction; Type: ACL; Schema: enki_finance; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE enki_finance.transaction TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE enki_finance.transaction TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE enki_finance.transaction TO service_role;


--
-- Name: TABLE transaction_type; Type: ACL; Schema: enki_finance; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE enki_finance.transaction_type TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE enki_finance.transaction_type TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE enki_finance.transaction_type TO service_role;


--
-- Name: TABLE expense_trends_analysis; Type: ACL; Schema: enki_finance; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE enki_finance.expense_trends_analysis TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE enki_finance.expense_trends_analysis TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE enki_finance.expense_trends_analysis TO service_role;


--
-- Name: TABLE financial_goal; Type: ACL; Schema: enki_finance; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE enki_finance.financial_goal TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE enki_finance.financial_goal TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE enki_finance.financial_goal TO service_role;


--
-- Name: TABLE foreign_keys; Type: ACL; Schema: enki_finance; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE enki_finance.foreign_keys TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE enki_finance.foreign_keys TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE enki_finance.foreign_keys TO service_role;


--
-- Name: TABLE jar; Type: ACL; Schema: enki_finance; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE enki_finance.jar TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE enki_finance.jar TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE enki_finance.jar TO service_role;


--
-- Name: TABLE goal_progress_summary; Type: ACL; Schema: enki_finance; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE enki_finance.goal_progress_summary TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE enki_finance.goal_progress_summary TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE enki_finance.goal_progress_summary TO service_role;


--
-- Name: TABLE installment_purchase; Type: ACL; Schema: enki_finance; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE enki_finance.installment_purchase TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE enki_finance.installment_purchase TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE enki_finance.installment_purchase TO service_role;


--
-- Name: TABLE jar_balance; Type: ACL; Schema: enki_finance; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE enki_finance.jar_balance TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE enki_finance.jar_balance TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE enki_finance.jar_balance TO service_role;


--
-- Name: TABLE notification; Type: ACL; Schema: enki_finance; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE enki_finance.notification TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE enki_finance.notification TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE enki_finance.notification TO service_role;


--
-- Name: TABLE recurring_transaction; Type: ACL; Schema: enki_finance; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE enki_finance.recurring_transaction TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE enki_finance.recurring_transaction TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE enki_finance.recurring_transaction TO service_role;


--
-- Name: TABLE schema_migrations; Type: ACL; Schema: enki_finance; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE enki_finance.schema_migrations TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE enki_finance.schema_migrations TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE enki_finance.schema_migrations TO service_role;


--
-- Name: TABLE subcategory; Type: ACL; Schema: enki_finance; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE enki_finance.subcategory TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE enki_finance.subcategory TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE enki_finance.subcategory TO service_role;


--
-- Name: TABLE transaction_medium; Type: ACL; Schema: enki_finance; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE enki_finance.transaction_medium TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE enki_finance.transaction_medium TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE enki_finance.transaction_medium TO service_role;


--
-- Name: TABLE transfer; Type: ACL; Schema: enki_finance; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE enki_finance.transfer TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE enki_finance.transfer TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE enki_finance.transfer TO service_role;


--
-- Name: TABLE transfer_summary; Type: ACL; Schema: enki_finance; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE enki_finance.transfer_summary TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE enki_finance.transfer_summary TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE enki_finance.transfer_summary TO service_role;


--
-- Name: TABLE transfer_analysis; Type: ACL; Schema: enki_finance; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE enki_finance.transfer_analysis TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE enki_finance.transfer_analysis TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE enki_finance.transfer_analysis TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: enki_finance; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA enki_finance GRANT ALL ON SEQUENCES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA enki_finance GRANT ALL ON SEQUENCES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA enki_finance GRANT ALL ON SEQUENCES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: enki_finance; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA enki_finance GRANT ALL ON FUNCTIONS TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA enki_finance GRANT ALL ON FUNCTIONS TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA enki_finance GRANT ALL ON FUNCTIONS TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: enki_finance; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA enki_finance GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA enki_finance GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA enki_finance GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO service_role;


--
-- PostgreSQL database dump complete
--

