-- #################################################
-- Sistema de Finanzas Personales - Estructura de Base de Datos
-- #################################################

-- Este script contiene la definición completa de la estructura de base de datos
-- para el sistema de finanzas personales con metodología de 6 jarras.

-- #################################################
-- TABLAS DEL SISTEMA (Sin Dependencias)
-- #################################################

-- Tabla: currency
-- Propósito: Almacena las monedas soportadas en el sistema
-- Uso:
--   - Moneda predeterminada para nuevas cuentas (MXN)
--   - Soporte para transacciones en moneda extranjera
--   - Conversión de monedas en reportes
CREATE TABLE public.currency (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    code varchar(3) NOT NULL UNIQUE,      -- Código ISO 4217 (ej: MXN, USD)
    name text NOT NULL,                   -- Nombre completo
    symbol varchar(5),                    -- Símbolo (ej: $, €)
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modified_at timestamptz,
);

COMMENT ON TABLE public.currency IS 'Catálogo de monedas soportadas';
COMMENT ON COLUMN public.currency.is_system_default IS 'Solo MXN puede ser moneda predeterminada del sistema';

-- Tabla: transaction_type
-- Propósito: Define los tipos fundamentales de transacciones
-- Tipos principales: INCOME (Ingreso), EXPENSE (Gasto), TRANSFER (Transferencia)
CREATE TABLE public.transaction_type (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    code varchar(20) NOT NULL UNIQUE,     -- Código único (ej: INCOME, EXPENSE)
    name text NOT NULL,                   -- Nombre descriptivo
    description text,                     -- Descripción detallada
    is_system boolean DEFAULT false,      -- Indica si es tipo del sistema
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modified_at timestamptz,
    CONSTRAINT valid_system_types CHECK (
        NOT is_system OR 
        code IN ('INCOME', 'EXPENSE', 'TRANSFER')
    )
);

COMMENT ON TABLE public.transaction_type IS 'Tipos de transacciones soportadas';
COMMENT ON COLUMN public.transaction_type.is_system IS 'Tipos base del sistema no pueden modificarse';

-- Tabla: transaction_medium
-- Propósito: Define los medios de pago (efectivo, tarjeta, etc.)
CREATE TABLE public.transaction_medium (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    code varchar(20) NOT NULL UNIQUE,     -- Código único (ej: CASH, CARD)
    name text NOT NULL,                   -- Nombre descriptivo
    description text,                     -- Descripción detallada
    is_system boolean DEFAULT false,      -- Indica si es medio del sistema
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modified_at timestamptz,
    CONSTRAINT valid_system_mediums CHECK (
        NOT is_system OR 
        code IN ('CASH', 'DEBIT_CARD', 'CREDIT_CARD', 'TRANSFER', 'OTHER')
    )
);

COMMENT ON TABLE public.transaction_medium IS 'Medios de pago soportados';

-- #################################################
-- TABLAS DE USUARIO Y PERFILES
-- #################################################

-- Tabla: app_user
-- Propósito: Extiende la tabla auth.users de Supabase con información adicional
CREATE TABLE public.app_user (
    id UUID PRIMARY KEY REFERENCES auth.users(id),
    email TEXT NOT NULL,
    first_name TEXT,
    last_name TEXT,
    default_currency_id uuid NOT NULL REFERENCES public.currency(id),
    notifications_enabled boolean DEFAULT true,
    notification_advance_days integer DEFAULT 1, -- Días de anticipación para notificaciones
    is_active boolean NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    modified_at timestamptz,
    CONSTRAINT valid_notification_days CHECK (notification_advance_days > 0)
);

COMMENT ON TABLE public.app_user IS 'Información extendida de usuarios';
COMMENT ON COLUMN public.app_user.notification_advance_days IS 'Días de anticipación para notificaciones recurrentes';

-- #################################################
-- TABLAS DE JARRAS Y CATEGORIZACIÓN
-- #################################################

-- Tabla: jar
-- Propósito: Define las 6 jarras del sistema según metodología T. Harv Eker
CREATE TABLE public.jar (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    code varchar(20) NOT NULL UNIQUE,     -- Código único (ej: NECESSITIES)
    name text NOT NULL,                   -- Nombre descriptivo
    description text,                     -- Descripción detallada
    target_percentage numeric(5,2) NOT NULL, -- Porcentaje objetivo según metodología
    is_system boolean DEFAULT false,      -- Indica si es jarra del sistema
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modified_at timestamptz,
    CONSTRAINT valid_percentage CHECK (target_percentage > 0 AND target_percentage <= 100),
    CONSTRAINT valid_system_jars CHECK (
        NOT is_system OR 
        code IN ('NECESSITIES', 'INVESTMENT', 'SAVINGS', 'EDUCATION', 'PLAY', 'GIVE')
    )
);

