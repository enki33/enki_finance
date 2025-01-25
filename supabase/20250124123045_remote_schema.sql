drop trigger if exists "validate_recurring_transaction_jar_requirement" on "public"."recurring_transaction";

drop trigger if exists "validate_jar_requirement" on "public"."subcategory";

drop trigger if exists "validate_transaction_jar_requirement" on "public"."transaction";

alter table "public"."transaction" drop constraint "transaction_jar_id_fkey";

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

drop function if exists "public"."check_jar_requirement"();

drop function if exists "public"."check_recurring_transaction_jar_requirement"();

drop function if exists "public"."check_transaction_jar_requirement"();

drop view if exists "public"."methodology_compliance_analysis";

drop view if exists "public"."expense_trends_analysis";

drop index if exists "public"."idx_transaction_jar";

drop index if exists "public"."idx_transaction_jar_analysis";

drop index if exists "public"."idx_transfer_jars";

alter table "public"."transaction" drop column "jar_id";

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

CREATE OR REPLACE FUNCTION public.analyze_jar_distribution(p_user_id uuid, p_start_date date DEFAULT NULL::date, p_end_date date DEFAULT NULL::date)
 RETURNS SETOF jar_distribution_summary
 LANGUAGE plpgsql
AS $function$
DECLARE
    v_total_income numeric(15,2);
BEGIN
    -- Get total income for the period
    SELECT COALESCE(sum(amount), 0) INTO v_total_income
    FROM public.transaction t
    JOIN public.transaction_type tt ON tt.id = t.transaction_type_id
    WHERE t.user_id = p_user_id
    AND tt.code = 'INCOME'
    AND (p_start_date IS NULL OR t.transaction_date >= p_start_date)
    AND (p_end_date IS NULL OR t.transaction_date <= p_end_date);

    -- Return jar analysis using subcategory.jar_id
    RETURN QUERY
    WITH jar_totals AS (
        SELECT 
            j.id,
            j.name as jar_name,
            j.target_percentage,
            COALESCE(sum(t.amount), 0) as total_amount
        FROM public.jar j
        LEFT JOIN public.subcategory sc ON sc.jar_id = j.id
        LEFT JOIN public.transaction t ON t.subcategory_id = sc.id
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
$function$
;

create or replace view "public"."expense_trends_analysis" as  WITH monthly_expenses AS (
         SELECT t.user_id,
            date_trunc('month'::text, (t.transaction_date)::timestamp with time zone) AS month,
            c.name AS category_name,
            sum(t.amount) AS total_amount,
            count(*) AS transaction_count
           FROM ((transaction t
             JOIN transaction_type tt ON ((tt.id = t.transaction_type_id)))
             JOIN category c ON ((c.id = t.category_id)))
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



