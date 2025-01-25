

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


CREATE EXTENSION IF NOT EXISTS "pg_cron" WITH SCHEMA "pg_catalog";






CREATE EXTENSION IF NOT EXISTS "pgsodium" WITH SCHEMA "pgsodium";






COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE EXTENSION IF NOT EXISTS "pg_graphql" WITH SCHEMA "graphql";






CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgjwt" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";






CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";






CREATE TYPE "public"."goal_progress_status" AS (
	"percentage_complete" numeric(5,2),
	"amount_remaining" numeric(15,2),
	"days_remaining" integer,
	"is_on_track" boolean,
	"required_daily_amount" numeric(15,2)
);


ALTER TYPE "public"."goal_progress_status" OWNER TO "postgres";


CREATE TYPE "public"."jar_distribution_summary" AS (
	"jar_name" "text",
	"current_percentage" numeric(5,2),
	"target_percentage" numeric(5,2),
	"difference" numeric(5,2),
	"is_compliant" boolean
);


ALTER TYPE "public"."jar_distribution_summary" OWNER TO "postgres";


CREATE TYPE "public"."period_summary_type" AS (
	"total_income" numeric(15,2),
	"total_expenses" numeric(15,2),
	"net_amount" numeric(15,2),
	"savings_rate" numeric(5,2),
	"expense_income_ratio" numeric(5,2)
);


ALTER TYPE "public"."period_summary_type" OWNER TO "postgres";


CREATE TYPE "public"."recurring_process_result" AS (
	"transactions_created" integer,
	"notifications_sent" integer,
	"errors_encountered" integer
);


ALTER TYPE "public"."recurring_process_result" OWNER TO "postgres";


CREATE TYPE "public"."transfer_validation_result" AS (
	"is_valid" boolean,
	"error_message" "text",
	"source_balance" numeric(15,2),
	"target_balance" numeric(15,2)
);


ALTER TYPE "public"."transfer_validation_result" OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."analyze_financial_goal"("p_goal_id" "uuid") RETURNS TABLE("name" "text", "target_amount" numeric, "current_amount" numeric, "percentage_complete" numeric, "amount_remaining" numeric, "days_remaining" integer, "is_on_track" boolean, "required_daily_amount" numeric, "average_daily_progress" numeric, "projected_completion_date" "date", "status" "text")
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    RETURN QUERY
    WITH goal_data AS (
        SELECT 
            g.*,
            public.calculate_goal_progress(
                g.current_amount,
                g.target_amount,
                g.start_date,
                g.target_date
            ) as progress
        FROM public.financial_goal g
        WHERE g.id = p_goal_id
    )
    SELECT
        g.name,
        g.target_amount,
        g.current_amount,
        (progress).percentage_complete,
        (progress).amount_remaining,
        (progress).days_remaining,
        (progress).is_on_track,
        (progress).required_daily_amount,
        g.current_amount / NULLIF(CURRENT_DATE - g.start_date, 0) as average_daily_progress,
        CASE 
            WHEN g.current_amount >= g.target_amount THEN g.modified_at::date
            WHEN g.current_amount = 0 THEN NULL
            ELSE CURRENT_DATE + 
                (((g.target_amount - g.current_amount) / 
                (g.current_amount / NULLIF(CURRENT_DATE - g.start_date, 0)))::integer)
        END as projected_completion_date,
        g.status
    FROM goal_data g;
END;
$$;