COMMENT ON TABLE public.jar IS 'Jarras según metodología de T. Harv Eker';
COMMENT ON COLUMN public.jar.target_percentage IS 'Porcentaje que debe recibir la jarra de los ingresos';

-- Tabla: category
-- Propósito: Categorías principales para ingresos y gastos
CREATE TABLE public.category (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    code varchar(50) NOT NULL UNIQUE,    -- Código único
    name text NOT NULL,                  -- Nombre descriptivo
    description text,                    -- Descripción detallada
    transaction_type_id uuid NOT NULL REFERENCES public.transaction_type(id),
    is_system boolean DEFAULT false,     -- Indica si es categoría del sistema
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modified_at timestamptz
);

COMMENT ON TABLE public.category IS 'Categorías para clasificación de transacciones';

-- Tabla: subcategory
-- Propósito: Subcategorías para clasificación detallada
CREATE TABLE public.subcategory (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    code varchar(50) NOT NULL UNIQUE,    -- Código único
    name text NOT NULL,                  -- Nombre descriptivo
    description text,                    --- Descripción detallada
    category_id uuid NOT NULL REFERENCES public.category(id),
    jar_id uuid REFERENCES public.jar(id), -- Nulo para categorías de ingreso
    is_system boolean DEFAULT false,     -- Indica si es subcategoría del sistema
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modified_at timestamptz
);

CREATE OR REPLACE FUNCTION check_jar_requirement() 
RETURNS TRIGGER AS $$
BEGIN
    IF (NEW.jar_id IS NOT NULL AND EXISTS (
        SELECT 1 FROM public.category c 
        WHERE c.id = NEW.category_id 
        AND c.transaction_type_id IN (
            SELECT id FROM public.transaction_type WHERE code = 'EXPENSE'
        )
    )) THEN
        RETURN NEW;
    ELSIF (NEW.jar_id IS NULL AND EXISTS (
        SELECT 1 FROM public.category c 
        WHERE c.id = NEW.category_id 
        AND c.transaction_type_id IN (
            SELECT id FROM public.transaction_type WHERE code != 'EXPENSE'
        )
    )) THEN
        RETURN NEW;
    ELSE
        RAISE EXCEPTION 'Invalid jar_id for the given category_id';
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER validate_jar_requirement
BEFORE INSERT OR UPDATE ON public.subcategory
FOR EACH ROW EXECUTE FUNCTION check_jar_requirement();

COMMENT ON TABLE public.subcategory IS 'Subcategorías para clasificación detallada';
COMMENT ON COLUMN public.subcategory.jar_id IS 'Jarra asociada, requerida solo para gastos';

-- #################################################
-- TABLAS DE CUENTAS Y BALANCES
-- #################################################

-- Tabla: account_type
-- Propósito: Define los tipos de cuenta soportados
CREATE TABLE public.account_type (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    code varchar(20) NOT NULL UNIQUE,    -- Código único
    name text NOT NULL,                  -- Nombre descriptivo
    description text,                    -- Descripción detallada
    is_system boolean DEFAULT false,     -- Indica si es tipo del sistema
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modified_at timestamptz,
    CONSTRAINT valid_system_account_types CHECK (
        NOT is_system OR 
        code IN ('CHECKING', 'SAVINGS', 'CASH', 'CREDIT_CARD', 'INVESTMENT')
    )
);

COMMENT ON TABLE public.account_type IS 'Tipos de cuenta soportados';

-- Tabla: account
-- Propósito: Representa las cuentas financieras del usuario
CREATE TABLE public.account (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES public.app_user(id),
    account_type_id uuid NOT NULL REFERENCES public.account_type(id),
    name text NOT NULL,                  -- Nombre descriptivo
    code text NOT NULL,                  -- Código único de la cuenta
    description text,                    -- Descripción detallada
    currency_id uuid NOT NULL REFERENCES public.currency(id),
    current_balance numeric(15,2) NOT NULL DEFAULT 0,
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modified_at timestamptz,
    CONSTRAINT unique_account_name_per_user UNIQUE (user_id, name),
    CONSTRAINT unique_account_code_per_user UNIQUE (user_id, code)
);

