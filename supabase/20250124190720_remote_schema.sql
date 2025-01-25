alter table "public"."balance_history" drop constraint "balance_history_change_type_check";

alter table "public"."credit_card_statement" drop constraint "credit_card_statement_status_check";

alter table "public"."financial_goal" drop constraint "financial_goal_status_check";

alter table "public"."installment_purchase" drop constraint "installment_purchase_status_check";

alter table "public"."notification" drop constraint "notification_notification_type_check";

alter table "public"."notification" drop constraint "notification_urgency_level_check";

alter table "public"."recurring_transaction" drop constraint "recurring_transaction_frequency_check";

alter table "public"."transaction" drop constraint "transaction_sync_status_check";

alter table "public"."transfer" drop constraint "transfer_sync_status_check";

alter table "public"."transfer" drop constraint "transfer_transfer_type_check";

drop index if exists "public"."idx_transfer_jars";

CREATE INDEX idx_transfer_jars ON public.transfer USING btree (from_jar_id, to_jar_id) WHERE ((transfer_type)::text = ANY ((ARRAY['JAR_TO_JAR'::character varying, 'PERIOD_ROLLOVER'::character varying])::text[]));

alter table "public"."balance_history" add constraint "balance_history_change_type_check" CHECK (((change_type)::text = ANY ((ARRAY['TRANSACTION'::character varying, 'TRANSFER'::character varying, 'ADJUSTMENT'::character varying, 'ROLLOVER'::character varying])::text[]))) not valid;

alter table "public"."balance_history" validate constraint "balance_history_change_type_check";

alter table "public"."credit_card_statement" add constraint "credit_card_statement_status_check" CHECK (((status)::text = ANY ((ARRAY['PENDING'::character varying, 'PAID_MINIMUM'::character varying, 'PAID_FULL'::character varying])::text[]))) not valid;

alter table "public"."credit_card_statement" validate constraint "credit_card_statement_status_check";

alter table "public"."financial_goal" add constraint "financial_goal_status_check" CHECK (((status)::text = ANY ((ARRAY['IN_PROGRESS'::character varying, 'COMPLETED'::character varying, 'CANCELLED'::character varying])::text[]))) not valid;

alter table "public"."financial_goal" validate constraint "financial_goal_status_check";

alter table "public"."installment_purchase" add constraint "installment_purchase_status_check" CHECK (((status)::text = ANY ((ARRAY['ACTIVE'::character varying, 'COMPLETED'::character varying, 'CANCELLED'::character varying])::text[]))) not valid;

alter table "public"."installment_purchase" validate constraint "installment_purchase_status_check";

alter table "public"."notification" add constraint "notification_notification_type_check" CHECK (((notification_type)::text = ANY ((ARRAY['RECURRING_TRANSACTION'::character varying, 'INSUFFICIENT_FUNDS'::character varying, 'GOAL_PROGRESS'::character varying, 'SYNC_ERROR'::character varying, 'SYSTEM'::character varying, 'CREDIT_CARD_DUE_DATE'::character varying, 'CREDIT_CARD_CUT_OFF'::character varying, 'CREDIT_CARD_LIMIT'::character varying, 'CREDIT_CARD_MINIMUM_PAYMENT'::character varying])::text[]))) not valid;

alter table "public"."notification" validate constraint "notification_notification_type_check";

alter table "public"."notification" add constraint "notification_urgency_level_check" CHECK (((urgency_level)::text = ANY ((ARRAY['LOW'::character varying, 'MEDIUM'::character varying, 'HIGH'::character varying])::text[]))) not valid;

alter table "public"."notification" validate constraint "notification_urgency_level_check";

alter table "public"."recurring_transaction" add constraint "recurring_transaction_frequency_check" CHECK (((frequency)::text = ANY ((ARRAY['WEEKLY'::character varying, 'MONTHLY'::character varying, 'YEARLY'::character varying])::text[]))) not valid;

alter table "public"."recurring_transaction" validate constraint "recurring_transaction_frequency_check";

alter table "public"."transaction" add constraint "transaction_sync_status_check" CHECK (((sync_status)::text = ANY ((ARRAY['PENDING'::character varying, 'SYNCED'::character varying, 'ERROR'::character varying])::text[]))) not valid;