ALTER FUNCTION "public"."analyze_financial_goal"("p_goal_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."analyze_jar_distribution"("p_user_id" "uuid", "p_start_date" "date" DEFAULT NULL::"date", "p_end_date" "date" DEFAULT NULL::"date") RETURNS SETOF "public"."jar_distribution_summary"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    v_total_income numeric(15,2);
BEGIN
    -- Obtener ingresos totales del período
    SELECT COALESCE(sum(amount), 0) INTO v_total_income
    FROM public.transaction t
    JOIN public.transaction_type tt ON tt.id = t.transaction_type_id
    WHERE t.user_id = p_user_id
    AND tt.code = 'INCOME'
    AND (p_start_date IS NULL OR t.transaction_date >= p_start_date)
    AND (p_end_date IS NULL OR t.transaction_date <= p_end_date);

    -- Retornar análisis por jarra
    RETURN QUERY
    WITH jar_totals AS (
        SELECT 
            j.id,
            j.name as jar_name,
            j.target_percentage,
            COALESCE(sum(t.amount), 0) as total_amount
        FROM public.jar j
        LEFT JOIN public.transaction t ON t.jar_id = j.id
        WHERE (p_start_date IS NULL OR t.transaction_date >= p_start_date)
        AND (p_end_date IS NULL OR t.transaction_date <= p_end_date)
        AND (t.user_id = p_user_id OR t.user_id IS NULL)
        GROUP BY j.id, j.name, j.target_percentage
    )
    SELECT 
        jar_name,
        CASE 
            WHEN v_total_income > 0 THEN round((total_amount / v_total_income) * 100, 2)
            ELSE 0
        END as current_percentage,
        target_percentage,
        CASE 
            WHEN v_total_income > 0 THEN round((total_amount / v_total_income) * 100 - target_percentage, 2)
            ELSE -target_percentage
        END as difference,
        CASE 
            WHEN v_total_income > 0 THEN 
                abs((total_amount / v_total_income) * 100 - target_percentage) <= 2
            ELSE false
        END as is_compliant
    FROM jar_totals
    ORDER BY target_percentage DESC;
END;
$$;


ALTER FUNCTION "public"."analyze_jar_distribution"("p_user_id" "uuid", "p_start_date" "date", "p_end_date" "date") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."analyze_transactions_by_category"("p_user_id" "uuid", "p_start_date" "date", "p_end_date" "date", "p_transaction_type" "text" DEFAULT NULL::"text") RETURNS TABLE("category_name" "text", "subcategory_name" "text", "transaction_count" bigint, "total_amount" numeric, "percentage_of_total" numeric, "avg_amount" numeric, "min_amount" numeric, "max_amount" numeric)
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    RETURN QUERY
    WITH transaction_totals AS (
        SELECT sum(t.amount) as grand_total
        FROM public.transaction t
        JOIN public.transaction_type tt ON tt.id = t.transaction_type_id
        WHERE t.user_id = p_user_id
        AND t.transaction_date BETWEEN p_start_date AND p_end_date
        AND (p_transaction_type IS NULL OR tt.code = p_transaction_type)
    )
    SELECT 
        c.name as category_name,
        sc.name as subcategory_name,
        count(*) as transaction_count,
        sum(t.amount) as total_amount,
        round((sum(t.amount) / tt.grand_total) * 100, 2) as percentage_of_total,
        round(avg(t.amount), 2) as avg_amount,
        min(t.amount) as min_amount,
        max(t.amount) as max_amount
    FROM public.transaction t
    JOIN public.category c ON c.id = t.category
    JOIN public.subcategory sc ON sc.id = t.sub_category
    JOIN public.transaction_type typ ON typ.id = t.transaction_type_id
    CROSS JOIN transaction_totals tt
    WHERE t.user_id = p_user_id
    AND t.transaction_date BETWEEN p_start_date AND p_end_date
    AND (p_transaction_type IS NULL OR typ.code = p_transaction_type)
    GROUP BY c.name, sc.name, tt.grand_total
    ORDER BY total_amount DESC;
END;
$$;


ALTER FUNCTION "public"."analyze_transactions_by_category"("p_user_id" "uuid", "p_start_date" "date", "p_end_date" "date", "p_transaction_type" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."archive_completed_goals"("p_days_threshold" integer DEFAULT 30) RETURNS integer
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    v_archived_count integer;
BEGIN
    UPDATE public.financial_goal
    SET is_active = false
    WHERE status = 'COMPLETED'
    AND modified_at < CURRENT_DATE - p_days_threshold
    AND is_active = true;

    GET DIAGNOSTICS v_archived_count = ROW_COUNT;
    RETURN v_archived_count;
END;
$$;


ALTER FUNCTION "public"."archive_completed_goals"("p_days_threshold" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."calculate_goal_progress"("p_current_amount" numeric, "p_target_amount" numeric, "p_start_date" "date", "p_target_date" "date") RETURNS "public"."goal_progress_status"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    v_result public.goal_progress_status;
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


ALTER FUNCTION "public"."calculate_goal_progress"("p_current_amount" numeric, "p_target_amount" numeric, "p_start_date" "date", "p_target_date" "date") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."calculate_next_cut_off_date"("p_cut_off_day" integer, "p_from_date" "date" DEFAULT CURRENT_DATE) RETURNS "date"
    LANGUAGE "plpgsql"
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


ALTER FUNCTION "public"."calculate_next_cut_off_date"("p_cut_off_day" integer, "p_from_date" "date") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."calculate_next_execution_date"("p_frequency" character varying, "p_start_date" "date", "p_last_execution" "date" DEFAULT NULL::"date") RETURNS "date"
    LANGUAGE "plpgsql"
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


ALTER FUNCTION "public"."calculate_next_execution_date"("p_frequency" character varying, "p_start_date" "date", "p_last_execution" "date") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."calculate_next_payment_date"("p_payment_day" integer, "p_cut_off_date" "date") RETURNS "date"
    LANGUAGE "plpgsql"
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


ALTER FUNCTION "public"."calculate_next_payment_date"("p_payment_day" integer, "p_cut_off_date" "date") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."check_available_balance_for_transfer"("p_user_id" "uuid", "p_account_id" "uuid" DEFAULT NULL::"uuid", "p_jar_id" "uuid" DEFAULT NULL::"uuid") RETURNS numeric
    LANGUAGE "plpgsql"
    AS $$
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
$$;


ALTER FUNCTION "public"."check_available_balance_for_transfer"("p_user_id" "uuid", "p_account_id" "uuid", "p_jar_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."check_jar_requirement"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    IF (NEW.jar_id IS NOT NULL AND EXISTS (
        SELECT 1 FROM public.category c 
        WHERE c.id = NEW.category_id 
        AND c.transaction_type_id IN (
            SELECT id FROM public.transaction_type WHERE name = 'Gasto'
        )
    )) THEN
        RETURN NEW;
    ELSIF (NEW.jar_id IS NULL AND EXISTS (
        SELECT 1 FROM public.category c 
        WHERE c.id = NEW.category_id 
        AND c.transaction_type_id IN (
            SELECT id FROM public.transaction_type WHERE name != 'Gasto'
        )
    )) THEN
        RETURN NEW;
    ELSE
        RAISE EXCEPTION 'Invalid jar_id for the given category_id';
    END IF;
END;
$$;


ALTER FUNCTION "public"."check_jar_requirement"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."check_recurring_transaction_jar_requirement"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    IF (NEW.jar_id IS NOT NULL AND EXISTS (
        SELECT 1 FROM public.transaction_type t 
        WHERE t.id = NEW.transaction_type_id 
        AND t.code = 'EXPENSE'
    )) THEN
        RETURN NEW;
    ELSIF (NEW.jar_id IS NULL AND EXISTS (
        SELECT 1 FROM public.transaction_type t 
        WHERE t.id = NEW.transaction_type_id 
        AND t.code != 'EXPENSE'
    )) THEN
        RETURN NEW;
    ELSE
        RAISE EXCEPTION 'Invalid jar_id for the given transaction_type';
    END IF;
END;
$$;


ALTER FUNCTION "public"."check_recurring_transaction_jar_requirement"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."check_transaction_jar_requirement"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    IF (NEW.jar_id IS NOT NULL AND EXISTS (
        SELECT 1 FROM public.transaction_type t 
        WHERE t.id = NEW.transaction_type_id 
        AND t.code = 'EXPENSE'
    )) THEN
        RETURN NEW;
    ELSIF (NEW.jar_id IS NULL AND EXISTS (
        SELECT 1 FROM public.transaction_type t 
        WHERE t.id = NEW.transaction_type_id 
        AND t.code != 'EXPENSE'
    )) THEN
        RETURN NEW;
    ELSE
        RAISE EXCEPTION 'Invalid jar_id for the given transaction_type';
    END IF;
END;
$$;


ALTER FUNCTION "public"."check_transaction_jar_requirement"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."execute_account_transfer"("p_user_id" "uuid", "p_from_account_id" "uuid", "p_to_account_id" "uuid", "p_amount" numeric, "p_exchange_rate" numeric DEFAULT 1, "p_description" "text" DEFAULT NULL::"text") RETURNS "uuid"
    LANGUAGE "plpgsql"
    AS $$
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
$$;


ALTER FUNCTION "public"."execute_account_transfer"("p_user_id" "uuid", "p_from_account_id" "uuid", "p_to_account_id" "uuid", "p_amount" numeric, "p_exchange_rate" numeric, "p_description" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."execute_jar_transfer"("p_user_id" "uuid", "p_from_jar_id" "uuid", "p_to_jar_id" "uuid", "p_amount" numeric, "p_description" "text" DEFAULT NULL::"text", "p_is_rollover" boolean DEFAULT false) RETURNS "uuid"
    LANGUAGE "plpgsql"
    AS $$
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
$$;


ALTER FUNCTION "public"."execute_jar_transfer"("p_user_id" "uuid", "p_from_jar_id" "uuid", "p_to_jar_id" "uuid", "p_amount" numeric, "p_description" "text", "p_is_rollover" boolean) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."export_jar_status_to_excel"("p_user_id" "uuid") RETURNS TABLE("jar_name" "text", "current_balance" numeric, "target_percentage" numeric, "current_percentage" numeric, "last_transaction_date" "date", "total_transactions" bigint)
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        j.name as jar_name,
        jb.current_balance,
        j.target_percentage,
        COALESCE(
            (
                SELECT round((sum(t.amount) / NULLIF((
                    SELECT sum(amount)
                    FROM public.transaction tr
                    JOIN public.transaction_type tt ON tt.id = tr.transaction_type_id
                    WHERE tr.user_id = p_user_id
                    AND tt.code = 'INCOME'
                    AND date_trunc('month', tr.transaction_date) = date_trunc('month', CURRENT_DATE)
                ), 0)) * 100, 2)
                FROM public.transaction t
                WHERE t.jar_id = j.id
                AND t.user_id = p_user_id
                AND date_trunc('month', t.transaction_date) = date_trunc('month', CURRENT_DATE)
            ),
            0
        ) as current_percentage,
        (
            SELECT max(transaction_date)
            FROM public.transaction t
            WHERE t.jar_id = j.id
            AND t.user_id = p_user_id
        ) as last_transaction_date,
        count(t.id) as total_transactions
    FROM public.jar j
    LEFT JOIN public.jar_balance jb ON jb.jar_id = j.id AND jb.user_id = p_user_id
    LEFT JOIN public.transaction t ON t.jar_id = j.id AND t.user_id = p_user_id
    GROUP BY j.id, j.name, jb.current_balance, j.target_percentage
    ORDER BY j.target_percentage DESC;
END;
$$;


ALTER FUNCTION "public"."export_jar_status_to_excel"("p_user_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."export_transactions_to_excel"("p_user_id" "uuid", "p_start_date" "date", "p_end_date" "date") RETURNS TABLE("transaction_date" "date", "transaction_type" "text", "category" "text", "subcategory" "text", "amount" numeric, "account_name" "text", "jar_name" "text", "description" "text")
    LANGUAGE "plpgsql"
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
    FROM public.transaction t
    JOIN public.transaction_type tt ON tt.id = t.transaction_type_id
    JOIN public.category c ON c.id = t.category
    JOIN public.subcategory sc ON sc.id = t.sub_category
    JOIN public.account a ON a.id = t.account
    LEFT JOIN public.jar j ON j.id = t.jar_id
    WHERE t.user_id = p_user_id
    AND t.transaction_date BETWEEN p_start_date AND p_end_date
    ORDER BY t.transaction_date DESC;
END;
$$;


ALTER FUNCTION "public"."export_transactions_to_excel"("p_user_id" "uuid", "p_start_date" "date", "p_end_date" "date") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."generate_credit_card_statement"("p_credit_card_id" "uuid", "p_statement_date" "date" DEFAULT CURRENT_DATE) RETURNS "uuid"
    LANGUAGE "plpgsql"
    AS $$
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
$$;


ALTER FUNCTION "public"."generate_credit_card_statement"("p_credit_card_id" "uuid", "p_statement_date" "date") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_credit_card_statements"("p_account_id" "uuid", "p_months" integer DEFAULT 12) RETURNS TABLE("statement_date" "date", "cut_off_date" "date", "due_date" "date", "previous_balance" numeric, "purchases_amount" numeric, "payments_amount" numeric, "interests_amount" numeric, "ending_balance" numeric, "minimum_payment" numeric, "status" "text")
    LANGUAGE "plpgsql"
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
    FROM public.credit_card_statement cs
    JOIN public.credit_card_details cc ON cc.id = cs.credit_card_id
    WHERE cc.account_id = p_account_id
    AND cs.statement_date >= CURRENT_DATE - (p_months || ' months')::interval
    ORDER BY cs.statement_date DESC;
END;
$$;


ALTER FUNCTION "public"."get_credit_card_statements"("p_account_id" "uuid", "p_months" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_credit_card_summary"("p_account_id" "uuid") RETURNS TABLE("credit_limit" numeric, "current_balance" numeric, "available_credit" numeric, "current_interest_rate" numeric, "next_cut_off_date" "date", "next_payment_date" "date", "active_installment_purchases" bigint, "total_installment_amount" numeric)
    LANGUAGE "plpgsql"
    AS $$
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
$$;


ALTER FUNCTION "public"."get_credit_card_summary"("p_account_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_goals_summary"("p_user_id" "uuid") RETURNS TABLE("total_goals" bigint, "completed_goals" bigint, "in_progress_goals" bigint, "total_target_amount" numeric, "total_current_amount" numeric, "overall_completion_percentage" numeric)
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        count(*),
        count(*) FILTER (WHERE status = 'COMPLETED'),
        count(*) FILTER (WHERE status = 'IN_PROGRESS'),
        sum(target_amount),
        sum(current_amount),
        round(
            (sum(current_amount) / NULLIF(sum(target_amount), 0)) * 100,
            2
        )
    FROM public.financial_goal
    WHERE user_id = p_user_id
    AND is_active = true;
END;
$$;


ALTER FUNCTION "public"."get_goals_summary"("p_user_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_period_summary"("p_user_id" "uuid", "p_start_date" "date", "p_end_date" "date") RETURNS "public"."period_summary_type"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    v_result public.period_summary_type;
BEGIN
    -- Calcular ingresos totales
    SELECT COALESCE(sum(t.amount), 0) INTO v_result.total_income
    FROM public.transaction t
    JOIN public.transaction_type tt ON tt.id = t.transaction_type_id
    WHERE t.user_id = p_user_id
    AND t.transaction_date BETWEEN p_start_date AND p_end_date
    AND tt.code = 'INCOME';

    -- Calcular gastos totales
    SELECT COALESCE(sum(t.amount), 0) INTO v_result.total_expenses
    FROM public.transaction t
    JOIN public.transaction_type tt ON tt.id = t.transaction_type_id
    WHERE t.user_id = p_user_id
    AND t.transaction_date BETWEEN p_start_date AND p_end_date
    AND tt.code = 'EXPENSE';

    -- Calcular monto neto
    v_result.net_amount := v_result.total_income - v_result.total_expenses;

    -- Calcular tasa de ahorro
    IF v_result.total_income > 0 THEN
        v_result.savings_rate := round(
            (v_result.net_amount / v_result.total_income) * 100,
            2
        );
    ELSE
        v_result.savings_rate := 0;
    END IF;

    -- Calcular ratio gastos/ingresos
    IF v_result.total_income > 0 THEN
        v_result.expense_income_ratio := round(
            (v_result.total_expenses / v_result.total_income) * 100,
            2
        );
    ELSE
        v_result.expense_income_ratio := 0;
    END IF;

    RETURN v_result;
END;
$$;


ALTER FUNCTION "public"."get_period_summary"("p_user_id" "uuid", "p_start_date" "date", "p_end_date" "date") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_transfer_history"("p_user_id" "uuid", "p_start_date" "date" DEFAULT NULL::"date", "p_end_date" "date" DEFAULT NULL::"date", "p_transfer_type" "text" DEFAULT NULL::"text", "p_limit" integer DEFAULT 100) RETURNS TABLE("transfer_id" "uuid", "transfer_date" "date", "transfer_type" "text", "source_name" "text", "target_name" "text", "amount" numeric, "converted_amount" numeric, "description" "text")
    LANGUAGE "plpgsql"
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
    FROM public.transfer t
    JOIN public.transfer_summary s ON s.transfer_id = t.id
    WHERE t.user_id = p_user_id
    AND (p_start_date IS NULL OR t.transfer_date >= p_start_date)
    AND (p_end_date IS NULL OR t.transfer_date <= p_end_date)
    AND (p_transfer_type IS NULL OR t.transfer_type::text = p_transfer_type)
    ORDER BY t.transfer_date DESC
    LIMIT p_limit;
END;
$$;


ALTER FUNCTION "public"."get_transfer_history"("p_user_id" "uuid", "p_start_date" "date", "p_end_date" "date", "p_transfer_type" "text", "p_limit" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_transfer_summary_by_period"("p_user_id" "uuid", "p_start_date" "date", "p_end_date" "date") RETURNS TABLE("period" "date", "account_transfers_count" integer, "account_transfers_amount" numeric, "jar_transfers_count" integer, "jar_transfers_amount" numeric, "rollover_count" integer, "rollover_amount" numeric)
    LANGUAGE "plpgsql"
    AS $$
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
$$;


ALTER FUNCTION "public"."get_transfer_summary_by_period"("p_user_id" "uuid", "p_start_date" "date", "p_end_date" "date") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_upcoming_recurring_transactions"("p_user_id" "uuid", "p_days" integer DEFAULT 7) RETURNS TABLE("id" "uuid", "name" "text", "next_execution_date" "date", "amount" numeric, "description" "text", "days_until" integer)
    LANGUAGE "plpgsql"
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
    FROM public.recurring_transaction r
    WHERE r.user_id = p_user_id
    AND r.is_active = true
    AND r.next_execution_date <= CURRENT_DATE + p_days
    ORDER BY r.next_execution_date;
END;
$$;


ALTER FUNCTION "public"."get_upcoming_recurring_transactions"("p_user_id" "uuid", "p_days" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_new_user"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    default_currency_id uuid;
BEGIN
    -- Get the default currency (MXN)
    SELECT id INTO default_currency_id
    FROM public.currency
    WHERE code = 'MXN';

    -- Insert the new user into public.app_user
    INSERT INTO public.app_user (
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
    INSERT INTO public.jar_balance (user_id, jar_id, current_balance)
    SELECT 
        NEW.id,
        j.id,
        0
    FROM public.jar j
    WHERE j.is_system = true;

    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."handle_new_user"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."initialize_system_data"() RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    -- Insert transaction types
    INSERT INTO public.transaction_type (name, description)
    VALUES 
        ('Ingreso', 'Entrada de dinero'),
        ('Gasto', 'Salida de dinero'),
        ('Transferencia', 'Movimiento entre cuentas o jarras')
    ON CONFLICT (name) DO NOTHING;

    -- Insert transaction mediums
    INSERT INTO public.transaction_medium (name, description)
    VALUES 
        ('Efectivo', 'Pago en efectivo'),
        ('Tarjeta de Débito', 'Pago con tarjeta de débito'),
        ('Tarjeta de Crédito', 'Pago con tarjeta de crédito'),
        ('Transferencia', 'Transferencia bancaria'),
        ('Otro', 'Otros medios de pago')
    ON CONFLICT (name) DO NOTHING;

    -- Insert jars
    INSERT INTO public.jar (name, description, target_percentage)
    VALUES 
        ('Necesidades', 'Gastos necesarios y obligatorios', 55),
        ('Inversión a Largo Plazo', 'Inversiones para el futuro', 10),
        ('Ahorro', 'Ahorro para emergencias y metas', 10),
        ('Educación', 'Desarrollo personal y profesional', 10),
        ('Ocio', 'Entretenimiento y diversión', 10),
        ('Donaciones', 'Ayuda a otros', 5)
    ON CONFLICT (name) DO NOTHING;

    -- Insert account types
    INSERT INTO public.account_type (name, description)
    VALUES 
        ('Cuenta de Cheques', 'Cuenta bancaria principal'),
        ('Cuenta de Ahorro', 'Cuenta para ahorros'),
        ('Efectivo', 'Dinero en efectivo'),
        ('Tarjeta de Crédito', 'Tarjeta de crédito bancaria'),
        ('Inversión', 'Cuenta de inversiones'),
        ('Préstamos', 'Préstamos y créditos bancarios')
    ON CONFLICT (name) DO NOTHING;
END;
$$;


ALTER FUNCTION "public"."initialize_system_data"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."notify_credit_card_events"() RETURNS "void"
    LANGUAGE "plpgsql"
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
$$;


ALTER FUNCTION "public"."notify_credit_card_events"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."notify_transfer"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
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
$$;


ALTER FUNCTION "public"."notify_transfer"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."process_jar_rollover"("p_user_id" "uuid") RETURNS TABLE("jar_code" "text", "amount_rolled" numeric)
    LANGUAGE "plpgsql"
    AS $$
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
$$;


ALTER FUNCTION "public"."process_jar_rollover"("p_user_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."process_recurring_transactions"("p_date" "date" DEFAULT CURRENT_DATE) RETURNS "public"."recurring_process_result"
    LANGUAGE "plpgsql"
    AS $$
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
$$;


ALTER FUNCTION "public"."process_recurring_transactions"("p_date" "date") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."reactivate_recurring_transaction"("p_transaction_id" "uuid", "p_new_start_date" "date" DEFAULT CURRENT_DATE) RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
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
$$;


ALTER FUNCTION "public"."reactivate_recurring_transaction"("p_transaction_id" "uuid", "p_new_start_date" "date") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."record_balance_history"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    IF TG_TABLE_NAME = 'transaction' THEN
        -- Registrar cambio en cuenta
        INSERT INTO public.balance_history (
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
            (SELECT current_balance FROM public.account WHERE id = NEW.account_id),
            (SELECT current_balance FROM public.account WHERE id = NEW.account_id) + 
                CASE 
                    WHEN EXISTS (
                        SELECT 1 FROM public.transaction_type t 
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
            SELECT 1 FROM public.transaction_type t 
            WHERE t.id = NEW.transaction_type_id AND t.code = 'EXPENSE'
        ) THEN
            INSERT INTO public.balance_history (
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
                (SELECT current_balance FROM public.jar_balance WHERE jar_id = NEW.jar_id AND user_id = NEW.user_id),
                (SELECT current_balance FROM public.jar_balance WHERE jar_id = NEW.jar_id AND user_id = NEW.user_id) - NEW.amount,
                NEW.amount,
                'TRANSACTION',
                'transaction',
                NEW.id
            );
        END IF;

    ELSIF TG_TABLE_NAME = 'transfer' THEN
        IF NEW.transfer_type = 'ACCOUNT_TO_ACCOUNT' THEN
            -- Registrar cambio en cuenta origen
            INSERT INTO public.balance_history (
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
                (SELECT current_balance FROM public.account WHERE id = NEW.from_account_id),
                (SELECT current_balance FROM public.account WHERE id = NEW.from_account_id) - NEW.amount,
                NEW.amount,
                'TRANSFER',
                'transfer',
                NEW.id
            );

            -- Registrar cambio en cuenta destino
            INSERT INTO public.balance_history (
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
                (SELECT current_balance FROM public.account WHERE id = NEW.to_account_id),
                (SELECT current_balance FROM public.account WHERE id = NEW.to_account_id) + (NEW.amount * NEW.exchange_rate),
                NEW.amount * NEW.exchange_rate,
                'TRANSFER',
                'transfer',
                NEW.id
            );

        ELSE
            -- Registrar cambio en jarra origen
            INSERT INTO public.balance_history (
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
                (SELECT current_balance FROM public.jar_balance WHERE jar_id = NEW.from_jar_id AND user_id = NEW.user_id),
                (SELECT current_balance FROM public.jar_balance WHERE jar_id = NEW.from_jar_id AND user_id = NEW.user_id) - NEW.amount,
                NEW.amount,
                CASE NEW.transfer_type
                    WHEN 'JAR_TO_JAR' THEN 'TRANSFER'
                    ELSE 'ROLLOVER'
                END,
                'transfer',
                NEW.id
            );

            -- Registrar cambio en jarra destino
            INSERT INTO public.balance_history (
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
                (SELECT current_balance FROM public.jar_balance WHERE jar_id = NEW.to_jar_id AND user_id = NEW.user_id),
                (SELECT current_balance FROM public.jar_balance WHERE jar_id = NEW.to_jar_id AND user_id = NEW.user_id) + NEW.amount,
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
END;
$$;


ALTER FUNCTION "public"."record_balance_history"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."remove_transaction_tag"("p_transaction_id" "uuid", "p_tag" "text") RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    UPDATE public.transaction
    SET tags = (
        SELECT jsonb_agg(value)
        FROM jsonb_array_elements(tags) AS t(value)
        WHERE value::text != p_tag::text
    )
    WHERE id = p_transaction_id;
END;
$$;


ALTER FUNCTION "public"."remove_transaction_tag"("p_transaction_id" "uuid", "p_tag" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."search_transactions_by_notes"("p_user_id" "uuid", "p_search_text" "text") RETURNS TABLE("id" "uuid", "transaction_date" "date", "description" "text", "amount" numeric, "tags" "jsonb", "notes" "text")
    LANGUAGE "plpgsql"
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
    FROM public.transaction t
    WHERE t.user_id = p_user_id
    AND to_tsvector('spanish', COALESCE(t.notes, '')) @@ to_tsquery('spanish', p_search_text)
    ORDER BY t.transaction_date DESC;
END;
$$;


ALTER FUNCTION "public"."search_transactions_by_notes"("p_user_id" "uuid", "p_search_text" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."search_transactions_by_tags"("p_user_id" "uuid", "p_tags" "text"[]) RETURNS TABLE("id" "uuid", "transaction_date" "date", "description" "text", "amount" numeric, "tags" "jsonb", "notes" "text")
    LANGUAGE "plpgsql"
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
    FROM public.transaction t
    WHERE t.user_id = p_user_id
    AND t.tags @> jsonb_array_to_jsonb(p_tags::jsonb[])
    ORDER BY t.transaction_date DESC;
END;
$$;


ALTER FUNCTION "public"."search_transactions_by_tags"("p_user_id" "uuid", "p_tags" "text"[]) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."track_interest_rate_changes"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
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
$$;


ALTER FUNCTION "public"."track_interest_rate_changes"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_balances"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    v_transaction_type_code text;
    v_old_balance numeric(15,2);
    v_new_balance numeric(15,2);
    v_jar_record record;
BEGIN
    -- Para transacciones
    IF TG_TABLE_NAME = 'transaction' THEN
        SELECT code INTO v_transaction_type_code
        FROM public.transaction_type
        WHERE id = NEW.transaction_type_id;

        IF v_transaction_type_code = 'EXPENSE' THEN
            -- Actualizar balance de jarra
            UPDATE public.jar_balance
            SET current_balance = current_balance - NEW.amount
            WHERE jar_id = NEW.jar_id AND user_id = NEW.user_id
            RETURNING current_balance INTO v_new_balance;

            -- Actualizar balance de cuenta
            UPDATE public.account
            SET current_balance = current_balance - NEW.amount
            WHERE id = NEW.account_id AND user_id = NEW.user_id;

        ELSIF v_transaction_type_code = 'INCOME' THEN
            -- Actualizar balance de cuenta
            UPDATE public.account
            SET current_balance = current_balance + NEW.amount
            WHERE id = NEW.account_id AND user_id = NEW.user_id;

            -- Distribuir en jarras según porcentajes
            FOR v_jar_record IN 
                SELECT j.id, j.target_percentage 
                FROM public.jar j
                WHERE j.is_active = true
            LOOP
                INSERT INTO public.jar_balance (user_id, jar_id, current_balance)
                VALUES (NEW.user_id, v_jar_record.id, 
                    NEW.amount * (v_jar_record.target_percentage / 100))
                ON CONFLICT (user_id, jar_id) DO UPDATE
                SET current_balance = jar_balance.current_balance + 
                    NEW.amount * (v_jar_record.target_percentage / 100);
            END LOOP;
        END IF;

    -- Para transferencias
    ELSIF TG_TABLE_NAME = 'transfer' THEN
        IF NEW.transfer_type = 'ACCOUNT_TO_ACCOUNT' THEN
            -- Actualizar cuenta origen
            UPDATE public.account
            SET current_balance = current_balance - NEW.amount
            WHERE id = NEW.from_account_id AND user_id = NEW.user_id;

            -- Actualizar cuenta destino
            UPDATE public.account
            SET current_balance = current_balance + (NEW.amount * NEW.exchange_rate)
            WHERE id = NEW.to_account_id AND user_id = NEW.user_id;

        ELSIF NEW.transfer_type IN ('JAR_TO_JAR', 'PERIOD_ROLLOVER') THEN
            -- Actualizar jarra origen
            UPDATE public.jar_balance
            SET current_balance = current_balance - NEW.amount
            WHERE jar_id = NEW.from_jar_id AND user_id = NEW.user_id;

            -- Actualizar jarra destino
            UPDATE public.jar_balance
            SET current_balance = current_balance + NEW.amount
            WHERE jar_id = NEW.to_jar_id AND user_id = NEW.user_id;
        END IF;
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."update_balances"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_goal_from_transaction"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    v_jar_id uuid;
BEGIN
    -- Solo procesar transacciones completadas
    IF NEW.status != 'COMPLETED' THEN
        RETURN NEW;
    END IF;

    -- Obtener jarra asociada si es un gasto
    IF EXISTS (
        SELECT 1 FROM public.transaction_type t 
        WHERE t.id = NEW.transaction_type_id 
        AND t.code = 'EXPENSE'
    ) THEN
        v_jar_id := NEW.jar_id;
    ELSE
        -- Para ingresos, obtener jarra de inversión o ahorro según subcategoría
        SELECT jar_id INTO v_jar_id
        FROM public.subcategory
        WHERE id = NEW.subcategory_id;
    END IF;

    -- Actualizar metas asociadas a la jarra
    IF v_jar_id IS NOT NULL THEN
        UPDATE public.financial_goal g
        SET current_amount = current_amount + 
            CASE 
                WHEN EXISTS (
                    SELECT 1 FROM public.transaction_type t 
                    WHERE t.id = NEW.transaction_type_id 
                    AND t.code = 'EXPENSE'
                ) THEN -NEW.amount
                ELSE NEW.amount
            END
        WHERE g.jar_id = v_jar_id
        AND g.user_id = NEW.user_id
        AND g.status = 'IN_PROGRESS';
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."update_goal_from_transaction"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_goal_progress"("p_goal_id" "uuid", "p_new_amount" numeric) RETURNS "public"."goal_progress_status"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    v_goal record;
    v_old_amount numeric(15,2);
    v_progress public.goal_progress_status;
BEGIN
    -- Obtener información de la meta
    SELECT * INTO v_goal
    FROM public.financial_goal
    WHERE id = p_goal_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Meta financiera no encontrada';
    END IF;

    -- Guardar monto anterior
    v_old_amount := v_goal.current_amount;

    -- Actualizar monto actual
    UPDATE public.financial_goal
    SET 
        current_amount = p_new_amount,
        modified_at = CURRENT_TIMESTAMP,
        status = CASE 
            WHEN p_new_amount >= target_amount THEN 'COMPLETED'
            ELSE status
        END
    WHERE id = p_goal_id
    RETURNING current_amount INTO v_goal.current_amount;

    -- Calcular nuevo progreso
    v_progress := public.calculate_goal_progress(
        v_goal.current_amount,
        v_goal.target_amount,
        v_goal.start_date,
        v_goal.target_date
    );

    -- Generar notificación si se completa la meta
    IF v_goal.current_amount >= v_goal.target_amount AND v_old_amount < v_goal.target_amount THEN
        INSERT INTO public.notification (
            user_id,
            title,
            message,
            notification_type,
            urgency_level,
            related_entity_type,
            related_entity_id
        ) VALUES (
            v_goal.user_id,
            '¡Meta financiera alcanzada!',
            format('Has alcanzado tu meta "%s" de %s', 
                v_goal.name, 
                to_char(v_goal.target_amount, 'FM999,999,999.00')
            ),
            'GOAL_PROGRESS',
            'MEDIUM',
            'financial_goal',
            v_goal.id
        );
    END IF;

    -- Generar notificación si se está desviando del objetivo
    IF NOT v_progress.is_on_track AND v_goal.status = 'IN_PROGRESS' THEN
        INSERT INTO public.notification (
            user_id,
            title,
            message,
            notification_type,
            urgency_level,
            related_entity_type,
            related_entity_id
        ) VALUES (
            v_goal.user_id,
            'Alerta de progreso de meta',
            format(
                'Tu meta "%s" está retrasada. Necesitas ahorrar %s diarios para alcanzarla.',
                v_goal.name,
                to_char(v_progress.required_daily_amount, 'FM999,999,999.00')
            ),
            'GOAL_PROGRESS',
            'HIGH',
            'financial_goal',
            v_goal.id
        );
    END IF;

    RETURN v_progress;
END;
$$;


ALTER FUNCTION "public"."update_goal_progress"("p_goal_id" "uuid", "p_new_amount" numeric) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_installment_purchases"() RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
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
$$;


ALTER FUNCTION "public"."update_installment_purchases"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_modified_timestamp"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    NEW.modified_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."update_modified_timestamp"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."validate_account_transfer"("p_user_id" "uuid", "p_from_account_id" "uuid", "p_to_account_id" "uuid", "p_amount" numeric, "p_exchange_rate" numeric DEFAULT 1) RETURNS "public"."transfer_validation_result"
    LANGUAGE "plpgsql"
    AS $$
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
$$;


ALTER FUNCTION "public"."validate_account_transfer"("p_user_id" "uuid", "p_from_account_id" "uuid", "p_to_account_id" "uuid", "p_amount" numeric, "p_exchange_rate" numeric) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."validate_credit_card_transaction"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
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
$$;


ALTER FUNCTION "public"."validate_credit_card_transaction"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."validate_credit_limit"("p_account_id" "uuid", "p_amount" numeric) RETURNS boolean
    LANGUAGE "plpgsql"
    AS $$
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
$$;


ALTER FUNCTION "public"."validate_credit_limit"("p_account_id" "uuid", "p_amount" numeric) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."validate_jar_transfer"("p_user_id" "uuid", "p_from_jar_id" "uuid", "p_to_jar_id" "uuid", "p_amount" numeric) RETURNS "public"."transfer_validation_result"
    LANGUAGE "plpgsql"
    AS $$
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
$$;


ALTER FUNCTION "public"."validate_jar_transfer"("p_user_id" "uuid", "p_from_jar_id" "uuid", "p_to_jar_id" "uuid", "p_amount" numeric) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."validate_recurring_transaction"("p_user_id" "uuid", "p_amount" numeric, "p_transaction_type_id" "uuid", "p_account_id" "uuid", "p_jar_id" "uuid" DEFAULT NULL::"uuid") RETURNS boolean
    LANGUAGE "plpgsql"
    AS $$
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
$$;


ALTER FUNCTION "public"."validate_recurring_transaction"("p_user_id" "uuid", "p_amount" numeric, "p_transaction_type_id" "uuid", "p_account_id" "uuid", "p_jar_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."validate_sufficient_balance"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    v_current_balance numeric(15,2);
    v_entity_type text;
    v_transaction_type_code text;
BEGIN
    -- Para transacciones, verificar si es gasto
    IF TG_TABLE_NAME = 'transaction' THEN
        SELECT code INTO v_transaction_type_code
        FROM public.transaction_type
        WHERE id = NEW.transaction_type_id;

        -- Solo validar balance para gastos
        IF v_transaction_type_code = 'EXPENSE' THEN
            IF NEW.jar_id IS NOT NULL THEN
                SELECT current_balance INTO v_current_balance
                FROM public.jar_balance
                WHERE jar_id = NEW.jar_id AND user_id = NEW.user_id;
                v_entity_type := 'jar';
            ELSE
                SELECT current_balance INTO v_current_balance
                FROM public.account
                WHERE id = NEW.account_id AND user_id = NEW.user_id;
                v_entity_type := 'account';
            END IF;

            -- Validar balance suficiente
            IF v_current_balance < NEW.amount THEN
                RAISE EXCEPTION 'Saldo insuficiente en % (Disponible: %, Requerido: %)',
                    v_entity_type, v_current_balance, NEW.amount;
            END IF;
        END IF;
    
    -- Para transferencias
    ELSIF TG_TABLE_NAME = 'transfer' THEN
        IF NEW.transfer_type = 'ACCOUNT_TO_ACCOUNT' THEN
            SELECT current_balance INTO v_current_balance
            FROM public.account
            WHERE id = NEW.from_account_id AND user_id = NEW.user_id;
            v_entity_type := 'account';
        ELSE
            SELECT current_balance INTO v_current_balance
            FROM public.jar_balance
            WHERE jar_id = NEW.from_jar_id AND user_id = NEW.user_id;
            v_entity_type := 'jar';
        END IF;

        -- Validar balance suficiente
        IF v_current_balance < NEW.amount THEN
            RAISE EXCEPTION 'Saldo insuficiente en % (Disponible: %, Requerido: %)',
                v_entity_type, v_current_balance, NEW.amount;
        END IF;
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."validate_sufficient_balance"() OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."account" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "account_type_id" "uuid" NOT NULL,
    "name" "text" NOT NULL,
    "description" "text",
    "currency_id" "uuid" NOT NULL,
    "current_balance" numeric(15,2) DEFAULT 0 NOT NULL,
    "is_active" boolean DEFAULT true NOT NULL,
    "created_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "modified_at" timestamp with time zone
);


ALTER TABLE "public"."account" OWNER TO "postgres";


COMMENT ON TABLE "public"."account" IS 'Cuentas financieras de los usuarios';



CREATE TABLE IF NOT EXISTS "public"."account_type" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "description" "text",
    "is_active" boolean DEFAULT true NOT NULL,
    "created_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "modified_at" timestamp with time zone
);


ALTER TABLE "public"."account_type" OWNER TO "postgres";


COMMENT ON TABLE "public"."account_type" IS 'Tipos de cuenta soportados';



CREATE TABLE IF NOT EXISTS "public"."app_user" (
    "id" "uuid" NOT NULL,
    "email" "text" NOT NULL,
    "first_name" "text",
    "last_name" "text",
    "default_currency_id" "uuid" NOT NULL,
    "notifications_enabled" boolean DEFAULT true,
    "notification_advance_days" integer DEFAULT 1,
    "is_active" boolean DEFAULT true NOT NULL,
    "created_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    "modified_at" timestamp with time zone,
    CONSTRAINT "valid_notification_days" CHECK (("notification_advance_days" > 0))
);


ALTER TABLE "public"."app_user" OWNER TO "postgres";


COMMENT ON TABLE "public"."app_user" IS 'Información extendida de usuarios';



COMMENT ON COLUMN "public"."app_user"."notification_advance_days" IS 'Días de anticipación para notificaciones recurrentes';



CREATE TABLE IF NOT EXISTS "public"."balance_history" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "account_id" "uuid",
    "jar_id" "uuid",
    "old_balance" numeric(15,2) NOT NULL,
    "new_balance" numeric(15,2) NOT NULL,
    "change_amount" numeric(15,2) NOT NULL,
    "change_type" character varying(50) NOT NULL,
    "reference_type" character varying(50) NOT NULL,
    "reference_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT "balance_history_change_type_check" CHECK ((("change_type")::"text" = ANY ((ARRAY['TRANSACTION'::character varying, 'TRANSFER'::character varying, 'ADJUSTMENT'::character varying, 'ROLLOVER'::character varying])::"text"[]))),
    CONSTRAINT "valid_target" CHECK (((("account_id" IS NOT NULL) AND ("jar_id" IS NULL)) OR (("account_id" IS NULL) AND ("jar_id" IS NOT NULL))))
);


ALTER TABLE "public"."balance_history" OWNER TO "postgres";


COMMENT ON TABLE "public"."balance_history" IS 'Historial de cambios en balances';



CREATE TABLE IF NOT EXISTS "public"."category" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "description" "text",
    "transaction_type_id" "uuid" NOT NULL,
    "is_active" boolean DEFAULT true NOT NULL,
    "created_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "modified_at" timestamp with time zone
);


ALTER TABLE "public"."category" OWNER TO "postgres";


COMMENT ON TABLE "public"."category" IS 'Categorías para clasificación de transacciones';



CREATE TABLE IF NOT EXISTS "public"."credit_card_details" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "account_id" "uuid" NOT NULL,
    "credit_limit" numeric(15,2) NOT NULL,
    "current_interest_rate" numeric(5,2) NOT NULL,
    "cut_off_day" integer NOT NULL,
    "payment_due_day" integer NOT NULL,
    "minimum_payment_percentage" numeric(5,2) NOT NULL,
    "created_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "modified_at" timestamp with time zone,
    CONSTRAINT "credit_card_details_credit_limit_check" CHECK (("credit_limit" > (0)::numeric)),
    CONSTRAINT "credit_card_details_current_interest_rate_check" CHECK (("current_interest_rate" >= (0)::numeric)),
    CONSTRAINT "credit_card_details_cut_off_day_check" CHECK ((("cut_off_day" >= 1) AND ("cut_off_day" <= 31))),
    CONSTRAINT "credit_card_details_minimum_payment_percentage_check" CHECK (("minimum_payment_percentage" > (0)::numeric)),
    CONSTRAINT "credit_card_details_payment_due_day_check" CHECK ((("payment_due_day" >= 1) AND ("payment_due_day" <= 31))),
    CONSTRAINT "valid_days_order" CHECK ((("payment_due_day" > "cut_off_day") OR ("payment_due_day" < "cut_off_day")))
);


ALTER TABLE "public"."credit_card_details" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."credit_card_interest_history" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "credit_card_id" "uuid" NOT NULL,
    "old_rate" numeric(5,2) NOT NULL,
    "new_rate" numeric(5,2) NOT NULL,
    "change_date" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "reason" "text",
    "created_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT "credit_card_interest_history_new_rate_check" CHECK (("new_rate" >= (0)::numeric)),
    CONSTRAINT "credit_card_interest_history_old_rate_check" CHECK (("old_rate" >= (0)::numeric))
);


ALTER TABLE "public"."credit_card_interest_history" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."credit_card_statement" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "credit_card_id" "uuid" NOT NULL,
    "statement_date" "date" NOT NULL,
    "cut_off_date" "date" NOT NULL,
    "due_date" "date" NOT NULL,
    "previous_balance" numeric(15,2) NOT NULL,
    "purchases_amount" numeric(15,2) DEFAULT 0 NOT NULL,
    "payments_amount" numeric(15,2) DEFAULT 0 NOT NULL,
    "interests_amount" numeric(15,2) DEFAULT 0 NOT NULL,
    "ending_balance" numeric(15,2) NOT NULL,
    "minimum_payment" numeric(15,2) NOT NULL,
    "remaining_credit" numeric(15,2) NOT NULL,
    "status" character varying(20) NOT NULL,
    "created_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "modified_at" timestamp with time zone,
    CONSTRAINT "credit_card_statement_status_check" CHECK ((("status")::"text" = ANY ((ARRAY['PENDING'::character varying, 'PAID_MINIMUM'::character varying, 'PAID_FULL'::character varying])::"text"[]))),
    CONSTRAINT "valid_dates" CHECK ((("statement_date" <= "cut_off_date") AND ("cut_off_date" < "due_date")))
);


ALTER TABLE "public"."credit_card_statement" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."currency" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "code" character varying(3) NOT NULL,
    "name" "text" NOT NULL,
    "symbol" character varying(5),
    "is_active" boolean DEFAULT true NOT NULL,
    "created_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "modified_at" timestamp with time zone
);


ALTER TABLE "public"."currency" OWNER TO "postgres";


COMMENT ON TABLE "public"."currency" IS 'Catálogo de monedas soportadas';



CREATE TABLE IF NOT EXISTS "public"."transaction" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "transaction_date" "date" DEFAULT CURRENT_DATE NOT NULL,
    "description" "text",
    "amount" numeric(15,2) NOT NULL,
    "transaction_type_id" "uuid" NOT NULL,
    "category_id" "uuid" NOT NULL,
    "subcategory_id" "uuid" NOT NULL,
    "account_id" "uuid" NOT NULL,
    "jar_id" "uuid",
    "transaction_medium_id" "uuid",
    "currency_id" "uuid" NOT NULL,
    "exchange_rate" numeric(10,6) DEFAULT 1 NOT NULL,
    "is_recurring" boolean DEFAULT false,
    "parent_recurring_id" "uuid",
    "sync_status" character varying(20) DEFAULT 'PENDING'::character varying NOT NULL,
    "created_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "modified_at" timestamp with time zone,
    "installment_purchase_id" "uuid",
    "tags" "jsonb" DEFAULT '[]'::"jsonb",
    "notes" "text",
    CONSTRAINT "transaction_amount_check" CHECK (("amount" <> (0)::numeric)),
    CONSTRAINT "transaction_sync_status_check" CHECK ((("sync_status")::"text" = ANY ((ARRAY['PENDING'::character varying, 'SYNCED'::character varying, 'ERROR'::character varying])::"text"[]))),
    CONSTRAINT "transaction_tags_is_array" CHECK (("jsonb_typeof"("tags") = 'array'::"text")),
    CONSTRAINT "valid_exchange_rate" CHECK (("exchange_rate" > (0)::numeric))
);


ALTER TABLE "public"."transaction" OWNER TO "postgres";


COMMENT ON TABLE "public"."transaction" IS 'Registro de todas las transacciones financieras';



COMMENT ON COLUMN "public"."transaction"."tags" IS 'Array of tags for transaction classification and searching';



COMMENT ON COLUMN "public"."transaction"."notes" IS 'Additional notes and details about the transaction';



CREATE TABLE IF NOT EXISTS "public"."transaction_type" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "description" "text",
    "is_active" boolean DEFAULT true NOT NULL,
    "created_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "modified_at" timestamp with time zone
);


ALTER TABLE "public"."transaction_type" OWNER TO "postgres";


COMMENT ON TABLE "public"."transaction_type" IS 'Tipos de transacciones soportadas';



CREATE OR REPLACE VIEW "public"."expense_trends_analysis" AS
 WITH "monthly_expenses" AS (
         SELECT "t"."user_id",
            "date_trunc"('month'::"text", ("t"."transaction_date")::timestamp with time zone) AS "month",
            "c"."name" AS "category_name",
            "sum"("t"."amount") AS "total_amount",
            "count"(*) AS "transaction_count"
           FROM (("public"."transaction" "t"
             JOIN "public"."transaction_type" "tt" ON (("tt"."id" = "t"."transaction_type_id")))
             JOIN "public"."category" "c" ON (("c"."id" = "t"."category_id")))
          WHERE ("tt"."name" = 'Gasto'::"text")
          GROUP BY "t"."user_id", ("date_trunc"('month'::"text", ("t"."transaction_date")::timestamp with time zone)), "c"."name"
        )
 SELECT "monthly_expenses"."user_id",
    "monthly_expenses"."month",
    "monthly_expenses"."category_name",
    "monthly_expenses"."total_amount",
    "monthly_expenses"."transaction_count",
    "lag"("monthly_expenses"."total_amount") OVER (PARTITION BY "monthly_expenses"."user_id", "monthly_expenses"."category_name" ORDER BY "monthly_expenses"."month") AS "prev_month_amount",
    "round"(((("monthly_expenses"."total_amount" - "lag"("monthly_expenses"."total_amount") OVER (PARTITION BY "monthly_expenses"."user_id", "monthly_expenses"."category_name" ORDER BY "monthly_expenses"."month")) / NULLIF("lag"("monthly_expenses"."total_amount") OVER (PARTITION BY "monthly_expenses"."user_id", "monthly_expenses"."category_name" ORDER BY "monthly_expenses"."month"), (0)::numeric)) * (100)::numeric), 2) AS "month_over_month_change",
    "avg"("monthly_expenses"."total_amount") OVER (PARTITION BY "monthly_expenses"."user_id", "monthly_expenses"."category_name" ORDER BY "monthly_expenses"."month" ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS "three_month_moving_avg"
   FROM "monthly_expenses";


ALTER TABLE "public"."expense_trends_analysis" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."financial_goal" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "name" "text" NOT NULL,
    "description" "text",
    "target_amount" numeric(15,2) NOT NULL,
    "current_amount" numeric(15,2) DEFAULT 0 NOT NULL,
    "start_date" "date" NOT NULL,
    "target_date" "date" NOT NULL,
    "jar_id" "uuid",
    "status" character varying(20) DEFAULT 'IN_PROGRESS'::character varying NOT NULL,
    "is_active" boolean DEFAULT true NOT NULL,
    "created_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "modified_at" timestamp with time zone,
    CONSTRAINT "financial_goal_status_check" CHECK ((("status")::"text" = ANY ((ARRAY['IN_PROGRESS'::character varying, 'COMPLETED'::character varying, 'CANCELLED'::character varying])::"text"[]))),
    CONSTRAINT "financial_goal_target_amount_check" CHECK (("target_amount" > (0)::numeric)),
    CONSTRAINT "valid_amounts" CHECK (("current_amount" <= "target_amount")),
    CONSTRAINT "valid_dates" CHECK (("target_date" > "start_date"))
);


ALTER TABLE "public"."financial_goal" OWNER TO "postgres";


COMMENT ON TABLE "public"."financial_goal" IS 'Metas financieras de ahorro e inversión';



CREATE TABLE IF NOT EXISTS "public"."jar" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "description" "text",
    "target_percentage" numeric(5,2) NOT NULL,
    "is_active" boolean DEFAULT true NOT NULL,
    "created_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "modified_at" timestamp with time zone,
    CONSTRAINT "valid_percentage" CHECK ((("target_percentage" > (0)::numeric) AND ("target_percentage" <= (100)::numeric)))
);


ALTER TABLE "public"."jar" OWNER TO "postgres";


COMMENT ON TABLE "public"."jar" IS 'Jarras según metodología de T. Harv Eker';



COMMENT ON COLUMN "public"."jar"."target_percentage" IS 'Porcentaje que debe recibir la jarra de los ingresos';



CREATE OR REPLACE VIEW "public"."goal_progress_summary" AS
 WITH "goal_progress" AS (
         SELECT "g_1"."id",
            "g_1"."user_id",
            "g_1"."name",
            "g_1"."description",
            "g_1"."target_amount",
            "g_1"."current_amount",
            "g_1"."start_date",
            "g_1"."target_date",
            "g_1"."jar_id",
            "g_1"."status",
            "g_1"."is_active",
            "g_1"."created_at",
            "g_1"."modified_at",
            "public"."calculate_goal_progress"("g_1"."current_amount", "g_1"."target_amount", "g_1"."start_date", "g_1"."target_date") AS "progress"
           FROM "public"."financial_goal" "g_1"
          WHERE ("g_1"."is_active" = true)
        )
 SELECT "g"."user_id",
    "g"."id" AS "goal_id",
    "g"."name",
    "g"."target_amount",
    "g"."current_amount",
    ("g"."progress")."percentage_complete" AS "percentage_complete",
    ("g"."progress")."amount_remaining" AS "amount_remaining",
    ("g"."progress")."days_remaining" AS "days_remaining",
    ("g"."progress")."is_on_track" AS "is_on_track",
    ("g"."progress")."required_daily_amount" AS "required_daily_amount",
    "j"."name" AS "jar_name",
    "g"."status",
    "g"."start_date",
    "g"."target_date",
    "g"."created_at",
    "g"."modified_at"
   FROM ("goal_progress" "g"
     LEFT JOIN "public"."jar" "j" ON (("j"."id" = "g"."jar_id")));


ALTER TABLE "public"."goal_progress_summary" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."installment_purchase" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "transaction_id" "uuid" NOT NULL,
    "credit_card_id" "uuid" NOT NULL,
    "total_amount" numeric(15,2) NOT NULL,
    "number_of_installments" integer NOT NULL,
    "installment_amount" numeric(15,2) NOT NULL,
    "remaining_installments" integer NOT NULL,
    "next_installment_date" "date" NOT NULL,
    "status" character varying(20) NOT NULL,
    "created_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "modified_at" timestamp with time zone,
    CONSTRAINT "installment_purchase_installment_amount_check" CHECK (("installment_amount" > (0)::numeric)),
    CONSTRAINT "installment_purchase_number_of_installments_check" CHECK (("number_of_installments" > 0)),
    CONSTRAINT "installment_purchase_status_check" CHECK ((("status")::"text" = ANY ((ARRAY['ACTIVE'::character varying, 'COMPLETED'::character varying, 'CANCELLED'::character varying])::"text"[]))),
    CONSTRAINT "installment_purchase_total_amount_check" CHECK (("total_amount" > (0)::numeric))
);


ALTER TABLE "public"."installment_purchase" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."jar_balance" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "jar_id" "uuid" NOT NULL,
    "current_balance" numeric(15,2) DEFAULT 0 NOT NULL,
    "created_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "modified_at" timestamp with time zone
);


ALTER TABLE "public"."jar_balance" OWNER TO "postgres";


COMMENT ON TABLE "public"."jar_balance" IS 'Balance actual de cada jarra por usuario';



CREATE OR REPLACE VIEW "public"."methodology_compliance_analysis" AS
 WITH "jar_distributions" AS (
         SELECT "t"."user_id",
            "date_trunc"('month'::"text", ("t"."transaction_date")::timestamp with time zone) AS "month",
            "j"."name" AS "jar_name",
            "j"."target_percentage",
            "sum"("t"."amount") AS "jar_amount",
            "sum"("sum"("t"."amount")) OVER (PARTITION BY "t"."user_id", ("date_trunc"('month'::"text", ("t"."transaction_date")::timestamp with time zone))) AS "total_amount"
           FROM (("public"."transaction" "t"
             JOIN "public"."transaction_type" "tt" ON (("tt"."id" = "t"."transaction_type_id")))
             JOIN "public"."jar" "j" ON (("j"."id" = "t"."jar_id")))
          WHERE ("tt"."name" = 'Gasto'::"text")
          GROUP BY "t"."user_id", ("date_trunc"('month'::"text", ("t"."transaction_date")::timestamp with time zone)), "j"."name", "j"."target_percentage"
        )
 SELECT "jar_distributions"."user_id",
    "jar_distributions"."month",
    "jar_distributions"."jar_name",
    "jar_distributions"."target_percentage",
    "round"((("jar_distributions"."jar_amount" / NULLIF("jar_distributions"."total_amount", (0)::numeric)) * (100)::numeric), 2) AS "actual_percentage",
    "round"(((("jar_distributions"."jar_amount" / NULLIF("jar_distributions"."total_amount", (0)::numeric)) * (100)::numeric) - "jar_distributions"."target_percentage"), 2) AS "percentage_difference",
    ("abs"(((("jar_distributions"."jar_amount" / NULLIF("jar_distributions"."total_amount", (0)::numeric)) * (100)::numeric) - "jar_distributions"."target_percentage")) <= (2)::numeric) AS "is_compliant"
   FROM "jar_distributions";


ALTER TABLE "public"."methodology_compliance_analysis" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."notification" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "title" "text" NOT NULL,
    "message" "text" NOT NULL,
    "notification_type" character varying(50) NOT NULL,
    "urgency_level" character varying(20) NOT NULL,
    "related_entity_type" character varying(50),
    "related_entity_id" "uuid",
    "is_read" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "read_at" timestamp with time zone,
    CONSTRAINT "notification_notification_type_check" CHECK ((("notification_type")::"text" = ANY ((ARRAY['RECURRING_TRANSACTION'::character varying, 'INSUFFICIENT_FUNDS'::character varying, 'GOAL_PROGRESS'::character varying, 'SYNC_ERROR'::character varying, 'SYSTEM'::character varying, 'CREDIT_CARD_DUE_DATE'::character varying, 'CREDIT_CARD_CUT_OFF'::character varying, 'CREDIT_CARD_LIMIT'::character varying, 'CREDIT_CARD_MINIMUM_PAYMENT'::character varying])::"text"[]))),
    CONSTRAINT "notification_urgency_level_check" CHECK ((("urgency_level")::"text" = ANY ((ARRAY['LOW'::character varying, 'MEDIUM'::character varying, 'HIGH'::character varying])::"text"[])))
);


ALTER TABLE "public"."notification" OWNER TO "postgres";


COMMENT ON TABLE "public"."notification" IS 'Registro de notificaciones del sistema';



CREATE TABLE IF NOT EXISTS "public"."recurring_transaction" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "name" "text" NOT NULL,
    "description" "text",
    "amount" numeric(15,2) NOT NULL,
    "transaction_type_id" "uuid" NOT NULL,
    "category_id" "uuid" NOT NULL,
    "subcategory_id" "uuid" NOT NULL,
    "account_id" "uuid" NOT NULL,
    "jar_id" "uuid",
    "transaction_medium_id" "uuid",
    "frequency" character varying(20) NOT NULL,
    "start_date" "date" NOT NULL,
    "end_date" "date",
    "last_execution_date" "date",
    "next_execution_date" "date",
    "is_active" boolean DEFAULT true NOT NULL,
    "created_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "modified_at" timestamp with time zone,
    CONSTRAINT "recurring_transaction_amount_check" CHECK (("amount" <> (0)::numeric)),
    CONSTRAINT "recurring_transaction_frequency_check" CHECK ((("frequency")::"text" = ANY ((ARRAY['WEEKLY'::character varying, 'MONTHLY'::character varying, 'YEARLY'::character varying])::"text"[]))),
    CONSTRAINT "valid_dates" CHECK (((("end_date" IS NULL) OR ("end_date" >= "start_date")) AND (("next_execution_date" IS NULL) OR ("next_execution_date" >= CURRENT_DATE))))
);


ALTER TABLE "public"."recurring_transaction" OWNER TO "postgres";


COMMENT ON TABLE "public"."recurring_transaction" IS 'Configuración de transacciones recurrentes';



CREATE TABLE IF NOT EXISTS "public"."schema_migrations" (
    "version" "text" NOT NULL
);


ALTER TABLE "public"."schema_migrations" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."subcategory" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "description" "text",
    "category_id" "uuid" NOT NULL,
    "jar_id" "uuid",
    "is_active" boolean DEFAULT true NOT NULL,
    "created_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "modified_at" timestamp with time zone
);


