-- #################################################
-- Gestión de Reportes y Análisis
-- #################################################

-- Este script implementa las vistas y funciones necesarias para
-- generar reportes y análisis del sistema financiero personal.

-- #################################################
-- TIPOS DE DATOS
-- #################################################

-- Tipo: Resumen de distribución de jarras
CREATE TYPE public.jar_distribution_summary AS (
    jar_name text,
    current_percentage numeric(5,2),
    target_percentage numeric(5,2),
    difference numeric(5,2),
    is_compliant boolean
);

-- Tipo: Resumen de período
CREATE TYPE public.period_summary_type AS (
    total_income numeric(15,2),
    total_expenses numeric(15,2),
    net_amount numeric(15,2),
    savings_rate numeric(5,2),
    expense_income_ratio numeric(5,2)
);

-- #################################################
-- FUNCIONES DE ANÁLISIS DE JARRAS
-- #################################################

-- Función: Analizar distribución de jarras
CREATE OR REPLACE FUNCTION public.analyze_jar_distribution(
    p_user_id uuid,
    p_start_date date DEFAULT NULL,
    p_end_date date DEFAULT NULL
)
RETURNS SETOF public.jar_distribution_summary AS $$
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
$$ LANGUAGE plpgsql;

-- #################################################
-- FUNCIONES DE ANÁLISIS DE TRANSACCIONES
-- #################################################

-- Función: Analizar transacciones por categoría
CREATE OR REPLACE FUNCTION public.analyze_transactions_by_category(
    p_user_id uuid,
    p_start_date date,
    p_end_date date,
    p_transaction_type text DEFAULT NULL
)
RETURNS TABLE (
    category_name text,
    subcategory_name text,
    transaction_count bigint,
    total_amount numeric(15,2),
    percentage_of_total numeric(5,2),
    avg_amount numeric(15,2),
    min_amount numeric(15,2),
    max_amount numeric(15,2)
) AS $$
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
$$ LANGUAGE plpgsql;

-- Función: Obtener resumen de período
CREATE OR REPLACE FUNCTION public.get_period_summary(
    p_user_id uuid,
    p_start_date date,
    p_end_date date
)
RETURNS public.period_summary_type AS $$
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
$$ LANGUAGE plpgsql;

-- #################################################
-- VISTAS DE ANÁLISIS
-- #################################################

-- Vista: Análisis de tendencias de gastos
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
    JOIN public.category c ON c.id = t.category_id  -- Changed from t.category to t.category_id
    WHERE tt.code = 'EXPENSE'
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

-- Vista: Análisis de cumplimiento de metodología
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
    WHERE tt.code = 'EXPENSE'
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

-- #################################################
-- FUNCIONES DE EXPORTACIÓN
-- #################################################

-- Función: Exportar transacciones a formato Excel
CREATE OR REPLACE FUNCTION public.export_transactions_to_excel(
    p_user_id uuid,
    p_start_date date,
    p_end_date date
)
RETURNS TABLE (
    transaction_date date,
    transaction_type text,
    category text,
    subcategory text,
    amount numeric,
    account_name text,
    jar_name text,
    description text
) AS $$
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
$$ LANGUAGE plpgsql;

-- Función: Exportar estado de jarras a formato Excel
CREATE OR REPLACE FUNCTION public.export_jar_status_to_excel(
    p_user_id uuid
)
RETURNS TABLE (
    jar_name text,
    current_balance numeric,
    target_percentage numeric,
    current_percentage numeric,
    last_transaction_date date,
    total_transactions bigint
) AS $$
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
$$ LANGUAGE plpgsql;

-- #################################################
-- ÍNDICES ADICIONALES PARA REPORTES
-- #################################################

-- Índice para análisis por categoría
CREATE INDEX idx_transaction_category_analysis 
ON public.transaction (user_id, category_id, transaction_date);

-- Índice para análisis por jarra
CREATE INDEX idx_transaction_jar_analysis 
ON public.transaction (user_id, jar_id, transaction_date);

-- Índice para análisis temporal
CREATE INDEX idx_transaction_date_analysis 
ON public.transaction (user_id, transaction_date)
INCLUDE (amount);

-- #################################################
-- FIN DEL SCRIPT
-- #################################################