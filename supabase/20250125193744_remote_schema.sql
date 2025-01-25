create type "public"."transfer_validation_result" as enum ('valid', 'invalid');

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

drop function if exists "public"."initialize_system_data"();

drop type "public"."transfer_validation_result";

drop index if exists "public"."idx_transfer_jars";

CREATE INDEX idx_transfer_jars ON public.transfer USING btree (from_jar_id, to_jar_id) WHERE ((transfer_type)::text = ANY ((ARRAY['JAR_TO_JAR'::character varying, 'PERIOD_ROLLOVER'::character varying])::text[]));

alter table "public"."app_user" add constraint "notification_advance_days_check" CHECK (((notification_advance_days >= 0) AND (notification_advance_days <= 30))) not valid;

alter table "public"."app_user" validate constraint "notification_advance_days_check";

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