ALTER TABLE "public"."subcategory" OWNER TO "postgres";


COMMENT ON TABLE "public"."subcategory" IS 'Subcategorías para clasificación detallada';



COMMENT ON COLUMN "public"."subcategory"."jar_id" IS 'Jarra asociada, requerida solo para gastos';



CREATE TABLE IF NOT EXISTS "public"."transaction_medium" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "description" "text",
    "is_active" boolean DEFAULT true NOT NULL,
    "created_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "modified_at" timestamp with time zone
);


ALTER TABLE "public"."transaction_medium" OWNER TO "postgres";


COMMENT ON TABLE "public"."transaction_medium" IS 'Medios de pago soportados';



CREATE TABLE IF NOT EXISTS "public"."transfer" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "transfer_date" "date" DEFAULT CURRENT_DATE NOT NULL,
    "description" "text",
    "amount" numeric(15,2) NOT NULL,
    "transfer_type" character varying(20) NOT NULL,
    "from_account_id" "uuid",
    "to_account_id" "uuid",
    "from_jar_id" "uuid",
    "to_jar_id" "uuid",
    "exchange_rate" numeric(10,6) DEFAULT 1 NOT NULL,
    "notes" "text",
    "sync_status" character varying(20) DEFAULT 'PENDING'::character varying NOT NULL,
    "created_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "modified_at" timestamp with time zone,
    CONSTRAINT "different_endpoints" CHECK (((("from_account_id" IS NULL) OR ("from_account_id" <> "to_account_id")) AND (("from_jar_id" IS NULL) OR ("from_jar_id" <> "to_jar_id")))),
    CONSTRAINT "transfer_amount_check" CHECK (("amount" > (0)::numeric)),
    CONSTRAINT "transfer_sync_status_check" CHECK ((("sync_status")::"text" = ANY ((ARRAY['PENDING'::character varying, 'SYNCED'::character varying, 'ERROR'::character varying])::"text"[]))),
    CONSTRAINT "transfer_transfer_type_check" CHECK ((("transfer_type")::"text" = ANY ((ARRAY['ACCOUNT_TO_ACCOUNT'::character varying, 'JAR_TO_JAR'::character varying, 'PERIOD_ROLLOVER'::character varying])::"text"[]))),
    CONSTRAINT "valid_transfer_endpoints" CHECK ((((("transfer_type")::"text" = 'ACCOUNT_TO_ACCOUNT'::"text") AND ("from_account_id" IS NOT NULL) AND ("to_account_id" IS NOT NULL) AND ("from_jar_id" IS NULL) AND ("to_jar_id" IS NULL)) OR ((("transfer_type")::"text" = 'JAR_TO_JAR'::"text") AND ("from_jar_id" IS NOT NULL) AND ("to_jar_id" IS NOT NULL) AND ("from_account_id" IS NULL) AND ("to_account_id" IS NULL)) OR ((("transfer_type")::"text" = 'PERIOD_ROLLOVER'::"text") AND ("from_jar_id" IS NOT NULL) AND ("to_jar_id" IS NOT NULL) AND ("from_account_id" IS NULL) AND ("to_account_id" IS NULL))))
);