alter table "public"."transaction" validate constraint "transaction_sync_status_check";

alter table "public"."transfer" add constraint "transfer_sync_status_check" CHECK (((sync_status)::text = ANY ((ARRAY['PENDING'::character varying, 'SYNCED'::character varying, 'ERROR'::character varying])::text[]))) not valid;

alter table "public"."transfer" validate constraint "transfer_sync_status_check";

alter table "public"."transfer" add constraint "transfer_transfer_type_check" CHECK (((transfer_type)::text = ANY ((ARRAY['ACCOUNT_TO_ACCOUNT'::character varying, 'JAR_TO_JAR'::character varying, 'PERIOD_ROLLOVER'::character varying])::text[]))) not valid;

alter table "public"."transfer" validate constraint "transfer_transfer_type_check";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.check_transfer_balance(p_transfer_id uuid, p_amount numeric)
 RETURNS transfer_validation_result
 LANGUAGE plpgsql
AS $function$
DECLARE
    v_result transfer_validation_result;
    v_transfer transfer;
    v_source_balance numeric;
    v_target_balance numeric;
BEGIN
    SELECT * INTO v_transfer FROM public.transfer WHERE id = p_transfer_id;
    
    IF v_transfer.transfer_type = 'ACCOUNT_TO_ACCOUNT' THEN
        -- Check account balances
        SELECT current_balance INTO v_source_balance 
        FROM public.account 
        WHERE id = v_transfer.from_account_id;
        
        SELECT current_balance INTO v_target_balance 
        FROM public.account 
        WHERE id = v_transfer.to_account_id;
        
    ELSIF v_transfer.transfer_type = 'JAR_TO_JAR' THEN
        -- Check jar balances
        SELECT current_balance INTO v_source_balance 
        FROM public.jar 
        WHERE id = v_transfer.from_jar_id;
        
        SELECT current_balance INTO v_target_balance 
        FROM public.jar 
        WHERE id = v_transfer.to_jar_id;
    END IF;
    
    v_result.is_valid := v_source_balance >= p_amount;
    v_result.error_message := CASE 
        WHEN NOT v_result.is_valid THEN 'Insufficient balance'
        ELSE NULL
    END;
    v_result.source_balance := v_source_balance;
    v_result.target_balance := v_target_balance;
    
    RETURN v_result;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.get_daily_transaction_totals(p_user_id uuid, p_start_date timestamp with time zone, p_end_date timestamp with time zone, p_transaction_type_id uuid DEFAULT NULL::uuid)
 RETURNS TABLE(transaction_date date, total_amount numeric, transaction_count bigint)
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    v_start_date DATE := p_start_date::DATE;
    v_end_date DATE := p_end_date::DATE;