COMMENT ON TABLE public.account IS 'Cuentas financieras de los usuarios';

-- Tabla: jar_balance
-- Propósito: Mantiene el balance actual de cada jarra por usuario
CREATE TABLE public.jar_balance (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES public.app_user(id),
    jar_id uuid NOT NULL REFERENCES public.jar(id),
    current_balance numeric(15,2) NOT NULL DEFAULT 0,
    created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modified_at timestamptz,
    CONSTRAINT unique_jar_per_user UNIQUE (user_id, jar_id)
);

COMMENT ON TABLE public.jar_balance IS 'Balance actual de cada jarra por usuario';

-- #################################################
-- TABLAS DE TRANSACCIONES
-- #################################################

-- Tabla: transaction
-- Propósito: Registro de todas las transacciones financieras
-- Tabla: transaction
CREATE TABLE public.transaction (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES public.app_user(id),
    transaction_date date NOT NULL DEFAULT CURRENT_DATE,
    description text,
    amount numeric(15,2) NOT NULL CHECK (amount != 0),
    transaction_type_id uuid NOT NULL REFERENCES public.transaction_type(id),
    category_id uuid NOT NULL REFERENCES public.category(id),
    subcategory_id uuid NOT NULL REFERENCES public.subcategory(id),
    account_id uuid NOT NULL REFERENCES public.account(id),
    jar_id uuid REFERENCES public.jar(id),
    transaction_medium_id uuid REFERENCES public.transaction_medium(id),
    currency_id uuid NOT NULL REFERENCES public.currency(id),
    exchange_rate numeric(10,6) NOT NULL DEFAULT 1,
    notes text,
    tags jsonb,
    is_recurring boolean DEFAULT false,
    parent_recurring_id uuid,
    sync_status varchar(20) NOT NULL DEFAULT 'PENDING' CHECK (
        sync_status IN ('PENDING', 'SYNCED', 'ERROR')
    ),
    created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modified_at timestamptz,
    CONSTRAINT valid_exchange_rate CHECK (exchange_rate > 0)
);

-- Function to check jar requirement for transactions
CREATE OR REPLACE FUNCTION check_transaction_jar_requirement() 
RETURNS TRIGGER AS $$
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
$$ LANGUAGE plpgsql;

-- Trigger for jar requirement validation
CREATE TRIGGER validate_transaction_jar_requirement
BEFORE INSERT OR UPDATE ON public.transaction
FOR EACH ROW EXECUTE FUNCTION check_transaction_jar_requirement();

COMMENT ON TABLE public.transaction IS 'Registro de todas las transacciones financieras';

-- Tabla: recurring_transaction
-- Propósito: Plantillas para transacciones recurrentes
-- Tabla: recurring_transaction
CREATE TABLE public.recurring_transaction (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES public.app_user(id),
    name text NOT NULL,
    description text,
    amount numeric(15,2) NOT NULL CHECK (amount != 0),
    transaction_type_id uuid NOT NULL REFERENCES public.transaction_type(id),
    category_id uuid NOT NULL REFERENCES public.category(id),
    subcategory_id uuid NOT NULL REFERENCES public.subcategory(id),
    account_id uuid NOT NULL REFERENCES public.account(id),
    jar_id uuid REFERENCES public.jar(id),
    transaction_medium_id uuid REFERENCES public.transaction_medium(id),
    frequency varchar(20) NOT NULL CHECK (
        frequency IN ('WEEKLY', 'MONTHLY', 'YEARLY')
    ),
    start_date date NOT NULL,
    end_date date,
    last_execution_date date,
    next_execution_date date,
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modified_at timestamptz,
    CONSTRAINT valid_dates CHECK (
        (end_date IS NULL OR end_date >= start_date)
        AND
        (next_execution_date IS NULL OR next_execution_date >= CURRENT_DATE)
    )
);

-- Function to check jar requirement for recurring transactions
CREATE OR REPLACE FUNCTION check_recurring_transaction_jar_requirement() 
RETURNS TRIGGER AS $$
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
$$ LANGUAGE plpgsql;

-- Trigger for jar requirement validation
CREATE TRIGGER validate_recurring_transaction_jar_requirement
BEFORE INSERT OR UPDATE ON public.recurring_transaction
FOR EACH ROW EXECUTE FUNCTION check_recurring_transaction_jar_requirement();

COMMENT ON TABLE public.recurring_transaction IS 'Configuración de transacciones recurrentes';