ALTER TABLE "public"."transfer" OWNER TO "postgres";


COMMENT ON TABLE "public"."transfer" IS 'Registro de transferencias entre cuentas y jarras';



COMMENT ON COLUMN "public"."transfer"."transfer_type" IS 'ACCOUNT_TO_ACCOUNT: entre cuentas, JAR_TO_JAR: entre jarras, PERIOD_ROLLOVER: rollover de periodo';



CREATE OR REPLACE VIEW "public"."transfer_summary" AS
 SELECT "t"."user_id",
    "t"."transfer_type",
    "t"."transfer_date",
    "t"."amount",
    "t"."exchange_rate",
        CASE
            WHEN (("t"."transfer_type")::"text" = 'ACCOUNT_TO_ACCOUNT'::"text") THEN ( SELECT "account"."name"
               FROM "public"."account"
              WHERE ("account"."id" = "t"."from_account_id"))
            ELSE ( SELECT "jar"."name"
               FROM "public"."jar"
              WHERE ("jar"."id" = "t"."from_jar_id"))
        END AS "source_name",
        CASE
            WHEN (("t"."transfer_type")::"text" = 'ACCOUNT_TO_ACCOUNT'::"text") THEN ( SELECT "account"."name"
               FROM "public"."account"
              WHERE ("account"."id" = "t"."to_account_id"))
            ELSE ( SELECT "jar"."name"
               FROM "public"."jar"
              WHERE ("jar"."id" = "t"."to_jar_id"))
        END AS "target_name",
        CASE
            WHEN (("t"."transfer_type")::"text" = 'ACCOUNT_TO_ACCOUNT'::"text") THEN ("t"."amount" * "t"."exchange_rate")
            ELSE "t"."amount"
        END AS "converted_amount",
    "t"."description",
    "t"."sync_status",
    "t"."created_at"
   FROM "public"."transfer" "t";