BEGIN
    RETURN QUERY
    SELECT 
        t.transaction_date::DATE as transaction_date,
        SUM(t.amount * t.exchange_rate) as total_amount,
        COUNT(*) as transaction_count
    FROM "transaction" t
    WHERE t.user_id = p_user_id
    AND t.transaction_date::DATE >= v_start_date
    AND t.transaction_date::DATE <= v_end_date
    AND (p_transaction_type_id IS NULL OR t.transaction_type_id = p_transaction_type_id)
    GROUP BY t.transaction_date::DATE
    ORDER BY t.transaction_date::DATE;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.get_transaction_summary_by_date_range(p_user_id uuid, p_start_date timestamp with time zone, p_end_date timestamp with time zone)
 RETURNS TABLE(transaction_type text, total_amount numeric, currency_id uuid, transaction_count bigint)
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
    RETURN QUERY
    SELECT 
        tt.name as transaction_type,
        SUM(t.amount * t.exchange_rate) as total_amount,
        t.currency_id,
        COUNT(*) as transaction_count
    FROM "transaction" t
    JOIN transaction_type tt ON t.transaction_type_id = tt.id
    WHERE t.user_id = p_user_id
    AND t.transaction_date >= p_start_date
    AND t.transaction_date <= p_end_date
    GROUP BY tt.name, t.currency_id
    ORDER BY tt.name;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.get_transactions_by_date_range(p_user_id uuid, p_start_date timestamp with time zone, p_end_date timestamp with time zone, p_transaction_type_id uuid DEFAULT NULL::uuid, p_category_id uuid DEFAULT NULL::uuid, p_subcategory_id uuid DEFAULT NULL::uuid, p_account_id uuid DEFAULT NULL::uuid, p_jar_id uuid DEFAULT NULL::uuid)
 RETURNS TABLE(id uuid, user_id uuid, transaction_date timestamp with time zone, description text, amount numeric, transaction_type_id uuid, category_id uuid, subcategory_id uuid, account_id uuid, transaction_medium_id uuid, currency_id uuid, exchange_rate numeric, notes text, tags jsonb, is_recurring boolean, parent_recurring_id uuid, sync_status text, created_at timestamp with time zone, modified_at timestamp with time zone)
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
    RETURN QUERY
    SELECT t.*
    FROM "transaction" t
    LEFT JOIN subcategory sc ON t.subcategory_id = sc.id
    WHERE t.user_id = p_user_id
    AND t.transaction_date >= p_start_date
    AND t.transaction_date <= p_end_date
    AND (p_transaction_type_id IS NULL OR t.transaction_type_id = p_transaction_type_id)
    AND (p_category_id IS NULL OR t.category_id = p_category_id)
    AND (p_subcategory_id IS NULL OR t.subcategory_id = p_subcategory_id)
    AND (p_account_id IS NULL OR t.account_id = p_account_id)
    AND (p_jar_id IS NULL OR sc.jar_id = p_jar_id)
    ORDER BY t.transaction_date DESC;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.validate_transfer()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    -- For Account to Account transfers
    IF NEW.transfer_type = 'ACCOUNT_TO_ACCOUNT' THEN
        IF NEW.from_account_id IS NULL OR NEW.to_account_id IS NULL THEN
            RAISE EXCEPTION 'Account transfers require both from_account_id and to_account_id';
        END IF;
        IF NEW.from_jar_id IS NOT NULL OR NEW.to_jar_id IS NOT NULL THEN
            RAISE EXCEPTION 'Account transfers should not include jar IDs';
        END IF;
    END IF;

    -- For Jar to Jar transfers
    IF NEW.transfer_type = 'JAR_TO_JAR' THEN
        IF NEW.from_jar_id IS NULL OR NEW.to_jar_id IS NULL THEN
            RAISE EXCEPTION 'Jar transfers require both from_jar_id and to_jar_id';
        END IF;
        IF NEW.from_account_id IS NOT NULL OR NEW.to_account_id IS NOT NULL THEN
            RAISE EXCEPTION 'Jar transfers should not include account IDs';
        END IF;
    END IF;

    RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.validate_transfer_by_type()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    -- For Account transfers
    IF NEW.transfer_type = 'ACCOUNT_TO_ACCOUNT' THEN
        IF NEW.from_jar_id IS NOT NULL OR NEW.to_jar_id IS NOT NULL THEN
            RAISE EXCEPTION 'Account transfers cannot include jar IDs';
        END IF;
        IF NEW.from_account_id IS NULL OR NEW.to_account_id IS NULL THEN
            RAISE EXCEPTION 'Account transfers require both account IDs';
        END IF;
    END IF;

    -- For Jar transfers
    IF NEW.transfer_type = 'JAR_TO_JAR' THEN
        IF NEW.from_account_id IS NOT NULL OR NEW.to_account_id IS NOT NULL THEN
            RAISE EXCEPTION 'Jar transfers cannot include account IDs';
        END IF;
        IF NEW.from_jar_id IS NULL OR NEW.to_jar_id IS NULL THEN
            RAISE EXCEPTION 'Jar transfers require both jar IDs';
        END IF;
    END IF;

    RETURN NEW;
END;
$function$
;

CREATE TRIGGER validate_transfer_trigger BEFORE INSERT OR UPDATE ON public.transfer FOR EACH ROW EXECUTE FUNCTION validate_transfer();

CREATE TRIGGER validate_transfer_type_trigger BEFORE INSERT OR UPDATE ON public.transfer FOR EACH ROW EXECUTE FUNCTION validate_transfer_by_type();


