-- #################################################
-- Consolidated Migration Script
-- #################################################

-- First drop dependent views to avoid conflicts
DROP VIEW IF EXISTS public.expense_trends_analysis;
DROP VIEW IF EXISTS public.methodology_compliance_analysis;

-- Drop existing triggers and functions that will be updated
DROP TRIGGER IF EXISTS validate_jar_requirement ON public.subcategory;
DROP FUNCTION IF EXISTS check_jar_requirement();

-- Drop indexes that might be using the code field
DROP INDEX IF EXISTS idx_transaction_type_code;
DROP INDEX IF EXISTS idx_jar_code;
DROP INDEX IF EXISTS idx_subcategory_code;
DROP INDEX IF EXISTS idx_category_code;
DROP INDEX IF EXISTS idx_account_type_code;
DROP INDEX IF EXISTS idx_currency_active;
DROP INDEX IF EXISTS idx_transaction_type_name;
DROP INDEX IF EXISTS idx_jar_name;

-- Drop constraints that might reference the code field
ALTER TABLE public.transaction_type DROP CONSTRAINT IF EXISTS valid_system_types;
ALTER TABLE public.transaction_medium DROP CONSTRAINT IF EXISTS valid_system_mediums;
ALTER TABLE public.jar DROP CONSTRAINT IF EXISTS valid_system_jars;
ALTER TABLE public.subcategory DROP CONSTRAINT IF EXISTS subcategory_code_unique;
ALTER TABLE public.category DROP CONSTRAINT IF EXISTS category_code_unique;
ALTER TABLE public.account_type DROP CONSTRAINT IF EXISTS account_type_code_unique;

-- Drop code columns from all tables
ALTER TABLE public.transaction_type DROP COLUMN IF EXISTS code;
ALTER TABLE public.transaction_medium DROP COLUMN IF EXISTS code;
ALTER TABLE public.jar DROP COLUMN IF EXISTS code;
ALTER TABLE public.category DROP COLUMN IF EXISTS code;
ALTER TABLE public.subcategory DROP COLUMN IF EXISTS code;
ALTER TABLE public.account_type DROP COLUMN IF EXISTS code;

-- Drop is_system columns from all tables
ALTER TABLE public.currency DROP COLUMN IF EXISTS is_system;
ALTER TABLE public.transaction_type DROP COLUMN IF EXISTS is_system;
ALTER TABLE public.transaction_medium DROP COLUMN IF EXISTS is_system;
ALTER TABLE public.jar DROP COLUMN IF EXISTS is_system;
ALTER TABLE public.category DROP COLUMN IF EXISTS is_system;
ALTER TABLE public.subcategory DROP COLUMN IF EXISTS is_system;
ALTER TABLE public.account_type DROP COLUMN IF EXISTS is_system;

-- Add new UNIQUE constraints on name fields
ALTER TABLE public.transaction_type ADD CONSTRAINT transaction_type_name_unique UNIQUE (name);
ALTER TABLE public.transaction_medium ADD CONSTRAINT transaction_medium_name_unique UNIQUE (name);
ALTER TABLE public.jar ADD CONSTRAINT jar_name_unique UNIQUE (name);
ALTER TABLE public.account_type ADD CONSTRAINT account_type_name_unique UNIQUE (name);

-- Create updated jar requirement check function
CREATE OR REPLACE FUNCTION check_jar_requirement() 
RETURNS TRIGGER AS $$
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
$$ LANGUAGE plpgsql;

-- Create new trigger for jar requirement
CREATE TRIGGER validate_jar_requirement
BEFORE INSERT OR UPDATE ON public.subcategory
FOR EACH ROW EXECUTE FUNCTION check_jar_requirement();

-- Create new system data initialization function
CREATE OR REPLACE FUNCTION public.initialize_system_data()
RETURNS void AS $$
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
$$ LANGUAGE plpgsql;

-- Create new indexes
CREATE INDEX idx_currency_name ON public.currency(name);
CREATE INDEX idx_transaction_type_name ON public.transaction_type(name);
CREATE INDEX idx_jar_name ON public.jar(name);

-- Recreate views with updated references
CREATE OR REPLACE VIEW public.expense_trends_analysis AS
WITH monthly_expenses AS (
    SELECT 
        t.user_id,
        date_trunc('month', t.transaction_date) as month,
        c.name as category_name,
        sum(t.amount) as total_amount,
        count(*) as transaction_count
    FROM public.transaction t
    JOIN public.transaction_type tt ON tt.id = t.transaction_type_id
    JOIN public.category c ON c.id = t.category_id
    WHERE tt.name = 'Gasto'
    GROUP BY t.user_id, date_trunc('month', t.transaction_date), c.name
)
SELECT 
    user_id,
    month,
    category_name,
    total_amount,
    transaction_count,
    lag(total_amount) OVER (
        PARTITION BY user_id, category_name 
        ORDER BY month
    ) as prev_month_amount,
    round(
        (total_amount - lag(total_amount) OVER (
            PARTITION BY user_id, category_name 
            ORDER BY month
        )) / NULLIF(lag(total_amount) OVER (
            PARTITION BY user_id, category_name 
            ORDER BY month
        ), 0) * 100,
        2
    ) as month_over_month_change,
    avg(total_amount) OVER (
        PARTITION BY user_id, category_name 
        ORDER BY month
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) as three_month_moving_avg
FROM monthly_expenses;

CREATE OR REPLACE VIEW public.methodology_compliance_analysis AS
WITH jar_distributions AS (
    SELECT 
        t.user_id,
        date_trunc('month', t.transaction_date) as month,
        j.name as jar_name,
        j.target_percentage,
        sum(t.amount) as jar_amount,
        sum(sum(t.amount)) OVER (
            PARTITION BY t.user_id, date_trunc('month', t.transaction_date)
        ) as total_amount
    FROM public.transaction t
    JOIN public.transaction_type tt ON tt.id = t.transaction_type_id
    JOIN public.jar j ON j.id = t.jar_id
    WHERE tt.name = 'Gasto'
    GROUP BY t.user_id, date_trunc('month', t.transaction_date), j.name, j.target_percentage
)
SELECT 
    user_id,
    month,
    jar_name,
    target_percentage,
    round((jar_amount / NULLIF(total_amount, 0)) * 100, 2) as actual_percentage,
    round(
        ((jar_amount / NULLIF(total_amount, 0)) * 100) - target_percentage,
        2
    ) as percentage_difference,
    abs(((jar_amount / NULLIF(total_amount, 0)) * 100) - target_percentage) <= 2 as is_compliant
FROM jar_distributions;

-- Verify changes
SELECT
    table_name,
    column_name,
    data_type
FROM
    information_schema.columns
WHERE
    table_schema = 'public'
    AND column_name IN ('code', 'is_system')
    AND table_name IN (
        'currency',
        'transaction_type',
        'transaction_medium',
        'jar',
        'category',
        'subcategory',
        'account_type'
    );