ALTER TABLE "public"."transfer_summary" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."transfer_analysis" AS
 WITH "monthly_stats" AS (
         SELECT "transfer_summary"."user_id",
            "date_trunc"('month'::"text", ("transfer_summary"."transfer_date")::timestamp with time zone) AS "month",
            "transfer_summary"."transfer_type",
            "count"(*) AS "transfer_count",
            "sum"("transfer_summary"."converted_amount") AS "total_amount",
            "avg"("transfer_summary"."converted_amount") AS "avg_amount"
           FROM "public"."transfer_summary"
          GROUP BY "transfer_summary"."user_id", ("date_trunc"('month'::"text", ("transfer_summary"."transfer_date")::timestamp with time zone)), "transfer_summary"."transfer_type"
        ), "monthly_changes" AS (
         SELECT "monthly_stats"."user_id",
            "monthly_stats"."month",
            "monthly_stats"."transfer_type",
            "monthly_stats"."transfer_count",
            "monthly_stats"."total_amount",
            "monthly_stats"."avg_amount",
            "lag"("monthly_stats"."total_amount") OVER (PARTITION BY "monthly_stats"."user_id", "monthly_stats"."transfer_type" ORDER BY "monthly_stats"."month") AS "prev_month_amount"
           FROM "monthly_stats"
        )
 SELECT "monthly_changes"."user_id",
    "monthly_changes"."month",
    "monthly_changes"."transfer_type",
    "monthly_changes"."transfer_count",
    "monthly_changes"."total_amount",
    "monthly_changes"."avg_amount",
    "monthly_changes"."prev_month_amount",
    "round"(((("monthly_changes"."total_amount" - "monthly_changes"."prev_month_amount") / NULLIF("monthly_changes"."prev_month_amount", (0)::numeric)) * (100)::numeric), 2) AS "month_over_month_change"
   FROM "monthly_changes";


ALTER TABLE "public"."transfer_analysis" OWNER TO "postgres";


ALTER TABLE ONLY "public"."account"
    ADD CONSTRAINT "account_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."account_type"
    ADD CONSTRAINT "account_type_name_unique" UNIQUE ("name");



ALTER TABLE ONLY "public"."account_type"
    ADD CONSTRAINT "account_type_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."app_user"
    ADD CONSTRAINT "app_user_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."balance_history"
    ADD CONSTRAINT "balance_history_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."category"
    ADD CONSTRAINT "category_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."credit_card_details"
    ADD CONSTRAINT "credit_card_details_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."credit_card_interest_history"
    ADD CONSTRAINT "credit_card_interest_history_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."credit_card_statement"
    ADD CONSTRAINT "credit_card_statement_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."currency"
    ADD CONSTRAINT "currency_code_key" UNIQUE ("code");



ALTER TABLE ONLY "public"."currency"
    ADD CONSTRAINT "currency_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."financial_goal"
    ADD CONSTRAINT "financial_goal_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."installment_purchase"
    ADD CONSTRAINT "installment_purchase_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."jar_balance"
    ADD CONSTRAINT "jar_balance_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."jar"
    ADD CONSTRAINT "jar_name_unique" UNIQUE ("name");



ALTER TABLE ONLY "public"."jar"
    ADD CONSTRAINT "jar_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."notification"
    ADD CONSTRAINT "notification_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."recurring_transaction"
    ADD CONSTRAINT "recurring_transaction_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."schema_migrations"
    ADD CONSTRAINT "schema_migrations_pkey" PRIMARY KEY ("version");



ALTER TABLE ONLY "public"."subcategory"
    ADD CONSTRAINT "subcategory_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."transaction_medium"
    ADD CONSTRAINT "transaction_medium_name_unique" UNIQUE ("name");



ALTER TABLE ONLY "public"."transaction_medium"
    ADD CONSTRAINT "transaction_medium_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."transaction"
    ADD CONSTRAINT "transaction_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."transaction_type"
    ADD CONSTRAINT "transaction_type_name_unique" UNIQUE ("name");



ALTER TABLE ONLY "public"."transaction_type"
    ADD CONSTRAINT "transaction_type_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."transfer"
    ADD CONSTRAINT "transfer_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."credit_card_details"
    ADD CONSTRAINT "unique_account_credit_card" UNIQUE ("account_id");



ALTER TABLE ONLY "public"."account"
    ADD CONSTRAINT "unique_account_name_per_user" UNIQUE ("user_id", "name");



ALTER TABLE ONLY "public"."jar_balance"
    ADD CONSTRAINT "unique_jar_per_user" UNIQUE ("user_id", "jar_id");



ALTER TABLE ONLY "public"."credit_card_statement"
    ADD CONSTRAINT "unique_statement_period" UNIQUE ("credit_card_id", "statement_date");



CREATE INDEX "idx_account_active" ON "public"."account" USING "btree" ("id") WHERE ("is_active" = true);



CREATE INDEX "idx_account_type" ON "public"."account" USING "btree" ("account_type_id");



CREATE INDEX "idx_account_user" ON "public"."account" USING "btree" ("user_id");



CREATE INDEX "idx_app_user_active" ON "public"."app_user" USING "btree" ("id") WHERE ("is_active" = true);



CREATE INDEX "idx_app_user_email" ON "public"."app_user" USING "btree" ("email");



CREATE INDEX "idx_balance_history_account" ON "public"."balance_history" USING "btree" ("account_id") WHERE ("account_id" IS NOT NULL);



CREATE INDEX "idx_balance_history_jar" ON "public"."balance_history" USING "btree" ("jar_id") WHERE ("jar_id" IS NOT NULL);



CREATE INDEX "idx_balance_history_reference" ON "public"."balance_history" USING "btree" ("reference_type", "reference_id");



CREATE INDEX "idx_balance_history_user" ON "public"."balance_history" USING "btree" ("user_id");



CREATE INDEX "idx_category_active" ON "public"."category" USING "btree" ("id") WHERE ("is_active" = true);



CREATE INDEX "idx_category_type" ON "public"."category" USING "btree" ("transaction_type_id");



CREATE INDEX "idx_credit_card_cut_off" ON "public"."credit_card_details" USING "btree" ("cut_off_day");



CREATE INDEX "idx_credit_card_details_account" ON "public"."credit_card_details" USING "btree" ("account_id");



CREATE INDEX "idx_credit_card_statement_dates" ON "public"."credit_card_statement" USING "btree" ("credit_card_id", "statement_date");



CREATE INDEX "idx_credit_card_statement_due" ON "public"."credit_card_statement" USING "btree" ("credit_card_id", "due_date") WHERE (("status")::"text" = 'PENDING'::"text");



CREATE INDEX "idx_currency_code" ON "public"."currency" USING "btree" ("code");



CREATE INDEX "idx_currency_name" ON "public"."currency" USING "btree" ("name");



CREATE INDEX "idx_financial_goal_active" ON "public"."financial_goal" USING "btree" ("id") WHERE ("is_active" = true);



CREATE INDEX "idx_financial_goal_dates" ON "public"."financial_goal" USING "btree" ("start_date", "target_date");



CREATE INDEX "idx_financial_goal_status" ON "public"."financial_goal" USING "btree" ("status");



CREATE INDEX "idx_financial_goal_user" ON "public"."financial_goal" USING "btree" ("user_id");



CREATE INDEX "idx_installment_purchase_active" ON "public"."installment_purchase" USING "btree" ("credit_card_id", "next_installment_date") WHERE (("status")::"text" = 'ACTIVE'::"text");



CREATE INDEX "idx_jar_active" ON "public"."jar" USING "btree" ("id") WHERE ("is_active" = true);



CREATE INDEX "idx_jar_balance_jar" ON "public"."jar_balance" USING "btree" ("jar_id");



CREATE INDEX "idx_jar_balance_user" ON "public"."jar_balance" USING "btree" ("user_id");



CREATE INDEX "idx_jar_name" ON "public"."jar" USING "btree" ("name");