-- Tabla: transfer
-- Propósito: Registro de transferencias entre cuentas y jarras
CREATE TABLE public.transfer (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES public.app_user(id),
    transfer_date date NOT NULL DEFAULT CURRENT_DATE,
    description text,
    amount numeric(15,2) NOT NULL CHECK (amount > 0),
    transfer_type varchar(20) NOT NULL CHECK (
        transfer_type IN ('ACCOUNT_TO_ACCOUNT', 'JAR_TO_JAR', 'PERIOD_ROLLOVER')
    ),
    from_account_id uuid REFERENCES public.account(id),
    to_account_id uuid REFERENCES public.account(id),
    from_jar_id uuid REFERENCES public.jar(id),
    to_jar_id uuid REFERENCES public.jar(id),
    exchange_rate numeric(10,6) NOT NULL DEFAULT 1,
    notes text,
    sync_status varchar(20) NOT NULL DEFAULT 'PENDING' CHECK (
        sync_status IN ('PENDING', 'SYNCED', 'ERROR')
    ),
    created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modified_at timestamptz,
    CONSTRAINT valid_transfer_endpoints CHECK (
        (transfer_type = 'ACCOUNT_TO_ACCOUNT' AND from_account_id IS NOT NULL AND to_account_id IS NOT NULL AND from_jar_id IS NULL AND to_jar_id IS NULL)
        OR
        (transfer_type = 'JAR_TO_JAR' AND from_jar_id IS NOT NULL AND to_jar_id IS NOT NULL AND from_account_id IS NULL AND to_account_id IS NULL)
        OR
        (transfer_type = 'PERIOD_ROLLOVER' AND from_jar_id IS NOT NULL AND to_jar_id IS NOT NULL AND from_account_id IS NULL AND to_account_id IS NULL)
    ),
    CONSTRAINT different_endpoints CHECK (
        (from_account_id IS NULL OR from_account_id != to_account_id)
        AND
        (from_jar_id IS NULL OR from_jar_id != to_jar_id)
    )
);

COMMENT ON TABLE public.transfer IS 'Registro de transferencias entre cuentas y jarras';
COMMENT ON COLUMN public.transfer.transfer_type IS 'ACCOUNT_TO_ACCOUNT: entre cuentas, JAR_TO_JAR: entre jarras, PERIOD_ROLLOVER: rollover de periodo';

-- #################################################
-- TABLAS DE METAS Y SEGUIMIENTO
-- #################################################

-- Tabla: financial_goal
-- Propósito: Registro de metas financieras
CREATE TABLE public.financial_goal (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES public.app_user(id),
    name text NOT NULL,
    description text,
    target_amount numeric(15,2) NOT NULL CHECK (target_amount > 0),
    current_amount numeric(15,2) NOT NULL DEFAULT 0,
    start_date date NOT NULL,
    target_date date NOT NULL,
    jar_id uuid REFERENCES public.jar(id),
    status varchar(20) NOT NULL DEFAULT 'IN_PROGRESS' CHECK (
        status IN ('IN_PROGRESS', 'COMPLETED', 'CANCELLED')
    ),
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modified_at timestamptz,
    CONSTRAINT valid_dates CHECK (target_date > start_date),
    CONSTRAINT valid_amounts CHECK (current_amount <= target_amount)
);

COMMENT ON TABLE public.financial_goal IS 'Metas financieras de ahorro e inversión';

-- #################################################
-- TABLAS DE NOTIFICACIONES
-- #################################################

-- Tabla: notification
-- Propósito: Registro de notificaciones del sistema
CREATE TABLE public.notification (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES public.app_user(id),
    title text NOT NULL,
    message text NOT NULL,
    notification_type varchar(50) NOT NULL CHECK (
        notification_type IN (
            'RECURRING_TRANSACTION',
            'INSUFFICIENT_FUNDS',
            'GOAL_PROGRESS',
            'SYNC_ERROR',
            'SYSTEM'
        )
    ),
    urgency_level varchar(20) NOT NULL CHECK (
        urgency_level IN ('LOW', 'MEDIUM', 'HIGH')
    ),
    related_entity_type varchar(50),  -- Tipo de entidad relacionada (transaction, goal, etc.)
    related_entity_id uuid,           -- ID de la entidad relacionada
    is_read boolean NOT NULL DEFAULT false,
    created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    read_at timestamptz
);

COMMENT ON TABLE public.notification IS 'Registro de notificaciones del sistema';

