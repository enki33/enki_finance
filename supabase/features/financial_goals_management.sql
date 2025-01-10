-- #################################################
-- Gestión de Metas Financieras
-- #################################################

-- Este script implementa la funcionalidad de metas financieras,
-- incluyendo seguimiento, análisis y notificaciones.

-- #################################################
-- TIPOS Y FUNCIONES DE CÁLCULO
-- #################################################

-- Tipo: Estado de progreso de meta
CREATE TYPE public.goal_progress_status AS (
    percentage_complete numeric(5,2),
    amount_remaining numeric(15,2),
    days_remaining integer,
    is_on_track boolean,
    required_daily_amount numeric(15,2)
);

-- Función: Calcular progreso de meta
CREATE OR REPLACE FUNCTION public.calculate_goal_progress(
    p_current_amount numeric,
    p_target_amount numeric,
    p_start_date date,
    p_target_date date
)
RETURNS public.goal_progress_status AS $$
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
$$ LANGUAGE plpgsql;

-- #################################################
-- FUNCIONES DE ACTUALIZACIÓN
-- #################################################

-- Función: Actualizar progreso de meta
CREATE OR REPLACE FUNCTION public.update_goal_progress(
    p_goal_id uuid,
    p_new_amount numeric
)
RETURNS public.goal_progress_status AS $$
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
$$ LANGUAGE plpgsql;

-- #################################################
-- FUNCIONES DE ANÁLISIS
-- #################################################

-- Función: Obtener análisis detallado de meta
CREATE OR REPLACE FUNCTION public.analyze_financial_goal(
    p_goal_id uuid
)
RETURNS TABLE (
    name text,
    target_amount numeric(15,2),
    current_amount numeric(15,2),
    percentage_complete numeric(5,2),
    amount_remaining numeric(15,2),
    days_remaining integer,
    is_on_track boolean,
    required_daily_amount numeric(15,2),
    average_daily_progress numeric(15,2),
    projected_completion_date date,
    status text
) AS $$
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
$$ LANGUAGE plpgsql;

-- Función: Obtener resumen de todas las metas
CREATE OR REPLACE FUNCTION public.get_goals_summary(
    p_user_id uuid
)
RETURNS TABLE (
    total_goals bigint,
    completed_goals bigint,
    in_progress_goals bigint,
    total_target_amount numeric(15,2),
    total_current_amount numeric(15,2),
    overall_completion_percentage numeric(5,2)
) AS $$
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
$$ LANGUAGE plpgsql;

-- #################################################
-- FUNCIONES DE SEGUIMIENTO AUTOMÁTICO
-- #################################################

-- Función: Actualizar progreso basado en transacciones
CREATE OR REPLACE FUNCTION public.update_goal_from_transaction()
RETURNS TRIGGER AS $$
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
$$ LANGUAGE plpgsql;

-- Trigger: Actualización automática de metas
CREATE TRIGGER update_goals_after_transaction
    AFTER INSERT OR UPDATE ON public.transaction
    FOR EACH ROW
    EXECUTE FUNCTION public.update_goal_from_transaction();

-- #################################################
-- FUNCIONES DE REPORTE
-- #################################################

-- Vista: Resumen de progreso de metas
CREATE OR REPLACE VIEW public.goal_progress_summary AS
WITH goal_progress AS (
    SELECT 
        g.*,
        public.calculate_goal_progress(
            g.current_amount,
            g.target_amount,
            g.start_date,
            g.target_date
        ) as progress
    FROM public.financial_goal g
    WHERE g.is_active = true
)
SELECT 
    g.user_id,
    g.id as goal_id,
    g.name,
    g.target_amount,
    g.current_amount,
    (g.progress).percentage_complete,
    (g.progress).amount_remaining,
    (g.progress).days_remaining,
    (g.progress).is_on_track,
    (g.progress).required_daily_amount,
    j.name as jar_name,
    g.status,
    g.start_date,
    g.target_date,
    g.created_at,
    g.modified_at
FROM goal_progress g
LEFT JOIN public.jar j ON j.id = g.jar_id;

-- #################################################
-- FUNCIONES DE LIMPIEZA
-- #################################################

-- Función: Archivar metas completadas antiguas
CREATE OR REPLACE FUNCTION public.archive_completed_goals(
    p_days_threshold integer DEFAULT 30
)
RETURNS integer AS $$
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
$$ LANGUAGE plpgsql;

-- Programar limpieza automática
SELECT cron.schedule(
    'archive-completed-goals',
    '0 0 1 * *',  -- Ejecutar el primer día de cada mes a las 00:00
    $$
    SELECT public.archive_completed_goals(30);
    $$
);

-- #################################################
-- FIN DEL SCRIPT
-- #################################################