CREATE INDEX "idx_notification_entity" ON "public"."notification" USING "btree" ("related_entity_type", "related_entity_id") WHERE ("related_entity_id" IS NOT NULL);



CREATE INDEX "idx_notification_type" ON "public"."notification" USING "btree" ("notification_type");



CREATE INDEX "idx_notification_unread" ON "public"."notification" USING "btree" ("id") WHERE (NOT "is_read");



CREATE INDEX "idx_notification_user" ON "public"."notification" USING "btree" ("user_id");



CREATE INDEX "idx_recurring_transaction_next_no_end" ON "public"."recurring_transaction" USING "btree" ("next_execution_date") WHERE (("is_active" = true) AND ("end_date" IS NULL));



CREATE INDEX "idx_recurring_transaction_next_with_end" ON "public"."recurring_transaction" USING "btree" ("next_execution_date", "end_date") WHERE ("is_active" = true);



CREATE INDEX "idx_recurring_transaction_user" ON "public"."recurring_transaction" USING "btree" ("user_id");



CREATE INDEX "idx_subcategory_active" ON "public"."subcategory" USING "btree" ("id") WHERE ("is_active" = true);



CREATE INDEX "idx_subcategory_category" ON "public"."subcategory" USING "btree" ("category_id");



CREATE INDEX "idx_subcategory_jar" ON "public"."subcategory" USING "btree" ("jar_id");



CREATE INDEX "idx_transaction_account" ON "public"."transaction" USING "btree" ("account_id");



CREATE INDEX "idx_transaction_category_analysis" ON "public"."transaction" USING "btree" ("user_id", "category_id", "transaction_date");



CREATE INDEX "idx_transaction_date" ON "public"."transaction" USING "btree" ("transaction_date");



CREATE INDEX "idx_transaction_date_analysis" ON "public"."transaction" USING "btree" ("user_id", "transaction_date") INCLUDE ("amount");



CREATE INDEX "idx_transaction_jar" ON "public"."transaction" USING "btree" ("jar_id");



CREATE INDEX "idx_transaction_jar_analysis" ON "public"."transaction" USING "btree" ("user_id", "jar_id", "transaction_date");



CREATE INDEX "idx_transaction_notes_search" ON "public"."transaction" USING "gin" ("to_tsvector"('"spanish"'::"regconfig", COALESCE("notes", ''::"text")));



CREATE INDEX "idx_transaction_recurring" ON "public"."transaction" USING "btree" ("parent_recurring_id") WHERE ("parent_recurring_id" IS NOT NULL);



CREATE INDEX "idx_transaction_sync" ON "public"."transaction" USING "btree" ("sync_status");



CREATE INDEX "idx_transaction_tags" ON "public"."transaction" USING "gin" ("tags");



CREATE INDEX "idx_transaction_type" ON "public"."transaction" USING "btree" ("transaction_type_id");



CREATE INDEX "idx_transaction_type_active" ON "public"."transaction_type" USING "btree" ("id") WHERE ("is_active" = true);



CREATE INDEX "idx_transaction_type_name" ON "public"."transaction_type" USING "btree" ("name");



CREATE INDEX "idx_transaction_user" ON "public"."transaction" USING "btree" ("user_id");



CREATE INDEX "idx_transfer_accounts" ON "public"."transfer" USING "btree" ("from_account_id", "to_account_id") WHERE (("transfer_type")::"text" = 'ACCOUNT_TO_ACCOUNT'::"text");



CREATE INDEX "idx_transfer_date" ON "public"."transfer" USING "btree" ("transfer_date");



CREATE INDEX "idx_transfer_jars" ON "public"."transfer" USING "btree" ("from_jar_id", "to_jar_id") WHERE (("transfer_type")::"text" = ANY ((ARRAY['JAR_TO_JAR'::character varying, 'PERIOD_ROLLOVER'::character varying])::"text"[]));



CREATE INDEX "idx_transfer_sync" ON "public"."transfer" USING "btree" ("sync_status");



CREATE INDEX "idx_transfer_user" ON "public"."transfer" USING "btree" ("user_id");



CREATE OR REPLACE TRIGGER "after_transfer_notification" AFTER INSERT ON "public"."transfer" FOR EACH ROW EXECUTE FUNCTION "public"."notify_transfer"();



CREATE OR REPLACE TRIGGER "record_transaction_history" AFTER INSERT ON "public"."transaction" FOR EACH ROW EXECUTE FUNCTION "public"."record_balance_history"();



CREATE OR REPLACE TRIGGER "record_transfer_history" AFTER INSERT ON "public"."transfer" FOR EACH ROW EXECUTE FUNCTION "public"."record_balance_history"();



CREATE OR REPLACE TRIGGER "track_interest_rate_changes_trigger" AFTER UPDATE OF "current_interest_rate" ON "public"."credit_card_details" FOR EACH ROW EXECUTE FUNCTION "public"."track_interest_rate_changes"();



CREATE OR REPLACE TRIGGER "update_balances_on_transaction" AFTER INSERT ON "public"."transaction" FOR EACH ROW EXECUTE FUNCTION "public"."update_balances"();



CREATE OR REPLACE TRIGGER "update_balances_on_transfer" AFTER INSERT ON "public"."transfer" FOR EACH ROW EXECUTE FUNCTION "public"."update_balances"();



CREATE OR REPLACE TRIGGER "update_goals_after_transaction" AFTER INSERT OR UPDATE ON "public"."transaction" FOR EACH ROW EXECUTE FUNCTION "public"."update_goal_from_transaction"();



CREATE OR REPLACE TRIGGER "update_modified_timestamp" BEFORE UPDATE ON "public"."account" FOR EACH ROW EXECUTE FUNCTION "public"."update_modified_timestamp"();



CREATE OR REPLACE TRIGGER "update_modified_timestamp" BEFORE UPDATE ON "public"."account_type" FOR EACH ROW EXECUTE FUNCTION "public"."update_modified_timestamp"();



CREATE OR REPLACE TRIGGER "update_modified_timestamp" BEFORE UPDATE ON "public"."app_user" FOR EACH ROW EXECUTE FUNCTION "public"."update_modified_timestamp"();



CREATE OR REPLACE TRIGGER "update_modified_timestamp" BEFORE UPDATE ON "public"."category" FOR EACH ROW EXECUTE FUNCTION "public"."update_modified_timestamp"();



CREATE OR REPLACE TRIGGER "update_modified_timestamp" BEFORE UPDATE ON "public"."currency" FOR EACH ROW EXECUTE FUNCTION "public"."update_modified_timestamp"();



CREATE OR REPLACE TRIGGER "update_modified_timestamp" BEFORE UPDATE ON "public"."financial_goal" FOR EACH ROW EXECUTE FUNCTION "public"."update_modified_timestamp"();



CREATE OR REPLACE TRIGGER "update_modified_timestamp" BEFORE UPDATE ON "public"."jar" FOR EACH ROW EXECUTE FUNCTION "public"."update_modified_timestamp"();



CREATE OR REPLACE TRIGGER "update_modified_timestamp" BEFORE UPDATE ON "public"."jar_balance" FOR EACH ROW EXECUTE FUNCTION "public"."update_modified_timestamp"();



CREATE OR REPLACE TRIGGER "update_modified_timestamp" BEFORE UPDATE ON "public"."recurring_transaction" FOR EACH ROW EXECUTE FUNCTION "public"."update_modified_timestamp"();



CREATE OR REPLACE TRIGGER "update_modified_timestamp" BEFORE UPDATE ON "public"."subcategory" FOR EACH ROW EXECUTE FUNCTION "public"."update_modified_timestamp"();



CREATE OR REPLACE TRIGGER "update_modified_timestamp" BEFORE UPDATE ON "public"."transaction" FOR EACH ROW EXECUTE FUNCTION "public"."update_modified_timestamp"();



CREATE OR REPLACE TRIGGER "update_modified_timestamp" BEFORE UPDATE ON "public"."transaction_medium" FOR EACH ROW EXECUTE FUNCTION "public"."update_modified_timestamp"();



CREATE OR REPLACE TRIGGER "update_modified_timestamp" BEFORE UPDATE ON "public"."transaction_type" FOR EACH ROW EXECUTE FUNCTION "public"."update_modified_timestamp"();



CREATE OR REPLACE TRIGGER "update_modified_timestamp" BEFORE UPDATE ON "public"."transfer" FOR EACH ROW EXECUTE FUNCTION "public"."update_modified_timestamp"();



CREATE OR REPLACE TRIGGER "validate_credit_card_transaction_trigger" BEFORE INSERT ON "public"."transaction" FOR EACH ROW EXECUTE FUNCTION "public"."validate_credit_card_transaction"();



CREATE OR REPLACE TRIGGER "validate_jar_requirement" BEFORE INSERT OR UPDATE ON "public"."subcategory" FOR EACH ROW EXECUTE FUNCTION "public"."check_jar_requirement"();



CREATE OR REPLACE TRIGGER "validate_recurring_transaction_jar_requirement" BEFORE INSERT OR UPDATE ON "public"."recurring_transaction" FOR EACH ROW EXECUTE FUNCTION "public"."check_recurring_transaction_jar_requirement"();



CREATE OR REPLACE TRIGGER "validate_transaction_balance" BEFORE INSERT OR UPDATE ON "public"."transaction" FOR EACH ROW EXECUTE FUNCTION "public"."validate_sufficient_balance"();



CREATE OR REPLACE TRIGGER "validate_transaction_jar_requirement" BEFORE INSERT OR UPDATE ON "public"."transaction" FOR EACH ROW EXECUTE FUNCTION "public"."check_transaction_jar_requirement"();



CREATE OR REPLACE TRIGGER "validate_transfer_balance" BEFORE INSERT OR UPDATE ON "public"."transfer" FOR EACH ROW EXECUTE FUNCTION "public"."validate_sufficient_balance"();



ALTER TABLE ONLY "public"."account"
    ADD CONSTRAINT "account_account_type_id_fkey" FOREIGN KEY ("account_type_id") REFERENCES "public"."account_type"("id");



ALTER TABLE ONLY "public"."account"
    ADD CONSTRAINT "account_currency_id_fkey" FOREIGN KEY ("currency_id") REFERENCES "public"."currency"("id");



ALTER TABLE ONLY "public"."account"
    ADD CONSTRAINT "account_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."app_user"("id");



ALTER TABLE ONLY "public"."app_user"
    ADD CONSTRAINT "app_user_default_currency_id_fkey" FOREIGN KEY ("default_currency_id") REFERENCES "public"."currency"("id");



ALTER TABLE ONLY "public"."app_user"
    ADD CONSTRAINT "app_user_id_fkey" FOREIGN KEY ("id") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "public"."balance_history"
    ADD CONSTRAINT "balance_history_account_id_fkey" FOREIGN KEY ("account_id") REFERENCES "public"."account"("id");



ALTER TABLE ONLY "public"."balance_history"
    ADD CONSTRAINT "balance_history_jar_id_fkey" FOREIGN KEY ("jar_id") REFERENCES "public"."jar"("id");



ALTER TABLE ONLY "public"."balance_history"
    ADD CONSTRAINT "balance_history_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."app_user"("id");



ALTER TABLE ONLY "public"."category"
    ADD CONSTRAINT "category_transaction_type_id_fkey" FOREIGN KEY ("transaction_type_id") REFERENCES "public"."transaction_type"("id");



ALTER TABLE ONLY "public"."credit_card_details"
    ADD CONSTRAINT "credit_card_details_account_id_fkey" FOREIGN KEY ("account_id") REFERENCES "public"."account"("id");



ALTER TABLE ONLY "public"."credit_card_interest_history"
    ADD CONSTRAINT "credit_card_interest_history_credit_card_id_fkey" FOREIGN KEY ("credit_card_id") REFERENCES "public"."credit_card_details"("id");



ALTER TABLE ONLY "public"."credit_card_statement"
    ADD CONSTRAINT "credit_card_statement_credit_card_id_fkey" FOREIGN KEY ("credit_card_id") REFERENCES "public"."credit_card_details"("id");



ALTER TABLE ONLY "public"."financial_goal"
    ADD CONSTRAINT "financial_goal_jar_id_fkey" FOREIGN KEY ("jar_id") REFERENCES "public"."jar"("id");



ALTER TABLE ONLY "public"."financial_goal"
    ADD CONSTRAINT "financial_goal_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."app_user"("id");



ALTER TABLE ONLY "public"."installment_purchase"
    ADD CONSTRAINT "installment_purchase_credit_card_id_fkey" FOREIGN KEY ("credit_card_id") REFERENCES "public"."credit_card_details"("id");



ALTER TABLE ONLY "public"."installment_purchase"
    ADD CONSTRAINT "installment_purchase_transaction_id_fkey" FOREIGN KEY ("transaction_id") REFERENCES "public"."transaction"("id");



ALTER TABLE ONLY "public"."jar_balance"
    ADD CONSTRAINT "jar_balance_jar_id_fkey" FOREIGN KEY ("jar_id") REFERENCES "public"."jar"("id");



ALTER TABLE ONLY "public"."jar_balance"
    ADD CONSTRAINT "jar_balance_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."app_user"("id");



ALTER TABLE ONLY "public"."notification"
    ADD CONSTRAINT "notification_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."app_user"("id");



ALTER TABLE ONLY "public"."recurring_transaction"
    ADD CONSTRAINT "recurring_transaction_account_id_fkey" FOREIGN KEY ("account_id") REFERENCES "public"."account"("id");



ALTER TABLE ONLY "public"."recurring_transaction"
    ADD CONSTRAINT "recurring_transaction_category_id_fkey" FOREIGN KEY ("category_id") REFERENCES "public"."category"("id");



ALTER TABLE ONLY "public"."recurring_transaction"
    ADD CONSTRAINT "recurring_transaction_jar_id_fkey" FOREIGN KEY ("jar_id") REFERENCES "public"."jar"("id");



ALTER TABLE ONLY "public"."recurring_transaction"
    ADD CONSTRAINT "recurring_transaction_subcategory_id_fkey" FOREIGN KEY ("subcategory_id") REFERENCES "public"."subcategory"("id");



ALTER TABLE ONLY "public"."recurring_transaction"
    ADD CONSTRAINT "recurring_transaction_transaction_medium_id_fkey" FOREIGN KEY ("transaction_medium_id") REFERENCES "public"."transaction_medium"("id");



ALTER TABLE ONLY "public"."recurring_transaction"
    ADD CONSTRAINT "recurring_transaction_transaction_type_id_fkey" FOREIGN KEY ("transaction_type_id") REFERENCES "public"."transaction_type"("id");



ALTER TABLE ONLY "public"."recurring_transaction"
    ADD CONSTRAINT "recurring_transaction_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."app_user"("id");



ALTER TABLE ONLY "public"."subcategory"
    ADD CONSTRAINT "subcategory_category_id_fkey" FOREIGN KEY ("category_id") REFERENCES "public"."category"("id");



ALTER TABLE ONLY "public"."subcategory"
    ADD CONSTRAINT "subcategory_jar_id_fkey" FOREIGN KEY ("jar_id") REFERENCES "public"."jar"("id");



ALTER TABLE ONLY "public"."transaction"
    ADD CONSTRAINT "transaction_account_id_fkey" FOREIGN KEY ("account_id") REFERENCES "public"."account"("id");