-- #################################################
-- TABLAS DE HISTÓRICOS
-- #################################################

-- Tabla: balance_history
-- Propósito: Historial de cambios en balances de cuentas y jarras
CREATE TABLE public.balance_history (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES public.app_user(id),
    account_id uuid REFERENCES public.account(id),
    jar_id uuid REFERENCES public.jar(id),
    old_balance numeric(15,2) NOT NULL,
    new_balance numeric(15,2) NOT NULL,
    change_amount numeric(15,2) NOT NULL,
    change_type varchar(50) NOT NULL CHECK (
        change_type IN (
            'TRANSACTION',
            'TRANSFER',
            'ADJUSTMENT',
            'ROLLOVER'
        )
    ),
    reference_type varchar(50) NOT NULL,  -- Tipo de entidad que causó el cambio
    reference_id uuid NOT NULL,           -- ID de la entidad que causó el cambio
    created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT valid_target CHECK (
        (account_id IS NOT NULL AND jar_id IS NULL) OR
        (account_id IS NULL AND jar_id IS NOT NULL)
    )
);

COMMENT ON TABLE public.balance_history IS 'Historial de cambios en balances';

-- #################################################
-- ÍNDICES
-- #################################################

-- Índices para currency
CREATE INDEX idx_currency_active ON public.currency(id) WHERE is_active = true;
CREATE INDEX idx_currency_code ON public.currency(code);

-- Índices para transaction_type
CREATE INDEX idx_transaction_type_active ON public.transaction_type(id) WHERE is_active = true;
CREATE INDEX idx_transaction_type_code ON public.transaction_type(code);

-- Índices para app_user
CREATE INDEX idx_app_user_email ON public.app_user(email);
CREATE INDEX idx_app_user_active ON public.app_user(id) WHERE is_active = true;

-- Índices para jar
CREATE INDEX idx_jar_active ON public.jar(id) WHERE is_active = true;
CREATE INDEX idx_jar_code ON public.jar(code);

-- Índices para category y subcategory
CREATE INDEX idx_category_active ON public.category(id) WHERE is_active = true;
CREATE INDEX idx_category_type ON public.category(transaction_type_id);
CREATE INDEX idx_subcategory_active ON public.subcategory(id) WHERE is_active = true;
CREATE INDEX idx_subcategory_category ON public.subcategory(category_id);
CREATE INDEX idx_subcategory_jar ON public.subcategory(jar_id);

-- Índices para account
CREATE INDEX idx_account_user ON public.account(user_id);
CREATE INDEX idx_account_active ON public.account(id) WHERE is_active = true;
CREATE INDEX idx_account_type ON public.account(account_type_id);

-- Índices para jar_balance
CREATE INDEX idx_jar_balance_user ON public.jar_balance(user_id);
CREATE INDEX idx_jar_balance_jar ON public.jar_balance(jar_id);

-- Índices para transaction
CREATE INDEX idx_transaction_user ON public.transaction(user_id);
CREATE INDEX idx_transaction_date ON public.transaction(transaction_date);
CREATE INDEX idx_transaction_type ON public.transaction(transaction_type_id);
CREATE INDEX idx_transaction_account ON public.transaction(account_id);
CREATE INDEX idx_transaction_jar ON public.transaction(jar_id);
CREATE INDEX idx_transaction_recurring ON public.transaction(parent_recurring_id) WHERE parent_recurring_id IS NOT NULL;
CREATE INDEX idx_transaction_sync ON public.transaction(sync_status);

-- Índices para recurring_transaction
CREATE INDEX idx_recurring_transaction_user ON public.recurring_transaction(user_id);
CREATE INDEX idx_recurring_transaction_next_no_end ON public.recurring_transaction(next_execution_date) 
    WHERE is_active = true AND end_date IS NULL;
CREATE INDEX idx_recurring_transaction_next_with_end ON public.recurring_transaction(next_execution_date, end_date) 
    WHERE is_active = true;

-- Índices para transfer
CREATE INDEX idx_transfer_user ON public.transfer(user_id);
CREATE INDEX idx_transfer_date ON public.transfer(transfer_date);
CREATE INDEX idx_transfer_sync ON public.transfer(sync_status);
CREATE INDEX idx_transfer_accounts ON public.transfer(from_account_id, to_account_id) 
    WHERE transfer_type = 'ACCOUNT_TO_ACCOUNT';
CREATE INDEX idx_transfer_jars ON public.transfer(from_jar_id, to_jar_id) 
    WHERE transfer_type IN ('JAR_TO_JAR', 'PERIOD_ROLLOVER');

