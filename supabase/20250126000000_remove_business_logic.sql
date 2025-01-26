-- Drop triggers first to avoid dependency issues
DROP TRIGGER IF EXISTS validate_transfer_trigger ON public.transfer;
DROP TRIGGER IF EXISTS validate_transfer_type_trigger ON public.transfer;
DROP TRIGGER IF EXISTS validate_credit_card_transaction_trigger ON public.transaction;
DROP TRIGGER IF EXISTS validate_sufficient_balance_trigger ON public.transfer;
DROP TRIGGER IF EXISTS check_jar_requirement_trigger ON public.transaction;
DROP TRIGGER IF EXISTS check_recurring_transaction_jar_requirement_trigger ON public.recurring_transaction;
DROP TRIGGER IF EXISTS validate_transaction_balance ON public.transaction;
DROP TRIGGER IF EXISTS validate_transfer_balance ON public.transfer;
DROP TRIGGER IF EXISTS update_goals_after_transaction ON public.transaction;
DROP TRIGGER IF EXISTS update_balances_on_transaction ON public.transaction;
DROP TRIGGER IF EXISTS update_balances_on_transfer ON public.transfer;

-- Drop related trigger functions
DROP FUNCTION IF EXISTS public.update_balances();
DROP FUNCTION IF EXISTS public.update_goal_from_transaction();

-- Drop validation functions
DROP FUNCTION IF EXISTS public.validate_transfer();
DROP FUNCTION IF EXISTS public.validate_transfer_by_type();
DROP FUNCTION IF EXISTS public.validate_account_transfer(uuid, uuid, uuid, numeric, numeric);
DROP FUNCTION IF EXISTS public.validate_jar_transfer(uuid, uuid, uuid, numeric);
DROP FUNCTION IF EXISTS public.validate_credit_card_transaction();
DROP FUNCTION IF EXISTS public.validate_credit_limit(uuid, numeric);
DROP FUNCTION IF EXISTS public.validate_sufficient_balance();
DROP FUNCTION IF EXISTS public.validate_recurring_transaction(uuid, numeric, uuid, uuid, uuid, uuid);
DROP FUNCTION IF EXISTS public.check_jar_requirement();
DROP FUNCTION IF EXISTS public.check_recurring_transaction_jar_requirement();
DROP FUNCTION IF EXISTS public.check_transaction_jar_requirement();

-- Drop balance calculation functions
DROP FUNCTION IF EXISTS public.check_transfer_balance(uuid, numeric);
DROP FUNCTION IF EXISTS public.check_available_balance_for_transfer(uuid, uuid, uuid);
DROP FUNCTION IF EXISTS public.calculate_account_balance(uuid, timestamp with time zone);
DROP FUNCTION IF EXISTS public.calculate_jar_balance(uuid, timestamp with time zone);

-- Drop analysis functions
DROP FUNCTION IF EXISTS public.analyze_transactions_by_category(uuid, date, date, text);
DROP FUNCTION IF EXISTS public.analyze_jar_distribution(uuid, date, date);
DROP FUNCTION IF EXISTS public.get_daily_transaction_totals(uuid, timestamp with time zone, timestamp with time zone, uuid);
DROP FUNCTION IF EXISTS public.get_transaction_summary_by_date_range(uuid, timestamp with time zone, timestamp with time zone);
DROP FUNCTION IF EXISTS public.get_transactions_by_date_range(uuid, timestamp with time zone, timestamp with time zone, uuid, uuid, uuid, uuid, uuid);

-- Drop goal-related business logic
DROP FUNCTION IF EXISTS public.analyze_financial_goal(uuid);
DROP FUNCTION IF EXISTS public.calculate_goal_progress(numeric, numeric, date, date);
DROP FUNCTION IF EXISTS public.update_goal_progress(uuid, numeric);
DROP FUNCTION IF EXISTS public.get_goals_summary(uuid);

-- Drop transfer-related business logic
DROP FUNCTION IF EXISTS public.execute_account_transfer(uuid, uuid, uuid, numeric, numeric, text);
DROP FUNCTION IF EXISTS public.process_jar_rollover(uuid);
DROP FUNCTION IF EXISTS public.get_transfer_summary_by_period(uuid, date, date);

-- Drop analysis and summary functions
DROP FUNCTION IF EXISTS public.get_period_summary(uuid, date, date);
DROP FUNCTION IF EXISTS public.get_credit_card_summary(uuid);

-- Drop obsolete types
DROP TYPE IF EXISTS public.transfer_validation_result;
DROP TYPE IF EXISTS public.goal_progress_status;
DROP TYPE IF EXISTS public.period_summary_type;

-- Add comment to explain migration
COMMENT ON MIGRATION IS 'Remove business logic from database layer as it has been moved to the domain layer in the application.'; 