ALTER TABLE ONLY "public"."transaction"
    ADD CONSTRAINT "transaction_category_id_fkey" FOREIGN KEY ("category_id") REFERENCES "public"."category"("id");



ALTER TABLE ONLY "public"."transaction"
    ADD CONSTRAINT "transaction_currency_id_fkey" FOREIGN KEY ("currency_id") REFERENCES "public"."currency"("id");



ALTER TABLE ONLY "public"."transaction"
    ADD CONSTRAINT "transaction_installment_purchase_id_fkey" FOREIGN KEY ("installment_purchase_id") REFERENCES "public"."installment_purchase"("id");



ALTER TABLE ONLY "public"."transaction"
    ADD CONSTRAINT "transaction_jar_id_fkey" FOREIGN KEY ("jar_id") REFERENCES "public"."jar"("id");



ALTER TABLE ONLY "public"."transaction"
    ADD CONSTRAINT "transaction_subcategory_id_fkey" FOREIGN KEY ("subcategory_id") REFERENCES "public"."subcategory"("id");



ALTER TABLE ONLY "public"."transaction"
    ADD CONSTRAINT "transaction_transaction_medium_id_fkey" FOREIGN KEY ("transaction_medium_id") REFERENCES "public"."transaction_medium"("id");



ALTER TABLE ONLY "public"."transaction"
    ADD CONSTRAINT "transaction_transaction_type_id_fkey" FOREIGN KEY ("transaction_type_id") REFERENCES "public"."transaction_type"("id");



ALTER TABLE ONLY "public"."transaction"
    ADD CONSTRAINT "transaction_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."app_user"("id");



ALTER TABLE ONLY "public"."transfer"
    ADD CONSTRAINT "transfer_from_account_id_fkey" FOREIGN KEY ("from_account_id") REFERENCES "public"."account"("id");



ALTER TABLE ONLY "public"."transfer"
    ADD CONSTRAINT "transfer_from_jar_id_fkey" FOREIGN KEY ("from_jar_id") REFERENCES "public"."jar"("id");



ALTER TABLE ONLY "public"."transfer"
    ADD CONSTRAINT "transfer_to_account_id_fkey" FOREIGN KEY ("to_account_id") REFERENCES "public"."account"("id");



ALTER TABLE ONLY "public"."transfer"
    ADD CONSTRAINT "transfer_to_jar_id_fkey" FOREIGN KEY ("to_jar_id") REFERENCES "public"."jar"("id");



ALTER TABLE ONLY "public"."transfer"
    ADD CONSTRAINT "transfer_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."app_user"("id");



CREATE POLICY "Usuarios autenticados pueden leer" ON "public"."account_type" FOR SELECT USING (("auth"."role"() = 'authenticated'::"text"));



CREATE POLICY "Usuarios autenticados pueden leer" ON "public"."category" FOR SELECT USING (("auth"."role"() = 'authenticated'::"text"));



CREATE POLICY "Usuarios autenticados pueden leer" ON "public"."currency" FOR SELECT USING (("auth"."role"() = 'authenticated'::"text"));



CREATE POLICY "Usuarios autenticados pueden leer" ON "public"."jar" FOR SELECT USING (("auth"."role"() = 'authenticated'::"text"));



CREATE POLICY "Usuarios autenticados pueden leer" ON "public"."subcategory" FOR SELECT USING (("auth"."role"() = 'authenticated'::"text"));



CREATE POLICY "Usuarios autenticados pueden leer" ON "public"."transaction_medium" FOR SELECT USING (("auth"."role"() = 'authenticated'::"text"));



CREATE POLICY "Usuarios autenticados pueden leer" ON "public"."transaction_type" FOR SELECT USING (("auth"."role"() = 'authenticated'::"text"));



CREATE POLICY "Usuarios pueden actualizar categorías" ON "public"."category" FOR UPDATE USING (("auth"."role"() = 'authenticated'::"text"));



CREATE POLICY "Usuarios pueden actualizar su perfil" ON "public"."app_user" FOR UPDATE USING (("auth"."uid"() = "id"));



CREATE POLICY "Usuarios pueden actualizar subcategorías" ON "public"."subcategory" FOR UPDATE USING (("auth"."role"() = 'authenticated'::"text"));



CREATE POLICY "Usuarios pueden actualizar sus balances" ON "public"."jar_balance" FOR UPDATE USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Usuarios pueden actualizar sus cuentas" ON "public"."account" FOR UPDATE USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Usuarios pueden actualizar sus metas" ON "public"."financial_goal" FOR UPDATE USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Usuarios pueden actualizar sus notificaciones" ON "public"."notification" FOR UPDATE USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Usuarios pueden actualizar sus tarjetas" ON "public"."credit_card_details" FOR UPDATE USING (("auth"."uid"() = ( SELECT "account"."user_id"
   FROM "public"."account"
  WHERE ("account"."id" = "credit_card_details"."account_id"))));



CREATE POLICY "Usuarios pueden actualizar sus transacciones" ON "public"."transaction" FOR UPDATE USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Usuarios pueden actualizar sus transacciones recurrentes" ON "public"."recurring_transaction" FOR UPDATE USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Usuarios pueden actualizar sus transferencias" ON "public"."transfer" FOR UPDATE USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Usuarios pueden crear balances" ON "public"."jar_balance" FOR INSERT WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Usuarios pueden crear categorías" ON "public"."category" FOR INSERT WITH CHECK (("auth"."role"() = 'authenticated'::"text"));



CREATE POLICY "Usuarios pueden crear cuentas" ON "public"."account" FOR INSERT WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Usuarios pueden crear metas" ON "public"."financial_goal" FOR INSERT WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Usuarios pueden crear registros históricos" ON "public"."balance_history" FOR INSERT WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Usuarios pueden crear subcategorías" ON "public"."subcategory" FOR INSERT WITH CHECK (("auth"."role"() = 'authenticated'::"text"));



CREATE POLICY "Usuarios pueden crear transacciones" ON "public"."transaction" FOR INSERT WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Usuarios pueden crear transacciones recurrentes" ON "public"."recurring_transaction" FOR INSERT WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Usuarios pueden crear transferencias" ON "public"."transfer" FOR INSERT WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Usuarios pueden eliminar categorías" ON "public"."category" FOR DELETE USING (("auth"."role"() = 'authenticated'::"text"));



CREATE POLICY "Usuarios pueden eliminar subcategorías" ON "public"."subcategory" FOR DELETE USING (("auth"."role"() = 'authenticated'::"text"));



CREATE POLICY "Usuarios pueden ver estados de cuenta" ON "public"."credit_card_statement" FOR SELECT USING (("auth"."uid"() = ( SELECT "a"."user_id"
   FROM ("public"."account" "a"
     JOIN "public"."credit_card_details" "cc" ON (("cc"."account_id" = "a"."id")))
  WHERE ("cc"."id" = "credit_card_statement"."credit_card_id"))));



CREATE POLICY "Usuarios pueden ver historial de sus tarjetas" ON "public"."credit_card_interest_history" FOR SELECT USING (("auth"."uid"() = ( SELECT "a"."user_id"
   FROM ("public"."account" "a"
     JOIN "public"."credit_card_details" "cc" ON (("cc"."account_id" = "a"."id")))
  WHERE ("cc"."id" = "credit_card_interest_history"."credit_card_id"))));



CREATE POLICY "Usuarios pueden ver su historial" ON "public"."balance_history" FOR SELECT USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Usuarios pueden ver su perfil" ON "public"."app_user" FOR SELECT USING (("auth"."uid"() = "id"));



CREATE POLICY "Usuarios pueden ver sus MSI" ON "public"."installment_purchase" FOR SELECT USING (("auth"."uid"() = ( SELECT "a"."user_id"
   FROM ("public"."account" "a"
     JOIN "public"."credit_card_details" "cc" ON (("cc"."account_id" = "a"."id")))
  WHERE ("cc"."id" = "installment_purchase"."credit_card_id"))));



CREATE POLICY "Usuarios pueden ver sus balances" ON "public"."jar_balance" FOR SELECT USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Usuarios pueden ver sus cuentas" ON "public"."account" FOR SELECT USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Usuarios pueden ver sus metas" ON "public"."financial_goal" FOR SELECT USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Usuarios pueden ver sus notificaciones" ON "public"."notification" FOR SELECT USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Usuarios pueden ver sus tarjetas" ON "public"."credit_card_details" FOR SELECT USING (("auth"."uid"() = ( SELECT "account"."user_id"
   FROM "public"."account"
  WHERE ("account"."id" = "credit_card_details"."account_id"))));



CREATE POLICY "Usuarios pueden ver sus transacciones" ON "public"."transaction" FOR SELECT USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Usuarios pueden ver sus transacciones recurrentes" ON "public"."recurring_transaction" FOR SELECT USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Usuarios pueden ver sus transferencias" ON "public"."transfer" FOR SELECT USING (("auth"."uid"() = "user_id"));



ALTER TABLE "public"."account" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."account_type" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."app_user" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."balance_history" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."category" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."credit_card_details" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."credit_card_interest_history" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."credit_card_statement" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."currency" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."financial_goal" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."installment_purchase" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."jar" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."jar_balance" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."notification" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."recurring_transaction" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."subcategory" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."transaction" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."transaction_medium" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."transaction_type" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."transfer" ENABLE ROW LEVEL SECURITY;




ALTER PUBLICATION "supabase_realtime" OWNER TO "postgres";





GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";









































































































































































