-- Índices para financial_goal
CREATE INDEX idx_financial_goal_user ON public.financial_goal(user_id);
CREATE INDEX idx_financial_goal_active ON public.financial_goal(id) WHERE is_active = true;
CREATE INDEX idx_financial_goal_status ON public.financial_goal(status);
CREATE INDEX idx_financial_goal_dates ON public.financial_goal(start_date, target_date);

-- Índices para notification
CREATE INDEX idx_notification_user ON public.notification(user_id);
CREATE INDEX idx_notification_unread ON public.notification(id) WHERE NOT is_read;
CREATE INDEX idx_notification_type ON public.notification(notification_type);
CREATE INDEX idx_notification_entity ON public.notification(related_entity_type, related_entity_id) 
    WHERE related_entity_id IS NOT NULL;

-- Índices para balance_history
CREATE INDEX idx_balance_history_user ON public.balance_history(user_id);
CREATE INDEX idx_balance_history_account ON public.balance_history(account_id) 
    WHERE account_id IS NOT NULL;
CREATE INDEX idx_balance_history_jar ON public.balance_history(jar_id) 
    WHERE jar_id IS NOT NULL;
CREATE INDEX idx_balance_history_reference ON public.balance_history(reference_type, reference_id);

-- #################################################
-- POLÍTICAS RLS
-- #################################################

-- Habilitar RLS en todas las tablas
ALTER TABLE public.currency ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transaction_type ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transaction_medium ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.app_user ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.jar ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.category ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subcategory ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.account_type ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.account ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.jar_balance ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transaction ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.recurring_transaction ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transfer ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.financial_goal ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notification ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.balance_history ENABLE ROW LEVEL SECURITY;

-- Políticas para tablas de catálogo (lectura para usuarios autenticados)
CREATE POLICY "Usuarios autenticados pueden leer" ON public.currency FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Usuarios autenticados pueden leer" ON public.transaction_type FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Usuarios autenticados pueden leer" ON public.transaction_medium FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Usuarios autenticados pueden leer" ON public.jar FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Usuarios autenticados pueden leer" ON public.category FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Usuarios autenticados pueden leer" ON public.subcategory FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Usuarios autenticados pueden leer" ON public.account_type FOR SELECT USING (auth.role() = 'authenticated');

-- Políticas para app_user
CREATE POLICY "Usuarios pueden ver su perfil" ON public.app_user 
    FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Usuarios pueden actualizar su perfil" ON public.app_user 
    FOR UPDATE USING (auth.uid() = id);

-- Políticas para account
CREATE POLICY "Usuarios pueden ver sus cuentas" ON public.account 
    FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Usuarios pueden crear cuentas" ON public.account 
    FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Usuarios pueden actualizar sus cuentas" ON public.account 
    FOR UPDATE USING (auth.uid() = user_id);

-- Políticas para jar_balance
CREATE POLICY "Usuarios pueden ver sus balances" ON public.jar_balance 
    FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Usuarios pueden crear balances" ON public.jar_balance 
    FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Usuarios pueden actualizar sus balances" ON public.jar_balance 
    FOR UPDATE USING (auth.uid() = user_id);

-- Políticas para transaction
CREATE POLICY "Usuarios pueden ver sus transacciones" ON public.transaction 
    FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Usuarios pueden crear transacciones" ON public.transaction 
    FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Usuarios pueden actualizar sus transacciones" ON public.transaction 
    FOR UPDATE USING (auth.uid() = user_id);

-- Políticas para recurring_transaction
CREATE POLICY "Usuarios pueden ver sus transacciones recurrentes" ON public.recurring_transaction 
    FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Usuarios pueden crear transacciones recurrentes" ON public.recurring_transaction 
    FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Usuarios pueden actualizar sus transacciones recurrentes" ON public.recurring_transaction 
    FOR UPDATE USING (auth.uid() = user_id);

-- Políticas para transfer
CREATE POLICY "Usuarios pueden ver sus transferencias" ON public.transfer 
    FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Usuarios pueden crear transferencias" ON public.transfer 
    FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Usuarios pueden actualizar sus transferencias" ON public.transfer 
    FOR UPDATE USING (auth.uid() = user_id);

-- Políticas para financial_goal
CREATE POLICY "Usuarios pueden ver sus metas" ON public.financial_goal 
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Usuarios pueden crear metas" ON public.financial_goal 
    FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Usuarios pueden actualizar sus metas" ON public.financial_goal 
    FOR UPDATE USING (auth.uid() = user_id);