GRANT ALL ON FUNCTION "public"."analyze_financial_goal"("p_goal_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."analyze_financial_goal"("p_goal_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."analyze_financial_goal"("p_goal_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."analyze_jar_distribution"("p_user_id" "uuid", "p_start_date" "date", "p_end_date" "date") TO "anon";
GRANT ALL ON FUNCTION "public"."analyze_jar_distribution"("p_user_id" "uuid", "p_start_date" "date", "p_end_date" "date") TO "authenticated";
GRANT ALL ON FUNCTION "public"."analyze_jar_distribution"("p_user_id" "uuid", "p_start_date" "date", "p_end_date" "date") TO "service_role";



GRANT ALL ON FUNCTION "public"."analyze_transactions_by_category"("p_user_id" "uuid", "p_start_date" "date", "p_end_date" "date", "p_transaction_type" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."analyze_transactions_by_category"("p_user_id" "uuid", "p_start_date" "date", "p_end_date" "date", "p_transaction_type" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."analyze_transactions_by_category"("p_user_id" "uuid", "p_start_date" "date", "p_end_date" "date", "p_transaction_type" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."archive_completed_goals"("p_days_threshold" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."archive_completed_goals"("p_days_threshold" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."archive_completed_goals"("p_days_threshold" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."calculate_goal_progress"("p_current_amount" numeric, "p_target_amount" numeric, "p_start_date" "date", "p_target_date" "date") TO "anon";
GRANT ALL ON FUNCTION "public"."calculate_goal_progress"("p_current_amount" numeric, "p_target_amount" numeric, "p_start_date" "date", "p_target_date" "date") TO "authenticated";
GRANT ALL ON FUNCTION "public"."calculate_goal_progress"("p_current_amount" numeric, "p_target_amount" numeric, "p_start_date" "date", "p_target_date" "date") TO "service_role";



GRANT ALL ON FUNCTION "public"."calculate_next_cut_off_date"("p_cut_off_day" integer, "p_from_date" "date") TO "anon";
GRANT ALL ON FUNCTION "public"."calculate_next_cut_off_date"("p_cut_off_day" integer, "p_from_date" "date") TO "authenticated";
GRANT ALL ON FUNCTION "public"."calculate_next_cut_off_date"("p_cut_off_day" integer, "p_from_date" "date") TO "service_role";



GRANT ALL ON FUNCTION "public"."calculate_next_execution_date"("p_frequency" character varying, "p_start_date" "date", "p_last_execution" "date") TO "anon";
GRANT ALL ON FUNCTION "public"."calculate_next_execution_date"("p_frequency" character varying, "p_start_date" "date", "p_last_execution" "date") TO "authenticated";
GRANT ALL ON FUNCTION "public"."calculate_next_execution_date"("p_frequency" character varying, "p_start_date" "date", "p_last_execution" "date") TO "service_role";



GRANT ALL ON FUNCTION "public"."calculate_next_payment_date"("p_payment_day" integer, "p_cut_off_date" "date") TO "anon";
GRANT ALL ON FUNCTION "public"."calculate_next_payment_date"("p_payment_day" integer, "p_cut_off_date" "date") TO "authenticated";
GRANT ALL ON FUNCTION "public"."calculate_next_payment_date"("p_payment_day" integer, "p_cut_off_date" "date") TO "service_role";



GRANT ALL ON FUNCTION "public"."check_available_balance_for_transfer"("p_user_id" "uuid", "p_account_id" "uuid", "p_jar_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."check_available_balance_for_transfer"("p_user_id" "uuid", "p_account_id" "uuid", "p_jar_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."check_available_balance_for_transfer"("p_user_id" "uuid", "p_account_id" "uuid", "p_jar_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."check_jar_requirement"() TO "anon";
GRANT ALL ON FUNCTION "public"."check_jar_requirement"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."check_jar_requirement"() TO "service_role";



GRANT ALL ON FUNCTION "public"."check_recurring_transaction_jar_requirement"() TO "anon";
GRANT ALL ON FUNCTION "public"."check_recurring_transaction_jar_requirement"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."check_recurring_transaction_jar_requirement"() TO "service_role";



GRANT ALL ON FUNCTION "public"."check_transaction_jar_requirement"() TO "anon";
GRANT ALL ON FUNCTION "public"."check_transaction_jar_requirement"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."check_transaction_jar_requirement"() TO "service_role";



GRANT ALL ON FUNCTION "public"."execute_account_transfer"("p_user_id" "uuid", "p_from_account_id" "uuid", "p_to_account_id" "uuid", "p_amount" numeric, "p_exchange_rate" numeric, "p_description" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."execute_account_transfer"("p_user_id" "uuid", "p_from_account_id" "uuid", "p_to_account_id" "uuid", "p_amount" numeric, "p_exchange_rate" numeric, "p_description" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."execute_account_transfer"("p_user_id" "uuid", "p_from_account_id" "uuid", "p_to_account_id" "uuid", "p_amount" numeric, "p_exchange_rate" numeric, "p_description" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."execute_jar_transfer"("p_user_id" "uuid", "p_from_jar_id" "uuid", "p_to_jar_id" "uuid", "p_amount" numeric, "p_description" "text", "p_is_rollover" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."execute_jar_transfer"("p_user_id" "uuid", "p_from_jar_id" "uuid", "p_to_jar_id" "uuid", "p_amount" numeric, "p_description" "text", "p_is_rollover" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."execute_jar_transfer"("p_user_id" "uuid", "p_from_jar_id" "uuid", "p_to_jar_id" "uuid", "p_amount" numeric, "p_description" "text", "p_is_rollover" boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."export_jar_status_to_excel"("p_user_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."export_jar_status_to_excel"("p_user_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."export_jar_status_to_excel"("p_user_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."export_transactions_to_excel"("p_user_id" "uuid", "p_start_date" "date", "p_end_date" "date") TO "anon";
GRANT ALL ON FUNCTION "public"."export_transactions_to_excel"("p_user_id" "uuid", "p_start_date" "date", "p_end_date" "date") TO "authenticated";
GRANT ALL ON FUNCTION "public"."export_transactions_to_excel"("p_user_id" "uuid", "p_start_date" "date", "p_end_date" "date") TO "service_role";



GRANT ALL ON FUNCTION "public"."generate_credit_card_statement"("p_credit_card_id" "uuid", "p_statement_date" "date") TO "anon";
GRANT ALL ON FUNCTION "public"."generate_credit_card_statement"("p_credit_card_id" "uuid", "p_statement_date" "date") TO "authenticated";
GRANT ALL ON FUNCTION "public"."generate_credit_card_statement"("p_credit_card_id" "uuid", "p_statement_date" "date") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_credit_card_statements"("p_account_id" "uuid", "p_months" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."get_credit_card_statements"("p_account_id" "uuid", "p_months" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_credit_card_statements"("p_account_id" "uuid", "p_months" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."get_credit_card_summary"("p_account_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_credit_card_summary"("p_account_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_credit_card_summary"("p_account_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_goals_summary"("p_user_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_goals_summary"("p_user_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_goals_summary"("p_user_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_period_summary"("p_user_id" "uuid", "p_start_date" "date", "p_end_date" "date") TO "anon";
GRANT ALL ON FUNCTION "public"."get_period_summary"("p_user_id" "uuid", "p_start_date" "date", "p_end_date" "date") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_period_summary"("p_user_id" "uuid", "p_start_date" "date", "p_end_date" "date") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_transfer_history"("p_user_id" "uuid", "p_start_date" "date", "p_end_date" "date", "p_transfer_type" "text", "p_limit" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."get_transfer_history"("p_user_id" "uuid", "p_start_date" "date", "p_end_date" "date", "p_transfer_type" "text", "p_limit" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_transfer_history"("p_user_id" "uuid", "p_start_date" "date", "p_end_date" "date", "p_transfer_type" "text", "p_limit" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."get_transfer_summary_by_period"("p_user_id" "uuid", "p_start_date" "date", "p_end_date" "date") TO "anon";
GRANT ALL ON FUNCTION "public"."get_transfer_summary_by_period"("p_user_id" "uuid", "p_start_date" "date", "p_end_date" "date") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_transfer_summary_by_period"("p_user_id" "uuid", "p_start_date" "date", "p_end_date" "date") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_upcoming_recurring_transactions"("p_user_id" "uuid", "p_days" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."get_upcoming_recurring_transactions"("p_user_id" "uuid", "p_days" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_upcoming_recurring_transactions"("p_user_id" "uuid", "p_days" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "service_role";



GRANT ALL ON FUNCTION "public"."initialize_system_data"() TO "anon";
GRANT ALL ON FUNCTION "public"."initialize_system_data"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."initialize_system_data"() TO "service_role";



GRANT ALL ON FUNCTION "public"."notify_credit_card_events"() TO "anon";
GRANT ALL ON FUNCTION "public"."notify_credit_card_events"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."notify_credit_card_events"() TO "service_role";



GRANT ALL ON FUNCTION "public"."notify_transfer"() TO "anon";
GRANT ALL ON FUNCTION "public"."notify_transfer"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."notify_transfer"() TO "service_role";



GRANT ALL ON FUNCTION "public"."process_jar_rollover"("p_user_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."process_jar_rollover"("p_user_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."process_jar_rollover"("p_user_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."process_recurring_transactions"("p_date" "date") TO "anon";
GRANT ALL ON FUNCTION "public"."process_recurring_transactions"("p_date" "date") TO "authenticated";
GRANT ALL ON FUNCTION "public"."process_recurring_transactions"("p_date" "date") TO "service_role";



GRANT ALL ON FUNCTION "public"."reactivate_recurring_transaction"("p_transaction_id" "uuid", "p_new_start_date" "date") TO "anon";
GRANT ALL ON FUNCTION "public"."reactivate_recurring_transaction"("p_transaction_id" "uuid", "p_new_start_date" "date") TO "authenticated";
GRANT ALL ON FUNCTION "public"."reactivate_recurring_transaction"("p_transaction_id" "uuid", "p_new_start_date" "date") TO "service_role";



GRANT ALL ON FUNCTION "public"."record_balance_history"() TO "anon";
GRANT ALL ON FUNCTION "public"."record_balance_history"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."record_balance_history"() TO "service_role";



GRANT ALL ON FUNCTION "public"."remove_transaction_tag"("p_transaction_id" "uuid", "p_tag" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."remove_transaction_tag"("p_transaction_id" "uuid", "p_tag" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."remove_transaction_tag"("p_transaction_id" "uuid", "p_tag" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."search_transactions_by_notes"("p_user_id" "uuid", "p_search_text" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."search_transactions_by_notes"("p_user_id" "uuid", "p_search_text" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."search_transactions_by_notes"("p_user_id" "uuid", "p_search_text" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."search_transactions_by_tags"("p_user_id" "uuid", "p_tags" "text"[]) TO "anon";
GRANT ALL ON FUNCTION "public"."search_transactions_by_tags"("p_user_id" "uuid", "p_tags" "text"[]) TO "authenticated";
GRANT ALL ON FUNCTION "public"."search_transactions_by_tags"("p_user_id" "uuid", "p_tags" "text"[]) TO "service_role";



GRANT ALL ON FUNCTION "public"."track_interest_rate_changes"() TO "anon";
GRANT ALL ON FUNCTION "public"."track_interest_rate_changes"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."track_interest_rate_changes"() TO "service_role";



GRANT ALL ON FUNCTION "public"."update_balances"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_balances"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_balances"() TO "service_role";



GRANT ALL ON FUNCTION "public"."update_goal_from_transaction"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_goal_from_transaction"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_goal_from_transaction"() TO "service_role";



GRANT ALL ON FUNCTION "public"."update_goal_progress"("p_goal_id" "uuid", "p_new_amount" numeric) TO "anon";
GRANT ALL ON FUNCTION "public"."update_goal_progress"("p_goal_id" "uuid", "p_new_amount" numeric) TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_goal_progress"("p_goal_id" "uuid", "p_new_amount" numeric) TO "service_role";



GRANT ALL ON FUNCTION "public"."update_installment_purchases"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_installment_purchases"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_installment_purchases"() TO "service_role";



GRANT ALL ON FUNCTION "public"."update_modified_timestamp"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_modified_timestamp"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_modified_timestamp"() TO "service_role";



GRANT ALL ON FUNCTION "public"."validate_account_transfer"("p_user_id" "uuid", "p_from_account_id" "uuid", "p_to_account_id" "uuid", "p_amount" numeric, "p_exchange_rate" numeric) TO "anon";
GRANT ALL ON FUNCTION "public"."validate_account_transfer"("p_user_id" "uuid", "p_from_account_id" "uuid", "p_to_account_id" "uuid", "p_amount" numeric, "p_exchange_rate" numeric) TO "authenticated";
GRANT ALL ON FUNCTION "public"."validate_account_transfer"("p_user_id" "uuid", "p_from_account_id" "uuid", "p_to_account_id" "uuid", "p_amount" numeric, "p_exchange_rate" numeric) TO "service_role";



GRANT ALL ON FUNCTION "public"."validate_credit_card_transaction"() TO "anon";
GRANT ALL ON FUNCTION "public"."validate_credit_card_transaction"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."validate_credit_card_transaction"() TO "service_role";



GRANT ALL ON FUNCTION "public"."validate_credit_limit"("p_account_id" "uuid", "p_amount" numeric) TO "anon";
GRANT ALL ON FUNCTION "public"."validate_credit_limit"("p_account_id" "uuid", "p_amount" numeric) TO "authenticated";
GRANT ALL ON FUNCTION "public"."validate_credit_limit"("p_account_id" "uuid", "p_amount" numeric) TO "service_role";



GRANT ALL ON FUNCTION "public"."validate_jar_transfer"("p_user_id" "uuid", "p_from_jar_id" "uuid", "p_to_jar_id" "uuid", "p_amount" numeric) TO "anon";
GRANT ALL ON FUNCTION "public"."validate_jar_transfer"("p_user_id" "uuid", "p_from_jar_id" "uuid", "p_to_jar_id" "uuid", "p_amount" numeric) TO "authenticated";
GRANT ALL ON FUNCTION "public"."validate_jar_transfer"("p_user_id" "uuid", "p_from_jar_id" "uuid", "p_to_jar_id" "uuid", "p_amount" numeric) TO "service_role";



GRANT ALL ON FUNCTION "public"."validate_recurring_transaction"("p_user_id" "uuid", "p_amount" numeric, "p_transaction_type_id" "uuid", "p_account_id" "uuid", "p_jar_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."validate_recurring_transaction"("p_user_id" "uuid", "p_amount" numeric, "p_transaction_type_id" "uuid", "p_account_id" "uuid", "p_jar_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."validate_recurring_transaction"("p_user_id" "uuid", "p_amount" numeric, "p_transaction_type_id" "uuid", "p_account_id" "uuid", "p_jar_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."validate_sufficient_balance"() TO "anon";
GRANT ALL ON FUNCTION "public"."validate_sufficient_balance"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."validate_sufficient_balance"() TO "service_role";
























GRANT ALL ON TABLE "public"."account" TO "anon";
GRANT ALL ON TABLE "public"."account" TO "authenticated";
GRANT ALL ON TABLE "public"."account" TO "service_role";



GRANT ALL ON TABLE "public"."account_type" TO "anon";
GRANT ALL ON TABLE "public"."account_type" TO "authenticated";
GRANT ALL ON TABLE "public"."account_type" TO "service_role";



GRANT ALL ON TABLE "public"."app_user" TO "anon";
GRANT ALL ON TABLE "public"."app_user" TO "authenticated";
GRANT ALL ON TABLE "public"."app_user" TO "service_role";



GRANT ALL ON TABLE "public"."balance_history" TO "anon";
GRANT ALL ON TABLE "public"."balance_history" TO "authenticated";
GRANT ALL ON TABLE "public"."balance_history" TO "service_role";



GRANT ALL ON TABLE "public"."category" TO "anon";
GRANT ALL ON TABLE "public"."category" TO "authenticated";
GRANT ALL ON TABLE "public"."category" TO "service_role";



GRANT ALL ON TABLE "public"."credit_card_details" TO "anon";
GRANT ALL ON TABLE "public"."credit_card_details" TO "authenticated";
GRANT ALL ON TABLE "public"."credit_card_details" TO "service_role";



GRANT ALL ON TABLE "public"."credit_card_interest_history" TO "anon";
GRANT ALL ON TABLE "public"."credit_card_interest_history" TO "authenticated";
GRANT ALL ON TABLE "public"."credit_card_interest_history" TO "service_role";



GRANT ALL ON TABLE "public"."credit_card_statement" TO "anon";
GRANT ALL ON TABLE "public"."credit_card_statement" TO "authenticated";
GRANT ALL ON TABLE "public"."credit_card_statement" TO "service_role";



GRANT ALL ON TABLE "public"."currency" TO "anon";
GRANT ALL ON TABLE "public"."currency" TO "authenticated";
GRANT ALL ON TABLE "public"."currency" TO "service_role";



GRANT ALL ON TABLE "public"."transaction" TO "anon";
GRANT ALL ON TABLE "public"."transaction" TO "authenticated";
GRANT ALL ON TABLE "public"."transaction" TO "service_role";



GRANT ALL ON TABLE "public"."transaction_type" TO "anon";
GRANT ALL ON TABLE "public"."transaction_type" TO "authenticated";
GRANT ALL ON TABLE "public"."transaction_type" TO "service_role";



GRANT ALL ON TABLE "public"."expense_trends_analysis" TO "anon";
GRANT ALL ON TABLE "public"."expense_trends_analysis" TO "authenticated";
GRANT ALL ON TABLE "public"."expense_trends_analysis" TO "service_role";



GRANT ALL ON TABLE "public"."financial_goal" TO "anon";
GRANT ALL ON TABLE "public"."financial_goal" TO "authenticated";
GRANT ALL ON TABLE "public"."financial_goal" TO "service_role";



GRANT ALL ON TABLE "public"."jar" TO "anon";
GRANT ALL ON TABLE "public"."jar" TO "authenticated";
GRANT ALL ON TABLE "public"."jar" TO "service_role";



GRANT ALL ON TABLE "public"."goal_progress_summary" TO "anon";
GRANT ALL ON TABLE "public"."goal_progress_summary" TO "authenticated";
GRANT ALL ON TABLE "public"."goal_progress_summary" TO "service_role";



GRANT ALL ON TABLE "public"."installment_purchase" TO "anon";
GRANT ALL ON TABLE "public"."installment_purchase" TO "authenticated";
GRANT ALL ON TABLE "public"."installment_purchase" TO "service_role";



GRANT ALL ON TABLE "public"."jar_balance" TO "anon";
GRANT ALL ON TABLE "public"."jar_balance" TO "authenticated";
GRANT ALL ON TABLE "public"."jar_balance" TO "service_role";



GRANT ALL ON TABLE "public"."methodology_compliance_analysis" TO "anon";
GRANT ALL ON TABLE "public"."methodology_compliance_analysis" TO "authenticated";
GRANT ALL ON TABLE "public"."methodology_compliance_analysis" TO "service_role";



GRANT ALL ON TABLE "public"."notification" TO "anon";
GRANT ALL ON TABLE "public"."notification" TO "authenticated";
GRANT ALL ON TABLE "public"."notification" TO "service_role";



GRANT ALL ON TABLE "public"."recurring_transaction" TO "anon";
GRANT ALL ON TABLE "public"."recurring_transaction" TO "authenticated";
GRANT ALL ON TABLE "public"."recurring_transaction" TO "service_role";



GRANT ALL ON TABLE "public"."schema_migrations" TO "anon";
GRANT ALL ON TABLE "public"."schema_migrations" TO "authenticated";
GRANT ALL ON TABLE "public"."schema_migrations" TO "service_role";



GRANT ALL ON TABLE "public"."subcategory" TO "anon";
GRANT ALL ON TABLE "public"."subcategory" TO "authenticated";
GRANT ALL ON TABLE "public"."subcategory" TO "service_role";



GRANT ALL ON TABLE "public"."transaction_medium" TO "anon";
GRANT ALL ON TABLE "public"."transaction_medium" TO "authenticated";
GRANT ALL ON TABLE "public"."transaction_medium" TO "service_role";



GRANT ALL ON TABLE "public"."transfer" TO "anon";
GRANT ALL ON TABLE "public"."transfer" TO "authenticated";
GRANT ALL ON TABLE "public"."transfer" TO "service_role";



GRANT ALL ON TABLE "public"."transfer_summary" TO "anon";
GRANT ALL ON TABLE "public"."transfer_summary" TO "authenticated";
GRANT ALL ON TABLE "public"."transfer_summary" TO "service_role";



GRANT ALL ON TABLE "public"."transfer_analysis" TO "anon";
GRANT ALL ON TABLE "public"."transfer_analysis" TO "authenticated";
GRANT ALL ON TABLE "public"."transfer_analysis" TO "service_role";



ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "service_role";






























RESET ALL;