-- Políticas para notification
CREATE POLICY "Usuarios pueden ver sus notificaciones" ON public.notification 
    FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Usuarios pueden actualizar sus notificaciones" ON public.notification 
    FOR UPDATE USING (auth.uid() = user_id);

-- Políticas para balance_history
CREATE POLICY "Usuarios pueden ver su historial" ON public.balance_history 
    FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Usuarios pueden crear registros históricos" ON public.balance_history 
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Add missing RLS policies for category table
CREATE POLICY "Usuarios pueden crear categorías" ON public.category 
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Usuarios pueden actualizar categorías" ON public.category 
    FOR UPDATE USING (auth.role() = 'authenticated');

CREATE POLICY "Usuarios pueden eliminar categorías" ON public.category 
    FOR DELETE USING (auth.role() = 'authenticated');

-- Add missing RLS policies for subcategory table
CREATE POLICY "Usuarios pueden crear subcategorías" ON public.subcategory 
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Usuarios pueden actualizar subcategorías" ON public.subcategory 
    FOR UPDATE USING (auth.role() = 'authenticated');

CREATE POLICY "Usuarios pueden eliminar subcategorías" ON public.subcategory 
    FOR DELETE USING (auth.role() = 'authenticated');

-- #################################################
-- TRIGGERS Y FUNCIONES
-- #################################################

-- Función: Actualizar timestamps de modificación
CREATE OR REPLACE FUNCTION public.update_modified_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.modified_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger: Actualización de timestamps
DO $$ 
DECLARE 
    t text;
BEGIN 
    FOR t IN 
        SELECT table_name 
        FROM information_schema.columns 
        WHERE column_name = 'modified_at' 
        AND table_schema = 'public'
    LOOP
        EXECUTE format('
            CREATE TRIGGER update_modified_timestamp
            BEFORE UPDATE ON public.%I
            FOR EACH ROW
            EXECUTE FUNCTION public.update_modified_timestamp();
        ', t);
    END LOOP;
END;
$$;

-- Función: Validar balance suficiente
CREATE OR REPLACE FUNCTION public.validate_sufficient_balance()
RETURNS TRIGGER AS $$
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
$$ LANGUAGE plpgsql;

-- Trigger: Validación de balance para transacciones
CREATE TRIGGER validate_transaction_balance
    BEFORE INSERT OR UPDATE ON public.transaction
    FOR EACH ROW
    EXECUTE FUNCTION public.validate_sufficient_balance();

-- Trigger: Validación de balance para transferencias
CREATE TRIGGER validate_transfer_balance
    BEFORE INSERT OR UPDATE ON public.transfer
    FOR EACH ROW
    EXECUTE FUNCTION public.validate_sufficient_balance();

-- Función: Actualizar balances
CREATE OR REPLACE FUNCTION public.update_balances()
RETURNS TRIGGER AS $$
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
$$ LANGUAGE plpgsql;

-- Trigger: Actualización de balances para transacciones
CREATE TRIGGER update_balances_on_transaction
    AFTER INSERT ON public.transaction
    FOR EACH ROW
    EXECUTE FUNCTION public.update_balances();

-- Trigger: Actualización de balances para transferencias
CREATE TRIGGER update_balances_on_transfer
    AFTER INSERT ON public.transfer
    FOR EACH ROW
    EXECUTE FUNCTION public.update_balances();

-- Función: Registrar historial de balances
CREATE OR REPLACE FUNCTION public.record_balance_history()
RETURNS TRIGGER AS $$
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
$$ LANGUAGE plpgsql;

-- Trigger: Registro de historial para transacciones
CREATE TRIGGER record_transaction_history
    AFTER INSERT ON public.transaction
    FOR EACH ROW
    EXECUTE FUNCTION public.record_balance_history();

-- Trigger: Registro de historial para transferencias
CREATE TRIGGER record_transfer_history
    AFTER INSERT ON public.transfer
    FOR EACH ROW
    EXECUTE FUNCTION public.record_balance_history();

-- #################################################
-- DATOS INICIALES DEL SISTEMA
-- #################################################

-- Insertar moneda base (MXN)
INSERT INTO public.currency (code, name, symbol, is_system_default)
VALUES ('MXN', 'Peso Mexicano', '$', true)
ON CONFLICT (code) DO NOTHING;

-- Insertar tipos de transacción del sistema
INSERT INTO public.transaction_type (code, name, description, is_system)
VALUES 
    ('INCOME', 'Ingreso', 'Entrada de dinero', true),
    ('EXPENSE', 'Gasto', 'Salida de dinero', true),
    ('TRANSFER', 'Transferencia', 'Movimiento entre cuentas o jarras', true)
ON CONFLICT (code) DO NOTHING;


-- Insertar medios de pago del sistema
INSERT INTO public.transaction_medium (code, name, description, is_system)
VALUES 
    ('CASH', 'Efectivo', 'Pago en efectivo', true),
    ('DEBIT_CARD', 'Tarjeta de Débito', 'Pago con tarjeta de débito', true),
    ('CREDIT_CARD', 'Tarjeta de Crédito', 'Pago con tarjeta de crédito', true),
    ('TRANSFER', 'Transferencia', 'Transferencia bancaria', true),
    ('OTHER', 'Otro', 'Otros medios de pago', true)
ON CONFLICT (code) DO NOTHING;

-- Insertar tipos de cuenta del sistema
INSERT INTO public.account_type (code, name, description, is_system)
VALUES 
    ('CHECKING', 'Cuenta de Cheques', 'Cuenta bancaria principal', true),
    ('SAVINGS', 'Cuenta de Ahorro', 'Cuenta para ahorros', true),
    ('CASH', 'Efectivo', 'Dinero en efectivo', true),
    ('CREDIT_CARD', 'Tarjeta de Crédito', 'Tarjeta de crédito bancaria', true),
    ('INVESTMENT', 'Inversión', 'Cuenta de inversiones', true)
ON CONFLICT (code) DO NOTHING;

-- Insertar jarras del sistema según metodología T. Harv Eker
INSERT INTO public.jar (code, name, description, target_percentage, is_system)
VALUES 
    ('NECESSITIES', 'Necesidades', 'Gastos necesarios y obligatorios', 55, true),
    ('INVESTMENT', 'Inversión a Largo Plazo', 'Inversiones para el futuro', 10, true),
    ('SAVINGS', 'Ahorro', 'Ahorro para emergencias y metas', 10, true),
    ('EDUCATION', 'Educación', 'Desarrollo personal y profesional', 10, true),
    ('PLAY', 'Ocio', 'Entretenimiento y diversión', 10, true),
    ('GIVE', 'Donaciones', 'Ayuda a otros', 5, true)
ON CONFLICT (code) DO NOTHING;

-- #################################################
-- VERIFICACIÓN DE INSTALACIÓN
-- #################################################

DO $$ 
DECLARE
    v_table_count integer;
    v_trigger_count integer;
    v_policy_count integer;
    v_index_count integer;
BEGIN
    -- Verificar tablas
    SELECT count(*) INTO v_table_count
    FROM information_schema.tables
    WHERE table_schema = 'public';

    -- Verificar triggers
    SELECT count(*) INTO v_trigger_count
    FROM information_schema.triggers
    WHERE trigger_schema = 'public';

    -- Verificar políticas RLS
    SELECT count(*) INTO v_policy_count
    FROM pg_policies
    WHERE schemaname = 'public';

    -- Verificar índices
    SELECT count(*) INTO v_index_count
    FROM pg_indexes
    WHERE schemaname = 'public';

    -- Mostrar resumen
    RAISE NOTICE 'Instalación completada:';
    RAISE NOTICE 'Tablas creadas: %', v_table_count;
    RAISE NOTICE 'Triggers instalados: %', v_trigger_count;
    RAISE NOTICE 'Políticas RLS: %', v_policy_count;
    RAISE NOTICE 'Índices creados: %', v_index_count;

    -- Verificar datos iniciales
    IF NOT EXISTS (SELECT 1 FROM public.currency WHERE is_system_default) THEN
        RAISE EXCEPTION 'Error: Moneda base (MXN) no instalada';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM public.jar 
        WHERE is_system 
        HAVING count(*) = 6
    ) THEN
        RAISE EXCEPTION 'Error: Jarras del sistema no instaladas correctamente';
    END IF;

    IF (
        SELECT sum(target_percentage) 
        FROM public.jar 
        WHERE is_system
    ) != 100 THEN
        RAISE EXCEPTION 'Error: Porcentajes de jarras no suman 100%%';
    END IF;

    RAISE NOTICE 'Verificación de datos iniciales completada con éxito';
END $$;

-- #################################################
-- FIN DEL SCRIPT PRINCIPAL
-- #################################################
