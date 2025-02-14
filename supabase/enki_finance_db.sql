--
-- PostgreSQL database dump
--

-- Dumped from database version 15.8
-- Dumped by pg_dump version 17.2

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
-- Name: auth; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA auth;


ALTER SCHEMA auth OWNER TO supabase_admin;

--
-- Name: pg_cron; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_cron WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION pg_cron; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_cron IS 'Job scheduler for PostgreSQL';


--
-- Name: extensions; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA extensions;


ALTER SCHEMA extensions OWNER TO postgres;

--
-- Name: graphql; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA graphql;


ALTER SCHEMA graphql OWNER TO supabase_admin;

--
-- Name: graphql_public; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA graphql_public;


ALTER SCHEMA graphql_public OWNER TO supabase_admin;

--
-- Name: pgbouncer; Type: SCHEMA; Schema: -; Owner: pgbouncer
--

CREATE SCHEMA pgbouncer;


ALTER SCHEMA pgbouncer OWNER TO pgbouncer;

--
-- Name: pgsodium; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA pgsodium;


ALTER SCHEMA pgsodium OWNER TO supabase_admin;

--
-- Name: pgsodium; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgsodium WITH SCHEMA pgsodium;


--
-- Name: EXTENSION pgsodium; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgsodium IS 'Pgsodium is a modern cryptography library for Postgres.';


--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: pg_database_owner
--

COMMENT ON SCHEMA public IS 'Standard public schema - Jar functions migrated to application domain layer';


--
-- Name: realtime; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA realtime;


ALTER SCHEMA realtime OWNER TO supabase_admin;

--
-- Name: storage; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA storage;


ALTER SCHEMA storage OWNER TO supabase_admin;

--
-- Name: supabase_migrations; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA supabase_migrations;


ALTER SCHEMA supabase_migrations OWNER TO postgres;

--
-- Name: vault; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA vault;


ALTER SCHEMA vault OWNER TO supabase_admin;

--
-- Name: pg_graphql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_graphql WITH SCHEMA graphql;


--
-- Name: EXTENSION pg_graphql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_graphql IS 'pg_graphql: GraphQL support';


--
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA extensions;


--
-- Name: EXTENSION pg_stat_statements; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_stat_statements IS 'track planning and execution statistics of all SQL statements executed';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA extensions;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: pgjwt; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgjwt WITH SCHEMA extensions;


--
-- Name: EXTENSION pgjwt; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgjwt IS 'JSON Web Token API for Postgresql';


--
-- Name: supabase_vault; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS supabase_vault WITH SCHEMA vault;


--
-- Name: EXTENSION supabase_vault; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION supabase_vault IS 'Supabase Vault Extension';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA extensions;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: aal_level; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.aal_level AS ENUM (
    'aal1',
    'aal2',
    'aal3'
);


ALTER TYPE auth.aal_level OWNER TO supabase_auth_admin;

--
-- Name: code_challenge_method; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.code_challenge_method AS ENUM (
    's256',
    'plain'
);


ALTER TYPE auth.code_challenge_method OWNER TO supabase_auth_admin;

--
-- Name: factor_status; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.factor_status AS ENUM (
    'unverified',
    'verified'
);


ALTER TYPE auth.factor_status OWNER TO supabase_auth_admin;

--
-- Name: factor_type; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.factor_type AS ENUM (
    'totp',
    'webauthn',
    'phone'
);


ALTER TYPE auth.factor_type OWNER TO supabase_auth_admin;

--
-- Name: one_time_token_type; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.one_time_token_type AS ENUM (
    'confirmation_token',
    'reauthentication_token',
    'recovery_token',
    'email_change_token_new',
    'email_change_token_current',
    'phone_change_token'
);


ALTER TYPE auth.one_time_token_type OWNER TO supabase_auth_admin;

--
-- Name: goal_progress_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.goal_progress_status AS (
	percentage_complete numeric(5,2),
	amount_remaining numeric(15,2),
	days_remaining integer,
	is_on_track boolean,
	required_daily_amount numeric(15,2)
);


ALTER TYPE public.goal_progress_status OWNER TO postgres;

--
-- Name: recurring_process_result; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.recurring_process_result AS (
	transactions_created integer,
	notifications_sent integer,
	errors_encountered integer
);


ALTER TYPE public.recurring_process_result OWNER TO postgres;

--
-- Name: action; Type: TYPE; Schema: realtime; Owner: supabase_admin
--

CREATE TYPE realtime.action AS ENUM (
    'INSERT',
    'UPDATE',
    'DELETE',
    'TRUNCATE',
    'ERROR'
);


ALTER TYPE realtime.action OWNER TO supabase_admin;

--
-- Name: equality_op; Type: TYPE; Schema: realtime; Owner: supabase_admin
--

CREATE TYPE realtime.equality_op AS ENUM (
    'eq',
    'neq',
    'lt',
    'lte',
    'gt',
    'gte',
    'in'
);


ALTER TYPE realtime.equality_op OWNER TO supabase_admin;

--
-- Name: user_defined_filter; Type: TYPE; Schema: realtime; Owner: supabase_admin
--

CREATE TYPE realtime.user_defined_filter AS (
	column_name text,
	op realtime.equality_op,
	value text
);


ALTER TYPE realtime.user_defined_filter OWNER TO supabase_admin;

--
-- Name: wal_column; Type: TYPE; Schema: realtime; Owner: supabase_admin
--

CREATE TYPE realtime.wal_column AS (
	name text,
	type_name text,
	type_oid oid,
	value jsonb,
	is_pkey boolean,
	is_selectable boolean
);


ALTER TYPE realtime.wal_column OWNER TO supabase_admin;

--
-- Name: wal_rls; Type: TYPE; Schema: realtime; Owner: supabase_admin
--

CREATE TYPE realtime.wal_rls AS (
	wal jsonb,
	is_rls_enabled boolean,
	subscription_ids uuid[],
	errors text[]
);


ALTER TYPE realtime.wal_rls OWNER TO supabase_admin;

--
-- Name: change_password_by_email(text, text); Type: FUNCTION; Schema: auth; Owner: postgres
--

CREATE FUNCTION auth.change_password_by_email(user_email text, new_password text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
    UPDATE auth.users
    SET 
        encrypted_password = crypt(new_password, gen_salt('bf')),
        updated_at = now()
    WHERE email = user_email;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'User with email % not found', user_email;
    END IF;
END;
$$;


ALTER FUNCTION auth.change_password_by_email(user_email text, new_password text) OWNER TO postgres;

--
-- Name: email(); Type: FUNCTION; Schema: auth; Owner: supabase_auth_admin
--

CREATE FUNCTION auth.email() RETURNS text
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.email', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'email')
  )::text
$$;


ALTER FUNCTION auth.email() OWNER TO supabase_auth_admin;

--
-- Name: FUNCTION email(); Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON FUNCTION auth.email() IS 'Deprecated. Use auth.jwt() -> ''email'' instead.';


--
-- Name: jwt(); Type: FUNCTION; Schema: auth; Owner: supabase_auth_admin
--

CREATE FUNCTION auth.jwt() RETURNS jsonb
    LANGUAGE sql STABLE
    AS $$
  select 
    coalesce(
        nullif(current_setting('request.jwt.claim', true), ''),
        nullif(current_setting('request.jwt.claims', true), '')
    )::jsonb
$$;


ALTER FUNCTION auth.jwt() OWNER TO supabase_auth_admin;

--
-- Name: role(); Type: FUNCTION; Schema: auth; Owner: supabase_auth_admin
--

CREATE FUNCTION auth.role() RETURNS text
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.role', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'role')
  )::text
$$;


ALTER FUNCTION auth.role() OWNER TO supabase_auth_admin;

--
-- Name: FUNCTION role(); Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON FUNCTION auth.role() IS 'Deprecated. Use auth.jwt() -> ''role'' instead.';


--
-- Name: uid(); Type: FUNCTION; Schema: auth; Owner: supabase_auth_admin
--

CREATE FUNCTION auth.uid() RETURNS uuid
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.sub', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'sub')
  )::uuid
$$;


ALTER FUNCTION auth.uid() OWNER TO supabase_auth_admin;

--
-- Name: FUNCTION uid(); Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON FUNCTION auth.uid() IS 'Deprecated. Use auth.jwt() -> ''sub'' instead.';


--
-- Name: grant_pg_cron_access(); Type: FUNCTION; Schema: extensions; Owner: postgres
--

CREATE FUNCTION extensions.grant_pg_cron_access() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF EXISTS (
    SELECT
    FROM pg_event_trigger_ddl_commands() AS ev
    JOIN pg_extension AS ext
    ON ev.objid = ext.oid
    WHERE ext.extname = 'pg_cron'
  )
  THEN
    grant usage on schema cron to postgres with grant option;

    alter default privileges in schema cron grant all on tables to postgres with grant option;
    alter default privileges in schema cron grant all on functions to postgres with grant option;
    alter default privileges in schema cron grant all on sequences to postgres with grant option;

    alter default privileges for user supabase_admin in schema cron grant all
        on sequences to postgres with grant option;
    alter default privileges for user supabase_admin in schema cron grant all
        on tables to postgres with grant option;
    alter default privileges for user supabase_admin in schema cron grant all
        on functions to postgres with grant option;

    grant all privileges on all tables in schema cron to postgres with grant option;
    revoke all on table cron.job from postgres;
    grant select on table cron.job to postgres with grant option;
  END IF;
END;
$$;


ALTER FUNCTION extensions.grant_pg_cron_access() OWNER TO postgres;

--
-- Name: FUNCTION grant_pg_cron_access(); Type: COMMENT; Schema: extensions; Owner: postgres
--

COMMENT ON FUNCTION extensions.grant_pg_cron_access() IS 'Grants access to pg_cron';


--
-- Name: grant_pg_graphql_access(); Type: FUNCTION; Schema: extensions; Owner: supabase_admin
--

CREATE FUNCTION extensions.grant_pg_graphql_access() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $_$
DECLARE
    func_is_graphql_resolve bool;
BEGIN
    func_is_graphql_resolve = (
        SELECT n.proname = 'resolve'
        FROM pg_event_trigger_ddl_commands() AS ev
        LEFT JOIN pg_catalog.pg_proc AS n
        ON ev.objid = n.oid
    );

    IF func_is_graphql_resolve
    THEN
        -- Update public wrapper to pass all arguments through to the pg_graphql resolve func
        DROP FUNCTION IF EXISTS graphql_public.graphql;
        create or replace function graphql_public.graphql(
            "operationName" text default null,
            query text default null,
            variables jsonb default null,
            extensions jsonb default null
        )
            returns jsonb
            language sql
        as $$
            select graphql.resolve(
                query := query,
                variables := coalesce(variables, '{}'),
                "operationName" := "operationName",
                extensions := extensions
            );
        $$;

        -- This hook executes when `graphql.resolve` is created. That is not necessarily the last
        -- function in the extension so we need to grant permissions on existing entities AND
        -- update default permissions to any others that are created after `graphql.resolve`
        grant usage on schema graphql to postgres, anon, authenticated, service_role;
        grant select on all tables in schema graphql to postgres, anon, authenticated, service_role;
        grant execute on all functions in schema graphql to postgres, anon, authenticated, service_role;
        grant all on all sequences in schema graphql to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on tables to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on functions to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on sequences to postgres, anon, authenticated, service_role;

        -- Allow postgres role to allow granting usage on graphql and graphql_public schemas to custom roles
        grant usage on schema graphql_public to postgres with grant option;
        grant usage on schema graphql to postgres with grant option;
    END IF;

END;
$_$;


ALTER FUNCTION extensions.grant_pg_graphql_access() OWNER TO supabase_admin;

--
-- Name: FUNCTION grant_pg_graphql_access(); Type: COMMENT; Schema: extensions; Owner: supabase_admin
--

COMMENT ON FUNCTION extensions.grant_pg_graphql_access() IS 'Grants access to pg_graphql';


--
-- Name: grant_pg_net_access(); Type: FUNCTION; Schema: extensions; Owner: postgres
--

CREATE FUNCTION extensions.grant_pg_net_access() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM pg_event_trigger_ddl_commands() AS ev
    JOIN pg_extension AS ext
    ON ev.objid = ext.oid
    WHERE ext.extname = 'pg_net'
  )
  THEN
    IF NOT EXISTS (
      SELECT 1
      FROM pg_roles
      WHERE rolname = 'supabase_functions_admin'
    )
    THEN
      CREATE USER supabase_functions_admin NOINHERIT CREATEROLE LOGIN NOREPLICATION;
    END IF;

    GRANT USAGE ON SCHEMA net TO supabase_functions_admin, postgres, anon, authenticated, service_role;

    ALTER function net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) SECURITY DEFINER;
    ALTER function net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) SECURITY DEFINER;

    ALTER function net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) SET search_path = net;
    ALTER function net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) SET search_path = net;

    REVOKE ALL ON FUNCTION net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) FROM PUBLIC;
    REVOKE ALL ON FUNCTION net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) FROM PUBLIC;

    GRANT EXECUTE ON FUNCTION net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) TO supabase_functions_admin, postgres, anon, authenticated, service_role;
    GRANT EXECUTE ON FUNCTION net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) TO supabase_functions_admin, postgres, anon, authenticated, service_role;
  END IF;
END;
$$;


ALTER FUNCTION extensions.grant_pg_net_access() OWNER TO postgres;

--
-- Name: FUNCTION grant_pg_net_access(); Type: COMMENT; Schema: extensions; Owner: postgres
--

COMMENT ON FUNCTION extensions.grant_pg_net_access() IS 'Grants access to pg_net';


--
-- Name: pgrst_ddl_watch(); Type: FUNCTION; Schema: extensions; Owner: supabase_admin
--

CREATE FUNCTION extensions.pgrst_ddl_watch() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  cmd record;
BEGIN
  FOR cmd IN SELECT * FROM pg_event_trigger_ddl_commands()
  LOOP
    IF cmd.command_tag IN (
      'CREATE SCHEMA', 'ALTER SCHEMA'
    , 'CREATE TABLE', 'CREATE TABLE AS', 'SELECT INTO', 'ALTER TABLE'
    , 'CREATE FOREIGN TABLE', 'ALTER FOREIGN TABLE'
    , 'CREATE VIEW', 'ALTER VIEW'
    , 'CREATE MATERIALIZED VIEW', 'ALTER MATERIALIZED VIEW'
    , 'CREATE FUNCTION', 'ALTER FUNCTION'
    , 'CREATE TRIGGER'
    , 'CREATE TYPE', 'ALTER TYPE'
    , 'CREATE RULE'
    , 'COMMENT'
    )
    -- don't notify in case of CREATE TEMP table or other objects created on pg_temp
    AND cmd.schema_name is distinct from 'pg_temp'
    THEN
      NOTIFY pgrst, 'reload schema';
    END IF;
  END LOOP;
END; $$;


ALTER FUNCTION extensions.pgrst_ddl_watch() OWNER TO supabase_admin;

--
-- Name: pgrst_drop_watch(); Type: FUNCTION; Schema: extensions; Owner: supabase_admin
--

CREATE FUNCTION extensions.pgrst_drop_watch() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  obj record;
BEGIN
  FOR obj IN SELECT * FROM pg_event_trigger_dropped_objects()
  LOOP
    IF obj.object_type IN (
      'schema'
    , 'table'
    , 'foreign table'
    , 'view'
    , 'materialized view'
    , 'function'
    , 'trigger'
    , 'type'
    , 'rule'
    )
    AND obj.is_temporary IS false -- no pg_temp objects
    THEN
      NOTIFY pgrst, 'reload schema';
    END IF;
  END LOOP;
END; $$;


ALTER FUNCTION extensions.pgrst_drop_watch() OWNER TO supabase_admin;

--
-- Name: set_graphql_placeholder(); Type: FUNCTION; Schema: extensions; Owner: supabase_admin
--

CREATE FUNCTION extensions.set_graphql_placeholder() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $_$
    DECLARE
    graphql_is_dropped bool;
    BEGIN
    graphql_is_dropped = (
        SELECT ev.schema_name = 'graphql_public'
        FROM pg_event_trigger_dropped_objects() AS ev
        WHERE ev.schema_name = 'graphql_public'
    );

    IF graphql_is_dropped
    THEN
        create or replace function graphql_public.graphql(
            "operationName" text default null,
            query text default null,
            variables jsonb default null,
            extensions jsonb default null
        )
            returns jsonb
            language plpgsql
        as $$
            DECLARE
                server_version float;
            BEGIN
                server_version = (SELECT (SPLIT_PART((select version()), ' ', 2))::float);

                IF server_version >= 14 THEN
                    RETURN jsonb_build_object(
                        'errors', jsonb_build_array(
                            jsonb_build_object(
                                'message', 'pg_graphql extension is not enabled.'
                            )
                        )
                    );
                ELSE
                    RETURN jsonb_build_object(
                        'errors', jsonb_build_array(
                            jsonb_build_object(
                                'message', 'pg_graphql is only available on projects running Postgres 14 onwards.'
                            )
                        )
                    );
                END IF;
            END;
        $$;
    END IF;

    END;
$_$;


ALTER FUNCTION extensions.set_graphql_placeholder() OWNER TO supabase_admin;

--
-- Name: FUNCTION set_graphql_placeholder(); Type: COMMENT; Schema: extensions; Owner: supabase_admin
--

COMMENT ON FUNCTION extensions.set_graphql_placeholder() IS 'Reintroduces placeholder function for graphql_public.graphql';


--
-- Name: get_auth(text); Type: FUNCTION; Schema: pgbouncer; Owner: postgres
--

CREATE FUNCTION pgbouncer.get_auth(p_usename text) RETURNS TABLE(username text, password text)
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
    RAISE WARNING 'PgBouncer auth request: %', p_usename;

    RETURN QUERY
    SELECT usename::TEXT, passwd::TEXT FROM pg_catalog.pg_shadow
    WHERE usename = p_usename;
END;
$$;


ALTER FUNCTION pgbouncer.get_auth(p_usename text) OWNER TO postgres;

--
-- Name: archive_completed_goals(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.archive_completed_goals(p_days_threshold integer DEFAULT 30) RETURNS integer
    LANGUAGE plpgsql
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


ALTER FUNCTION public.archive_completed_goals(p_days_threshold integer) OWNER TO postgres;

--
-- Name: calculate_goal_progress(numeric, numeric, date, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.calculate_goal_progress(p_current_amount numeric, p_target_amount numeric, p_start_date date, p_target_date date) RETURNS public.goal_progress_status
    LANGUAGE plpgsql
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


ALTER FUNCTION public.calculate_goal_progress(p_current_amount numeric, p_target_amount numeric, p_start_date date, p_target_date date) OWNER TO postgres;

--
-- Name: calculate_next_cut_off_date(integer, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.calculate_next_cut_off_date(p_cut_off_day integer, p_from_date date DEFAULT CURRENT_DATE) RETURNS date
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


ALTER FUNCTION public.calculate_next_cut_off_date(p_cut_off_day integer, p_from_date date) OWNER TO postgres;

--
-- Name: calculate_next_execution_date(character varying, date, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.calculate_next_execution_date(p_frequency character varying, p_start_date date, p_last_execution date DEFAULT NULL::date) RETURNS date
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


ALTER FUNCTION public.calculate_next_execution_date(p_frequency character varying, p_start_date date, p_last_execution date) OWNER TO postgres;

--
-- Name: calculate_next_payment_date(integer, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.calculate_next_payment_date(p_payment_day integer, p_cut_off_date date) RETURNS date
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


ALTER FUNCTION public.calculate_next_payment_date(p_payment_day integer, p_cut_off_date date) OWNER TO postgres;

--
-- Name: export_transactions_to_excel(uuid, date, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.export_transactions_to_excel(p_user_id uuid, p_start_date date, p_end_date date) RETURNS TABLE(transaction_date date, transaction_type text, category text, subcategory text, amount numeric, account_name text, jar_name text, description text)
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


ALTER FUNCTION public.export_transactions_to_excel(p_user_id uuid, p_start_date date, p_end_date date) OWNER TO postgres;

--
-- Name: generate_credit_card_statement(uuid, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.generate_credit_card_statement(p_credit_card_id uuid, p_statement_date date DEFAULT CURRENT_DATE) RETURNS uuid
    LANGUAGE plpgsql
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


ALTER FUNCTION public.generate_credit_card_statement(p_credit_card_id uuid, p_statement_date date) OWNER TO postgres;

--
-- Name: get_credit_card_statements(uuid, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_credit_card_statements(p_account_id uuid, p_months integer DEFAULT 12) RETURNS TABLE(statement_date date, cut_off_date date, due_date date, previous_balance numeric, purchases_amount numeric, payments_amount numeric, interests_amount numeric, ending_balance numeric, minimum_payment numeric, status text)
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
    FROM public.credit_card_statement cs
    JOIN public.credit_card_details cc ON cc.id = cs.credit_card_id
    WHERE cc.account_id = p_account_id
    AND cs.statement_date >= CURRENT_DATE - (p_months || ' months')::interval
    ORDER BY cs.statement_date DESC;
END;
$$;


ALTER FUNCTION public.get_credit_card_statements(p_account_id uuid, p_months integer) OWNER TO postgres;

--
-- Name: get_transfer_history(uuid, date, date, text, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_transfer_history(p_user_id uuid, p_start_date date DEFAULT NULL::date, p_end_date date DEFAULT NULL::date, p_transfer_type text DEFAULT NULL::text, p_limit integer DEFAULT 100) RETURNS TABLE(transfer_id uuid, transfer_date date, transfer_type text, source_name text, target_name text, amount numeric, converted_amount numeric, description text)
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


ALTER FUNCTION public.get_transfer_history(p_user_id uuid, p_start_date date, p_end_date date, p_transfer_type text, p_limit integer) OWNER TO postgres;

--
-- Name: get_upcoming_recurring_transactions(uuid, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_upcoming_recurring_transactions(p_user_id uuid, p_days integer DEFAULT 7) RETURNS TABLE(id uuid, name text, next_execution_date date, amount numeric, description text, days_until integer)
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
    FROM public.recurring_transaction r
    WHERE r.user_id = p_user_id
    AND r.is_active = true
    AND r.next_execution_date <= CURRENT_DATE + p_days
    ORDER BY r.next_execution_date;
END;
$$;


ALTER FUNCTION public.get_upcoming_recurring_transactions(p_user_id uuid, p_days integer) OWNER TO postgres;

--
-- Name: handle_new_user(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.handle_new_user() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
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


ALTER FUNCTION public.handle_new_user() OWNER TO postgres;

--
-- Name: notify_credit_card_events(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.notify_credit_card_events() RETURNS void
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


ALTER FUNCTION public.notify_credit_card_events() OWNER TO postgres;

--
-- Name: notify_transfer(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.notify_transfer() RETURNS trigger
    LANGUAGE plpgsql
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


ALTER FUNCTION public.notify_transfer() OWNER TO postgres;

--
-- Name: process_recurring_transactions(date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.process_recurring_transactions(p_date date DEFAULT CURRENT_DATE) RETURNS public.recurring_process_result
    LANGUAGE plpgsql
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


ALTER FUNCTION public.process_recurring_transactions(p_date date) OWNER TO postgres;

--
-- Name: reactivate_recurring_transaction(uuid, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.reactivate_recurring_transaction(p_transaction_id uuid, p_new_start_date date DEFAULT CURRENT_DATE) RETURNS void
    LANGUAGE plpgsql
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


ALTER FUNCTION public.reactivate_recurring_transaction(p_transaction_id uuid, p_new_start_date date) OWNER TO postgres;

--
-- Name: record_balance_history(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.record_balance_history() RETURNS trigger
    LANGUAGE plpgsql
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


ALTER FUNCTION public.record_balance_history() OWNER TO postgres;

--
-- Name: remove_transaction_tag(uuid, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.remove_transaction_tag(p_transaction_id uuid, p_tag text) RETURNS void
    LANGUAGE plpgsql
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


ALTER FUNCTION public.remove_transaction_tag(p_transaction_id uuid, p_tag text) OWNER TO postgres;

--
-- Name: search_transactions_by_notes(uuid, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.search_transactions_by_notes(p_user_id uuid, p_search_text text) RETURNS TABLE(id uuid, transaction_date date, description text, amount numeric, tags jsonb, notes text)
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
    FROM public.transaction t
    WHERE t.user_id = p_user_id
    AND to_tsvector('spanish', COALESCE(t.notes, '')) @@ to_tsquery('spanish', p_search_text)
    ORDER BY t.transaction_date DESC;
END;
$$;


ALTER FUNCTION public.search_transactions_by_notes(p_user_id uuid, p_search_text text) OWNER TO postgres;

--
-- Name: search_transactions_by_tags(uuid, text[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.search_transactions_by_tags(p_user_id uuid, p_tags text[]) RETURNS TABLE(id uuid, transaction_date date, description text, amount numeric, tags jsonb, notes text)
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
    FROM public.transaction t
    WHERE t.user_id = p_user_id
    AND t.tags @> jsonb_array_to_jsonb(p_tags::jsonb[])
    ORDER BY t.transaction_date DESC;
END;
$$;


ALTER FUNCTION public.search_transactions_by_tags(p_user_id uuid, p_tags text[]) OWNER TO postgres;

--
-- Name: track_interest_rate_changes(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.track_interest_rate_changes() RETURNS trigger
    LANGUAGE plpgsql
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


ALTER FUNCTION public.track_interest_rate_changes() OWNER TO postgres;

--
-- Name: update_installment_purchases(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_installment_purchases() RETURNS void
    LANGUAGE plpgsql
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


ALTER FUNCTION public.update_installment_purchases() OWNER TO postgres;

--
-- Name: update_modified_timestamp(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_modified_timestamp() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.modified_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_modified_timestamp() OWNER TO postgres;

--
-- Name: validate_recurring_transaction(uuid, numeric, uuid, uuid, uuid); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.validate_recurring_transaction(p_user_id uuid, p_amount numeric, p_transaction_type_id uuid, p_account_id uuid, p_jar_id uuid DEFAULT NULL::uuid) RETURNS boolean
    LANGUAGE plpgsql
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


ALTER FUNCTION public.validate_recurring_transaction(p_user_id uuid, p_amount numeric, p_transaction_type_id uuid, p_account_id uuid, p_jar_id uuid) OWNER TO postgres;

--
-- Name: apply_rls(jsonb, integer); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer DEFAULT (1024 * 1024)) RETURNS SETOF realtime.wal_rls
    LANGUAGE plpgsql
    AS $$
declare
-- Regclass of the table e.g. public.notes
entity_ regclass = (quote_ident(wal ->> 'schema') || '.' || quote_ident(wal ->> 'table'))::regclass;

-- I, U, D, T: insert, update ...
action realtime.action = (
    case wal ->> 'action'
        when 'I' then 'INSERT'
        when 'U' then 'UPDATE'
        when 'D' then 'DELETE'
        else 'ERROR'
    end
);

-- Is row level security enabled for the table
is_rls_enabled bool = relrowsecurity from pg_class where oid = entity_;

subscriptions realtime.subscription[] = array_agg(subs)
    from
        realtime.subscription subs
    where
        subs.entity = entity_;

-- Subscription vars
roles regrole[] = array_agg(distinct us.claims_role::text)
    from
        unnest(subscriptions) us;

working_role regrole;
claimed_role regrole;
claims jsonb;

subscription_id uuid;
subscription_has_access bool;
visible_to_subscription_ids uuid[] = '{}';

-- structured info for wal's columns
columns realtime.wal_column[];
-- previous identity values for update/delete
old_columns realtime.wal_column[];

error_record_exceeds_max_size boolean = octet_length(wal::text) > max_record_bytes;

-- Primary jsonb output for record
output jsonb;

begin
perform set_config('role', null, true);

columns =
    array_agg(
        (
            x->>'name',
            x->>'type',
            x->>'typeoid',
            realtime.cast(
                (x->'value') #>> '{}',
                coalesce(
                    (x->>'typeoid')::regtype, -- null when wal2json version <= 2.4
                    (x->>'type')::regtype
                )
            ),
            (pks ->> 'name') is not null,
            true
        )::realtime.wal_column
    )
    from
        jsonb_array_elements(wal -> 'columns') x
        left join jsonb_array_elements(wal -> 'pk') pks
            on (x ->> 'name') = (pks ->> 'name');

old_columns =
    array_agg(
        (
            x->>'name',
            x->>'type',
            x->>'typeoid',
            realtime.cast(
                (x->'value') #>> '{}',
                coalesce(
                    (x->>'typeoid')::regtype, -- null when wal2json version <= 2.4
                    (x->>'type')::regtype
                )
            ),
            (pks ->> 'name') is not null,
            true
        )::realtime.wal_column
    )
    from
        jsonb_array_elements(wal -> 'identity') x
        left join jsonb_array_elements(wal -> 'pk') pks
            on (x ->> 'name') = (pks ->> 'name');

for working_role in select * from unnest(roles) loop

    -- Update `is_selectable` for columns and old_columns
    columns =
        array_agg(
            (
                c.name,
                c.type_name,
                c.type_oid,
                c.value,
                c.is_pkey,
                pg_catalog.has_column_privilege(working_role, entity_, c.name, 'SELECT')
            )::realtime.wal_column
        )
        from
            unnest(columns) c;

    old_columns =
            array_agg(
                (
                    c.name,
                    c.type_name,
                    c.type_oid,
                    c.value,
                    c.is_pkey,
                    pg_catalog.has_column_privilege(working_role, entity_, c.name, 'SELECT')
                )::realtime.wal_column
            )
            from
                unnest(old_columns) c;

    if action <> 'DELETE' and count(1) = 0 from unnest(columns) c where c.is_pkey then
        return next (
            jsonb_build_object(
                'schema', wal ->> 'schema',
                'table', wal ->> 'table',
                'type', action
            ),
            is_rls_enabled,
            -- subscriptions is already filtered by entity
            (select array_agg(s.subscription_id) from unnest(subscriptions) as s where claims_role = working_role),
            array['Error 400: Bad Request, no primary key']
        )::realtime.wal_rls;

    -- The claims role does not have SELECT permission to the primary key of entity
    elsif action <> 'DELETE' and sum(c.is_selectable::int) <> count(1) from unnest(columns) c where c.is_pkey then
        return next (
            jsonb_build_object(
                'schema', wal ->> 'schema',
                'table', wal ->> 'table',
                'type', action
            ),
            is_rls_enabled,
            (select array_agg(s.subscription_id) from unnest(subscriptions) as s where claims_role = working_role),
            array['Error 401: Unauthorized']
        )::realtime.wal_rls;

    else
        output = jsonb_build_object(
            'schema', wal ->> 'schema',
            'table', wal ->> 'table',
            'type', action,
            'commit_timestamp', to_char(
                ((wal ->> 'timestamp')::timestamptz at time zone 'utc'),
                'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"'
            ),
            'columns', (
                select
                    jsonb_agg(
                        jsonb_build_object(
                            'name', pa.attname,
                            'type', pt.typname
                        )
                        order by pa.attnum asc
                    )
                from
                    pg_attribute pa
                    join pg_type pt
                        on pa.atttypid = pt.oid
                where
                    attrelid = entity_
                    and attnum > 0
                    and pg_catalog.has_column_privilege(working_role, entity_, pa.attname, 'SELECT')
            )
        )
        -- Add "record" key for insert and update
        || case
            when action in ('INSERT', 'UPDATE') then
                jsonb_build_object(
                    'record',
                    (
                        select
                            jsonb_object_agg(
                                -- if unchanged toast, get column name and value from old record
                                coalesce((c).name, (oc).name),
                                case
                                    when (c).name is null then (oc).value
                                    else (c).value
                                end
                            )
                        from
                            unnest(columns) c
                            full outer join unnest(old_columns) oc
                                on (c).name = (oc).name
                        where
                            coalesce((c).is_selectable, (oc).is_selectable)
                            and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                    )
                )
            else '{}'::jsonb
        end
        -- Add "old_record" key for update and delete
        || case
            when action = 'UPDATE' then
                jsonb_build_object(
                        'old_record',
                        (
                            select jsonb_object_agg((c).name, (c).value)
                            from unnest(old_columns) c
                            where
                                (c).is_selectable
                                and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                        )
                    )
            when action = 'DELETE' then
                jsonb_build_object(
                    'old_record',
                    (
                        select jsonb_object_agg((c).name, (c).value)
                        from unnest(old_columns) c
                        where
                            (c).is_selectable
                            and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                            and ( not is_rls_enabled or (c).is_pkey ) -- if RLS enabled, we can't secure deletes so filter to pkey
                    )
                )
            else '{}'::jsonb
        end;

        -- Create the prepared statement
        if is_rls_enabled and action <> 'DELETE' then
            if (select 1 from pg_prepared_statements where name = 'walrus_rls_stmt' limit 1) > 0 then
                deallocate walrus_rls_stmt;
            end if;
            execute realtime.build_prepared_statement_sql('walrus_rls_stmt', entity_, columns);
        end if;

        visible_to_subscription_ids = '{}';

        for subscription_id, claims in (
                select
                    subs.subscription_id,
                    subs.claims
                from
                    unnest(subscriptions) subs
                where
                    subs.entity = entity_
                    and subs.claims_role = working_role
                    and (
                        realtime.is_visible_through_filters(columns, subs.filters)
                        or (
                          action = 'DELETE'
                          and realtime.is_visible_through_filters(old_columns, subs.filters)
                        )
                    )
        ) loop

            if not is_rls_enabled or action = 'DELETE' then
                visible_to_subscription_ids = visible_to_subscription_ids || subscription_id;
            else
                -- Check if RLS allows the role to see the record
                perform
                    -- Trim leading and trailing quotes from working_role because set_config
                    -- doesn't recognize the role as valid if they are included
                    set_config('role', trim(both '"' from working_role::text), true),
                    set_config('request.jwt.claims', claims::text, true);

                execute 'execute walrus_rls_stmt' into subscription_has_access;

                if subscription_has_access then
                    visible_to_subscription_ids = visible_to_subscription_ids || subscription_id;
                end if;
            end if;
        end loop;

        perform set_config('role', null, true);

        return next (
            output,
            is_rls_enabled,
            visible_to_subscription_ids,
            case
                when error_record_exceeds_max_size then array['Error 413: Payload Too Large']
                else '{}'
            end
        )::realtime.wal_rls;

    end if;
end loop;

perform set_config('role', null, true);
end;
$$;


ALTER FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) OWNER TO supabase_admin;

--
-- Name: broadcast_changes(text, text, text, text, text, record, record, text); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.broadcast_changes(topic_name text, event_name text, operation text, table_name text, table_schema text, new record, old record, level text DEFAULT 'ROW'::text) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    -- Declare a variable to hold the JSONB representation of the row
    row_data jsonb := '{}'::jsonb;
BEGIN
    IF level = 'STATEMENT' THEN
        RAISE EXCEPTION 'function can only be triggered for each row, not for each statement';
    END IF;
    -- Check the operation type and handle accordingly
    IF operation = 'INSERT' OR operation = 'UPDATE' OR operation = 'DELETE' THEN
        row_data := jsonb_build_object('old_record', OLD, 'record', NEW, 'operation', operation, 'table', table_name, 'schema', table_schema);
        PERFORM realtime.send (row_data, event_name, topic_name);
    ELSE
        RAISE EXCEPTION 'Unexpected operation type: %', operation;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Failed to process the row: %', SQLERRM;
END;

$$;


ALTER FUNCTION realtime.broadcast_changes(topic_name text, event_name text, operation text, table_name text, table_schema text, new record, old record, level text) OWNER TO supabase_admin;

--
-- Name: build_prepared_statement_sql(text, regclass, realtime.wal_column[]); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) RETURNS text
    LANGUAGE sql
    AS $$
      /*
      Builds a sql string that, if executed, creates a prepared statement to
      tests retrive a row from *entity* by its primary key columns.
      Example
          select realtime.build_prepared_statement_sql('public.notes', '{"id"}'::text[], '{"bigint"}'::text[])
      */
          select
      'prepare ' || prepared_statement_name || ' as
          select
              exists(
                  select
                      1
                  from
                      ' || entity || '
                  where
                      ' || string_agg(quote_ident(pkc.name) || '=' || quote_nullable(pkc.value #>> '{}') , ' and ') || '
              )'
          from
              unnest(columns) pkc
          where
              pkc.is_pkey
          group by
              entity
      $$;


ALTER FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) OWNER TO supabase_admin;

--
-- Name: cast(text, regtype); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime."cast"(val text, type_ regtype) RETURNS jsonb
    LANGUAGE plpgsql IMMUTABLE
    AS $$
    declare
      res jsonb;
    begin
      execute format('select to_jsonb(%L::'|| type_::text || ')', val)  into res;
      return res;
    end
    $$;


ALTER FUNCTION realtime."cast"(val text, type_ regtype) OWNER TO supabase_admin;

--
-- Name: check_equality_op(realtime.equality_op, regtype, text, text); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
      /*
      Casts *val_1* and *val_2* as type *type_* and check the *op* condition for truthiness
      */
      declare
          op_symbol text = (
              case
                  when op = 'eq' then '='
                  when op = 'neq' then '!='
                  when op = 'lt' then '<'
                  when op = 'lte' then '<='
                  when op = 'gt' then '>'
                  when op = 'gte' then '>='
                  when op = 'in' then '= any'
                  else 'UNKNOWN OP'
              end
          );
          res boolean;
      begin
          execute format(
              'select %L::'|| type_::text || ' ' || op_symbol
              || ' ( %L::'
              || (
                  case
                      when op = 'in' then type_::text || '[]'
                      else type_::text end
              )
              || ')', val_1, val_2) into res;
          return res;
      end;
      $$;


ALTER FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) OWNER TO supabase_admin;

--
-- Name: is_visible_through_filters(realtime.wal_column[], realtime.user_defined_filter[]); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) RETURNS boolean
    LANGUAGE sql IMMUTABLE
    AS $_$
    /*
    Should the record be visible (true) or filtered out (false) after *filters* are applied
    */
        select
            -- Default to allowed when no filters present
            $2 is null -- no filters. this should not happen because subscriptions has a default
            or array_length($2, 1) is null -- array length of an empty array is null
            or bool_and(
                coalesce(
                    realtime.check_equality_op(
                        op:=f.op,
                        type_:=coalesce(
                            col.type_oid::regtype, -- null when wal2json version <= 2.4
                            col.type_name::regtype
                        ),
                        -- cast jsonb to text
                        val_1:=col.value #>> '{}',
                        val_2:=f.value
                    ),
                    false -- if null, filter does not match
                )
            )
        from
            unnest(filters) f
            join unnest(columns) col
                on f.column_name = col.name;
    $_$;


ALTER FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) OWNER TO supabase_admin;

--
-- Name: list_changes(name, name, integer, integer); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) RETURNS SETOF realtime.wal_rls
    LANGUAGE sql
    SET log_min_messages TO 'fatal'
    AS $$
      with pub as (
        select
          concat_ws(
            ',',
            case when bool_or(pubinsert) then 'insert' else null end,
            case when bool_or(pubupdate) then 'update' else null end,
            case when bool_or(pubdelete) then 'delete' else null end
          ) as w2j_actions,
          coalesce(
            string_agg(
              realtime.quote_wal2json(format('%I.%I', schemaname, tablename)::regclass),
              ','
            ) filter (where ppt.tablename is not null and ppt.tablename not like '% %'),
            ''
          ) w2j_add_tables
        from
          pg_publication pp
          left join pg_publication_tables ppt
            on pp.pubname = ppt.pubname
        where
          pp.pubname = publication
        group by
          pp.pubname
        limit 1
      ),
      w2j as (
        select
          x.*, pub.w2j_add_tables
        from
          pub,
          pg_logical_slot_get_changes(
            slot_name, null, max_changes,
            'include-pk', 'true',
            'include-transaction', 'false',
            'include-timestamp', 'true',
            'include-type-oids', 'true',
            'format-version', '2',
            'actions', pub.w2j_actions,
            'add-tables', pub.w2j_add_tables
          ) x
      )
      select
        xyz.wal,
        xyz.is_rls_enabled,
        xyz.subscription_ids,
        xyz.errors
      from
        w2j,
        realtime.apply_rls(
          wal := w2j.data::jsonb,
          max_record_bytes := max_record_bytes
        ) xyz(wal, is_rls_enabled, subscription_ids, errors)
      where
        w2j.w2j_add_tables <> ''
        and xyz.subscription_ids[1] is not null
    $$;


ALTER FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) OWNER TO supabase_admin;

--
-- Name: quote_wal2json(regclass); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.quote_wal2json(entity regclass) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $$
      select
        (
          select string_agg('' || ch,'')
          from unnest(string_to_array(nsp.nspname::text, null)) with ordinality x(ch, idx)
          where
            not (x.idx = 1 and x.ch = '"')
            and not (
              x.idx = array_length(string_to_array(nsp.nspname::text, null), 1)
              and x.ch = '"'
            )
        )
        || '.'
        || (
          select string_agg('' || ch,'')
          from unnest(string_to_array(pc.relname::text, null)) with ordinality x(ch, idx)
          where
            not (x.idx = 1 and x.ch = '"')
            and not (
              x.idx = array_length(string_to_array(nsp.nspname::text, null), 1)
              and x.ch = '"'
            )
          )
      from
        pg_class pc
        join pg_namespace nsp
          on pc.relnamespace = nsp.oid
      where
        pc.oid = entity
    $$;


ALTER FUNCTION realtime.quote_wal2json(entity regclass) OWNER TO supabase_admin;

--
-- Name: send(jsonb, text, text, boolean); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.send(payload jsonb, event text, topic text, private boolean DEFAULT true) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  BEGIN
    -- Set the topic configuration
    EXECUTE format('SET LOCAL realtime.topic TO %L', topic);

    -- Attempt to insert the message
    INSERT INTO realtime.messages (payload, event, topic, private, extension)
    VALUES (payload, event, topic, private, 'broadcast');
  EXCEPTION
    WHEN OTHERS THEN
      -- Capture and notify the error
      PERFORM pg_notify(
          'realtime:system',
          jsonb_build_object(
              'error', SQLERRM,
              'function', 'realtime.send',
              'event', event,
              'topic', topic,
              'private', private
          )::text
      );
  END;
END;
$$;


ALTER FUNCTION realtime.send(payload jsonb, event text, topic text, private boolean) OWNER TO supabase_admin;

--
-- Name: subscription_check_filters(); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.subscription_check_filters() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    /*
    Validates that the user defined filters for a subscription:
    - refer to valid columns that the claimed role may access
    - values are coercable to the correct column type
    */
    declare
        col_names text[] = coalesce(
                array_agg(c.column_name order by c.ordinal_position),
                '{}'::text[]
            )
            from
                information_schema.columns c
            where
                format('%I.%I', c.table_schema, c.table_name)::regclass = new.entity
                and pg_catalog.has_column_privilege(
                    (new.claims ->> 'role'),
                    format('%I.%I', c.table_schema, c.table_name)::regclass,
                    c.column_name,
                    'SELECT'
                );
        filter realtime.user_defined_filter;
        col_type regtype;

        in_val jsonb;
    begin
        for filter in select * from unnest(new.filters) loop
            -- Filtered column is valid
            if not filter.column_name = any(col_names) then
                raise exception 'invalid column for filter %', filter.column_name;
            end if;

            -- Type is sanitized and safe for string interpolation
            col_type = (
                select atttypid::regtype
                from pg_catalog.pg_attribute
                where attrelid = new.entity
                      and attname = filter.column_name
            );
            if col_type is null then
                raise exception 'failed to lookup type for column %', filter.column_name;
            end if;

            -- Set maximum number of entries for in filter
            if filter.op = 'in'::realtime.equality_op then
                in_val = realtime.cast(filter.value, (col_type::text || '[]')::regtype);
                if coalesce(jsonb_array_length(in_val), 0) > 100 then
                    raise exception 'too many values for `in` filter. Maximum 100';
                end if;
            else
                -- raises an exception if value is not coercable to type
                perform realtime.cast(filter.value, col_type);
            end if;

        end loop;

        -- Apply consistent order to filters so the unique constraint on
        -- (subscription_id, entity, filters) can't be tricked by a different filter order
        new.filters = coalesce(
            array_agg(f order by f.column_name, f.op, f.value),
            '{}'
        ) from unnest(new.filters) f;

        return new;
    end;
    $$;


ALTER FUNCTION realtime.subscription_check_filters() OWNER TO supabase_admin;

--
-- Name: to_regrole(text); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.to_regrole(role_name text) RETURNS regrole
    LANGUAGE sql IMMUTABLE
    AS $$ select role_name::regrole $$;


ALTER FUNCTION realtime.to_regrole(role_name text) OWNER TO supabase_admin;

--
-- Name: topic(); Type: FUNCTION; Schema: realtime; Owner: supabase_realtime_admin
--

CREATE FUNCTION realtime.topic() RETURNS text
    LANGUAGE sql STABLE
    AS $$
select nullif(current_setting('realtime.topic', true), '')::text;
$$;


ALTER FUNCTION realtime.topic() OWNER TO supabase_realtime_admin;

--
-- Name: can_insert_object(text, text, uuid, jsonb); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.can_insert_object(bucketid text, name text, owner uuid, metadata jsonb) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO "storage"."objects" ("bucket_id", "name", "owner", "metadata") VALUES (bucketid, name, owner, metadata);
  -- hack to rollback the successful insert
  RAISE sqlstate 'PT200' using
  message = 'ROLLBACK',
  detail = 'rollback successful insert';
END
$$;


ALTER FUNCTION storage.can_insert_object(bucketid text, name text, owner uuid, metadata jsonb) OWNER TO supabase_storage_admin;

--
-- Name: extension(text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.extension(name text) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
_parts text[];
_filename text;
BEGIN
	select string_to_array(name, '/') into _parts;
	select _parts[array_length(_parts,1)] into _filename;
	-- @todo return the last part instead of 2
	return reverse(split_part(reverse(_filename), '.', 1));
END
$$;


ALTER FUNCTION storage.extension(name text) OWNER TO supabase_storage_admin;

--
-- Name: filename(text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.filename(name text) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
_parts text[];
BEGIN
	select string_to_array(name, '/') into _parts;
	return _parts[array_length(_parts,1)];
END
$$;


ALTER FUNCTION storage.filename(name text) OWNER TO supabase_storage_admin;

--
-- Name: foldername(text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.foldername(name text) RETURNS text[]
    LANGUAGE plpgsql
    AS $$
DECLARE
_parts text[];
BEGIN
	select string_to_array(name, '/') into _parts;
	return _parts[1:array_length(_parts,1)-1];
END
$$;


ALTER FUNCTION storage.foldername(name text) OWNER TO supabase_storage_admin;

--
-- Name: get_size_by_bucket(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.get_size_by_bucket() RETURNS TABLE(size bigint, bucket_id text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    return query
        select sum((metadata->>'size')::int) as size, obj.bucket_id
        from "storage".objects as obj
        group by obj.bucket_id;
END
$$;


ALTER FUNCTION storage.get_size_by_bucket() OWNER TO supabase_storage_admin;

--
-- Name: list_multipart_uploads_with_delimiter(text, text, text, integer, text, text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.list_multipart_uploads_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer DEFAULT 100, next_key_token text DEFAULT ''::text, next_upload_token text DEFAULT ''::text) RETURNS TABLE(key text, id text, created_at timestamp with time zone)
    LANGUAGE plpgsql
    AS $_$
BEGIN
    RETURN QUERY EXECUTE
        'SELECT DISTINCT ON(key COLLATE "C") * from (
            SELECT
                CASE
                    WHEN position($2 IN substring(key from length($1) + 1)) > 0 THEN
                        substring(key from 1 for length($1) + position($2 IN substring(key from length($1) + 1)))
                    ELSE
                        key
                END AS key, id, created_at
            FROM
                storage.s3_multipart_uploads
            WHERE
                bucket_id = $5 AND
                key ILIKE $1 || ''%'' AND
                CASE
                    WHEN $4 != '''' AND $6 = '''' THEN
                        CASE
                            WHEN position($2 IN substring(key from length($1) + 1)) > 0 THEN
                                substring(key from 1 for length($1) + position($2 IN substring(key from length($1) + 1))) COLLATE "C" > $4
                            ELSE
                                key COLLATE "C" > $4
                            END
                    ELSE
                        true
                END AND
                CASE
                    WHEN $6 != '''' THEN
                        id COLLATE "C" > $6
                    ELSE
                        true
                    END
            ORDER BY
                key COLLATE "C" ASC, created_at ASC) as e order by key COLLATE "C" LIMIT $3'
        USING prefix_param, delimiter_param, max_keys, next_key_token, bucket_id, next_upload_token;
END;
$_$;


ALTER FUNCTION storage.list_multipart_uploads_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer, next_key_token text, next_upload_token text) OWNER TO supabase_storage_admin;

--
-- Name: list_objects_with_delimiter(text, text, text, integer, text, text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.list_objects_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer DEFAULT 100, start_after text DEFAULT ''::text, next_token text DEFAULT ''::text) RETURNS TABLE(name text, id uuid, metadata jsonb, updated_at timestamp with time zone)
    LANGUAGE plpgsql
    AS $_$
BEGIN
    RETURN QUERY EXECUTE
        'SELECT DISTINCT ON(name COLLATE "C") * from (
            SELECT
                CASE
                    WHEN position($2 IN substring(name from length($1) + 1)) > 0 THEN
                        substring(name from 1 for length($1) + position($2 IN substring(name from length($1) + 1)))
                    ELSE
                        name
                END AS name, id, metadata, updated_at
            FROM
                storage.objects
            WHERE
                bucket_id = $5 AND
                name ILIKE $1 || ''%'' AND
                CASE
                    WHEN $6 != '''' THEN
                    name COLLATE "C" > $6
                ELSE true END
                AND CASE
                    WHEN $4 != '''' THEN
                        CASE
                            WHEN position($2 IN substring(name from length($1) + 1)) > 0 THEN
                                substring(name from 1 for length($1) + position($2 IN substring(name from length($1) + 1))) COLLATE "C" > $4
                            ELSE
                                name COLLATE "C" > $4
                            END
                    ELSE
                        true
                END
            ORDER BY
                name COLLATE "C" ASC) as e order by name COLLATE "C" LIMIT $3'
        USING prefix_param, delimiter_param, max_keys, next_token, bucket_id, start_after;
END;
$_$;


ALTER FUNCTION storage.list_objects_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer, start_after text, next_token text) OWNER TO supabase_storage_admin;

--
-- Name: operation(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.operation() RETURNS text
    LANGUAGE plpgsql STABLE
    AS $$
BEGIN
    RETURN current_setting('storage.operation', true);
END;
$$;


ALTER FUNCTION storage.operation() OWNER TO supabase_storage_admin;

--
-- Name: search(text, text, integer, integer, integer, text, text, text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.search(prefix text, bucketname text, limits integer DEFAULT 100, levels integer DEFAULT 1, offsets integer DEFAULT 0, search text DEFAULT ''::text, sortcolumn text DEFAULT 'name'::text, sortorder text DEFAULT 'asc'::text) RETURNS TABLE(name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb)
    LANGUAGE plpgsql STABLE
    AS $_$
declare
  v_order_by text;
  v_sort_order text;
begin
  case
    when sortcolumn = 'name' then
      v_order_by = 'name';
    when sortcolumn = 'updated_at' then
      v_order_by = 'updated_at';
    when sortcolumn = 'created_at' then
      v_order_by = 'created_at';
    when sortcolumn = 'last_accessed_at' then
      v_order_by = 'last_accessed_at';
    else
      v_order_by = 'name';
  end case;

  case
    when sortorder = 'asc' then
      v_sort_order = 'asc';
    when sortorder = 'desc' then
      v_sort_order = 'desc';
    else
      v_sort_order = 'asc';
  end case;

  v_order_by = v_order_by || ' ' || v_sort_order;

  return query execute
    'with folders as (
       select path_tokens[$1] as folder
       from storage.objects
         where objects.name ilike $2 || $3 || ''%''
           and bucket_id = $4
           and array_length(objects.path_tokens, 1) <> $1
       group by folder
       order by folder ' || v_sort_order || '
     )
     (select folder as "name",
            null as id,
            null as updated_at,
            null as created_at,
            null as last_accessed_at,
            null as metadata from folders)
     union all
     (select path_tokens[$1] as "name",
            id,
            updated_at,
            created_at,
            last_accessed_at,
            metadata
     from storage.objects
     where objects.name ilike $2 || $3 || ''%''
       and bucket_id = $4
       and array_length(objects.path_tokens, 1) = $1
     order by ' || v_order_by || ')
     limit $5
     offset $6' using levels, prefix, search, bucketname, limits, offsets;
end;
$_$;


ALTER FUNCTION storage.search(prefix text, bucketname text, limits integer, levels integer, offsets integer, search text, sortcolumn text, sortorder text) OWNER TO supabase_storage_admin;

--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW; 
END;
$$;


ALTER FUNCTION storage.update_updated_at_column() OWNER TO supabase_storage_admin;

--
-- Name: secrets_encrypt_secret_secret(); Type: FUNCTION; Schema: vault; Owner: supabase_admin
--

CREATE FUNCTION vault.secrets_encrypt_secret_secret() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
		BEGIN
		        new.secret = CASE WHEN new.secret IS NULL THEN NULL ELSE
			CASE WHEN new.key_id IS NULL THEN NULL ELSE pg_catalog.encode(
			  pgsodium.crypto_aead_det_encrypt(
				pg_catalog.convert_to(new.secret, 'utf8'),
				pg_catalog.convert_to((new.id::text || new.description::text || new.created_at::text || new.updated_at::text)::text, 'utf8'),
				new.key_id::uuid,
				new.nonce
			  ),
				'base64') END END;
		RETURN new;
		END;
		$$;


ALTER FUNCTION vault.secrets_encrypt_secret_secret() OWNER TO supabase_admin;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: audit_log_entries; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.audit_log_entries (
    instance_id uuid,
    id uuid NOT NULL,
    payload json,
    created_at timestamp with time zone,
    ip_address character varying(64) DEFAULT ''::character varying NOT NULL
);


ALTER TABLE auth.audit_log_entries OWNER TO supabase_auth_admin;

--
-- Name: TABLE audit_log_entries; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.audit_log_entries IS 'Auth: Audit trail for user actions.';


--
-- Name: flow_state; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.flow_state (
    id uuid NOT NULL,
    user_id uuid,
    auth_code text NOT NULL,
    code_challenge_method auth.code_challenge_method NOT NULL,
    code_challenge text NOT NULL,
    provider_type text NOT NULL,
    provider_access_token text,
    provider_refresh_token text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    authentication_method text NOT NULL,
    auth_code_issued_at timestamp with time zone
);


ALTER TABLE auth.flow_state OWNER TO supabase_auth_admin;

--
-- Name: TABLE flow_state; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.flow_state IS 'stores metadata for pkce logins';


--
-- Name: identities; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.identities (
    provider_id text NOT NULL,
    user_id uuid NOT NULL,
    identity_data jsonb NOT NULL,
    provider text NOT NULL,
    last_sign_in_at timestamp with time zone,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    email text GENERATED ALWAYS AS (lower((identity_data ->> 'email'::text))) STORED,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


ALTER TABLE auth.identities OWNER TO supabase_auth_admin;

--
-- Name: TABLE identities; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.identities IS 'Auth: Stores identities associated to a user.';


--
-- Name: COLUMN identities.email; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.identities.email IS 'Auth: Email is a generated column that references the optional email property in the identity_data';


--
-- Name: instances; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.instances (
    id uuid NOT NULL,
    uuid uuid,
    raw_base_config text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE auth.instances OWNER TO supabase_auth_admin;

--
-- Name: TABLE instances; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.instances IS 'Auth: Manages users across multiple sites.';


--
-- Name: mfa_amr_claims; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.mfa_amr_claims (
    session_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    authentication_method text NOT NULL,
    id uuid NOT NULL
);


ALTER TABLE auth.mfa_amr_claims OWNER TO supabase_auth_admin;

--
-- Name: TABLE mfa_amr_claims; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.mfa_amr_claims IS 'auth: stores authenticator method reference claims for multi factor authentication';


--
-- Name: mfa_challenges; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.mfa_challenges (
    id uuid NOT NULL,
    factor_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    verified_at timestamp with time zone,
    ip_address inet NOT NULL,
    otp_code text,
    web_authn_session_data jsonb
);


ALTER TABLE auth.mfa_challenges OWNER TO supabase_auth_admin;

--
-- Name: TABLE mfa_challenges; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.mfa_challenges IS 'auth: stores metadata about challenge requests made';


--
-- Name: mfa_factors; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.mfa_factors (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    friendly_name text,
    factor_type auth.factor_type NOT NULL,
    status auth.factor_status NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    secret text,
    phone text,
    last_challenged_at timestamp with time zone,
    web_authn_credential jsonb,
    web_authn_aaguid uuid
);


ALTER TABLE auth.mfa_factors OWNER TO supabase_auth_admin;

--
-- Name: TABLE mfa_factors; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.mfa_factors IS 'auth: stores metadata about factors';


--
-- Name: one_time_tokens; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.one_time_tokens (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    token_type auth.one_time_token_type NOT NULL,
    token_hash text NOT NULL,
    relates_to text NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT one_time_tokens_token_hash_check CHECK ((char_length(token_hash) > 0))
);


ALTER TABLE auth.one_time_tokens OWNER TO supabase_auth_admin;

--
-- Name: refresh_tokens; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.refresh_tokens (
    instance_id uuid,
    id bigint NOT NULL,
    token character varying(255),
    user_id character varying(255),
    revoked boolean,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    parent character varying(255),
    session_id uuid
);


ALTER TABLE auth.refresh_tokens OWNER TO supabase_auth_admin;

--
-- Name: TABLE refresh_tokens; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.refresh_tokens IS 'Auth: Store of tokens used to refresh JWT tokens once they expire.';


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE; Schema: auth; Owner: supabase_auth_admin
--

CREATE SEQUENCE auth.refresh_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE auth.refresh_tokens_id_seq OWNER TO supabase_auth_admin;

--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: auth; Owner: supabase_auth_admin
--

ALTER SEQUENCE auth.refresh_tokens_id_seq OWNED BY auth.refresh_tokens.id;


--
-- Name: saml_providers; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.saml_providers (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    entity_id text NOT NULL,
    metadata_xml text NOT NULL,
    metadata_url text,
    attribute_mapping jsonb,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    name_id_format text,
    CONSTRAINT "entity_id not empty" CHECK ((char_length(entity_id) > 0)),
    CONSTRAINT "metadata_url not empty" CHECK (((metadata_url = NULL::text) OR (char_length(metadata_url) > 0))),
    CONSTRAINT "metadata_xml not empty" CHECK ((char_length(metadata_xml) > 0))
);


ALTER TABLE auth.saml_providers OWNER TO supabase_auth_admin;

--
-- Name: TABLE saml_providers; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.saml_providers IS 'Auth: Manages SAML Identity Provider connections.';


--
-- Name: saml_relay_states; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.saml_relay_states (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    request_id text NOT NULL,
    for_email text,
    redirect_to text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    flow_state_id uuid,
    CONSTRAINT "request_id not empty" CHECK ((char_length(request_id) > 0))
);


ALTER TABLE auth.saml_relay_states OWNER TO supabase_auth_admin;

--
-- Name: TABLE saml_relay_states; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.saml_relay_states IS 'Auth: Contains SAML Relay State information for each Service Provider initiated login.';


--
-- Name: schema_migrations; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.schema_migrations (
    version character varying(255) NOT NULL
);


ALTER TABLE auth.schema_migrations OWNER TO supabase_auth_admin;

--
-- Name: TABLE schema_migrations; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.schema_migrations IS 'Auth: Manages updates to the auth system.';


--
-- Name: sessions; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.sessions (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    factor_id uuid,
    aal auth.aal_level,
    not_after timestamp with time zone,
    refreshed_at timestamp without time zone,
    user_agent text,
    ip inet,
    tag text
);


ALTER TABLE auth.sessions OWNER TO supabase_auth_admin;

--
-- Name: TABLE sessions; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.sessions IS 'Auth: Stores session data associated to a user.';


--
-- Name: COLUMN sessions.not_after; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.sessions.not_after IS 'Auth: Not after is a nullable column that contains a timestamp after which the session should be regarded as expired.';


--
-- Name: sso_domains; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.sso_domains (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    domain text NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    CONSTRAINT "domain not empty" CHECK ((char_length(domain) > 0))
);


ALTER TABLE auth.sso_domains OWNER TO supabase_auth_admin;

--
-- Name: TABLE sso_domains; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.sso_domains IS 'Auth: Manages SSO email address domain mapping to an SSO Identity Provider.';


--
-- Name: sso_providers; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.sso_providers (
    id uuid NOT NULL,
    resource_id text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    CONSTRAINT "resource_id not empty" CHECK (((resource_id = NULL::text) OR (char_length(resource_id) > 0)))
);


ALTER TABLE auth.sso_providers OWNER TO supabase_auth_admin;

--
-- Name: TABLE sso_providers; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.sso_providers IS 'Auth: Manages SSO identity provider information; see saml_providers for SAML.';


--
-- Name: COLUMN sso_providers.resource_id; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.sso_providers.resource_id IS 'Auth: Uniquely identifies a SSO provider according to a user-chosen resource ID (case insensitive), useful in infrastructure as code.';


--
-- Name: users; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.users (
    instance_id uuid,
    id uuid NOT NULL,
    aud character varying(255),
    role character varying(255),
    email character varying(255),
    encrypted_password character varying(255),
    email_confirmed_at timestamp with time zone,
    invited_at timestamp with time zone,
    confirmation_token character varying(255),
    confirmation_sent_at timestamp with time zone,
    recovery_token character varying(255),
    recovery_sent_at timestamp with time zone,
    email_change_token_new character varying(255),
    email_change character varying(255),
    email_change_sent_at timestamp with time zone,
    last_sign_in_at timestamp with time zone,
    raw_app_meta_data jsonb,
    raw_user_meta_data jsonb,
    is_super_admin boolean,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    phone text DEFAULT NULL::character varying,
    phone_confirmed_at timestamp with time zone,
    phone_change text DEFAULT ''::character varying,
    phone_change_token character varying(255) DEFAULT ''::character varying,
    phone_change_sent_at timestamp with time zone,
    confirmed_at timestamp with time zone GENERATED ALWAYS AS (LEAST(email_confirmed_at, phone_confirmed_at)) STORED,
    email_change_token_current character varying(255) DEFAULT ''::character varying,
    email_change_confirm_status smallint DEFAULT 0,
    banned_until timestamp with time zone,
    reauthentication_token character varying(255) DEFAULT ''::character varying,
    reauthentication_sent_at timestamp with time zone,
    is_sso_user boolean DEFAULT false NOT NULL,
    deleted_at timestamp with time zone,
    is_anonymous boolean DEFAULT false NOT NULL,
    CONSTRAINT users_email_change_confirm_status_check CHECK (((email_change_confirm_status >= 0) AND (email_change_confirm_status <= 2)))
);


ALTER TABLE auth.users OWNER TO supabase_auth_admin;

--
-- Name: TABLE users; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.users IS 'Auth: Stores user login data within a secure schema.';


--
-- Name: COLUMN users.is_sso_user; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.users.is_sso_user IS 'Auth: Set this column to true when the account comes from SSO. These accounts can have duplicate emails.';


--
-- Name: account; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.account (
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


ALTER TABLE public.account OWNER TO postgres;

--
-- Name: TABLE account; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.account IS 'Cuentas financieras de los usuarios';


--
-- Name: account_type; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.account_type (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    description text,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    modified_at timestamp with time zone
);


ALTER TABLE public.account_type OWNER TO postgres;

--
-- Name: TABLE account_type; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.account_type IS 'Tipos de cuenta soportados';


--
-- Name: app_user; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.app_user (
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


ALTER TABLE public.app_user OWNER TO postgres;

--
-- Name: TABLE app_user; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.app_user IS 'Stores user settings and preferences. Settings validation is now handled in the application domain layer.';


--
-- Name: COLUMN app_user.notification_advance_days; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.app_user.notification_advance_days IS 'Días de anticipación para notificaciones recurrentes';


--
-- Name: balance_history; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.balance_history (
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


ALTER TABLE public.balance_history OWNER TO postgres;

--
-- Name: TABLE balance_history; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.balance_history IS 'Historial de cambios en balances';


--
-- Name: category; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.category (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    description text,
    transaction_type_id uuid NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    modified_at timestamp with time zone
);


ALTER TABLE public.category OWNER TO postgres;

--
-- Name: TABLE category; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.category IS 'Categorías para clasificación de transacciones';


--
-- Name: credit_card_details; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.credit_card_details (
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


ALTER TABLE public.credit_card_details OWNER TO postgres;

--
-- Name: credit_card_interest_history; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.credit_card_interest_history (
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


ALTER TABLE public.credit_card_interest_history OWNER TO postgres;

--
-- Name: credit_card_statement; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.credit_card_statement (
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


ALTER TABLE public.credit_card_statement OWNER TO postgres;

--
-- Name: currency; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.currency (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    code character varying(3) NOT NULL,
    name text NOT NULL,
    symbol character varying(5),
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    modified_at timestamp with time zone
);


ALTER TABLE public.currency OWNER TO postgres;

--
-- Name: TABLE currency; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.currency IS 'Catálogo de monedas soportadas';


--
-- Name: transaction; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.transaction (
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


ALTER TABLE public.transaction OWNER TO postgres;

--
-- Name: TABLE transaction; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.transaction IS 'Registro de todas las transacciones financieras';


--
-- Name: COLUMN transaction.tags; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.transaction.tags IS 'Array of tags for transaction classification and searching';


--
-- Name: COLUMN transaction.notes; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.transaction.notes IS 'Additional notes and details about the transaction';


--
-- Name: transaction_type; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.transaction_type (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    description text,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    modified_at timestamp with time zone
);


ALTER TABLE public.transaction_type OWNER TO postgres;

--
-- Name: TABLE transaction_type; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.transaction_type IS 'Tipos de transacciones soportadas';


--
-- Name: expense_trends_analysis; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.expense_trends_analysis AS
 WITH monthly_expenses AS (
         SELECT t.user_id,
            date_trunc('month'::text, (t.transaction_date)::timestamp with time zone) AS month,
            c.name AS category_name,
            sum(t.amount) AS total_amount,
            count(*) AS transaction_count
           FROM ((public.transaction t
             JOIN public.transaction_type tt ON ((tt.id = t.transaction_type_id)))
             JOIN public.category c ON ((c.id = t.category_id)))
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


ALTER VIEW public.expense_trends_analysis OWNER TO postgres;

--
-- Name: financial_goal; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.financial_goal (
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


ALTER TABLE public.financial_goal OWNER TO postgres;

--
-- Name: TABLE financial_goal; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.financial_goal IS 'Metas financieras de ahorro e inversión';


--
-- Name: foreign_keys; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.foreign_keys AS
 SELECT pg_constraint.conrelid AS table_id,
    pg_constraint.confrelid AS referenced_table_id,
    pg_constraint.conname AS fk_name
   FROM pg_constraint
  WHERE (pg_constraint.contype = 'f'::"char");


ALTER VIEW public.foreign_keys OWNER TO postgres;

--
-- Name: jar; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.jar (
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


ALTER TABLE public.jar OWNER TO postgres;

--
-- Name: TABLE jar; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.jar IS 'Jarras según metodología de T. Harv Eker';


--
-- Name: COLUMN jar.target_percentage; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.jar.target_percentage IS 'Porcentaje que debe recibir la jarra de los ingresos';


--
-- Name: goal_progress_summary; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.goal_progress_summary AS
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
            public.calculate_goal_progress(g_1.current_amount, g_1.target_amount, g_1.start_date, g_1.target_date) AS progress
           FROM public.financial_goal g_1
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
     LEFT JOIN public.jar j ON ((j.id = g.jar_id)));


ALTER VIEW public.goal_progress_summary OWNER TO postgres;

--
-- Name: installment_purchase; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.installment_purchase (
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


ALTER TABLE public.installment_purchase OWNER TO postgres;

--
-- Name: jar_balance; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.jar_balance (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    jar_id uuid NOT NULL,
    current_balance numeric(15,2) DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    modified_at timestamp with time zone
);


ALTER TABLE public.jar_balance OWNER TO postgres;

--
-- Name: TABLE jar_balance; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.jar_balance IS 'Balance actual de cada jarra por usuario';


--
-- Name: notification; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.notification (
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


ALTER TABLE public.notification OWNER TO postgres;

--
-- Name: TABLE notification; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.notification IS 'Registro de notificaciones del sistema';


--
-- Name: recurring_transaction; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.recurring_transaction (
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


ALTER TABLE public.recurring_transaction OWNER TO postgres;

--
-- Name: TABLE recurring_transaction; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.recurring_transaction IS 'Configuración de transacciones recurrentes';


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.schema_migrations (
    version text NOT NULL
);


ALTER TABLE public.schema_migrations OWNER TO postgres;

--
-- Name: subcategory; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.subcategory (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    description text,
    category_id uuid NOT NULL,
    jar_id uuid,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    modified_at timestamp with time zone
);


ALTER TABLE public.subcategory OWNER TO postgres;

--
-- Name: TABLE subcategory; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.subcategory IS 'Subcategorías para clasificación detallada';


--
-- Name: COLUMN subcategory.jar_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.subcategory.jar_id IS 'Jarra asociada, requerida solo para gastos';


--
-- Name: transaction_medium; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.transaction_medium (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    description text,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    modified_at timestamp with time zone
);


ALTER TABLE public.transaction_medium OWNER TO postgres;

--
-- Name: TABLE transaction_medium; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.transaction_medium IS 'Medios de pago soportados';


--
-- Name: transfer; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.transfer (
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


ALTER TABLE public.transfer OWNER TO postgres;

--
-- Name: TABLE transfer; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.transfer IS 'Registro de transferencias entre cuentas y jarras';


--
-- Name: COLUMN transfer.transfer_type; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.transfer.transfer_type IS 'ACCOUNT_TO_ACCOUNT: entre cuentas, JAR_TO_JAR: entre jarras, PERIOD_ROLLOVER: rollover de periodo';


--
-- Name: transfer_summary; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.transfer_summary AS
 SELECT t.user_id,
    t.transfer_type,
    t.transfer_date,
    t.amount,
    t.exchange_rate,
        CASE
            WHEN ((t.transfer_type)::text = 'ACCOUNT_TO_ACCOUNT'::text) THEN ( SELECT account.name
               FROM public.account
              WHERE (account.id = t.from_account_id))
            ELSE ( SELECT jar.name
               FROM public.jar
              WHERE (jar.id = t.from_jar_id))
        END AS source_name,
        CASE
            WHEN ((t.transfer_type)::text = 'ACCOUNT_TO_ACCOUNT'::text) THEN ( SELECT account.name
               FROM public.account
              WHERE (account.id = t.to_account_id))
            ELSE ( SELECT jar.name
               FROM public.jar
              WHERE (jar.id = t.to_jar_id))
        END AS target_name,
        CASE
            WHEN ((t.transfer_type)::text = 'ACCOUNT_TO_ACCOUNT'::text) THEN (t.amount * t.exchange_rate)
            ELSE t.amount
        END AS converted_amount,
    t.description,
    t.sync_status,
    t.created_at
   FROM public.transfer t;


ALTER VIEW public.transfer_summary OWNER TO postgres;

--
-- Name: transfer_analysis; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.transfer_analysis AS
 WITH monthly_stats AS (
         SELECT transfer_summary.user_id,
            date_trunc('month'::text, (transfer_summary.transfer_date)::timestamp with time zone) AS month,
            transfer_summary.transfer_type,
            count(*) AS transfer_count,
            sum(transfer_summary.converted_amount) AS total_amount,
            avg(transfer_summary.converted_amount) AS avg_amount
           FROM public.transfer_summary
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


ALTER VIEW public.transfer_analysis OWNER TO postgres;

--
-- Name: messages; Type: TABLE; Schema: realtime; Owner: supabase_realtime_admin
--

CREATE TABLE realtime.messages (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL
)
PARTITION BY RANGE (inserted_at);


ALTER TABLE realtime.messages OWNER TO supabase_realtime_admin;

--
-- Name: schema_migrations; Type: TABLE; Schema: realtime; Owner: supabase_admin
--

CREATE TABLE realtime.schema_migrations (
    version bigint NOT NULL,
    inserted_at timestamp(0) without time zone
);


ALTER TABLE realtime.schema_migrations OWNER TO supabase_admin;

--
-- Name: subscription; Type: TABLE; Schema: realtime; Owner: supabase_admin
--

CREATE TABLE realtime.subscription (
    id bigint NOT NULL,
    subscription_id uuid NOT NULL,
    entity regclass NOT NULL,
    filters realtime.user_defined_filter[] DEFAULT '{}'::realtime.user_defined_filter[] NOT NULL,
    claims jsonb NOT NULL,
    claims_role regrole GENERATED ALWAYS AS (realtime.to_regrole((claims ->> 'role'::text))) STORED NOT NULL,
    created_at timestamp without time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);


ALTER TABLE realtime.subscription OWNER TO supabase_admin;

--
-- Name: subscription_id_seq; Type: SEQUENCE; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE realtime.subscription ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME realtime.subscription_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: buckets; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.buckets (
    id text NOT NULL,
    name text NOT NULL,
    owner uuid,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    public boolean DEFAULT false,
    avif_autodetection boolean DEFAULT false,
    file_size_limit bigint,
    allowed_mime_types text[],
    owner_id text
);


ALTER TABLE storage.buckets OWNER TO supabase_storage_admin;

--
-- Name: COLUMN buckets.owner; Type: COMMENT; Schema: storage; Owner: supabase_storage_admin
--

COMMENT ON COLUMN storage.buckets.owner IS 'Field is deprecated, use owner_id instead';


--
-- Name: migrations; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.migrations (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    hash character varying(40) NOT NULL,
    executed_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE storage.migrations OWNER TO supabase_storage_admin;

--
-- Name: objects; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.objects (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    bucket_id text,
    name text,
    owner uuid,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    last_accessed_at timestamp with time zone DEFAULT now(),
    metadata jsonb,
    path_tokens text[] GENERATED ALWAYS AS (string_to_array(name, '/'::text)) STORED,
    version text,
    owner_id text,
    user_metadata jsonb
);


ALTER TABLE storage.objects OWNER TO supabase_storage_admin;

--
-- Name: COLUMN objects.owner; Type: COMMENT; Schema: storage; Owner: supabase_storage_admin
--

COMMENT ON COLUMN storage.objects.owner IS 'Field is deprecated, use owner_id instead';


--
-- Name: s3_multipart_uploads; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.s3_multipart_uploads (
    id text NOT NULL,
    in_progress_size bigint DEFAULT 0 NOT NULL,
    upload_signature text NOT NULL,
    bucket_id text NOT NULL,
    key text NOT NULL COLLATE pg_catalog."C",
    version text NOT NULL,
    owner_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    user_metadata jsonb
);


ALTER TABLE storage.s3_multipart_uploads OWNER TO supabase_storage_admin;

--
-- Name: s3_multipart_uploads_parts; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.s3_multipart_uploads_parts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    upload_id text NOT NULL,
    size bigint DEFAULT 0 NOT NULL,
    part_number integer NOT NULL,
    bucket_id text NOT NULL,
    key text NOT NULL COLLATE pg_catalog."C",
    etag text NOT NULL,
    owner_id text,
    version text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE storage.s3_multipart_uploads_parts OWNER TO supabase_storage_admin;

--
-- Name: schema_migrations; Type: TABLE; Schema: supabase_migrations; Owner: postgres
--

CREATE TABLE supabase_migrations.schema_migrations (
    version text NOT NULL,
    statements text[],
    name text
);


ALTER TABLE supabase_migrations.schema_migrations OWNER TO postgres;

--
-- Name: seed_files; Type: TABLE; Schema: supabase_migrations; Owner: postgres
--

CREATE TABLE supabase_migrations.seed_files (
    path text NOT NULL,
    hash text NOT NULL
);


ALTER TABLE supabase_migrations.seed_files OWNER TO postgres;

--
-- Name: decrypted_secrets; Type: VIEW; Schema: vault; Owner: supabase_admin
--

CREATE VIEW vault.decrypted_secrets AS
 SELECT secrets.id,
    secrets.name,
    secrets.description,
    secrets.secret,
        CASE
            WHEN (secrets.secret IS NULL) THEN NULL::text
            ELSE
            CASE
                WHEN (secrets.key_id IS NULL) THEN NULL::text
                ELSE convert_from(pgsodium.crypto_aead_det_decrypt(decode(secrets.secret, 'base64'::text), convert_to(((((secrets.id)::text || secrets.description) || (secrets.created_at)::text) || (secrets.updated_at)::text), 'utf8'::name), secrets.key_id, secrets.nonce), 'utf8'::name)
            END
        END AS decrypted_secret,
    secrets.key_id,
    secrets.nonce,
    secrets.created_at,
    secrets.updated_at
   FROM vault.secrets;


ALTER VIEW vault.decrypted_secrets OWNER TO supabase_admin;

--
-- Name: refresh_tokens id; Type: DEFAULT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.refresh_tokens ALTER COLUMN id SET DEFAULT nextval('auth.refresh_tokens_id_seq'::regclass);


--
-- Data for Name: audit_log_entries; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.audit_log_entries (instance_id, id, payload, created_at, ip_address) FROM stdin;
00000000-0000-0000-0000-000000000000	f814520b-5f71-4514-a8f7-d4a8d6ab995e	{"action":"user_confirmation_requested","actor_id":"32c2ad65-3737-4a01-9981-160916999514","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2025-01-02 16:28:25.401318+00	
00000000-0000-0000-0000-000000000000	509430d6-236b-4919-a324-075bacec0395	{"action":"user_signedup","actor_id":"32c2ad65-3737-4a01-9981-160916999514","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"team"}	2025-01-02 16:38:39.913433+00	
00000000-0000-0000-0000-000000000000	5e23eb70-d102-4c5c-bfff-a4246ee29392	{"action":"login","actor_id":"32c2ad65-3737-4a01-9981-160916999514","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-01-02 16:39:21.360125+00	
00000000-0000-0000-0000-000000000000	243c17ab-58b1-48f0-b69b-3e518a60ad79	{"action":"token_refreshed","actor_id":"32c2ad65-3737-4a01-9981-160916999514","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-02 17:39:07.704166+00	
00000000-0000-0000-0000-000000000000	902e8f05-f6db-4350-93df-d069f82774e6	{"action":"token_revoked","actor_id":"32c2ad65-3737-4a01-9981-160916999514","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-02 17:39:07.70561+00	
00000000-0000-0000-0000-000000000000	20e4cad5-2d4e-4f58-b211-8e13e338b4bb	{"action":"token_refreshed","actor_id":"32c2ad65-3737-4a01-9981-160916999514","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-03 01:34:28.354637+00	
00000000-0000-0000-0000-000000000000	7a42dcbc-0eac-4076-b4b9-258b6fa937bf	{"action":"token_revoked","actor_id":"32c2ad65-3737-4a01-9981-160916999514","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-03 01:34:28.364324+00	
00000000-0000-0000-0000-000000000000	d0b78a6d-fab2-47e0-9e36-c59b74f4e043	{"action":"token_refreshed","actor_id":"32c2ad65-3737-4a01-9981-160916999514","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-03 02:33:59.221406+00	
00000000-0000-0000-0000-000000000000	d2910530-cdc7-48ed-96ac-808a477ae535	{"action":"token_revoked","actor_id":"32c2ad65-3737-4a01-9981-160916999514","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-03 02:33:59.222315+00	
00000000-0000-0000-0000-000000000000	00c572c8-b8c6-43c4-a28f-a75438d0938b	{"action":"token_refreshed","actor_id":"32c2ad65-3737-4a01-9981-160916999514","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-03 03:45:20.88781+00	
00000000-0000-0000-0000-000000000000	e9dcaa9e-abb6-4bb3-865b-74abc3a0398b	{"action":"token_revoked","actor_id":"32c2ad65-3737-4a01-9981-160916999514","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-03 03:45:20.888765+00	
00000000-0000-0000-0000-000000000000	dcac4c4a-1100-4065-ab51-3e52d676c0fd	{"action":"user_signedup","actor_id":"7131f40a-27dc-4814-a3c1-8a3fec4e356a","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-01-03 05:33:17.306695+00	
00000000-0000-0000-0000-000000000000	27a45e88-062d-46f7-afe3-7868fa321ab4	{"action":"login","actor_id":"7131f40a-27dc-4814-a3c1-8a3fec4e356a","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-01-03 05:33:17.312465+00	
00000000-0000-0000-0000-000000000000	eb5e7f05-b599-4716-a11c-1e507856fc9e	{"action":"token_refreshed","actor_id":"7131f40a-27dc-4814-a3c1-8a3fec4e356a","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-03 06:32:44.133307+00	
00000000-0000-0000-0000-000000000000	e3ed80ed-00df-423f-af3e-055bc34a3d15	{"action":"token_revoked","actor_id":"7131f40a-27dc-4814-a3c1-8a3fec4e356a","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-03 06:32:44.140783+00	
00000000-0000-0000-0000-000000000000	30378403-3088-46c6-a5b3-053554616076	{"action":"token_refreshed","actor_id":"7131f40a-27dc-4814-a3c1-8a3fec4e356a","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-03 07:32:09.424632+00	
00000000-0000-0000-0000-000000000000	903d174c-6b5c-431a-95e4-43cb5ead0001	{"action":"token_revoked","actor_id":"7131f40a-27dc-4814-a3c1-8a3fec4e356a","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-03 07:32:09.428823+00	
00000000-0000-0000-0000-000000000000	718b20b5-6ca8-42ab-abb9-b5f5f59be814	{"action":"token_refreshed","actor_id":"7131f40a-27dc-4814-a3c1-8a3fec4e356a","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-03 08:31:39.573347+00	
00000000-0000-0000-0000-000000000000	72daabce-72cb-48b4-b0ae-952d4ddc2afe	{"action":"token_revoked","actor_id":"7131f40a-27dc-4814-a3c1-8a3fec4e356a","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-03 08:31:39.574259+00	
00000000-0000-0000-0000-000000000000	4cc72eb5-d6a1-4dfd-9ef6-a37ea55e5a53	{"action":"token_refreshed","actor_id":"7131f40a-27dc-4814-a3c1-8a3fec4e356a","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-03 09:31:09.42813+00	
00000000-0000-0000-0000-000000000000	fd3380e9-132a-4e40-b32d-29256735577c	{"action":"token_revoked","actor_id":"7131f40a-27dc-4814-a3c1-8a3fec4e356a","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-03 09:31:09.429611+00	
00000000-0000-0000-0000-000000000000	01928f9b-099f-498a-98b4-54a0ec814665	{"action":"token_refreshed","actor_id":"7131f40a-27dc-4814-a3c1-8a3fec4e356a","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-03 10:30:39.430036+00	
00000000-0000-0000-0000-000000000000	16553c04-6a53-4c4a-aedc-df40a3dac824	{"action":"token_revoked","actor_id":"7131f40a-27dc-4814-a3c1-8a3fec4e356a","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-03 10:30:39.432054+00	
00000000-0000-0000-0000-000000000000	03c7e36b-5bd6-4252-b2dc-89f7519e82d0	{"action":"token_refreshed","actor_id":"7131f40a-27dc-4814-a3c1-8a3fec4e356a","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-03 11:30:09.376521+00	
00000000-0000-0000-0000-000000000000	49e5a00b-f5b2-4db2-9a69-85378e76d9fa	{"action":"token_revoked","actor_id":"7131f40a-27dc-4814-a3c1-8a3fec4e356a","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-03 11:30:09.378787+00	
00000000-0000-0000-0000-000000000000	5158454b-fed6-4e0a-8156-af87cfd05411	{"action":"token_refreshed","actor_id":"7131f40a-27dc-4814-a3c1-8a3fec4e356a","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-03 12:29:39.271496+00	
00000000-0000-0000-0000-000000000000	4fc22dad-fd19-4638-b23a-95abe985580a	{"action":"token_revoked","actor_id":"7131f40a-27dc-4814-a3c1-8a3fec4e356a","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-03 12:29:39.273749+00	
00000000-0000-0000-0000-000000000000	83a03b5b-a952-46d4-be2f-d895749880cf	{"action":"token_refreshed","actor_id":"7131f40a-27dc-4814-a3c1-8a3fec4e356a","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-03 13:29:09.365959+00	
00000000-0000-0000-0000-000000000000	5d982455-9574-47f5-988f-01e7a41b538f	{"action":"token_revoked","actor_id":"7131f40a-27dc-4814-a3c1-8a3fec4e356a","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-03 13:29:09.366802+00	
00000000-0000-0000-0000-000000000000	763a51e6-adfe-4124-8508-40a19249cb9c	{"action":"token_refreshed","actor_id":"7131f40a-27dc-4814-a3c1-8a3fec4e356a","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-03 14:28:39.241913+00	
00000000-0000-0000-0000-000000000000	c48822ae-d957-44c0-810f-c301c3b7e335	{"action":"token_revoked","actor_id":"7131f40a-27dc-4814-a3c1-8a3fec4e356a","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-03 14:28:39.242739+00	
00000000-0000-0000-0000-000000000000	11029bcb-2d3e-4dd0-81df-800cecc9e21a	{"action":"user_signedup","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-01-11 00:48:59.991154+00	
00000000-0000-0000-0000-000000000000	67bbf12d-8d18-44fa-969c-522590b48ca3	{"action":"login","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-01-11 00:49:00.00201+00	
00000000-0000-0000-0000-000000000000	99e8e242-99bf-4001-8133-b51bbc98c49e	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-11 01:48:29.612695+00	
00000000-0000-0000-0000-000000000000	68170679-6755-4dc3-8f90-1d7ca81a32e9	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-11 01:48:29.620128+00	
00000000-0000-0000-0000-000000000000	5b561aa7-3a40-47b4-83eb-4ed3f2b296d0	{"action":"logout","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"account"}	2025-01-11 01:53:59.907864+00	
00000000-0000-0000-0000-000000000000	ecfc6c1f-4ab5-4a49-9bfd-ec1fc33747e3	{"action":"login","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-01-11 02:06:31.768224+00	
00000000-0000-0000-0000-000000000000	74b74414-5d71-4133-8e09-e1752fb9e404	{"action":"logout","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"account"}	2025-01-11 02:08:18.063113+00	
00000000-0000-0000-0000-000000000000	7dc30a21-6be9-4e67-9b0a-158565c32eb5	{"action":"login","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-01-11 03:14:51.160808+00	
00000000-0000-0000-0000-000000000000	92f80152-551d-4f10-aa04-1765c5e46a4c	{"action":"login","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-01-11 03:15:14.019311+00	
00000000-0000-0000-0000-000000000000	b4f07c60-e97c-461f-98a9-9bae556dd430	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-11 04:14:38.88434+00	
00000000-0000-0000-0000-000000000000	7b548753-1d66-45c0-b320-12dc0888e8cd	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-11 04:14:38.885212+00	
00000000-0000-0000-0000-000000000000	ec4359d9-5c27-40b9-b9dc-b257c2dd247c	{"action":"login","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-01-11 04:39:26.196113+00	
00000000-0000-0000-0000-000000000000	0c62a4eb-4ca3-445b-9212-a5cf5e2f9b37	{"action":"login","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-01-11 04:39:38.245036+00	
00000000-0000-0000-0000-000000000000	7f26cdbe-4c69-4306-9ec6-7fa91abdcbd9	{"action":"logout","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"account"}	2025-01-11 04:42:07.325159+00	
00000000-0000-0000-0000-000000000000	9976befb-eddc-4858-ba9b-0593ebd214af	{"action":"login","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-01-11 14:35:04.41251+00	
00000000-0000-0000-0000-000000000000	48461cc9-2b78-4a66-b78e-a1e9131f1fa5	{"action":"logout","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"account"}	2025-01-11 14:35:35.137945+00	
00000000-0000-0000-0000-000000000000	bb915164-aec5-4f6f-8286-128c077f7225	{"action":"login","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-01-11 14:36:09.438365+00	
00000000-0000-0000-0000-000000000000	d7abaf6c-b794-4fd8-aa44-6f4121eb4e68	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-11 15:41:04.187412+00	
00000000-0000-0000-0000-000000000000	dbdd6634-154e-47c7-8439-e33df8f827db	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-11 15:41:04.188797+00	
00000000-0000-0000-0000-000000000000	cb71b880-ef24-457b-af02-ea0e1d94b6b1	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-11 16:40:29.283413+00	
00000000-0000-0000-0000-000000000000	0f24aabb-6f44-4d69-a7cc-4f15d2ca2258	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-11 16:40:29.284363+00	
00000000-0000-0000-0000-000000000000	e9b37f81-5469-4849-846c-a06ed019a348	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-11 17:40:09.628923+00	
00000000-0000-0000-0000-000000000000	05bae0ea-fc2a-43d7-ac24-6fa9c16c5efb	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-11 17:40:09.630762+00	
00000000-0000-0000-0000-000000000000	6aef1f31-f024-4dcd-b3b6-8b587e3c29ae	{"action":"user_modified","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"user"}	2025-01-11 18:08:31.622845+00	
00000000-0000-0000-0000-000000000000	e385df9d-5ab0-4737-8eee-a55a26a86f1f	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-11 18:39:38.853436+00	
00000000-0000-0000-0000-000000000000	7a991a11-5b64-45e6-80f2-f9b0df7d361f	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-11 18:39:38.854365+00	
00000000-0000-0000-0000-000000000000	9e83eb0b-1bcd-4fb3-b5e2-675b318693ef	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-11 19:38:58.803935+00	
00000000-0000-0000-0000-000000000000	af468eec-84d1-4a64-a1da-e142df5ad45d	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-11 19:38:58.804868+00	
00000000-0000-0000-0000-000000000000	5c419d9d-8b85-4ee7-b5d6-799dfe074c31	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-11 20:38:18.685543+00	
00000000-0000-0000-0000-000000000000	49a48916-c80e-4894-9a62-0ba9ff0b24f6	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-11 20:38:18.686386+00	
00000000-0000-0000-0000-000000000000	9793d2fd-ab79-4047-8766-bb2b755f6a5c	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-11 21:37:38.678061+00	
00000000-0000-0000-0000-000000000000	8688bd51-df54-4d5a-984e-3440ca6a6792	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-11 21:37:38.678909+00	
00000000-0000-0000-0000-000000000000	5b3c83bb-8430-452e-8b1d-0347173b8bba	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-11 22:36:58.608927+00	
00000000-0000-0000-0000-000000000000	c461f814-a031-4185-a6aa-6b11be76b08f	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-11 22:36:58.609772+00	
00000000-0000-0000-0000-000000000000	32343d78-bd5a-4e19-8a77-7847d74e39dd	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-11 23:36:18.544747+00	
00000000-0000-0000-0000-000000000000	2caed369-78e3-4305-b5b3-5569ddaf3044	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-11 23:36:18.545687+00	
00000000-0000-0000-0000-000000000000	0aae70d6-e456-43ac-a416-0d48cfef0180	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-12 00:35:38.467546+00	
00000000-0000-0000-0000-000000000000	d4f2689e-573a-41c4-a698-85d3abd519a2	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-12 00:35:38.469592+00	
00000000-0000-0000-0000-000000000000	b8189041-4739-4676-b326-c670af25f4b1	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-12 01:34:58.469831+00	
00000000-0000-0000-0000-000000000000	59a1c347-b491-4fb8-a7bc-1196095d6975	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-12 01:34:58.470729+00	
00000000-0000-0000-0000-000000000000	5ef01af7-1bc1-428a-bd87-55c86f63e590	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-12 02:34:18.389381+00	
00000000-0000-0000-0000-000000000000	81273091-40b5-4df0-b743-99f0575e6e05	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-12 02:34:18.390695+00	
00000000-0000-0000-0000-000000000000	459701e3-f432-453e-9bae-2366061112ff	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-12 03:33:38.394061+00	
00000000-0000-0000-0000-000000000000	6714d2d4-51a1-4091-a556-263f3c91678f	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-12 03:33:38.396686+00	
00000000-0000-0000-0000-000000000000	33b5c7a1-f2b8-4b05-b8a6-3e58239016f0	{"action":"user_modified","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"user"}	2025-01-12 04:10:48.145821+00	
00000000-0000-0000-0000-000000000000	be5c24aa-9fab-478f-a3da-0a6a9078016e	{"action":"user_modified","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"user"}	2025-01-12 04:11:56.083769+00	
00000000-0000-0000-0000-000000000000	5ec098c3-76a9-4a74-8083-79059c456815	{"action":"user_modified","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"user"}	2025-01-12 04:22:28.03679+00	
00000000-0000-0000-0000-000000000000	1f46669b-46d4-4a5b-a096-fdab79bc759e	{"action":"logout","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"account"}	2025-01-12 04:22:30.96572+00	
00000000-0000-0000-0000-000000000000	f08fbb10-50a3-4d68-8e3a-93fdef9d549a	{"action":"login","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-01-12 04:23:54.663964+00	
00000000-0000-0000-0000-000000000000	1ff79b0b-d4a1-4441-b1ca-0c2c23e1bc9c	{"action":"login","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-01-12 04:24:20.682546+00	
00000000-0000-0000-0000-000000000000	bc56bb2f-f9a3-4bb2-a274-80506d481197	{"action":"user_modified","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"user"}	2025-01-12 04:42:57.480191+00	
00000000-0000-0000-0000-000000000000	f344dacc-1a93-4543-b7cc-ea86e9d22ddd	{"action":"user_updated_password","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"user"}	2025-01-12 04:42:57.901903+00	
00000000-0000-0000-0000-000000000000	785241e0-1591-482c-9044-717845c392a9	{"action":"user_modified","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"user"}	2025-01-12 04:42:57.902485+00	
00000000-0000-0000-0000-000000000000	bab54caf-caca-44f0-ae0e-9de9b62021cf	{"action":"logout","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"account"}	2025-01-12 04:43:10.392468+00	
00000000-0000-0000-0000-000000000000	f91c605a-d7e5-4a90-b67c-b3ddadddabc7	{"action":"login","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-01-12 04:43:35.153408+00	
00000000-0000-0000-0000-000000000000	06db7d14-4458-4056-b8b4-f9e38492a55d	{"action":"logout","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"account"}	2025-01-12 04:48:39.343981+00	
00000000-0000-0000-0000-000000000000	9cf902c5-f41d-4830-b7d1-f2f9f5a8cef3	{"action":"login","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-01-12 04:49:13.974044+00	
00000000-0000-0000-0000-000000000000	510f2d01-2edd-4df5-894e-62a21ef95059	{"action":"logout","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"account"}	2025-01-12 04:52:14.78163+00	
00000000-0000-0000-0000-000000000000	b9459a60-6da3-4aaf-a6b8-aa4203f35b21	{"action":"login","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-01-12 04:52:39.813707+00	
00000000-0000-0000-0000-000000000000	cd17026f-f05a-4aca-8d8d-28753074d930	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-12 05:52:06.498869+00	
00000000-0000-0000-0000-000000000000	7771018a-2791-4732-8171-9d1c6b2d510a	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-12 05:52:06.499736+00	
00000000-0000-0000-0000-000000000000	ed72c474-0299-4c06-9811-a9584c59b4b4	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-12 06:51:36.403253+00	
00000000-0000-0000-0000-000000000000	9c32e71d-baae-4640-bc70-dc217249dab1	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-12 06:51:36.406905+00	
00000000-0000-0000-0000-000000000000	25d79f29-dcab-49cf-8045-6706831f8bd3	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-12 15:46:53.033721+00	
00000000-0000-0000-0000-000000000000	c5957662-9837-4c23-86bd-77a73f9b68de	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-12 15:46:53.041573+00	
00000000-0000-0000-0000-000000000000	ada7aa4d-eeca-43c7-b582-df785d1407a9	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-12 19:50:21.564647+00	
00000000-0000-0000-0000-000000000000	0113df8a-136f-4480-b313-887ee89b683b	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-12 19:50:21.567196+00	
00000000-0000-0000-0000-000000000000	8477c0cc-6a40-4308-9d47-9e262f7c7025	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-12 20:49:51.384289+00	
00000000-0000-0000-0000-000000000000	cf9bef73-c71f-4478-a289-3c93cabebcd5	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-12 20:49:51.386798+00	
00000000-0000-0000-0000-000000000000	e9807ba2-a2a1-4b2c-aa0d-52e37f0db06f	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-12 21:49:21.339941+00	
00000000-0000-0000-0000-000000000000	51d1ab2c-7952-4a9d-acfb-e6eed0d34036	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-12 21:49:21.342451+00	
00000000-0000-0000-0000-000000000000	854a3762-7bcd-44b6-ae7b-00ad29a6cd0b	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-13 02:06:21.799195+00	
00000000-0000-0000-0000-000000000000	357fd9aa-c8a0-4580-a304-33ddba4fc94b	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-13 02:06:21.80789+00	
00000000-0000-0000-0000-000000000000	de4022e4-a0cd-40c0-91e7-f8330b9cb21a	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-13 03:07:02.833436+00	
00000000-0000-0000-0000-000000000000	353e695f-3476-45fe-9045-9249d67025cc	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-13 03:07:02.83478+00	
00000000-0000-0000-0000-000000000000	7bdd7036-80d7-4e05-8a8c-2111a7aec9ed	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-13 04:06:25.467479+00	
00000000-0000-0000-0000-000000000000	68501068-b38f-48c0-a92f-93e1020c9737	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-13 04:06:25.469305+00	
00000000-0000-0000-0000-000000000000	4d36fd04-82f6-4f05-b1d8-6849134ea203	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-13 05:05:55.352664+00	
00000000-0000-0000-0000-000000000000	afa285f2-bd91-4e11-b561-70cf821dc903	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-13 05:05:55.353544+00	
00000000-0000-0000-0000-000000000000	583df29a-4c70-4ea7-a8a9-92a32a007b99	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-13 06:05:25.285861+00	
00000000-0000-0000-0000-000000000000	0dbe3bf8-fc50-4185-9a19-7e151db426fe	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-13 06:05:25.291723+00	
00000000-0000-0000-0000-000000000000	03b2607e-85de-497f-985f-47a1967bd9fe	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-13 07:04:55.333755+00	
00000000-0000-0000-0000-000000000000	70fabcd5-bf97-4ed0-9f20-911a812c9bf6	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-13 07:04:55.341464+00	
00000000-0000-0000-0000-000000000000	a9266735-c2cf-4ced-b1d9-4ae56c03f47e	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-13 08:04:25.213754+00	
00000000-0000-0000-0000-000000000000	99d03ba7-d808-4f25-ae50-74d5d5cb2f2f	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-13 08:04:25.215129+00	
00000000-0000-0000-0000-000000000000	c79bc5fd-8080-4783-be38-820e73a91cd9	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-13 09:03:55.130664+00	
00000000-0000-0000-0000-000000000000	34024c4c-dc0a-4419-b72c-5e81caf6af68	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-13 09:03:55.131523+00	
00000000-0000-0000-0000-000000000000	6a5fa667-faf2-4779-a9db-d9c2df3e3bad	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-13 10:03:25.072324+00	
00000000-0000-0000-0000-000000000000	c366fef4-c205-4a78-80e4-10aa906f14f9	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-13 10:03:25.073991+00	
00000000-0000-0000-0000-000000000000	493edc7b-0255-4e4f-8faa-0cd4a5752af6	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-13 11:02:55.054121+00	
00000000-0000-0000-0000-000000000000	b07ffb60-7e95-4a15-acc6-90de396e19c5	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-13 11:02:55.05575+00	
00000000-0000-0000-0000-000000000000	47f97ff7-67ff-414d-bdfd-9d0e1e80fcda	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-13 12:02:25.011899+00	
00000000-0000-0000-0000-000000000000	f20bb8f4-e328-4f41-b55d-27b806ef416b	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-13 12:02:25.013456+00	
00000000-0000-0000-0000-000000000000	f9114dc9-4a2f-42b5-abb4-427cfe9228b6	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-13 13:01:54.968388+00	
00000000-0000-0000-0000-000000000000	40ebef54-3178-4f05-a4fa-e3f76ea2dbe1	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-13 13:01:54.971867+00	
00000000-0000-0000-0000-000000000000	41e4ee62-eb6e-496f-a72e-bbca1048b99c	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-13 14:01:14.878672+00	
00000000-0000-0000-0000-000000000000	3b2cb806-ba8a-44fe-82e0-05cadc83b52c	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-13 14:01:14.880141+00	
00000000-0000-0000-0000-000000000000	8154c356-e0a6-4934-b400-d10628ec06b4	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-13 15:00:34.88171+00	
00000000-0000-0000-0000-000000000000	c619250e-e4ee-4075-8228-45761e520bc5	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-13 15:00:34.883727+00	
00000000-0000-0000-0000-000000000000	f892bd31-42d7-4527-8489-e7b3c5c69504	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-13 15:59:54.814878+00	
00000000-0000-0000-0000-000000000000	c45d9147-b502-4ee4-8a0b-6448d7cfc50c	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-13 15:59:54.817719+00	
00000000-0000-0000-0000-000000000000	8480c273-1c69-4d88-b8a4-1badfe518f95	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-13 16:59:14.753722+00	
00000000-0000-0000-0000-000000000000	bfd745a8-3aea-4630-8ed4-c15afe11f430	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-13 16:59:14.7569+00	
00000000-0000-0000-0000-000000000000	d872d0da-2f70-4ae7-af08-b0e51ddb8459	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-13 17:58:34.678498+00	
00000000-0000-0000-0000-000000000000	b93796cf-94b8-4e80-b3c4-8507a14c0904	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-13 17:58:34.681926+00	
00000000-0000-0000-0000-000000000000	c2dddac7-d743-4056-b3fa-4e0f6cf1bd51	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-13 18:57:54.657623+00	
00000000-0000-0000-0000-000000000000	5c2e7913-8a3b-4f0b-aa5d-9db23ada5528	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-13 18:57:54.660063+00	
00000000-0000-0000-0000-000000000000	35aeaed4-c168-4cc5-beb3-9e450a3cf5c6	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-13 19:57:14.60425+00	
00000000-0000-0000-0000-000000000000	11b3c79e-d8ca-4df5-b5c9-6f62aeaaf835	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-13 19:57:14.606729+00	
00000000-0000-0000-0000-000000000000	f086176d-5279-4294-91cb-c34bde304bc9	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-13 20:56:34.55444+00	
00000000-0000-0000-0000-000000000000	1ac08d4e-0cce-41dd-988a-0b99f0f93191	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-13 20:56:34.555985+00	
00000000-0000-0000-0000-000000000000	54e2dc65-3547-44b7-8d28-f89d535ac86b	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-13 21:55:54.518072+00	
00000000-0000-0000-0000-000000000000	2a28550f-924f-4f95-8f60-51e4571be9b2	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-13 21:55:54.519831+00	
00000000-0000-0000-0000-000000000000	64bc5329-0358-4b20-bec0-db2829022d81	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-13 22:55:14.561547+00	
00000000-0000-0000-0000-000000000000	f4448ea5-594f-4376-b370-7ca9029a8ea4	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-13 22:55:14.563259+00	
00000000-0000-0000-0000-000000000000	2699aeff-d72c-49b6-bd97-3c557caec042	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-13 23:54:34.371007+00	
00000000-0000-0000-0000-000000000000	c92b0c7c-e762-424b-8432-a9ae3e4693ed	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-13 23:54:34.371869+00	
00000000-0000-0000-0000-000000000000	219e4818-b213-4149-a6a5-9c32825f5c7b	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-14 00:53:54.363756+00	
00000000-0000-0000-0000-000000000000	25fb3600-3003-4fd9-99c6-cdd9f57aa184	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-14 00:53:54.365793+00	
00000000-0000-0000-0000-000000000000	d500b6bc-b9e2-40bb-9c2a-b6f272943583	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-14 01:53:14.435241+00	
00000000-0000-0000-0000-000000000000	70502a2f-5dac-40c6-9a06-7d9a76ca975b	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-14 01:53:14.437507+00	
00000000-0000-0000-0000-000000000000	266c8e4a-df32-4024-aabd-a1e6f37eef1b	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-14 02:52:34.457364+00	
00000000-0000-0000-0000-000000000000	ab34d7ee-59c0-48b5-a929-23de1020e206	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-14 02:52:34.458952+00	
00000000-0000-0000-0000-000000000000	83fabb03-857a-4923-b099-271371c504a6	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-14 03:51:54.302763+00	
00000000-0000-0000-0000-000000000000	54bdca44-d9b0-46e3-a90a-0bba1d1e7dcf	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-14 03:51:54.304258+00	
00000000-0000-0000-0000-000000000000	89e2fb5a-8055-45f5-9938-f49344b04c66	{"action":"user_modified","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"user"}	2025-01-14 04:38:40.568797+00	
00000000-0000-0000-0000-000000000000	4ea8408c-f193-41d6-bc63-a666404d57c6	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-14 04:51:17.260551+00	
00000000-0000-0000-0000-000000000000	b120870a-db4c-41d3-87d7-bde938d50fd4	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-14 04:51:17.262325+00	
00000000-0000-0000-0000-000000000000	ec99ca6a-261d-4c55-a9ef-7eee4e7a82f9	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-14 05:50:37.288042+00	
00000000-0000-0000-0000-000000000000	7c15b3fb-073f-40c3-809a-aa6d1d5e4a8f	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-14 05:50:37.288887+00	
00000000-0000-0000-0000-000000000000	58c6e9ad-1c06-401e-97e3-81d75df7fa98	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-14 06:49:57.439469+00	
00000000-0000-0000-0000-000000000000	9ad67afe-8687-44fe-8e2c-83743b90b245	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-14 06:49:57.44118+00	
00000000-0000-0000-0000-000000000000	46e70ade-3395-4d7d-8e99-936a06cf9d3b	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-14 07:49:17.169081+00	
00000000-0000-0000-0000-000000000000	bf9fb724-c81f-4d3f-af4e-b209d147b28b	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-14 07:49:17.170685+00	
00000000-0000-0000-0000-000000000000	94cb4f20-168d-49ac-b699-32a9a880f667	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-14 08:48:37.224429+00	
00000000-0000-0000-0000-000000000000	3252ee50-8016-424d-b721-eba1160f11e0	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-14 08:48:37.225291+00	
00000000-0000-0000-0000-000000000000	2dc77739-b172-470b-96f1-e7f9f124960f	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-14 09:47:56.985424+00	
00000000-0000-0000-0000-000000000000	5bcff836-dfb1-45ac-9ce5-03dea99b5998	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-14 09:47:56.988212+00	
00000000-0000-0000-0000-000000000000	8dc34f7c-9d91-48c0-b01f-aae4cce041eb	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-14 10:47:17.124783+00	
00000000-0000-0000-0000-000000000000	129d0d3b-9ba7-42bd-8c7b-e0304b863cb0	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-14 10:47:17.135526+00	
00000000-0000-0000-0000-000000000000	498c88b5-6427-4baa-8cf6-e220ee2d38cc	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-14 11:46:36.94093+00	
00000000-0000-0000-0000-000000000000	22f45d26-fab6-4111-b4aa-d8a02871929a	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-14 11:46:36.943285+00	
00000000-0000-0000-0000-000000000000	9e8cef99-cb8c-4e1a-8d84-2564de6d359b	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-14 12:45:56.860208+00	
00000000-0000-0000-0000-000000000000	df73eae9-3cce-43c1-95e7-f039e1975ac6	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-14 12:45:56.86298+00	
00000000-0000-0000-0000-000000000000	37536708-0059-4e65-aa0d-36b55c205720	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-14 13:45:16.803029+00	
00000000-0000-0000-0000-000000000000	77d17d74-01df-4d45-8b70-7e15415cdb49	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-14 13:45:16.804478+00	
00000000-0000-0000-0000-000000000000	53eefc84-2326-4496-8c46-2feab0bb559b	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-14 14:44:36.891555+00	
00000000-0000-0000-0000-000000000000	71986e6c-31db-495c-9d6d-03a31f1460dd	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-14 14:44:36.893384+00	
00000000-0000-0000-0000-000000000000	88dd2bb3-dc02-4239-bc08-47270f8ab962	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-14 15:43:56.700244+00	
00000000-0000-0000-0000-000000000000	c55b75b8-1f2f-40c4-b13e-f1fc5d0ed701	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-14 15:43:56.702208+00	
00000000-0000-0000-0000-000000000000	3948a1e8-88ce-4bfb-89f7-bea1dd9dd03f	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-14 16:43:16.618621+00	
00000000-0000-0000-0000-000000000000	9d3a75e2-0a9b-4ddf-868c-df182c632aea	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-14 16:43:16.619481+00	
00000000-0000-0000-0000-000000000000	82a7e812-59b3-458b-aefb-575c95d5daca	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-14 17:42:36.641924+00	
00000000-0000-0000-0000-000000000000	5726b533-cdcc-4e05-8afa-06438874c457	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-14 17:42:36.644201+00	
00000000-0000-0000-0000-000000000000	76f29e04-74be-402b-b433-1afef9757616	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-14 22:53:47.61515+00	
00000000-0000-0000-0000-000000000000	f9577093-10a3-4ed5-be9d-850ce5281b1e	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-14 22:53:47.616065+00	
00000000-0000-0000-0000-000000000000	4e5884c2-c794-4748-9723-8c5900c84ff5	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-14 23:53:15.77696+00	
00000000-0000-0000-0000-000000000000	957ce6e0-d493-4b98-89ba-ad7eb3ca3621	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-14 23:53:15.779023+00	
00000000-0000-0000-0000-000000000000	6423013e-d4a1-4c35-b747-35dd9eed92fb	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-15 00:52:44.71128+00	
00000000-0000-0000-0000-000000000000	5f410d13-0f4c-44b2-b503-7869365ee189	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-15 00:52:44.722024+00	
00000000-0000-0000-0000-000000000000	d736a7b3-6369-46c8-8441-fa18aa880486	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-15 01:52:14.253709+00	
00000000-0000-0000-0000-000000000000	e8f972b3-ebe4-474b-8715-6fce074dc0c2	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-15 01:52:14.25701+00	
00000000-0000-0000-0000-000000000000	0e90305f-94e8-4dcb-93ad-8b2d0858e264	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-15 05:43:08.64571+00	
00000000-0000-0000-0000-000000000000	c467c530-fb72-454c-966b-2be17cd27f32	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-15 05:43:08.647677+00	
00000000-0000-0000-0000-000000000000	796d3e32-3bd5-4cbf-9cba-867891b53bd4	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-15 06:42:34.021045+00	
00000000-0000-0000-0000-000000000000	afb33998-c08d-4522-a6be-20eb7b486f7d	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-15 06:42:34.023998+00	
00000000-0000-0000-0000-000000000000	eada4231-3b93-4b43-a941-c17a43ae046e	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-15 07:42:04.027517+00	
00000000-0000-0000-0000-000000000000	43aa894c-8a4e-4e08-9f30-04fb78c7a96c	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-15 07:42:04.029069+00	
00000000-0000-0000-0000-000000000000	03e745e5-e366-4131-8c78-bea893d8141f	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-15 08:41:33.85459+00	
00000000-0000-0000-0000-000000000000	15d2084b-e578-41d2-9abd-68b4f40d2e1a	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-15 08:41:33.857239+00	
00000000-0000-0000-0000-000000000000	bb744097-0f6e-41c2-8199-960bf188d03e	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-15 09:41:03.785522+00	
00000000-0000-0000-0000-000000000000	b3e922b5-674d-44e6-bcf8-05c101e5675a	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-15 09:41:03.788614+00	
00000000-0000-0000-0000-000000000000	7b65ec1e-c823-41d3-9555-abbbe8404588	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-15 10:40:33.753233+00	
00000000-0000-0000-0000-000000000000	3c60e302-8ae9-4420-ab56-9528b7bcba34	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-15 10:40:33.754251+00	
00000000-0000-0000-0000-000000000000	54d090f8-5971-447a-acf4-8bec09e91520	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-15 11:40:03.715127+00	
00000000-0000-0000-0000-000000000000	86ce382c-8d1a-4dad-a964-8789d3f64da9	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-15 11:40:03.718817+00	
00000000-0000-0000-0000-000000000000	006ca738-f292-45ab-a498-7c65008c877d	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-15 12:39:33.638072+00	
00000000-0000-0000-0000-000000000000	f1b719cc-b998-4039-afe0-107077ac3920	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-15 12:39:33.638997+00	
00000000-0000-0000-0000-000000000000	e1617c48-8946-4834-b3ff-316e656e4e5e	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-15 13:39:03.59024+00	
00000000-0000-0000-0000-000000000000	0be79551-3287-4cc6-a82c-9305d0f6e387	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-15 13:39:03.592011+00	
00000000-0000-0000-0000-000000000000	5518a154-0ef3-4b44-bc54-a9fc19917ec8	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-15 14:38:33.571364+00	
00000000-0000-0000-0000-000000000000	e75ce577-81eb-4280-a80b-0847eb599bab	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-15 14:38:33.573046+00	
00000000-0000-0000-0000-000000000000	be04ebcd-5c10-45ec-9ba6-2abb668ef1c9	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-15 15:38:03.510861+00	
00000000-0000-0000-0000-000000000000	e37f1c12-d079-4a1e-adf1-a2d2ca8d5b64	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-15 15:38:03.512761+00	
00000000-0000-0000-0000-000000000000	2fcd6493-fb0d-4379-a863-099586194bad	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-15 18:18:57.214051+00	
00000000-0000-0000-0000-000000000000	96a84af6-4ede-4732-a98b-e869b90c848a	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-15 18:18:57.215956+00	
00000000-0000-0000-0000-000000000000	64e34046-402a-4b69-a2c0-69b50f429995	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-15 23:25:38.13004+00	
00000000-0000-0000-0000-000000000000	1ad3224e-0084-4065-be3d-043078aba424	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-15 23:25:38.13092+00	
00000000-0000-0000-0000-000000000000	7a33d2a4-7365-4488-b04d-6bc42b96029e	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-16 00:25:04.175867+00	
00000000-0000-0000-0000-000000000000	f51b42c7-a21a-4a8a-b3e5-d62f4ed14452	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-16 00:25:04.176719+00	
00000000-0000-0000-0000-000000000000	8ba2d88d-fedb-49e7-a8f4-74f85d340aa2	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-16 01:28:34.99946+00	
00000000-0000-0000-0000-000000000000	85e595fa-8f27-4668-a643-d45086c9adb5	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-16 01:28:35.001157+00	
00000000-0000-0000-0000-000000000000	4bbc18d3-f362-4ed1-9fe2-6b8f2cf9dd74	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-16 02:28:00.239783+00	
00000000-0000-0000-0000-000000000000	f1dc3003-e754-4212-bf80-ed244bc336d7	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-16 02:28:00.243863+00	
00000000-0000-0000-0000-000000000000	c5de83aa-90b5-44af-99b9-c717d787f5f2	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-16 03:27:29.350927+00	
00000000-0000-0000-0000-000000000000	820036ef-832e-408f-9d0b-b04cd76f0e3f	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-16 03:27:29.356277+00	
00000000-0000-0000-0000-000000000000	07d9ab80-74e1-4c43-a298-723b3ee2c93c	{"action":"user_recovery_requested","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"user"}	2025-01-16 04:18:57.147426+00	
00000000-0000-0000-0000-000000000000	80e1da4d-643c-4ee3-b616-549d5a2fb355	{"action":"login","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"account"}	2025-01-16 04:19:20.345441+00	
00000000-0000-0000-0000-000000000000	c32cccd4-3be7-4b53-97f9-529d9f960324	{"action":"user_recovery_requested","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"user"}	2025-01-16 04:28:32.936605+00	
00000000-0000-0000-0000-000000000000	dbaa8f60-2c05-4add-a66c-5d28020a6fa4	{"action":"login","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"account"}	2025-01-16 04:28:43.531036+00	
00000000-0000-0000-0000-000000000000	45adebdb-583f-4231-adfd-a1eb8c1f4a94	{"action":"login","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-01-16 04:38:35.696669+00	
00000000-0000-0000-0000-000000000000	07692375-ef5a-47c1-9a81-5bef38fbe100	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-16 04:40:36.43654+00	
00000000-0000-0000-0000-000000000000	8dc189dd-b6a5-4909-96fb-c5830f00863d	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-16 04:40:36.437416+00	
00000000-0000-0000-0000-000000000000	3dce3b79-1a11-43fc-a190-7d864e5955ab	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-16 05:40:01.354648+00	
00000000-0000-0000-0000-000000000000	9144ca87-75fd-48e0-a36d-2bd22143770c	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-16 05:40:01.3579+00	
00000000-0000-0000-0000-000000000000	9c28ab52-2fc2-4bb3-b965-ff271e3a4672	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-16 06:39:31.372098+00	
00000000-0000-0000-0000-000000000000	f85cde3d-62f5-4b25-8c01-ce1667acd8cc	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-16 06:39:31.37778+00	
00000000-0000-0000-0000-000000000000	971a4a02-9341-4dbe-a0d4-50661d340920	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-16 07:39:02.217863+00	
00000000-0000-0000-0000-000000000000	28903a59-fe4d-4db7-aafc-60e2c58d5ffc	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-16 07:39:02.219937+00	
00000000-0000-0000-0000-000000000000	dadaf031-d8b7-4475-bc32-265617f7ed9f	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-16 08:38:31.208918+00	
00000000-0000-0000-0000-000000000000	5bb92b02-68a7-47f0-bb3a-d5e10416c02f	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-16 08:38:31.209833+00	
00000000-0000-0000-0000-000000000000	710297a3-5af1-4ecf-996c-430d55274c9c	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-16 09:38:01.176541+00	
00000000-0000-0000-0000-000000000000	34fa9ca9-329a-4298-b5af-a0334c609406	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-16 09:38:01.178273+00	
00000000-0000-0000-0000-000000000000	19315b51-e543-4a94-a8bc-d2b1581d1b2c	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-16 10:37:31.22837+00	
00000000-0000-0000-0000-000000000000	699c97dd-0ab5-41a3-af84-69f1cb652cc4	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-16 10:37:31.229209+00	
00000000-0000-0000-0000-000000000000	d323dede-1b7c-4af1-91f1-07ffc8190e65	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-16 11:36:57.337962+00	
00000000-0000-0000-0000-000000000000	4d956b2e-8ec3-42bc-92a6-8804ced607cd	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-16 11:36:57.338887+00	
00000000-0000-0000-0000-000000000000	3363eec1-c197-4923-b6be-7f084e71032d	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-17 00:30:48.450599+00	
00000000-0000-0000-0000-000000000000	e9e72bd3-4e58-4c68-bd92-c1661e4c57d2	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-17 00:30:48.463349+00	
00000000-0000-0000-0000-000000000000	c890831b-cc06-42ee-9460-01afc2a3ad93	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-17 01:30:09.331374+00	
00000000-0000-0000-0000-000000000000	1f71513b-29eb-4be9-9095-00cefe3c1199	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-17 01:30:09.3348+00	
00000000-0000-0000-0000-000000000000	2bd72269-c539-4016-ba37-24ce7d358a83	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-17 02:29:29.198593+00	
00000000-0000-0000-0000-000000000000	4176cb2e-a6c2-4e86-9137-4887c9cd91fd	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-17 02:29:29.200054+00	
00000000-0000-0000-0000-000000000000	3bf74643-e707-4e9b-bd0d-6f7cf5bc174b	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-17 03:31:07.710367+00	
00000000-0000-0000-0000-000000000000	abf2dd48-8b14-49bb-8a79-8609bfcbfb08	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-17 03:31:07.712302+00	
00000000-0000-0000-0000-000000000000	31c52f8e-e21c-452b-96c9-b8d640a24bb2	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-17 04:30:28.832517+00	
00000000-0000-0000-0000-000000000000	fc3b5a0a-4001-4760-a03d-acd7483bde1a	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-17 04:30:28.833368+00	
00000000-0000-0000-0000-000000000000	d2312df0-c83c-44af-b6e9-816fbdc2c5f6	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-17 05:36:57.966234+00	
00000000-0000-0000-0000-000000000000	ca0533e0-8654-4bca-a742-dff66b9251b2	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-17 05:36:57.968724+00	
00000000-0000-0000-0000-000000000000	8c7d8592-1895-4c27-b05f-1f7af38311f6	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-17 06:36:23.788166+00	
00000000-0000-0000-0000-000000000000	c19c6c06-8c39-4125-bcb7-9115c83b15d6	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-17 06:36:23.789028+00	
00000000-0000-0000-0000-000000000000	fe45ac3b-b558-49ba-86c1-6b9c8c95a6c1	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-17 07:35:44.256275+00	
00000000-0000-0000-0000-000000000000	a5da27da-4118-4d16-a176-ddab1dde5b36	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-17 07:35:44.264586+00	
00000000-0000-0000-0000-000000000000	18c603a7-7bfe-4d4a-8138-9dfa44cdd4e5	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-17 08:35:04.401599+00	
00000000-0000-0000-0000-000000000000	4ddd1620-c675-4e4c-a0ed-95561791a311	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-17 08:35:04.405935+00	
00000000-0000-0000-0000-000000000000	eddc703f-9ec5-4a7a-97d7-f2fb07bd7e9e	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-17 09:34:23.65504+00	
00000000-0000-0000-0000-000000000000	bf00673a-9fb7-4e44-a83d-8ee128d47915	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-17 09:34:23.657781+00	
00000000-0000-0000-0000-000000000000	16fb6116-b9d3-48cd-9148-2c0ca5a057ea	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-17 10:33:43.614899+00	
00000000-0000-0000-0000-000000000000	efd4f46e-e08b-4cad-94cc-d761692283c2	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-17 10:33:43.617805+00	
00000000-0000-0000-0000-000000000000	8eff220f-ad95-425b-8bbd-42866f356260	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-17 11:33:04.119174+00	
00000000-0000-0000-0000-000000000000	ef4a4274-0ab5-4d14-8e41-6604d9b216de	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-17 11:33:04.134231+00	
00000000-0000-0000-0000-000000000000	79241b17-059a-455f-a179-da88a8f836f9	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-17 12:37:28.090568+00	
00000000-0000-0000-0000-000000000000	4f4c1ceb-ec01-47d1-a85e-edf8a13c3174	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-17 12:37:28.093216+00	
00000000-0000-0000-0000-000000000000	65f3606c-d53b-4cfd-8958-f36d74e2b324	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-17 19:01:36.742328+00	
00000000-0000-0000-0000-000000000000	7d52f96a-d4de-45f6-a397-759c6121103c	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-17 19:01:36.746304+00	
00000000-0000-0000-0000-000000000000	3eaffb61-d304-4196-b892-9434bd8987b7	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-17 20:01:02.507694+00	
00000000-0000-0000-0000-000000000000	dd1d6e29-043d-4ec4-b479-7964254c4e02	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-17 20:01:02.511135+00	
00000000-0000-0000-0000-000000000000	4b450938-01c7-4e10-9771-0fbb4c1ff5b0	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-17 21:00:22.407475+00	
00000000-0000-0000-0000-000000000000	4d1c1317-de62-449d-9271-82e5d27752fa	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-17 21:00:22.411106+00	
00000000-0000-0000-0000-000000000000	efc1018d-1d3c-4712-911d-d65353d9812b	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-17 21:59:42.614235+00	
00000000-0000-0000-0000-000000000000	68628726-1d8f-4c41-a110-0d276893b5d0	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-17 21:59:42.61779+00	
00000000-0000-0000-0000-000000000000	7036db27-8e52-4ebf-a5fa-cbdae2eee738	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-17 22:59:02.41054+00	
00000000-0000-0000-0000-000000000000	740f1384-d3aa-48a8-8743-45f796546d47	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-17 22:59:02.413369+00	
00000000-0000-0000-0000-000000000000	cc153801-811f-44b0-a790-66b597ac1371	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-17 23:58:22.418171+00	
00000000-0000-0000-0000-000000000000	daaa2da6-ed98-459c-9902-06c481159b64	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-17 23:58:22.42393+00	
00000000-0000-0000-0000-000000000000	da06cec8-972c-454a-9e09-bffe2bce8336	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-18 00:57:42.61344+00	
00000000-0000-0000-0000-000000000000	4ccae938-0d80-463b-b219-23d7fa094335	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-18 00:57:42.616274+00	
00000000-0000-0000-0000-000000000000	67131cd6-feb3-478b-8272-328e827b5db9	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-18 01:57:02.281257+00	
00000000-0000-0000-0000-000000000000	22248f5d-bdab-4292-b8b4-659389212fe6	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-18 01:57:02.28463+00	
00000000-0000-0000-0000-000000000000	00b554de-5241-4afd-a724-57404f44e7a0	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-18 02:56:22.26087+00	
00000000-0000-0000-0000-000000000000	248d2be1-b9ab-4a0a-8cc6-67117ad2a572	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-18 02:56:22.263842+00	
00000000-0000-0000-0000-000000000000	ce075c1e-c99e-4639-b2fc-fe60c0d089a2	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-18 03:55:42.454105+00	
00000000-0000-0000-0000-000000000000	9e320e32-0f47-4474-9f48-4aa533ba9fde	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-18 03:55:42.456236+00	
00000000-0000-0000-0000-000000000000	ca5c33de-2b96-4021-b137-4043feb6fac5	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-18 04:55:02.313201+00	
00000000-0000-0000-0000-000000000000	51e5fdc7-992b-4bf3-ae54-6f5ae78ca8fa	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-18 04:55:02.31594+00	
00000000-0000-0000-0000-000000000000	41bcc27c-a7f5-4796-bde7-c0344b583231	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-18 05:54:22.130685+00	
00000000-0000-0000-0000-000000000000	64cbb59c-b7f6-4b4a-ae96-2766229cbe56	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-18 05:54:22.133569+00	
00000000-0000-0000-0000-000000000000	771b7dae-0808-4b48-9a94-e29988e24fae	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-18 06:53:52.484022+00	
00000000-0000-0000-0000-000000000000	3acb64c4-6cfc-41e3-993c-df48c98073b5	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-18 06:53:52.486802+00	
00000000-0000-0000-0000-000000000000	03744215-b1bb-49eb-ac77-ebd988eed462	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-18 07:53:12.012639+00	
00000000-0000-0000-0000-000000000000	db9354f2-340b-43b6-8cc7-9fc18e1e256a	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-18 07:53:12.01599+00	
00000000-0000-0000-0000-000000000000	4bf61941-c656-4078-84ac-bbd13991c8dd	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-18 08:52:32.009122+00	
00000000-0000-0000-0000-000000000000	676f78b2-b23f-4705-a78d-b3011094c657	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-18 08:52:32.011049+00	
00000000-0000-0000-0000-000000000000	3054ad73-309a-463a-9da0-d11988ff78d7	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-18 09:51:52.231637+00	
00000000-0000-0000-0000-000000000000	2cca0f5f-02ed-4468-b6a9-fffb7e0b6953	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-18 09:51:52.233589+00	
00000000-0000-0000-0000-000000000000	1910439d-2bcb-4865-a890-bc7241fe837f	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-18 10:51:11.938959+00	
00000000-0000-0000-0000-000000000000	181f887c-9227-42be-a8c3-22f6a2e9a3b6	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-18 10:51:11.945103+00	
00000000-0000-0000-0000-000000000000	66ae0df9-947f-4d7a-b1a8-9c20fa019136	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-18 11:50:31.773602+00	
00000000-0000-0000-0000-000000000000	f08f3a08-ff1a-4e62-8cc4-ae47ca0e1eb0	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-18 11:50:31.775503+00	
00000000-0000-0000-0000-000000000000	a7fd7d69-1f3c-4e88-bc4f-fd5d52373759	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-18 12:49:50.111036+00	
00000000-0000-0000-0000-000000000000	8d23fca4-4bfa-4e27-a263-6d0fb954d59b	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-18 12:49:50.111852+00	
00000000-0000-0000-0000-000000000000	728f6399-cf34-4799-b4ca-7ef36966b99a	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-18 13:49:13.098846+00	
00000000-0000-0000-0000-000000000000	cb0404c0-4fe9-4300-b788-31b2d5730b14	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-18 13:49:13.100401+00	
00000000-0000-0000-0000-000000000000	5334e1c8-602f-4fc1-b75d-b482cda4f15e	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-18 14:48:34.857056+00	
00000000-0000-0000-0000-000000000000	5a24025a-ae6a-4865-b01c-693595f722ff	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-18 14:48:34.857971+00	
00000000-0000-0000-0000-000000000000	0e7f51ff-7cba-486d-a17d-824d6d7fc1cf	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-18 15:47:54.818561+00	
00000000-0000-0000-0000-000000000000	40179967-8e35-4808-9818-b1d7847b272d	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-18 15:47:54.820372+00	
00000000-0000-0000-0000-000000000000	04a7667c-3a7a-40fc-bfed-b2550ccb7512	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-18 16:47:14.681892+00	
00000000-0000-0000-0000-000000000000	24b9e9de-032e-4da7-8346-f2f1a248e6a4	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-18 16:47:14.683652+00	
00000000-0000-0000-0000-000000000000	8f3134d5-0f89-4e25-93a6-81329c26cef0	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-18 17:46:34.621815+00	
00000000-0000-0000-0000-000000000000	f31a490d-84a0-498e-bcf3-5b4806b5c8ee	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-18 17:46:34.62278+00	
00000000-0000-0000-0000-000000000000	854f171d-b9de-4fe5-a5ed-6a56064cd9c0	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-18 18:46:04.505745+00	
00000000-0000-0000-0000-000000000000	fe35c121-3129-479c-bcb1-7c6855fbbf87	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-18 18:46:04.507917+00	
00000000-0000-0000-0000-000000000000	a9dbe6b9-d922-4df8-a3a6-1590cc84837b	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-18 19:45:34.54989+00	
00000000-0000-0000-0000-000000000000	7bcd640e-360b-4530-b9c3-827105d00bab	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-18 19:45:34.552383+00	
00000000-0000-0000-0000-000000000000	136abae5-daaf-4e9a-9737-812486c27842	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-18 20:45:04.386777+00	
00000000-0000-0000-0000-000000000000	8d289bb9-52f9-456f-b47d-56991acbb7a6	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-18 20:45:04.38831+00	
00000000-0000-0000-0000-000000000000	b99cf86a-5d22-4008-b89d-e80c92fa2a54	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-18 21:44:34.447519+00	
00000000-0000-0000-0000-000000000000	73156585-aa40-4b37-bd73-9d15ae76d3aa	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-18 21:44:34.448969+00	
00000000-0000-0000-0000-000000000000	dea2843f-e0cf-467f-b068-848923762392	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-18 22:44:04.34619+00	
00000000-0000-0000-0000-000000000000	c9fda9bb-5261-4b49-9734-b2ddf8daee47	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-18 22:44:04.347871+00	
00000000-0000-0000-0000-000000000000	12573123-6e27-4bcc-ba3f-ed4129c31a82	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-18 23:43:34.482951+00	
00000000-0000-0000-0000-000000000000	c5546ca5-e8f2-404b-b73a-3e53dbcee9de	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-18 23:43:34.484522+00	
00000000-0000-0000-0000-000000000000	8723c992-dbe3-4b8b-b008-a12f0761bae6	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-19 00:42:59.740289+00	
00000000-0000-0000-0000-000000000000	e47d6632-c679-47d5-afa4-f32114cec151	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-19 00:42:59.741968+00	
00000000-0000-0000-0000-000000000000	099bb263-e76e-4c71-ac34-7a3abaeb5236	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-19 22:31:19.850807+00	
00000000-0000-0000-0000-000000000000	363cd020-e4a7-4a25-82c1-1d8fffbabda0	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-19 22:31:19.864507+00	
00000000-0000-0000-0000-000000000000	4b5128c8-42e8-4f05-9766-c01afef199cf	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-19 23:47:50.482089+00	
00000000-0000-0000-0000-000000000000	f593fb40-a5a0-4127-9606-6bf623ba18ba	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-19 23:47:50.484961+00	
00000000-0000-0000-0000-000000000000	b496e042-8a6e-494f-a9b4-d4c60cbc4e33	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-20 00:47:12.334193+00	
00000000-0000-0000-0000-000000000000	3fd83aaf-e70d-47c6-89a6-a0f158ceb703	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-20 00:47:12.335512+00	
00000000-0000-0000-0000-000000000000	410daa28-fbd3-49a4-9659-331e7dcb57fc	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-20 01:46:37.263243+00	
00000000-0000-0000-0000-000000000000	f1ec565d-7c48-4d4c-9f07-53d936cfd469	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-20 01:46:37.268508+00	
00000000-0000-0000-0000-000000000000	8e94fdab-5d24-4efb-b7e1-1329dbdf89a7	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-20 02:45:57.077661+00	
00000000-0000-0000-0000-000000000000	8efdeca0-eb9c-452c-87b6-51de16abcca3	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-20 02:45:57.078501+00	
00000000-0000-0000-0000-000000000000	e993c180-f746-4c2f-80de-714a05aaf570	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-20 03:45:17.738742+00	
00000000-0000-0000-0000-000000000000	30ba4e1c-432a-41d7-87d0-affb4edaa4c7	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-20 03:45:17.739618+00	
00000000-0000-0000-0000-000000000000	31936d12-47fe-49a9-bc52-415d841ff893	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-20 04:52:39.568978+00	
00000000-0000-0000-0000-000000000000	0d04419c-a39d-44dc-8403-5f834c007c74	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-20 04:52:39.569848+00	
00000000-0000-0000-0000-000000000000	7bdcf4b1-9598-433e-bea8-54cf104a9c8e	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-20 05:52:00.136196+00	
00000000-0000-0000-0000-000000000000	e07018bc-6607-43aa-89fc-760df698a02e	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-20 05:52:00.137726+00	
00000000-0000-0000-0000-000000000000	344677b6-5919-45b0-9983-f9448c6b7462	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-20 06:51:26.838534+00	
00000000-0000-0000-0000-000000000000	7c6f8921-654c-4086-9bef-d71ccc7e9319	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-20 06:51:26.842807+00	
00000000-0000-0000-0000-000000000000	e797b79b-459b-4bba-b441-cddded416764	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-20 07:50:49.495095+00	
00000000-0000-0000-0000-000000000000	0877aa4c-083a-4725-bbc2-2a61c30c9721	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-20 07:50:49.496905+00	
00000000-0000-0000-0000-000000000000	8d034bb3-4951-44e9-9ee4-8bed8437182d	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-20 08:50:09.490844+00	
00000000-0000-0000-0000-000000000000	1847750b-acda-48eb-808d-a12554482ebd	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-20 08:50:09.495005+00	
00000000-0000-0000-0000-000000000000	5efbd00d-63fc-4e2c-b551-e755ce629250	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-20 09:49:30.181558+00	
00000000-0000-0000-0000-000000000000	d7f177e4-d0b9-4a3a-a464-ec6480715a4c	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-20 09:49:30.183957+00	
00000000-0000-0000-0000-000000000000	1f5ab655-ebe8-4287-b851-49141867503f	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-20 10:48:48.773373+00	
00000000-0000-0000-0000-000000000000	1040f67a-8eb1-4254-9d3d-47062ea37de7	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-20 10:48:48.774239+00	
00000000-0000-0000-0000-000000000000	0edb9780-ad77-473c-95c9-d5107247e63d	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-20 11:48:09.384962+00	
00000000-0000-0000-0000-000000000000	171dbf55-0f8c-4a55-8eaa-0103525e6793	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-20 11:48:09.387346+00	
00000000-0000-0000-0000-000000000000	4b229b03-c6a9-4a24-bfb1-143e192b141a	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-20 12:47:28.639926+00	
00000000-0000-0000-0000-000000000000	4a12e66c-a4fe-4ed8-8fca-2f1b86ce6777	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-20 12:47:28.642515+00	
00000000-0000-0000-0000-000000000000	796131b0-47e8-4c08-9257-fbdbaa60330f	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-20 13:46:49.482559+00	
00000000-0000-0000-0000-000000000000	2b26818f-2c4c-40e2-a499-25171cef9c47	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-20 13:46:49.484985+00	
00000000-0000-0000-0000-000000000000	cf84253c-70b9-475d-958a-d9414d94986c	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-20 14:46:09.523111+00	
00000000-0000-0000-0000-000000000000	399ca88a-457e-4352-a500-e3bd4ea59a46	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-20 14:46:09.526219+00	
00000000-0000-0000-0000-000000000000	82416297-496d-44f3-97bc-d4c44e2b67cc	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-20 15:45:28.48895+00	
00000000-0000-0000-0000-000000000000	5aff708a-bab0-4fda-b8c2-97d56fe3b250	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-20 15:45:28.491297+00	
00000000-0000-0000-0000-000000000000	8e803e25-4fc4-4d2d-9b9b-552ad469132c	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-20 16:44:48.549627+00	
00000000-0000-0000-0000-000000000000	adcf8c16-1807-45df-8f68-7b82ebffce8c	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-20 16:44:48.552272+00	
00000000-0000-0000-0000-000000000000	99dd0b6f-2db1-4a97-96ce-dfa55bbc9f11	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-20 17:44:09.12063+00	
00000000-0000-0000-0000-000000000000	baa7e536-d060-4dad-8ecc-53a5d57f497b	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-20 17:44:09.122017+00	
00000000-0000-0000-0000-000000000000	bfc3f51b-7360-40fd-a929-e1a6ffc610ad	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-20 18:43:28.911201+00	
00000000-0000-0000-0000-000000000000	b28e29fd-afbd-4edf-a67d-a5de18dee7c3	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-20 18:43:28.9132+00	
00000000-0000-0000-0000-000000000000	0a9ed703-577f-4e27-926f-ab07d944e6da	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-20 19:42:50.744309+00	
00000000-0000-0000-0000-000000000000	851fa142-36c3-49f7-a1b0-aaba43f312b4	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-20 19:42:50.745913+00	
00000000-0000-0000-0000-000000000000	a18ef41f-0fb5-4f3d-afbc-5d8d2f3b355a	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-20 20:42:22.9761+00	
00000000-0000-0000-0000-000000000000	0b679d2e-57ce-4860-b345-73b47e7dce49	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-20 20:42:22.979153+00	
00000000-0000-0000-0000-000000000000	879c5668-5ef5-4b13-afdd-1efcdc1cdf14	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-20 21:41:50.922426+00	
00000000-0000-0000-0000-000000000000	09485b40-cbff-4318-a5ea-77d07e787ca2	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-20 21:41:50.924751+00	
00000000-0000-0000-0000-000000000000	351adefc-0469-4ce2-8e93-710c8df88e05	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-20 22:41:09.598098+00	
00000000-0000-0000-0000-000000000000	222135dd-9dd0-4734-9f3f-060bbcc8ed4c	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-20 22:41:09.600086+00	
00000000-0000-0000-0000-000000000000	2f6c22e4-8e5c-4a22-bc9d-533e0c9fbac4	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-20 23:40:30.033401+00	
00000000-0000-0000-0000-000000000000	f38f6a30-b8df-412a-892c-2bd4206fcf63	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-20 23:40:30.03425+00	
00000000-0000-0000-0000-000000000000	44af10cb-99e9-4a27-9fd5-75f76b6d58d3	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-21 01:33:41.853765+00	
00000000-0000-0000-0000-000000000000	0a8a4945-1416-4629-9997-34d513e6d18c	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-21 01:33:41.855346+00	
00000000-0000-0000-0000-000000000000	06be345d-cac5-49ce-b672-06eeb62efc04	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-21 10:16:59.519049+00	
00000000-0000-0000-0000-000000000000	26e7d7e4-088c-45c4-b38b-1b0a4e7cdd56	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-21 10:16:59.528711+00	
00000000-0000-0000-0000-000000000000	20475453-2fbb-46cf-be6c-7c1c0fd14fcc	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-21 11:16:31.168954+00	
00000000-0000-0000-0000-000000000000	653cf999-ec35-4885-b5e7-0306b3ce5a65	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-21 11:16:31.171228+00	
00000000-0000-0000-0000-000000000000	c3ff36ae-2982-419a-92d6-1c446fd0f2cd	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-21 12:16:01.071995+00	
00000000-0000-0000-0000-000000000000	70b0d864-f258-46b3-8dfc-7b51f637bc51	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-21 12:16:01.07467+00	
00000000-0000-0000-0000-000000000000	544a633a-24c9-45c9-af10-e89c6ce6a41a	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-21 13:15:31.056138+00	
00000000-0000-0000-0000-000000000000	ecda1a14-1a3c-4532-bcd2-d77e2c47244c	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-21 13:15:31.058789+00	
00000000-0000-0000-0000-000000000000	a7a60a3c-b401-4639-87a5-4ff1226ec0e4	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-21 14:15:01.024916+00	
00000000-0000-0000-0000-000000000000	35810a8d-846c-46c2-8a73-ae8766ffd181	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-21 14:15:01.026855+00	
00000000-0000-0000-0000-000000000000	2efe80bd-b778-4b41-959d-1b4cca367673	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-21 15:14:30.95013+00	
00000000-0000-0000-0000-000000000000	31ba3c9e-3e0f-466e-83d3-543ec41f47cf	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-21 15:14:30.952773+00	
00000000-0000-0000-0000-000000000000	34b99083-1183-4e05-bc41-acb195e290a8	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-21 16:14:00.875473+00	
00000000-0000-0000-0000-000000000000	d75214b8-8b1d-4c56-acbd-df7409e9554c	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-21 16:14:00.878003+00	
00000000-0000-0000-0000-000000000000	0b7d3a37-040b-43d3-80a0-7b10405bc5f7	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-21 17:13:30.847159+00	
00000000-0000-0000-0000-000000000000	d87f8312-a0b7-4869-a9b4-7b33c566613f	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-21 17:13:30.850846+00	
00000000-0000-0000-0000-000000000000	66df6aeb-9ed8-488d-97eb-e39b46cdf05b	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-21 18:13:00.7486+00	
00000000-0000-0000-0000-000000000000	9367f0d0-27f2-4940-b250-1e097cfccd8b	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-21 18:13:00.750412+00	
00000000-0000-0000-0000-000000000000	873f8469-ea11-41aa-8225-f8a2ea2b7440	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-21 19:22:24.144872+00	
00000000-0000-0000-0000-000000000000	ef7ba3fa-1b0a-4bc4-b236-40212b744e65	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-21 19:22:24.147033+00	
00000000-0000-0000-0000-000000000000	7d9c4fe9-a396-4c6b-afe2-ba19b3088334	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-21 20:21:54.256327+00	
00000000-0000-0000-0000-000000000000	7a8ae22d-e466-4d34-9070-305e1219e5c5	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-21 20:21:54.259327+00	
00000000-0000-0000-0000-000000000000	0f73af29-eb19-4c5c-92c1-8647abcb8aef	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-22 23:21:48.620732+00	
00000000-0000-0000-0000-000000000000	0a419b8c-dc4a-4b80-88cd-6ed77177aaf0	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-22 23:21:48.635089+00	
00000000-0000-0000-0000-000000000000	99be4848-1118-430d-bfb0-9ba85a57f91e	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-23 00:21:17.85073+00	
00000000-0000-0000-0000-000000000000	43a84be5-8b5d-4388-ad16-93f34fbd17a9	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-23 00:21:17.860724+00	
00000000-0000-0000-0000-000000000000	8f175a3a-8d7e-4979-b040-ca749d5de987	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-24 06:23:08.181461+00	
00000000-0000-0000-0000-000000000000	bb47ecce-fb64-4f60-8728-795b60b02cd8	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-24 06:23:08.208865+00	
00000000-0000-0000-0000-000000000000	51bb55b9-15b4-4f05-993d-dd54053629b8	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-24 11:38:00.320601+00	
00000000-0000-0000-0000-000000000000	9bbcac93-e165-46ae-aee9-37e172e1cb86	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-24 11:38:00.331403+00	
00000000-0000-0000-0000-000000000000	542c7a3d-d5e0-4bc8-ade3-219dbf217dc7	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-24 12:37:26.940026+00	
00000000-0000-0000-0000-000000000000	083cc82c-250b-45cd-bb2b-e7b22259c428	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-24 12:37:26.943662+00	
00000000-0000-0000-0000-000000000000	4d80cfc9-96a4-4f61-8beb-3c3ba5a5a363	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-24 13:36:50.337051+00	
00000000-0000-0000-0000-000000000000	a96e45a1-1481-491d-8bf3-0083c88e1d62	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-24 13:36:50.349777+00	
00000000-0000-0000-0000-000000000000	007bc75a-f526-4951-99be-cda7edda4741	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-24 14:36:20.36194+00	
00000000-0000-0000-0000-000000000000	7bd0292e-ea58-466b-b620-9068cc491a4c	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-24 14:36:20.364641+00	
00000000-0000-0000-0000-000000000000	8e8a7b6c-6a8c-4ac5-ad5c-96ae0526a1cb	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-24 15:35:50.364056+00	
00000000-0000-0000-0000-000000000000	1a3ebf82-14ed-4dbf-893d-432a49427cba	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-24 15:35:50.37693+00	
00000000-0000-0000-0000-000000000000	d277249a-3e7d-49de-9295-bec71647653d	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-24 16:35:17.272834+00	
00000000-0000-0000-0000-000000000000	9f5ded94-7ad3-4f3a-8886-472a1f252d74	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-24 16:35:17.275264+00	
00000000-0000-0000-0000-000000000000	b710b458-0ea5-41cd-aa60-c7d5071d462c	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-24 17:34:42.577054+00	
00000000-0000-0000-0000-000000000000	704b29e2-2f82-4b70-808b-46296c55d7d0	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-24 17:34:42.58329+00	
00000000-0000-0000-0000-000000000000	85c7d73e-2c62-43a2-9fe8-864ae3dd18dd	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-24 18:44:59.422702+00	
00000000-0000-0000-0000-000000000000	8b57064c-8af6-4eb0-873e-43eb2a35b45b	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-24 18:44:59.434118+00	
00000000-0000-0000-0000-000000000000	4cda15c4-26b8-4bb8-abec-df5b33b51524	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-24 20:43:31.432532+00	
00000000-0000-0000-0000-000000000000	e70db06e-e698-45bb-845b-797c1157c277	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-24 20:43:31.438933+00	
00000000-0000-0000-0000-000000000000	039aa84d-3f90-485b-8f41-465a478d6634	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-24 21:42:58.878933+00	
00000000-0000-0000-0000-000000000000	d0bc8aba-68f7-43e5-99cf-0905f0ad39ff	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-24 21:42:58.880666+00	
00000000-0000-0000-0000-000000000000	45a6385d-6309-451a-b83f-d9284cef5193	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-24 22:42:18.785819+00	
00000000-0000-0000-0000-000000000000	5a9f32f3-a49b-4116-a1b2-a6b53e99718b	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-24 22:42:18.788192+00	
00000000-0000-0000-0000-000000000000	3e96cfae-8384-4480-bb42-b3c36943feb6	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-24 23:41:38.76302+00	
00000000-0000-0000-0000-000000000000	72fb5b19-c251-45f9-9ff8-082040c9664a	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-24 23:41:38.76603+00	
00000000-0000-0000-0000-000000000000	ad894995-a675-4851-83a5-358cedd6a802	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-25 00:40:58.696423+00	
00000000-0000-0000-0000-000000000000	62131df6-893e-4e63-ab73-867cad7b09ae	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-25 00:40:58.699575+00	
00000000-0000-0000-0000-000000000000	efb4d455-76e3-46ab-ae42-b34d42e88c2a	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-25 01:42:41.511296+00	
00000000-0000-0000-0000-000000000000	92033f01-8a21-4e03-ad2b-958c8b9ef17e	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-25 01:42:41.515206+00	
00000000-0000-0000-0000-000000000000	e160535e-6a54-45d5-83b8-6260907e6881	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-25 03:12:45.545734+00	
00000000-0000-0000-0000-000000000000	3831c059-b7d8-4dc6-8456-5ba6ab949717	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-25 03:12:45.550969+00	
00000000-0000-0000-0000-000000000000	7d1b33b7-22b4-4f12-a0df-e83a52ff4b7c	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-25 04:12:09.482344+00	
00000000-0000-0000-0000-000000000000	c461571c-153c-449a-911e-6404e3a0384a	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-25 04:12:09.485783+00	
00000000-0000-0000-0000-000000000000	6a33b529-499a-4b03-b804-7f49736384db	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-25 06:03:24.601157+00	
00000000-0000-0000-0000-000000000000	b9a14f0a-0b09-4bbb-b9b6-aa14ce9f274d	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-25 06:03:24.60821+00	
00000000-0000-0000-0000-000000000000	1a10724e-5c5d-4147-a52d-d3ed583c1d5e	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-25 07:36:24.631637+00	
00000000-0000-0000-0000-000000000000	95207f63-91c3-4ff0-a074-1b4c54bcd572	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-25 07:36:24.63956+00	
00000000-0000-0000-0000-000000000000	7fa696e6-e8e6-4172-8769-7c81d3d2dd3f	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-25 08:35:47.911462+00	
00000000-0000-0000-0000-000000000000	d6a1cda0-5f23-4730-8e23-6b618abf4f8e	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-25 08:35:47.914791+00	
00000000-0000-0000-0000-000000000000	d2c430ad-9179-448a-8821-794aafa77b36	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-25 09:35:07.844056+00	
00000000-0000-0000-0000-000000000000	6a2fafaf-0205-4d86-abad-09893df7998d	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-25 09:35:07.845473+00	
00000000-0000-0000-0000-000000000000	71b8a152-2106-4eb5-8ac2-be0484ce527d	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-25 10:34:27.978648+00	
00000000-0000-0000-0000-000000000000	29524abb-da54-49a5-b005-1f0333ba8eff	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-25 10:34:27.980138+00	
00000000-0000-0000-0000-000000000000	6c987fb8-f3c4-4360-960a-2e1a230fe4fa	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-25 11:33:47.731104+00	
00000000-0000-0000-0000-000000000000	9f1bb2ce-de2c-400b-b134-0e2c70b5755a	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-25 11:33:47.732517+00	
00000000-0000-0000-0000-000000000000	bca65930-c820-4d01-86c8-61ea320e46f3	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-25 12:33:07.662792+00	
00000000-0000-0000-0000-000000000000	f21c0520-2d2b-46d3-8733-f4c24afe72cb	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-25 12:33:07.666421+00	
00000000-0000-0000-0000-000000000000	d765ff0e-31f0-49c7-9112-f9b7c5360c3c	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-25 13:32:27.639775+00	
00000000-0000-0000-0000-000000000000	ffdfa1e0-5d20-4c9d-86ab-05fb095db9e8	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-25 13:32:27.642648+00	
00000000-0000-0000-0000-000000000000	08bb4fbe-7cf4-4918-ad57-1e736290216a	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-25 14:31:47.832019+00	
00000000-0000-0000-0000-000000000000	1647fd7f-d97f-4ebd-8dfe-3eab6d6fabed	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-25 14:31:47.834907+00	
00000000-0000-0000-0000-000000000000	d3c9b2e1-a5db-4d99-bbdf-d069ff297376	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-25 17:44:04.578356+00	
00000000-0000-0000-0000-000000000000	cf12a1cc-749f-4b79-a3b9-df225c689ea1	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-25 17:44:04.583186+00	
00000000-0000-0000-0000-000000000000	6fe681c7-28cf-43a5-8e6d-8c23e1c4b7e7	{"action":"user_modified","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"user"}	2025-01-25 18:04:16.739684+00	
00000000-0000-0000-0000-000000000000	a64cdac1-9c72-4665-91e3-a0b2823e35c3	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-25 22:01:08.998402+00	
00000000-0000-0000-0000-000000000000	f0b50d09-9ac2-4224-9bc8-c49384c18cc1	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-25 22:01:09.015654+00	
00000000-0000-0000-0000-000000000000	12bf2732-db66-4c2a-b2bf-453720ca6c95	{"action":"user_modified","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"user"}	2025-01-25 22:09:42.114213+00	
00000000-0000-0000-0000-000000000000	d5e1064b-c2b4-43de-a19f-8db296fdb051	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-26 07:46:17.020564+00	
00000000-0000-0000-0000-000000000000	50a6e132-1415-4300-8aa5-6774d1ab4539	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-26 07:46:17.040051+00	
00000000-0000-0000-0000-000000000000	fca668e6-9a32-4946-81d7-24cfadbd944b	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-27 00:38:52.258664+00	
00000000-0000-0000-0000-000000000000	0f955fac-41d6-456c-b325-5eb8c4014adb	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-27 00:38:52.295292+00	
00000000-0000-0000-0000-000000000000	bf109018-2f12-4dc1-8c2f-cbd9837d87c0	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-27 01:38:16.296192+00	
00000000-0000-0000-0000-000000000000	92132199-5378-472c-88fe-c8638a680fd0	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-27 01:38:16.299775+00	
00000000-0000-0000-0000-000000000000	b7678094-88df-4b01-b75f-e0a29865a86f	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-27 02:37:43.987536+00	
00000000-0000-0000-0000-000000000000	cd4b9d85-fd97-4d89-984b-6a6d259a8192	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-27 02:37:43.989768+00	
00000000-0000-0000-0000-000000000000	0e0f1025-5a5c-43a8-84ea-5624f34ec3be	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-27 03:37:08.557585+00	
00000000-0000-0000-0000-000000000000	426236c7-6ee6-4f4a-8b19-d7fe969d6119	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-27 03:37:08.559088+00	
00000000-0000-0000-0000-000000000000	13e02d68-2071-4213-a5a2-05aec5362829	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-27 04:38:34.025131+00	
00000000-0000-0000-0000-000000000000	cc24692a-63e2-4414-9805-46d47532ceac	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-27 04:38:34.028763+00	
00000000-0000-0000-0000-000000000000	8530bbba-9996-49ca-b0dd-07f3355051b1	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-27 05:38:01.534623+00	
00000000-0000-0000-0000-000000000000	c177ac02-95e4-4635-841b-fa4595619df0	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-27 05:38:01.53551+00	
00000000-0000-0000-0000-000000000000	ca932e88-3f4b-430a-9439-10f5c60041df	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-27 06:37:21.498978+00	
00000000-0000-0000-0000-000000000000	9fa0c610-7738-4390-aa70-bcaee06c8c04	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-27 06:37:21.49984+00	
00000000-0000-0000-0000-000000000000	524f2beb-4657-47da-846a-2de7bcd70c37	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-27 07:36:41.556273+00	
00000000-0000-0000-0000-000000000000	a39811eb-ee13-4725-b207-16fc23d97684	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-27 07:36:41.562894+00	
00000000-0000-0000-0000-000000000000	b5bd6d36-8906-472c-932a-e8a0fc4b6fee	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-27 08:36:01.410302+00	
00000000-0000-0000-0000-000000000000	2c86f7d1-a2d9-4cf4-9283-17ef80d18ab9	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-27 08:36:01.41182+00	
00000000-0000-0000-0000-000000000000	c9978621-3384-4bcd-9572-a630ec07f464	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-27 09:35:21.28174+00	
00000000-0000-0000-0000-000000000000	84339f6d-2a34-482b-89e1-76b7be49eae1	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-27 09:35:21.284048+00	
00000000-0000-0000-0000-000000000000	c7d526a5-1a06-4288-956d-873fb1f9cc2d	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-27 10:34:41.400822+00	
00000000-0000-0000-0000-000000000000	ec0ff451-94d2-47e9-8458-fcedc6de01ba	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-27 10:34:41.404832+00	
00000000-0000-0000-0000-000000000000	442d4ea3-b2bb-4027-9b36-e854a4c44894	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-27 11:34:01.566262+00	
00000000-0000-0000-0000-000000000000	8a20b091-09a0-4015-8577-332809cf944c	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-27 11:34:01.56937+00	
00000000-0000-0000-0000-000000000000	e8eb0a83-8e25-4399-bc29-2896201f1253	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-27 12:33:21.150955+00	
00000000-0000-0000-0000-000000000000	af22e4f8-ca51-4ada-99f7-f19bcb5d8514	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-27 12:33:21.153557+00	
00000000-0000-0000-0000-000000000000	fc8c0409-f9d1-48b8-b962-39df0c4adaf4	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-27 13:32:41.097634+00	
00000000-0000-0000-0000-000000000000	a9e406f7-e77c-48f2-9ea3-a4fec8944310	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-27 13:32:41.100925+00	
00000000-0000-0000-0000-000000000000	9a67299d-b5f1-40e2-b562-fef0ccf9e8c4	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-27 14:32:01.096773+00	
00000000-0000-0000-0000-000000000000	c2730ceb-8909-49f1-b5e8-675a792a92eb	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-27 14:32:01.10582+00	
00000000-0000-0000-0000-000000000000	4b18a7e0-0362-43d8-8489-2d7d25a35daf	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-27 15:31:21.083177+00	
00000000-0000-0000-0000-000000000000	6abde3a3-3a5e-4191-80ef-6b4decafd5ae	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-27 15:31:21.085719+00	
00000000-0000-0000-0000-000000000000	33e10915-83a9-44ae-ae93-e5fa2bd96321	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-27 16:30:41.379798+00	
00000000-0000-0000-0000-000000000000	2bd12443-0359-42ba-a083-5abb92af30b6	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-27 16:30:41.382725+00	
00000000-0000-0000-0000-000000000000	284e74c2-a0bd-4a92-aa13-a2853e42c231	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-27 17:30:00.948672+00	
00000000-0000-0000-0000-000000000000	8b896537-fdaf-4255-947b-94fefedbc24e	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-27 17:30:00.951155+00	
00000000-0000-0000-0000-000000000000	dfd276fd-a98d-4973-9a41-1c6015131555	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-27 18:29:20.878342+00	
00000000-0000-0000-0000-000000000000	65af64fd-86ae-4511-8ceb-b88d2025714b	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-27 18:29:20.881093+00	
00000000-0000-0000-0000-000000000000	7f134aec-f7ea-4c60-8653-e96985eeff82	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-27 19:28:40.906908+00	
00000000-0000-0000-0000-000000000000	00871afd-c755-4cab-b69c-466466f88e09	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-27 19:28:40.909603+00	
00000000-0000-0000-0000-000000000000	2ba9b000-4fa0-48c0-b80d-89db91f652c2	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-27 20:28:00.775055+00	
00000000-0000-0000-0000-000000000000	0f767d10-4127-46ef-997e-b0d96a37a0d7	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-27 20:28:00.778064+00	
00000000-0000-0000-0000-000000000000	52c48e10-c048-4284-89dd-96c6d798b07b	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-27 21:27:20.814924+00	
00000000-0000-0000-0000-000000000000	c11b2a88-50d3-41ea-b575-315d68b0a601	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-27 21:27:20.81771+00	
00000000-0000-0000-0000-000000000000	048c5aab-16be-4a74-80c5-2ed316e523d6	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-27 22:26:40.693418+00	
00000000-0000-0000-0000-000000000000	495ae163-2dd4-4e89-8392-a11dd875e4d5	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-27 22:26:40.696058+00	
00000000-0000-0000-0000-000000000000	c58169ce-2364-41c1-92d6-c009ddcfc974	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-27 23:26:00.666908+00	
00000000-0000-0000-0000-000000000000	a98162e2-1faa-4d01-93fb-b16422f4753a	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-27 23:26:00.669071+00	
00000000-0000-0000-0000-000000000000	4a3e82c0-83e5-4483-bcd2-882f3ed4ea81	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-28 00:25:22.091414+00	
00000000-0000-0000-0000-000000000000	62da304e-b163-480c-ae0e-81bd33718309	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-28 00:25:22.096047+00	
00000000-0000-0000-0000-000000000000	d98425f9-3527-4df2-a294-feb9455a7c2f	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-28 01:25:47.617949+00	
00000000-0000-0000-0000-000000000000	97097f6c-6ecf-4037-b3fd-44b88643b5ff	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-28 01:25:47.625257+00	
00000000-0000-0000-0000-000000000000	af879543-577f-40d6-a876-ada2d0ffe820	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-28 03:51:22.394156+00	
00000000-0000-0000-0000-000000000000	7e744a0c-6242-45ca-a82f-ff57c933ce14	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-28 03:51:22.399775+00	
00000000-0000-0000-0000-000000000000	304ebe22-6e83-4fce-a26c-d0fe69b0fcd5	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-28 04:50:44.639819+00	
00000000-0000-0000-0000-000000000000	6969aa57-7437-47dd-83b0-0acb328987e7	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-28 04:50:44.643374+00	
00000000-0000-0000-0000-000000000000	6906ce85-38a6-409c-9494-1b250f213a0b	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-28 05:50:04.669136+00	
00000000-0000-0000-0000-000000000000	69ebb4c7-d59f-4bf1-aa9f-1fecd9afdad2	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-28 05:50:04.671344+00	
00000000-0000-0000-0000-000000000000	31503ea2-3768-4b9b-9412-4cad0f576b8f	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-28 06:49:24.772007+00	
00000000-0000-0000-0000-000000000000	663bd6f5-c650-4ec1-a7af-2ee9530d14fb	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-28 06:49:24.781439+00	
00000000-0000-0000-0000-000000000000	ad269ac6-bea9-42a4-852e-2535f6aa18ff	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-28 07:48:44.703063+00	
00000000-0000-0000-0000-000000000000	2ca76f84-f3a1-4073-8301-a076ef0877b3	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-28 07:48:44.707009+00	
00000000-0000-0000-0000-000000000000	b333628e-d0c2-41f6-b928-4bf60e611181	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-28 08:48:04.50375+00	
00000000-0000-0000-0000-000000000000	74f63df4-0671-4154-959f-d4ddbf602633	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-28 08:48:04.50604+00	
00000000-0000-0000-0000-000000000000	20ddac5e-05e2-4c4a-af34-2551ed306aa0	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-28 09:47:24.425664+00	
00000000-0000-0000-0000-000000000000	7b0df8b8-44e7-47f5-8438-21b9d7dbc7a7	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-28 09:47:24.426521+00	
00000000-0000-0000-0000-000000000000	f1dad9df-702a-47a1-a6f0-52506782e077	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-28 10:46:44.386971+00	
00000000-0000-0000-0000-000000000000	75d02b64-eb82-40f5-92b8-2f921cb78feb	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-28 10:46:44.390415+00	
00000000-0000-0000-0000-000000000000	89137540-84be-4d9d-add7-ea2cde94a44d	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-28 11:46:12.762273+00	
00000000-0000-0000-0000-000000000000	6d6a2edd-7320-4cf6-8a93-7af9ad9cafd9	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-28 11:46:12.764813+00	
00000000-0000-0000-0000-000000000000	c23b489a-61b6-4812-8148-d9239f8d511a	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-28 12:45:32.967045+00	
00000000-0000-0000-0000-000000000000	f36b1ab7-2acc-42c7-9a9e-8cda76c5e2bd	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-28 12:45:32.96867+00	
00000000-0000-0000-0000-000000000000	5ccab2dd-c760-42d2-a172-50b7c26bd27f	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-28 13:44:52.695199+00	
00000000-0000-0000-0000-000000000000	4011fe55-213b-4593-afd7-8b1a565f4d09	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-28 13:44:52.697744+00	
00000000-0000-0000-0000-000000000000	ddf6caf5-a018-45fc-aab8-123d6a7ffb69	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-28 14:44:12.725838+00	
00000000-0000-0000-0000-000000000000	68361cf4-c71c-4d88-8777-33d2c73d7727	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-28 14:44:12.728005+00	
00000000-0000-0000-0000-000000000000	cf28ad58-da24-4766-8a54-8339fd4c815f	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-28 15:43:32.635754+00	
00000000-0000-0000-0000-000000000000	2013df36-de41-4564-8a5e-aa6afb138434	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-28 15:43:32.637917+00	
00000000-0000-0000-0000-000000000000	cfe9d064-7bf8-47fd-ba99-22cf5855ecf5	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-28 16:42:52.540915+00	
00000000-0000-0000-0000-000000000000	4923281a-b6e0-47f0-943b-35769c4054be	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-28 16:42:52.543692+00	
00000000-0000-0000-0000-000000000000	e683730c-832d-4790-81f6-8eb932bfdffc	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-28 17:42:12.581862+00	
00000000-0000-0000-0000-000000000000	2de7317e-5ea4-4774-a246-b8438745a37a	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-28 17:42:12.583453+00	
00000000-0000-0000-0000-000000000000	269a1599-ddb5-4500-a904-700f5de5802f	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-28 18:41:32.481621+00	
00000000-0000-0000-0000-000000000000	a6c3baac-ee43-4c58-889f-d191cedb8407	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-28 18:41:32.483379+00	
00000000-0000-0000-0000-000000000000	bb756cba-96da-4b83-9106-4d43447b33da	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-28 19:40:52.499122+00	
00000000-0000-0000-0000-000000000000	2bddeacc-5326-4210-a7c4-f2eef18704db	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-28 19:40:52.50051+00	
00000000-0000-0000-0000-000000000000	a18c1666-827c-48a4-8bc0-1d40d093d7e9	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-28 20:40:12.375861+00	
00000000-0000-0000-0000-000000000000	5bba0d3c-d49e-4829-b5bc-d4e8cdf9b24d	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-28 20:40:12.377649+00	
00000000-0000-0000-0000-000000000000	cbc98de4-da69-473f-9c1e-1658f15a4d3b	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-28 21:39:32.286106+00	
00000000-0000-0000-0000-000000000000	3d6506f9-c6df-4a09-b1e7-992635c86ef0	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-28 21:39:32.287669+00	
00000000-0000-0000-0000-000000000000	96bf8d71-c4bd-4d26-add0-a1ac8755ed8b	{"action":"token_refreshed","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-28 22:38:52.197511+00	
00000000-0000-0000-0000-000000000000	dffc225d-7f86-4ecc-83ee-0d696e48541b	{"action":"token_revoked","actor_id":"8fd89363-cdda-45b8-b662-cab6d44e2bca","actor_username":"enki@adastra.lat","actor_via_sso":false,"log_type":"token"}	2025-01-28 22:38:52.199757+00	
\.


--
-- Data for Name: flow_state; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.flow_state (id, user_id, auth_code, code_challenge_method, code_challenge, provider_type, provider_access_token, provider_refresh_token, created_at, updated_at, authentication_method, auth_code_issued_at) FROM stdin;
5be0dd78-25e8-4b8f-91d9-f60f5b320d57	32c2ad65-3737-4a01-9981-160916999514	1b694371-f6fe-4975-a9dc-fe87ce9b4dfc	s256	37T7auXJ5pHawgsH7mZdrSGAeleCL9hJk1F7ms4yb8Y	email			2025-01-02 16:28:25.403194+00	2025-01-02 16:38:39.921165+00	email/signup	2025-01-02 16:38:39.921129+00
84d93cac-e8d9-44c0-8ff1-5df6f314966f	8fd89363-cdda-45b8-b662-cab6d44e2bca	4a77a8e6-ea25-4505-ae1c-a10f15b01ff9	s256	eWqeMpTByj3FGUkUn87S6L9F_UWv0MUYW2MLNtfnD5c	recovery			2025-01-16 04:18:57.137961+00	2025-01-16 04:19:20.350435+00	recovery	2025-01-16 04:19:20.350395+00
\.


--
-- Data for Name: identities; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.identities (provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at, id) FROM stdin;
8fd89363-cdda-45b8-b662-cab6d44e2bca	8fd89363-cdda-45b8-b662-cab6d44e2bca	{"sub": "8fd89363-cdda-45b8-b662-cab6d44e2bca", "email": "enki@adastra.lat", "last_name": "Rodríguez Samano ", "first_name": "Christian J", "email_verified": false, "phone_verified": false}	email	2025-01-11 00:48:59.985342+00	2025-01-11 00:48:59.985392+00	2025-01-11 00:48:59.985392+00	234d1cff-695b-491f-bf11-e12ddedb9258
\.


--
-- Data for Name: instances; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.instances (id, uuid, raw_base_config, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: mfa_amr_claims; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.mfa_amr_claims (session_id, created_at, updated_at, authentication_method, id) FROM stdin;
c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9	2025-01-12 04:52:39.817138+00	2025-01-12 04:52:39.817138+00	password	20ac5aa4-15d6-4a5a-95b6-afaf96eb96a4
97c781b8-e340-485c-8d73-9951e35dd5c6	2025-01-16 04:28:43.540886+00	2025-01-16 04:28:43.540886+00	otp	836c9720-9837-4113-928f-ab48f1948bd2
7732f5a5-cd4c-463b-891f-4ad60bff531b	2025-01-16 04:38:35.705307+00	2025-01-16 04:38:35.705307+00	password	d8c526ff-e1b4-457f-b279-f2199be2bffc
\.


--
-- Data for Name: mfa_challenges; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.mfa_challenges (id, factor_id, created_at, verified_at, ip_address, otp_code, web_authn_session_data) FROM stdin;
\.


--
-- Data for Name: mfa_factors; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.mfa_factors (id, user_id, friendly_name, factor_type, status, created_at, updated_at, secret, phone, last_challenged_at, web_authn_credential, web_authn_aaguid) FROM stdin;
\.


--
-- Data for Name: one_time_tokens; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.one_time_tokens (id, user_id, token_type, token_hash, relates_to, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: refresh_tokens; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.refresh_tokens (instance_id, id, token, user_id, revoked, created_at, updated_at, parent, session_id) FROM stdin;
00000000-0000-0000-0000-000000000000	43	mE8XAGUKAve7oiRVhSZaBw	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-12 04:52:39.815459+00	2025-01-12 05:52:06.500308+00	\N	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	44	KUV3XCZ1pUjMyBkVlH4tTw	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-12 05:52:06.500915+00	2025-01-12 06:51:36.407436+00	mE8XAGUKAve7oiRVhSZaBw	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	45	Ws5kmDJfnHd36KEaAAgcDw	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-12 06:51:36.409899+00	2025-01-12 15:46:53.042566+00	KUV3XCZ1pUjMyBkVlH4tTw	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	46	NDJ3f66aXhdDpmSCGIqA8Q	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-12 15:46:53.045258+00	2025-01-12 19:50:21.567736+00	Ws5kmDJfnHd36KEaAAgcDw	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	47	p6cTrIBKY899lhO-mSKYyQ	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-12 19:50:21.569276+00	2025-01-12 20:49:51.387297+00	NDJ3f66aXhdDpmSCGIqA8Q	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	48	-0d0V_6BEAvfyNGf5NozlQ	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-12 20:49:51.388717+00	2025-01-12 21:49:21.344087+00	p6cTrIBKY899lhO-mSKYyQ	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	49	70LrbpZw1oNYnAkthSymWg	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-12 21:49:21.345187+00	2025-01-13 02:06:21.808408+00	-0d0V_6BEAvfyNGf5NozlQ	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	50	5BzQIlOir8zFgCk5LB1irg	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-13 02:06:21.815703+00	2025-01-13 03:07:02.835688+00	70LrbpZw1oNYnAkthSymWg	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	51	6LxNMzfre85WHDeS1TLc3Q	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-13 03:07:02.836739+00	2025-01-13 04:06:25.469815+00	5BzQIlOir8zFgCk5LB1irg	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	52	Wf3McWhVyCkAkjFhOAicAw	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-13 04:06:25.471416+00	2025-01-13 05:05:55.354031+00	6LxNMzfre85WHDeS1TLc3Q	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	53	eB4Td99mQvjEblBwFxkwaA	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-13 05:05:55.354599+00	2025-01-13 06:05:25.29226+00	Wf3McWhVyCkAkjFhOAicAw	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	54	ITe1plmORyba3Hf1LWo_eA	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-13 06:05:25.292888+00	2025-01-13 07:04:55.34241+00	eB4Td99mQvjEblBwFxkwaA	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	55	TaijCvO1m2_fngvsmEwILQ	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-13 07:04:55.345487+00	2025-01-13 08:04:25.215681+00	ITe1plmORyba3Hf1LWo_eA	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	56	6XMZNxq-I_IfeeEA0aYgZQ	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-13 08:04:25.217325+00	2025-01-13 09:03:55.132206+00	TaijCvO1m2_fngvsmEwILQ	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	57	9VZqVoTmFsPGOhTkPRxBzQ	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-13 09:03:55.134309+00	2025-01-13 10:03:25.075002+00	6XMZNxq-I_IfeeEA0aYgZQ	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	58	91zPJyohOQ_kKhyhQpgZZg	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-13 10:03:25.075588+00	2025-01-13 11:02:55.056913+00	9VZqVoTmFsPGOhTkPRxBzQ	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	59	YewCvc3bvkcckoSZm99LjA	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-13 11:02:55.058143+00	2025-01-13 12:02:25.01395+00	91zPJyohOQ_kKhyhQpgZZg	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	60	Z7IQmpENERFU6ahPLYZIiw	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-13 12:02:25.014583+00	2025-01-13 13:01:54.972371+00	YewCvc3bvkcckoSZm99LjA	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	61	38yOkj1yhruisQvAXxqHxA	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-13 13:01:54.974024+00	2025-01-13 14:01:14.880629+00	Z7IQmpENERFU6ahPLYZIiw	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	62	MyAFP8Cd5Tu89oKg4DkW9g	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-13 14:01:14.881741+00	2025-01-13 15:00:34.884259+00	38yOkj1yhruisQvAXxqHxA	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	63	dWM4RYxVTifgwFC8UHvAFQ	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-13 15:00:34.886665+00	2025-01-13 15:59:54.818281+00	MyAFP8Cd5Tu89oKg4DkW9g	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	64	bTC77TGbJx3s2Bj3eC-0zA	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-13 15:59:54.820314+00	2025-01-13 16:59:14.757403+00	dWM4RYxVTifgwFC8UHvAFQ	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	65	JB6-Zz7VPL8uCHON0m2tdQ	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-13 16:59:14.758739+00	2025-01-13 17:58:34.684712+00	bTC77TGbJx3s2Bj3eC-0zA	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	66	UqYS1L1KO2ptgRu4HQXNBQ	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-13 17:58:34.687149+00	2025-01-13 18:57:54.663478+00	JB6-Zz7VPL8uCHON0m2tdQ	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	67	QQOOAtJ4DY7ST8UNTstr5g	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-13 18:57:54.665642+00	2025-01-13 19:57:14.607197+00	UqYS1L1KO2ptgRu4HQXNBQ	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	68	zSUEJhQauD6tjd_g9rWLYg	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-13 19:57:14.609986+00	2025-01-13 20:56:34.556507+00	QQOOAtJ4DY7ST8UNTstr5g	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	69	ayhyXQw5Ksjqqb8szOR9CQ	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-13 20:56:34.557824+00	2025-01-13 21:55:54.520823+00	zSUEJhQauD6tjd_g9rWLYg	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	70	TVH_Bi3wACxtxwlR5_gX7A	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-13 21:55:54.522749+00	2025-01-13 22:55:14.563763+00	ayhyXQw5Ksjqqb8szOR9CQ	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	71	MhEOsx0lWJK0SIbrwROnbw	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-13 22:55:14.566379+00	2025-01-13 23:54:34.372373+00	TVH_Bi3wACxtxwlR5_gX7A	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	72	uSA8NPy-fekzvMS3O2G2wg	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-13 23:54:34.374134+00	2025-01-14 00:53:54.366268+00	MhEOsx0lWJK0SIbrwROnbw	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	73	n0E4tL-OWlHlu5XY4RiiJA	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-14 00:53:54.368518+00	2025-01-14 01:53:14.443053+00	uSA8NPy-fekzvMS3O2G2wg	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	74	viaAHwRJ14mpTvnG2jEKZw	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-14 01:53:14.446153+00	2025-01-14 02:52:34.460215+00	n0E4tL-OWlHlu5XY4RiiJA	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	75	osNyhUZWnekhtwTXU-bAlg	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-14 02:52:34.462109+00	2025-01-14 03:51:54.304747+00	viaAHwRJ14mpTvnG2jEKZw	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	76	PiSCvN0l0PT4U8ndsCWegQ	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-14 03:51:54.307026+00	2025-01-14 04:51:17.262822+00	osNyhUZWnekhtwTXU-bAlg	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	77	dzWsDnIgxqWQnVzrsad_OQ	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-14 04:51:17.265291+00	2025-01-14 05:50:37.289345+00	PiSCvN0l0PT4U8ndsCWegQ	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	78	bCR0yuny0EzLoue_CqUssQ	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-14 05:50:37.289953+00	2025-01-14 06:49:57.441659+00	dzWsDnIgxqWQnVzrsad_OQ	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	79	ZhfOOfiHRP301JodZjtuSg	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-14 06:49:57.442261+00	2025-01-14 07:49:17.171209+00	bCR0yuny0EzLoue_CqUssQ	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	80	7F7aTC8UEwUrPSpAmoNqlQ	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-14 07:49:17.172674+00	2025-01-14 08:48:37.225767+00	ZhfOOfiHRP301JodZjtuSg	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	81	WsMC7lOhx2IK0_anm6Sluw	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-14 08:48:37.226345+00	2025-01-14 09:47:56.988734+00	7F7aTC8UEwUrPSpAmoNqlQ	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	82	tQzJqdFUfumfBgPcuWa1YA	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-14 09:47:56.989417+00	2025-01-14 10:47:17.136078+00	WsMC7lOhx2IK0_anm6Sluw	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	83	lcdLW8svozsD7W-gKHUhlw	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-14 10:47:17.146585+00	2025-01-14 11:46:36.943779+00	tQzJqdFUfumfBgPcuWa1YA	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	84	zMjmn2KlNn9VtNRE6T2WLQ	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-14 11:46:36.947667+00	2025-01-14 12:45:56.863568+00	lcdLW8svozsD7W-gKHUhlw	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	85	BF9XKeQ6QybCUkaemwQiOw	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-14 12:45:56.865594+00	2025-01-14 13:45:16.804973+00	zMjmn2KlNn9VtNRE6T2WLQ	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	86	oxgXI4_1UmCj1HUXoEBzdA	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-14 13:45:16.806208+00	2025-01-14 14:44:36.894417+00	BF9XKeQ6QybCUkaemwQiOw	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	87	WZNixc6yxj-hXbRSjZNZYA	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-14 14:44:36.895712+00	2025-01-14 15:43:56.702672+00	oxgXI4_1UmCj1HUXoEBzdA	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	91	ttYh_G_DhQH-EwfCzZ8gZw	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-14 22:53:47.617793+00	2025-01-14 23:53:15.779522+00	X3j5pd3tzk9wJo8x420C-A	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	88	QSfoCeQF-37oNiu2GV40wA	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-14 15:43:56.704816+00	2025-01-14 16:43:16.620039+00	WZNixc6yxj-hXbRSjZNZYA	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	92	matqyAJxRbite6mWoPoE2g	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-14 23:53:15.781429+00	2025-01-15 00:52:44.72259+00	ttYh_G_DhQH-EwfCzZ8gZw	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	89	vCyEGP69fYLqVxt6FbQE6g	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-14 16:43:16.621483+00	2025-01-14 17:42:36.644727+00	QSfoCeQF-37oNiu2GV40wA	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	167	vybfp9tGCuFOiu4h4cYCXA	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-19 23:47:50.490629+00	2025-01-20 00:47:12.335997+00	RJ9yDXXRGsPT86dpr4vNWw	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	90	X3j5pd3tzk9wJo8x420C-A	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-14 17:42:36.646538+00	2025-01-14 22:53:47.616562+00	vCyEGP69fYLqVxt6FbQE6g	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	93	q0C7-rCuuGNoIyjtcr7K1Q	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-15 00:52:44.728164+00	2025-01-15 01:52:14.257521+00	matqyAJxRbite6mWoPoE2g	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	94	VI2XTjK9AN1kOz8gqMlj9g	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-15 01:52:14.261508+00	2025-01-15 05:43:08.648198+00	q0C7-rCuuGNoIyjtcr7K1Q	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	95	uKTOv8fB0AL2ivH2CCuzzQ	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-15 05:43:08.649877+00	2025-01-15 06:42:34.024472+00	VI2XTjK9AN1kOz8gqMlj9g	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	96	zcd0mTHPNjUuZ5fSGOwTWw	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-15 06:42:34.026401+00	2025-01-15 07:42:04.029605+00	uKTOv8fB0AL2ivH2CCuzzQ	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	97	oGJwgQ0zwwQhRHBlt8_qKA	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-15 07:42:04.032124+00	2025-01-15 08:41:33.857765+00	zcd0mTHPNjUuZ5fSGOwTWw	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	98	M85yNDbxaxvdANeeLC6uYg	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-15 08:41:33.85942+00	2025-01-15 09:41:03.789132+00	oGJwgQ0zwwQhRHBlt8_qKA	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	99	wnHg-AgY5Z3iUAJvzfJXWw	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-15 09:41:03.7924+00	2025-01-15 10:40:33.754753+00	M85yNDbxaxvdANeeLC6uYg	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	100	GeWC97vUNuTUdjOEI9TcjQ	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-15 10:40:33.75696+00	2025-01-15 11:40:03.719346+00	wnHg-AgY5Z3iUAJvzfJXWw	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	101	wqgLmgkrMvE_leaD41FZWQ	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-15 11:40:03.72253+00	2025-01-15 12:39:33.639472+00	GeWC97vUNuTUdjOEI9TcjQ	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	102	JVcJ2JiNKJb3QgUl3eFRwA	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-15 12:39:33.640882+00	2025-01-15 13:39:03.592498+00	wqgLmgkrMvE_leaD41FZWQ	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	103	4JsK9YQsjRhYY9D8ZqwAPA	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-15 13:39:03.596758+00	2025-01-15 14:38:33.573532+00	JVcJ2JiNKJb3QgUl3eFRwA	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	104	mtXPRHyCYNG352Xal9WOaw	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-15 14:38:33.57411+00	2025-01-15 15:38:03.513258+00	4JsK9YQsjRhYY9D8ZqwAPA	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	105	6eBB24V5reiHFDxjLdf90g	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-15 15:38:03.515111+00	2025-01-15 18:18:57.21645+00	mtXPRHyCYNG352Xal9WOaw	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	106	OHkLRdBajKSM1eF2phNGOw	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-15 18:18:57.217051+00	2025-01-15 23:25:38.13144+00	6eBB24V5reiHFDxjLdf90g	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	107	Jc58xpb6nyCdrTe6fUpN4A	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-15 23:25:38.13294+00	2025-01-16 00:25:04.177187+00	OHkLRdBajKSM1eF2phNGOw	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	108	vyGiy9GeihuC2GMoPt2Q1A	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-16 00:25:04.177743+00	2025-01-16 01:28:35.001667+00	Jc58xpb6nyCdrTe6fUpN4A	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	109	YEGEW8PnCjiH6hBpfjXanQ	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-16 01:28:35.002304+00	2025-01-16 02:28:00.244406+00	vyGiy9GeihuC2GMoPt2Q1A	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	110	Y1GmKQVyj4tOh6Imd_Gc3w	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-16 02:28:00.247305+00	2025-01-16 03:27:29.356828+00	YEGEW8PnCjiH6hBpfjXanQ	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	112	Y5_tRo5PZ_IA9k-j7ZQUog	8fd89363-cdda-45b8-b662-cab6d44e2bca	f	2025-01-16 04:28:43.537393+00	2025-01-16 04:28:43.537393+00	\N	97c781b8-e340-485c-8d73-9951e35dd5c6
00000000-0000-0000-0000-000000000000	113	4pnegSReXk_PKt0YesKyxA	8fd89363-cdda-45b8-b662-cab6d44e2bca	f	2025-01-16 04:38:35.700435+00	2025-01-16 04:38:35.700435+00	\N	7732f5a5-cd4c-463b-891f-4ad60bff531b
00000000-0000-0000-0000-000000000000	111	yUvIjDw-vUe8sHB2xklHNQ	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-16 03:27:29.359068+00	2025-01-16 04:40:36.437929+00	Y1GmKQVyj4tOh6Imd_Gc3w	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	114	Zzxw33rmvlGc8zNMpGRDzQ	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-16 04:40:36.438517+00	2025-01-16 05:40:01.358446+00	yUvIjDw-vUe8sHB2xklHNQ	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	115	9jtOFDn7aIr8ic2pCIcVGg	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-16 05:40:01.359844+00	2025-01-16 06:39:31.380375+00	Zzxw33rmvlGc8zNMpGRDzQ	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	116	bTYWQWJvRlBspLzhC8vU5Q	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-16 06:39:31.3841+00	2025-01-16 07:39:02.220446+00	9jtOFDn7aIr8ic2pCIcVGg	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	117	UdOC5HA7LFoWN2u1Ttp4_w	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-16 07:39:02.221077+00	2025-01-16 08:38:31.210299+00	bTYWQWJvRlBspLzhC8vU5Q	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	118	b7VCDydQX4-ofzXEvUMcTA	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-16 08:38:31.211678+00	2025-01-16 09:38:01.178769+00	UdOC5HA7LFoWN2u1Ttp4_w	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	119	60s4wi27X39ht8BhOnumLw	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-16 09:38:01.180059+00	2025-01-16 10:37:31.229686+00	b7VCDydQX4-ofzXEvUMcTA	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	120	x9iCLf3lpey2mJIlMU1HQQ	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-16 10:37:31.231507+00	2025-01-16 11:36:57.339389+00	60s4wi27X39ht8BhOnumLw	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	121	VTCXjuv3Z3mV9eovJbnm0w	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-16 11:36:57.340002+00	2025-01-17 00:30:48.463938+00	x9iCLf3lpey2mJIlMU1HQQ	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	122	SKbOswj763b6XirOSsCfDA	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-17 00:30:48.466722+00	2025-01-17 01:30:09.335332+00	VTCXjuv3Z3mV9eovJbnm0w	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	123	LTHS7qPCUvAS8ZiCT3va-Q	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-17 01:30:09.338862+00	2025-01-17 02:29:29.200554+00	SKbOswj763b6XirOSsCfDA	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	124	hpMygtJbzhHBN0yXY-Om9Q	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-17 02:29:29.202704+00	2025-01-17 03:31:07.712801+00	LTHS7qPCUvAS8ZiCT3va-Q	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	125	u-oE0xE6G6vDmke4qGimzA	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-17 03:31:07.714997+00	2025-01-17 04:30:28.833883+00	hpMygtJbzhHBN0yXY-Om9Q	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	126	mgC5mUTP3FWeRnF_PRFCzw	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-17 04:30:28.83449+00	2025-01-17 05:36:57.969304+00	u-oE0xE6G6vDmke4qGimzA	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	127	O26aRpV2_fcGUGlj6SosAw	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-17 05:36:57.970848+00	2025-01-17 06:36:23.789519+00	mgC5mUTP3FWeRnF_PRFCzw	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	128	DpOUGhAd8ZBsSFKENUNknA	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-17 06:36:23.790131+00	2025-01-17 07:35:44.266023+00	O26aRpV2_fcGUGlj6SosAw	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	129	yTrLQkFp6NLYKal2pitAoQ	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-17 07:35:44.270233+00	2025-01-17 08:35:04.406481+00	DpOUGhAd8ZBsSFKENUNknA	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	130	yafshoH6Bd3nxrlnPyYmfw	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-17 08:35:04.410358+00	2025-01-17 09:34:23.658271+00	yTrLQkFp6NLYKal2pitAoQ	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	131	RCHmYtwObVjXyqXraQsanw	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-17 09:34:23.660799+00	2025-01-17 10:33:43.618374+00	yafshoH6Bd3nxrlnPyYmfw	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	132	S3PmmljTWHVp3PPDYQ5wFQ	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-17 10:33:43.620479+00	2025-01-17 11:33:04.139331+00	RCHmYtwObVjXyqXraQsanw	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	166	RJ9yDXXRGsPT86dpr4vNWw	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-19 22:31:19.873949+00	2025-01-19 23:47:50.487978+00	eO4NsuqaIK1D7e_p0qDw5w	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	133	dZhmNBolCRcBfkw3AKYl_g	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-17 11:33:04.14719+00	2025-01-17 12:37:28.093696+00	S3PmmljTWHVp3PPDYQ5wFQ	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	134	dK4_U_RaB4lUOZX2eBn1GA	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-17 12:37:28.095459+00	2025-01-17 19:01:36.747329+00	dZhmNBolCRcBfkw3AKYl_g	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	168	IO_NRxqVfk8a9DHrtXlSGw	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-20 00:47:12.336641+00	2025-01-20 01:46:37.269062+00	vybfp9tGCuFOiu4h4cYCXA	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	135	6Dy8wR2ebceQB3BwlpgerQ	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-17 19:01:36.751456+00	2025-01-17 20:01:02.511661+00	dK4_U_RaB4lUOZX2eBn1GA	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	136	5HDoYqk4XyB83XqYlLFl7w	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-17 20:01:02.515482+00	2025-01-17 21:00:22.411657+00	6Dy8wR2ebceQB3BwlpgerQ	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	169	CuxYhqf2JhyHoQ2N2BVWBg	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-20 01:46:37.269691+00	2025-01-20 02:45:57.078978+00	IO_NRxqVfk8a9DHrtXlSGw	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	137	EWAzm22EE3c7Hj8w7HDWmw	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-17 21:00:22.414609+00	2025-01-17 21:59:42.618299+00	5HDoYqk4XyB83XqYlLFl7w	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	138	dg-8-N06Ol3IEWeTZIUE6w	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-17 21:59:42.622881+00	2025-01-17 22:59:02.413871+00	EWAzm22EE3c7Hj8w7HDWmw	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	170	6awGyKLb0N69w7xQvIZkCQ	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-20 02:45:57.081062+00	2025-01-20 03:45:17.740909+00	CuxYhqf2JhyHoQ2N2BVWBg	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	139	piViPmy-nxMcIvLHyBLn3Q	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-17 22:59:02.418165+00	2025-01-17 23:58:22.424484+00	dg-8-N06Ol3IEWeTZIUE6w	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	140	Q3ZXXEOPqopYTF6cC1i3fg	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-17 23:58:22.428505+00	2025-01-18 00:57:42.616796+00	piViPmy-nxMcIvLHyBLn3Q	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	171	pKEMuqC8_-n7z4Gvm4twuw	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-20 03:45:17.741555+00	2025-01-20 04:52:39.570372+00	6awGyKLb0N69w7xQvIZkCQ	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	141	CB1jCW-aHNFswNr5MUNeoQ	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-18 00:57:42.62188+00	2025-01-18 01:57:02.285127+00	Q3ZXXEOPqopYTF6cC1i3fg	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	142	LEpEuo_kLPB9d9MRtVRK-w	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-18 01:57:02.288134+00	2025-01-18 02:56:22.26765+00	CB1jCW-aHNFswNr5MUNeoQ	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	172	vf_W806fT7Ks7HaiZLJw-w	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-20 04:52:39.571754+00	2025-01-20 05:52:00.138333+00	pKEMuqC8_-n7z4Gvm4twuw	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	143	glMqCc3AvF59xGSWkjSiEg	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-18 02:56:22.271063+00	2025-01-18 03:55:42.456807+00	LEpEuo_kLPB9d9MRtVRK-w	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	144	Zfo9iUIGPe2eadaClUA2YA	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-18 03:55:42.461316+00	2025-01-18 04:55:02.31645+00	glMqCc3AvF59xGSWkjSiEg	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	173	c6pYH8ieLWMj04z_MD5IGA	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-20 05:52:00.139547+00	2025-01-20 06:51:26.843356+00	vf_W806fT7Ks7HaiZLJw-w	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	145	wG5kkNsZmSVdPMqr__pcBw	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-18 04:55:02.320606+00	2025-01-18 05:54:22.134081+00	Zfo9iUIGPe2eadaClUA2YA	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	146	1vr66fEWugAHi7m_cmOTPA	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-18 05:54:22.138113+00	2025-01-18 06:53:52.487294+00	wG5kkNsZmSVdPMqr__pcBw	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	174	BwFpOPajPfOhQFx2-RBqXw	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-20 06:51:26.846219+00	2025-01-20 07:50:49.497395+00	c6pYH8ieLWMj04z_MD5IGA	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	147	pQU49A2bNVRBa-Xiqv2MLQ	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-18 06:53:52.491747+00	2025-01-18 07:53:12.016465+00	1vr66fEWugAHi7m_cmOTPA	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	148	lyfa2A7AFoV7e-PmJH_WiQ	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-18 07:53:12.019606+00	2025-01-18 08:52:32.011526+00	pQU49A2bNVRBa-Xiqv2MLQ	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	175	9x3iZdv5U9UXvbPHn3diDQ	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-20 07:50:49.499952+00	2025-01-20 08:50:09.495556+00	BwFpOPajPfOhQFx2-RBqXw	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	149	CBmVKjo-uo-92DefZPdvsg	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-18 08:52:32.013305+00	2025-01-18 09:51:52.234742+00	lyfa2A7AFoV7e-PmJH_WiQ	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	150	TtFYa6KwbcR8Q5zOa1qdvA	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-18 09:51:52.237999+00	2025-01-18 10:51:11.94564+00	CBmVKjo-uo-92DefZPdvsg	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	176	3Tt_xvS_xhp7y5CXsBBAlQ	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-20 08:50:09.498324+00	2025-01-20 09:49:30.184547+00	9x3iZdv5U9UXvbPHn3diDQ	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	151	gXVdVaWXPqWteeIynlYwfw	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-18 10:51:11.950286+00	2025-01-18 11:50:31.776562+00	TtFYa6KwbcR8Q5zOa1qdvA	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	152	DgpHaulJ8H2DyvvfTUUO5Q	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-18 11:50:31.779943+00	2025-01-18 12:49:50.112842+00	gXVdVaWXPqWteeIynlYwfw	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	177	_w-jj3o2bDNr0RooEZEXPA	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-20 09:49:30.188449+00	2025-01-20 10:48:48.774722+00	3Tt_xvS_xhp7y5CXsBBAlQ	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	153	DdRPupgWEQUBYYEeqInmxQ	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-18 12:49:50.114889+00	2025-01-18 13:49:13.1009+00	DgpHaulJ8H2DyvvfTUUO5Q	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	154	2s_AKEivgNOanHks_8oYvA	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-18 13:49:13.104345+00	2025-01-18 14:48:34.858489+00	DdRPupgWEQUBYYEeqInmxQ	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	178	04eyEk_Bl1-URRM5Ahc02g	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-20 10:48:48.777162+00	2025-01-20 11:48:09.388424+00	_w-jj3o2bDNr0RooEZEXPA	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	155	DRStkQ1i3H95lV9wIeEE3Q	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-18 14:48:34.859968+00	2025-01-18 15:47:54.820886+00	2s_AKEivgNOanHks_8oYvA	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	156	yah_lZZGX92jeonGyaPrOA	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-18 15:47:54.822114+00	2025-01-18 16:47:14.684179+00	DRStkQ1i3H95lV9wIeEE3Q	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	179	F4fjTUoNu021kr8qNC6neA	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-20 11:48:09.390354+00	2025-01-20 12:47:28.643013+00	04eyEk_Bl1-URRM5Ahc02g	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	157	CRs8gGSFYZVsxX8IaMaogg	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-18 16:47:14.68558+00	2025-01-18 17:46:34.623864+00	yah_lZZGX92jeonGyaPrOA	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	158	Al2Fz07ZWhH9p9WAlGhBzQ	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-18 17:46:34.627573+00	2025-01-18 18:46:04.509182+00	CRs8gGSFYZVsxX8IaMaogg	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	159	Ug0fN8NByBtPm5bsM7Go7g	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-18 18:46:04.510455+00	2025-01-18 19:45:34.552877+00	Al2Fz07ZWhH9p9WAlGhBzQ	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	160	yoKGwWID2Spiidfczs8jqw	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-18 19:45:34.557833+00	2025-01-18 20:45:04.388879+00	Ug0fN8NByBtPm5bsM7Go7g	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	161	oJoycL-PzN0BXopu0zT55Q	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-18 20:45:04.391971+00	2025-01-18 21:44:34.449431+00	yoKGwWID2Spiidfczs8jqw	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	162	EIW3KH2UrgRI6xxQsSIr7w	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-18 21:44:34.453342+00	2025-01-18 22:44:04.348386+00	oJoycL-PzN0BXopu0zT55Q	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	163	_FIq6LT0FqrwuR5FC_ovig	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-18 22:44:04.350708+00	2025-01-18 23:43:34.484995+00	EIW3KH2UrgRI6xxQsSIr7w	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	164	7i7_RJy7XB3nBHFJrWyrGQ	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-18 23:43:34.487115+00	2025-01-19 00:42:59.742471+00	_FIq6LT0FqrwuR5FC_ovig	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	165	eO4NsuqaIK1D7e_p0qDw5w	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-19 00:42:59.743753+00	2025-01-19 22:31:19.865047+00	7i7_RJy7XB3nBHFJrWyrGQ	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	253	6WxMVSIUHLtQjTSFbd3WCA	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-27 18:29:20.887774+00	2025-01-27 19:28:40.910925+00	X3SBqKoGZGR8Db0rfXgdCQ	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	180	7pmzhxvFr8PTcNtYF1gWOA	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-20 12:47:28.643648+00	2025-01-20 13:46:49.48611+00	F4fjTUoNu021kr8qNC6neA	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	181	KkKGN3DzItQeCl2uF0IJxQ	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-20 13:46:49.490103+00	2025-01-20 14:46:09.527491+00	7pmzhxvFr8PTcNtYF1gWOA	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	182	Ve6L-r9tGx3RtbQeqBAvOQ	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-20 14:46:09.530407+00	2025-01-20 15:45:28.492288+00	KkKGN3DzItQeCl2uF0IJxQ	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	183	skI9OHnIcOqb1DPPt5WFJQ	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-20 15:45:28.495742+00	2025-01-20 16:44:48.553379+00	Ve6L-r9tGx3RtbQeqBAvOQ	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	184	NAxMboCcWXnapYX9JsHgqA	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-20 16:44:48.55724+00	2025-01-20 17:44:09.122528+00	skI9OHnIcOqb1DPPt5WFJQ	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	185	g50bJEF3Z25FVOosbdo50Q	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-20 17:44:09.129117+00	2025-01-20 18:43:28.913736+00	NAxMboCcWXnapYX9JsHgqA	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	186	Ce45Ced6WQlBznmGns6sUw	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-20 18:43:28.918113+00	2025-01-20 19:42:50.747078+00	g50bJEF3Z25FVOosbdo50Q	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	187	2DAHvJmcQ8pBUAaTqriUAQ	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-20 19:42:50.750792+00	2025-01-20 20:42:22.980115+00	Ce45Ced6WQlBznmGns6sUw	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	188	WOrnzvMBfgvW8IPhkYQFuQ	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-20 20:42:22.983874+00	2025-01-20 21:41:50.925717+00	2DAHvJmcQ8pBUAaTqriUAQ	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	189	BD0Lh07R2j-dqbDpTawPzw	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-20 21:41:50.92888+00	2025-01-20 22:41:09.601139+00	WOrnzvMBfgvW8IPhkYQFuQ	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	190	zMZdFaml-u6vIdb32u-LRA	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-20 22:41:09.604264+00	2025-01-20 23:40:30.036158+00	BD0Lh07R2j-dqbDpTawPzw	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	191	jBlpegDb8nL6pvIXbD_SZQ	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-20 23:40:30.037988+00	2025-01-21 01:33:41.855842+00	zMZdFaml-u6vIdb32u-LRA	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	192	H1j5SDfbZ-n_93zFaWh8Wg	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-21 01:33:41.856473+00	2025-01-21 10:16:59.529816+00	jBlpegDb8nL6pvIXbD_SZQ	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	193	Px0gNlGTp0Cha6OVUN2xXA	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-21 10:16:59.539445+00	2025-01-21 11:16:31.171758+00	H1j5SDfbZ-n_93zFaWh8Wg	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	194	sD5NZgXr8B8H9QUrH65CMg	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-21 11:16:31.17603+00	2025-01-21 12:16:01.07575+00	Px0gNlGTp0Cha6OVUN2xXA	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	195	x8HiBW7g3893YWxCD65sDQ	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-21 12:16:01.081388+00	2025-01-21 13:15:31.060312+00	sD5NZgXr8B8H9QUrH65CMg	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	196	wCGqGfgqzYMhpCDQHBfOyQ	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-21 13:15:31.06567+00	2025-01-21 14:15:01.027832+00	x8HiBW7g3893YWxCD65sDQ	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	197	WAWjBTuwwo2Fo7WXL80JIQ	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-21 14:15:01.032378+00	2025-01-21 15:14:30.953292+00	wCGqGfgqzYMhpCDQHBfOyQ	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	198	LPS68JuDZ006ZK43PyLZcg	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-21 15:14:30.957005+00	2025-01-21 16:14:00.878505+00	WAWjBTuwwo2Fo7WXL80JIQ	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	199	zXj3plLH7gDgFmCNwcIr8g	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-21 16:14:00.881255+00	2025-01-21 17:13:30.851431+00	LPS68JuDZ006ZK43PyLZcg	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	200	rjbhvRF-kw81M7JhTOihbg	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-21 17:13:30.855226+00	2025-01-21 18:13:00.752667+00	zXj3plLH7gDgFmCNwcIr8g	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	201	50U-TeIUrbBPDUzZBg1gbQ	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-21 18:13:00.753953+00	2025-01-21 19:22:24.148146+00	rjbhvRF-kw81M7JhTOihbg	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	202	DANCgEOifSua_2AR-zdkHw	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-21 19:22:24.150944+00	2025-01-21 20:21:54.259824+00	50U-TeIUrbBPDUzZBg1gbQ	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	203	i_R0rN0YiAM5k2k3p4NTtA	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-21 20:21:54.264142+00	2025-01-22 23:21:48.635632+00	DANCgEOifSua_2AR-zdkHw	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	204	MkRZg3akH2OO0z2v21rdIA	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-22 23:21:48.639996+00	2025-01-23 00:21:17.86203+00	i_R0rN0YiAM5k2k3p4NTtA	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	205	IrnVwoo9U1V_Bxthxq5P6g	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-23 00:21:17.869182+00	2025-01-24 06:23:08.210588+00	MkRZg3akH2OO0z2v21rdIA	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	206	b-1fdSYSD169hzUcNyTh0w	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-24 06:23:08.222104+00	2025-01-24 11:38:00.33237+00	IrnVwoo9U1V_Bxthxq5P6g	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	207	03Tm0IqiCDve0sXhyRB6gQ	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-24 11:38:00.338773+00	2025-01-24 12:37:26.944636+00	b-1fdSYSD169hzUcNyTh0w	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	208	sENKPRSgB_VSpumzlJlozA	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-24 12:37:26.952283+00	2025-01-24 13:36:50.351336+00	03Tm0IqiCDve0sXhyRB6gQ	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	209	AU3AL2YsXtb6m-mBrsUt-w	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-24 13:36:50.363142+00	2025-01-24 14:36:20.366308+00	sENKPRSgB_VSpumzlJlozA	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	210	u06BNoDnWlp4dNLXhwxNXQ	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-24 14:36:20.373502+00	2025-01-24 15:35:50.378148+00	AU3AL2YsXtb6m-mBrsUt-w	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	211	ndrRrsy-rQvzmtVBbHOzWg	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-24 15:35:50.390093+00	2025-01-24 16:35:17.275886+00	u06BNoDnWlp4dNLXhwxNXQ	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	212	W3VAGc12UTsTI5IugB6Vsw	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-24 16:35:17.281463+00	2025-01-24 17:34:42.583816+00	ndrRrsy-rQvzmtVBbHOzWg	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	213	c0b9E8xV4gWTcRerz80sLw	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-24 17:34:42.586874+00	2025-01-24 18:44:59.434764+00	W3VAGc12UTsTI5IugB6Vsw	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	214	S6dycukVdQvH_xKnSUGCeA	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-24 18:44:59.440695+00	2025-01-24 20:43:31.439999+00	c0b9E8xV4gWTcRerz80sLw	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	215	w_oCGF-oHm_PAXkfDLvT_g	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-24 20:43:31.44597+00	2025-01-24 21:42:58.8812+00	S6dycukVdQvH_xKnSUGCeA	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	216	154QyfSxNDrOwEH-ws5Y6A	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-24 21:42:58.885797+00	2025-01-24 22:42:18.788985+00	w_oCGF-oHm_PAXkfDLvT_g	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	217	tIB9LTvl7lOggDhp5-uWJw	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-24 22:42:18.794051+00	2025-01-24 23:41:38.769866+00	154QyfSxNDrOwEH-ws5Y6A	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	218	rkKaX3mQ63trhuDgz4KClg	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-24 23:41:38.77413+00	2025-01-25 00:40:58.70077+00	tIB9LTvl7lOggDhp5-uWJw	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	219	xCKlJ3RadvjjtwynEN3d8g	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-25 00:40:58.70735+00	2025-01-25 01:42:41.516846+00	rkKaX3mQ63trhuDgz4KClg	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	220	G7WpRJyUe17DLP-Xipgmgw	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-25 01:42:41.520227+00	2025-01-25 03:12:45.551485+00	xCKlJ3RadvjjtwynEN3d8g	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	221	1arV2iAL2XQS8kATsnvjZg	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-25 03:12:45.554031+00	2025-01-25 04:12:09.486299+00	G7WpRJyUe17DLP-Xipgmgw	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	222	w8rxqgNYtbL--mKlsicKag	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-25 04:12:09.48904+00	2025-01-25 06:03:24.60978+00	1arV2iAL2XQS8kATsnvjZg	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	223	G8_mO_msD-Kb_z0dR9nHyA	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-25 06:03:24.615159+00	2025-01-25 07:36:24.641486+00	w8rxqgNYtbL--mKlsicKag	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	224	QRrJacEsMiKmV4r6Ovt0-g	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-25 07:36:24.649637+00	2025-01-25 08:35:47.915299+00	G8_mO_msD-Kb_z0dR9nHyA	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	252	X3SBqKoGZGR8Db0rfXgdCQ	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-27 17:30:00.957147+00	2025-01-27 18:29:20.883211+00	2nH1kG2zVHVzeRSqHky7qw	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	225	IMaheH_0yWxTiQKp08gKQA	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-25 08:35:47.918386+00	2025-01-25 09:35:07.846569+00	QRrJacEsMiKmV4r6Ovt0-g	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	226	v6TDgsW45tPpzw6LO15vfg	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-25 09:35:07.850234+00	2025-01-25 10:34:27.980644+00	IMaheH_0yWxTiQKp08gKQA	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	254	oEZulsDsXGY85JrSsW1l2A	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-27 19:28:40.915931+00	2025-01-27 20:28:00.778556+00	6WxMVSIUHLtQjTSFbd3WCA	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	227	PBVDB5Ea1jlkEaVKGJKSBQ	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-25 10:34:27.985162+00	2025-01-25 11:33:47.737444+00	v6TDgsW45tPpzw6LO15vfg	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	228	aYaDlWqGAwszvZrUShAvUA	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-25 11:33:47.740246+00	2025-01-25 12:33:07.668444+00	PBVDB5Ea1jlkEaVKGJKSBQ	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	255	bQ3Dqk4rdGnNVoQ2w6TwuQ	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-27 20:28:00.7825+00	2025-01-27 21:27:20.818891+00	oEZulsDsXGY85JrSsW1l2A	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	229	7X7KjVUkDJq7TgXC9UHNHw	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-25 12:33:07.673761+00	2025-01-25 13:32:27.643147+00	aYaDlWqGAwszvZrUShAvUA	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	230	d6eS9X8gRfue-ta7wdN57g	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-25 13:32:27.647733+00	2025-01-25 14:31:47.835383+00	7X7KjVUkDJq7TgXC9UHNHw	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	256	No0mb7-cb0yd0a1Ji7j4Sg	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-27 21:27:20.822556+00	2025-01-27 22:26:40.696538+00	bQ3Dqk4rdGnNVoQ2w6TwuQ	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	231	8GF5uagHHJmHjnXHBF9f6Q	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-25 14:31:47.839928+00	2025-01-25 17:44:04.584356+00	d6eS9X8gRfue-ta7wdN57g	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	232	QhIM5vLW1chlLwu3A861xQ	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-25 17:44:04.589814+00	2025-01-25 22:01:09.017393+00	8GF5uagHHJmHjnXHBF9f6Q	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	257	Ml-kE6JtVIQMqFYp4Rpo9g	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-27 22:26:40.700671+00	2025-01-27 23:26:00.669586+00	No0mb7-cb0yd0a1Ji7j4Sg	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	233	y8hJ0Ez584FnihkiZLc3FA	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-25 22:01:09.023955+00	2025-01-26 07:46:17.044335+00	QhIM5vLW1chlLwu3A861xQ	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	234	VrgLDYGDiNxDRL2G6Bai5g	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-26 07:46:17.056679+00	2025-01-27 00:38:52.297038+00	y8hJ0Ez584FnihkiZLc3FA	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	258	xqk1Zg694DpvWv96P-ul1Q	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-27 23:26:00.672923+00	2025-01-28 00:25:22.096545+00	Ml-kE6JtVIQMqFYp4Rpo9g	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	235	ztEG0Tb76sRCkfX390Bd1Q	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-27 00:38:52.314162+00	2025-01-27 01:38:16.300269+00	VrgLDYGDiNxDRL2G6Bai5g	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	236	3KcilPu4kU9OuizS8F9MAw	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-27 01:38:16.303314+00	2025-01-27 02:37:43.990277+00	ztEG0Tb76sRCkfX390Bd1Q	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	259	RWc8Pfk6Y2_XT-D1HPT-lA	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-28 00:25:22.103207+00	2025-01-28 01:25:47.625798+00	xqk1Zg694DpvWv96P-ul1Q	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	237	7lDexAcZHHbZCLmXmDv_qQ	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-27 02:37:43.992234+00	2025-01-27 03:37:08.559575+00	3KcilPu4kU9OuizS8F9MAw	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	238	aRYJb9uPZ3Oio8uNemzXgA	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-27 03:37:08.560188+00	2025-01-27 04:38:34.030581+00	7lDexAcZHHbZCLmXmDv_qQ	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	260	Y-PkKywMsvei3hiTqrwInQ	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-28 01:25:47.630704+00	2025-01-28 03:51:22.400288+00	RWc8Pfk6Y2_XT-D1HPT-lA	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	239	86ShQhlBvMGvmfvfBC5ifA	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-27 04:38:34.036673+00	2025-01-27 05:38:01.536074+00	aRYJb9uPZ3Oio8uNemzXgA	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	240	7h5J4ds1H4Kv_0IKF-uCjg	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-27 05:38:01.538565+00	2025-01-27 06:37:21.500332+00	86ShQhlBvMGvmfvfBC5ifA	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	261	Kt9Fnz8FhdKeeAdObWppwA	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-28 03:51:22.404107+00	2025-01-28 04:50:44.643851+00	Y-PkKywMsvei3hiTqrwInQ	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	241	KNZ3J38aX9rbGzQzqeHxBg	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-27 06:37:21.50237+00	2025-01-27 07:36:41.563422+00	7h5J4ds1H4Kv_0IKF-uCjg	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	242	I05KuooErskOYWhvvgm_tA	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-27 07:36:41.566707+00	2025-01-27 08:36:01.412355+00	KNZ3J38aX9rbGzQzqeHxBg	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	262	q1J6Eq-Cfo_T9lGYNsh7ew	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-28 04:50:44.649105+00	2025-01-28 05:50:04.671851+00	Kt9Fnz8FhdKeeAdObWppwA	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	243	Dyqt3p23qim9sRMoru4QGg	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-27 08:36:01.414526+00	2025-01-27 09:35:21.284548+00	I05KuooErskOYWhvvgm_tA	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	244	Whomlt6zPXfSD0JykdwZRg	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-27 09:35:21.286704+00	2025-01-27 10:34:41.407299+00	Dyqt3p23qim9sRMoru4QGg	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	263	g4lKl7ye0DuWsAR4dKox_A	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-28 05:50:04.676114+00	2025-01-28 06:49:24.782684+00	q1J6Eq-Cfo_T9lGYNsh7ew	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	245	jiZ5-6zDrHXHlMfAXmAl_g	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-27 10:34:41.414288+00	2025-01-27 11:34:01.570423+00	Whomlt6zPXfSD0JykdwZRg	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	246	tA14j1ZFTMMY9VnLE7eWGQ	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-27 11:34:01.575733+00	2025-01-27 12:33:21.154042+00	jiZ5-6zDrHXHlMfAXmAl_g	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	264	vPI3O8t8vArCDb1aRqSrnA	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-28 06:49:24.79195+00	2025-01-28 07:48:44.708084+00	g4lKl7ye0DuWsAR4dKox_A	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	247	UhmuEPwpKNITZrtjuaHjDA	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-27 12:33:21.159935+00	2025-01-27 13:32:41.102022+00	tA14j1ZFTMMY9VnLE7eWGQ	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	248	aQM9Zay4_YepfMweaDunAA	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-27 13:32:41.10578+00	2025-01-27 14:32:01.107194+00	UhmuEPwpKNITZrtjuaHjDA	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	265	-v8I_xh9d4UPEhNE_yrxig	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-28 07:48:44.71254+00	2025-01-28 08:48:04.506591+00	vPI3O8t8vArCDb1aRqSrnA	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	249	pilMpOaNNLI1J_2Hitvy9g	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-27 14:32:01.115234+00	2025-01-27 15:31:21.086663+00	aQM9Zay4_YepfMweaDunAA	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	250	6VYyvOMXoQFlgKJZtcezHA	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-27 15:31:21.090368+00	2025-01-27 16:30:41.386227+00	pilMpOaNNLI1J_2Hitvy9g	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	266	8W-ctSoTv1u69KOruLWqHw	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-28 08:48:04.509707+00	2025-01-28 09:47:24.428298+00	-v8I_xh9d4UPEhNE_yrxig	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	251	2nH1kG2zVHVzeRSqHky7qw	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-27 16:30:41.390917+00	2025-01-27 17:30:00.951657+00	6VYyvOMXoQFlgKJZtcezHA	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	267	cZ4qi0TCEoXsXrWZx6NmDg	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-28 09:47:24.430189+00	2025-01-28 10:46:44.393587+00	8W-ctSoTv1u69KOruLWqHw	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	268	jyHXRZan42xD8Ax0ZZhBvg	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-28 10:46:44.400177+00	2025-01-28 11:46:12.765336+00	cZ4qi0TCEoXsXrWZx6NmDg	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	269	5eOjGXGkPDF8Coo7wM-lYA	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-28 11:46:12.76812+00	2025-01-28 12:45:32.969202+00	jyHXRZan42xD8Ax0ZZhBvg	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	270	tG8a8SXFKLRMg-rcrOUM_Q	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-28 12:45:32.971155+00	2025-01-28 13:44:52.698264+00	5eOjGXGkPDF8Coo7wM-lYA	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	271	qmnwSe5oSRoF7otP1PBpJQ	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-28 13:44:52.70227+00	2025-01-28 14:44:12.729119+00	tG8a8SXFKLRMg-rcrOUM_Q	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	272	FRR-ghmPx1aNB7-cKEJsGg	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-28 14:44:12.731665+00	2025-01-28 15:43:32.639743+00	qmnwSe5oSRoF7otP1PBpJQ	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	273	t_TtmwI7ahmdZ08BQMmo1g	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-28 15:43:32.643577+00	2025-01-28 16:42:52.544256+00	FRR-ghmPx1aNB7-cKEJsGg	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	274	9t7gx6WvYniueJN-_P3gJA	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-28 16:42:52.54623+00	2025-01-28 17:42:12.584683+00	t_TtmwI7ahmdZ08BQMmo1g	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	275	-2bDipW3Cp-9k6suGnCtyA	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-28 17:42:12.587883+00	2025-01-28 18:41:32.484393+00	9t7gx6WvYniueJN-_P3gJA	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	276	HOEZGJD-TbZ6SrX4QH-OQg	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-28 18:41:32.487377+00	2025-01-28 19:40:52.501861+00	-2bDipW3Cp-9k6suGnCtyA	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	277	X_PIjeUJglRPfUyf67Xfzg	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-28 19:40:52.5041+00	2025-01-28 20:40:12.378206+00	HOEZGJD-TbZ6SrX4QH-OQg	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	278	Xf2tgV0gwEdJtCkwNI9rfw	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-28 20:40:12.379389+00	2025-01-28 21:39:32.288868+00	X_PIjeUJglRPfUyf67Xfzg	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	279	aPDndcBH9o6f8Pvu2YKrpA	8fd89363-cdda-45b8-b662-cab6d44e2bca	t	2025-01-28 21:39:32.290819+00	2025-01-28 22:38:52.200301+00	Xf2tgV0gwEdJtCkwNI9rfw	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
00000000-0000-0000-0000-000000000000	280	g2PxVhK2gnZeBLhQ4fFraw	8fd89363-cdda-45b8-b662-cab6d44e2bca	f	2025-01-28 22:38:52.202703+00	2025-01-28 22:38:52.202703+00	aPDndcBH9o6f8Pvu2YKrpA	c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9
\.


--
-- Data for Name: saml_providers; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.saml_providers (id, sso_provider_id, entity_id, metadata_xml, metadata_url, attribute_mapping, created_at, updated_at, name_id_format) FROM stdin;
\.


--
-- Data for Name: saml_relay_states; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.saml_relay_states (id, sso_provider_id, request_id, for_email, redirect_to, created_at, updated_at, flow_state_id) FROM stdin;
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.schema_migrations (version) FROM stdin;
20171026211738
20171026211808
20171026211834
20180103212743
20180108183307
20180119214651
20180125194653
00
20210710035447
20210722035447
20210730183235
20210909172000
20210927181326
20211122151130
20211124214934
20211202183645
20220114185221
20220114185340
20220224000811
20220323170000
20220429102000
20220531120530
20220614074223
20220811173540
20221003041349
20221003041400
20221011041400
20221020193600
20221021073300
20221021082433
20221027105023
20221114143122
20221114143410
20221125140132
20221208132122
20221215195500
20221215195800
20221215195900
20230116124310
20230116124412
20230131181311
20230322519590
20230402418590
20230411005111
20230508135423
20230523124323
20230818113222
20230914180801
20231027141322
20231114161723
20231117164230
20240115144230
20240214120130
20240306115329
20240314092811
20240427152123
20240612123726
20240729123726
20240802193726
20240806073726
20241009103726
\.


--
-- Data for Name: sessions; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.sessions (id, user_id, created_at, updated_at, factor_id, aal, not_after, refreshed_at, user_agent, ip, tag) FROM stdin;
97c781b8-e340-485c-8d73-9951e35dd5c6	8fd89363-cdda-45b8-b662-cab6d44e2bca	2025-01-16 04:28:43.534065+00	2025-01-16 04:28:43.534065+00	\N	aal1	\N	\N	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36	187.190.229.78	\N
7732f5a5-cd4c-463b-891f-4ad60bff531b	8fd89363-cdda-45b8-b662-cab6d44e2bca	2025-01-16 04:38:35.69829+00	2025-01-16 04:38:35.69829+00	\N	aal1	\N	\N	Dart/3.6 (dart:io)	187.190.229.78	\N
c2c7b4ae-e6ea-4378-aae4-ae2b85d902c9	8fd89363-cdda-45b8-b662-cab6d44e2bca	2025-01-12 04:52:39.814513+00	2025-01-28 22:38:52.205006+00	\N	aal1	\N	2025-01-28 22:38:52.204935	Dart/3.6 (dart:io)	187.190.229.78	\N
\.


--
-- Data for Name: sso_domains; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.sso_domains (id, sso_provider_id, domain, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: sso_providers; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.sso_providers (id, resource_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, invited_at, confirmation_token, confirmation_sent_at, recovery_token, recovery_sent_at, email_change_token_new, email_change, email_change_sent_at, last_sign_in_at, raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at, phone, phone_confirmed_at, phone_change, phone_change_token, phone_change_sent_at, email_change_token_current, email_change_confirm_status, banned_until, reauthentication_token, reauthentication_sent_at, is_sso_user, deleted_at, is_anonymous) FROM stdin;
00000000-0000-0000-0000-000000000000	8fd89363-cdda-45b8-b662-cab6d44e2bca	authenticated	authenticated	enki@adastra.lat	$2a$06$0sUV2i73.QTJ.6gKYjbV1.hRnIYWOo2429h60SdEKNppVBkVzVvcq	2025-01-11 00:48:59.995122+00	\N		\N		2025-01-16 04:28:32.938835+00			\N	2025-01-16 04:38:35.698216+00	{"provider": "email", "providers": ["email"]}	{"sub": "8fd89363-cdda-45b8-b662-cab6d44e2bca", "email": "enki@adastra.lat", "last_name": "Rodríguez Sámano ", "first_name": "Christian J", "email_verified": true, "phone_verified": false}	\N	2025-01-11 00:48:59.933198+00	2025-01-28 22:38:52.203812+00	\N	\N			\N		0	\N		\N	f	\N	f
\.


--
-- Data for Name: job; Type: TABLE DATA; Schema: cron; Owner: supabase_admin
--

COPY cron.job (jobid, schedule, command, nodename, nodeport, database, username, active, jobname) FROM stdin;
1	0 0 1 * *	\r\n    SELECT public.archive_completed_goals(30);\r\n    	localhost	5432	postgres	postgres	t	archive-completed-goals
2	0 1 * * *	\r\n    SELECT public.process_recurring_transactions();\r\n    	localhost	5432	postgres	postgres	t	process-recurring-transactions
3	0 1 * * *	\r\n    DO \r\n    $do$\r\n    DECLARE\r\n        v_record record;\r\n    BEGIN\r\n        FOR v_record IN \r\n            SELECT cc.id\r\n            FROM public.credit_card_details cc\r\n            WHERE public.calculate_next_cut_off_date(cc.cut_off_day) = CURRENT_DATE\r\n        LOOP\r\n            PERFORM public.generate_credit_card_statement(v_record.id);\r\n        END LOOP;\r\n    END\r\n    $do$;\r\n    	localhost	5432	postgres	postgres	t	generate-credit-card-statements
4	0 2 * * *	\r\n    SELECT public.update_installment_purchases();\r\n    	localhost	5432	postgres	postgres	t	update-installment-purchases
5	0 8 * * *	\r\n    SELECT public.notify_credit_card_events();\r\n    	localhost	5432	postgres	postgres	t	credit-card-notifications
\.


--
-- Data for Name: job_run_details; Type: TABLE DATA; Schema: cron; Owner: supabase_admin
--

COPY cron.job_run_details (jobid, runid, job_pid, database, username, command, status, return_message, start_time, end_time) FROM stdin;
3	12	297895	postgres	postgres	\r\n    DO \r\n    $do$\r\n    DECLARE\r\n        v_record record;\r\n    BEGIN\r\n        FOR v_record IN \r\n            SELECT cc.id\r\n            FROM public.credit_card_details cc\r\n            WHERE public.calculate_next_cut_off_date(cc.cut_off_day) = CURRENT_DATE\r\n        LOOP\r\n            PERFORM public.generate_credit_card_statement(v_record.id);\r\n        END LOOP;\r\n    END\r\n    $do$;\r\n    	succeeded	DO	2025-01-16 01:00:00.123177+00	2025-01-16 01:00:00.125195+00
2	11	297894	postgres	postgres	\r\n    SELECT public.process_recurring_transactions();\r\n    	succeeded	1 row	2025-01-16 01:00:00.121139+00	2025-01-16 01:00:00.128086+00
2	1	240362	postgres	postgres	\r\n    SELECT public.process_recurring_transactions();\r\n    	succeeded	1 row	2025-01-13 01:00:00.171479+00	2025-01-13 01:00:00.198969+00
3	8	278858	postgres	postgres	\r\n    DO \r\n    $do$\r\n    DECLARE\r\n        v_record record;\r\n    BEGIN\r\n        FOR v_record IN \r\n            SELECT cc.id\r\n            FROM public.credit_card_details cc\r\n            WHERE public.calculate_next_cut_off_date(cc.cut_off_day) = CURRENT_DATE\r\n        LOOP\r\n            PERFORM public.generate_credit_card_statement(v_record.id);\r\n        END LOOP;\r\n    END\r\n    $do$;\r\n    	succeeded	DO	2025-01-15 01:00:00.170416+00	2025-01-15 01:00:00.175259+00
2	7	278857	postgres	postgres	\r\n    SELECT public.process_recurring_transactions();\r\n    	succeeded	1 row	2025-01-15 01:00:00.169367+00	2025-01-15 01:00:00.184556+00
5	2	246116	postgres	postgres	\r\n    SELECT public.notify_credit_card_events();\r\n    	succeeded	1 row	2025-01-13 08:00:00.126521+00	2025-01-13 08:00:00.149463+00
2	23	357426	postgres	postgres	\r\n    SELECT public.process_recurring_transactions();\r\n    	succeeded	1 row	2025-01-19 01:00:00.167022+00	2025-01-19 01:00:00.196154+00
5	26	363468	postgres	postgres	\r\n    SELECT public.notify_credit_card_events();\r\n    	succeeded	1 row	2025-01-19 08:00:00.083126+00	2025-01-19 08:00:00.114439+00
4	9	279633	postgres	postgres	\r\n    SELECT public.update_installment_purchases();\r\n    	succeeded	1 row	2025-01-15 02:00:00.01696+00	2025-01-15 02:00:00.021389+00
4	13	299041	postgres	postgres	\r\n    SELECT public.update_installment_purchases();\r\n    	succeeded	1 row	2025-01-16 02:00:00.053291+00	2025-01-16 02:00:00.058412+00
3	4	259334	postgres	postgres	\r\n    DO \r\n    $do$\r\n    DECLARE\r\n        v_record record;\r\n    BEGIN\r\n        FOR v_record IN \r\n            SELECT cc.id\r\n            FROM public.credit_card_details cc\r\n            WHERE public.calculate_next_cut_off_date(cc.cut_off_day) = CURRENT_DATE\r\n        LOOP\r\n            PERFORM public.generate_credit_card_statement(v_record.id);\r\n        END LOOP;\r\n    END\r\n    $do$;\r\n    	succeeded	DO	2025-01-14 01:00:00.115242+00	2025-01-14 01:00:00.121357+00
2	3	259333	postgres	postgres	\r\n    SELECT public.process_recurring_transactions();\r\n    	succeeded	1 row	2025-01-14 01:00:00.11293+00	2025-01-14 01:00:00.133883+00
3	16	318082	postgres	postgres	\r\n    DO \r\n    $do$\r\n    DECLARE\r\n        v_record record;\r\n    BEGIN\r\n        FOR v_record IN \r\n            SELECT cc.id\r\n            FROM public.credit_card_details cc\r\n            WHERE public.calculate_next_cut_off_date(cc.cut_off_day) = CURRENT_DATE\r\n        LOOP\r\n            PERFORM public.generate_credit_card_statement(v_record.id);\r\n        END LOOP;\r\n    END\r\n    $do$;\r\n    	succeeded	DO	2025-01-17 01:00:00.118208+00	2025-01-17 01:00:00.121317+00
5	10	284408	postgres	postgres	\r\n    SELECT public.notify_credit_card_events();\r\n    	succeeded	1 row	2025-01-15 08:00:00.037123+00	2025-01-15 08:00:00.054078+00
4	5	260106	postgres	postgres	\r\n    SELECT public.update_installment_purchases();\r\n    	succeeded	1 row	2025-01-14 02:00:00.017138+00	2025-01-14 02:00:00.020335+00
2	15	318081	postgres	postgres	\r\n    SELECT public.process_recurring_transactions();\r\n    	succeeded	1 row	2025-01-17 01:00:00.115557+00	2025-01-17 01:00:00.125331+00
5	6	265013	postgres	postgres	\r\n    SELECT public.notify_credit_card_events();\r\n    	succeeded	1 row	2025-01-14 08:00:00.112504+00	2025-01-14 08:00:00.121283+00
5	14	304266	postgres	postgres	\r\n    SELECT public.notify_credit_card_events();\r\n    	succeeded	1 row	2025-01-16 08:00:00.082265+00	2025-01-16 08:00:00.089693+00
4	21	338701	postgres	postgres	\r\n    SELECT public.update_installment_purchases();\r\n    	succeeded	1 row	2025-01-18 02:00:00.020318+00	2025-01-18 02:00:00.025058+00
4	17	318871	postgres	postgres	\r\n    SELECT public.update_installment_purchases();\r\n    	succeeded	1 row	2025-01-17 02:00:00.017723+00	2025-01-17 02:00:00.021539+00
3	20	337912	postgres	postgres	\r\n    DO \r\n    $do$\r\n    DECLARE\r\n        v_record record;\r\n    BEGIN\r\n        FOR v_record IN \r\n            SELECT cc.id\r\n            FROM public.credit_card_details cc\r\n            WHERE public.calculate_next_cut_off_date(cc.cut_off_day) = CURRENT_DATE\r\n        LOOP\r\n            PERFORM public.generate_credit_card_statement(v_record.id);\r\n        END LOOP;\r\n    END\r\n    $do$;\r\n    	succeeded	DO	2025-01-18 01:00:00.191544+00	2025-01-18 01:00:00.198358+00
2	19	337911	postgres	postgres	\r\n    SELECT public.process_recurring_transactions();\r\n    	succeeded	1 row	2025-01-18 01:00:00.189219+00	2025-01-18 01:00:00.21398+00
3	24	357427	postgres	postgres	\r\n    DO \r\n    $do$\r\n    DECLARE\r\n        v_record record;\r\n    BEGIN\r\n        FOR v_record IN \r\n            SELECT cc.id\r\n            FROM public.credit_card_details cc\r\n            WHERE public.calculate_next_cut_off_date(cc.cut_off_day) = CURRENT_DATE\r\n        LOOP\r\n            PERFORM public.generate_credit_card_statement(v_record.id);\r\n        END LOOP;\r\n    END\r\n    $do$;\r\n    	succeeded	DO	2025-01-19 01:00:00.169199+00	2025-01-19 01:00:00.182374+00
2	27	376975	postgres	postgres	\r\n    SELECT public.process_recurring_transactions();\r\n    	succeeded	1 row	2025-01-20 01:00:00.140709+00	2025-01-20 01:00:00.150618+00
5	18	324011	postgres	postgres	\r\n    SELECT public.notify_credit_card_events();\r\n    	succeeded	1 row	2025-01-17 08:00:00.102448+00	2025-01-17 08:00:00.126415+00
5	22	343581	postgres	postgres	\r\n    SELECT public.notify_credit_card_events();\r\n    	succeeded	1 row	2025-01-18 08:00:00.043874+00	2025-01-18 08:00:00.05495+00
4	25	358250	postgres	postgres	\r\n    SELECT public.update_installment_purchases();\r\n    	succeeded	1 row	2025-01-19 02:00:00.121959+00	2025-01-19 02:00:00.125143+00
3	28	376976	postgres	postgres	\r\n    DO \r\n    $do$\r\n    DECLARE\r\n        v_record record;\r\n    BEGIN\r\n        FOR v_record IN \r\n            SELECT cc.id\r\n            FROM public.credit_card_details cc\r\n            WHERE public.calculate_next_cut_off_date(cc.cut_off_day) = CURRENT_DATE\r\n        LOOP\r\n            PERFORM public.generate_credit_card_statement(v_record.id);\r\n        END LOOP;\r\n    END\r\n    $do$;\r\n    	succeeded	DO	2025-01-20 01:00:00.142734+00	2025-01-20 01:00:00.144629+00
3	48	475057	postgres	postgres	\r\n    DO \r\n    $do$\r\n    DECLARE\r\n        v_record record;\r\n    BEGIN\r\n        FOR v_record IN \r\n            SELECT cc.id\r\n            FROM public.credit_card_details cc\r\n            WHERE public.calculate_next_cut_off_date(cc.cut_off_day) = CURRENT_DATE\r\n        LOOP\r\n            PERFORM public.generate_credit_card_statement(v_record.id);\r\n        END LOOP;\r\n    END\r\n    $do$;\r\n    	succeeded	DO	2025-01-25 01:00:00.197593+00	2025-01-25 01:00:00.211273+00
5	46	460806	postgres	postgres	\r\n    SELECT public.notify_credit_card_events();\r\n    	succeeded	1 row	2025-01-24 08:00:00.074213+00	2025-01-24 08:00:00.09418+00
4	29	377763	postgres	postgres	\r\n    SELECT public.update_installment_purchases();\r\n    	succeeded	1 row	2025-01-20 02:00:00.018195+00	2025-01-20 02:00:00.021308+00
3	40	436030	postgres	postgres	\r\n    DO \r\n    $do$\r\n    DECLARE\r\n        v_record record;\r\n    BEGIN\r\n        FOR v_record IN \r\n            SELECT cc.id\r\n            FROM public.credit_card_details cc\r\n            WHERE public.calculate_next_cut_off_date(cc.cut_off_day) = CURRENT_DATE\r\n        LOOP\r\n            PERFORM public.generate_credit_card_statement(v_record.id);\r\n        END LOOP;\r\n    END\r\n    $do$;\r\n    	succeeded	DO	2025-01-23 01:00:00.192638+00	2025-01-23 01:00:00.195981+00
3	36	416109	postgres	postgres	\r\n    DO \r\n    $do$\r\n    DECLARE\r\n        v_record record;\r\n    BEGIN\r\n        FOR v_record IN \r\n            SELECT cc.id\r\n            FROM public.credit_card_details cc\r\n            WHERE public.calculate_next_cut_off_date(cc.cut_off_day) = CURRENT_DATE\r\n        LOOP\r\n            PERFORM public.generate_credit_card_statement(v_record.id);\r\n        END LOOP;\r\n    END\r\n    $do$;\r\n    	succeeded	DO	2025-01-22 01:00:00.169866+00	2025-01-22 01:00:00.182307+00
2	35	416108	postgres	postgres	\r\n    SELECT public.process_recurring_transactions();\r\n    	succeeded	1 row	2025-01-22 01:00:00.167688+00	2025-01-22 01:00:00.199185+00
5	30	382645	postgres	postgres	\r\n    SELECT public.notify_credit_card_events();\r\n    	succeeded	1 row	2025-01-20 08:00:00.078667+00	2025-01-20 08:00:00.098226+00
2	39	436029	postgres	postgres	\r\n    SELECT public.process_recurring_transactions();\r\n    	succeeded	1 row	2025-01-23 01:00:00.194892+00	2025-01-23 01:00:00.20474+00
2	47	475056	postgres	postgres	\r\n    SELECT public.process_recurring_transactions();\r\n    	succeeded	1 row	2025-01-25 01:00:00.194477+00	2025-01-25 01:00:00.233351+00
4	37	416892	postgres	postgres	\r\n    SELECT public.update_installment_purchases();\r\n    	succeeded	1 row	2025-01-22 02:00:00.018282+00	2025-01-22 02:00:00.025414+00
3	32	396386	postgres	postgres	\r\n    DO \r\n    $do$\r\n    DECLARE\r\n        v_record record;\r\n    BEGIN\r\n        FOR v_record IN \r\n            SELECT cc.id\r\n            FROM public.credit_card_details cc\r\n            WHERE public.calculate_next_cut_off_date(cc.cut_off_day) = CURRENT_DATE\r\n        LOOP\r\n            PERFORM public.generate_credit_card_statement(v_record.id);\r\n        END LOOP;\r\n    END\r\n    $do$;\r\n    	succeeded	DO	2025-01-21 01:00:00.126023+00	2025-01-21 01:00:00.129213+00
2	31	396385	postgres	postgres	\r\n    SELECT public.process_recurring_transactions();\r\n    	succeeded	1 row	2025-01-21 01:00:00.128174+00	2025-01-21 01:00:00.139595+00
3	44	455167	postgres	postgres	\r\n    DO \r\n    $do$\r\n    DECLARE\r\n        v_record record;\r\n    BEGIN\r\n        FOR v_record IN \r\n            SELECT cc.id\r\n            FROM public.credit_card_details cc\r\n            WHERE public.calculate_next_cut_off_date(cc.cut_off_day) = CURRENT_DATE\r\n        LOOP\r\n            PERFORM public.generate_credit_card_statement(v_record.id);\r\n        END LOOP;\r\n    END\r\n    $do$;\r\n    	succeeded	DO	2025-01-24 01:00:00.183847+00	2025-01-24 01:00:00.188477+00
2	43	455166	postgres	postgres	\r\n    SELECT public.process_recurring_transactions();\r\n    	succeeded	1 row	2025-01-24 01:00:00.179934+00	2025-01-24 01:00:00.202124+00
4	41	436799	postgres	postgres	\r\n    SELECT public.update_installment_purchases();\r\n    	succeeded	1 row	2025-01-23 02:00:00.017994+00	2025-01-23 02:00:00.02182+00
4	33	397553	postgres	postgres	\r\n    SELECT public.update_installment_purchases();\r\n    	succeeded	1 row	2025-01-21 02:00:00.118658+00	2025-01-21 02:00:00.124646+00
5	38	421756	postgres	postgres	\r\n    SELECT public.notify_credit_card_events();\r\n    	succeeded	1 row	2025-01-22 08:00:00.035613+00	2025-01-22 08:00:00.071415+00
5	34	402558	postgres	postgres	\r\n    SELECT public.notify_credit_card_events();\r\n    	succeeded	1 row	2025-01-21 08:00:00.116512+00	2025-01-21 08:00:00.140495+00
2	51	495244	postgres	postgres	\r\n    SELECT public.process_recurring_transactions();\r\n    	succeeded	1 row	2025-01-26 01:00:00.214898+00	2025-01-26 01:00:00.228086+00
4	45	455987	postgres	postgres	\r\n    SELECT public.update_installment_purchases();\r\n    	succeeded	1 row	2025-01-24 02:00:00.110054+00	2025-01-24 02:00:00.113284+00
5	42	441895	postgres	postgres	\r\n    SELECT public.notify_credit_card_events();\r\n    	succeeded	1 row	2025-01-23 08:00:00.138698+00	2025-01-23 08:00:00.162466+00
4	49	476011	postgres	postgres	\r\n    SELECT public.update_installment_purchases();\r\n    	succeeded	1 row	2025-01-25 02:00:00.144914+00	2025-01-25 02:00:00.148069+00
3	52	495245	postgres	postgres	\r\n    DO \r\n    $do$\r\n    DECLARE\r\n        v_record record;\r\n    BEGIN\r\n        FOR v_record IN \r\n            SELECT cc.id\r\n            FROM public.credit_card_details cc\r\n            WHERE public.calculate_next_cut_off_date(cc.cut_off_day) = CURRENT_DATE\r\n        LOOP\r\n            PERFORM public.generate_credit_card_statement(v_record.id);\r\n        END LOOP;\r\n    END\r\n    $do$;\r\n    	succeeded	DO	2025-01-26 01:00:00.213934+00	2025-01-26 01:00:00.223296+00
5	50	481128	postgres	postgres	\r\n    SELECT public.notify_credit_card_events();\r\n    	succeeded	1 row	2025-01-25 08:00:00.189918+00	2025-01-25 08:00:00.196323+00
2	55	514607	postgres	postgres	\r\n    SELECT public.process_recurring_transactions();\r\n    	succeeded	1 row	2025-01-27 01:00:00.205614+00	2025-01-27 01:00:00.213781+00
5	54	500777	postgres	postgres	\r\n    SELECT public.notify_credit_card_events();\r\n    	succeeded	1 row	2025-01-26 08:00:00.131707+00	2025-01-26 08:00:00.145893+00
4	53	496008	postgres	postgres	\r\n    SELECT public.update_installment_purchases();\r\n    	succeeded	1 row	2025-01-26 02:00:00.018449+00	2025-01-26 02:00:00.023422+00
3	56	514608	postgres	postgres	\r\n    DO \r\n    $do$\r\n    DECLARE\r\n        v_record record;\r\n    BEGIN\r\n        FOR v_record IN \r\n            SELECT cc.id\r\n            FROM public.credit_card_details cc\r\n            WHERE public.calculate_next_cut_off_date(cc.cut_off_day) = CURRENT_DATE\r\n        LOOP\r\n            PERFORM public.generate_credit_card_statement(v_record.id);\r\n        END LOOP;\r\n    END\r\n    $do$;\r\n    	succeeded	DO	2025-01-27 01:00:00.209169+00	2025-01-27 01:00:00.212545+00
4	73	592527	postgres	postgres	\r\n    SELECT public.update_installment_purchases();\r\n    	succeeded	1 row	2025-01-31 02:00:00.019571+00	2025-01-31 02:00:00.025619+00
2	80	630584	postgres	postgres	\r\n    SELECT public.process_recurring_transactions();\r\n    	succeeded	1 row	2025-02-02 01:00:00.20004+00	2025-02-02 01:00:00.22209+00
4	57	515388	postgres	postgres	\r\n    SELECT public.update_installment_purchases();\r\n    	succeeded	1 row	2025-01-27 02:00:00.018342+00	2025-01-27 02:00:00.021438+00
3	68	572331	postgres	postgres	\r\n    DO \r\n    $do$\r\n    DECLARE\r\n        v_record record;\r\n    BEGIN\r\n        FOR v_record IN \r\n            SELECT cc.id\r\n            FROM public.credit_card_details cc\r\n            WHERE public.calculate_next_cut_off_date(cc.cut_off_day) = CURRENT_DATE\r\n        LOOP\r\n            PERFORM public.generate_credit_card_statement(v_record.id);\r\n        END LOOP;\r\n    END\r\n    $do$;\r\n    	succeeded	DO	2025-01-30 01:00:00.190596+00	2025-01-30 01:00:00.204093+00
3	64	553143	postgres	postgres	\r\n    DO \r\n    $do$\r\n    DECLARE\r\n        v_record record;\r\n    BEGIN\r\n        FOR v_record IN \r\n            SELECT cc.id\r\n            FROM public.credit_card_details cc\r\n            WHERE public.calculate_next_cut_off_date(cc.cut_off_day) = CURRENT_DATE\r\n        LOOP\r\n            PERFORM public.generate_credit_card_statement(v_record.id);\r\n        END LOOP;\r\n    END\r\n    $do$;\r\n    	succeeded	DO	2025-01-29 01:00:00.165495+00	2025-01-29 01:00:00.16752+00
5	58	520297	postgres	postgres	\r\n    SELECT public.notify_credit_card_events();\r\n    	succeeded	1 row	2025-01-27 08:00:00.153472+00	2025-01-27 08:00:00.179959+00
2	63	553142	postgres	postgres	\r\n    SELECT public.process_recurring_transactions();\r\n    	succeeded	1 row	2025-01-29 01:00:00.162165+00	2025-01-29 01:00:00.176406+00
2	67	572330	postgres	postgres	\r\n    SELECT public.process_recurring_transactions();\r\n    	succeeded	1 row	2025-01-30 01:00:00.189434+00	2025-01-30 01:00:00.233521+00
4	65	554014	postgres	postgres	\r\n    SELECT public.update_installment_purchases();\r\n    	succeeded	1 row	2025-01-29 02:00:00.052151+00	2025-01-29 02:00:00.055367+00
3	60	533854	postgres	postgres	\r\n    DO \r\n    $do$\r\n    DECLARE\r\n        v_record record;\r\n    BEGIN\r\n        FOR v_record IN \r\n            SELECT cc.id\r\n            FROM public.credit_card_details cc\r\n            WHERE public.calculate_next_cut_off_date(cc.cut_off_day) = CURRENT_DATE\r\n        LOOP\r\n            PERFORM public.generate_credit_card_statement(v_record.id);\r\n        END LOOP;\r\n    END\r\n    $do$;\r\n    	succeeded	DO	2025-01-28 01:00:00.204602+00	2025-01-28 01:00:00.207802+00
2	59	533853	postgres	postgres	\r\n    SELECT public.process_recurring_transactions();\r\n    	succeeded	1 row	2025-01-28 01:00:00.201137+00	2025-01-28 01:00:00.213247+00
3	72	591740	postgres	postgres	\r\n    DO \r\n    $do$\r\n    DECLARE\r\n        v_record record;\r\n    BEGIN\r\n        FOR v_record IN \r\n            SELECT cc.id\r\n            FROM public.credit_card_details cc\r\n            WHERE public.calculate_next_cut_off_date(cc.cut_off_day) = CURRENT_DATE\r\n        LOOP\r\n            PERFORM public.generate_credit_card_statement(v_record.id);\r\n        END LOOP;\r\n    END\r\n    $do$;\r\n    	succeeded	DO	2025-01-31 01:00:00.140858+00	2025-01-31 01:00:00.181866+00
2	71	591739	postgres	postgres	\r\n    SELECT public.process_recurring_transactions();\r\n    	succeeded	1 row	2025-01-31 01:00:00.133372+00	2025-01-31 01:00:00.236844+00
4	61	534676	postgres	postgres	\r\n    SELECT public.update_installment_purchases();\r\n    	succeeded	1 row	2025-01-28 02:00:00.026884+00	2025-01-28 02:00:00.030107+00
4	69	573103	postgres	postgres	\r\n    SELECT public.update_installment_purchases();\r\n    	succeeded	1 row	2025-01-30 02:00:00.018211+00	2025-01-30 02:00:00.023209+00
5	66	559113	postgres	postgres	\r\n    SELECT public.notify_credit_card_events();\r\n    	succeeded	1 row	2025-01-29 08:00:00.146196+00	2025-01-29 08:00:00.191047+00
5	62	539950	postgres	postgres	\r\n    SELECT public.notify_credit_card_events();\r\n    	succeeded	1 row	2025-01-28 08:00:00.168003+00	2025-01-28 08:00:00.191211+00
5	74	597867	postgres	postgres	\r\n    SELECT public.notify_credit_card_events();\r\n    	succeeded	1 row	2025-01-31 08:00:00.190949+00	2025-01-31 08:00:00.225752+00
4	78	612334	postgres	postgres	\r\n    SELECT public.update_installment_purchases();\r\n    	succeeded	1 row	2025-02-01 02:00:00.033282+00	2025-02-01 02:00:00.047233+00
3	77	611198	postgres	postgres	\r\n    DO \r\n    $do$\r\n    DECLARE\r\n        v_record record;\r\n    BEGIN\r\n        FOR v_record IN \r\n            SELECT cc.id\r\n            FROM public.credit_card_details cc\r\n            WHERE public.calculate_next_cut_off_date(cc.cut_off_day) = CURRENT_DATE\r\n        LOOP\r\n            PERFORM public.generate_credit_card_statement(v_record.id);\r\n        END LOOP;\r\n    END\r\n    $do$;\r\n    	succeeded	DO	2025-02-01 01:00:00.034272+00	2025-02-01 01:00:00.046219+00
5	70	577883	postgres	postgres	\r\n    SELECT public.notify_credit_card_events();\r\n    	succeeded	1 row	2025-01-30 08:00:00.044635+00	2025-01-30 08:00:00.061613+00
2	76	611197	postgres	postgres	\r\n    SELECT public.process_recurring_transactions();\r\n    	succeeded	1 row	2025-02-01 01:00:00.031428+00	2025-02-01 01:00:00.074873+00
1	75	610412	postgres	postgres	\r\n    SELECT public.archive_completed_goals(30);\r\n    	succeeded	1 row	2025-02-01 00:00:00.169555+00	2025-02-01 00:00:00.234179+00
3	81	630585	postgres	postgres	\r\n    DO \r\n    $do$\r\n    DECLARE\r\n        v_record record;\r\n    BEGIN\r\n        FOR v_record IN \r\n            SELECT cc.id\r\n            FROM public.credit_card_details cc\r\n            WHERE public.calculate_next_cut_off_date(cc.cut_off_day) = CURRENT_DATE\r\n        LOOP\r\n            PERFORM public.generate_credit_card_statement(v_record.id);\r\n        END LOOP;\r\n    END\r\n    $do$;\r\n    	succeeded	DO	2025-02-02 01:00:00.198976+00	2025-02-02 01:00:00.204253+00
5	79	617182	postgres	postgres	\r\n    SELECT public.notify_credit_card_events();\r\n    	succeeded	1 row	2025-02-01 08:00:00.05629+00	2025-02-01 08:00:00.070165+00
5	83	636220	postgres	postgres	\r\n    SELECT public.notify_credit_card_events();\r\n    	succeeded	1 row	2025-02-02 08:00:00.051134+00	2025-02-02 08:00:00.067121+00
4	82	631374	postgres	postgres	\r\n    SELECT public.update_installment_purchases();\r\n    	succeeded	1 row	2025-02-02 02:00:00.020359+00	2025-02-02 02:00:00.024929+00
2	84	649947	postgres	postgres	\r\n    SELECT public.process_recurring_transactions();\r\n    	succeeded	1 row	2025-02-03 01:00:00.130633+00	2025-02-03 01:00:00.249478+00
3	85	649948	postgres	postgres	\r\n    DO \r\n    $do$\r\n    DECLARE\r\n        v_record record;\r\n    BEGIN\r\n        FOR v_record IN \r\n            SELECT cc.id\r\n            FROM public.credit_card_details cc\r\n            WHERE public.calculate_next_cut_off_date(cc.cut_off_day) = CURRENT_DATE\r\n        LOOP\r\n            PERFORM public.generate_credit_card_statement(v_record.id);\r\n        END LOOP;\r\n    END\r\n    $do$;\r\n    	succeeded	DO	2025-02-03 01:00:00.132781+00	2025-02-03 01:00:00.189869+00
4	102	728803	postgres	postgres	\r\n    SELECT public.update_installment_purchases();\r\n    	succeeded	1 row	2025-02-07 02:00:00.143858+00	2025-02-07 02:00:00.176941+00
4	86	650735	postgres	postgres	\r\n    SELECT public.update_installment_purchases();\r\n    	succeeded	1 row	2025-02-03 02:00:00.019073+00	2025-02-03 02:00:00.027559+00
3	105	747775	postgres	postgres	\r\n    DO \r\n    $do$\r\n    DECLARE\r\n        v_record record;\r\n    BEGIN\r\n        FOR v_record IN \r\n            SELECT cc.id\r\n            FROM public.credit_card_details cc\r\n            WHERE public.calculate_next_cut_off_date(cc.cut_off_day) = CURRENT_DATE\r\n        LOOP\r\n            PERFORM public.generate_credit_card_statement(v_record.id);\r\n        END LOOP;\r\n    END\r\n    $do$;\r\n    	succeeded	DO	2025-02-08 01:00:00.215641+00	2025-02-08 01:00:00.230463+00
3	97	708201	postgres	postgres	\r\n    DO \r\n    $do$\r\n    DECLARE\r\n        v_record record;\r\n    BEGIN\r\n        FOR v_record IN \r\n            SELECT cc.id\r\n            FROM public.credit_card_details cc\r\n            WHERE public.calculate_next_cut_off_date(cc.cut_off_day) = CURRENT_DATE\r\n        LOOP\r\n            PERFORM public.generate_credit_card_statement(v_record.id);\r\n        END LOOP;\r\n    END\r\n    $do$;\r\n    	succeeded	DO	2025-02-06 01:00:00.241528+00	2025-02-06 01:00:00.272806+00
3	93	688979	postgres	postgres	\r\n    DO \r\n    $do$\r\n    DECLARE\r\n        v_record record;\r\n    BEGIN\r\n        FOR v_record IN \r\n            SELECT cc.id\r\n            FROM public.credit_card_details cc\r\n            WHERE public.calculate_next_cut_off_date(cc.cut_off_day) = CURRENT_DATE\r\n        LOOP\r\n            PERFORM public.generate_credit_card_statement(v_record.id);\r\n        END LOOP;\r\n    END\r\n    $do$;\r\n    	succeeded	DO	2025-02-05 01:00:00.191163+00	2025-02-05 01:00:00.197467+00
5	87	655598	postgres	postgres	\r\n    SELECT public.notify_credit_card_events();\r\n    	succeeded	1 row	2025-02-03 08:00:00.063804+00	2025-02-03 08:00:00.073885+00
2	92	688978	postgres	postgres	\r\n    SELECT public.process_recurring_transactions();\r\n    	succeeded	1 row	2025-02-05 01:00:00.189073+00	2025-02-05 01:00:00.207281+00
2	96	708200	postgres	postgres	\r\n    SELECT public.process_recurring_transactions();\r\n    	succeeded	1 row	2025-02-06 01:00:00.240421+00	2025-02-06 01:00:00.305502+00
2	104	747774	postgres	postgres	\r\n    SELECT public.process_recurring_transactions();\r\n    	succeeded	1 row	2025-02-08 01:00:00.213493+00	2025-02-08 01:00:00.26039+00
4	94	689750	postgres	postgres	\r\n    SELECT public.update_installment_purchases();\r\n    	succeeded	1 row	2025-02-05 02:00:00.016706+00	2025-02-05 02:00:00.019788+00
3	89	669304	postgres	postgres	\r\n    DO \r\n    $do$\r\n    DECLARE\r\n        v_record record;\r\n    BEGIN\r\n        FOR v_record IN \r\n            SELECT cc.id\r\n            FROM public.credit_card_details cc\r\n            WHERE public.calculate_next_cut_off_date(cc.cut_off_day) = CURRENT_DATE\r\n        LOOP\r\n            PERFORM public.generate_credit_card_statement(v_record.id);\r\n        END LOOP;\r\n    END\r\n    $do$;\r\n    	succeeded	DO	2025-02-04 01:00:00.259451+00	2025-02-04 01:00:00.325076+00
2	88	669303	postgres	postgres	\r\n    SELECT public.process_recurring_transactions();\r\n    	succeeded	1 row	2025-02-04 01:00:00.257203+00	2025-02-04 01:00:00.374474+00
3	101	727658	postgres	postgres	\r\n    DO \r\n    $do$\r\n    DECLARE\r\n        v_record record;\r\n    BEGIN\r\n        FOR v_record IN \r\n            SELECT cc.id\r\n            FROM public.credit_card_details cc\r\n            WHERE public.calculate_next_cut_off_date(cc.cut_off_day) = CURRENT_DATE\r\n        LOOP\r\n            PERFORM public.generate_credit_card_statement(v_record.id);\r\n        END LOOP;\r\n    END\r\n    $do$;\r\n    	succeeded	DO	2025-02-07 01:00:00.237827+00	2025-02-07 01:00:00.283626+00
2	100	727657	postgres	postgres	\r\n    SELECT public.process_recurring_transactions();\r\n    	succeeded	1 row	2025-02-07 01:00:00.234609+00	2025-02-07 01:00:00.339027+00
4	90	670084	postgres	postgres	\r\n    SELECT public.update_installment_purchases();\r\n    	succeeded	1 row	2025-02-04 02:00:00.022775+00	2025-02-04 02:00:00.037291+00
4	98	708997	postgres	postgres	\r\n    SELECT public.update_installment_purchases();\r\n    	succeeded	1 row	2025-02-06 02:00:00.073755+00	2025-02-06 02:00:00.077489+00
5	95	694715	postgres	postgres	\r\n    SELECT public.notify_credit_card_events();\r\n    	succeeded	1 row	2025-02-05 08:00:00.159305+00	2025-02-05 08:00:00.172057+00
5	91	674918	postgres	postgres	\r\n    SELECT public.notify_credit_card_events();\r\n    	succeeded	1 row	2025-02-04 08:00:00.142121+00	2025-02-04 08:00:00.175286+00
5	103	734595	postgres	postgres	\r\n    SELECT public.notify_credit_card_events();\r\n    	succeeded	1 row	2025-02-07 08:00:00.201154+00	2025-02-07 08:00:00.328966+00
5	99	713853	postgres	postgres	\r\n    SELECT public.notify_credit_card_events();\r\n    	succeeded	1 row	2025-02-06 08:00:00.11943+00	2025-02-06 08:00:00.147753+00
4	106	748547	postgres	postgres	\r\n    SELECT public.update_installment_purchases();\r\n    	succeeded	1 row	2025-02-08 02:00:00.017796+00	2025-02-08 02:00:00.022854+00
5	107	753313	postgres	postgres	\r\n    SELECT public.notify_credit_card_events();\r\n    	succeeded	1 row	2025-02-08 08:00:00.159975+00	2025-02-08 08:00:00.208938+00
\.


--
-- Data for Name: key; Type: TABLE DATA; Schema: pgsodium; Owner: supabase_admin
--

COPY pgsodium.key (id, status, created, expires, key_type, key_id, key_context, name, associated_data, raw_key, raw_key_nonce, parent_key, comment, user_data) FROM stdin;
\.


--
-- Data for Name: account; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.account (id, user_id, account_type_id, name, description, currency_id, current_balance, is_active, created_at, modified_at) FROM stdin;
33db3427-055e-4592-93f4-0a063832cb3d	8fd89363-cdda-45b8-b662-cab6d44e2bca	f4a4f07f-7718-4cb6-8058-6ab05f152a23	Nomina	Roche BBVA	6fa923e7-2f19-41fb-b17a-b020dbb33d34	0.00	t	2025-01-17 13:43:21.17189+00	2025-01-17 22:04:37.68466+00
\.


--
-- Data for Name: account_type; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.account_type (id, name, description, is_active, created_at, modified_at) FROM stdin;
362196de-bf78-49b2-bc6b-1a14e9a1816b	Cuenta de Cheques	Cuenta bancaria principal	t	2025-01-10 19:12:44.770172+00	\N
f4a4f07f-7718-4cb6-8058-6ab05f152a23	Cuenta de Ahorro	Cuenta para ahorros	t	2025-01-10 19:12:44.770172+00	\N
cf4fcb05-79e2-4b16-9a1c-47ff73187eb5	Efectivo	Dinero en efectivo	t	2025-01-10 19:12:44.770172+00	\N
dbb76f78-20d0-420d-9fef-7469492d868f	Tarjeta de Crédito	Tarjeta de crédito bancaria	t	2025-01-10 19:12:44.770172+00	\N
70bc3674-a6e6-4f59-870f-031a34b363b7	Inversión	Cuenta de inversiones	t	2025-01-10 19:12:44.770172+00	\N
157b36c0-3585-4992-8b5c-ff1c2c5c9b69	Préstamos	Préstamos y créditos bancarios	t	2025-01-16 04:58:50.747292+00	\N
\.


--
-- Data for Name: app_user; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.app_user (id, email, first_name, last_name, default_currency_id, notifications_enabled, notification_advance_days, is_active, created_at, modified_at) FROM stdin;
8fd89363-cdda-45b8-b662-cab6d44e2bca	enki@adastra.lat	Christian J	Rodríguez Sámano 	6fa923e7-2f19-41fb-b17a-b020dbb33d34	t	1	t	2025-01-11 00:48:59.92796+00	2025-01-25 22:09:41.790401+00
\.


--
-- Data for Name: balance_history; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.balance_history (id, user_id, account_id, jar_id, old_balance, new_balance, change_amount, change_type, reference_type, reference_id, created_at) FROM stdin;
\.


--
-- Data for Name: category; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.category (id, name, description, transaction_type_id, is_active, created_at, modified_at) FROM stdin;
a30fd06d-8da9-4466-927e-93602a7eb564	Bienestar	Gastos relacionados con salud y bienestar	37ff3c27-c813-4fbf-986c-4e5f94bbba01	t	2025-01-14 06:27:51.165001+00	\N
6b4f7c0b-409c-451f-8014-918bd849b5f2	Hogar	Gastos relacionados con vivienda	37ff3c27-c813-4fbf-986c-4e5f94bbba01	t	2025-01-14 06:27:51.165001+00	\N
174554bc-69fc-495b-ae2b-36bcee604ea5	Familia	Gastos relacionados con familia	37ff3c27-c813-4fbf-986c-4e5f94bbba01	t	2025-01-14 06:27:51.165001+00	\N
e8df3d86-41d3-4709-9633-45e683549040	Suscripciones	Gastos relacionados con servicios recurrentes	37ff3c27-c813-4fbf-986c-4e5f94bbba01	t	2025-01-14 06:27:51.165001+00	\N
896da45f-b049-4c75-b5f8-02ed164deb4d	Compras	Gastos relacionados con compras personales	37ff3c27-c813-4fbf-986c-4e5f94bbba01	t	2025-01-14 06:27:51.165001+00	2025-01-17 05:38:29.606501+00
6c798419-75b2-43b7-b0fe-a9f32c49c0fd	Alimentación	Gastos relacionados con alimentación	37ff3c27-c813-4fbf-986c-4e5f94bbba01	t	2025-01-14 06:27:51.165001+00	2025-01-17 12:39:37.30315+00
7682c2eb-fc71-400b-80fa-c763bef9a3eb	Wealth	Fuentes de ingreso 	42780b1f-892c-4faa-ae7d-264890e7163a	t	2025-01-17 06:40:34.460894+00	2025-01-17 12:41:34.531985+00
3887530f-04f4-49c5-bef7-0e26ad2e8c00	Mascotas	Gastos relacionados con mascotas	37ff3c27-c813-4fbf-986c-4e5f94bbba01	t	2025-01-14 06:27:51.165001+00	2025-01-27 02:21:16.292359+00
\.


--
-- Data for Name: credit_card_details; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.credit_card_details (id, account_id, credit_limit, current_interest_rate, cut_off_day, payment_due_day, minimum_payment_percentage, created_at, modified_at) FROM stdin;
\.


--
-- Data for Name: credit_card_interest_history; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.credit_card_interest_history (id, credit_card_id, old_rate, new_rate, change_date, reason, created_at) FROM stdin;
\.


--
-- Data for Name: credit_card_statement; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.credit_card_statement (id, credit_card_id, statement_date, cut_off_date, due_date, previous_balance, purchases_amount, payments_amount, interests_amount, ending_balance, minimum_payment, remaining_credit, status, created_at, modified_at) FROM stdin;
\.


--
-- Data for Name: currency; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.currency (id, code, name, symbol, is_active, created_at, modified_at) FROM stdin;
6fa923e7-2f19-41fb-b17a-b020dbb33d34	MXN	Peso Mexicano	$	t	2025-01-10 19:12:44.770172+00	\N
57931f08-dc3d-4a31-8cbc-ba812c8c3b6f	USD	Dólar americano	\N	t	2025-01-11 16:34:57.84948+00	\N
\.


--
-- Data for Name: financial_goal; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.financial_goal (id, user_id, name, description, target_amount, current_amount, start_date, target_date, jar_id, status, is_active, created_at, modified_at) FROM stdin;
\.


--
-- Data for Name: installment_purchase; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.installment_purchase (id, transaction_id, credit_card_id, total_amount, number_of_installments, installment_amount, remaining_installments, next_installment_date, status, created_at, modified_at) FROM stdin;
\.


--
-- Data for Name: jar; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.jar (id, name, description, target_percentage, is_active, created_at, modified_at) FROM stdin;
b5b3a838-3c90-432f-b7dc-a6ab37435594	Necesidades	Gastos necesarios y obligatorios	55.00	t	2025-01-10 19:12:44.770172+00	\N
9bb93ef6-2975-47a6-b9f3-a3f7f07f1d50	Inversión a Largo Plazo	Inversiones para el futuro	10.00	t	2025-01-10 19:12:44.770172+00	\N
c9bc6f62-fa55-4cbe-91e3-04e15d58980e	Ahorro	Ahorro para emergencias y metas	10.00	t	2025-01-10 19:12:44.770172+00	\N
aa9b583e-8921-4bf8-901a-c2c65a84f863	Educación	Desarrollo personal y profesional	10.00	t	2025-01-10 19:12:44.770172+00	\N
6e0dd1d2-e31f-4d66-acaa-3acbed11c853	Ocio	Entretenimiento y diversión	10.00	t	2025-01-10 19:12:44.770172+00	\N
19d0c841-2548-426f-8dd9-81db4908cd28	Donaciones	Ayuda a otros	5.00	t	2025-01-10 19:12:44.770172+00	\N
\.


--
-- Data for Name: jar_balance; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.jar_balance (id, user_id, jar_id, current_balance, created_at, modified_at) FROM stdin;
b6aa72ce-01fa-4620-aceb-2367b320b7e0	8fd89363-cdda-45b8-b662-cab6d44e2bca	b5b3a838-3c90-432f-b7dc-a6ab37435594	0.00	2025-01-11 00:48:59.92796+00	\N
bfcbb845-e628-425e-ae8a-eda6130876ed	8fd89363-cdda-45b8-b662-cab6d44e2bca	9bb93ef6-2975-47a6-b9f3-a3f7f07f1d50	0.00	2025-01-11 00:48:59.92796+00	\N
95fcce7b-10c5-42bf-8e80-015c7b7fb07b	8fd89363-cdda-45b8-b662-cab6d44e2bca	c9bc6f62-fa55-4cbe-91e3-04e15d58980e	0.00	2025-01-11 00:48:59.92796+00	\N
ed7a9b11-f13e-470a-81cb-336b6e13db18	8fd89363-cdda-45b8-b662-cab6d44e2bca	aa9b583e-8921-4bf8-901a-c2c65a84f863	0.00	2025-01-11 00:48:59.92796+00	\N
537bd74f-842f-4fab-9992-59a883519b02	8fd89363-cdda-45b8-b662-cab6d44e2bca	6e0dd1d2-e31f-4d66-acaa-3acbed11c853	0.00	2025-01-11 00:48:59.92796+00	\N
64caed15-f599-4069-b0ec-e395214fdc23	8fd89363-cdda-45b8-b662-cab6d44e2bca	19d0c841-2548-426f-8dd9-81db4908cd28	0.00	2025-01-11 00:48:59.92796+00	\N
\.


--
-- Data for Name: notification; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.notification (id, user_id, title, message, notification_type, urgency_level, related_entity_type, related_entity_id, is_read, created_at, read_at) FROM stdin;
\.


--
-- Data for Name: recurring_transaction; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.recurring_transaction (id, user_id, name, description, amount, transaction_type_id, category_id, subcategory_id, account_id, jar_id, transaction_medium_id, frequency, start_date, end_date, last_execution_date, next_execution_date, is_active, created_at, modified_at) FROM stdin;
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.schema_migrations (version) FROM stdin;
\.


--
-- Data for Name: subcategory; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subcategory (id, name, description, category_id, jar_id, is_active, created_at, modified_at) FROM stdin;
0a124972-f729-437f-84a6-0e2d552d23c2	Medicamentos	\N	a30fd06d-8da9-4466-927e-93602a7eb564	b5b3a838-3c90-432f-b7dc-a6ab37435594	t	2025-01-14 06:27:51.165001+00	\N
1e80e529-6018-4ceb-ab67-b0e4c86f9758	Doctor	\N	a30fd06d-8da9-4466-927e-93602a7eb564	b5b3a838-3c90-432f-b7dc-a6ab37435594	t	2025-01-14 06:27:51.165001+00	\N
2a542d7e-2930-4f7f-8c2b-2d2b03412192	Pensión	\N	174554bc-69fc-495b-ae2b-36bcee604ea5	b5b3a838-3c90-432f-b7dc-a6ab37435594	t	2025-01-14 06:27:51.165001+00	\N
89642c3d-d13e-4c28-928e-ac9014787bfd	Internet	\N	6b4f7c0b-409c-451f-8014-918bd849b5f2	b5b3a838-3c90-432f-b7dc-a6ab37435594	t	2025-01-14 06:27:51.165001+00	\N
2654b443-8f19-4627-acc2-b5aa7bc531f0	Línea telefónica	\N	e8df3d86-41d3-4709-9633-45e683549040	b5b3a838-3c90-432f-b7dc-a6ab37435594	t	2025-01-14 06:27:51.165001+00	\N
16452d30-4261-4704-a58f-aa8a5f5d1077	Alimentos	\N	6c798419-75b2-43b7-b0fe-a9f32c49c0fd	b5b3a838-3c90-432f-b7dc-a6ab37435594	t	2025-01-14 06:27:51.165001+00	\N
459d1521-e74f-4eea-93c0-51649836fadc	Lavandería	\N	6b4f7c0b-409c-451f-8014-918bd849b5f2	b5b3a838-3c90-432f-b7dc-a6ab37435594	t	2025-01-14 06:27:51.165001+00	\N
5c3f3857-fab6-4bcb-88cb-97d5794044ef	Alimento mascota	\N	3887530f-04f4-49c5-bef7-0e26ad2e8c00	b5b3a838-3c90-432f-b7dc-a6ab37435594	t	2025-01-14 06:27:51.165001+00	\N
0825908f-ad29-4497-a2b3-b6926b4e2ec7	Psicólogo	\N	a30fd06d-8da9-4466-927e-93602a7eb564	b5b3a838-3c90-432f-b7dc-a6ab37435594	t	2025-01-14 06:27:51.165001+00	\N
9aea6430-7828-4a0e-bc2f-b76fdc022289	Claude AI	Servicio de Inteligencia Artificial	e8df3d86-41d3-4709-9633-45e683549040	aa9b583e-8921-4bf8-901a-c2c65a84f863	t	2025-01-16 20:58:12.626774+00	2025-01-16 20:58:12.62679+00
70c317a2-cbdd-4ed4-b713-68abf08195fe	Ropa	\N	896da45f-b049-4c75-b5f8-02ed164deb4d	6e0dd1d2-e31f-4d66-acaa-3acbed11c853	t	2025-01-14 06:27:51.165001+00	2025-01-17 06:03:08.20509+00
34fdca02-8582-48c1-a1eb-c6c6fb98f3fa	Regalos	Regalos para amistades o familiares	896da45f-b049-4c75-b5f8-02ed164deb4d	6e0dd1d2-e31f-4d66-acaa-3acbed11c853	t	2025-01-17 06:27:55.756819+00	2025-01-17 06:27:55.756832+00
4af4ed66-226e-4da7-a769-9adae5f19fad	Renta	\N	6b4f7c0b-409c-451f-8014-918bd849b5f2	b5b3a838-3c90-432f-b7dc-a6ab37435594	t	2025-01-14 06:27:51.165001+00	2025-01-28 04:49:43.633791+00
\.


--
-- Data for Name: transaction; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.transaction (id, user_id, transaction_date, description, amount, transaction_type_id, category_id, subcategory_id, account_id, transaction_medium_id, currency_id, exchange_rate, is_recurring, parent_recurring_id, sync_status, created_at, modified_at, installment_purchase_id, tags, notes) FROM stdin;
\.


--
-- Data for Name: transaction_medium; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.transaction_medium (id, name, description, is_active, created_at, modified_at) FROM stdin;
049ca632-aa41-4a5b-bef2-ea5cb4387cdc	Efectivo	Pago en efectivo	t	2025-01-10 19:12:44.770172+00	\N
627fd6fd-068c-4390-9b72-66296e45f71f	Tarjeta de Débito	Pago con tarjeta de débito	t	2025-01-10 19:12:44.770172+00	\N
c2380ebb-6665-4d09-abdc-8191576f95c4	Tarjeta de Crédito	Pago con tarjeta de crédito	t	2025-01-10 19:12:44.770172+00	\N
ea8d1466-8c1f-4402-8a69-859d4ae74e85	Transferencia	Transferencia bancaria	t	2025-01-10 19:12:44.770172+00	\N
535b811f-bf81-4671-97cd-f57e603ebefe	Otro	Otros medios de pago	t	2025-01-10 19:12:44.770172+00	\N
\.


--
-- Data for Name: transaction_type; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.transaction_type (id, name, description, is_active, created_at, modified_at) FROM stdin;
42780b1f-892c-4faa-ae7d-264890e7163a	Ingreso	Entrada de dinero	t	2025-01-10 19:12:44.770172+00	\N
37ff3c27-c813-4fbf-986c-4e5f94bbba01	Gasto	Salida de dinero	t	2025-01-10 19:12:44.770172+00	\N
b520ced4-0733-4dcf-af84-7f4dd3d8c71e	Transferencia	Movimiento entre cuentas o jarras	t	2025-01-10 19:12:44.770172+00	\N
\.


--
-- Data for Name: transfer; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.transfer (id, user_id, transfer_date, description, amount, transfer_type, from_account_id, to_account_id, from_jar_id, to_jar_id, exchange_rate, notes, sync_status, created_at, modified_at) FROM stdin;
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: realtime; Owner: supabase_admin
--

COPY realtime.schema_migrations (version, inserted_at) FROM stdin;
20211116024918	2025-01-01 12:34:49
20211116045059	2025-01-01 12:34:50
20211116050929	2025-01-01 12:34:50
20211116051442	2025-01-01 12:34:51
20211116212300	2025-01-01 12:34:52
20211116213355	2025-01-01 12:34:52
20211116213934	2025-01-01 12:34:53
20211116214523	2025-01-01 12:34:54
20211122062447	2025-01-01 12:34:54
20211124070109	2025-01-01 12:34:55
20211202204204	2025-01-01 12:34:56
20211202204605	2025-01-01 12:34:56
20211210212804	2025-01-01 12:34:58
20211228014915	2025-01-01 12:34:59
20220107221237	2025-01-01 12:34:59
20220228202821	2025-01-01 12:35:00
20220312004840	2025-01-01 12:35:01
20220603231003	2025-01-01 12:35:02
20220603232444	2025-01-01 12:35:02
20220615214548	2025-01-01 12:35:03
20220712093339	2025-01-01 12:35:04
20220908172859	2025-01-01 12:35:04
20220916233421	2025-01-01 12:35:05
20230119133233	2025-01-01 12:35:05
20230128025114	2025-01-01 12:35:06
20230128025212	2025-01-01 12:35:07
20230227211149	2025-01-01 12:35:08
20230228184745	2025-01-01 12:35:08
20230308225145	2025-01-01 12:35:09
20230328144023	2025-01-01 12:35:09
20231018144023	2025-01-01 12:35:10
20231204144023	2025-01-01 12:35:11
20231204144024	2025-01-01 12:35:12
20231204144025	2025-01-01 12:35:12
20240108234812	2025-01-01 12:35:13
20240109165339	2025-01-01 12:35:13
20240227174441	2025-01-01 12:35:15
20240311171622	2025-01-01 12:35:15
20240321100241	2025-01-01 12:35:17
20240401105812	2025-01-01 12:35:18
20240418121054	2025-01-01 12:35:19
20240523004032	2025-01-01 12:35:22
20240618124746	2025-01-01 12:35:22
20240801235015	2025-01-01 12:35:23
20240805133720	2025-01-01 12:35:24
20240827160934	2025-01-01 12:35:24
20240919163303	2025-01-01 12:35:25
20240919163305	2025-01-01 12:35:26
20241019105805	2025-01-01 12:35:26
20241030150047	2025-01-01 12:35:29
20241108114728	2025-01-01 12:35:30
20241121104152	2025-01-01 12:35:30
20241130184212	2025-01-01 12:35:31
20241220035512	2025-01-10 18:42:01
20241220123912	2025-01-10 18:42:02
20241224161212	2025-01-10 18:42:03
20250107150512	2025-01-10 18:42:04
20250110162412	2025-01-10 18:42:04
20250123174212	2025-02-05 06:27:48
20250128220012	2025-02-05 06:27:48
\.


--
-- Data for Name: subscription; Type: TABLE DATA; Schema: realtime; Owner: supabase_admin
--

COPY realtime.subscription (id, subscription_id, entity, filters, claims, created_at) FROM stdin;
\.


--
-- Data for Name: buckets; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY storage.buckets (id, name, owner, created_at, updated_at, public, avif_autodetection, file_size_limit, allowed_mime_types, owner_id) FROM stdin;
avatars	avatars	\N	2025-01-02 15:47:14.319363+00	2025-01-02 15:47:14.319363+00	t	f	\N	\N	\N
\.


--
-- Data for Name: migrations; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY storage.migrations (id, name, hash, executed_at) FROM stdin;
0	create-migrations-table	e18db593bcde2aca2a408c4d1100f6abba2195df	2025-01-01 12:30:38.670773
1	initialmigration	6ab16121fbaa08bbd11b712d05f358f9b555d777	2025-01-01 12:30:38.696804
2	storage-schema	5c7968fd083fcea04050c1b7f6253c9771b99011	2025-01-01 12:30:38.709469
3	pathtoken-column	2cb1b0004b817b29d5b0a971af16bafeede4b70d	2025-01-01 12:30:38.741795
4	add-migrations-rls	427c5b63fe1c5937495d9c635c263ee7a5905058	2025-01-01 12:30:38.773089
5	add-size-functions	79e081a1455b63666c1294a440f8ad4b1e6a7f84	2025-01-01 12:30:38.784659
6	change-column-name-in-get-size	f93f62afdf6613ee5e7e815b30d02dc990201044	2025-01-01 12:30:38.797522
7	add-rls-to-buckets	e7e7f86adbc51049f341dfe8d30256c1abca17aa	2025-01-01 12:30:38.810901
8	add-public-to-buckets	fd670db39ed65f9d08b01db09d6202503ca2bab3	2025-01-01 12:30:38.82352
9	fix-search-function	3a0af29f42e35a4d101c259ed955b67e1bee6825	2025-01-01 12:30:38.836644
10	search-files-search-function	68dc14822daad0ffac3746a502234f486182ef6e	2025-01-01 12:30:38.848375
11	add-trigger-to-auto-update-updated_at-column	7425bdb14366d1739fa8a18c83100636d74dcaa2	2025-01-01 12:30:38.861764
12	add-automatic-avif-detection-flag	8e92e1266eb29518b6a4c5313ab8f29dd0d08df9	2025-01-01 12:30:38.880928
13	add-bucket-custom-limits	cce962054138135cd9a8c4bcd531598684b25e7d	2025-01-01 12:30:38.893742
14	use-bytes-for-max-size	941c41b346f9802b411f06f30e972ad4744dad27	2025-01-01 12:30:38.906487
15	add-can-insert-object-function	934146bc38ead475f4ef4b555c524ee5d66799e5	2025-01-01 12:30:38.942626
16	add-version	76debf38d3fd07dcfc747ca49096457d95b1221b	2025-01-01 12:30:38.955383
17	drop-owner-foreign-key	f1cbb288f1b7a4c1eb8c38504b80ae2a0153d101	2025-01-01 12:30:38.967225
18	add_owner_id_column_deprecate_owner	e7a511b379110b08e2f214be852c35414749fe66	2025-01-01 12:30:38.982463
19	alter-default-value-objects-id	02e5e22a78626187e00d173dc45f58fa66a4f043	2025-01-01 12:30:38.996356
20	list-objects-with-delimiter	cd694ae708e51ba82bf012bba00caf4f3b6393b7	2025-01-01 12:30:39.011387
21	s3-multipart-uploads	8c804d4a566c40cd1e4cc5b3725a664a9303657f	2025-01-01 12:30:39.030186
22	s3-multipart-uploads-big-ints	9737dc258d2397953c9953d9b86920b8be0cdb73	2025-01-01 12:30:39.070328
23	optimize-search-function	9d7e604cddc4b56a5422dc68c9313f4a1b6f132c	2025-01-01 12:30:39.11503
24	operation-function	8312e37c2bf9e76bbe841aa5fda889206d2bf8aa	2025-01-01 12:30:39.163815
25	custom-metadata	67eb93b7e8d401cafcdc97f9ac779e71a79bfe03	2025-01-01 12:30:39.286067
\.


--
-- Data for Name: objects; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY storage.objects (id, bucket_id, name, owner, created_at, updated_at, last_accessed_at, metadata, version, owner_id, user_metadata) FROM stdin;
c840162c-3e41-4ac3-b8ed-4cdbd8cfdc44	avatars	default_avatar.png	\N	2025-01-02 15:47:58.398187+00	2025-01-03 06:37:30.392187+00	2025-01-02 15:47:58.398187+00	{"eTag": "\\"2f967b12d0700348f82ba13cad695682\\"", "size": 458522, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-01-03T06:37:31.000Z", "contentLength": 458522, "httpStatusCode": 200}	fa1a7faa-6f4c-4e1d-8d88-318f4b5e3bed	\N	\N
\.


--
-- Data for Name: s3_multipart_uploads; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY storage.s3_multipart_uploads (id, in_progress_size, upload_signature, bucket_id, key, version, owner_id, created_at, user_metadata) FROM stdin;
\.


--
-- Data for Name: s3_multipart_uploads_parts; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY storage.s3_multipart_uploads_parts (id, upload_id, size, part_number, bucket_id, key, etag, owner_id, version, created_at) FROM stdin;
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: supabase_migrations; Owner: postgres
--

COPY supabase_migrations.schema_migrations (version, statements, name) FROM stdin;
20250123053112	{"SET statement_timeout = 0","SET lock_timeout = 0","SET idle_in_transaction_session_timeout = 0","SET client_encoding = 'UTF8'","SET standard_conforming_strings = on","SELECT pg_catalog.set_config('search_path', '', false)","SET check_function_bodies = false","SET xmloption = content","SET client_min_messages = warning","SET row_security = off","CREATE EXTENSION IF NOT EXISTS \\"pg_cron\\" WITH SCHEMA \\"pg_catalog\\"","CREATE EXTENSION IF NOT EXISTS \\"pgsodium\\" WITH SCHEMA \\"pgsodium\\"","COMMENT ON SCHEMA \\"public\\" IS 'standard public schema'","CREATE EXTENSION IF NOT EXISTS \\"pg_graphql\\" WITH SCHEMA \\"graphql\\"","CREATE EXTENSION IF NOT EXISTS \\"pg_stat_statements\\" WITH SCHEMA \\"extensions\\"","CREATE EXTENSION IF NOT EXISTS \\"pgcrypto\\" WITH SCHEMA \\"extensions\\"","CREATE EXTENSION IF NOT EXISTS \\"pgjwt\\" WITH SCHEMA \\"extensions\\"","CREATE EXTENSION IF NOT EXISTS \\"supabase_vault\\" WITH SCHEMA \\"vault\\"","CREATE EXTENSION IF NOT EXISTS \\"uuid-ossp\\" WITH SCHEMA \\"extensions\\"","CREATE TYPE \\"public\\".\\"goal_progress_status\\" AS (\n\t\\"percentage_complete\\" numeric(5,2),\n\t\\"amount_remaining\\" numeric(15,2),\n\t\\"days_remaining\\" integer,\n\t\\"is_on_track\\" boolean,\n\t\\"required_daily_amount\\" numeric(15,2)\n)","ALTER TYPE \\"public\\".\\"goal_progress_status\\" OWNER TO \\"postgres\\"","CREATE TYPE \\"public\\".\\"jar_distribution_summary\\" AS (\n\t\\"jar_name\\" \\"text\\",\n\t\\"current_percentage\\" numeric(5,2),\n\t\\"target_percentage\\" numeric(5,2),\n\t\\"difference\\" numeric(5,2),\n\t\\"is_compliant\\" boolean\n)","ALTER TYPE \\"public\\".\\"jar_distribution_summary\\" OWNER TO \\"postgres\\"","CREATE TYPE \\"public\\".\\"period_summary_type\\" AS (\n\t\\"total_income\\" numeric(15,2),\n\t\\"total_expenses\\" numeric(15,2),\n\t\\"net_amount\\" numeric(15,2),\n\t\\"savings_rate\\" numeric(5,2),\n\t\\"expense_income_ratio\\" numeric(5,2)\n)","ALTER TYPE \\"public\\".\\"period_summary_type\\" OWNER TO \\"postgres\\"","CREATE TYPE \\"public\\".\\"recurring_process_result\\" AS (\n\t\\"transactions_created\\" integer,\n\t\\"notifications_sent\\" integer,\n\t\\"errors_encountered\\" integer\n)","ALTER TYPE \\"public\\".\\"recurring_process_result\\" OWNER TO \\"postgres\\"","CREATE TYPE \\"public\\".\\"transfer_validation_result\\" AS (\n\t\\"is_valid\\" boolean,\n\t\\"error_message\\" \\"text\\",\n\t\\"source_balance\\" numeric(15,2),\n\t\\"target_balance\\" numeric(15,2)\n)","ALTER TYPE \\"public\\".\\"transfer_validation_result\\" OWNER TO \\"postgres\\"","CREATE OR REPLACE FUNCTION \\"public\\".\\"analyze_financial_goal\\"(\\"p_goal_id\\" \\"uuid\\") RETURNS TABLE(\\"name\\" \\"text\\", \\"target_amount\\" numeric, \\"current_amount\\" numeric, \\"percentage_complete\\" numeric, \\"amount_remaining\\" numeric, \\"days_remaining\\" integer, \\"is_on_track\\" boolean, \\"required_daily_amount\\" numeric, \\"average_daily_progress\\" numeric, \\"projected_completion_date\\" \\"date\\", \\"status\\" \\"text\\")\n    LANGUAGE \\"plpgsql\\"\n    AS $$\r\nBEGIN\r\n    RETURN QUERY\r\n    WITH goal_data AS (\r\n        SELECT \r\n            g.*,\r\n            public.calculate_goal_progress(\r\n                g.current_amount,\r\n                g.target_amount,\r\n                g.start_date,\r\n                g.target_date\r\n            ) as progress\r\n        FROM public.financial_goal g\r\n        WHERE g.id = p_goal_id\r\n    )\r\n    SELECT\r\n        g.name,\r\n        g.target_amount,\r\n        g.current_amount,\r\n        (progress).percentage_complete,\r\n        (progress).amount_remaining,\r\n        (progress).days_remaining,\r\n        (progress).is_on_track,\r\n        (progress).required_daily_amount,\r\n        g.current_amount / NULLIF(CURRENT_DATE - g.start_date, 0) as average_daily_progress,\r\n        CASE \r\n            WHEN g.current_amount >= g.target_amount THEN g.modified_at::date\r\n            WHEN g.current_amount = 0 THEN NULL\r\n            ELSE CURRENT_DATE + \r\n                (((g.target_amount - g.current_amount) / \r\n                (g.current_amount / NULLIF(CURRENT_DATE - g.start_date, 0)))::integer)\r\n        END as projected_completion_date,\r\n        g.status\r\n    FROM goal_data g;\r\nEND;\r\n$$","ALTER FUNCTION \\"public\\".\\"analyze_financial_goal\\"(\\"p_goal_id\\" \\"uuid\\") OWNER TO \\"postgres\\"","CREATE OR REPLACE FUNCTION \\"public\\".\\"analyze_jar_distribution\\"(\\"p_user_id\\" \\"uuid\\", \\"p_start_date\\" \\"date\\" DEFAULT NULL::\\"date\\", \\"p_end_date\\" \\"date\\" DEFAULT NULL::\\"date\\") RETURNS SETOF \\"public\\".\\"jar_distribution_summary\\"\n    LANGUAGE \\"plpgsql\\"\n    AS $$\r\nDECLARE\r\n    v_total_income numeric(15,2);\r\nBEGIN\r\n    -- Obtener ingresos totales del período\r\n    SELECT COALESCE(sum(amount), 0) INTO v_total_income\r\n    FROM public.transaction t\r\n    JOIN public.transaction_type tt ON tt.id = t.transaction_type_id\r\n    WHERE t.user_id = p_user_id\r\n    AND tt.code = 'INCOME'\r\n    AND (p_start_date IS NULL OR t.transaction_date >= p_start_date)\r\n    AND (p_end_date IS NULL OR t.transaction_date <= p_end_date);\r\n\r\n    -- Retornar análisis por jarra\r\n    RETURN QUERY\r\n    WITH jar_totals AS (\r\n        SELECT \r\n            j.id,\r\n            j.name as jar_name,\r\n            j.target_percentage,\r\n            COALESCE(sum(t.amount), 0) as total_amount\r\n        FROM public.jar j\r\n        LEFT JOIN public.transaction t ON t.jar_id = j.id\r\n        WHERE (p_start_date IS NULL OR t.transaction_date >= p_start_date)\r\n        AND (p_end_date IS NULL OR t.transaction_date <= p_end_date)\r\n        AND (t.user_id = p_user_id OR t.user_id IS NULL)\r\n        GROUP BY j.id, j.name, j.target_percentage\r\n    )\r\n    SELECT \r\n        jar_name,\r\n        CASE \r\n            WHEN v_total_income > 0 THEN round((total_amount / v_total_income) * 100, 2)\r\n            ELSE 0\r\n        END as current_percentage,\r\n        target_percentage,\r\n        CASE \r\n            WHEN v_total_income > 0 THEN round((total_amount / v_total_income) * 100 - target_percentage, 2)\r\n            ELSE -target_percentage\r\n        END as difference,\r\n        CASE \r\n            WHEN v_total_income > 0 THEN \r\n                abs((total_amount / v_total_income) * 100 - target_percentage) <= 2\r\n            ELSE false\r\n        END as is_compliant\r\n    FROM jar_totals\r\n    ORDER BY target_percentage DESC;\r\nEND;\r\n$$","ALTER FUNCTION \\"public\\".\\"analyze_jar_distribution\\"(\\"p_user_id\\" \\"uuid\\", \\"p_start_date\\" \\"date\\", \\"p_end_date\\" \\"date\\") OWNER TO \\"postgres\\"","CREATE OR REPLACE FUNCTION \\"public\\".\\"analyze_transactions_by_category\\"(\\"p_user_id\\" \\"uuid\\", \\"p_start_date\\" \\"date\\", \\"p_end_date\\" \\"date\\", \\"p_transaction_type\\" \\"text\\" DEFAULT NULL::\\"text\\") RETURNS TABLE(\\"category_name\\" \\"text\\", \\"subcategory_name\\" \\"text\\", \\"transaction_count\\" bigint, \\"total_amount\\" numeric, \\"percentage_of_total\\" numeric, \\"avg_amount\\" numeric, \\"min_amount\\" numeric, \\"max_amount\\" numeric)\n    LANGUAGE \\"plpgsql\\"\n    AS $$\r\nBEGIN\r\n    RETURN QUERY\r\n    WITH transaction_totals AS (\r\n        SELECT sum(t.amount) as grand_total\r\n        FROM public.transaction t\r\n        JOIN public.transaction_type tt ON tt.id = t.transaction_type_id\r\n        WHERE t.user_id = p_user_id\r\n        AND t.transaction_date BETWEEN p_start_date AND p_end_date\r\n        AND (p_transaction_type IS NULL OR tt.code = p_transaction_type)\r\n    )\r\n    SELECT \r\n        c.name as category_name,\r\n        sc.name as subcategory_name,\r\n        count(*) as transaction_count,\r\n        sum(t.amount) as total_amount,\r\n        round((sum(t.amount) / tt.grand_total) * 100, 2) as percentage_of_total,\r\n        round(avg(t.amount), 2) as avg_amount,\r\n        min(t.amount) as min_amount,\r\n        max(t.amount) as max_amount\r\n    FROM public.transaction t\r\n    JOIN public.category c ON c.id = t.category\r\n    JOIN public.subcategory sc ON sc.id = t.sub_category\r\n    JOIN public.transaction_type typ ON typ.id = t.transaction_type_id\r\n    CROSS JOIN transaction_totals tt\r\n    WHERE t.user_id = p_user_id\r\n    AND t.transaction_date BETWEEN p_start_date AND p_end_date\r\n    AND (p_transaction_type IS NULL OR typ.code = p_transaction_type)\r\n    GROUP BY c.name, sc.name, tt.grand_total\r\n    ORDER BY total_amount DESC;\r\nEND;\r\n$$","ALTER FUNCTION \\"public\\".\\"analyze_transactions_by_category\\"(\\"p_user_id\\" \\"uuid\\", \\"p_start_date\\" \\"date\\", \\"p_end_date\\" \\"date\\", \\"p_transaction_type\\" \\"text\\") OWNER TO \\"postgres\\"","CREATE OR REPLACE FUNCTION \\"public\\".\\"archive_completed_goals\\"(\\"p_days_threshold\\" integer DEFAULT 30) RETURNS integer\n    LANGUAGE \\"plpgsql\\"\n    AS $$\r\nDECLARE\r\n    v_archived_count integer;\r\nBEGIN\r\n    UPDATE public.financial_goal\r\n    SET is_active = false\r\n    WHERE status = 'COMPLETED'\r\n    AND modified_at < CURRENT_DATE - p_days_threshold\r\n    AND is_active = true;\r\n\r\n    GET DIAGNOSTICS v_archived_count = ROW_COUNT;\r\n    RETURN v_archived_count;\r\nEND;\r\n$$","ALTER FUNCTION \\"public\\".\\"archive_completed_goals\\"(\\"p_days_threshold\\" integer) OWNER TO \\"postgres\\"","CREATE OR REPLACE FUNCTION \\"public\\".\\"calculate_goal_progress\\"(\\"p_current_amount\\" numeric, \\"p_target_amount\\" numeric, \\"p_start_date\\" \\"date\\", \\"p_target_date\\" \\"date\\") RETURNS \\"public\\".\\"goal_progress_status\\"\n    LANGUAGE \\"plpgsql\\"\n    AS $$\r\nDECLARE\r\n    v_result public.goal_progress_status;\r\n    v_total_days integer;\r\n    v_elapsed_days integer;\r\n    v_expected_amount numeric(15,2);\r\nBEGIN\r\n    -- Calcular porcentaje completado\r\n    v_result.percentage_complete := round(\r\n        (p_current_amount / NULLIF(p_target_amount, 0)) * 100,\r\n        2\r\n    );\r\n\r\n    -- Calcular monto restante\r\n    v_result.amount_remaining := p_target_amount - p_current_amount;\r\n\r\n    -- Calcular días restantes\r\n    v_result.days_remaining := p_target_date - CURRENT_DATE;\r\n\r\n    -- Calcular si está en camino\r\n    v_total_days := p_target_date - p_start_date;\r\n    v_elapsed_days := CURRENT_DATE - p_start_date;\r\n    \r\n    -- Calcular monto esperado según el tiempo transcurrido\r\n    v_expected_amount := (p_target_amount / v_total_days) * v_elapsed_days;\r\n    \r\n    -- Determinar si está en camino\r\n    v_result.is_on_track := p_current_amount >= v_expected_amount;\r\n\r\n    -- Calcular monto diario requerido para alcanzar la meta\r\n    IF v_result.days_remaining > 0 THEN\r\n        v_result.required_daily_amount := round(\r\n            v_result.amount_remaining / v_result.days_remaining,\r\n            2\r\n        );\r\n    ELSE\r\n        v_result.required_daily_amount := 0;\r\n    END IF;\r\n\r\n    RETURN v_result;\r\nEND;\r\n$$","ALTER FUNCTION \\"public\\".\\"calculate_goal_progress\\"(\\"p_current_amount\\" numeric, \\"p_target_amount\\" numeric, \\"p_start_date\\" \\"date\\", \\"p_target_date\\" \\"date\\") OWNER TO \\"postgres\\"","CREATE OR REPLACE FUNCTION \\"public\\".\\"calculate_next_cut_off_date\\"(\\"p_cut_off_day\\" integer, \\"p_from_date\\" \\"date\\" DEFAULT CURRENT_DATE) RETURNS \\"date\\"\n    LANGUAGE \\"plpgsql\\"\n    AS $$\r\nDECLARE\r\n    v_next_date date;\r\nBEGIN\r\n    -- Calcular próxima fecha de corte\r\n    v_next_date := date_trunc('month', p_from_date) + \r\n                   (p_cut_off_day - 1 || ' days')::interval;\r\n    \r\n    -- Si la fecha ya pasó, ir al siguiente mes\r\n    IF v_next_date <= p_from_date THEN\r\n        v_next_date := date_trunc('month', p_from_date + interval '1 month') + \r\n                       (p_cut_off_day - 1 || ' days')::interval;\r\n    END IF;\r\n    \r\n    RETURN v_next_date;\r\nEND;\r\n$$","ALTER FUNCTION \\"public\\".\\"calculate_next_cut_off_date\\"(\\"p_cut_off_day\\" integer, \\"p_from_date\\" \\"date\\") OWNER TO \\"postgres\\"","CREATE OR REPLACE FUNCTION \\"public\\".\\"calculate_next_execution_date\\"(\\"p_frequency\\" character varying, \\"p_start_date\\" \\"date\\", \\"p_last_execution\\" \\"date\\" DEFAULT NULL::\\"date\\") RETURNS \\"date\\"\n    LANGUAGE \\"plpgsql\\"\n    AS $$\r\nDECLARE\r\n    v_next_date date;\r\nBEGIN\r\n    -- Si no hay última ejecución, usar fecha de inicio\r\n    IF p_last_execution IS NULL THEN\r\n        v_next_date := p_start_date;\r\n    ELSE\r\n        -- Calcular siguiente fecha según frecuencia\r\n        CASE p_frequency\r\n            WHEN 'WEEKLY' THEN\r\n                v_next_date := p_last_execution + INTERVAL '1 week';\r\n            WHEN 'MONTHLY' THEN\r\n                v_next_date := p_last_execution + INTERVAL '1 month';\r\n            WHEN 'YEARLY' THEN\r\n                v_next_date := p_last_execution + INTERVAL '1 year';\r\n            ELSE\r\n                RAISE EXCEPTION 'Frecuencia no válida: %', p_frequency;\r\n        END CASE;\r\n    END IF;\r\n\r\n    RETURN v_next_date;\r\nEND;\r\n$$","ALTER FUNCTION \\"public\\".\\"calculate_next_execution_date\\"(\\"p_frequency\\" character varying, \\"p_start_date\\" \\"date\\", \\"p_last_execution\\" \\"date\\") OWNER TO \\"postgres\\"","CREATE OR REPLACE FUNCTION \\"public\\".\\"calculate_next_payment_date\\"(\\"p_payment_day\\" integer, \\"p_cut_off_date\\" \\"date\\") RETURNS \\"date\\"\n    LANGUAGE \\"plpgsql\\"\n    AS $$\r\nDECLARE\r\n    v_next_date date;\r\nBEGIN\r\n    -- Calcular próxima fecha de pago después del corte\r\n    v_next_date := date_trunc('month', p_cut_off_date) + \r\n                   (p_payment_day - 1 || ' days')::interval;\r\n    \r\n    -- Si la fecha es antes del corte, ir al siguiente mes\r\n    IF v_next_date <= p_cut_off_date THEN\r\n        v_next_date := date_trunc('month', p_cut_off_date + interval '1 month') + \r\n                       (p_payment_day - 1 || ' days')::interval;\r\n    END IF;\r\n    \r\n    RETURN v_next_date;\r\nEND;\r\n$$","ALTER FUNCTION \\"public\\".\\"calculate_next_payment_date\\"(\\"p_payment_day\\" integer, \\"p_cut_off_date\\" \\"date\\") OWNER TO \\"postgres\\"","CREATE OR REPLACE FUNCTION \\"public\\".\\"check_available_balance_for_transfer\\"(\\"p_user_id\\" \\"uuid\\", \\"p_account_id\\" \\"uuid\\" DEFAULT NULL::\\"uuid\\", \\"p_jar_id\\" \\"uuid\\" DEFAULT NULL::\\"uuid\\") RETURNS numeric\n    LANGUAGE \\"plpgsql\\"\n    AS $$\r\nDECLARE\r\n    v_balance numeric(15,2);\r\nBEGIN\r\n    IF p_account_id IS NOT NULL THEN\r\n        SELECT current_balance INTO v_balance\r\n        FROM public.account\r\n        WHERE id = p_account_id AND user_id = p_user_id;\r\n    ELSIF p_jar_id IS NOT NULL THEN\r\n        SELECT current_balance INTO v_balance\r\n        FROM public.jar_balance\r\n        WHERE jar_id = p_jar_id AND user_id = p_user_id;\r\n    ELSE\r\n        RAISE EXCEPTION 'Debe especificar una cuenta o jarra';\r\n    END IF;\r\n\r\n    RETURN COALESCE(v_balance, 0);\r\nEND;\r\n$$","ALTER FUNCTION \\"public\\".\\"check_available_balance_for_transfer\\"(\\"p_user_id\\" \\"uuid\\", \\"p_account_id\\" \\"uuid\\", \\"p_jar_id\\" \\"uuid\\") OWNER TO \\"postgres\\"","CREATE OR REPLACE FUNCTION \\"public\\".\\"check_jar_requirement\\"() RETURNS \\"trigger\\"\n    LANGUAGE \\"plpgsql\\"\n    AS $$\r\nBEGIN\r\n    IF (NEW.jar_id IS NOT NULL AND EXISTS (\r\n        SELECT 1 FROM public.category c \r\n        WHERE c.id = NEW.category_id \r\n        AND c.transaction_type_id IN (\r\n            SELECT id FROM public.transaction_type WHERE name = 'Gasto'\r\n        )\r\n    )) THEN\r\n        RETURN NEW;\r\n    ELSIF (NEW.jar_id IS NULL AND EXISTS (\r\n        SELECT 1 FROM public.category c \r\n        WHERE c.id = NEW.category_id \r\n        AND c.transaction_type_id IN (\r\n            SELECT id FROM public.transaction_type WHERE name != 'Gasto'\r\n        )\r\n    )) THEN\r\n        RETURN NEW;\r\n    ELSE\r\n        RAISE EXCEPTION 'Invalid jar_id for the given category_id';\r\n    END IF;\r\nEND;\r\n$$","ALTER FUNCTION \\"public\\".\\"check_jar_requirement\\"() OWNER TO \\"postgres\\"","CREATE OR REPLACE FUNCTION \\"public\\".\\"check_recurring_transaction_jar_requirement\\"() RETURNS \\"trigger\\"\n    LANGUAGE \\"plpgsql\\"\n    AS $$\r\nBEGIN\r\n    IF (NEW.jar_id IS NOT NULL AND EXISTS (\r\n        SELECT 1 FROM public.transaction_type t \r\n        WHERE t.id = NEW.transaction_type_id \r\n        AND t.code = 'EXPENSE'\r\n    )) THEN\r\n        RETURN NEW;\r\n    ELSIF (NEW.jar_id IS NULL AND EXISTS (\r\n        SELECT 1 FROM public.transaction_type t \r\n        WHERE t.id = NEW.transaction_type_id \r\n        AND t.code != 'EXPENSE'\r\n    )) THEN\r\n        RETURN NEW;\r\n    ELSE\r\n        RAISE EXCEPTION 'Invalid jar_id for the given transaction_type';\r\n    END IF;\r\nEND;\r\n$$","ALTER FUNCTION \\"public\\".\\"check_recurring_transaction_jar_requirement\\"() OWNER TO \\"postgres\\"","CREATE OR REPLACE FUNCTION \\"public\\".\\"check_transaction_jar_requirement\\"() RETURNS \\"trigger\\"\n    LANGUAGE \\"plpgsql\\"\n    AS $$\r\nBEGIN\r\n    IF (NEW.jar_id IS NOT NULL AND EXISTS (\r\n        SELECT 1 FROM public.transaction_type t \r\n        WHERE t.id = NEW.transaction_type_id \r\n        AND t.code = 'EXPENSE'\r\n    )) THEN\r\n        RETURN NEW;\r\n    ELSIF (NEW.jar_id IS NULL AND EXISTS (\r\n        SELECT 1 FROM public.transaction_type t \r\n        WHERE t.id = NEW.transaction_type_id \r\n        AND t.code != 'EXPENSE'\r\n    )) THEN\r\n        RETURN NEW;\r\n    ELSE\r\n        RAISE EXCEPTION 'Invalid jar_id for the given transaction_type';\r\n    END IF;\r\nEND;\r\n$$","ALTER FUNCTION \\"public\\".\\"check_transaction_jar_requirement\\"() OWNER TO \\"postgres\\"","CREATE OR REPLACE FUNCTION \\"public\\".\\"execute_account_transfer\\"(\\"p_user_id\\" \\"uuid\\", \\"p_from_account_id\\" \\"uuid\\", \\"p_to_account_id\\" \\"uuid\\", \\"p_amount\\" numeric, \\"p_exchange_rate\\" numeric DEFAULT 1, \\"p_description\\" \\"text\\" DEFAULT NULL::\\"text\\") RETURNS \\"uuid\\"\n    LANGUAGE \\"plpgsql\\"\n    AS $$\r\nDECLARE\r\n    v_validation public.transfer_validation_result;\r\n    v_transfer_id uuid;\r\nBEGIN\r\n    -- Validar la transferencia\r\n    v_validation := public.validate_account_transfer(\r\n        p_user_id,\r\n        p_from_account_id,\r\n        p_to_account_id,\r\n        p_amount,\r\n        p_exchange_rate\r\n    );\r\n\r\n    IF NOT v_validation.is_valid THEN\r\n        RAISE EXCEPTION '%', v_validation.error_message;\r\n    END IF;\r\n\r\n    -- Crear registro de transferencia\r\n    INSERT INTO public.transfer (\r\n        user_id,\r\n        transfer_type,\r\n        amount,\r\n        exchange_rate,\r\n        from_account_id,\r\n        to_account_id,\r\n        description\r\n    ) VALUES (\r\n        p_user_id,\r\n        'ACCOUNT_TO_ACCOUNT',\r\n        p_amount,\r\n        p_exchange_rate,\r\n        p_from_account_id,\r\n        p_to_account_id,\r\n        p_description\r\n    ) RETURNING id INTO v_transfer_id;\r\n\r\n    -- Actualizar balances\r\n    UPDATE public.account\r\n    SET \r\n        current_balance = current_balance - p_amount,\r\n        modified_at = CURRENT_TIMESTAMP\r\n    WHERE id = p_from_account_id;\r\n\r\n    UPDATE public.account\r\n    SET \r\n        current_balance = current_balance + (p_amount * p_exchange_rate),\r\n        modified_at = CURRENT_TIMESTAMP\r\n    WHERE id = p_to_account_id;\r\n\r\n    -- Registrar en historial\r\n    INSERT INTO public.balance_history (\r\n        user_id,\r\n        account_id,\r\n        old_balance,\r\n        new_balance,\r\n        change_amount,\r\n        change_type,\r\n        reference_type,\r\n        reference_id\r\n    ) VALUES\r\n    (\r\n        p_user_id,\r\n        p_from_account_id,\r\n        v_validation.source_balance,\r\n        v_validation.source_balance - p_amount,\r\n        p_amount,\r\n        'TRANSFER',\r\n        'transfer',\r\n        v_transfer_id\r\n    ),\r\n    (\r\n        p_user_id,\r\n        p_to_account_id,\r\n        v_validation.target_balance,\r\n        v_validation.target_balance + (p_amount * p_exchange_rate),\r\n        p_amount * p_exchange_rate,\r\n        'TRANSFER',\r\n        'transfer',\r\n        v_transfer_id\r\n    );\r\n\r\n    RETURN v_transfer_id;\r\nEND;\r\n$$","ALTER FUNCTION \\"public\\".\\"execute_account_transfer\\"(\\"p_user_id\\" \\"uuid\\", \\"p_from_account_id\\" \\"uuid\\", \\"p_to_account_id\\" \\"uuid\\", \\"p_amount\\" numeric, \\"p_exchange_rate\\" numeric, \\"p_description\\" \\"text\\") OWNER TO \\"postgres\\"","CREATE OR REPLACE FUNCTION \\"public\\".\\"execute_jar_transfer\\"(\\"p_user_id\\" \\"uuid\\", \\"p_from_jar_id\\" \\"uuid\\", \\"p_to_jar_id\\" \\"uuid\\", \\"p_amount\\" numeric, \\"p_description\\" \\"text\\" DEFAULT NULL::\\"text\\", \\"p_is_rollover\\" boolean DEFAULT false) RETURNS \\"uuid\\"\n    LANGUAGE \\"plpgsql\\"\n    AS $$\r\nDECLARE\r\n    v_validation public.transfer_validation_result;\r\n    v_transfer_id uuid;\r\nBEGIN\r\n    -- Validar la transferencia\r\n    v_validation := public.validate_jar_transfer(\r\n        p_user_id,\r\n        p_from_jar_id,\r\n        p_to_jar_id,\r\n        p_amount\r\n    );\r\n\r\n    IF NOT v_validation.is_valid THEN\r\n        RAISE EXCEPTION '%', v_validation.error_message;\r\n    END IF;\r\n\r\n    -- Crear registro de transferencia\r\n    INSERT INTO public.transfer (\r\n        user_id,\r\n        transfer_type,\r\n        amount,\r\n        from_jar_id,\r\n        to_jar_id,\r\n        description\r\n    ) VALUES (\r\n        p_user_id,\r\n        CASE WHEN p_is_rollover THEN 'PERIOD_ROLLOVER' ELSE 'JAR_TO_JAR' END,\r\n        p_amount,\r\n        p_from_jar_id,\r\n        p_to_jar_id,\r\n        p_description\r\n    ) RETURNING id INTO v_transfer_id;\r\n\r\n    -- Actualizar balances\r\n    UPDATE public.jar_balance\r\n    SET \r\n        current_balance = current_balance - p_amount,\r\n        modified_at = CURRENT_TIMESTAMP\r\n    WHERE jar_id = p_from_jar_id AND user_id = p_user_id;\r\n\r\n    UPDATE public.jar_balance\r\n    SET \r\n        current_balance = current_balance + p_amount,\r\n        modified_at = CURRENT_TIMESTAMP\r\n    WHERE jar_id = p_to_jar_id AND user_id = p_user_id;\r\n\r\n    -- Registrar en historial\r\n    INSERT INTO public.balance_history (\r\n        user_id,\r\n        jar_id,\r\n        old_balance,\r\n        new_balance,\r\n        change_amount,\r\n        change_type,\r\n        reference_type,\r\n        reference_id\r\n    ) VALUES\r\n    (\r\n        p_user_id,\r\n        p_from_jar_id,\r\n        v_validation.source_balance,\r\n        v_validation.source_balance - p_amount,\r\n        p_amount,\r\n        CASE WHEN p_is_rollover THEN 'ROLLOVER' ELSE 'TRANSFER' END,\r\n        'transfer',\r\n        v_transfer_id\r\n    ),\r\n    (\r\n        p_user_id,\r\n        p_to_jar_id,\r\n        v_validation.target_balance,\r\n        v_validation.target_balance + p_amount,\r\n        p_amount,\r\n        CASE WHEN p_is_rollover THEN 'ROLLOVER' ELSE 'TRANSFER' END,\r\n        'transfer',\r\n        v_transfer_id\r\n    );\r\n\r\n    RETURN v_transfer_id;\r\nEND;\r\n$$","ALTER FUNCTION \\"public\\".\\"execute_jar_transfer\\"(\\"p_user_id\\" \\"uuid\\", \\"p_from_jar_id\\" \\"uuid\\", \\"p_to_jar_id\\" \\"uuid\\", \\"p_amount\\" numeric, \\"p_description\\" \\"text\\", \\"p_is_rollover\\" boolean) OWNER TO \\"postgres\\"","CREATE OR REPLACE FUNCTION \\"public\\".\\"export_jar_status_to_excel\\"(\\"p_user_id\\" \\"uuid\\") RETURNS TABLE(\\"jar_name\\" \\"text\\", \\"current_balance\\" numeric, \\"target_percentage\\" numeric, \\"current_percentage\\" numeric, \\"last_transaction_date\\" \\"date\\", \\"total_transactions\\" bigint)\n    LANGUAGE \\"plpgsql\\"\n    AS $$\r\nBEGIN\r\n    RETURN QUERY\r\n    SELECT \r\n        j.name as jar_name,\r\n        jb.current_balance,\r\n        j.target_percentage,\r\n        COALESCE(\r\n            (\r\n                SELECT round((sum(t.amount) / NULLIF((\r\n                    SELECT sum(amount)\r\n                    FROM public.transaction tr\r\n                    JOIN public.transaction_type tt ON tt.id = tr.transaction_type_id\r\n                    WHERE tr.user_id = p_user_id\r\n                    AND tt.code = 'INCOME'\r\n                    AND date_trunc('month', tr.transaction_date) = date_trunc('month', CURRENT_DATE)\r\n                ), 0)) * 100, 2)\r\n                FROM public.transaction t\r\n                WHERE t.jar_id = j.id\r\n                AND t.user_id = p_user_id\r\n                AND date_trunc('month', t.transaction_date) = date_trunc('month', CURRENT_DATE)\r\n            ),\r\n            0\r\n        ) as current_percentage,\r\n        (\r\n            SELECT max(transaction_date)\r\n            FROM public.transaction t\r\n            WHERE t.jar_id = j.id\r\n            AND t.user_id = p_user_id\r\n        ) as last_transaction_date,\r\n        count(t.id) as total_transactions\r\n    FROM public.jar j\r\n    LEFT JOIN public.jar_balance jb ON jb.jar_id = j.id AND jb.user_id = p_user_id\r\n    LEFT JOIN public.transaction t ON t.jar_id = j.id AND t.user_id = p_user_id\r\n    GROUP BY j.id, j.name, jb.current_balance, j.target_percentage\r\n    ORDER BY j.target_percentage DESC;\r\nEND;\r\n$$","ALTER FUNCTION \\"public\\".\\"export_jar_status_to_excel\\"(\\"p_user_id\\" \\"uuid\\") OWNER TO \\"postgres\\"","CREATE OR REPLACE FUNCTION \\"public\\".\\"export_transactions_to_excel\\"(\\"p_user_id\\" \\"uuid\\", \\"p_start_date\\" \\"date\\", \\"p_end_date\\" \\"date\\") RETURNS TABLE(\\"transaction_date\\" \\"date\\", \\"transaction_type\\" \\"text\\", \\"category\\" \\"text\\", \\"subcategory\\" \\"text\\", \\"amount\\" numeric, \\"account_name\\" \\"text\\", \\"jar_name\\" \\"text\\", \\"description\\" \\"text\\")\n    LANGUAGE \\"plpgsql\\"\n    AS $$\r\nBEGIN\r\n    RETURN QUERY\r\n    SELECT \r\n        t.transaction_date,\r\n        tt.name as transaction_type,\r\n        c.name as category,\r\n        sc.name as subcategory,\r\n        t.amount,\r\n        a.name as account_name,\r\n        j.name as jar_name,\r\n        t.description\r\n    FROM public.transaction t\r\n    JOIN public.transaction_type tt ON tt.id = t.transaction_type_id\r\n    JOIN public.category c ON c.id = t.category\r\n    JOIN public.subcategory sc ON sc.id = t.sub_category\r\n    JOIN public.account a ON a.id = t.account\r\n    LEFT JOIN public.jar j ON j.id = t.jar_id\r\n    WHERE t.user_id = p_user_id\r\n    AND t.transaction_date BETWEEN p_start_date AND p_end_date\r\n    ORDER BY t.transaction_date DESC;\r\nEND;\r\n$$","ALTER FUNCTION \\"public\\".\\"export_transactions_to_excel\\"(\\"p_user_id\\" \\"uuid\\", \\"p_start_date\\" \\"date\\", \\"p_end_date\\" \\"date\\") OWNER TO \\"postgres\\"","CREATE OR REPLACE FUNCTION \\"public\\".\\"generate_credit_card_statement\\"(\\"p_credit_card_id\\" \\"uuid\\", \\"p_statement_date\\" \\"date\\" DEFAULT CURRENT_DATE) RETURNS \\"uuid\\"\n    LANGUAGE \\"plpgsql\\"\n    AS $$\r\nDECLARE\r\n    v_card record;\r\n    v_previous_balance numeric(15,2);\r\n    v_purchases numeric(15,2);\r\n    v_payments numeric(15,2);\r\n    v_interests numeric(15,2);\r\n    v_ending_balance numeric(15,2);\r\n    v_minimum_payment numeric(15,2);\r\n    v_statement_id uuid;\r\n    v_cut_off_date date;\r\n    v_due_date date;\r\nBEGIN\r\n    -- Obtener información de la tarjeta\r\n    SELECT \r\n        cc.*,\r\n        a.current_balance\r\n    INTO v_card\r\n    FROM public.credit_card_details cc\r\n    JOIN public.account a ON a.id = cc.account_id\r\n    WHERE cc.id = p_credit_card_id;\r\n    \r\n    -- Calcular fechas importantes\r\n    v_cut_off_date := public.calculate_next_cut_off_date(v_card.cut_off_day, p_statement_date);\r\n    v_due_date := public.calculate_next_payment_date(v_card.payment_due_day, v_cut_off_date);\r\n    \r\n    -- Obtener balance del estado de cuenta anterior\r\n    SELECT COALESCE(ending_balance, 0) INTO v_previous_balance\r\n    FROM public.credit_card_statement\r\n    WHERE credit_card_id = p_credit_card_id\r\n    ORDER BY statement_date DESC\r\n    LIMIT 1;\r\n    \r\n    -- Si no hay estado anterior, usar el balance actual\r\n    IF v_previous_balance IS NULL THEN\r\n        v_previous_balance := v_card.current_balance;\r\n    END IF;\r\n    \r\n    -- Calcular movimientos del período\r\n    SELECT COALESCE(SUM(amount), 0) INTO v_purchases\r\n    FROM public.transaction\r\n    WHERE account_id = v_card.account_id\r\n    AND transaction_date BETWEEN p_statement_date AND v_cut_off_date\r\n    AND transaction_type_id = (SELECT id FROM public.transaction_type WHERE code = 'EXPENSE');\r\n    \r\n    SELECT COALESCE(SUM(amount), 0) INTO v_payments\r\n    FROM public.transaction\r\n    WHERE account_id = v_card.account_id\r\n    AND transaction_date BETWEEN p_statement_date AND v_cut_off_date\r\n    AND transaction_type_id = (SELECT id FROM public.transaction_type WHERE code = 'INCOME');\r\n    \r\n    -- Calcular intereses si aplican\r\n    IF v_previous_balance > 0 THEN\r\n        v_interests := ROUND(\r\n            (v_previous_balance * v_card.current_interest_rate / 100) / 12,\r\n            2\r\n        );\r\n    ELSE\r\n        v_interests := 0;\r\n    END IF;\r\n    \r\n    -- Calcular balance final\r\n    v_ending_balance := v_previous_balance + v_purchases - v_payments + v_interests;\r\n    \r\n    -- Calcular pago mínimo\r\n    v_minimum_payment := GREATEST(\r\n        ROUND(v_ending_balance * v_card.minimum_payment_percentage / 100, 2),\r\n        500 -- Mínimo absoluto de 500\r\n    );\r\n    \r\n    -- Crear nuevo estado de cuenta\r\n    INSERT INTO public.credit_card_statement (\r\n        credit_card_id,\r\n        statement_date,\r\n        cut_off_date,\r\n        due_date,\r\n        previous_balance,\r\n        purchases_amount,\r\n        payments_amount,\r\n        interests_amount,\r\n        ending_balance,\r\n        minimum_payment,\r\n        remaining_credit,\r\n        status\r\n    ) VALUES (\r\n        p_credit_card_id,\r\n        p_statement_date,\r\n        v_cut_off_date,\r\n        v_due_date,\r\n        v_previous_balance,\r\n        v_purchases,\r\n        v_payments,\r\n        v_interests,\r\n        v_ending_balance,\r\n        v_minimum_payment,\r\n        v_card.credit_limit - v_ending_balance,\r\n        'PENDING'\r\n    ) RETURNING id INTO v_statement_id;\r\n    \r\n    RETURN v_statement_id;\r\nEND;\r\n$$","ALTER FUNCTION \\"public\\".\\"generate_credit_card_statement\\"(\\"p_credit_card_id\\" \\"uuid\\", \\"p_statement_date\\" \\"date\\") OWNER TO \\"postgres\\"","CREATE OR REPLACE FUNCTION \\"public\\".\\"get_credit_card_statements\\"(\\"p_account_id\\" \\"uuid\\", \\"p_months\\" integer DEFAULT 12) RETURNS TABLE(\\"statement_date\\" \\"date\\", \\"cut_off_date\\" \\"date\\", \\"due_date\\" \\"date\\", \\"previous_balance\\" numeric, \\"purchases_amount\\" numeric, \\"payments_amount\\" numeric, \\"interests_amount\\" numeric, \\"ending_balance\\" numeric, \\"minimum_payment\\" numeric, \\"status\\" \\"text\\")\n    LANGUAGE \\"plpgsql\\"\n    AS $$\r\nBEGIN\r\n    RETURN QUERY\r\n    SELECT \r\n        cs.statement_date,\r\n        cs.cut_off_date,\r\n        cs.due_date,\r\n        cs.previous_balance,\r\n        cs.purchases_amount,\r\n        cs.payments_amount,\r\n        cs.interests_amount,\r\n        cs.ending_balance,\r\n        cs.minimum_payment,\r\n        cs.status\r\n    FROM public.credit_card_statement cs\r\n    JOIN public.credit_card_details cc ON cc.id = cs.credit_card_id\r\n    WHERE cc.account_id = p_account_id\r\n    AND cs.statement_date >= CURRENT_DATE - (p_months || ' months')::interval\r\n    ORDER BY cs.statement_date DESC;\r\nEND;\r\n$$","ALTER FUNCTION \\"public\\".\\"get_credit_card_statements\\"(\\"p_account_id\\" \\"uuid\\", \\"p_months\\" integer) OWNER TO \\"postgres\\"","CREATE OR REPLACE FUNCTION \\"public\\".\\"get_credit_card_summary\\"(\\"p_account_id\\" \\"uuid\\") RETURNS TABLE(\\"credit_limit\\" numeric, \\"current_balance\\" numeric, \\"available_credit\\" numeric, \\"current_interest_rate\\" numeric, \\"next_cut_off_date\\" \\"date\\", \\"next_payment_date\\" \\"date\\", \\"active_installment_purchases\\" bigint, \\"total_installment_amount\\" numeric)\n    LANGUAGE \\"plpgsql\\"\n    AS $$\r\nBEGIN\r\n    RETURN QUERY\r\n    SELECT \r\n        cc.credit_limit,\r\n        a.current_balance,\r\n        cc.credit_limit + a.current_balance as available_credit,\r\n        cc.current_interest_rate,\r\n        public.calculate_next_cut_off_date(cc.cut_off_day) as next_cut_off_date,\r\n        public.calculate_next_payment_date(\r\n            cc.payment_due_day, \r\n            public.calculate_next_cut_off_date(cc.cut_off_day)\r\n        ) as next_payment_date,\r\n        COUNT(ip.id) as active_installment_purchases,\r\n        COALESCE(SUM(ip.remaining_installments * ip.installment_amount), 0) as total_installment_amount\r\n    FROM public.credit_card_details cc\r\n    JOIN public.account a ON a.id = cc.account_id\r\n    LEFT JOIN public.installment_purchase ip ON ip.credit_card_id = cc.id \r\n        AND ip.status = 'ACTIVE'\r\n    WHERE cc.account_id = p_account_id\r\n    GROUP BY cc.credit_limit, a.current_balance, cc.current_interest_rate, \r\n             cc.cut_off_day, cc.payment_due_day;\r\nEND;\r\n$$","ALTER FUNCTION \\"public\\".\\"get_credit_card_summary\\"(\\"p_account_id\\" \\"uuid\\") OWNER TO \\"postgres\\"","CREATE OR REPLACE FUNCTION \\"public\\".\\"get_goals_summary\\"(\\"p_user_id\\" \\"uuid\\") RETURNS TABLE(\\"total_goals\\" bigint, \\"completed_goals\\" bigint, \\"in_progress_goals\\" bigint, \\"total_target_amount\\" numeric, \\"total_current_amount\\" numeric, \\"overall_completion_percentage\\" numeric)\n    LANGUAGE \\"plpgsql\\"\n    AS $$\r\nBEGIN\r\n    RETURN QUERY\r\n    SELECT\r\n        count(*),\r\n        count(*) FILTER (WHERE status = 'COMPLETED'),\r\n        count(*) FILTER (WHERE status = 'IN_PROGRESS'),\r\n        sum(target_amount),\r\n        sum(current_amount),\r\n        round(\r\n            (sum(current_amount) / NULLIF(sum(target_amount), 0)) * 100,\r\n            2\r\n        )\r\n    FROM public.financial_goal\r\n    WHERE user_id = p_user_id\r\n    AND is_active = true;\r\nEND;\r\n$$","ALTER FUNCTION \\"public\\".\\"get_goals_summary\\"(\\"p_user_id\\" \\"uuid\\") OWNER TO \\"postgres\\"","CREATE OR REPLACE FUNCTION \\"public\\".\\"get_period_summary\\"(\\"p_user_id\\" \\"uuid\\", \\"p_start_date\\" \\"date\\", \\"p_end_date\\" \\"date\\") RETURNS \\"public\\".\\"period_summary_type\\"\n    LANGUAGE \\"plpgsql\\"\n    AS $$\r\nDECLARE\r\n    v_result public.period_summary_type;\r\nBEGIN\r\n    -- Calcular ingresos totales\r\n    SELECT COALESCE(sum(t.amount), 0) INTO v_result.total_income\r\n    FROM public.transaction t\r\n    JOIN public.transaction_type tt ON tt.id = t.transaction_type_id\r\n    WHERE t.user_id = p_user_id\r\n    AND t.transaction_date BETWEEN p_start_date AND p_end_date\r\n    AND tt.code = 'INCOME';\r\n\r\n    -- Calcular gastos totales\r\n    SELECT COALESCE(sum(t.amount), 0) INTO v_result.total_expenses\r\n    FROM public.transaction t\r\n    JOIN public.transaction_type tt ON tt.id = t.transaction_type_id\r\n    WHERE t.user_id = p_user_id\r\n    AND t.transaction_date BETWEEN p_start_date AND p_end_date\r\n    AND tt.code = 'EXPENSE';\r\n\r\n    -- Calcular monto neto\r\n    v_result.net_amount := v_result.total_income - v_result.total_expenses;\r\n\r\n    -- Calcular tasa de ahorro\r\n    IF v_result.total_income > 0 THEN\r\n        v_result.savings_rate := round(\r\n            (v_result.net_amount / v_result.total_income) * 100,\r\n            2\r\n        );\r\n    ELSE\r\n        v_result.savings_rate := 0;\r\n    END IF;\r\n\r\n    -- Calcular ratio gastos/ingresos\r\n    IF v_result.total_income > 0 THEN\r\n        v_result.expense_income_ratio := round(\r\n            (v_result.total_expenses / v_result.total_income) * 100,\r\n            2\r\n        );\r\n    ELSE\r\n        v_result.expense_income_ratio := 0;\r\n    END IF;\r\n\r\n    RETURN v_result;\r\nEND;\r\n$$","ALTER FUNCTION \\"public\\".\\"get_period_summary\\"(\\"p_user_id\\" \\"uuid\\", \\"p_start_date\\" \\"date\\", \\"p_end_date\\" \\"date\\") OWNER TO \\"postgres\\"","CREATE OR REPLACE FUNCTION \\"public\\".\\"get_transfer_history\\"(\\"p_user_id\\" \\"uuid\\", \\"p_start_date\\" \\"date\\" DEFAULT NULL::\\"date\\", \\"p_end_date\\" \\"date\\" DEFAULT NULL::\\"date\\", \\"p_transfer_type\\" \\"text\\" DEFAULT NULL::\\"text\\", \\"p_limit\\" integer DEFAULT 100) RETURNS TABLE(\\"transfer_id\\" \\"uuid\\", \\"transfer_date\\" \\"date\\", \\"transfer_type\\" \\"text\\", \\"source_name\\" \\"text\\", \\"target_name\\" \\"text\\", \\"amount\\" numeric, \\"converted_amount\\" numeric, \\"description\\" \\"text\\")\n    LANGUAGE \\"plpgsql\\"\n    AS $$\r\nBEGIN\r\n    RETURN QUERY\r\n    SELECT \r\n        t.id as transfer_id,\r\n        t.transfer_date,\r\n        t.transfer_type::text,\r\n        s.source_name,\r\n        s.target_name,\r\n        t.amount,\r\n        s.converted_amount,\r\n        t.description\r\n    FROM public.transfer t\r\n    JOIN public.transfer_summary s ON s.transfer_id = t.id\r\n    WHERE t.user_id = p_user_id\r\n    AND (p_start_date IS NULL OR t.transfer_date >= p_start_date)\r\n    AND (p_end_date IS NULL OR t.transfer_date <= p_end_date)\r\n    AND (p_transfer_type IS NULL OR t.transfer_type::text = p_transfer_type)\r\n    ORDER BY t.transfer_date DESC\r\n    LIMIT p_limit;\r\nEND;\r\n$$","ALTER FUNCTION \\"public\\".\\"get_transfer_history\\"(\\"p_user_id\\" \\"uuid\\", \\"p_start_date\\" \\"date\\", \\"p_end_date\\" \\"date\\", \\"p_transfer_type\\" \\"text\\", \\"p_limit\\" integer) OWNER TO \\"postgres\\"","CREATE OR REPLACE FUNCTION \\"public\\".\\"get_transfer_summary_by_period\\"(\\"p_user_id\\" \\"uuid\\", \\"p_start_date\\" \\"date\\", \\"p_end_date\\" \\"date\\") RETURNS TABLE(\\"period\\" \\"date\\", \\"account_transfers_count\\" integer, \\"account_transfers_amount\\" numeric, \\"jar_transfers_count\\" integer, \\"jar_transfers_amount\\" numeric, \\"rollover_count\\" integer, \\"rollover_amount\\" numeric)\n    LANGUAGE \\"plpgsql\\"\n    AS $$\r\nBEGIN\r\n    RETURN QUERY\r\n    SELECT \r\n        date_trunc('month', t.transfer_date)::date as period,\r\n        count(*) FILTER (WHERE t.transfer_type = 'ACCOUNT_TO_ACCOUNT') as account_transfers_count,\r\n        coalesce(sum(s.converted_amount) FILTER (WHERE t.transfer_type = 'ACCOUNT_TO_ACCOUNT'), 0) as account_transfers_amount,\r\n        count(*) FILTER (WHERE t.transfer_type = 'JAR_TO_JAR') as jar_transfers_count,\r\n        coalesce(sum(t.amount) FILTER (WHERE t.transfer_type = 'JAR_TO_JAR'), 0) as jar_transfers_amount,\r\n        count(*) FILTER (WHERE t.transfer_type = 'PERIOD_ROLLOVER') as rollover_count,\r\n        coalesce(sum(t.amount) FILTER (WHERE t.transfer_type = 'PERIOD_ROLLOVER'), 0) as rollover_amount\r\n    FROM public.transfer t\r\n    JOIN public.transfer_summary s ON s.transfer_id = t.id\r\n    WHERE t.user_id = p_user_id\r\n    AND t.transfer_date BETWEEN p_start_date AND p_end_date\r\n    GROUP BY date_trunc('month', t.transfer_date)\r\n    ORDER BY period;\r\nEND;\r\n$$","ALTER FUNCTION \\"public\\".\\"get_transfer_summary_by_period\\"(\\"p_user_id\\" \\"uuid\\", \\"p_start_date\\" \\"date\\", \\"p_end_date\\" \\"date\\") OWNER TO \\"postgres\\"","CREATE OR REPLACE FUNCTION \\"public\\".\\"get_upcoming_recurring_transactions\\"(\\"p_user_id\\" \\"uuid\\", \\"p_days\\" integer DEFAULT 7) RETURNS TABLE(\\"id\\" \\"uuid\\", \\"name\\" \\"text\\", \\"next_execution_date\\" \\"date\\", \\"amount\\" numeric, \\"description\\" \\"text\\", \\"days_until\\" integer)\n    LANGUAGE \\"plpgsql\\"\n    AS $$\r\nBEGIN\r\n    RETURN QUERY\r\n    SELECT \r\n        r.id,\r\n        r.name,\r\n        r.next_execution_date,\r\n        r.amount,\r\n        r.description,\r\n        r.next_execution_date - CURRENT_DATE as days_until\r\n    FROM public.recurring_transaction r\r\n    WHERE r.user_id = p_user_id\r\n    AND r.is_active = true\r\n    AND r.next_execution_date <= CURRENT_DATE + p_days\r\n    ORDER BY r.next_execution_date;\r\nEND;\r\n$$","ALTER FUNCTION \\"public\\".\\"get_upcoming_recurring_transactions\\"(\\"p_user_id\\" \\"uuid\\", \\"p_days\\" integer) OWNER TO \\"postgres\\"","CREATE OR REPLACE FUNCTION \\"public\\".\\"handle_new_user\\"() RETURNS \\"trigger\\"\n    LANGUAGE \\"plpgsql\\" SECURITY DEFINER\n    AS $$\r\nDECLARE\r\n    default_currency_id uuid;\r\nBEGIN\r\n    -- Get the default currency (MXN)\r\n    SELECT id INTO default_currency_id\r\n    FROM public.currency\r\n    WHERE code = 'MXN';\r\n\r\n    -- Insert the new user into public.app_user\r\n    INSERT INTO public.app_user (\r\n        id,\r\n        email,\r\n        first_name,\r\n        last_name,\r\n        default_currency_id\r\n    )\r\n    VALUES (\r\n        NEW.id,\r\n        NEW.email,\r\n        NEW.raw_user_meta_data->>'first_name',\r\n        NEW.raw_user_meta_data->>'last_name',\r\n        default_currency_id\r\n    );\r\n\r\n    -- Create default jar balances for the user\r\n    INSERT INTO public.jar_balance (user_id, jar_id, current_balance)\r\n    SELECT \r\n        NEW.id,\r\n        j.id,\r\n        0\r\n    FROM public.jar j\r\n    WHERE j.is_system = true;\r\n\r\n    RETURN NEW;\r\nEND;\r\n$$","ALTER FUNCTION \\"public\\".\\"handle_new_user\\"() OWNER TO \\"postgres\\"","CREATE OR REPLACE FUNCTION \\"public\\".\\"initialize_system_data\\"() RETURNS \\"void\\"\n    LANGUAGE \\"plpgsql\\"\n    AS $$\r\nBEGIN\r\n    -- Insert transaction types\r\n    INSERT INTO public.transaction_type (name, description)\r\n    VALUES \r\n        ('Ingreso', 'Entrada de dinero'),\r\n        ('Gasto', 'Salida de dinero'),\r\n        ('Transferencia', 'Movimiento entre cuentas o jarras')\r\n    ON CONFLICT (name) DO NOTHING;\r\n\r\n    -- Insert transaction mediums\r\n    INSERT INTO public.transaction_medium (name, description)\r\n    VALUES \r\n        ('Efectivo', 'Pago en efectivo'),\r\n        ('Tarjeta de Débito', 'Pago con tarjeta de débito'),\r\n        ('Tarjeta de Crédito', 'Pago con tarjeta de crédito'),\r\n        ('Transferencia', 'Transferencia bancaria'),\r\n        ('Otro', 'Otros medios de pago')\r\n    ON CONFLICT (name) DO NOTHING;\r\n\r\n    -- Insert jars\r\n    INSERT INTO public.jar (name, description, target_percentage)\r\n    VALUES \r\n        ('Necesidades', 'Gastos necesarios y obligatorios', 55),\r\n        ('Inversión a Largo Plazo', 'Inversiones para el futuro', 10),\r\n        ('Ahorro', 'Ahorro para emergencias y metas', 10),\r\n        ('Educación', 'Desarrollo personal y profesional', 10),\r\n        ('Ocio', 'Entretenimiento y diversión', 10),\r\n        ('Donaciones', 'Ayuda a otros', 5)\r\n    ON CONFLICT (name) DO NOTHING;\r\n\r\n    -- Insert account types\r\n    INSERT INTO public.account_type (name, description)\r\n    VALUES \r\n        ('Cuenta de Cheques', 'Cuenta bancaria principal'),\r\n        ('Cuenta de Ahorro', 'Cuenta para ahorros'),\r\n        ('Efectivo', 'Dinero en efectivo'),\r\n        ('Tarjeta de Crédito', 'Tarjeta de crédito bancaria'),\r\n        ('Inversión', 'Cuenta de inversiones'),\r\n        ('Préstamos', 'Préstamos y créditos bancarios')\r\n    ON CONFLICT (name) DO NOTHING;\r\nEND;\r\n$$","ALTER FUNCTION \\"public\\".\\"initialize_system_data\\"() OWNER TO \\"postgres\\"","CREATE OR REPLACE FUNCTION \\"public\\".\\"notify_credit_card_events\\"() RETURNS \\"void\\"\n    LANGUAGE \\"plpgsql\\"\n    AS $$\r\nDECLARE\r\n    v_record record;\r\nBEGIN\r\n    -- Notificar fechas de corte próximas (3 días antes)\r\n    FOR v_record IN \r\n        SELECT \r\n            cc.id as credit_card_id,\r\n            a.user_id,\r\n            a.name as account_name,\r\n            public.calculate_next_cut_off_date(cc.cut_off_day) as next_cut_off\r\n        FROM public.credit_card_details cc\r\n        JOIN public.account a ON a.id = cc.account_id\r\n        WHERE public.calculate_next_cut_off_date(cc.cut_off_day) = CURRENT_DATE + interval '3 days'\r\n    LOOP\r\n        INSERT INTO public.notification (\r\n            user_id,\r\n            title,\r\n            message,\r\n            notification_type,\r\n            urgency_level,\r\n            related_entity_type,\r\n            related_entity_id\r\n        ) VALUES (\r\n            v_record.user_id,\r\n            'Próxima fecha de corte',\r\n            format('Tu tarjeta %s tendrá fecha de corte el %s',\r\n                v_record.account_name,\r\n                to_char(v_record.next_cut_off, 'DD/MM/YYYY')\r\n            ),\r\n            'CREDIT_CARD_CUT_OFF',\r\n            'HIGH',\r\n            'credit_card_details',\r\n            v_record.credit_card_id\r\n        );\r\n    END LOOP;\r\n    \r\n    -- Notificar límite de crédito cercano (90% utilizado)\r\n    FOR v_record IN \r\n        SELECT \r\n            cc.id as credit_card_id,\r\n            a.user_id,\r\n            a.name as account_name,\r\n            cc.credit_limit,\r\n            a.current_balance,\r\n            round((a.current_balance::numeric / cc.credit_limit::numeric) * 100, 2) as utilization\r\n        FROM public.credit_card_details cc\r\n        JOIN public.account a ON a.id = cc.account_id\r\n        WHERE a.current_balance::numeric / cc.credit_limit::numeric >= 0.9\r\n    LOOP\r\n        INSERT INTO public.notification (\r\n            user_id,\r\n            title,\r\n            message,\r\n            notification_type,\r\n            urgency_level,\r\n            related_entity_type,\r\n            related_entity_id\r\n        ) VALUES (\r\n            v_record.user_id,\r\n            'Límite de crédito cercano',\r\n            format('Tu tarjeta %s está al %s%% de su límite de crédito',\r\n                v_record.account_name,\r\n                v_record.utilization\r\n            ),\r\n            'CREDIT_CARD_LIMIT',\r\n            'HIGH',\r\n            'credit_card_details',\r\n            v_record.credit_card_id\r\n        );\r\n    END LOOP;\r\n\r\n    -- Notificar pagos mínimos pendientes\r\n    FOR v_record IN \r\n        SELECT \r\n            cs.id as statement_id,\r\n            cc.id as credit_card_id,\r\n            a.user_id,\r\n            a.name as account_name,\r\n            cs.minimum_payment,\r\n            cs.due_date\r\n        FROM public.credit_card_statement cs\r\n        JOIN public.credit_card_details cc ON cc.id = cs.credit_card_id\r\n        JOIN public.account a ON a.id = cc.account_id\r\n        WHERE cs.status = 'PENDING'\r\n        AND cs.due_date = CURRENT_DATE + interval '5 days'\r\n    LOOP\r\n        INSERT INTO public.notification (\r\n            user_id,\r\n            title,\r\n            message,\r\n            notification_type,\r\n            urgency_level,\r\n            related_entity_type,\r\n            related_entity_id\r\n        ) VALUES (\r\n            v_record.user_id,\r\n            'Pago mínimo pendiente',\r\n            format('Tu tarjeta %s requiere un pago mínimo de %s antes del %s',\r\n                v_record.account_name,\r\n                to_char(v_record.minimum_payment, 'FM999,999,999.00'),\r\n                to_char(v_record.due_date, 'DD/MM/YYYY')\r\n            ),\r\n            'CREDIT_CARD_MINIMUM_PAYMENT',\r\n            'HIGH',\r\n            'credit_card_statement',\r\n            v_record.statement_id\r\n        );\r\n    END LOOP;\r\nEND;\r\n$$","ALTER FUNCTION \\"public\\".\\"notify_credit_card_events\\"() OWNER TO \\"postgres\\"","CREATE OR REPLACE FUNCTION \\"public\\".\\"notify_transfer\\"() RETURNS \\"trigger\\"\n    LANGUAGE \\"plpgsql\\"\n    AS $$\r\nBEGIN\r\n    -- Insertar notificación\r\n    INSERT INTO public.notification (\r\n        user_id,\r\n        title,\r\n        message,\r\n        notification_type,\r\n        urgency_level,\r\n        related_entity_type,\r\n        related_entity_id\r\n    )\r\n    SELECT\r\n        NEW.user_id,\r\n        CASE NEW.transfer_type\r\n            WHEN 'ACCOUNT_TO_ACCOUNT' THEN 'Transferencia entre cuentas'\r\n            WHEN 'JAR_TO_JAR' THEN 'Transferencia entre jarras'\r\n            ELSE 'Rollover de período'\r\n        END,\r\n        CASE NEW.transfer_type\r\n            WHEN 'ACCOUNT_TO_ACCOUNT' THEN \r\n                format('Transferencia de %s realizada desde %s a %s',\r\n                    to_char(NEW.amount, 'FM999,999,999.00'),\r\n                    (SELECT name FROM public.account WHERE id = NEW.from_account_id),\r\n                    (SELECT name FROM public.account WHERE id = NEW.to_account_id)\r\n                )\r\n            ELSE\r\n                format('Transferencia de %s realizada desde %s a %s',\r\n                    to_char(NEW.amount, 'FM999,999,999.00'),\r\n                    (SELECT name FROM public.jar WHERE id = NEW.from_jar_id),\r\n                    (SELECT name FROM public.jar WHERE id = NEW.to_jar_id)\r\n                )\r\n        END,\r\n        'TRANSFER',\r\n        'LOW',\r\n        'transfer',\r\n        NEW.id;\r\n\r\n    RETURN NEW;\r\nEND;\r\n$$","ALTER FUNCTION \\"public\\".\\"notify_transfer\\"() OWNER TO \\"postgres\\"","CREATE OR REPLACE FUNCTION \\"public\\".\\"process_jar_rollover\\"(\\"p_user_id\\" \\"uuid\\") RETURNS TABLE(\\"jar_code\\" \\"text\\", \\"amount_rolled\\" numeric)\n    LANGUAGE \\"plpgsql\\"\n    AS $$\r\nDECLARE\r\n    v_jar record;\r\n    v_savings_jar_id uuid;\r\n    v_investment_jar_id uuid;\r\n    v_amount numeric(15,2);\r\n    v_transfer_id uuid;\r\nBEGIN\r\n    -- Obtener IDs de jarras de ahorro e inversión\r\n    SELECT id INTO v_savings_jar_id\r\n    FROM public.jar WHERE code = 'SAVINGS';\r\n\r\n    SELECT id INTO v_investment_jar_id\r\n    FROM public.jar WHERE code = 'INVESTMENT';\r\n\r\n    -- Procesar cada jarra excepto ahorro e inversión\r\n    FOR v_jar IN \r\n        SELECT j.*, jb.current_balance\r\n        FROM public.jar j\r\n        JOIN public.jar_balance jb ON jb.jar_id = j.id\r\n        WHERE j.code NOT IN ('SAVINGS', 'INVESTMENT')\r\n        AND jb.user_id = p_user_id\r\n        AND jb.current_balance > 0\r\n    LOOP\r\n        -- Calcular monto a transferir (50% a cada jarra)\r\n        v_amount := v_jar.current_balance / 2;\r\n\r\n        -- Transferir a ahorro\r\n        IF v_amount > 0 THEN\r\n            v_transfer_id := public.execute_jar_transfer(\r\n                p_user_id,\r\n                v_jar.id,\r\n                v_savings_jar_id,\r\n                v_amount,\r\n                'Rollover automático a ahorro',\r\n                true\r\n            );\r\n\r\n            jar_code := v_jar.code;\r\n            amount_rolled := v_amount;\r\n            RETURN NEXT;\r\n        END IF;\r\n\r\n        -- Transferir a inversión\r\n        IF v_amount > 0 THEN\r\n            v_transfer_id := public.execute_jar_transfer(\r\n                p_user_id,\r\n                v_jar.id,\r\n                v_investment_jar_id,\r\n                v_amount,\r\n                'Rollover automático a inversión',\r\n                true\r\n            );\r\n        END IF;\r\n    END LOOP;\r\nEND;\r\n$$","ALTER FUNCTION \\"public\\".\\"process_jar_rollover\\"(\\"p_user_id\\" \\"uuid\\") OWNER TO \\"postgres\\"","CREATE OR REPLACE FUNCTION \\"public\\".\\"process_recurring_transactions\\"(\\"p_date\\" \\"date\\" DEFAULT CURRENT_DATE) RETURNS \\"public\\".\\"recurring_process_result\\"\n    LANGUAGE \\"plpgsql\\"\n    AS $$\r\nDECLARE\r\n    v_result public.recurring_process_result;\r\n    v_record record;\r\n    v_valid boolean;\r\nBEGIN\r\n    -- Inicializar resultado\r\n    v_result.transactions_created := 0;\r\n    v_result.notifications_sent := 0;\r\n    v_result.errors_encountered := 0;\r\n\r\n    -- Procesar cada transacción recurrente activa\r\n    FOR v_record IN \r\n        SELECT r.*, u.notification_advance_days\r\n        FROM public.recurring_transaction r\r\n        JOIN public.app_user u ON u.id = r.user_id\r\n        WHERE r.is_active = true\r\n        AND r.next_execution_date <= p_date\r\n        AND (r.end_date IS NULL OR r.end_date >= p_date)\r\n    LOOP\r\n        -- Validar si la transacción puede ejecutarse\r\n        v_valid := public.validate_recurring_transaction(\r\n            v_record.user_id,\r\n            v_record.amount,\r\n            v_record.transaction_type_id,\r\n            v_record.account_id,\r\n            v_record.jar_id\r\n        );\r\n\r\n        IF v_valid THEN\r\n            BEGIN\r\n                -- Crear la transacción\r\n                INSERT INTO public.transaction (\r\n                    user_id,\r\n                    transaction_date,\r\n                    amount,\r\n                    transaction_type_id,\r\n                    category_id,\r\n                    subcategory_id,\r\n                    account_id,\r\n                    jar_id,\r\n                    transaction_medium_id,\r\n                    description,\r\n                    is_recurring,\r\n                    parent_recurring_id\r\n                ) VALUES (\r\n                    v_record.user_id,\r\n                    p_date,\r\n                    v_record.amount,\r\n                    v_record.transaction_type_id,\r\n                    v_record.category_id,\r\n                    v_record.subcategory_id,\r\n                    v_record.account_id,\r\n                    v_record.jar_id,\r\n                    v_record.transaction_medium_id,\r\n                    v_record.description || ' (Recurrente)',\r\n                    true,\r\n                    v_record.id\r\n                );\r\n\r\n                -- Actualizar fechas en plantilla\r\n                UPDATE public.recurring_transaction\r\n                SET \r\n                    last_execution_date = p_date,\r\n                    next_execution_date = public.calculate_next_execution_date(\r\n                        frequency,\r\n                        start_date,\r\n                        p_date\r\n                    ),\r\n                    modified_at = CURRENT_TIMESTAMP\r\n                WHERE id = v_record.id;\r\n\r\n                v_result.transactions_created := v_result.transactions_created + 1;\r\n\r\n            EXCEPTION WHEN OTHERS THEN\r\n                v_result.errors_encountered := v_result.errors_encountered + 1;\r\n                \r\n                -- Registrar error\r\n                INSERT INTO public.notification (\r\n                    user_id,\r\n                    title,\r\n                    message,\r\n                    notification_type,\r\n                    urgency_level,\r\n                    related_entity_type,\r\n                    related_entity_id\r\n                ) VALUES (\r\n                    v_record.user_id,\r\n                    'Error en transacción recurrente',\r\n                    'Error al procesar la transacción recurrente: ' || v_record.name || '. Error: ' || SQLERRM,\r\n                    'RECURRING_TRANSACTION',\r\n                    'HIGH',\r\n                    'recurring_transaction',\r\n                    v_record.id\r\n                );\r\n            END;\r\n        ELSE\r\n            -- Notificar saldo insuficiente\r\n            INSERT INTO public.notification (\r\n                user_id,\r\n                title,\r\n                message,\r\n                notification_type,\r\n                urgency_level,\r\n                related_entity_type,\r\n                related_entity_id\r\n            ) VALUES (\r\n                v_record.user_id,\r\n                'Saldo insuficiente para transacción recurrente',\r\n                'No hay saldo suficiente para procesar la transacción recurrente: ' || v_record.name,\r\n                'INSUFFICIENT_FUNDS',\r\n                'HIGH',\r\n                'recurring_transaction',\r\n                v_record.id\r\n            );\r\n\r\n            v_result.notifications_sent := v_result.notifications_sent + 1;\r\n        END IF;\r\n    END LOOP;\r\n\r\n    -- Generar notificaciones de próximas transacciones\r\n    INSERT INTO public.notification (\r\n        user_id,\r\n        title,\r\n        message,\r\n        notification_type,\r\n        urgency_level,\r\n        related_entity_type,\r\n        related_entity_id\r\n    )\r\n    SELECT \r\n        r.user_id,\r\n        'Próxima transacción recurrente',\r\n        'La transacción ' || r.name || ' está programada para el ' || \r\n        to_char(r.next_execution_date, 'DD/MM/YYYY'),\r\n        'RECURRING_TRANSACTION',\r\n        'MEDIUM',\r\n        'recurring_transaction',\r\n        r.id\r\n    FROM public.recurring_transaction r\r\n    JOIN public.app_user u ON u.id = r.user_id\r\n    WHERE r.is_active = true\r\n    AND r.next_execution_date = p_date + u.notification_advance_days\r\n    AND NOT EXISTS (\r\n        SELECT 1 FROM public.notification n\r\n        WHERE n.related_entity_id = r.id\r\n        AND n.notification_type = 'RECURRING_TRANSACTION'\r\n        AND n.created_at >= CURRENT_DATE\r\n    );\r\n\r\n    RETURN v_result;\r\nEND;\r\n$$","ALTER FUNCTION \\"public\\".\\"process_recurring_transactions\\"(\\"p_date\\" \\"date\\") OWNER TO \\"postgres\\"","CREATE OR REPLACE FUNCTION \\"public\\".\\"reactivate_recurring_transaction\\"(\\"p_transaction_id\\" \\"uuid\\", \\"p_new_start_date\\" \\"date\\" DEFAULT CURRENT_DATE) RETURNS \\"void\\"\n    LANGUAGE \\"plpgsql\\"\n    AS $$\r\nBEGIN\r\n    UPDATE public.recurring_transaction\r\n    SET \r\n        is_active = true,\r\n        start_date = p_new_start_date,\r\n        next_execution_date = p_new_start_date,\r\n        modified_at = CURRENT_TIMESTAMP\r\n    WHERE id = p_transaction_id;\r\n\r\n    -- Notificar reactivación\r\n    INSERT INTO public.notification (\r\n        user_id,\r\n        title,\r\n        message,\r\n        notification_type,\r\n        urgency_level,\r\n        related_entity_type,\r\n        related_entity_id\r\n    )\r\n    SELECT \r\n        user_id,\r\n        'Transacción recurrente reactivada',\r\n        'La transacción ' || name || ' ha sido reactivada y comenzará el ' || \r\n        to_char(p_new_start_date, 'DD/MM/YYYY'),\r\n        'RECURRING_TRANSACTION',\r\n        'MEDIUM',\r\n        'recurring_transaction',\r\n        id\r\n    FROM public.recurring_transaction\r\n    WHERE id = p_transaction_id;\r\nEND;\r\n$$","ALTER FUNCTION \\"public\\".\\"reactivate_recurring_transaction\\"(\\"p_transaction_id\\" \\"uuid\\", \\"p_new_start_date\\" \\"date\\") OWNER TO \\"postgres\\"","CREATE OR REPLACE FUNCTION \\"public\\".\\"record_balance_history\\"() RETURNS \\"trigger\\"\n    LANGUAGE \\"plpgsql\\"\n    AS $$\r\nBEGIN\r\n    IF TG_TABLE_NAME = 'transaction' THEN\r\n        -- Registrar cambio en cuenta\r\n        INSERT INTO public.balance_history (\r\n            user_id, \r\n            account_id,\r\n            old_balance,\r\n            new_balance,\r\n            change_amount,\r\n            change_type,\r\n            reference_type,\r\n            reference_id\r\n        )\r\n        VALUES (\r\n            NEW.user_id,\r\n            NEW.account_id,\r\n            (SELECT current_balance FROM public.account WHERE id = NEW.account_id),\r\n            (SELECT current_balance FROM public.account WHERE id = NEW.account_id) + \r\n                CASE \r\n                    WHEN EXISTS (\r\n                        SELECT 1 FROM public.transaction_type t \r\n                        WHERE t.id = NEW.transaction_type_id AND t.code = 'EXPENSE'\r\n                    ) THEN -NEW.amount\r\n                    ELSE NEW.amount\r\n                END,\r\n            NEW.amount,\r\n            'TRANSACTION',\r\n            'transaction',\r\n            NEW.id\r\n        );\r\n\r\n        -- Si es un gasto, registrar cambio en jarra\r\n        IF EXISTS (\r\n            SELECT 1 FROM public.transaction_type t \r\n            WHERE t.id = NEW.transaction_type_id AND t.code = 'EXPENSE'\r\n        ) THEN\r\n            INSERT INTO public.balance_history (\r\n                user_id,\r\n                jar_id,\r\n                old_balance,\r\n                new_balance,\r\n                change_amount,\r\n                change_type,\r\n                reference_type,\r\n                reference_id\r\n            )\r\n            VALUES (\r\n                NEW.user_id,\r\n                NEW.jar_id,\r\n                (SELECT current_balance FROM public.jar_balance WHERE jar_id = NEW.jar_id AND user_id = NEW.user_id),\r\n                (SELECT current_balance FROM public.jar_balance WHERE jar_id = NEW.jar_id AND user_id = NEW.user_id) - NEW.amount,\r\n                NEW.amount,\r\n                'TRANSACTION',\r\n                'transaction',\r\n                NEW.id\r\n            );\r\n        END IF;\r\n\r\n    ELSIF TG_TABLE_NAME = 'transfer' THEN\r\n        IF NEW.transfer_type = 'ACCOUNT_TO_ACCOUNT' THEN\r\n            -- Registrar cambio en cuenta origen\r\n            INSERT INTO public.balance_history (\r\n                user_id,\r\n                account_id,\r\n                old_balance,\r\n                new_balance,\r\n                change_amount,\r\n                change_type,\r\n                reference_type,\r\n                reference_id\r\n            )\r\n            VALUES (\r\n                NEW.user_id,\r\n                NEW.from_account_id,\r\n                (SELECT current_balance FROM public.account WHERE id = NEW.from_account_id),\r\n                (SELECT current_balance FROM public.account WHERE id = NEW.from_account_id) - NEW.amount,\r\n                NEW.amount,\r\n                'TRANSFER',\r\n                'transfer',\r\n                NEW.id\r\n            );\r\n\r\n            -- Registrar cambio en cuenta destino\r\n            INSERT INTO public.balance_history (\r\n                user_id,\r\n                account_id,\r\n                old_balance,\r\n                new_balance,\r\n                change_amount,\r\n                change_type,\r\n                reference_type,\r\n                reference_id\r\n            )\r\n            VALUES (\r\n                NEW.user_id,\r\n                NEW.to_account_id,\r\n                (SELECT current_balance FROM public.account WHERE id = NEW.to_account_id),\r\n                (SELECT current_balance FROM public.account WHERE id = NEW.to_account_id) + (NEW.amount * NEW.exchange_rate),\r\n                NEW.amount * NEW.exchange_rate,\r\n                'TRANSFER',\r\n                'transfer',\r\n                NEW.id\r\n            );\r\n\r\n        ELSE\r\n            -- Registrar cambio en jarra origen\r\n            INSERT INTO public.balance_history (\r\n                user_id,\r\n                jar_id,\r\n                old_balance,\r\n                new_balance,\r\n                change_amount,\r\n                change_type,\r\n                reference_type,\r\n                reference_id\r\n            )\r\n            VALUES (\r\n                NEW.user_id,\r\n                NEW.from_jar_id,\r\n                (SELECT current_balance FROM public.jar_balance WHERE jar_id = NEW.from_jar_id AND user_id = NEW.user_id),\r\n                (SELECT current_balance FROM public.jar_balance WHERE jar_id = NEW.from_jar_id AND user_id = NEW.user_id) - NEW.amount,\r\n                NEW.amount,\r\n                CASE NEW.transfer_type\r\n                    WHEN 'JAR_TO_JAR' THEN 'TRANSFER'\r\n                    ELSE 'ROLLOVER'\r\n                END,\r\n                'transfer',\r\n                NEW.id\r\n            );\r\n\r\n            -- Registrar cambio en jarra destino\r\n            INSERT INTO public.balance_history (\r\n                user_id,\r\n                jar_id,\r\n                old_balance,\r\n                new_balance,\r\n                change_amount,\r\n                change_type,\r\n                reference_type,\r\n                reference_id\r\n            )\r\n            VALUES (\r\n                NEW.user_id,\r\n                NEW.to_jar_id,\r\n                (SELECT current_balance FROM public.jar_balance WHERE jar_id = NEW.to_jar_id AND user_id = NEW.user_id),\r\n                (SELECT current_balance FROM public.jar_balance WHERE jar_id = NEW.to_jar_id AND user_id = NEW.user_id) + NEW.amount,\r\n                NEW.amount,\r\n                CASE NEW.transfer_type\r\n                    WHEN 'JAR_TO_JAR' THEN 'TRANSFER'\r\n                    ELSE 'ROLLOVER'\r\n                END,\r\n                'transfer',\r\n                NEW.id\r\n            );\r\n        END IF;\r\n    END IF;\r\n\r\n    RETURN NEW;\r\nEND;\r\n$$","ALTER FUNCTION \\"public\\".\\"record_balance_history\\"() OWNER TO \\"postgres\\"","CREATE OR REPLACE FUNCTION \\"public\\".\\"remove_transaction_tag\\"(\\"p_transaction_id\\" \\"uuid\\", \\"p_tag\\" \\"text\\") RETURNS \\"void\\"\n    LANGUAGE \\"plpgsql\\"\n    AS $$\nBEGIN\n    UPDATE public.transaction\n    SET tags = (\n        SELECT jsonb_agg(value)\n        FROM jsonb_array_elements(tags) AS t(value)\n        WHERE value::text != p_tag::text\n    )\n    WHERE id = p_transaction_id;\nEND;\n$$","ALTER FUNCTION \\"public\\".\\"remove_transaction_tag\\"(\\"p_transaction_id\\" \\"uuid\\", \\"p_tag\\" \\"text\\") OWNER TO \\"postgres\\"","CREATE OR REPLACE FUNCTION \\"public\\".\\"search_transactions_by_notes\\"(\\"p_user_id\\" \\"uuid\\", \\"p_search_text\\" \\"text\\") RETURNS TABLE(\\"id\\" \\"uuid\\", \\"transaction_date\\" \\"date\\", \\"description\\" \\"text\\", \\"amount\\" numeric, \\"tags\\" \\"jsonb\\", \\"notes\\" \\"text\\")\n    LANGUAGE \\"plpgsql\\"\n    AS $$\nBEGIN\n    RETURN QUERY\n    SELECT \n        t.id,\n        t.transaction_date,\n        t.description,\n        t.amount,\n        t.tags,\n        t.notes\n    FROM public.transaction t\n    WHERE t.user_id = p_user_id\n    AND to_tsvector('spanish', COALESCE(t.notes, '')) @@ to_tsquery('spanish', p_search_text)\n    ORDER BY t.transaction_date DESC;\nEND;\n$$","ALTER FUNCTION \\"public\\".\\"search_transactions_by_notes\\"(\\"p_user_id\\" \\"uuid\\", \\"p_search_text\\" \\"text\\") OWNER TO \\"postgres\\"","CREATE OR REPLACE FUNCTION \\"public\\".\\"search_transactions_by_tags\\"(\\"p_user_id\\" \\"uuid\\", \\"p_tags\\" \\"text\\"[]) RETURNS TABLE(\\"id\\" \\"uuid\\", \\"transaction_date\\" \\"date\\", \\"description\\" \\"text\\", \\"amount\\" numeric, \\"tags\\" \\"jsonb\\", \\"notes\\" \\"text\\")\n    LANGUAGE \\"plpgsql\\"\n    AS $$\nBEGIN\n    RETURN QUERY\n    SELECT \n        t.id,\n        t.transaction_date,\n        t.description,\n        t.amount,\n        t.tags,\n        t.notes\n    FROM public.transaction t\n    WHERE t.user_id = p_user_id\n    AND t.tags @> jsonb_array_to_jsonb(p_tags::jsonb[])\n    ORDER BY t.transaction_date DESC;\nEND;\n$$","ALTER FUNCTION \\"public\\".\\"search_transactions_by_tags\\"(\\"p_user_id\\" \\"uuid\\", \\"p_tags\\" \\"text\\"[]) OWNER TO \\"postgres\\"","CREATE OR REPLACE FUNCTION \\"public\\".\\"track_interest_rate_changes\\"() RETURNS \\"trigger\\"\n    LANGUAGE \\"plpgsql\\"\n    AS $$\r\nBEGIN\r\n    IF OLD.current_interest_rate != NEW.current_interest_rate THEN\r\n        INSERT INTO public.credit_card_interest_history (\r\n            credit_card_id,\r\n            old_rate,\r\n            new_rate,\r\n            reason\r\n        ) VALUES (\r\n            NEW.id,\r\n            OLD.current_interest_rate,\r\n            NEW.current_interest_rate,\r\n            'Actualización manual de tasa'\r\n        );\r\n    END IF;\r\n    RETURN NEW;\r\nEND;\r\n$$","ALTER FUNCTION \\"public\\".\\"track_interest_rate_changes\\"() OWNER TO \\"postgres\\"","CREATE OR REPLACE FUNCTION \\"public\\".\\"update_balances\\"() RETURNS \\"trigger\\"\n    LANGUAGE \\"plpgsql\\"\n    AS $$\r\nDECLARE\r\n    v_transaction_type_code text;\r\n    v_old_balance numeric(15,2);\r\n    v_new_balance numeric(15,2);\r\n    v_jar_record record;\r\nBEGIN\r\n    -- Para transacciones\r\n    IF TG_TABLE_NAME = 'transaction' THEN\r\n        SELECT code INTO v_transaction_type_code\r\n        FROM public.transaction_type\r\n        WHERE id = NEW.transaction_type_id;\r\n\r\n        IF v_transaction_type_code = 'EXPENSE' THEN\r\n            -- Actualizar balance de jarra\r\n            UPDATE public.jar_balance\r\n            SET current_balance = current_balance - NEW.amount\r\n            WHERE jar_id = NEW.jar_id AND user_id = NEW.user_id\r\n            RETURNING current_balance INTO v_new_balance;\r\n\r\n            -- Actualizar balance de cuenta\r\n            UPDATE public.account\r\n            SET current_balance = current_balance - NEW.amount\r\n            WHERE id = NEW.account_id AND user_id = NEW.user_id;\r\n\r\n        ELSIF v_transaction_type_code = 'INCOME' THEN\r\n            -- Actualizar balance de cuenta\r\n            UPDATE public.account\r\n            SET current_balance = current_balance + NEW.amount\r\n            WHERE id = NEW.account_id AND user_id = NEW.user_id;\r\n\r\n            -- Distribuir en jarras según porcentajes\r\n            FOR v_jar_record IN \r\n                SELECT j.id, j.target_percentage \r\n                FROM public.jar j\r\n                WHERE j.is_active = true\r\n            LOOP\r\n                INSERT INTO public.jar_balance (user_id, jar_id, current_balance)\r\n                VALUES (NEW.user_id, v_jar_record.id, \r\n                    NEW.amount * (v_jar_record.target_percentage / 100))\r\n                ON CONFLICT (user_id, jar_id) DO UPDATE\r\n                SET current_balance = jar_balance.current_balance + \r\n                    NEW.amount * (v_jar_record.target_percentage / 100);\r\n            END LOOP;\r\n        END IF;\r\n\r\n    -- Para transferencias\r\n    ELSIF TG_TABLE_NAME = 'transfer' THEN\r\n        IF NEW.transfer_type = 'ACCOUNT_TO_ACCOUNT' THEN\r\n            -- Actualizar cuenta origen\r\n            UPDATE public.account\r\n            SET current_balance = current_balance - NEW.amount\r\n            WHERE id = NEW.from_account_id AND user_id = NEW.user_id;\r\n\r\n            -- Actualizar cuenta destino\r\n            UPDATE public.account\r\n            SET current_balance = current_balance + (NEW.amount * NEW.exchange_rate)\r\n            WHERE id = NEW.to_account_id AND user_id = NEW.user_id;\r\n\r\n        ELSIF NEW.transfer_type IN ('JAR_TO_JAR', 'PERIOD_ROLLOVER') THEN\r\n            -- Actualizar jarra origen\r\n            UPDATE public.jar_balance\r\n            SET current_balance = current_balance - NEW.amount\r\n            WHERE jar_id = NEW.from_jar_id AND user_id = NEW.user_id;\r\n\r\n            -- Actualizar jarra destino\r\n            UPDATE public.jar_balance\r\n            SET current_balance = current_balance + NEW.amount\r\n            WHERE jar_id = NEW.to_jar_id AND user_id = NEW.user_id;\r\n        END IF;\r\n    END IF;\r\n\r\n    RETURN NEW;\r\nEND;\r\n$$","ALTER FUNCTION \\"public\\".\\"update_balances\\"() OWNER TO \\"postgres\\"","CREATE OR REPLACE FUNCTION \\"public\\".\\"update_goal_from_transaction\\"() RETURNS \\"trigger\\"\n    LANGUAGE \\"plpgsql\\"\n    AS $$\r\nDECLARE\r\n    v_jar_id uuid;\r\nBEGIN\r\n    -- Solo procesar transacciones completadas\r\n    IF NEW.status != 'COMPLETED' THEN\r\n        RETURN NEW;\r\n    END IF;\r\n\r\n    -- Obtener jarra asociada si es un gasto\r\n    IF EXISTS (\r\n        SELECT 1 FROM public.transaction_type t \r\n        WHERE t.id = NEW.transaction_type_id \r\n        AND t.code = 'EXPENSE'\r\n    ) THEN\r\n        v_jar_id := NEW.jar_id;\r\n    ELSE\r\n        -- Para ingresos, obtener jarra de inversión o ahorro según subcategoría\r\n        SELECT jar_id INTO v_jar_id\r\n        FROM public.subcategory\r\n        WHERE id = NEW.subcategory_id;\r\n    END IF;\r\n\r\n    -- Actualizar metas asociadas a la jarra\r\n    IF v_jar_id IS NOT NULL THEN\r\n        UPDATE public.financial_goal g\r\n        SET current_amount = current_amount + \r\n            CASE \r\n                WHEN EXISTS (\r\n                    SELECT 1 FROM public.transaction_type t \r\n                    WHERE t.id = NEW.transaction_type_id \r\n                    AND t.code = 'EXPENSE'\r\n                ) THEN -NEW.amount\r\n                ELSE NEW.amount\r\n            END\r\n        WHERE g.jar_id = v_jar_id\r\n        AND g.user_id = NEW.user_id\r\n        AND g.status = 'IN_PROGRESS';\r\n    END IF;\r\n\r\n    RETURN NEW;\r\nEND;\r\n$$","ALTER FUNCTION \\"public\\".\\"update_goal_from_transaction\\"() OWNER TO \\"postgres\\"","CREATE OR REPLACE FUNCTION \\"public\\".\\"update_goal_progress\\"(\\"p_goal_id\\" \\"uuid\\", \\"p_new_amount\\" numeric) RETURNS \\"public\\".\\"goal_progress_status\\"\n    LANGUAGE \\"plpgsql\\"\n    AS $$\r\nDECLARE\r\n    v_goal record;\r\n    v_old_amount numeric(15,2);\r\n    v_progress public.goal_progress_status;\r\nBEGIN\r\n    -- Obtener información de la meta\r\n    SELECT * INTO v_goal\r\n    FROM public.financial_goal\r\n    WHERE id = p_goal_id;\r\n\r\n    IF NOT FOUND THEN\r\n        RAISE EXCEPTION 'Meta financiera no encontrada';\r\n    END IF;\r\n\r\n    -- Guardar monto anterior\r\n    v_old_amount := v_goal.current_amount;\r\n\r\n    -- Actualizar monto actual\r\n    UPDATE public.financial_goal\r\n    SET \r\n        current_amount = p_new_amount,\r\n        modified_at = CURRENT_TIMESTAMP,\r\n        status = CASE \r\n            WHEN p_new_amount >= target_amount THEN 'COMPLETED'\r\n            ELSE status\r\n        END\r\n    WHERE id = p_goal_id\r\n    RETURNING current_amount INTO v_goal.current_amount;\r\n\r\n    -- Calcular nuevo progreso\r\n    v_progress := public.calculate_goal_progress(\r\n        v_goal.current_amount,\r\n        v_goal.target_amount,\r\n        v_goal.start_date,\r\n        v_goal.target_date\r\n    );\r\n\r\n    -- Generar notificación si se completa la meta\r\n    IF v_goal.current_amount >= v_goal.target_amount AND v_old_amount < v_goal.target_amount THEN\r\n        INSERT INTO public.notification (\r\n            user_id,\r\n            title,\r\n            message,\r\n            notification_type,\r\n            urgency_level,\r\n            related_entity_type,\r\n            related_entity_id\r\n        ) VALUES (\r\n            v_goal.user_id,\r\n            '¡Meta financiera alcanzada!',\r\n            format('Has alcanzado tu meta \\"%s\\" de %s', \r\n                v_goal.name, \r\n                to_char(v_goal.target_amount, 'FM999,999,999.00')\r\n            ),\r\n            'GOAL_PROGRESS',\r\n            'MEDIUM',\r\n            'financial_goal',\r\n            v_goal.id\r\n        );\r\n    END IF;\r\n\r\n    -- Generar notificación si se está desviando del objetivo\r\n    IF NOT v_progress.is_on_track AND v_goal.status = 'IN_PROGRESS' THEN\r\n        INSERT INTO public.notification (\r\n            user_id,\r\n            title,\r\n            message,\r\n            notification_type,\r\n            urgency_level,\r\n            related_entity_type,\r\n            related_entity_id\r\n        ) VALUES (\r\n            v_goal.user_id,\r\n            'Alerta de progreso de meta',\r\n            format(\r\n                'Tu meta \\"%s\\" está retrasada. Necesitas ahorrar %s diarios para alcanzarla.',\r\n                v_goal.name,\r\n                to_char(v_progress.required_daily_amount, 'FM999,999,999.00')\r\n            ),\r\n            'GOAL_PROGRESS',\r\n            'HIGH',\r\n            'financial_goal',\r\n            v_goal.id\r\n        );\r\n    END IF;\r\n\r\n    RETURN v_progress;\r\nEND;\r\n$$","ALTER FUNCTION \\"public\\".\\"update_goal_progress\\"(\\"p_goal_id\\" \\"uuid\\", \\"p_new_amount\\" numeric) OWNER TO \\"postgres\\"","CREATE OR REPLACE FUNCTION \\"public\\".\\"update_installment_purchases\\"() RETURNS \\"void\\"\n    LANGUAGE \\"plpgsql\\"\n    AS $$\r\nDECLARE\r\n    v_record record;\r\nBEGIN\r\n    FOR v_record IN \r\n        SELECT ip.*\r\n        FROM public.installment_purchase ip\r\n        WHERE ip.status = 'ACTIVE'\r\n        AND ip.next_installment_date <= CURRENT_DATE\r\n    LOOP\r\n        -- Registrar cargo de mensualidad\r\n        INSERT INTO public.transaction (\r\n            user_id,\r\n            transaction_date,\r\n            description,\r\n            amount,\r\n            transaction_type_id,\r\n            category_id,\r\n            subcategory_id,\r\n            account_id,\r\n            installment_purchase_id\r\n        )\r\n        SELECT \r\n            t.user_id,\r\n            CURRENT_DATE,\r\n            'Mensualidad MSI: ' || t.description,\r\n            v_record.installment_amount,\r\n            t.transaction_type_id,\r\n            t.category_id,\r\n            t.subcategory_id,\r\n            t.account_id,\r\n            v_record.id\r\n        FROM public.transaction t\r\n        WHERE t.id = v_record.transaction_id;\r\n\r\n        -- Actualizar registro de MSI\r\n        UPDATE public.installment_purchase\r\n        SET \r\n            remaining_installments = remaining_installments - 1,\r\n            next_installment_date = next_installment_date + interval '1 month',\r\n            status = CASE \r\n                WHEN remaining_installments - 1 = 0 THEN 'COMPLETED'\r\n                ELSE 'ACTIVE'\r\n            END,\r\n            modified_at = CURRENT_TIMESTAMP\r\n        WHERE id = v_record.id;\r\n    END LOOP;\r\nEND;\r\n$$","ALTER FUNCTION \\"public\\".\\"update_installment_purchases\\"() OWNER TO \\"postgres\\"","CREATE OR REPLACE FUNCTION \\"public\\".\\"update_modified_timestamp\\"() RETURNS \\"trigger\\"\n    LANGUAGE \\"plpgsql\\"\n    AS $$\r\nBEGIN\r\n    NEW.modified_at = CURRENT_TIMESTAMP;\r\n    RETURN NEW;\r\nEND;\r\n$$","ALTER FUNCTION \\"public\\".\\"update_modified_timestamp\\"() OWNER TO \\"postgres\\"","CREATE OR REPLACE FUNCTION \\"public\\".\\"validate_account_transfer\\"(\\"p_user_id\\" \\"uuid\\", \\"p_from_account_id\\" \\"uuid\\", \\"p_to_account_id\\" \\"uuid\\", \\"p_amount\\" numeric, \\"p_exchange_rate\\" numeric DEFAULT 1) RETURNS \\"public\\".\\"transfer_validation_result\\"\n    LANGUAGE \\"plpgsql\\"\n    AS $$\r\nDECLARE\r\n    v_result public.transfer_validation_result;\r\n    v_from_currency varchar(3);\r\n    v_to_currency varchar(3);\r\nBEGIN\r\n    -- Inicializar resultado\r\n    v_result.is_valid := false;\r\n    \r\n    -- Verificar que las cuentas son diferentes\r\n    IF p_from_account_id = p_to_account_id THEN\r\n        v_result.error_message := 'No se puede transferir a la misma cuenta';\r\n        RETURN v_result;\r\n    END IF;\r\n\r\n    -- Obtener monedas y balances de las cuentas\r\n    SELECT \r\n        a.current_balance,\r\n        c.code INTO v_result.source_balance, v_from_currency\r\n    FROM public.account a\r\n    JOIN public.currency c ON c.id = a.currency_id\r\n    WHERE a.id = p_from_account_id AND a.user_id = p_user_id;\r\n\r\n    SELECT \r\n        a.current_balance,\r\n        c.code INTO v_result.target_balance, v_to_currency\r\n    FROM public.account a\r\n    JOIN public.currency c ON c.id = a.currency_id\r\n    WHERE a.id = p_to_account_id AND a.user_id = p_user_id;\r\n\r\n    -- Validar que existen las cuentas\r\n    IF v_result.source_balance IS NULL OR v_result.target_balance IS NULL THEN\r\n        v_result.error_message := 'Cuenta no encontrada o sin acceso';\r\n        RETURN v_result;\r\n    END IF;\r\n\r\n    -- Validar saldo suficiente\r\n    IF v_result.source_balance < p_amount THEN\r\n        v_result.error_message := format(\r\n            'Saldo insuficiente. Disponible: %s %s, Requerido: %s %s',\r\n            v_from_currency, v_result.source_balance, v_from_currency, p_amount\r\n        );\r\n        RETURN v_result;\r\n    END IF;\r\n\r\n    -- Validar tipo de cambio si las monedas son diferentes\r\n    IF v_from_currency != v_to_currency AND p_exchange_rate <= 0 THEN\r\n        v_result.error_message := 'Tipo de cambio inválido para transferencia entre diferentes monedas';\r\n        RETURN v_result;\r\n    END IF;\r\n\r\n    -- Si todo está bien\r\n    v_result.is_valid := true;\r\n    RETURN v_result;\r\nEND;\r\n$$","ALTER FUNCTION \\"public\\".\\"validate_account_transfer\\"(\\"p_user_id\\" \\"uuid\\", \\"p_from_account_id\\" \\"uuid\\", \\"p_to_account_id\\" \\"uuid\\", \\"p_amount\\" numeric, \\"p_exchange_rate\\" numeric) OWNER TO \\"postgres\\"","CREATE OR REPLACE FUNCTION \\"public\\".\\"validate_credit_card_transaction\\"() RETURNS \\"trigger\\"\n    LANGUAGE \\"plpgsql\\"\n    AS $$\r\nDECLARE\r\n    v_account_type text;\r\n    v_transaction_type text;\r\n    v_available_credit numeric;\r\nBEGIN\r\n    -- Obtener tipo de cuenta\r\n    SELECT at.code INTO v_account_type\r\n    FROM public.account a\r\n    JOIN public.account_type at ON at.id = a.account_type_id\r\n    WHERE a.id = NEW.account_id;\r\n\r\n    -- Si no es tarjeta de crédito, permitir la transacción\r\n    IF v_account_type != 'CREDIT_CARD' THEN\r\n        RETURN NEW;\r\n    END IF;\r\n\r\n    -- Obtener tipo de transacción\r\n    SELECT code INTO v_transaction_type\r\n    FROM public.transaction_type\r\n    WHERE id = NEW.transaction_type_id;\r\n\r\n    -- Para gastos, validar límite de crédito\r\n    IF v_transaction_type = 'EXPENSE' THEN\r\n        IF NOT public.validate_credit_limit(NEW.account_id, NEW.amount) THEN\r\n            RAISE EXCEPTION 'La transacción excede el límite de crédito disponible';\r\n        END IF;\r\n    END IF;\r\n\r\n    RETURN NEW;\r\nEND;\r\n$$","ALTER FUNCTION \\"public\\".\\"validate_credit_card_transaction\\"() OWNER TO \\"postgres\\"","CREATE OR REPLACE FUNCTION \\"public\\".\\"validate_credit_limit\\"(\\"p_account_id\\" \\"uuid\\", \\"p_amount\\" numeric) RETURNS boolean\n    LANGUAGE \\"plpgsql\\"\n    AS $$\r\nDECLARE\r\n    v_current_balance numeric;\r\n    v_credit_limit numeric;\r\nBEGIN\r\n    -- Obtener balance actual y límite de crédito\r\n    SELECT \r\n        a.current_balance,\r\n        cc.credit_limit INTO v_current_balance, v_credit_limit\r\n    FROM public.account a\r\n    JOIN public.credit_card_details cc ON cc.account_id = a.id\r\n    WHERE a.id = p_account_id;\r\n    \r\n    -- Validar si hay suficiente crédito disponible\r\n    RETURN (v_credit_limit + v_current_balance) >= p_amount;\r\nEND;\r\n$$","ALTER FUNCTION \\"public\\".\\"validate_credit_limit\\"(\\"p_account_id\\" \\"uuid\\", \\"p_amount\\" numeric) OWNER TO \\"postgres\\"","CREATE OR REPLACE FUNCTION \\"public\\".\\"validate_jar_transfer\\"(\\"p_user_id\\" \\"uuid\\", \\"p_from_jar_id\\" \\"uuid\\", \\"p_to_jar_id\\" \\"uuid\\", \\"p_amount\\" numeric) RETURNS \\"public\\".\\"transfer_validation_result\\"\n    LANGUAGE \\"plpgsql\\"\n    AS $$\r\nDECLARE\r\n    v_result public.transfer_validation_result;\r\nBEGIN\r\n    -- Inicializar resultado\r\n    v_result.is_valid := false;\r\n    \r\n    -- Verificar que las jarras son diferentes\r\n    IF p_from_jar_id = p_to_jar_id THEN\r\n        v_result.error_message := 'No se puede transferir a la misma jarra';\r\n        RETURN v_result;\r\n    END IF;\r\n\r\n    -- Obtener balances de las jarras\r\n    SELECT current_balance INTO v_result.source_balance\r\n    FROM public.jar_balance\r\n    WHERE jar_id = p_from_jar_id AND user_id = p_user_id;\r\n\r\n    SELECT current_balance INTO v_result.target_balance\r\n    FROM public.jar_balance\r\n    WHERE jar_id = p_to_jar_id AND user_id = p_user_id;\r\n\r\n    -- Validar que existen las jarras\r\n    IF v_result.source_balance IS NULL OR v_result.target_balance IS NULL THEN\r\n        v_result.error_message := 'Jarra no encontrada o sin acceso';\r\n        RETURN v_result;\r\n    END IF;\r\n\r\n    -- Validar saldo suficiente\r\n    IF v_result.source_balance < p_amount THEN\r\n        v_result.error_message := format(\r\n            'Saldo insuficiente en jarra. Disponible: %s, Requerido: %s',\r\n            v_result.source_balance, p_amount\r\n        );\r\n        RETURN v_result;\r\n    END IF;\r\n\r\n    -- Si todo está bien\r\n    v_result.is_valid := true;\r\n    RETURN v_result;\r\nEND;\r\n$$","ALTER FUNCTION \\"public\\".\\"validate_jar_transfer\\"(\\"p_user_id\\" \\"uuid\\", \\"p_from_jar_id\\" \\"uuid\\", \\"p_to_jar_id\\" \\"uuid\\", \\"p_amount\\" numeric) OWNER TO \\"postgres\\"","CREATE OR REPLACE FUNCTION \\"public\\".\\"validate_recurring_transaction\\"(\\"p_user_id\\" \\"uuid\\", \\"p_amount\\" numeric, \\"p_transaction_type_id\\" \\"uuid\\", \\"p_account_id\\" \\"uuid\\", \\"p_jar_id\\" \\"uuid\\" DEFAULT NULL::\\"uuid\\") RETURNS boolean\n    LANGUAGE \\"plpgsql\\"\n    AS $$\r\nDECLARE\r\n    v_transaction_type_code text;\r\n    v_current_balance numeric;\r\nBEGIN\r\n    -- Obtener tipo de transacción\r\n    SELECT code INTO v_transaction_type_code\r\n    FROM public.transaction_type\r\n    WHERE id = p_transaction_type_id;\r\n\r\n    -- Para gastos, validar saldo disponible\r\n    IF v_transaction_type_code = 'EXPENSE' THEN\r\n        -- Validar saldo en jarra si aplica\r\n        IF p_jar_id IS NOT NULL THEN\r\n            SELECT current_balance INTO v_current_balance\r\n            FROM public.jar_balance\r\n            WHERE user_id = p_user_id AND jar_id = p_jar_id;\r\n\r\n            IF v_current_balance < p_amount THEN\r\n                RETURN false;\r\n            END IF;\r\n        END IF;\r\n\r\n        -- Validar saldo en cuenta\r\n        SELECT current_balance INTO v_current_balance\r\n        FROM public.account\r\n        WHERE id = p_account_id AND user_id = p_user_id;\r\n\r\n        IF v_current_balance < p_amount THEN\r\n            RETURN false;\r\n        END IF;\r\n    END IF;\r\n\r\n    RETURN true;\r\nEND;\r\n$$","ALTER FUNCTION \\"public\\".\\"validate_recurring_transaction\\"(\\"p_user_id\\" \\"uuid\\", \\"p_amount\\" numeric, \\"p_transaction_type_id\\" \\"uuid\\", \\"p_account_id\\" \\"uuid\\", \\"p_jar_id\\" \\"uuid\\") OWNER TO \\"postgres\\"","CREATE OR REPLACE FUNCTION \\"public\\".\\"validate_sufficient_balance\\"() RETURNS \\"trigger\\"\n    LANGUAGE \\"plpgsql\\"\n    AS $$\r\nDECLARE\r\n    v_current_balance numeric(15,2);\r\n    v_entity_type text;\r\n    v_transaction_type_code text;\r\nBEGIN\r\n    -- Para transacciones, verificar si es gasto\r\n    IF TG_TABLE_NAME = 'transaction' THEN\r\n        SELECT code INTO v_transaction_type_code\r\n        FROM public.transaction_type\r\n        WHERE id = NEW.transaction_type_id;\r\n\r\n        -- Solo validar balance para gastos\r\n        IF v_transaction_type_code = 'EXPENSE' THEN\r\n            IF NEW.jar_id IS NOT NULL THEN\r\n                SELECT current_balance INTO v_current_balance\r\n                FROM public.jar_balance\r\n                WHERE jar_id = NEW.jar_id AND user_id = NEW.user_id;\r\n                v_entity_type := 'jar';\r\n            ELSE\r\n                SELECT current_balance INTO v_current_balance\r\n                FROM public.account\r\n                WHERE id = NEW.account_id AND user_id = NEW.user_id;\r\n                v_entity_type := 'account';\r\n            END IF;\r\n\r\n            -- Validar balance suficiente\r\n            IF v_current_balance < NEW.amount THEN\r\n                RAISE EXCEPTION 'Saldo insuficiente en % (Disponible: %, Requerido: %)',\r\n                    v_entity_type, v_current_balance, NEW.amount;\r\n            END IF;\r\n        END IF;\r\n    \r\n    -- Para transferencias\r\n    ELSIF TG_TABLE_NAME = 'transfer' THEN\r\n        IF NEW.transfer_type = 'ACCOUNT_TO_ACCOUNT' THEN\r\n            SELECT current_balance INTO v_current_balance\r\n            FROM public.account\r\n            WHERE id = NEW.from_account_id AND user_id = NEW.user_id;\r\n            v_entity_type := 'account';\r\n        ELSE\r\n            SELECT current_balance INTO v_current_balance\r\n            FROM public.jar_balance\r\n            WHERE jar_id = NEW.from_jar_id AND user_id = NEW.user_id;\r\n            v_entity_type := 'jar';\r\n        END IF;\r\n\r\n        -- Validar balance suficiente\r\n        IF v_current_balance < NEW.amount THEN\r\n            RAISE EXCEPTION 'Saldo insuficiente en % (Disponible: %, Requerido: %)',\r\n                v_entity_type, v_current_balance, NEW.amount;\r\n        END IF;\r\n    END IF;\r\n\r\n    RETURN NEW;\r\nEND;\r\n$$","ALTER FUNCTION \\"public\\".\\"validate_sufficient_balance\\"() OWNER TO \\"postgres\\"","SET default_tablespace = ''","SET default_table_access_method = \\"heap\\"","CREATE TABLE IF NOT EXISTS \\"public\\".\\"account\\" (\n    \\"id\\" \\"uuid\\" DEFAULT \\"gen_random_uuid\\"() NOT NULL,\n    \\"user_id\\" \\"uuid\\" NOT NULL,\n    \\"account_type_id\\" \\"uuid\\" NOT NULL,\n    \\"name\\" \\"text\\" NOT NULL,\n    \\"description\\" \\"text\\",\n    \\"currency_id\\" \\"uuid\\" NOT NULL,\n    \\"current_balance\\" numeric(15,2) DEFAULT 0 NOT NULL,\n    \\"is_active\\" boolean DEFAULT true NOT NULL,\n    \\"created_at\\" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,\n    \\"modified_at\\" timestamp with time zone\n)","ALTER TABLE \\"public\\".\\"account\\" OWNER TO \\"postgres\\"","COMMENT ON TABLE \\"public\\".\\"account\\" IS 'Cuentas financieras de los usuarios'","CREATE TABLE IF NOT EXISTS \\"public\\".\\"account_type\\" (\n    \\"id\\" \\"uuid\\" DEFAULT \\"gen_random_uuid\\"() NOT NULL,\n    \\"name\\" \\"text\\" NOT NULL,\n    \\"description\\" \\"text\\",\n    \\"is_active\\" boolean DEFAULT true NOT NULL,\n    \\"created_at\\" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,\n    \\"modified_at\\" timestamp with time zone\n)","ALTER TABLE \\"public\\".\\"account_type\\" OWNER TO \\"postgres\\"","COMMENT ON TABLE \\"public\\".\\"account_type\\" IS 'Tipos de cuenta soportados'","CREATE TABLE IF NOT EXISTS \\"public\\".\\"app_user\\" (\n    \\"id\\" \\"uuid\\" NOT NULL,\n    \\"email\\" \\"text\\" NOT NULL,\n    \\"first_name\\" \\"text\\",\n    \\"last_name\\" \\"text\\",\n    \\"default_currency_id\\" \\"uuid\\" NOT NULL,\n    \\"notifications_enabled\\" boolean DEFAULT true,\n    \\"notification_advance_days\\" integer DEFAULT 1,\n    \\"is_active\\" boolean DEFAULT true NOT NULL,\n    \\"created_at\\" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,\n    \\"modified_at\\" timestamp with time zone,\n    CONSTRAINT \\"valid_notification_days\\" CHECK ((\\"notification_advance_days\\" > 0))\n)","ALTER TABLE \\"public\\".\\"app_user\\" OWNER TO \\"postgres\\"","COMMENT ON TABLE \\"public\\".\\"app_user\\" IS 'Información extendida de usuarios'","COMMENT ON COLUMN \\"public\\".\\"app_user\\".\\"notification_advance_days\\" IS 'Días de anticipación para notificaciones recurrentes'","CREATE TABLE IF NOT EXISTS \\"public\\".\\"balance_history\\" (\n    \\"id\\" \\"uuid\\" DEFAULT \\"gen_random_uuid\\"() NOT NULL,\n    \\"user_id\\" \\"uuid\\" NOT NULL,\n    \\"account_id\\" \\"uuid\\",\n    \\"jar_id\\" \\"uuid\\",\n    \\"old_balance\\" numeric(15,2) NOT NULL,\n    \\"new_balance\\" numeric(15,2) NOT NULL,\n    \\"change_amount\\" numeric(15,2) NOT NULL,\n    \\"change_type\\" character varying(50) NOT NULL,\n    \\"reference_type\\" character varying(50) NOT NULL,\n    \\"reference_id\\" \\"uuid\\" NOT NULL,\n    \\"created_at\\" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,\n    CONSTRAINT \\"balance_history_change_type_check\\" CHECK (((\\"change_type\\")::\\"text\\" = ANY ((ARRAY['TRANSACTION'::character varying, 'TRANSFER'::character varying, 'ADJUSTMENT'::character varying, 'ROLLOVER'::character varying])::\\"text\\"[]))),\n    CONSTRAINT \\"valid_target\\" CHECK ((((\\"account_id\\" IS NOT NULL) AND (\\"jar_id\\" IS NULL)) OR ((\\"account_id\\" IS NULL) AND (\\"jar_id\\" IS NOT NULL))))\n)","ALTER TABLE \\"public\\".\\"balance_history\\" OWNER TO \\"postgres\\"","COMMENT ON TABLE \\"public\\".\\"balance_history\\" IS 'Historial de cambios en balances'","CREATE TABLE IF NOT EXISTS \\"public\\".\\"category\\" (\n    \\"id\\" \\"uuid\\" DEFAULT \\"gen_random_uuid\\"() NOT NULL,\n    \\"name\\" \\"text\\" NOT NULL,\n    \\"description\\" \\"text\\",\n    \\"transaction_type_id\\" \\"uuid\\" NOT NULL,\n    \\"is_active\\" boolean DEFAULT true NOT NULL,\n    \\"created_at\\" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,\n    \\"modified_at\\" timestamp with time zone\n)","ALTER TABLE \\"public\\".\\"category\\" OWNER TO \\"postgres\\"","COMMENT ON TABLE \\"public\\".\\"category\\" IS 'Categorías para clasificación de transacciones'","CREATE TABLE IF NOT EXISTS \\"public\\".\\"credit_card_details\\" (\n    \\"id\\" \\"uuid\\" DEFAULT \\"gen_random_uuid\\"() NOT NULL,\n    \\"account_id\\" \\"uuid\\" NOT NULL,\n    \\"credit_limit\\" numeric(15,2) NOT NULL,\n    \\"current_interest_rate\\" numeric(5,2) NOT NULL,\n    \\"cut_off_day\\" integer NOT NULL,\n    \\"payment_due_day\\" integer NOT NULL,\n    \\"minimum_payment_percentage\\" numeric(5,2) NOT NULL,\n    \\"created_at\\" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,\n    \\"modified_at\\" timestamp with time zone,\n    CONSTRAINT \\"credit_card_details_credit_limit_check\\" CHECK ((\\"credit_limit\\" > (0)::numeric)),\n    CONSTRAINT \\"credit_card_details_current_interest_rate_check\\" CHECK ((\\"current_interest_rate\\" >= (0)::numeric)),\n    CONSTRAINT \\"credit_card_details_cut_off_day_check\\" CHECK (((\\"cut_off_day\\" >= 1) AND (\\"cut_off_day\\" <= 31))),\n    CONSTRAINT \\"credit_card_details_minimum_payment_percentage_check\\" CHECK ((\\"minimum_payment_percentage\\" > (0)::numeric)),\n    CONSTRAINT \\"credit_card_details_payment_due_day_check\\" CHECK (((\\"payment_due_day\\" >= 1) AND (\\"payment_due_day\\" <= 31))),\n    CONSTRAINT \\"valid_days_order\\" CHECK (((\\"payment_due_day\\" > \\"cut_off_day\\") OR (\\"payment_due_day\\" < \\"cut_off_day\\")))\n)","ALTER TABLE \\"public\\".\\"credit_card_details\\" OWNER TO \\"postgres\\"","CREATE TABLE IF NOT EXISTS \\"public\\".\\"credit_card_interest_history\\" (\n    \\"id\\" \\"uuid\\" DEFAULT \\"gen_random_uuid\\"() NOT NULL,\n    \\"credit_card_id\\" \\"uuid\\" NOT NULL,\n    \\"old_rate\\" numeric(5,2) NOT NULL,\n    \\"new_rate\\" numeric(5,2) NOT NULL,\n    \\"change_date\\" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,\n    \\"reason\\" \\"text\\",\n    \\"created_at\\" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,\n    CONSTRAINT \\"credit_card_interest_history_new_rate_check\\" CHECK ((\\"new_rate\\" >= (0)::numeric)),\n    CONSTRAINT \\"credit_card_interest_history_old_rate_check\\" CHECK ((\\"old_rate\\" >= (0)::numeric))\n)","ALTER TABLE \\"public\\".\\"credit_card_interest_history\\" OWNER TO \\"postgres\\"","CREATE TABLE IF NOT EXISTS \\"public\\".\\"credit_card_statement\\" (\n    \\"id\\" \\"uuid\\" DEFAULT \\"gen_random_uuid\\"() NOT NULL,\n    \\"credit_card_id\\" \\"uuid\\" NOT NULL,\n    \\"statement_date\\" \\"date\\" NOT NULL,\n    \\"cut_off_date\\" \\"date\\" NOT NULL,\n    \\"due_date\\" \\"date\\" NOT NULL,\n    \\"previous_balance\\" numeric(15,2) NOT NULL,\n    \\"purchases_amount\\" numeric(15,2) DEFAULT 0 NOT NULL,\n    \\"payments_amount\\" numeric(15,2) DEFAULT 0 NOT NULL,\n    \\"interests_amount\\" numeric(15,2) DEFAULT 0 NOT NULL,\n    \\"ending_balance\\" numeric(15,2) NOT NULL,\n    \\"minimum_payment\\" numeric(15,2) NOT NULL,\n    \\"remaining_credit\\" numeric(15,2) NOT NULL,\n    \\"status\\" character varying(20) NOT NULL,\n    \\"created_at\\" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,\n    \\"modified_at\\" timestamp with time zone,\n    CONSTRAINT \\"credit_card_statement_status_check\\" CHECK (((\\"status\\")::\\"text\\" = ANY ((ARRAY['PENDING'::character varying, 'PAID_MINIMUM'::character varying, 'PAID_FULL'::character varying])::\\"text\\"[]))),\n    CONSTRAINT \\"valid_dates\\" CHECK (((\\"statement_date\\" <= \\"cut_off_date\\") AND (\\"cut_off_date\\" < \\"due_date\\")))\n)","ALTER TABLE \\"public\\".\\"credit_card_statement\\" OWNER TO \\"postgres\\"","CREATE TABLE IF NOT EXISTS \\"public\\".\\"currency\\" (\n    \\"id\\" \\"uuid\\" DEFAULT \\"gen_random_uuid\\"() NOT NULL,\n    \\"code\\" character varying(3) NOT NULL,\n    \\"name\\" \\"text\\" NOT NULL,\n    \\"symbol\\" character varying(5),\n    \\"is_active\\" boolean DEFAULT true NOT NULL,\n    \\"created_at\\" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,\n    \\"modified_at\\" timestamp with time zone\n)","ALTER TABLE \\"public\\".\\"currency\\" OWNER TO \\"postgres\\"","COMMENT ON TABLE \\"public\\".\\"currency\\" IS 'Catálogo de monedas soportadas'","CREATE TABLE IF NOT EXISTS \\"public\\".\\"transaction\\" (\n    \\"id\\" \\"uuid\\" DEFAULT \\"gen_random_uuid\\"() NOT NULL,\n    \\"user_id\\" \\"uuid\\" NOT NULL,\n    \\"transaction_date\\" \\"date\\" DEFAULT CURRENT_DATE NOT NULL,\n    \\"description\\" \\"text\\",\n    \\"amount\\" numeric(15,2) NOT NULL,\n    \\"transaction_type_id\\" \\"uuid\\" NOT NULL,\n    \\"category_id\\" \\"uuid\\" NOT NULL,\n    \\"subcategory_id\\" \\"uuid\\" NOT NULL,\n    \\"account_id\\" \\"uuid\\" NOT NULL,\n    \\"jar_id\\" \\"uuid\\",\n    \\"transaction_medium_id\\" \\"uuid\\",\n    \\"currency_id\\" \\"uuid\\" NOT NULL,\n    \\"exchange_rate\\" numeric(10,6) DEFAULT 1 NOT NULL,\n    \\"is_recurring\\" boolean DEFAULT false,\n    \\"parent_recurring_id\\" \\"uuid\\",\n    \\"sync_status\\" character varying(20) DEFAULT 'PENDING'::character varying NOT NULL,\n    \\"created_at\\" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,\n    \\"modified_at\\" timestamp with time zone,\n    \\"installment_purchase_id\\" \\"uuid\\",\n    \\"tags\\" \\"jsonb\\" DEFAULT '[]'::\\"jsonb\\",\n    \\"notes\\" \\"text\\",\n    CONSTRAINT \\"transaction_amount_check\\" CHECK ((\\"amount\\" <> (0)::numeric)),\n    CONSTRAINT \\"transaction_sync_status_check\\" CHECK (((\\"sync_status\\")::\\"text\\" = ANY ((ARRAY['PENDING'::character varying, 'SYNCED'::character varying, 'ERROR'::character varying])::\\"text\\"[]))),\n    CONSTRAINT \\"transaction_tags_is_array\\" CHECK ((\\"jsonb_typeof\\"(\\"tags\\") = 'array'::\\"text\\")),\n    CONSTRAINT \\"valid_exchange_rate\\" CHECK ((\\"exchange_rate\\" > (0)::numeric))\n)","ALTER TABLE \\"public\\".\\"transaction\\" OWNER TO \\"postgres\\"","COMMENT ON TABLE \\"public\\".\\"transaction\\" IS 'Registro de todas las transacciones financieras'","COMMENT ON COLUMN \\"public\\".\\"transaction\\".\\"tags\\" IS 'Array of tags for transaction classification and searching'","COMMENT ON COLUMN \\"public\\".\\"transaction\\".\\"notes\\" IS 'Additional notes and details about the transaction'","CREATE TABLE IF NOT EXISTS \\"public\\".\\"transaction_type\\" (\n    \\"id\\" \\"uuid\\" DEFAULT \\"gen_random_uuid\\"() NOT NULL,\n    \\"name\\" \\"text\\" NOT NULL,\n    \\"description\\" \\"text\\",\n    \\"is_active\\" boolean DEFAULT true NOT NULL,\n    \\"created_at\\" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,\n    \\"modified_at\\" timestamp with time zone\n)","ALTER TABLE \\"public\\".\\"transaction_type\\" OWNER TO \\"postgres\\"","COMMENT ON TABLE \\"public\\".\\"transaction_type\\" IS 'Tipos de transacciones soportadas'","CREATE OR REPLACE VIEW \\"public\\".\\"expense_trends_analysis\\" AS\n WITH \\"monthly_expenses\\" AS (\n         SELECT \\"t\\".\\"user_id\\",\n            \\"date_trunc\\"('month'::\\"text\\", (\\"t\\".\\"transaction_date\\")::timestamp with time zone) AS \\"month\\",\n            \\"c\\".\\"name\\" AS \\"category_name\\",\n            \\"sum\\"(\\"t\\".\\"amount\\") AS \\"total_amount\\",\n            \\"count\\"(*) AS \\"transaction_count\\"\n           FROM ((\\"public\\".\\"transaction\\" \\"t\\"\n             JOIN \\"public\\".\\"transaction_type\\" \\"tt\\" ON ((\\"tt\\".\\"id\\" = \\"t\\".\\"transaction_type_id\\")))\n             JOIN \\"public\\".\\"category\\" \\"c\\" ON ((\\"c\\".\\"id\\" = \\"t\\".\\"category_id\\")))\n          WHERE (\\"tt\\".\\"name\\" = 'Gasto'::\\"text\\")\n          GROUP BY \\"t\\".\\"user_id\\", (\\"date_trunc\\"('month'::\\"text\\", (\\"t\\".\\"transaction_date\\")::timestamp with time zone)), \\"c\\".\\"name\\"\n        )\n SELECT \\"monthly_expenses\\".\\"user_id\\",\n    \\"monthly_expenses\\".\\"month\\",\n    \\"monthly_expenses\\".\\"category_name\\",\n    \\"monthly_expenses\\".\\"total_amount\\",\n    \\"monthly_expenses\\".\\"transaction_count\\",\n    \\"lag\\"(\\"monthly_expenses\\".\\"total_amount\\") OVER (PARTITION BY \\"monthly_expenses\\".\\"user_id\\", \\"monthly_expenses\\".\\"category_name\\" ORDER BY \\"monthly_expenses\\".\\"month\\") AS \\"prev_month_amount\\",\n    \\"round\\"((((\\"monthly_expenses\\".\\"total_amount\\" - \\"lag\\"(\\"monthly_expenses\\".\\"total_amount\\") OVER (PARTITION BY \\"monthly_expenses\\".\\"user_id\\", \\"monthly_expenses\\".\\"category_name\\" ORDER BY \\"monthly_expenses\\".\\"month\\")) / NULLIF(\\"lag\\"(\\"monthly_expenses\\".\\"total_amount\\") OVER (PARTITION BY \\"monthly_expenses\\".\\"user_id\\", \\"monthly_expenses\\".\\"category_name\\" ORDER BY \\"monthly_expenses\\".\\"month\\"), (0)::numeric)) * (100)::numeric), 2) AS \\"month_over_month_change\\",\n    \\"avg\\"(\\"monthly_expenses\\".\\"total_amount\\") OVER (PARTITION BY \\"monthly_expenses\\".\\"user_id\\", \\"monthly_expenses\\".\\"category_name\\" ORDER BY \\"monthly_expenses\\".\\"month\\" ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS \\"three_month_moving_avg\\"\n   FROM \\"monthly_expenses\\"","ALTER TABLE \\"public\\".\\"expense_trends_analysis\\" OWNER TO \\"postgres\\"","CREATE TABLE IF NOT EXISTS \\"public\\".\\"financial_goal\\" (\n    \\"id\\" \\"uuid\\" DEFAULT \\"gen_random_uuid\\"() NOT NULL,\n    \\"user_id\\" \\"uuid\\" NOT NULL,\n    \\"name\\" \\"text\\" NOT NULL,\n    \\"description\\" \\"text\\",\n    \\"target_amount\\" numeric(15,2) NOT NULL,\n    \\"current_amount\\" numeric(15,2) DEFAULT 0 NOT NULL,\n    \\"start_date\\" \\"date\\" NOT NULL,\n    \\"target_date\\" \\"date\\" NOT NULL,\n    \\"jar_id\\" \\"uuid\\",\n    \\"status\\" character varying(20) DEFAULT 'IN_PROGRESS'::character varying NOT NULL,\n    \\"is_active\\" boolean DEFAULT true NOT NULL,\n    \\"created_at\\" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,\n    \\"modified_at\\" timestamp with time zone,\n    CONSTRAINT \\"financial_goal_status_check\\" CHECK (((\\"status\\")::\\"text\\" = ANY ((ARRAY['IN_PROGRESS'::character varying, 'COMPLETED'::character varying, 'CANCELLED'::character varying])::\\"text\\"[]))),\n    CONSTRAINT \\"financial_goal_target_amount_check\\" CHECK ((\\"target_amount\\" > (0)::numeric)),\n    CONSTRAINT \\"valid_amounts\\" CHECK ((\\"current_amount\\" <= \\"target_amount\\")),\n    CONSTRAINT \\"valid_dates\\" CHECK ((\\"target_date\\" > \\"start_date\\"))\n)","ALTER TABLE \\"public\\".\\"financial_goal\\" OWNER TO \\"postgres\\"","COMMENT ON TABLE \\"public\\".\\"financial_goal\\" IS 'Metas financieras de ahorro e inversión'","CREATE TABLE IF NOT EXISTS \\"public\\".\\"jar\\" (\n    \\"id\\" \\"uuid\\" DEFAULT \\"gen_random_uuid\\"() NOT NULL,\n    \\"name\\" \\"text\\" NOT NULL,\n    \\"description\\" \\"text\\",\n    \\"target_percentage\\" numeric(5,2) NOT NULL,\n    \\"is_active\\" boolean DEFAULT true NOT NULL,\n    \\"created_at\\" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,\n    \\"modified_at\\" timestamp with time zone,\n    CONSTRAINT \\"valid_percentage\\" CHECK (((\\"target_percentage\\" > (0)::numeric) AND (\\"target_percentage\\" <= (100)::numeric)))\n)","ALTER TABLE \\"public\\".\\"jar\\" OWNER TO \\"postgres\\"","COMMENT ON TABLE \\"public\\".\\"jar\\" IS 'Jarras según metodología de T. Harv Eker'","COMMENT ON COLUMN \\"public\\".\\"jar\\".\\"target_percentage\\" IS 'Porcentaje que debe recibir la jarra de los ingresos'","CREATE OR REPLACE VIEW \\"public\\".\\"goal_progress_summary\\" AS\n WITH \\"goal_progress\\" AS (\n         SELECT \\"g_1\\".\\"id\\",\n            \\"g_1\\".\\"user_id\\",\n            \\"g_1\\".\\"name\\",\n            \\"g_1\\".\\"description\\",\n            \\"g_1\\".\\"target_amount\\",\n            \\"g_1\\".\\"current_amount\\",\n            \\"g_1\\".\\"start_date\\",\n            \\"g_1\\".\\"target_date\\",\n            \\"g_1\\".\\"jar_id\\",\n            \\"g_1\\".\\"status\\",\n            \\"g_1\\".\\"is_active\\",\n            \\"g_1\\".\\"created_at\\",\n            \\"g_1\\".\\"modified_at\\",\n            \\"public\\".\\"calculate_goal_progress\\"(\\"g_1\\".\\"current_amount\\", \\"g_1\\".\\"target_amount\\", \\"g_1\\".\\"start_date\\", \\"g_1\\".\\"target_date\\") AS \\"progress\\"\n           FROM \\"public\\".\\"financial_goal\\" \\"g_1\\"\n          WHERE (\\"g_1\\".\\"is_active\\" = true)\n        )\n SELECT \\"g\\".\\"user_id\\",\n    \\"g\\".\\"id\\" AS \\"goal_id\\",\n    \\"g\\".\\"name\\",\n    \\"g\\".\\"target_amount\\",\n    \\"g\\".\\"current_amount\\",\n    (\\"g\\".\\"progress\\").\\"percentage_complete\\" AS \\"percentage_complete\\",\n    (\\"g\\".\\"progress\\").\\"amount_remaining\\" AS \\"amount_remaining\\",\n    (\\"g\\".\\"progress\\").\\"days_remaining\\" AS \\"days_remaining\\",\n    (\\"g\\".\\"progress\\").\\"is_on_track\\" AS \\"is_on_track\\",\n    (\\"g\\".\\"progress\\").\\"required_daily_amount\\" AS \\"required_daily_amount\\",\n    \\"j\\".\\"name\\" AS \\"jar_name\\",\n    \\"g\\".\\"status\\",\n    \\"g\\".\\"start_date\\",\n    \\"g\\".\\"target_date\\",\n    \\"g\\".\\"created_at\\",\n    \\"g\\".\\"modified_at\\"\n   FROM (\\"goal_progress\\" \\"g\\"\n     LEFT JOIN \\"public\\".\\"jar\\" \\"j\\" ON ((\\"j\\".\\"id\\" = \\"g\\".\\"jar_id\\")))","ALTER TABLE \\"public\\".\\"goal_progress_summary\\" OWNER TO \\"postgres\\"","CREATE TABLE IF NOT EXISTS \\"public\\".\\"installment_purchase\\" (\n    \\"id\\" \\"uuid\\" DEFAULT \\"gen_random_uuid\\"() NOT NULL,\n    \\"transaction_id\\" \\"uuid\\" NOT NULL,\n    \\"credit_card_id\\" \\"uuid\\" NOT NULL,\n    \\"total_amount\\" numeric(15,2) NOT NULL,\n    \\"number_of_installments\\" integer NOT NULL,\n    \\"installment_amount\\" numeric(15,2) NOT NULL,\n    \\"remaining_installments\\" integer NOT NULL,\n    \\"next_installment_date\\" \\"date\\" NOT NULL,\n    \\"status\\" character varying(20) NOT NULL,\n    \\"created_at\\" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,\n    \\"modified_at\\" timestamp with time zone,\n    CONSTRAINT \\"installment_purchase_installment_amount_check\\" CHECK ((\\"installment_amount\\" > (0)::numeric)),\n    CONSTRAINT \\"installment_purchase_number_of_installments_check\\" CHECK ((\\"number_of_installments\\" > 0)),\n    CONSTRAINT \\"installment_purchase_status_check\\" CHECK (((\\"status\\")::\\"text\\" = ANY ((ARRAY['ACTIVE'::character varying, 'COMPLETED'::character varying, 'CANCELLED'::character varying])::\\"text\\"[]))),\n    CONSTRAINT \\"installment_purchase_total_amount_check\\" CHECK ((\\"total_amount\\" > (0)::numeric))\n)","ALTER TABLE \\"public\\".\\"installment_purchase\\" OWNER TO \\"postgres\\"","CREATE TABLE IF NOT EXISTS \\"public\\".\\"jar_balance\\" (\n    \\"id\\" \\"uuid\\" DEFAULT \\"gen_random_uuid\\"() NOT NULL,\n    \\"user_id\\" \\"uuid\\" NOT NULL,\n    \\"jar_id\\" \\"uuid\\" NOT NULL,\n    \\"current_balance\\" numeric(15,2) DEFAULT 0 NOT NULL,\n    \\"created_at\\" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,\n    \\"modified_at\\" timestamp with time zone\n)","ALTER TABLE \\"public\\".\\"jar_balance\\" OWNER TO \\"postgres\\"","COMMENT ON TABLE \\"public\\".\\"jar_balance\\" IS 'Balance actual de cada jarra por usuario'","CREATE OR REPLACE VIEW \\"public\\".\\"methodology_compliance_analysis\\" AS\n WITH \\"jar_distributions\\" AS (\n         SELECT \\"t\\".\\"user_id\\",\n            \\"date_trunc\\"('month'::\\"text\\", (\\"t\\".\\"transaction_date\\")::timestamp with time zone) AS \\"month\\",\n            \\"j\\".\\"name\\" AS \\"jar_name\\",\n            \\"j\\".\\"target_percentage\\",\n            \\"sum\\"(\\"t\\".\\"amount\\") AS \\"jar_amount\\",\n            \\"sum\\"(\\"sum\\"(\\"t\\".\\"amount\\")) OVER (PARTITION BY \\"t\\".\\"user_id\\", (\\"date_trunc\\"('month'::\\"text\\", (\\"t\\".\\"transaction_date\\")::timestamp with time zone))) AS \\"total_amount\\"\n           FROM ((\\"public\\".\\"transaction\\" \\"t\\"\n             JOIN \\"public\\".\\"transaction_type\\" \\"tt\\" ON ((\\"tt\\".\\"id\\" = \\"t\\".\\"transaction_type_id\\")))\n             JOIN \\"public\\".\\"jar\\" \\"j\\" ON ((\\"j\\".\\"id\\" = \\"t\\".\\"jar_id\\")))\n          WHERE (\\"tt\\".\\"name\\" = 'Gasto'::\\"text\\")\n          GROUP BY \\"t\\".\\"user_id\\", (\\"date_trunc\\"('month'::\\"text\\", (\\"t\\".\\"transaction_date\\")::timestamp with time zone)), \\"j\\".\\"name\\", \\"j\\".\\"target_percentage\\"\n        )\n SELECT \\"jar_distributions\\".\\"user_id\\",\n    \\"jar_distributions\\".\\"month\\",\n    \\"jar_distributions\\".\\"jar_name\\",\n    \\"jar_distributions\\".\\"target_percentage\\",\n    \\"round\\"(((\\"jar_distributions\\".\\"jar_amount\\" / NULLIF(\\"jar_distributions\\".\\"total_amount\\", (0)::numeric)) * (100)::numeric), 2) AS \\"actual_percentage\\",\n    \\"round\\"((((\\"jar_distributions\\".\\"jar_amount\\" / NULLIF(\\"jar_distributions\\".\\"total_amount\\", (0)::numeric)) * (100)::numeric) - \\"jar_distributions\\".\\"target_percentage\\"), 2) AS \\"percentage_difference\\",\n    (\\"abs\\"((((\\"jar_distributions\\".\\"jar_amount\\" / NULLIF(\\"jar_distributions\\".\\"total_amount\\", (0)::numeric)) * (100)::numeric) - \\"jar_distributions\\".\\"target_percentage\\")) <= (2)::numeric) AS \\"is_compliant\\"\n   FROM \\"jar_distributions\\"","ALTER TABLE \\"public\\".\\"methodology_compliance_analysis\\" OWNER TO \\"postgres\\"","CREATE TABLE IF NOT EXISTS \\"public\\".\\"notification\\" (\n    \\"id\\" \\"uuid\\" DEFAULT \\"gen_random_uuid\\"() NOT NULL,\n    \\"user_id\\" \\"uuid\\" NOT NULL,\n    \\"title\\" \\"text\\" NOT NULL,\n    \\"message\\" \\"text\\" NOT NULL,\n    \\"notification_type\\" character varying(50) NOT NULL,\n    \\"urgency_level\\" character varying(20) NOT NULL,\n    \\"related_entity_type\\" character varying(50),\n    \\"related_entity_id\\" \\"uuid\\",\n    \\"is_read\\" boolean DEFAULT false NOT NULL,\n    \\"created_at\\" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,\n    \\"read_at\\" timestamp with time zone,\n    CONSTRAINT \\"notification_notification_type_check\\" CHECK (((\\"notification_type\\")::\\"text\\" = ANY ((ARRAY['RECURRING_TRANSACTION'::character varying, 'INSUFFICIENT_FUNDS'::character varying, 'GOAL_PROGRESS'::character varying, 'SYNC_ERROR'::character varying, 'SYSTEM'::character varying, 'CREDIT_CARD_DUE_DATE'::character varying, 'CREDIT_CARD_CUT_OFF'::character varying, 'CREDIT_CARD_LIMIT'::character varying, 'CREDIT_CARD_MINIMUM_PAYMENT'::character varying])::\\"text\\"[]))),\n    CONSTRAINT \\"notification_urgency_level_check\\" CHECK (((\\"urgency_level\\")::\\"text\\" = ANY ((ARRAY['LOW'::character varying, 'MEDIUM'::character varying, 'HIGH'::character varying])::\\"text\\"[])))\n)","ALTER TABLE \\"public\\".\\"notification\\" OWNER TO \\"postgres\\"","COMMENT ON TABLE \\"public\\".\\"notification\\" IS 'Registro de notificaciones del sistema'","CREATE TABLE IF NOT EXISTS \\"public\\".\\"recurring_transaction\\" (\n    \\"id\\" \\"uuid\\" DEFAULT \\"gen_random_uuid\\"() NOT NULL,\n    \\"user_id\\" \\"uuid\\" NOT NULL,\n    \\"name\\" \\"text\\" NOT NULL,\n    \\"description\\" \\"text\\",\n    \\"amount\\" numeric(15,2) NOT NULL,\n    \\"transaction_type_id\\" \\"uuid\\" NOT NULL,\n    \\"category_id\\" \\"uuid\\" NOT NULL,\n    \\"subcategory_id\\" \\"uuid\\" NOT NULL,\n    \\"account_id\\" \\"uuid\\" NOT NULL,\n    \\"jar_id\\" \\"uuid\\",\n    \\"transaction_medium_id\\" \\"uuid\\",\n    \\"frequency\\" character varying(20) NOT NULL,\n    \\"start_date\\" \\"date\\" NOT NULL,\n    \\"end_date\\" \\"date\\",\n    \\"last_execution_date\\" \\"date\\",\n    \\"next_execution_date\\" \\"date\\",\n    \\"is_active\\" boolean DEFAULT true NOT NULL,\n    \\"created_at\\" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,\n    \\"modified_at\\" timestamp with time zone,\n    CONSTRAINT \\"recurring_transaction_amount_check\\" CHECK ((\\"amount\\" <> (0)::numeric)),\n    CONSTRAINT \\"recurring_transaction_frequency_check\\" CHECK (((\\"frequency\\")::\\"text\\" = ANY ((ARRAY['WEEKLY'::character varying, 'MONTHLY'::character varying, 'YEARLY'::character varying])::\\"text\\"[]))),\n    CONSTRAINT \\"valid_dates\\" CHECK ((((\\"end_date\\" IS NULL) OR (\\"end_date\\" >= \\"start_date\\")) AND ((\\"next_execution_date\\" IS NULL) OR (\\"next_execution_date\\" >= CURRENT_DATE))))\n)","ALTER TABLE \\"public\\".\\"recurring_transaction\\" OWNER TO \\"postgres\\"","COMMENT ON TABLE \\"public\\".\\"recurring_transaction\\" IS 'Configuración de transacciones recurrentes'","CREATE TABLE IF NOT EXISTS \\"public\\".\\"schema_migrations\\" (\n    \\"version\\" \\"text\\" NOT NULL\n)","ALTER TABLE \\"public\\".\\"schema_migrations\\" OWNER TO \\"postgres\\"","CREATE TABLE IF NOT EXISTS \\"public\\".\\"subcategory\\" (\n    \\"id\\" \\"uuid\\" DEFAULT \\"gen_random_uuid\\"() NOT NULL,\n    \\"name\\" \\"text\\" NOT NULL,\n    \\"description\\" \\"text\\",\n    \\"category_id\\" \\"uuid\\" NOT NULL,\n    \\"jar_id\\" \\"uuid\\",\n    \\"is_active\\" boolean DEFAULT true NOT NULL,\n    \\"created_at\\" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,\n    \\"modified_at\\" timestamp with time zone\n)","ALTER TABLE \\"public\\".\\"subcategory\\" OWNER TO \\"postgres\\"","COMMENT ON TABLE \\"public\\".\\"subcategory\\" IS 'Subcategorías para clasificación detallada'","COMMENT ON COLUMN \\"public\\".\\"subcategory\\".\\"jar_id\\" IS 'Jarra asociada, requerida solo para gastos'","CREATE TABLE IF NOT EXISTS \\"public\\".\\"transaction_medium\\" (\n    \\"id\\" \\"uuid\\" DEFAULT \\"gen_random_uuid\\"() NOT NULL,\n    \\"name\\" \\"text\\" NOT NULL,\n    \\"description\\" \\"text\\",\n    \\"is_active\\" boolean DEFAULT true NOT NULL,\n    \\"created_at\\" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,\n    \\"modified_at\\" timestamp with time zone\n)","ALTER TABLE \\"public\\".\\"transaction_medium\\" OWNER TO \\"postgres\\"","COMMENT ON TABLE \\"public\\".\\"transaction_medium\\" IS 'Medios de pago soportados'","CREATE TABLE IF NOT EXISTS \\"public\\".\\"transfer\\" (\n    \\"id\\" \\"uuid\\" DEFAULT \\"gen_random_uuid\\"() NOT NULL,\n    \\"user_id\\" \\"uuid\\" NOT NULL,\n    \\"transfer_date\\" \\"date\\" DEFAULT CURRENT_DATE NOT NULL,\n    \\"description\\" \\"text\\",\n    \\"amount\\" numeric(15,2) NOT NULL,\n    \\"transfer_type\\" character varying(20) NOT NULL,\n    \\"from_account_id\\" \\"uuid\\",\n    \\"to_account_id\\" \\"uuid\\",\n    \\"from_jar_id\\" \\"uuid\\",\n    \\"to_jar_id\\" \\"uuid\\",\n    \\"exchange_rate\\" numeric(10,6) DEFAULT 1 NOT NULL,\n    \\"notes\\" \\"text\\",\n    \\"sync_status\\" character varying(20) DEFAULT 'PENDING'::character varying NOT NULL,\n    \\"created_at\\" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,\n    \\"modified_at\\" timestamp with time zone,\n    CONSTRAINT \\"different_endpoints\\" CHECK ((((\\"from_account_id\\" IS NULL) OR (\\"from_account_id\\" <> \\"to_account_id\\")) AND ((\\"from_jar_id\\" IS NULL) OR (\\"from_jar_id\\" <> \\"to_jar_id\\")))),\n    CONSTRAINT \\"transfer_amount_check\\" CHECK ((\\"amount\\" > (0)::numeric)),\n    CONSTRAINT \\"transfer_sync_status_check\\" CHECK (((\\"sync_status\\")::\\"text\\" = ANY ((ARRAY['PENDING'::character varying, 'SYNCED'::character varying, 'ERROR'::character varying])::\\"text\\"[]))),\n    CONSTRAINT \\"transfer_transfer_type_check\\" CHECK (((\\"transfer_type\\")::\\"text\\" = ANY ((ARRAY['ACCOUNT_TO_ACCOUNT'::character varying, 'JAR_TO_JAR'::character varying, 'PERIOD_ROLLOVER'::character varying])::\\"text\\"[]))),\n    CONSTRAINT \\"valid_transfer_endpoints\\" CHECK (((((\\"transfer_type\\")::\\"text\\" = 'ACCOUNT_TO_ACCOUNT'::\\"text\\") AND (\\"from_account_id\\" IS NOT NULL) AND (\\"to_account_id\\" IS NOT NULL) AND (\\"from_jar_id\\" IS NULL) AND (\\"to_jar_id\\" IS NULL)) OR (((\\"transfer_type\\")::\\"text\\" = 'JAR_TO_JAR'::\\"text\\") AND (\\"from_jar_id\\" IS NOT NULL) AND (\\"to_jar_id\\" IS NOT NULL) AND (\\"from_account_id\\" IS NULL) AND (\\"to_account_id\\" IS NULL)) OR (((\\"transfer_type\\")::\\"text\\" = 'PERIOD_ROLLOVER'::\\"text\\") AND (\\"from_jar_id\\" IS NOT NULL) AND (\\"to_jar_id\\" IS NOT NULL) AND (\\"from_account_id\\" IS NULL) AND (\\"to_account_id\\" IS NULL))))\n)","ALTER TABLE \\"public\\".\\"transfer\\" OWNER TO \\"postgres\\"","COMMENT ON TABLE \\"public\\".\\"transfer\\" IS 'Registro de transferencias entre cuentas y jarras'","COMMENT ON COLUMN \\"public\\".\\"transfer\\".\\"transfer_type\\" IS 'ACCOUNT_TO_ACCOUNT: entre cuentas, JAR_TO_JAR: entre jarras, PERIOD_ROLLOVER: rollover de periodo'","CREATE OR REPLACE VIEW \\"public\\".\\"transfer_summary\\" AS\n SELECT \\"t\\".\\"user_id\\",\n    \\"t\\".\\"transfer_type\\",\n    \\"t\\".\\"transfer_date\\",\n    \\"t\\".\\"amount\\",\n    \\"t\\".\\"exchange_rate\\",\n        CASE\n            WHEN ((\\"t\\".\\"transfer_type\\")::\\"text\\" = 'ACCOUNT_TO_ACCOUNT'::\\"text\\") THEN ( SELECT \\"account\\".\\"name\\"\n               FROM \\"public\\".\\"account\\"\n              WHERE (\\"account\\".\\"id\\" = \\"t\\".\\"from_account_id\\"))\n            ELSE ( SELECT \\"jar\\".\\"name\\"\n               FROM \\"public\\".\\"jar\\"\n              WHERE (\\"jar\\".\\"id\\" = \\"t\\".\\"from_jar_id\\"))\n        END AS \\"source_name\\",\n        CASE\n            WHEN ((\\"t\\".\\"transfer_type\\")::\\"text\\" = 'ACCOUNT_TO_ACCOUNT'::\\"text\\") THEN ( SELECT \\"account\\".\\"name\\"\n               FROM \\"public\\".\\"account\\"\n              WHERE (\\"account\\".\\"id\\" = \\"t\\".\\"to_account_id\\"))\n            ELSE ( SELECT \\"jar\\".\\"name\\"\n               FROM \\"public\\".\\"jar\\"\n              WHERE (\\"jar\\".\\"id\\" = \\"t\\".\\"to_jar_id\\"))\n        END AS \\"target_name\\",\n        CASE\n            WHEN ((\\"t\\".\\"transfer_type\\")::\\"text\\" = 'ACCOUNT_TO_ACCOUNT'::\\"text\\") THEN (\\"t\\".\\"amount\\" * \\"t\\".\\"exchange_rate\\")\n            ELSE \\"t\\".\\"amount\\"\n        END AS \\"converted_amount\\",\n    \\"t\\".\\"description\\",\n    \\"t\\".\\"sync_status\\",\n    \\"t\\".\\"created_at\\"\n   FROM \\"public\\".\\"transfer\\" \\"t\\"","ALTER TABLE \\"public\\".\\"transfer_summary\\" OWNER TO \\"postgres\\"","CREATE OR REPLACE VIEW \\"public\\".\\"transfer_analysis\\" AS\n WITH \\"monthly_stats\\" AS (\n         SELECT \\"transfer_summary\\".\\"user_id\\",\n            \\"date_trunc\\"('month'::\\"text\\", (\\"transfer_summary\\".\\"transfer_date\\")::timestamp with time zone) AS \\"month\\",\n            \\"transfer_summary\\".\\"transfer_type\\",\n            \\"count\\"(*) AS \\"transfer_count\\",\n            \\"sum\\"(\\"transfer_summary\\".\\"converted_amount\\") AS \\"total_amount\\",\n            \\"avg\\"(\\"transfer_summary\\".\\"converted_amount\\") AS \\"avg_amount\\"\n           FROM \\"public\\".\\"transfer_summary\\"\n          GROUP BY \\"transfer_summary\\".\\"user_id\\", (\\"date_trunc\\"('month'::\\"text\\", (\\"transfer_summary\\".\\"transfer_date\\")::timestamp with time zone)), \\"transfer_summary\\".\\"transfer_type\\"\n        ), \\"monthly_changes\\" AS (\n         SELECT \\"monthly_stats\\".\\"user_id\\",\n            \\"monthly_stats\\".\\"month\\",\n            \\"monthly_stats\\".\\"transfer_type\\",\n            \\"monthly_stats\\".\\"transfer_count\\",\n            \\"monthly_stats\\".\\"total_amount\\",\n            \\"monthly_stats\\".\\"avg_amount\\",\n            \\"lag\\"(\\"monthly_stats\\".\\"total_amount\\") OVER (PARTITION BY \\"monthly_stats\\".\\"user_id\\", \\"monthly_stats\\".\\"transfer_type\\" ORDER BY \\"monthly_stats\\".\\"month\\") AS \\"prev_month_amount\\"\n           FROM \\"monthly_stats\\"\n        )\n SELECT \\"monthly_changes\\".\\"user_id\\",\n    \\"monthly_changes\\".\\"month\\",\n    \\"monthly_changes\\".\\"transfer_type\\",\n    \\"monthly_changes\\".\\"transfer_count\\",\n    \\"monthly_changes\\".\\"total_amount\\",\n    \\"monthly_changes\\".\\"avg_amount\\",\n    \\"monthly_changes\\".\\"prev_month_amount\\",\n    \\"round\\"((((\\"monthly_changes\\".\\"total_amount\\" - \\"monthly_changes\\".\\"prev_month_amount\\") / NULLIF(\\"monthly_changes\\".\\"prev_month_amount\\", (0)::numeric)) * (100)::numeric), 2) AS \\"month_over_month_change\\"\n   FROM \\"monthly_changes\\"","ALTER TABLE \\"public\\".\\"transfer_analysis\\" OWNER TO \\"postgres\\"","ALTER TABLE ONLY \\"public\\".\\"account\\"\n    ADD CONSTRAINT \\"account_pkey\\" PRIMARY KEY (\\"id\\")","ALTER TABLE ONLY \\"public\\".\\"account_type\\"\n    ADD CONSTRAINT \\"account_type_name_unique\\" UNIQUE (\\"name\\")","ALTER TABLE ONLY \\"public\\".\\"account_type\\"\n    ADD CONSTRAINT \\"account_type_pkey\\" PRIMARY KEY (\\"id\\")","ALTER TABLE ONLY \\"public\\".\\"app_user\\"\n    ADD CONSTRAINT \\"app_user_pkey\\" PRIMARY KEY (\\"id\\")","ALTER TABLE ONLY \\"public\\".\\"balance_history\\"\n    ADD CONSTRAINT \\"balance_history_pkey\\" PRIMARY KEY (\\"id\\")","ALTER TABLE ONLY \\"public\\".\\"category\\"\n    ADD CONSTRAINT \\"category_pkey\\" PRIMARY KEY (\\"id\\")","ALTER TABLE ONLY \\"public\\".\\"credit_card_details\\"\n    ADD CONSTRAINT \\"credit_card_details_pkey\\" PRIMARY KEY (\\"id\\")","ALTER TABLE ONLY \\"public\\".\\"credit_card_interest_history\\"\n    ADD CONSTRAINT \\"credit_card_interest_history_pkey\\" PRIMARY KEY (\\"id\\")","ALTER TABLE ONLY \\"public\\".\\"credit_card_statement\\"\n    ADD CONSTRAINT \\"credit_card_statement_pkey\\" PRIMARY KEY (\\"id\\")","ALTER TABLE ONLY \\"public\\".\\"currency\\"\n    ADD CONSTRAINT \\"currency_code_key\\" UNIQUE (\\"code\\")","ALTER TABLE ONLY \\"public\\".\\"currency\\"\n    ADD CONSTRAINT \\"currency_pkey\\" PRIMARY KEY (\\"id\\")","ALTER TABLE ONLY \\"public\\".\\"financial_goal\\"\n    ADD CONSTRAINT \\"financial_goal_pkey\\" PRIMARY KEY (\\"id\\")","ALTER TABLE ONLY \\"public\\".\\"installment_purchase\\"\n    ADD CONSTRAINT \\"installment_purchase_pkey\\" PRIMARY KEY (\\"id\\")","ALTER TABLE ONLY \\"public\\".\\"jar_balance\\"\n    ADD CONSTRAINT \\"jar_balance_pkey\\" PRIMARY KEY (\\"id\\")","ALTER TABLE ONLY \\"public\\".\\"jar\\"\n    ADD CONSTRAINT \\"jar_name_unique\\" UNIQUE (\\"name\\")","ALTER TABLE ONLY \\"public\\".\\"jar\\"\n    ADD CONSTRAINT \\"jar_pkey\\" PRIMARY KEY (\\"id\\")","ALTER TABLE ONLY \\"public\\".\\"notification\\"\n    ADD CONSTRAINT \\"notification_pkey\\" PRIMARY KEY (\\"id\\")","ALTER TABLE ONLY \\"public\\".\\"recurring_transaction\\"\n    ADD CONSTRAINT \\"recurring_transaction_pkey\\" PRIMARY KEY (\\"id\\")","ALTER TABLE ONLY \\"public\\".\\"schema_migrations\\"\n    ADD CONSTRAINT \\"schema_migrations_pkey\\" PRIMARY KEY (\\"version\\")","ALTER TABLE ONLY \\"public\\".\\"subcategory\\"\n    ADD CONSTRAINT \\"subcategory_pkey\\" PRIMARY KEY (\\"id\\")","ALTER TABLE ONLY \\"public\\".\\"transaction_medium\\"\n    ADD CONSTRAINT \\"transaction_medium_name_unique\\" UNIQUE (\\"name\\")","ALTER TABLE ONLY \\"public\\".\\"transaction_medium\\"\n    ADD CONSTRAINT \\"transaction_medium_pkey\\" PRIMARY KEY (\\"id\\")","ALTER TABLE ONLY \\"public\\".\\"transaction\\"\n    ADD CONSTRAINT \\"transaction_pkey\\" PRIMARY KEY (\\"id\\")","ALTER TABLE ONLY \\"public\\".\\"transaction_type\\"\n    ADD CONSTRAINT \\"transaction_type_name_unique\\" UNIQUE (\\"name\\")","ALTER TABLE ONLY \\"public\\".\\"transaction_type\\"\n    ADD CONSTRAINT \\"transaction_type_pkey\\" PRIMARY KEY (\\"id\\")","ALTER TABLE ONLY \\"public\\".\\"transfer\\"\n    ADD CONSTRAINT \\"transfer_pkey\\" PRIMARY KEY (\\"id\\")","ALTER TABLE ONLY \\"public\\".\\"credit_card_details\\"\n    ADD CONSTRAINT \\"unique_account_credit_card\\" UNIQUE (\\"account_id\\")","ALTER TABLE ONLY \\"public\\".\\"account\\"\n    ADD CONSTRAINT \\"unique_account_name_per_user\\" UNIQUE (\\"user_id\\", \\"name\\")","ALTER TABLE ONLY \\"public\\".\\"jar_balance\\"\n    ADD CONSTRAINT \\"unique_jar_per_user\\" UNIQUE (\\"user_id\\", \\"jar_id\\")","ALTER TABLE ONLY \\"public\\".\\"credit_card_statement\\"\n    ADD CONSTRAINT \\"unique_statement_period\\" UNIQUE (\\"credit_card_id\\", \\"statement_date\\")","CREATE INDEX \\"idx_account_active\\" ON \\"public\\".\\"account\\" USING \\"btree\\" (\\"id\\") WHERE (\\"is_active\\" = true)","CREATE INDEX \\"idx_account_type\\" ON \\"public\\".\\"account\\" USING \\"btree\\" (\\"account_type_id\\")","CREATE INDEX \\"idx_account_user\\" ON \\"public\\".\\"account\\" USING \\"btree\\" (\\"user_id\\")","CREATE INDEX \\"idx_app_user_active\\" ON \\"public\\".\\"app_user\\" USING \\"btree\\" (\\"id\\") WHERE (\\"is_active\\" = true)","CREATE INDEX \\"idx_app_user_email\\" ON \\"public\\".\\"app_user\\" USING \\"btree\\" (\\"email\\")","CREATE INDEX \\"idx_balance_history_account\\" ON \\"public\\".\\"balance_history\\" USING \\"btree\\" (\\"account_id\\") WHERE (\\"account_id\\" IS NOT NULL)","CREATE INDEX \\"idx_balance_history_jar\\" ON \\"public\\".\\"balance_history\\" USING \\"btree\\" (\\"jar_id\\") WHERE (\\"jar_id\\" IS NOT NULL)","CREATE INDEX \\"idx_balance_history_reference\\" ON \\"public\\".\\"balance_history\\" USING \\"btree\\" (\\"reference_type\\", \\"reference_id\\")","CREATE INDEX \\"idx_balance_history_user\\" ON \\"public\\".\\"balance_history\\" USING \\"btree\\" (\\"user_id\\")","CREATE INDEX \\"idx_category_active\\" ON \\"public\\".\\"category\\" USING \\"btree\\" (\\"id\\") WHERE (\\"is_active\\" = true)","CREATE INDEX \\"idx_category_type\\" ON \\"public\\".\\"category\\" USING \\"btree\\" (\\"transaction_type_id\\")","CREATE INDEX \\"idx_credit_card_cut_off\\" ON \\"public\\".\\"credit_card_details\\" USING \\"btree\\" (\\"cut_off_day\\")","CREATE INDEX \\"idx_credit_card_details_account\\" ON \\"public\\".\\"credit_card_details\\" USING \\"btree\\" (\\"account_id\\")","CREATE INDEX \\"idx_credit_card_statement_dates\\" ON \\"public\\".\\"credit_card_statement\\" USING \\"btree\\" (\\"credit_card_id\\", \\"statement_date\\")","CREATE INDEX \\"idx_credit_card_statement_due\\" ON \\"public\\".\\"credit_card_statement\\" USING \\"btree\\" (\\"credit_card_id\\", \\"due_date\\") WHERE ((\\"status\\")::\\"text\\" = 'PENDING'::\\"text\\")","CREATE INDEX \\"idx_currency_code\\" ON \\"public\\".\\"currency\\" USING \\"btree\\" (\\"code\\")","CREATE INDEX \\"idx_currency_name\\" ON \\"public\\".\\"currency\\" USING \\"btree\\" (\\"name\\")","CREATE INDEX \\"idx_financial_goal_active\\" ON \\"public\\".\\"financial_goal\\" USING \\"btree\\" (\\"id\\") WHERE (\\"is_active\\" = true)","CREATE INDEX \\"idx_financial_goal_dates\\" ON \\"public\\".\\"financial_goal\\" USING \\"btree\\" (\\"start_date\\", \\"target_date\\")","CREATE INDEX \\"idx_financial_goal_status\\" ON \\"public\\".\\"financial_goal\\" USING \\"btree\\" (\\"status\\")","CREATE INDEX \\"idx_financial_goal_user\\" ON \\"public\\".\\"financial_goal\\" USING \\"btree\\" (\\"user_id\\")","CREATE INDEX \\"idx_installment_purchase_active\\" ON \\"public\\".\\"installment_purchase\\" USING \\"btree\\" (\\"credit_card_id\\", \\"next_installment_date\\") WHERE ((\\"status\\")::\\"text\\" = 'ACTIVE'::\\"text\\")","CREATE INDEX \\"idx_jar_active\\" ON \\"public\\".\\"jar\\" USING \\"btree\\" (\\"id\\") WHERE (\\"is_active\\" = true)","CREATE INDEX \\"idx_jar_balance_jar\\" ON \\"public\\".\\"jar_balance\\" USING \\"btree\\" (\\"jar_id\\")","CREATE INDEX \\"idx_jar_balance_user\\" ON \\"public\\".\\"jar_balance\\" USING \\"btree\\" (\\"user_id\\")","CREATE INDEX \\"idx_jar_name\\" ON \\"public\\".\\"jar\\" USING \\"btree\\" (\\"name\\")","CREATE INDEX \\"idx_notification_entity\\" ON \\"public\\".\\"notification\\" USING \\"btree\\" (\\"related_entity_type\\", \\"related_entity_id\\") WHERE (\\"related_entity_id\\" IS NOT NULL)","CREATE INDEX \\"idx_notification_type\\" ON \\"public\\".\\"notification\\" USING \\"btree\\" (\\"notification_type\\")","CREATE INDEX \\"idx_notification_unread\\" ON \\"public\\".\\"notification\\" USING \\"btree\\" (\\"id\\") WHERE (NOT \\"is_read\\")","CREATE INDEX \\"idx_notification_user\\" ON \\"public\\".\\"notification\\" USING \\"btree\\" (\\"user_id\\")","CREATE INDEX \\"idx_recurring_transaction_next_no_end\\" ON \\"public\\".\\"recurring_transaction\\" USING \\"btree\\" (\\"next_execution_date\\") WHERE ((\\"is_active\\" = true) AND (\\"end_date\\" IS NULL))","CREATE INDEX \\"idx_recurring_transaction_next_with_end\\" ON \\"public\\".\\"recurring_transaction\\" USING \\"btree\\" (\\"next_execution_date\\", \\"end_date\\") WHERE (\\"is_active\\" = true)","CREATE INDEX \\"idx_recurring_transaction_user\\" ON \\"public\\".\\"recurring_transaction\\" USING \\"btree\\" (\\"user_id\\")","CREATE INDEX \\"idx_subcategory_active\\" ON \\"public\\".\\"subcategory\\" USING \\"btree\\" (\\"id\\") WHERE (\\"is_active\\" = true)","CREATE INDEX \\"idx_subcategory_category\\" ON \\"public\\".\\"subcategory\\" USING \\"btree\\" (\\"category_id\\")","CREATE INDEX \\"idx_subcategory_jar\\" ON \\"public\\".\\"subcategory\\" USING \\"btree\\" (\\"jar_id\\")","CREATE INDEX \\"idx_transaction_account\\" ON \\"public\\".\\"transaction\\" USING \\"btree\\" (\\"account_id\\")","CREATE INDEX \\"idx_transaction_category_analysis\\" ON \\"public\\".\\"transaction\\" USING \\"btree\\" (\\"user_id\\", \\"category_id\\", \\"transaction_date\\")","CREATE INDEX \\"idx_transaction_date\\" ON \\"public\\".\\"transaction\\" USING \\"btree\\" (\\"transaction_date\\")","CREATE INDEX \\"idx_transaction_date_analysis\\" ON \\"public\\".\\"transaction\\" USING \\"btree\\" (\\"user_id\\", \\"transaction_date\\") INCLUDE (\\"amount\\")","CREATE INDEX \\"idx_transaction_jar\\" ON \\"public\\".\\"transaction\\" USING \\"btree\\" (\\"jar_id\\")","CREATE INDEX \\"idx_transaction_jar_analysis\\" ON \\"public\\".\\"transaction\\" USING \\"btree\\" (\\"user_id\\", \\"jar_id\\", \\"transaction_date\\")","CREATE INDEX \\"idx_transaction_notes_search\\" ON \\"public\\".\\"transaction\\" USING \\"gin\\" (\\"to_tsvector\\"('\\"spanish\\"'::\\"regconfig\\", COALESCE(\\"notes\\", ''::\\"text\\")))","CREATE INDEX \\"idx_transaction_recurring\\" ON \\"public\\".\\"transaction\\" USING \\"btree\\" (\\"parent_recurring_id\\") WHERE (\\"parent_recurring_id\\" IS NOT NULL)","CREATE INDEX \\"idx_transaction_sync\\" ON \\"public\\".\\"transaction\\" USING \\"btree\\" (\\"sync_status\\")","CREATE INDEX \\"idx_transaction_tags\\" ON \\"public\\".\\"transaction\\" USING \\"gin\\" (\\"tags\\")","CREATE INDEX \\"idx_transaction_type\\" ON \\"public\\".\\"transaction\\" USING \\"btree\\" (\\"transaction_type_id\\")","CREATE INDEX \\"idx_transaction_type_active\\" ON \\"public\\".\\"transaction_type\\" USING \\"btree\\" (\\"id\\") WHERE (\\"is_active\\" = true)","CREATE INDEX \\"idx_transaction_type_name\\" ON \\"public\\".\\"transaction_type\\" USING \\"btree\\" (\\"name\\")","CREATE INDEX \\"idx_transaction_user\\" ON \\"public\\".\\"transaction\\" USING \\"btree\\" (\\"user_id\\")","CREATE INDEX \\"idx_transfer_accounts\\" ON \\"public\\".\\"transfer\\" USING \\"btree\\" (\\"from_account_id\\", \\"to_account_id\\") WHERE ((\\"transfer_type\\")::\\"text\\" = 'ACCOUNT_TO_ACCOUNT'::\\"text\\")","CREATE INDEX \\"idx_transfer_date\\" ON \\"public\\".\\"transfer\\" USING \\"btree\\" (\\"transfer_date\\")","CREATE INDEX \\"idx_transfer_jars\\" ON \\"public\\".\\"transfer\\" USING \\"btree\\" (\\"from_jar_id\\", \\"to_jar_id\\") WHERE ((\\"transfer_type\\")::\\"text\\" = ANY ((ARRAY['JAR_TO_JAR'::character varying, 'PERIOD_ROLLOVER'::character varying])::\\"text\\"[]))","CREATE INDEX \\"idx_transfer_sync\\" ON \\"public\\".\\"transfer\\" USING \\"btree\\" (\\"sync_status\\")","CREATE INDEX \\"idx_transfer_user\\" ON \\"public\\".\\"transfer\\" USING \\"btree\\" (\\"user_id\\")","CREATE OR REPLACE TRIGGER \\"after_transfer_notification\\" AFTER INSERT ON \\"public\\".\\"transfer\\" FOR EACH ROW EXECUTE FUNCTION \\"public\\".\\"notify_transfer\\"()","CREATE OR REPLACE TRIGGER \\"record_transaction_history\\" AFTER INSERT ON \\"public\\".\\"transaction\\" FOR EACH ROW EXECUTE FUNCTION \\"public\\".\\"record_balance_history\\"()","CREATE OR REPLACE TRIGGER \\"record_transfer_history\\" AFTER INSERT ON \\"public\\".\\"transfer\\" FOR EACH ROW EXECUTE FUNCTION \\"public\\".\\"record_balance_history\\"()","CREATE OR REPLACE TRIGGER \\"track_interest_rate_changes_trigger\\" AFTER UPDATE OF \\"current_interest_rate\\" ON \\"public\\".\\"credit_card_details\\" FOR EACH ROW EXECUTE FUNCTION \\"public\\".\\"track_interest_rate_changes\\"()","CREATE OR REPLACE TRIGGER \\"update_balances_on_transaction\\" AFTER INSERT ON \\"public\\".\\"transaction\\" FOR EACH ROW EXECUTE FUNCTION \\"public\\".\\"update_balances\\"()","CREATE OR REPLACE TRIGGER \\"update_balances_on_transfer\\" AFTER INSERT ON \\"public\\".\\"transfer\\" FOR EACH ROW EXECUTE FUNCTION \\"public\\".\\"update_balances\\"()","CREATE OR REPLACE TRIGGER \\"update_goals_after_transaction\\" AFTER INSERT OR UPDATE ON \\"public\\".\\"transaction\\" FOR EACH ROW EXECUTE FUNCTION \\"public\\".\\"update_goal_from_transaction\\"()","CREATE OR REPLACE TRIGGER \\"update_modified_timestamp\\" BEFORE UPDATE ON \\"public\\".\\"account\\" FOR EACH ROW EXECUTE FUNCTION \\"public\\".\\"update_modified_timestamp\\"()","CREATE OR REPLACE TRIGGER \\"update_modified_timestamp\\" BEFORE UPDATE ON \\"public\\".\\"account_type\\" FOR EACH ROW EXECUTE FUNCTION \\"public\\".\\"update_modified_timestamp\\"()","CREATE OR REPLACE TRIGGER \\"update_modified_timestamp\\" BEFORE UPDATE ON \\"public\\".\\"app_user\\" FOR EACH ROW EXECUTE FUNCTION \\"public\\".\\"update_modified_timestamp\\"()","CREATE OR REPLACE TRIGGER \\"update_modified_timestamp\\" BEFORE UPDATE ON \\"public\\".\\"category\\" FOR EACH ROW EXECUTE FUNCTION \\"public\\".\\"update_modified_timestamp\\"()","CREATE OR REPLACE TRIGGER \\"update_modified_timestamp\\" BEFORE UPDATE ON \\"public\\".\\"currency\\" FOR EACH ROW EXECUTE FUNCTION \\"public\\".\\"update_modified_timestamp\\"()","CREATE OR REPLACE TRIGGER \\"update_modified_timestamp\\" BEFORE UPDATE ON \\"public\\".\\"financial_goal\\" FOR EACH ROW EXECUTE FUNCTION \\"public\\".\\"update_modified_timestamp\\"()","CREATE OR REPLACE TRIGGER \\"update_modified_timestamp\\" BEFORE UPDATE ON \\"public\\".\\"jar\\" FOR EACH ROW EXECUTE FUNCTION \\"public\\".\\"update_modified_timestamp\\"()","CREATE OR REPLACE TRIGGER \\"update_modified_timestamp\\" BEFORE UPDATE ON \\"public\\".\\"jar_balance\\" FOR EACH ROW EXECUTE FUNCTION \\"public\\".\\"update_modified_timestamp\\"()","CREATE OR REPLACE TRIGGER \\"update_modified_timestamp\\" BEFORE UPDATE ON \\"public\\".\\"recurring_transaction\\" FOR EACH ROW EXECUTE FUNCTION \\"public\\".\\"update_modified_timestamp\\"()","CREATE OR REPLACE TRIGGER \\"update_modified_timestamp\\" BEFORE UPDATE ON \\"public\\".\\"subcategory\\" FOR EACH ROW EXECUTE FUNCTION \\"public\\".\\"update_modified_timestamp\\"()","CREATE OR REPLACE TRIGGER \\"update_modified_timestamp\\" BEFORE UPDATE ON \\"public\\".\\"transaction\\" FOR EACH ROW EXECUTE FUNCTION \\"public\\".\\"update_modified_timestamp\\"()","CREATE OR REPLACE TRIGGER \\"update_modified_timestamp\\" BEFORE UPDATE ON \\"public\\".\\"transaction_medium\\" FOR EACH ROW EXECUTE FUNCTION \\"public\\".\\"update_modified_timestamp\\"()","CREATE OR REPLACE TRIGGER \\"update_modified_timestamp\\" BEFORE UPDATE ON \\"public\\".\\"transaction_type\\" FOR EACH ROW EXECUTE FUNCTION \\"public\\".\\"update_modified_timestamp\\"()","CREATE OR REPLACE TRIGGER \\"update_modified_timestamp\\" BEFORE UPDATE ON \\"public\\".\\"transfer\\" FOR EACH ROW EXECUTE FUNCTION \\"public\\".\\"update_modified_timestamp\\"()","CREATE OR REPLACE TRIGGER \\"validate_credit_card_transaction_trigger\\" BEFORE INSERT ON \\"public\\".\\"transaction\\" FOR EACH ROW EXECUTE FUNCTION \\"public\\".\\"validate_credit_card_transaction\\"()","CREATE OR REPLACE TRIGGER \\"validate_jar_requirement\\" BEFORE INSERT OR UPDATE ON \\"public\\".\\"subcategory\\" FOR EACH ROW EXECUTE FUNCTION \\"public\\".\\"check_jar_requirement\\"()","CREATE OR REPLACE TRIGGER \\"validate_recurring_transaction_jar_requirement\\" BEFORE INSERT OR UPDATE ON \\"public\\".\\"recurring_transaction\\" FOR EACH ROW EXECUTE FUNCTION \\"public\\".\\"check_recurring_transaction_jar_requirement\\"()","CREATE OR REPLACE TRIGGER \\"validate_transaction_balance\\" BEFORE INSERT OR UPDATE ON \\"public\\".\\"transaction\\" FOR EACH ROW EXECUTE FUNCTION \\"public\\".\\"validate_sufficient_balance\\"()","CREATE OR REPLACE TRIGGER \\"validate_transaction_jar_requirement\\" BEFORE INSERT OR UPDATE ON \\"public\\".\\"transaction\\" FOR EACH ROW EXECUTE FUNCTION \\"public\\".\\"check_transaction_jar_requirement\\"()","CREATE OR REPLACE TRIGGER \\"validate_transfer_balance\\" BEFORE INSERT OR UPDATE ON \\"public\\".\\"transfer\\" FOR EACH ROW EXECUTE FUNCTION \\"public\\".\\"validate_sufficient_balance\\"()","ALTER TABLE ONLY \\"public\\".\\"account\\"\n    ADD CONSTRAINT \\"account_account_type_id_fkey\\" FOREIGN KEY (\\"account_type_id\\") REFERENCES \\"public\\".\\"account_type\\"(\\"id\\")","ALTER TABLE ONLY \\"public\\".\\"account\\"\n    ADD CONSTRAINT \\"account_currency_id_fkey\\" FOREIGN KEY (\\"currency_id\\") REFERENCES \\"public\\".\\"currency\\"(\\"id\\")","ALTER TABLE ONLY \\"public\\".\\"account\\"\n    ADD CONSTRAINT \\"account_user_id_fkey\\" FOREIGN KEY (\\"user_id\\") REFERENCES \\"public\\".\\"app_user\\"(\\"id\\")","ALTER TABLE ONLY \\"public\\".\\"app_user\\"\n    ADD CONSTRAINT \\"app_user_default_currency_id_fkey\\" FOREIGN KEY (\\"default_currency_id\\") REFERENCES \\"public\\".\\"currency\\"(\\"id\\")","ALTER TABLE ONLY \\"public\\".\\"app_user\\"\n    ADD CONSTRAINT \\"app_user_id_fkey\\" FOREIGN KEY (\\"id\\") REFERENCES \\"auth\\".\\"users\\"(\\"id\\")","ALTER TABLE ONLY \\"public\\".\\"balance_history\\"\n    ADD CONSTRAINT \\"balance_history_account_id_fkey\\" FOREIGN KEY (\\"account_id\\") REFERENCES \\"public\\".\\"account\\"(\\"id\\")","ALTER TABLE ONLY \\"public\\".\\"balance_history\\"\n    ADD CONSTRAINT \\"balance_history_jar_id_fkey\\" FOREIGN KEY (\\"jar_id\\") REFERENCES \\"public\\".\\"jar\\"(\\"id\\")","ALTER TABLE ONLY \\"public\\".\\"balance_history\\"\n    ADD CONSTRAINT \\"balance_history_user_id_fkey\\" FOREIGN KEY (\\"user_id\\") REFERENCES \\"public\\".\\"app_user\\"(\\"id\\")","ALTER TABLE ONLY \\"public\\".\\"category\\"\n    ADD CONSTRAINT \\"category_transaction_type_id_fkey\\" FOREIGN KEY (\\"transaction_type_id\\") REFERENCES \\"public\\".\\"transaction_type\\"(\\"id\\")","ALTER TABLE ONLY \\"public\\".\\"credit_card_details\\"\n    ADD CONSTRAINT \\"credit_card_details_account_id_fkey\\" FOREIGN KEY (\\"account_id\\") REFERENCES \\"public\\".\\"account\\"(\\"id\\")","ALTER TABLE ONLY \\"public\\".\\"credit_card_interest_history\\"\n    ADD CONSTRAINT \\"credit_card_interest_history_credit_card_id_fkey\\" FOREIGN KEY (\\"credit_card_id\\") REFERENCES \\"public\\".\\"credit_card_details\\"(\\"id\\")","ALTER TABLE ONLY \\"public\\".\\"credit_card_statement\\"\n    ADD CONSTRAINT \\"credit_card_statement_credit_card_id_fkey\\" FOREIGN KEY (\\"credit_card_id\\") REFERENCES \\"public\\".\\"credit_card_details\\"(\\"id\\")","ALTER TABLE ONLY \\"public\\".\\"financial_goal\\"\n    ADD CONSTRAINT \\"financial_goal_jar_id_fkey\\" FOREIGN KEY (\\"jar_id\\") REFERENCES \\"public\\".\\"jar\\"(\\"id\\")","ALTER TABLE ONLY \\"public\\".\\"financial_goal\\"\n    ADD CONSTRAINT \\"financial_goal_user_id_fkey\\" FOREIGN KEY (\\"user_id\\") REFERENCES \\"public\\".\\"app_user\\"(\\"id\\")","ALTER TABLE ONLY \\"public\\".\\"installment_purchase\\"\n    ADD CONSTRAINT \\"installment_purchase_credit_card_id_fkey\\" FOREIGN KEY (\\"credit_card_id\\") REFERENCES \\"public\\".\\"credit_card_details\\"(\\"id\\")","ALTER TABLE ONLY \\"public\\".\\"installment_purchase\\"\n    ADD CONSTRAINT \\"installment_purchase_transaction_id_fkey\\" FOREIGN KEY (\\"transaction_id\\") REFERENCES \\"public\\".\\"transaction\\"(\\"id\\")","ALTER TABLE ONLY \\"public\\".\\"jar_balance\\"\n    ADD CONSTRAINT \\"jar_balance_jar_id_fkey\\" FOREIGN KEY (\\"jar_id\\") REFERENCES \\"public\\".\\"jar\\"(\\"id\\")","ALTER TABLE ONLY \\"public\\".\\"jar_balance\\"\n    ADD CONSTRAINT \\"jar_balance_user_id_fkey\\" FOREIGN KEY (\\"user_id\\") REFERENCES \\"public\\".\\"app_user\\"(\\"id\\")","ALTER TABLE ONLY \\"public\\".\\"notification\\"\n    ADD CONSTRAINT \\"notification_user_id_fkey\\" FOREIGN KEY (\\"user_id\\") REFERENCES \\"public\\".\\"app_user\\"(\\"id\\")","ALTER TABLE ONLY \\"public\\".\\"recurring_transaction\\"\n    ADD CONSTRAINT \\"recurring_transaction_account_id_fkey\\" FOREIGN KEY (\\"account_id\\") REFERENCES \\"public\\".\\"account\\"(\\"id\\")","ALTER TABLE ONLY \\"public\\".\\"recurring_transaction\\"\n    ADD CONSTRAINT \\"recurring_transaction_category_id_fkey\\" FOREIGN KEY (\\"category_id\\") REFERENCES \\"public\\".\\"category\\"(\\"id\\")","ALTER TABLE ONLY \\"public\\".\\"recurring_transaction\\"\n    ADD CONSTRAINT \\"recurring_transaction_jar_id_fkey\\" FOREIGN KEY (\\"jar_id\\") REFERENCES \\"public\\".\\"jar\\"(\\"id\\")","ALTER TABLE ONLY \\"public\\".\\"recurring_transaction\\"\n    ADD CONSTRAINT \\"recurring_transaction_subcategory_id_fkey\\" FOREIGN KEY (\\"subcategory_id\\") REFERENCES \\"public\\".\\"subcategory\\"(\\"id\\")","ALTER TABLE ONLY \\"public\\".\\"recurring_transaction\\"\n    ADD CONSTRAINT \\"recurring_transaction_transaction_medium_id_fkey\\" FOREIGN KEY (\\"transaction_medium_id\\") REFERENCES \\"public\\".\\"transaction_medium\\"(\\"id\\")","ALTER TABLE ONLY \\"public\\".\\"recurring_transaction\\"\n    ADD CONSTRAINT \\"recurring_transaction_transaction_type_id_fkey\\" FOREIGN KEY (\\"transaction_type_id\\") REFERENCES \\"public\\".\\"transaction_type\\"(\\"id\\")","ALTER TABLE ONLY \\"public\\".\\"recurring_transaction\\"\n    ADD CONSTRAINT \\"recurring_transaction_user_id_fkey\\" FOREIGN KEY (\\"user_id\\") REFERENCES \\"public\\".\\"app_user\\"(\\"id\\")","ALTER TABLE ONLY \\"public\\".\\"subcategory\\"\n    ADD CONSTRAINT \\"subcategory_category_id_fkey\\" FOREIGN KEY (\\"category_id\\") REFERENCES \\"public\\".\\"category\\"(\\"id\\")","ALTER TABLE ONLY \\"public\\".\\"subcategory\\"\n    ADD CONSTRAINT \\"subcategory_jar_id_fkey\\" FOREIGN KEY (\\"jar_id\\") REFERENCES \\"public\\".\\"jar\\"(\\"id\\")","ALTER TABLE ONLY \\"public\\".\\"transaction\\"\n    ADD CONSTRAINT \\"transaction_account_id_fkey\\" FOREIGN KEY (\\"account_id\\") REFERENCES \\"public\\".\\"account\\"(\\"id\\")","ALTER TABLE ONLY \\"public\\".\\"transaction\\"\n    ADD CONSTRAINT \\"transaction_category_id_fkey\\" FOREIGN KEY (\\"category_id\\") REFERENCES \\"public\\".\\"category\\"(\\"id\\")","ALTER TABLE ONLY \\"public\\".\\"transaction\\"\n    ADD CONSTRAINT \\"transaction_currency_id_fkey\\" FOREIGN KEY (\\"currency_id\\") REFERENCES \\"public\\".\\"currency\\"(\\"id\\")","ALTER TABLE ONLY \\"public\\".\\"transaction\\"\n    ADD CONSTRAINT \\"transaction_installment_purchase_id_fkey\\" FOREIGN KEY (\\"installment_purchase_id\\") REFERENCES \\"public\\".\\"installment_purchase\\"(\\"id\\")","ALTER TABLE ONLY \\"public\\".\\"transaction\\"\n    ADD CONSTRAINT \\"transaction_jar_id_fkey\\" FOREIGN KEY (\\"jar_id\\") REFERENCES \\"public\\".\\"jar\\"(\\"id\\")","ALTER TABLE ONLY \\"public\\".\\"transaction\\"\n    ADD CONSTRAINT \\"transaction_subcategory_id_fkey\\" FOREIGN KEY (\\"subcategory_id\\") REFERENCES \\"public\\".\\"subcategory\\"(\\"id\\")","ALTER TABLE ONLY \\"public\\".\\"transaction\\"\n    ADD CONSTRAINT \\"transaction_transaction_medium_id_fkey\\" FOREIGN KEY (\\"transaction_medium_id\\") REFERENCES \\"public\\".\\"transaction_medium\\"(\\"id\\")","ALTER TABLE ONLY \\"public\\".\\"transaction\\"\n    ADD CONSTRAINT \\"transaction_transaction_type_id_fkey\\" FOREIGN KEY (\\"transaction_type_id\\") REFERENCES \\"public\\".\\"transaction_type\\"(\\"id\\")","ALTER TABLE ONLY \\"public\\".\\"transaction\\"\n    ADD CONSTRAINT \\"transaction_user_id_fkey\\" FOREIGN KEY (\\"user_id\\") REFERENCES \\"public\\".\\"app_user\\"(\\"id\\")","ALTER TABLE ONLY \\"public\\".\\"transfer\\"\n    ADD CONSTRAINT \\"transfer_from_account_id_fkey\\" FOREIGN KEY (\\"from_account_id\\") REFERENCES \\"public\\".\\"account\\"(\\"id\\")","ALTER TABLE ONLY \\"public\\".\\"transfer\\"\n    ADD CONSTRAINT \\"transfer_from_jar_id_fkey\\" FOREIGN KEY (\\"from_jar_id\\") REFERENCES \\"public\\".\\"jar\\"(\\"id\\")","ALTER TABLE ONLY \\"public\\".\\"transfer\\"\n    ADD CONSTRAINT \\"transfer_to_account_id_fkey\\" FOREIGN KEY (\\"to_account_id\\") REFERENCES \\"public\\".\\"account\\"(\\"id\\")","ALTER TABLE ONLY \\"public\\".\\"transfer\\"\n    ADD CONSTRAINT \\"transfer_to_jar_id_fkey\\" FOREIGN KEY (\\"to_jar_id\\") REFERENCES \\"public\\".\\"jar\\"(\\"id\\")","ALTER TABLE ONLY \\"public\\".\\"transfer\\"\n    ADD CONSTRAINT \\"transfer_user_id_fkey\\" FOREIGN KEY (\\"user_id\\") REFERENCES \\"public\\".\\"app_user\\"(\\"id\\")","CREATE POLICY \\"Usuarios autenticados pueden leer\\" ON \\"public\\".\\"account_type\\" FOR SELECT USING ((\\"auth\\".\\"role\\"() = 'authenticated'::\\"text\\"))","CREATE POLICY \\"Usuarios autenticados pueden leer\\" ON \\"public\\".\\"category\\" FOR SELECT USING ((\\"auth\\".\\"role\\"() = 'authenticated'::\\"text\\"))","CREATE POLICY \\"Usuarios autenticados pueden leer\\" ON \\"public\\".\\"currency\\" FOR SELECT USING ((\\"auth\\".\\"role\\"() = 'authenticated'::\\"text\\"))","CREATE POLICY \\"Usuarios autenticados pueden leer\\" ON \\"public\\".\\"jar\\" FOR SELECT USING ((\\"auth\\".\\"role\\"() = 'authenticated'::\\"text\\"))","CREATE POLICY \\"Usuarios autenticados pueden leer\\" ON \\"public\\".\\"subcategory\\" FOR SELECT USING ((\\"auth\\".\\"role\\"() = 'authenticated'::\\"text\\"))","CREATE POLICY \\"Usuarios autenticados pueden leer\\" ON \\"public\\".\\"transaction_medium\\" FOR SELECT USING ((\\"auth\\".\\"role\\"() = 'authenticated'::\\"text\\"))","CREATE POLICY \\"Usuarios autenticados pueden leer\\" ON \\"public\\".\\"transaction_type\\" FOR SELECT USING ((\\"auth\\".\\"role\\"() = 'authenticated'::\\"text\\"))","CREATE POLICY \\"Usuarios pueden actualizar categorías\\" ON \\"public\\".\\"category\\" FOR UPDATE USING ((\\"auth\\".\\"role\\"() = 'authenticated'::\\"text\\"))","CREATE POLICY \\"Usuarios pueden actualizar su perfil\\" ON \\"public\\".\\"app_user\\" FOR UPDATE USING ((\\"auth\\".\\"uid\\"() = \\"id\\"))","CREATE POLICY \\"Usuarios pueden actualizar subcategorías\\" ON \\"public\\".\\"subcategory\\" FOR UPDATE USING ((\\"auth\\".\\"role\\"() = 'authenticated'::\\"text\\"))","CREATE POLICY \\"Usuarios pueden actualizar sus balances\\" ON \\"public\\".\\"jar_balance\\" FOR UPDATE USING ((\\"auth\\".\\"uid\\"() = \\"user_id\\"))","CREATE POLICY \\"Usuarios pueden actualizar sus cuentas\\" ON \\"public\\".\\"account\\" FOR UPDATE USING ((\\"auth\\".\\"uid\\"() = \\"user_id\\"))","CREATE POLICY \\"Usuarios pueden actualizar sus metas\\" ON \\"public\\".\\"financial_goal\\" FOR UPDATE USING ((\\"auth\\".\\"uid\\"() = \\"user_id\\"))","CREATE POLICY \\"Usuarios pueden actualizar sus notificaciones\\" ON \\"public\\".\\"notification\\" FOR UPDATE USING ((\\"auth\\".\\"uid\\"() = \\"user_id\\"))","CREATE POLICY \\"Usuarios pueden actualizar sus tarjetas\\" ON \\"public\\".\\"credit_card_details\\" FOR UPDATE USING ((\\"auth\\".\\"uid\\"() = ( SELECT \\"account\\".\\"user_id\\"\n   FROM \\"public\\".\\"account\\"\n  WHERE (\\"account\\".\\"id\\" = \\"credit_card_details\\".\\"account_id\\"))))","CREATE POLICY \\"Usuarios pueden actualizar sus transacciones\\" ON \\"public\\".\\"transaction\\" FOR UPDATE USING ((\\"auth\\".\\"uid\\"() = \\"user_id\\"))","CREATE POLICY \\"Usuarios pueden actualizar sus transacciones recurrentes\\" ON \\"public\\".\\"recurring_transaction\\" FOR UPDATE USING ((\\"auth\\".\\"uid\\"() = \\"user_id\\"))","CREATE POLICY \\"Usuarios pueden actualizar sus transferencias\\" ON \\"public\\".\\"transfer\\" FOR UPDATE USING ((\\"auth\\".\\"uid\\"() = \\"user_id\\"))","CREATE POLICY \\"Usuarios pueden crear balances\\" ON \\"public\\".\\"jar_balance\\" FOR INSERT WITH CHECK ((\\"auth\\".\\"uid\\"() = \\"user_id\\"))","CREATE POLICY \\"Usuarios pueden crear categorías\\" ON \\"public\\".\\"category\\" FOR INSERT WITH CHECK ((\\"auth\\".\\"role\\"() = 'authenticated'::\\"text\\"))","CREATE POLICY \\"Usuarios pueden crear cuentas\\" ON \\"public\\".\\"account\\" FOR INSERT WITH CHECK ((\\"auth\\".\\"uid\\"() = \\"user_id\\"))","CREATE POLICY \\"Usuarios pueden crear metas\\" ON \\"public\\".\\"financial_goal\\" FOR INSERT WITH CHECK ((\\"auth\\".\\"uid\\"() = \\"user_id\\"))","CREATE POLICY \\"Usuarios pueden crear registros históricos\\" ON \\"public\\".\\"balance_history\\" FOR INSERT WITH CHECK ((\\"auth\\".\\"uid\\"() = \\"user_id\\"))","CREATE POLICY \\"Usuarios pueden crear subcategorías\\" ON \\"public\\".\\"subcategory\\" FOR INSERT WITH CHECK ((\\"auth\\".\\"role\\"() = 'authenticated'::\\"text\\"))","CREATE POLICY \\"Usuarios pueden crear transacciones\\" ON \\"public\\".\\"transaction\\" FOR INSERT WITH CHECK ((\\"auth\\".\\"uid\\"() = \\"user_id\\"))","CREATE POLICY \\"Usuarios pueden crear transacciones recurrentes\\" ON \\"public\\".\\"recurring_transaction\\" FOR INSERT WITH CHECK ((\\"auth\\".\\"uid\\"() = \\"user_id\\"))","CREATE POLICY \\"Usuarios pueden crear transferencias\\" ON \\"public\\".\\"transfer\\" FOR INSERT WITH CHECK ((\\"auth\\".\\"uid\\"() = \\"user_id\\"))","CREATE POLICY \\"Usuarios pueden eliminar categorías\\" ON \\"public\\".\\"category\\" FOR DELETE USING ((\\"auth\\".\\"role\\"() = 'authenticated'::\\"text\\"))","CREATE POLICY \\"Usuarios pueden eliminar subcategorías\\" ON \\"public\\".\\"subcategory\\" FOR DELETE USING ((\\"auth\\".\\"role\\"() = 'authenticated'::\\"text\\"))","CREATE POLICY \\"Usuarios pueden ver estados de cuenta\\" ON \\"public\\".\\"credit_card_statement\\" FOR SELECT USING ((\\"auth\\".\\"uid\\"() = ( SELECT \\"a\\".\\"user_id\\"\n   FROM (\\"public\\".\\"account\\" \\"a\\"\n     JOIN \\"public\\".\\"credit_card_details\\" \\"cc\\" ON ((\\"cc\\".\\"account_id\\" = \\"a\\".\\"id\\")))\n  WHERE (\\"cc\\".\\"id\\" = \\"credit_card_statement\\".\\"credit_card_id\\"))))","CREATE POLICY \\"Usuarios pueden ver historial de sus tarjetas\\" ON \\"public\\".\\"credit_card_interest_history\\" FOR SELECT USING ((\\"auth\\".\\"uid\\"() = ( SELECT \\"a\\".\\"user_id\\"\n   FROM (\\"public\\".\\"account\\" \\"a\\"\n     JOIN \\"public\\".\\"credit_card_details\\" \\"cc\\" ON ((\\"cc\\".\\"account_id\\" = \\"a\\".\\"id\\")))\n  WHERE (\\"cc\\".\\"id\\" = \\"credit_card_interest_history\\".\\"credit_card_id\\"))))","CREATE POLICY \\"Usuarios pueden ver su historial\\" ON \\"public\\".\\"balance_history\\" FOR SELECT USING ((\\"auth\\".\\"uid\\"() = \\"user_id\\"))","CREATE POLICY \\"Usuarios pueden ver su perfil\\" ON \\"public\\".\\"app_user\\" FOR SELECT USING ((\\"auth\\".\\"uid\\"() = \\"id\\"))","CREATE POLICY \\"Usuarios pueden ver sus MSI\\" ON \\"public\\".\\"installment_purchase\\" FOR SELECT USING ((\\"auth\\".\\"uid\\"() = ( SELECT \\"a\\".\\"user_id\\"\n   FROM (\\"public\\".\\"account\\" \\"a\\"\n     JOIN \\"public\\".\\"credit_card_details\\" \\"cc\\" ON ((\\"cc\\".\\"account_id\\" = \\"a\\".\\"id\\")))\n  WHERE (\\"cc\\".\\"id\\" = \\"installment_purchase\\".\\"credit_card_id\\"))))","CREATE POLICY \\"Usuarios pueden ver sus balances\\" ON \\"public\\".\\"jar_balance\\" FOR SELECT USING ((\\"auth\\".\\"uid\\"() = \\"user_id\\"))","CREATE POLICY \\"Usuarios pueden ver sus cuentas\\" ON \\"public\\".\\"account\\" FOR SELECT USING ((\\"auth\\".\\"uid\\"() = \\"user_id\\"))","CREATE POLICY \\"Usuarios pueden ver sus metas\\" ON \\"public\\".\\"financial_goal\\" FOR SELECT USING ((\\"auth\\".\\"uid\\"() = \\"user_id\\"))","CREATE POLICY \\"Usuarios pueden ver sus notificaciones\\" ON \\"public\\".\\"notification\\" FOR SELECT USING ((\\"auth\\".\\"uid\\"() = \\"user_id\\"))","CREATE POLICY \\"Usuarios pueden ver sus tarjetas\\" ON \\"public\\".\\"credit_card_details\\" FOR SELECT USING ((\\"auth\\".\\"uid\\"() = ( SELECT \\"account\\".\\"user_id\\"\n   FROM \\"public\\".\\"account\\"\n  WHERE (\\"account\\".\\"id\\" = \\"credit_card_details\\".\\"account_id\\"))))","CREATE POLICY \\"Usuarios pueden ver sus transacciones\\" ON \\"public\\".\\"transaction\\" FOR SELECT USING ((\\"auth\\".\\"uid\\"() = \\"user_id\\"))","CREATE POLICY \\"Usuarios pueden ver sus transacciones recurrentes\\" ON \\"public\\".\\"recurring_transaction\\" FOR SELECT USING ((\\"auth\\".\\"uid\\"() = \\"user_id\\"))","CREATE POLICY \\"Usuarios pueden ver sus transferencias\\" ON \\"public\\".\\"transfer\\" FOR SELECT USING ((\\"auth\\".\\"uid\\"() = \\"user_id\\"))","ALTER TABLE \\"public\\".\\"account\\" ENABLE ROW LEVEL SECURITY","ALTER TABLE \\"public\\".\\"account_type\\" ENABLE ROW LEVEL SECURITY","ALTER TABLE \\"public\\".\\"app_user\\" ENABLE ROW LEVEL SECURITY","ALTER TABLE \\"public\\".\\"balance_history\\" ENABLE ROW LEVEL SECURITY","ALTER TABLE \\"public\\".\\"category\\" ENABLE ROW LEVEL SECURITY","ALTER TABLE \\"public\\".\\"credit_card_details\\" ENABLE ROW LEVEL SECURITY","ALTER TABLE \\"public\\".\\"credit_card_interest_history\\" ENABLE ROW LEVEL SECURITY","ALTER TABLE \\"public\\".\\"credit_card_statement\\" ENABLE ROW LEVEL SECURITY","ALTER TABLE \\"public\\".\\"currency\\" ENABLE ROW LEVEL SECURITY","ALTER TABLE \\"public\\".\\"financial_goal\\" ENABLE ROW LEVEL SECURITY","ALTER TABLE \\"public\\".\\"installment_purchase\\" ENABLE ROW LEVEL SECURITY","ALTER TABLE \\"public\\".\\"jar\\" ENABLE ROW LEVEL SECURITY","ALTER TABLE \\"public\\".\\"jar_balance\\" ENABLE ROW LEVEL SECURITY","ALTER TABLE \\"public\\".\\"notification\\" ENABLE ROW LEVEL SECURITY","ALTER TABLE \\"public\\".\\"recurring_transaction\\" ENABLE ROW LEVEL SECURITY","ALTER TABLE \\"public\\".\\"subcategory\\" ENABLE ROW LEVEL SECURITY","ALTER TABLE \\"public\\".\\"transaction\\" ENABLE ROW LEVEL SECURITY","ALTER TABLE \\"public\\".\\"transaction_medium\\" ENABLE ROW LEVEL SECURITY","ALTER TABLE \\"public\\".\\"transaction_type\\" ENABLE ROW LEVEL SECURITY","ALTER TABLE \\"public\\".\\"transfer\\" ENABLE ROW LEVEL SECURITY","ALTER PUBLICATION \\"supabase_realtime\\" OWNER TO \\"postgres\\"","GRANT USAGE ON SCHEMA \\"public\\" TO \\"postgres\\"","GRANT USAGE ON SCHEMA \\"public\\" TO \\"anon\\"","GRANT USAGE ON SCHEMA \\"public\\" TO \\"authenticated\\"","GRANT USAGE ON SCHEMA \\"public\\" TO \\"service_role\\"","GRANT ALL ON FUNCTION \\"public\\".\\"analyze_financial_goal\\"(\\"p_goal_id\\" \\"uuid\\") TO \\"anon\\"","GRANT ALL ON FUNCTION \\"public\\".\\"analyze_financial_goal\\"(\\"p_goal_id\\" \\"uuid\\") TO \\"authenticated\\"","GRANT ALL ON FUNCTION \\"public\\".\\"analyze_financial_goal\\"(\\"p_goal_id\\" \\"uuid\\") TO \\"service_role\\"","GRANT ALL ON FUNCTION \\"public\\".\\"analyze_jar_distribution\\"(\\"p_user_id\\" \\"uuid\\", \\"p_start_date\\" \\"date\\", \\"p_end_date\\" \\"date\\") TO \\"anon\\"","GRANT ALL ON FUNCTION \\"public\\".\\"analyze_jar_distribution\\"(\\"p_user_id\\" \\"uuid\\", \\"p_start_date\\" \\"date\\", \\"p_end_date\\" \\"date\\") TO \\"authenticated\\"","GRANT ALL ON FUNCTION \\"public\\".\\"analyze_jar_distribution\\"(\\"p_user_id\\" \\"uuid\\", \\"p_start_date\\" \\"date\\", \\"p_end_date\\" \\"date\\") TO \\"service_role\\"","GRANT ALL ON FUNCTION \\"public\\".\\"analyze_transactions_by_category\\"(\\"p_user_id\\" \\"uuid\\", \\"p_start_date\\" \\"date\\", \\"p_end_date\\" \\"date\\", \\"p_transaction_type\\" \\"text\\") TO \\"anon\\"","GRANT ALL ON FUNCTION \\"public\\".\\"analyze_transactions_by_category\\"(\\"p_user_id\\" \\"uuid\\", \\"p_start_date\\" \\"date\\", \\"p_end_date\\" \\"date\\", \\"p_transaction_type\\" \\"text\\") TO \\"authenticated\\"","GRANT ALL ON FUNCTION \\"public\\".\\"analyze_transactions_by_category\\"(\\"p_user_id\\" \\"uuid\\", \\"p_start_date\\" \\"date\\", \\"p_end_date\\" \\"date\\", \\"p_transaction_type\\" \\"text\\") TO \\"service_role\\"","GRANT ALL ON FUNCTION \\"public\\".\\"archive_completed_goals\\"(\\"p_days_threshold\\" integer) TO \\"anon\\"","GRANT ALL ON FUNCTION \\"public\\".\\"archive_completed_goals\\"(\\"p_days_threshold\\" integer) TO \\"authenticated\\"","GRANT ALL ON FUNCTION \\"public\\".\\"archive_completed_goals\\"(\\"p_days_threshold\\" integer) TO \\"service_role\\"","GRANT ALL ON FUNCTION \\"public\\".\\"calculate_goal_progress\\"(\\"p_current_amount\\" numeric, \\"p_target_amount\\" numeric, \\"p_start_date\\" \\"date\\", \\"p_target_date\\" \\"date\\") TO \\"anon\\"","GRANT ALL ON FUNCTION \\"public\\".\\"calculate_goal_progress\\"(\\"p_current_amount\\" numeric, \\"p_target_amount\\" numeric, \\"p_start_date\\" \\"date\\", \\"p_target_date\\" \\"date\\") TO \\"authenticated\\"","GRANT ALL ON FUNCTION \\"public\\".\\"calculate_goal_progress\\"(\\"p_current_amount\\" numeric, \\"p_target_amount\\" numeric, \\"p_start_date\\" \\"date\\", \\"p_target_date\\" \\"date\\") TO \\"service_role\\"","GRANT ALL ON FUNCTION \\"public\\".\\"calculate_next_cut_off_date\\"(\\"p_cut_off_day\\" integer, \\"p_from_date\\" \\"date\\") TO \\"anon\\"","GRANT ALL ON FUNCTION \\"public\\".\\"calculate_next_cut_off_date\\"(\\"p_cut_off_day\\" integer, \\"p_from_date\\" \\"date\\") TO \\"authenticated\\"","GRANT ALL ON FUNCTION \\"public\\".\\"calculate_next_cut_off_date\\"(\\"p_cut_off_day\\" integer, \\"p_from_date\\" \\"date\\") TO \\"service_role\\"","GRANT ALL ON FUNCTION \\"public\\".\\"calculate_next_execution_date\\"(\\"p_frequency\\" character varying, \\"p_start_date\\" \\"date\\", \\"p_last_execution\\" \\"date\\") TO \\"anon\\"","GRANT ALL ON FUNCTION \\"public\\".\\"calculate_next_execution_date\\"(\\"p_frequency\\" character varying, \\"p_start_date\\" \\"date\\", \\"p_last_execution\\" \\"date\\") TO \\"authenticated\\"","GRANT ALL ON FUNCTION \\"public\\".\\"calculate_next_execution_date\\"(\\"p_frequency\\" character varying, \\"p_start_date\\" \\"date\\", \\"p_last_execution\\" \\"date\\") TO \\"service_role\\"","GRANT ALL ON FUNCTION \\"public\\".\\"calculate_next_payment_date\\"(\\"p_payment_day\\" integer, \\"p_cut_off_date\\" \\"date\\") TO \\"anon\\"","GRANT ALL ON FUNCTION \\"public\\".\\"calculate_next_payment_date\\"(\\"p_payment_day\\" integer, \\"p_cut_off_date\\" \\"date\\") TO \\"authenticated\\"","GRANT ALL ON FUNCTION \\"public\\".\\"calculate_next_payment_date\\"(\\"p_payment_day\\" integer, \\"p_cut_off_date\\" \\"date\\") TO \\"service_role\\"","GRANT ALL ON FUNCTION \\"public\\".\\"check_available_balance_for_transfer\\"(\\"p_user_id\\" \\"uuid\\", \\"p_account_id\\" \\"uuid\\", \\"p_jar_id\\" \\"uuid\\") TO \\"anon\\"","GRANT ALL ON FUNCTION \\"public\\".\\"check_available_balance_for_transfer\\"(\\"p_user_id\\" \\"uuid\\", \\"p_account_id\\" \\"uuid\\", \\"p_jar_id\\" \\"uuid\\") TO \\"authenticated\\"","GRANT ALL ON FUNCTION \\"public\\".\\"check_available_balance_for_transfer\\"(\\"p_user_id\\" \\"uuid\\", \\"p_account_id\\" \\"uuid\\", \\"p_jar_id\\" \\"uuid\\") TO \\"service_role\\"","GRANT ALL ON FUNCTION \\"public\\".\\"check_jar_requirement\\"() TO \\"anon\\"","GRANT ALL ON FUNCTION \\"public\\".\\"check_jar_requirement\\"() TO \\"authenticated\\"","GRANT ALL ON FUNCTION \\"public\\".\\"check_jar_requirement\\"() TO \\"service_role\\"","GRANT ALL ON FUNCTION \\"public\\".\\"check_recurring_transaction_jar_requirement\\"() TO \\"anon\\"","GRANT ALL ON FUNCTION \\"public\\".\\"check_recurring_transaction_jar_requirement\\"() TO \\"authenticated\\"","GRANT ALL ON FUNCTION \\"public\\".\\"check_recurring_transaction_jar_requirement\\"() TO \\"service_role\\"","GRANT ALL ON FUNCTION \\"public\\".\\"check_transaction_jar_requirement\\"() TO \\"anon\\"","GRANT ALL ON FUNCTION \\"public\\".\\"check_transaction_jar_requirement\\"() TO \\"authenticated\\"","GRANT ALL ON FUNCTION \\"public\\".\\"check_transaction_jar_requirement\\"() TO \\"service_role\\"","GRANT ALL ON FUNCTION \\"public\\".\\"execute_account_transfer\\"(\\"p_user_id\\" \\"uuid\\", \\"p_from_account_id\\" \\"uuid\\", \\"p_to_account_id\\" \\"uuid\\", \\"p_amount\\" numeric, \\"p_exchange_rate\\" numeric, \\"p_description\\" \\"text\\") TO \\"anon\\"","GRANT ALL ON FUNCTION \\"public\\".\\"execute_account_transfer\\"(\\"p_user_id\\" \\"uuid\\", \\"p_from_account_id\\" \\"uuid\\", \\"p_to_account_id\\" \\"uuid\\", \\"p_amount\\" numeric, \\"p_exchange_rate\\" numeric, \\"p_description\\" \\"text\\") TO \\"authenticated\\"","GRANT ALL ON FUNCTION \\"public\\".\\"execute_account_transfer\\"(\\"p_user_id\\" \\"uuid\\", \\"p_from_account_id\\" \\"uuid\\", \\"p_to_account_id\\" \\"uuid\\", \\"p_amount\\" numeric, \\"p_exchange_rate\\" numeric, \\"p_description\\" \\"text\\") TO \\"service_role\\"","GRANT ALL ON FUNCTION \\"public\\".\\"execute_jar_transfer\\"(\\"p_user_id\\" \\"uuid\\", \\"p_from_jar_id\\" \\"uuid\\", \\"p_to_jar_id\\" \\"uuid\\", \\"p_amount\\" numeric, \\"p_description\\" \\"text\\", \\"p_is_rollover\\" boolean) TO \\"anon\\"","GRANT ALL ON FUNCTION \\"public\\".\\"execute_jar_transfer\\"(\\"p_user_id\\" \\"uuid\\", \\"p_from_jar_id\\" \\"uuid\\", \\"p_to_jar_id\\" \\"uuid\\", \\"p_amount\\" numeric, \\"p_description\\" \\"text\\", \\"p_is_rollover\\" boolean) TO \\"authenticated\\"","GRANT ALL ON FUNCTION \\"public\\".\\"execute_jar_transfer\\"(\\"p_user_id\\" \\"uuid\\", \\"p_from_jar_id\\" \\"uuid\\", \\"p_to_jar_id\\" \\"uuid\\", \\"p_amount\\" numeric, \\"p_description\\" \\"text\\", \\"p_is_rollover\\" boolean) TO \\"service_role\\"","GRANT ALL ON FUNCTION \\"public\\".\\"export_jar_status_to_excel\\"(\\"p_user_id\\" \\"uuid\\") TO \\"anon\\"","GRANT ALL ON FUNCTION \\"public\\".\\"export_jar_status_to_excel\\"(\\"p_user_id\\" \\"uuid\\") TO \\"authenticated\\"","GRANT ALL ON FUNCTION \\"public\\".\\"export_jar_status_to_excel\\"(\\"p_user_id\\" \\"uuid\\") TO \\"service_role\\"","GRANT ALL ON FUNCTION \\"public\\".\\"export_transactions_to_excel\\"(\\"p_user_id\\" \\"uuid\\", \\"p_start_date\\" \\"date\\", \\"p_end_date\\" \\"date\\") TO \\"anon\\"","GRANT ALL ON FUNCTION \\"public\\".\\"export_transactions_to_excel\\"(\\"p_user_id\\" \\"uuid\\", \\"p_start_date\\" \\"date\\", \\"p_end_date\\" \\"date\\") TO \\"authenticated\\"","GRANT ALL ON FUNCTION \\"public\\".\\"export_transactions_to_excel\\"(\\"p_user_id\\" \\"uuid\\", \\"p_start_date\\" \\"date\\", \\"p_end_date\\" \\"date\\") TO \\"service_role\\"","GRANT ALL ON FUNCTION \\"public\\".\\"generate_credit_card_statement\\"(\\"p_credit_card_id\\" \\"uuid\\", \\"p_statement_date\\" \\"date\\") TO \\"anon\\"","GRANT ALL ON FUNCTION \\"public\\".\\"generate_credit_card_statement\\"(\\"p_credit_card_id\\" \\"uuid\\", \\"p_statement_date\\" \\"date\\") TO \\"authenticated\\"","GRANT ALL ON FUNCTION \\"public\\".\\"generate_credit_card_statement\\"(\\"p_credit_card_id\\" \\"uuid\\", \\"p_statement_date\\" \\"date\\") TO \\"service_role\\"","GRANT ALL ON FUNCTION \\"public\\".\\"get_credit_card_statements\\"(\\"p_account_id\\" \\"uuid\\", \\"p_months\\" integer) TO \\"anon\\"","GRANT ALL ON FUNCTION \\"public\\".\\"get_credit_card_statements\\"(\\"p_account_id\\" \\"uuid\\", \\"p_months\\" integer) TO \\"authenticated\\"","GRANT ALL ON FUNCTION \\"public\\".\\"get_credit_card_statements\\"(\\"p_account_id\\" \\"uuid\\", \\"p_months\\" integer) TO \\"service_role\\"","GRANT ALL ON FUNCTION \\"public\\".\\"get_credit_card_summary\\"(\\"p_account_id\\" \\"uuid\\") TO \\"anon\\"","GRANT ALL ON FUNCTION \\"public\\".\\"get_credit_card_summary\\"(\\"p_account_id\\" \\"uuid\\") TO \\"authenticated\\"","GRANT ALL ON FUNCTION \\"public\\".\\"get_credit_card_summary\\"(\\"p_account_id\\" \\"uuid\\") TO \\"service_role\\"","GRANT ALL ON FUNCTION \\"public\\".\\"get_goals_summary\\"(\\"p_user_id\\" \\"uuid\\") TO \\"anon\\"","GRANT ALL ON FUNCTION \\"public\\".\\"get_goals_summary\\"(\\"p_user_id\\" \\"uuid\\") TO \\"authenticated\\"","GRANT ALL ON FUNCTION \\"public\\".\\"get_goals_summary\\"(\\"p_user_id\\" \\"uuid\\") TO \\"service_role\\"","GRANT ALL ON FUNCTION \\"public\\".\\"get_period_summary\\"(\\"p_user_id\\" \\"uuid\\", \\"p_start_date\\" \\"date\\", \\"p_end_date\\" \\"date\\") TO \\"anon\\"","GRANT ALL ON FUNCTION \\"public\\".\\"get_period_summary\\"(\\"p_user_id\\" \\"uuid\\", \\"p_start_date\\" \\"date\\", \\"p_end_date\\" \\"date\\") TO \\"authenticated\\"","GRANT ALL ON FUNCTION \\"public\\".\\"get_period_summary\\"(\\"p_user_id\\" \\"uuid\\", \\"p_start_date\\" \\"date\\", \\"p_end_date\\" \\"date\\") TO \\"service_role\\"","GRANT ALL ON FUNCTION \\"public\\".\\"get_transfer_history\\"(\\"p_user_id\\" \\"uuid\\", \\"p_start_date\\" \\"date\\", \\"p_end_date\\" \\"date\\", \\"p_transfer_type\\" \\"text\\", \\"p_limit\\" integer) TO \\"anon\\"","GRANT ALL ON FUNCTION \\"public\\".\\"get_transfer_history\\"(\\"p_user_id\\" \\"uuid\\", \\"p_start_date\\" \\"date\\", \\"p_end_date\\" \\"date\\", \\"p_transfer_type\\" \\"text\\", \\"p_limit\\" integer) TO \\"authenticated\\"","GRANT ALL ON FUNCTION \\"public\\".\\"get_transfer_history\\"(\\"p_user_id\\" \\"uuid\\", \\"p_start_date\\" \\"date\\", \\"p_end_date\\" \\"date\\", \\"p_transfer_type\\" \\"text\\", \\"p_limit\\" integer) TO \\"service_role\\"","GRANT ALL ON FUNCTION \\"public\\".\\"get_transfer_summary_by_period\\"(\\"p_user_id\\" \\"uuid\\", \\"p_start_date\\" \\"date\\", \\"p_end_date\\" \\"date\\") TO \\"anon\\"","GRANT ALL ON FUNCTION \\"public\\".\\"get_transfer_summary_by_period\\"(\\"p_user_id\\" \\"uuid\\", \\"p_start_date\\" \\"date\\", \\"p_end_date\\" \\"date\\") TO \\"authenticated\\"","GRANT ALL ON FUNCTION \\"public\\".\\"get_transfer_summary_by_period\\"(\\"p_user_id\\" \\"uuid\\", \\"p_start_date\\" \\"date\\", \\"p_end_date\\" \\"date\\") TO \\"service_role\\"","GRANT ALL ON FUNCTION \\"public\\".\\"get_upcoming_recurring_transactions\\"(\\"p_user_id\\" \\"uuid\\", \\"p_days\\" integer) TO \\"anon\\"","GRANT ALL ON FUNCTION \\"public\\".\\"get_upcoming_recurring_transactions\\"(\\"p_user_id\\" \\"uuid\\", \\"p_days\\" integer) TO \\"authenticated\\"","GRANT ALL ON FUNCTION \\"public\\".\\"get_upcoming_recurring_transactions\\"(\\"p_user_id\\" \\"uuid\\", \\"p_days\\" integer) TO \\"service_role\\"","GRANT ALL ON FUNCTION \\"public\\".\\"handle_new_user\\"() TO \\"anon\\"","GRANT ALL ON FUNCTION \\"public\\".\\"handle_new_user\\"() TO \\"authenticated\\"","GRANT ALL ON FUNCTION \\"public\\".\\"handle_new_user\\"() TO \\"service_role\\"","GRANT ALL ON FUNCTION \\"public\\".\\"initialize_system_data\\"() TO \\"anon\\"","GRANT ALL ON FUNCTION \\"public\\".\\"initialize_system_data\\"() TO \\"authenticated\\"","GRANT ALL ON FUNCTION \\"public\\".\\"initialize_system_data\\"() TO \\"service_role\\"","GRANT ALL ON FUNCTION \\"public\\".\\"notify_credit_card_events\\"() TO \\"anon\\"","GRANT ALL ON FUNCTION \\"public\\".\\"notify_credit_card_events\\"() TO \\"authenticated\\"","GRANT ALL ON FUNCTION \\"public\\".\\"notify_credit_card_events\\"() TO \\"service_role\\"","GRANT ALL ON FUNCTION \\"public\\".\\"notify_transfer\\"() TO \\"anon\\"","GRANT ALL ON FUNCTION \\"public\\".\\"notify_transfer\\"() TO \\"authenticated\\"","GRANT ALL ON FUNCTION \\"public\\".\\"notify_transfer\\"() TO \\"service_role\\"","GRANT ALL ON FUNCTION \\"public\\".\\"process_jar_rollover\\"(\\"p_user_id\\" \\"uuid\\") TO \\"anon\\"","GRANT ALL ON FUNCTION \\"public\\".\\"process_jar_rollover\\"(\\"p_user_id\\" \\"uuid\\") TO \\"authenticated\\"","GRANT ALL ON FUNCTION \\"public\\".\\"process_jar_rollover\\"(\\"p_user_id\\" \\"uuid\\") TO \\"service_role\\"","GRANT ALL ON FUNCTION \\"public\\".\\"process_recurring_transactions\\"(\\"p_date\\" \\"date\\") TO \\"anon\\"","GRANT ALL ON FUNCTION \\"public\\".\\"process_recurring_transactions\\"(\\"p_date\\" \\"date\\") TO \\"authenticated\\"","GRANT ALL ON FUNCTION \\"public\\".\\"process_recurring_transactions\\"(\\"p_date\\" \\"date\\") TO \\"service_role\\"","GRANT ALL ON FUNCTION \\"public\\".\\"reactivate_recurring_transaction\\"(\\"p_transaction_id\\" \\"uuid\\", \\"p_new_start_date\\" \\"date\\") TO \\"anon\\"","GRANT ALL ON FUNCTION \\"public\\".\\"reactivate_recurring_transaction\\"(\\"p_transaction_id\\" \\"uuid\\", \\"p_new_start_date\\" \\"date\\") TO \\"authenticated\\"","GRANT ALL ON FUNCTION \\"public\\".\\"reactivate_recurring_transaction\\"(\\"p_transaction_id\\" \\"uuid\\", \\"p_new_start_date\\" \\"date\\") TO \\"service_role\\"","GRANT ALL ON FUNCTION \\"public\\".\\"record_balance_history\\"() TO \\"anon\\"","GRANT ALL ON FUNCTION \\"public\\".\\"record_balance_history\\"() TO \\"authenticated\\"","GRANT ALL ON FUNCTION \\"public\\".\\"record_balance_history\\"() TO \\"service_role\\"","GRANT ALL ON FUNCTION \\"public\\".\\"remove_transaction_tag\\"(\\"p_transaction_id\\" \\"uuid\\", \\"p_tag\\" \\"text\\") TO \\"anon\\"","GRANT ALL ON FUNCTION \\"public\\".\\"remove_transaction_tag\\"(\\"p_transaction_id\\" \\"uuid\\", \\"p_tag\\" \\"text\\") TO \\"authenticated\\"","GRANT ALL ON FUNCTION \\"public\\".\\"remove_transaction_tag\\"(\\"p_transaction_id\\" \\"uuid\\", \\"p_tag\\" \\"text\\") TO \\"service_role\\"","GRANT ALL ON FUNCTION \\"public\\".\\"search_transactions_by_notes\\"(\\"p_user_id\\" \\"uuid\\", \\"p_search_text\\" \\"text\\") TO \\"anon\\"","GRANT ALL ON FUNCTION \\"public\\".\\"search_transactions_by_notes\\"(\\"p_user_id\\" \\"uuid\\", \\"p_search_text\\" \\"text\\") TO \\"authenticated\\"","GRANT ALL ON FUNCTION \\"public\\".\\"search_transactions_by_notes\\"(\\"p_user_id\\" \\"uuid\\", \\"p_search_text\\" \\"text\\") TO \\"service_role\\"","GRANT ALL ON FUNCTION \\"public\\".\\"search_transactions_by_tags\\"(\\"p_user_id\\" \\"uuid\\", \\"p_tags\\" \\"text\\"[]) TO \\"anon\\"","GRANT ALL ON FUNCTION \\"public\\".\\"search_transactions_by_tags\\"(\\"p_user_id\\" \\"uuid\\", \\"p_tags\\" \\"text\\"[]) TO \\"authenticated\\"","GRANT ALL ON FUNCTION \\"public\\".\\"search_transactions_by_tags\\"(\\"p_user_id\\" \\"uuid\\", \\"p_tags\\" \\"text\\"[]) TO \\"service_role\\"","GRANT ALL ON FUNCTION \\"public\\".\\"track_interest_rate_changes\\"() TO \\"anon\\"","GRANT ALL ON FUNCTION \\"public\\".\\"track_interest_rate_changes\\"() TO \\"authenticated\\"","GRANT ALL ON FUNCTION \\"public\\".\\"track_interest_rate_changes\\"() TO \\"service_role\\"","GRANT ALL ON FUNCTION \\"public\\".\\"update_balances\\"() TO \\"anon\\"","GRANT ALL ON FUNCTION \\"public\\".\\"update_balances\\"() TO \\"authenticated\\"","GRANT ALL ON FUNCTION \\"public\\".\\"update_balances\\"() TO \\"service_role\\"","GRANT ALL ON FUNCTION \\"public\\".\\"update_goal_from_transaction\\"() TO \\"anon\\"","GRANT ALL ON FUNCTION \\"public\\".\\"update_goal_from_transaction\\"() TO \\"authenticated\\"","GRANT ALL ON FUNCTION \\"public\\".\\"update_goal_from_transaction\\"() TO \\"service_role\\"","GRANT ALL ON FUNCTION \\"public\\".\\"update_goal_progress\\"(\\"p_goal_id\\" \\"uuid\\", \\"p_new_amount\\" numeric) TO \\"anon\\"","GRANT ALL ON FUNCTION \\"public\\".\\"update_goal_progress\\"(\\"p_goal_id\\" \\"uuid\\", \\"p_new_amount\\" numeric) TO \\"authenticated\\"","GRANT ALL ON FUNCTION \\"public\\".\\"update_goal_progress\\"(\\"p_goal_id\\" \\"uuid\\", \\"p_new_amount\\" numeric) TO \\"service_role\\"","GRANT ALL ON FUNCTION \\"public\\".\\"update_installment_purchases\\"() TO \\"anon\\"","GRANT ALL ON FUNCTION \\"public\\".\\"update_installment_purchases\\"() TO \\"authenticated\\"","GRANT ALL ON FUNCTION \\"public\\".\\"update_installment_purchases\\"() TO \\"service_role\\"","GRANT ALL ON FUNCTION \\"public\\".\\"update_modified_timestamp\\"() TO \\"anon\\"","GRANT ALL ON FUNCTION \\"public\\".\\"update_modified_timestamp\\"() TO \\"authenticated\\"","GRANT ALL ON FUNCTION \\"public\\".\\"update_modified_timestamp\\"() TO \\"service_role\\"","GRANT ALL ON FUNCTION \\"public\\".\\"validate_account_transfer\\"(\\"p_user_id\\" \\"uuid\\", \\"p_from_account_id\\" \\"uuid\\", \\"p_to_account_id\\" \\"uuid\\", \\"p_amount\\" numeric, \\"p_exchange_rate\\" numeric) TO \\"anon\\"","GRANT ALL ON FUNCTION \\"public\\".\\"validate_account_transfer\\"(\\"p_user_id\\" \\"uuid\\", \\"p_from_account_id\\" \\"uuid\\", \\"p_to_account_id\\" \\"uuid\\", \\"p_amount\\" numeric, \\"p_exchange_rate\\" numeric) TO \\"authenticated\\"","GRANT ALL ON FUNCTION \\"public\\".\\"validate_account_transfer\\"(\\"p_user_id\\" \\"uuid\\", \\"p_from_account_id\\" \\"uuid\\", \\"p_to_account_id\\" \\"uuid\\", \\"p_amount\\" numeric, \\"p_exchange_rate\\" numeric) TO \\"service_role\\"","GRANT ALL ON FUNCTION \\"public\\".\\"validate_credit_card_transaction\\"() TO \\"anon\\"","GRANT ALL ON FUNCTION \\"public\\".\\"validate_credit_card_transaction\\"() TO \\"authenticated\\"","GRANT ALL ON FUNCTION \\"public\\".\\"validate_credit_card_transaction\\"() TO \\"service_role\\"","GRANT ALL ON FUNCTION \\"public\\".\\"validate_credit_limit\\"(\\"p_account_id\\" \\"uuid\\", \\"p_amount\\" numeric) TO \\"anon\\"","GRANT ALL ON FUNCTION \\"public\\".\\"validate_credit_limit\\"(\\"p_account_id\\" \\"uuid\\", \\"p_amount\\" numeric) TO \\"authenticated\\"","GRANT ALL ON FUNCTION \\"public\\".\\"validate_credit_limit\\"(\\"p_account_id\\" \\"uuid\\", \\"p_amount\\" numeric) TO \\"service_role\\"","GRANT ALL ON FUNCTION \\"public\\".\\"validate_jar_transfer\\"(\\"p_user_id\\" \\"uuid\\", \\"p_from_jar_id\\" \\"uuid\\", \\"p_to_jar_id\\" \\"uuid\\", \\"p_amount\\" numeric) TO \\"anon\\"","GRANT ALL ON FUNCTION \\"public\\".\\"validate_jar_transfer\\"(\\"p_user_id\\" \\"uuid\\", \\"p_from_jar_id\\" \\"uuid\\", \\"p_to_jar_id\\" \\"uuid\\", \\"p_amount\\" numeric) TO \\"authenticated\\"","GRANT ALL ON FUNCTION \\"public\\".\\"validate_jar_transfer\\"(\\"p_user_id\\" \\"uuid\\", \\"p_from_jar_id\\" \\"uuid\\", \\"p_to_jar_id\\" \\"uuid\\", \\"p_amount\\" numeric) TO \\"service_role\\"","GRANT ALL ON FUNCTION \\"public\\".\\"validate_recurring_transaction\\"(\\"p_user_id\\" \\"uuid\\", \\"p_amount\\" numeric, \\"p_transaction_type_id\\" \\"uuid\\", \\"p_account_id\\" \\"uuid\\", \\"p_jar_id\\" \\"uuid\\") TO \\"anon\\"","GRANT ALL ON FUNCTION \\"public\\".\\"validate_recurring_transaction\\"(\\"p_user_id\\" \\"uuid\\", \\"p_amount\\" numeric, \\"p_transaction_type_id\\" \\"uuid\\", \\"p_account_id\\" \\"uuid\\", \\"p_jar_id\\" \\"uuid\\") TO \\"authenticated\\"","GRANT ALL ON FUNCTION \\"public\\".\\"validate_recurring_transaction\\"(\\"p_user_id\\" \\"uuid\\", \\"p_amount\\" numeric, \\"p_transaction_type_id\\" \\"uuid\\", \\"p_account_id\\" \\"uuid\\", \\"p_jar_id\\" \\"uuid\\") TO \\"service_role\\"","GRANT ALL ON FUNCTION \\"public\\".\\"validate_sufficient_balance\\"() TO \\"anon\\"","GRANT ALL ON FUNCTION \\"public\\".\\"validate_sufficient_balance\\"() TO \\"authenticated\\"","GRANT ALL ON FUNCTION \\"public\\".\\"validate_sufficient_balance\\"() TO \\"service_role\\"","GRANT ALL ON TABLE \\"public\\".\\"account\\" TO \\"anon\\"","GRANT ALL ON TABLE \\"public\\".\\"account\\" TO \\"authenticated\\"","GRANT ALL ON TABLE \\"public\\".\\"account\\" TO \\"service_role\\"","GRANT ALL ON TABLE \\"public\\".\\"account_type\\" TO \\"anon\\"","GRANT ALL ON TABLE \\"public\\".\\"account_type\\" TO \\"authenticated\\"","GRANT ALL ON TABLE \\"public\\".\\"account_type\\" TO \\"service_role\\"","GRANT ALL ON TABLE \\"public\\".\\"app_user\\" TO \\"anon\\"","GRANT ALL ON TABLE \\"public\\".\\"app_user\\" TO \\"authenticated\\"","GRANT ALL ON TABLE \\"public\\".\\"app_user\\" TO \\"service_role\\"","GRANT ALL ON TABLE \\"public\\".\\"balance_history\\" TO \\"anon\\"","GRANT ALL ON TABLE \\"public\\".\\"balance_history\\" TO \\"authenticated\\"","GRANT ALL ON TABLE \\"public\\".\\"balance_history\\" TO \\"service_role\\"","GRANT ALL ON TABLE \\"public\\".\\"category\\" TO \\"anon\\"","GRANT ALL ON TABLE \\"public\\".\\"category\\" TO \\"authenticated\\"","GRANT ALL ON TABLE \\"public\\".\\"category\\" TO \\"service_role\\"","GRANT ALL ON TABLE \\"public\\".\\"credit_card_details\\" TO \\"anon\\"","GRANT ALL ON TABLE \\"public\\".\\"credit_card_details\\" TO \\"authenticated\\"","GRANT ALL ON TABLE \\"public\\".\\"credit_card_details\\" TO \\"service_role\\"","GRANT ALL ON TABLE \\"public\\".\\"credit_card_interest_history\\" TO \\"anon\\"","GRANT ALL ON TABLE \\"public\\".\\"credit_card_interest_history\\" TO \\"authenticated\\"","GRANT ALL ON TABLE \\"public\\".\\"credit_card_interest_history\\" TO \\"service_role\\"","GRANT ALL ON TABLE \\"public\\".\\"credit_card_statement\\" TO \\"anon\\"","GRANT ALL ON TABLE \\"public\\".\\"credit_card_statement\\" TO \\"authenticated\\"","GRANT ALL ON TABLE \\"public\\".\\"credit_card_statement\\" TO \\"service_role\\"","GRANT ALL ON TABLE \\"public\\".\\"currency\\" TO \\"anon\\"","GRANT ALL ON TABLE \\"public\\".\\"currency\\" TO \\"authenticated\\"","GRANT ALL ON TABLE \\"public\\".\\"currency\\" TO \\"service_role\\"","GRANT ALL ON TABLE \\"public\\".\\"transaction\\" TO \\"anon\\"","GRANT ALL ON TABLE \\"public\\".\\"transaction\\" TO \\"authenticated\\"","GRANT ALL ON TABLE \\"public\\".\\"transaction\\" TO \\"service_role\\"","GRANT ALL ON TABLE \\"public\\".\\"transaction_type\\" TO \\"anon\\"","GRANT ALL ON TABLE \\"public\\".\\"transaction_type\\" TO \\"authenticated\\"","GRANT ALL ON TABLE \\"public\\".\\"transaction_type\\" TO \\"service_role\\"","GRANT ALL ON TABLE \\"public\\".\\"expense_trends_analysis\\" TO \\"anon\\"","GRANT ALL ON TABLE \\"public\\".\\"expense_trends_analysis\\" TO \\"authenticated\\"","GRANT ALL ON TABLE \\"public\\".\\"expense_trends_analysis\\" TO \\"service_role\\"","GRANT ALL ON TABLE \\"public\\".\\"financial_goal\\" TO \\"anon\\"","GRANT ALL ON TABLE \\"public\\".\\"financial_goal\\" TO \\"authenticated\\"","GRANT ALL ON TABLE \\"public\\".\\"financial_goal\\" TO \\"service_role\\"","GRANT ALL ON TABLE \\"public\\".\\"jar\\" TO \\"anon\\"","GRANT ALL ON TABLE \\"public\\".\\"jar\\" TO \\"authenticated\\"","GRANT ALL ON TABLE \\"public\\".\\"jar\\" TO \\"service_role\\"","GRANT ALL ON TABLE \\"public\\".\\"goal_progress_summary\\" TO \\"anon\\"","GRANT ALL ON TABLE \\"public\\".\\"goal_progress_summary\\" TO \\"authenticated\\"","GRANT ALL ON TABLE \\"public\\".\\"goal_progress_summary\\" TO \\"service_role\\"","GRANT ALL ON TABLE \\"public\\".\\"installment_purchase\\" TO \\"anon\\"","GRANT ALL ON TABLE \\"public\\".\\"installment_purchase\\" TO \\"authenticated\\"","GRANT ALL ON TABLE \\"public\\".\\"installment_purchase\\" TO \\"service_role\\"","GRANT ALL ON TABLE \\"public\\".\\"jar_balance\\" TO \\"anon\\"","GRANT ALL ON TABLE \\"public\\".\\"jar_balance\\" TO \\"authenticated\\"","GRANT ALL ON TABLE \\"public\\".\\"jar_balance\\" TO \\"service_role\\"","GRANT ALL ON TABLE \\"public\\".\\"methodology_compliance_analysis\\" TO \\"anon\\"","GRANT ALL ON TABLE \\"public\\".\\"methodology_compliance_analysis\\" TO \\"authenticated\\"","GRANT ALL ON TABLE \\"public\\".\\"methodology_compliance_analysis\\" TO \\"service_role\\"","GRANT ALL ON TABLE \\"public\\".\\"notification\\" TO \\"anon\\"","GRANT ALL ON TABLE \\"public\\".\\"notification\\" TO \\"authenticated\\"","GRANT ALL ON TABLE \\"public\\".\\"notification\\" TO \\"service_role\\"","GRANT ALL ON TABLE \\"public\\".\\"recurring_transaction\\" TO \\"anon\\"","GRANT ALL ON TABLE \\"public\\".\\"recurring_transaction\\" TO \\"authenticated\\"","GRANT ALL ON TABLE \\"public\\".\\"recurring_transaction\\" TO \\"service_role\\"","GRANT ALL ON TABLE \\"public\\".\\"schema_migrations\\" TO \\"anon\\"","GRANT ALL ON TABLE \\"public\\".\\"schema_migrations\\" TO \\"authenticated\\"","GRANT ALL ON TABLE \\"public\\".\\"schema_migrations\\" TO \\"service_role\\"","GRANT ALL ON TABLE \\"public\\".\\"subcategory\\" TO \\"anon\\"","GRANT ALL ON TABLE \\"public\\".\\"subcategory\\" TO \\"authenticated\\"","GRANT ALL ON TABLE \\"public\\".\\"subcategory\\" TO \\"service_role\\"","GRANT ALL ON TABLE \\"public\\".\\"transaction_medium\\" TO \\"anon\\"","GRANT ALL ON TABLE \\"public\\".\\"transaction_medium\\" TO \\"authenticated\\"","GRANT ALL ON TABLE \\"public\\".\\"transaction_medium\\" TO \\"service_role\\"","GRANT ALL ON TABLE \\"public\\".\\"transfer\\" TO \\"anon\\"","GRANT ALL ON TABLE \\"public\\".\\"transfer\\" TO \\"authenticated\\"","GRANT ALL ON TABLE \\"public\\".\\"transfer\\" TO \\"service_role\\"","GRANT ALL ON TABLE \\"public\\".\\"transfer_summary\\" TO \\"anon\\"","GRANT ALL ON TABLE \\"public\\".\\"transfer_summary\\" TO \\"authenticated\\"","GRANT ALL ON TABLE \\"public\\".\\"transfer_summary\\" TO \\"service_role\\"","GRANT ALL ON TABLE \\"public\\".\\"transfer_analysis\\" TO \\"anon\\"","GRANT ALL ON TABLE \\"public\\".\\"transfer_analysis\\" TO \\"authenticated\\"","GRANT ALL ON TABLE \\"public\\".\\"transfer_analysis\\" TO \\"service_role\\"","ALTER DEFAULT PRIVILEGES FOR ROLE \\"postgres\\" IN SCHEMA \\"public\\" GRANT ALL ON SEQUENCES  TO \\"postgres\\"","ALTER DEFAULT PRIVILEGES FOR ROLE \\"postgres\\" IN SCHEMA \\"public\\" GRANT ALL ON SEQUENCES  TO \\"anon\\"","ALTER DEFAULT PRIVILEGES FOR ROLE \\"postgres\\" IN SCHEMA \\"public\\" GRANT ALL ON SEQUENCES  TO \\"authenticated\\"","ALTER DEFAULT PRIVILEGES FOR ROLE \\"postgres\\" IN SCHEMA \\"public\\" GRANT ALL ON SEQUENCES  TO \\"service_role\\"","ALTER DEFAULT PRIVILEGES FOR ROLE \\"postgres\\" IN SCHEMA \\"public\\" GRANT ALL ON FUNCTIONS  TO \\"postgres\\"","ALTER DEFAULT PRIVILEGES FOR ROLE \\"postgres\\" IN SCHEMA \\"public\\" GRANT ALL ON FUNCTIONS  TO \\"anon\\"","ALTER DEFAULT PRIVILEGES FOR ROLE \\"postgres\\" IN SCHEMA \\"public\\" GRANT ALL ON FUNCTIONS  TO \\"authenticated\\"","ALTER DEFAULT PRIVILEGES FOR ROLE \\"postgres\\" IN SCHEMA \\"public\\" GRANT ALL ON FUNCTIONS  TO \\"service_role\\"","ALTER DEFAULT PRIVILEGES FOR ROLE \\"postgres\\" IN SCHEMA \\"public\\" GRANT ALL ON TABLES  TO \\"postgres\\"","ALTER DEFAULT PRIVILEGES FOR ROLE \\"postgres\\" IN SCHEMA \\"public\\" GRANT ALL ON TABLES  TO \\"anon\\"","ALTER DEFAULT PRIVILEGES FOR ROLE \\"postgres\\" IN SCHEMA \\"public\\" GRANT ALL ON TABLES  TO \\"authenticated\\"","ALTER DEFAULT PRIVILEGES FOR ROLE \\"postgres\\" IN SCHEMA \\"public\\" GRANT ALL ON TABLES  TO \\"service_role\\"","RESET ALL"}	remote_schema
20250124123045	{"drop trigger if exists \\"validate_recurring_transaction_jar_requirement\\" on \\"public\\".\\"recurring_transaction\\"","drop trigger if exists \\"validate_jar_requirement\\" on \\"public\\".\\"subcategory\\"","drop trigger if exists \\"validate_transaction_jar_requirement\\" on \\"public\\".\\"transaction\\"","alter table \\"public\\".\\"transaction\\" drop constraint \\"transaction_jar_id_fkey\\"","alter table \\"public\\".\\"balance_history\\" drop constraint \\"balance_history_change_type_check\\"","alter table \\"public\\".\\"credit_card_statement\\" drop constraint \\"credit_card_statement_status_check\\"","alter table \\"public\\".\\"financial_goal\\" drop constraint \\"financial_goal_status_check\\"","alter table \\"public\\".\\"installment_purchase\\" drop constraint \\"installment_purchase_status_check\\"","alter table \\"public\\".\\"notification\\" drop constraint \\"notification_notification_type_check\\"","alter table \\"public\\".\\"notification\\" drop constraint \\"notification_urgency_level_check\\"","alter table \\"public\\".\\"recurring_transaction\\" drop constraint \\"recurring_transaction_frequency_check\\"","alter table \\"public\\".\\"transaction\\" drop constraint \\"transaction_sync_status_check\\"","alter table \\"public\\".\\"transfer\\" drop constraint \\"transfer_sync_status_check\\"","alter table \\"public\\".\\"transfer\\" drop constraint \\"transfer_transfer_type_check\\"","drop function if exists \\"public\\".\\"check_jar_requirement\\"()","drop function if exists \\"public\\".\\"check_recurring_transaction_jar_requirement\\"()","drop function if exists \\"public\\".\\"check_transaction_jar_requirement\\"()","drop view if exists \\"public\\".\\"methodology_compliance_analysis\\"","drop view if exists \\"public\\".\\"expense_trends_analysis\\"","drop index if exists \\"public\\".\\"idx_transaction_jar\\"","drop index if exists \\"public\\".\\"idx_transaction_jar_analysis\\"","drop index if exists \\"public\\".\\"idx_transfer_jars\\"","alter table \\"public\\".\\"transaction\\" drop column \\"jar_id\\"","CREATE INDEX idx_transfer_jars ON public.transfer USING btree (from_jar_id, to_jar_id) WHERE ((transfer_type)::text = ANY ((ARRAY['JAR_TO_JAR'::character varying, 'PERIOD_ROLLOVER'::character varying])::text[]))","alter table \\"public\\".\\"balance_history\\" add constraint \\"balance_history_change_type_check\\" CHECK (((change_type)::text = ANY ((ARRAY['TRANSACTION'::character varying, 'TRANSFER'::character varying, 'ADJUSTMENT'::character varying, 'ROLLOVER'::character varying])::text[]))) not valid","alter table \\"public\\".\\"balance_history\\" validate constraint \\"balance_history_change_type_check\\"","alter table \\"public\\".\\"credit_card_statement\\" add constraint \\"credit_card_statement_status_check\\" CHECK (((status)::text = ANY ((ARRAY['PENDING'::character varying, 'PAID_MINIMUM'::character varying, 'PAID_FULL'::character varying])::text[]))) not valid","alter table \\"public\\".\\"credit_card_statement\\" validate constraint \\"credit_card_statement_status_check\\"","alter table \\"public\\".\\"financial_goal\\" add constraint \\"financial_goal_status_check\\" CHECK (((status)::text = ANY ((ARRAY['IN_PROGRESS'::character varying, 'COMPLETED'::character varying, 'CANCELLED'::character varying])::text[]))) not valid","alter table \\"public\\".\\"financial_goal\\" validate constraint \\"financial_goal_status_check\\"","alter table \\"public\\".\\"installment_purchase\\" add constraint \\"installment_purchase_status_check\\" CHECK (((status)::text = ANY ((ARRAY['ACTIVE'::character varying, 'COMPLETED'::character varying, 'CANCELLED'::character varying])::text[]))) not valid","alter table \\"public\\".\\"installment_purchase\\" validate constraint \\"installment_purchase_status_check\\"","alter table \\"public\\".\\"notification\\" add constraint \\"notification_notification_type_check\\" CHECK (((notification_type)::text = ANY ((ARRAY['RECURRING_TRANSACTION'::character varying, 'INSUFFICIENT_FUNDS'::character varying, 'GOAL_PROGRESS'::character varying, 'SYNC_ERROR'::character varying, 'SYSTEM'::character varying, 'CREDIT_CARD_DUE_DATE'::character varying, 'CREDIT_CARD_CUT_OFF'::character varying, 'CREDIT_CARD_LIMIT'::character varying, 'CREDIT_CARD_MINIMUM_PAYMENT'::character varying])::text[]))) not valid","alter table \\"public\\".\\"notification\\" validate constraint \\"notification_notification_type_check\\"","alter table \\"public\\".\\"notification\\" add constraint \\"notification_urgency_level_check\\" CHECK (((urgency_level)::text = ANY ((ARRAY['LOW'::character varying, 'MEDIUM'::character varying, 'HIGH'::character varying])::text[]))) not valid","alter table \\"public\\".\\"notification\\" validate constraint \\"notification_urgency_level_check\\"","alter table \\"public\\".\\"recurring_transaction\\" add constraint \\"recurring_transaction_frequency_check\\" CHECK (((frequency)::text = ANY ((ARRAY['WEEKLY'::character varying, 'MONTHLY'::character varying, 'YEARLY'::character varying])::text[]))) not valid","alter table \\"public\\".\\"recurring_transaction\\" validate constraint \\"recurring_transaction_frequency_check\\"","alter table \\"public\\".\\"transaction\\" add constraint \\"transaction_sync_status_check\\" CHECK (((sync_status)::text = ANY ((ARRAY['PENDING'::character varying, 'SYNCED'::character varying, 'ERROR'::character varying])::text[]))) not valid","alter table \\"public\\".\\"transaction\\" validate constraint \\"transaction_sync_status_check\\"","alter table \\"public\\".\\"transfer\\" add constraint \\"transfer_sync_status_check\\" CHECK (((sync_status)::text = ANY ((ARRAY['PENDING'::character varying, 'SYNCED'::character varying, 'ERROR'::character varying])::text[]))) not valid","alter table \\"public\\".\\"transfer\\" validate constraint \\"transfer_sync_status_check\\"","alter table \\"public\\".\\"transfer\\" add constraint \\"transfer_transfer_type_check\\" CHECK (((transfer_type)::text = ANY ((ARRAY['ACCOUNT_TO_ACCOUNT'::character varying, 'JAR_TO_JAR'::character varying, 'PERIOD_ROLLOVER'::character varying])::text[]))) not valid","alter table \\"public\\".\\"transfer\\" validate constraint \\"transfer_transfer_type_check\\"","set check_function_bodies = off","CREATE OR REPLACE FUNCTION public.analyze_jar_distribution(p_user_id uuid, p_start_date date DEFAULT NULL::date, p_end_date date DEFAULT NULL::date)\n RETURNS SETOF jar_distribution_summary\n LANGUAGE plpgsql\nAS $function$\r\nDECLARE\r\n    v_total_income numeric(15,2);\r\nBEGIN\r\n    -- Get total income for the period\r\n    SELECT COALESCE(sum(amount), 0) INTO v_total_income\r\n    FROM public.transaction t\r\n    JOIN public.transaction_type tt ON tt.id = t.transaction_type_id\r\n    WHERE t.user_id = p_user_id\r\n    AND tt.code = 'INCOME'\r\n    AND (p_start_date IS NULL OR t.transaction_date >= p_start_date)\r\n    AND (p_end_date IS NULL OR t.transaction_date <= p_end_date);\r\n\r\n    -- Return jar analysis using subcategory.jar_id\r\n    RETURN QUERY\r\n    WITH jar_totals AS (\r\n        SELECT \r\n            j.id,\r\n            j.name as jar_name,\r\n            j.target_percentage,\r\n            COALESCE(sum(t.amount), 0) as total_amount\r\n        FROM public.jar j\r\n        LEFT JOIN public.subcategory sc ON sc.jar_id = j.id\r\n        LEFT JOIN public.transaction t ON t.subcategory_id = sc.id\r\n        WHERE (p_start_date IS NULL OR t.transaction_date >= p_start_date)\r\n        AND (p_end_date IS NULL OR t.transaction_date <= p_end_date)\r\n        AND (t.user_id = p_user_id OR t.user_id IS NULL)\r\n        GROUP BY j.id, j.name, j.target_percentage\r\n    )\r\n    SELECT \r\n        jar_name,\r\n        CASE \r\n            WHEN v_total_income > 0 THEN round((total_amount / v_total_income) * 100, 2)\r\n            ELSE 0\r\n        END as current_percentage,\r\n        target_percentage,\r\n        CASE \r\n            WHEN v_total_income > 0 THEN round((total_amount / v_total_income) * 100 - target_percentage, 2)\r\n            ELSE -target_percentage\r\n        END as difference,\r\n        CASE \r\n            WHEN v_total_income > 0 THEN \r\n                abs((total_amount / v_total_income) * 100 - target_percentage) <= 2\r\n            ELSE false\r\n        END as is_compliant\r\n    FROM jar_totals\r\n    ORDER BY target_percentage DESC;\r\nEND;\r\n$function$","create or replace view \\"public\\".\\"expense_trends_analysis\\" as  WITH monthly_expenses AS (\n         SELECT t.user_id,\n            date_trunc('month'::text, (t.transaction_date)::timestamp with time zone) AS month,\n            c.name AS category_name,\n            sum(t.amount) AS total_amount,\n            count(*) AS transaction_count\n           FROM ((transaction t\n             JOIN transaction_type tt ON ((tt.id = t.transaction_type_id)))\n             JOIN category c ON ((c.id = t.category_id)))\n          WHERE (tt.name = 'Gasto'::text)\n          GROUP BY t.user_id, (date_trunc('month'::text, (t.transaction_date)::timestamp with time zone)), c.name\n        )\n SELECT monthly_expenses.user_id,\n    monthly_expenses.month,\n    monthly_expenses.category_name,\n    monthly_expenses.total_amount,\n    monthly_expenses.transaction_count,\n    lag(monthly_expenses.total_amount) OVER (PARTITION BY monthly_expenses.user_id, monthly_expenses.category_name ORDER BY monthly_expenses.month) AS prev_month_amount,\n    round((((monthly_expenses.total_amount - lag(monthly_expenses.total_amount) OVER (PARTITION BY monthly_expenses.user_id, monthly_expenses.category_name ORDER BY monthly_expenses.month)) / NULLIF(lag(monthly_expenses.total_amount) OVER (PARTITION BY monthly_expenses.user_id, monthly_expenses.category_name ORDER BY monthly_expenses.month), (0)::numeric)) * (100)::numeric), 2) AS month_over_month_change,\n    avg(monthly_expenses.total_amount) OVER (PARTITION BY monthly_expenses.user_id, monthly_expenses.category_name ORDER BY monthly_expenses.month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS three_month_moving_avg\n   FROM monthly_expenses"}	remote_schema
20250124123358	{"alter table \\"public\\".\\"balance_history\\" drop constraint \\"balance_history_change_type_check\\"","alter table \\"public\\".\\"credit_card_statement\\" drop constraint \\"credit_card_statement_status_check\\"","alter table \\"public\\".\\"financial_goal\\" drop constraint \\"financial_goal_status_check\\"","alter table \\"public\\".\\"installment_purchase\\" drop constraint \\"installment_purchase_status_check\\"","alter table \\"public\\".\\"notification\\" drop constraint \\"notification_notification_type_check\\"","alter table \\"public\\".\\"notification\\" drop constraint \\"notification_urgency_level_check\\"","alter table \\"public\\".\\"recurring_transaction\\" drop constraint \\"recurring_transaction_frequency_check\\"","alter table \\"public\\".\\"transaction\\" drop constraint \\"transaction_sync_status_check\\"","alter table \\"public\\".\\"transfer\\" drop constraint \\"transfer_sync_status_check\\"","alter table \\"public\\".\\"transfer\\" drop constraint \\"transfer_transfer_type_check\\"","drop index if exists \\"public\\".\\"idx_transfer_jars\\"","CREATE INDEX idx_transfer_jars ON public.transfer USING btree (from_jar_id, to_jar_id) WHERE ((transfer_type)::text = ANY ((ARRAY['JAR_TO_JAR'::character varying, 'PERIOD_ROLLOVER'::character varying])::text[]))","alter table \\"public\\".\\"balance_history\\" add constraint \\"balance_history_change_type_check\\" CHECK (((change_type)::text = ANY ((ARRAY['TRANSACTION'::character varying, 'TRANSFER'::character varying, 'ADJUSTMENT'::character varying, 'ROLLOVER'::character varying])::text[]))) not valid","alter table \\"public\\".\\"balance_history\\" validate constraint \\"balance_history_change_type_check\\"","alter table \\"public\\".\\"credit_card_statement\\" add constraint \\"credit_card_statement_status_check\\" CHECK (((status)::text = ANY ((ARRAY['PENDING'::character varying, 'PAID_MINIMUM'::character varying, 'PAID_FULL'::character varying])::text[]))) not valid","alter table \\"public\\".\\"credit_card_statement\\" validate constraint \\"credit_card_statement_status_check\\"","alter table \\"public\\".\\"financial_goal\\" add constraint \\"financial_goal_status_check\\" CHECK (((status)::text = ANY ((ARRAY['IN_PROGRESS'::character varying, 'COMPLETED'::character varying, 'CANCELLED'::character varying])::text[]))) not valid","alter table \\"public\\".\\"financial_goal\\" validate constraint \\"financial_goal_status_check\\"","alter table \\"public\\".\\"installment_purchase\\" add constraint \\"installment_purchase_status_check\\" CHECK (((status)::text = ANY ((ARRAY['ACTIVE'::character varying, 'COMPLETED'::character varying, 'CANCELLED'::character varying])::text[]))) not valid","alter table \\"public\\".\\"installment_purchase\\" validate constraint \\"installment_purchase_status_check\\"","alter table \\"public\\".\\"notification\\" add constraint \\"notification_notification_type_check\\" CHECK (((notification_type)::text = ANY ((ARRAY['RECURRING_TRANSACTION'::character varying, 'INSUFFICIENT_FUNDS'::character varying, 'GOAL_PROGRESS'::character varying, 'SYNC_ERROR'::character varying, 'SYSTEM'::character varying, 'CREDIT_CARD_DUE_DATE'::character varying, 'CREDIT_CARD_CUT_OFF'::character varying, 'CREDIT_CARD_LIMIT'::character varying, 'CREDIT_CARD_MINIMUM_PAYMENT'::character varying])::text[]))) not valid","alter table \\"public\\".\\"notification\\" validate constraint \\"notification_notification_type_check\\"","alter table \\"public\\".\\"notification\\" add constraint \\"notification_urgency_level_check\\" CHECK (((urgency_level)::text = ANY ((ARRAY['LOW'::character varying, 'MEDIUM'::character varying, 'HIGH'::character varying])::text[]))) not valid","alter table \\"public\\".\\"notification\\" validate constraint \\"notification_urgency_level_check\\"","alter table \\"public\\".\\"recurring_transaction\\" add constraint \\"recurring_transaction_frequency_check\\" CHECK (((frequency)::text = ANY ((ARRAY['WEEKLY'::character varying, 'MONTHLY'::character varying, 'YEARLY'::character varying])::text[]))) not valid","alter table \\"public\\".\\"recurring_transaction\\" validate constraint \\"recurring_transaction_frequency_check\\"","alter table \\"public\\".\\"transaction\\" add constraint \\"transaction_sync_status_check\\" CHECK (((sync_status)::text = ANY ((ARRAY['PENDING'::character varying, 'SYNCED'::character varying, 'ERROR'::character varying])::text[]))) not valid","alter table \\"public\\".\\"transaction\\" validate constraint \\"transaction_sync_status_check\\"","alter table \\"public\\".\\"transfer\\" add constraint \\"transfer_sync_status_check\\" CHECK (((sync_status)::text = ANY ((ARRAY['PENDING'::character varying, 'SYNCED'::character varying, 'ERROR'::character varying])::text[]))) not valid","alter table \\"public\\".\\"transfer\\" validate constraint \\"transfer_sync_status_check\\"","alter table \\"public\\".\\"transfer\\" add constraint \\"transfer_transfer_type_check\\" CHECK (((transfer_type)::text = ANY ((ARRAY['ACCOUNT_TO_ACCOUNT'::character varying, 'JAR_TO_JAR'::character varying, 'PERIOD_ROLLOVER'::character varying])::text[]))) not valid","alter table \\"public\\".\\"transfer\\" validate constraint \\"transfer_transfer_type_check\\""}	remote_schema
20250124190720	{"alter table \\"public\\".\\"balance_history\\" drop constraint \\"balance_history_change_type_check\\"","alter table \\"public\\".\\"credit_card_statement\\" drop constraint \\"credit_card_statement_status_check\\"","alter table \\"public\\".\\"financial_goal\\" drop constraint \\"financial_goal_status_check\\"","alter table \\"public\\".\\"installment_purchase\\" drop constraint \\"installment_purchase_status_check\\"","alter table \\"public\\".\\"notification\\" drop constraint \\"notification_notification_type_check\\"","alter table \\"public\\".\\"notification\\" drop constraint \\"notification_urgency_level_check\\"","alter table \\"public\\".\\"recurring_transaction\\" drop constraint \\"recurring_transaction_frequency_check\\"","alter table \\"public\\".\\"transaction\\" drop constraint \\"transaction_sync_status_check\\"","alter table \\"public\\".\\"transfer\\" drop constraint \\"transfer_sync_status_check\\"","alter table \\"public\\".\\"transfer\\" drop constraint \\"transfer_transfer_type_check\\"","drop index if exists \\"public\\".\\"idx_transfer_jars\\"","CREATE INDEX idx_transfer_jars ON public.transfer USING btree (from_jar_id, to_jar_id) WHERE ((transfer_type)::text = ANY ((ARRAY['JAR_TO_JAR'::character varying, 'PERIOD_ROLLOVER'::character varying])::text[]))","alter table \\"public\\".\\"balance_history\\" add constraint \\"balance_history_change_type_check\\" CHECK (((change_type)::text = ANY ((ARRAY['TRANSACTION'::character varying, 'TRANSFER'::character varying, 'ADJUSTMENT'::character varying, 'ROLLOVER'::character varying])::text[]))) not valid","alter table \\"public\\".\\"balance_history\\" validate constraint \\"balance_history_change_type_check\\"","alter table \\"public\\".\\"credit_card_statement\\" add constraint \\"credit_card_statement_status_check\\" CHECK (((status)::text = ANY ((ARRAY['PENDING'::character varying, 'PAID_MINIMUM'::character varying, 'PAID_FULL'::character varying])::text[]))) not valid","alter table \\"public\\".\\"credit_card_statement\\" validate constraint \\"credit_card_statement_status_check\\"","alter table \\"public\\".\\"financial_goal\\" add constraint \\"financial_goal_status_check\\" CHECK (((status)::text = ANY ((ARRAY['IN_PROGRESS'::character varying, 'COMPLETED'::character varying, 'CANCELLED'::character varying])::text[]))) not valid","alter table \\"public\\".\\"financial_goal\\" validate constraint \\"financial_goal_status_check\\"","alter table \\"public\\".\\"installment_purchase\\" add constraint \\"installment_purchase_status_check\\" CHECK (((status)::text = ANY ((ARRAY['ACTIVE'::character varying, 'COMPLETED'::character varying, 'CANCELLED'::character varying])::text[]))) not valid","alter table \\"public\\".\\"installment_purchase\\" validate constraint \\"installment_purchase_status_check\\"","alter table \\"public\\".\\"notification\\" add constraint \\"notification_notification_type_check\\" CHECK (((notification_type)::text = ANY ((ARRAY['RECURRING_TRANSACTION'::character varying, 'INSUFFICIENT_FUNDS'::character varying, 'GOAL_PROGRESS'::character varying, 'SYNC_ERROR'::character varying, 'SYSTEM'::character varying, 'CREDIT_CARD_DUE_DATE'::character varying, 'CREDIT_CARD_CUT_OFF'::character varying, 'CREDIT_CARD_LIMIT'::character varying, 'CREDIT_CARD_MINIMUM_PAYMENT'::character varying])::text[]))) not valid","alter table \\"public\\".\\"notification\\" validate constraint \\"notification_notification_type_check\\"","alter table \\"public\\".\\"notification\\" add constraint \\"notification_urgency_level_check\\" CHECK (((urgency_level)::text = ANY ((ARRAY['LOW'::character varying, 'MEDIUM'::character varying, 'HIGH'::character varying])::text[]))) not valid","alter table \\"public\\".\\"notification\\" validate constraint \\"notification_urgency_level_check\\"","alter table \\"public\\".\\"recurring_transaction\\" add constraint \\"recurring_transaction_frequency_check\\" CHECK (((frequency)::text = ANY ((ARRAY['WEEKLY'::character varying, 'MONTHLY'::character varying, 'YEARLY'::character varying])::text[]))) not valid","alter table \\"public\\".\\"recurring_transaction\\" validate constraint \\"recurring_transaction_frequency_check\\"","alter table \\"public\\".\\"transaction\\" add constraint \\"transaction_sync_status_check\\" CHECK (((sync_status)::text = ANY ((ARRAY['PENDING'::character varying, 'SYNCED'::character varying, 'ERROR'::character varying])::text[]))) not valid","alter table \\"public\\".\\"transaction\\" validate constraint \\"transaction_sync_status_check\\"","alter table \\"public\\".\\"transfer\\" add constraint \\"transfer_sync_status_check\\" CHECK (((sync_status)::text = ANY ((ARRAY['PENDING'::character varying, 'SYNCED'::character varying, 'ERROR'::character varying])::text[]))) not valid","alter table \\"public\\".\\"transfer\\" validate constraint \\"transfer_sync_status_check\\"","alter table \\"public\\".\\"transfer\\" add constraint \\"transfer_transfer_type_check\\" CHECK (((transfer_type)::text = ANY ((ARRAY['ACCOUNT_TO_ACCOUNT'::character varying, 'JAR_TO_JAR'::character varying, 'PERIOD_ROLLOVER'::character varying])::text[]))) not valid","alter table \\"public\\".\\"transfer\\" validate constraint \\"transfer_transfer_type_check\\"","set check_function_bodies = off","CREATE OR REPLACE FUNCTION public.check_transfer_balance(p_transfer_id uuid, p_amount numeric)\n RETURNS transfer_validation_result\n LANGUAGE plpgsql\nAS $function$\r\nDECLARE\r\n    v_result transfer_validation_result;\r\n    v_transfer transfer;\r\n    v_source_balance numeric;\r\n    v_target_balance numeric;\r\nBEGIN\r\n    SELECT * INTO v_transfer FROM public.transfer WHERE id = p_transfer_id;\r\n    \r\n    IF v_transfer.transfer_type = 'ACCOUNT_TO_ACCOUNT' THEN\r\n        -- Check account balances\r\n        SELECT current_balance INTO v_source_balance \r\n        FROM public.account \r\n        WHERE id = v_transfer.from_account_id;\r\n        \r\n        SELECT current_balance INTO v_target_balance \r\n        FROM public.account \r\n        WHERE id = v_transfer.to_account_id;\r\n        \r\n    ELSIF v_transfer.transfer_type = 'JAR_TO_JAR' THEN\r\n        -- Check jar balances\r\n        SELECT current_balance INTO v_source_balance \r\n        FROM public.jar \r\n        WHERE id = v_transfer.from_jar_id;\r\n        \r\n        SELECT current_balance INTO v_target_balance \r\n        FROM public.jar \r\n        WHERE id = v_transfer.to_jar_id;\r\n    END IF;\r\n    \r\n    v_result.is_valid := v_source_balance >= p_amount;\r\n    v_result.error_message := CASE \r\n        WHEN NOT v_result.is_valid THEN 'Insufficient balance'\r\n        ELSE NULL\r\n    END;\r\n    v_result.source_balance := v_source_balance;\r\n    v_result.target_balance := v_target_balance;\r\n    \r\n    RETURN v_result;\r\nEND;\r\n$function$","CREATE OR REPLACE FUNCTION public.get_daily_transaction_totals(p_user_id uuid, p_start_date timestamp with time zone, p_end_date timestamp with time zone, p_transaction_type_id uuid DEFAULT NULL::uuid)\n RETURNS TABLE(transaction_date date, total_amount numeric, transaction_count bigint)\n LANGUAGE plpgsql\n SECURITY DEFINER\nAS $function$\r\nDECLARE\r\n    v_start_date DATE := p_start_date::DATE;\r\n    v_end_date DATE := p_end_date::DATE;\r\nBEGIN\r\n    RETURN QUERY\r\n    SELECT \r\n        t.transaction_date::DATE as transaction_date,\r\n        SUM(t.amount * t.exchange_rate) as total_amount,\r\n        COUNT(*) as transaction_count\r\n    FROM \\"transaction\\" t\r\n    WHERE t.user_id = p_user_id\r\n    AND t.transaction_date::DATE >= v_start_date\r\n    AND t.transaction_date::DATE <= v_end_date\r\n    AND (p_transaction_type_id IS NULL OR t.transaction_type_id = p_transaction_type_id)\r\n    GROUP BY t.transaction_date::DATE\r\n    ORDER BY t.transaction_date::DATE;\r\nEND;\r\n$function$","CREATE OR REPLACE FUNCTION public.get_transaction_summary_by_date_range(p_user_id uuid, p_start_date timestamp with time zone, p_end_date timestamp with time zone)\n RETURNS TABLE(transaction_type text, total_amount numeric, currency_id uuid, transaction_count bigint)\n LANGUAGE plpgsql\n SECURITY DEFINER\nAS $function$\r\nBEGIN\r\n    RETURN QUERY\r\n    SELECT \r\n        tt.name as transaction_type,\r\n        SUM(t.amount * t.exchange_rate) as total_amount,\r\n        t.currency_id,\r\n        COUNT(*) as transaction_count\r\n    FROM \\"transaction\\" t\r\n    JOIN transaction_type tt ON t.transaction_type_id = tt.id\r\n    WHERE t.user_id = p_user_id\r\n    AND t.transaction_date >= p_start_date\r\n    AND t.transaction_date <= p_end_date\r\n    GROUP BY tt.name, t.currency_id\r\n    ORDER BY tt.name;\r\nEND;\r\n$function$","CREATE OR REPLACE FUNCTION public.get_transactions_by_date_range(p_user_id uuid, p_start_date timestamp with time zone, p_end_date timestamp with time zone, p_transaction_type_id uuid DEFAULT NULL::uuid, p_category_id uuid DEFAULT NULL::uuid, p_subcategory_id uuid DEFAULT NULL::uuid, p_account_id uuid DEFAULT NULL::uuid, p_jar_id uuid DEFAULT NULL::uuid)\n RETURNS TABLE(id uuid, user_id uuid, transaction_date timestamp with time zone, description text, amount numeric, transaction_type_id uuid, category_id uuid, subcategory_id uuid, account_id uuid, transaction_medium_id uuid, currency_id uuid, exchange_rate numeric, notes text, tags jsonb, is_recurring boolean, parent_recurring_id uuid, sync_status text, created_at timestamp with time zone, modified_at timestamp with time zone)\n LANGUAGE plpgsql\n SECURITY DEFINER\nAS $function$\r\nBEGIN\r\n    RETURN QUERY\r\n    SELECT t.*\r\n    FROM \\"transaction\\" t\r\n    LEFT JOIN subcategory sc ON t.subcategory_id = sc.id\r\n    WHERE t.user_id = p_user_id\r\n    AND t.transaction_date >= p_start_date\r\n    AND t.transaction_date <= p_end_date\r\n    AND (p_transaction_type_id IS NULL OR t.transaction_type_id = p_transaction_type_id)\r\n    AND (p_category_id IS NULL OR t.category_id = p_category_id)\r\n    AND (p_subcategory_id IS NULL OR t.subcategory_id = p_subcategory_id)\r\n    AND (p_account_id IS NULL OR t.account_id = p_account_id)\r\n    AND (p_jar_id IS NULL OR sc.jar_id = p_jar_id)\r\n    ORDER BY t.transaction_date DESC;\r\nEND;\r\n$function$","CREATE OR REPLACE FUNCTION public.validate_transfer()\n RETURNS trigger\n LANGUAGE plpgsql\nAS $function$\r\nBEGIN\r\n    -- For Account to Account transfers\r\n    IF NEW.transfer_type = 'ACCOUNT_TO_ACCOUNT' THEN\r\n        IF NEW.from_account_id IS NULL OR NEW.to_account_id IS NULL THEN\r\n            RAISE EXCEPTION 'Account transfers require both from_account_id and to_account_id';\r\n        END IF;\r\n        IF NEW.from_jar_id IS NOT NULL OR NEW.to_jar_id IS NOT NULL THEN\r\n            RAISE EXCEPTION 'Account transfers should not include jar IDs';\r\n        END IF;\r\n    END IF;\r\n\r\n    -- For Jar to Jar transfers\r\n    IF NEW.transfer_type = 'JAR_TO_JAR' THEN\r\n        IF NEW.from_jar_id IS NULL OR NEW.to_jar_id IS NULL THEN\r\n            RAISE EXCEPTION 'Jar transfers require both from_jar_id and to_jar_id';\r\n        END IF;\r\n        IF NEW.from_account_id IS NOT NULL OR NEW.to_account_id IS NOT NULL THEN\r\n            RAISE EXCEPTION 'Jar transfers should not include account IDs';\r\n        END IF;\r\n    END IF;\r\n\r\n    RETURN NEW;\r\nEND;\r\n$function$","CREATE OR REPLACE FUNCTION public.validate_transfer_by_type()\n RETURNS trigger\n LANGUAGE plpgsql\nAS $function$\r\nBEGIN\r\n    -- For Account transfers\r\n    IF NEW.transfer_type = 'ACCOUNT_TO_ACCOUNT' THEN\r\n        IF NEW.from_jar_id IS NOT NULL OR NEW.to_jar_id IS NOT NULL THEN\r\n            RAISE EXCEPTION 'Account transfers cannot include jar IDs';\r\n        END IF;\r\n        IF NEW.from_account_id IS NULL OR NEW.to_account_id IS NULL THEN\r\n            RAISE EXCEPTION 'Account transfers require both account IDs';\r\n        END IF;\r\n    END IF;\r\n\r\n    -- For Jar transfers\r\n    IF NEW.transfer_type = 'JAR_TO_JAR' THEN\r\n        IF NEW.from_account_id IS NOT NULL OR NEW.to_account_id IS NOT NULL THEN\r\n            RAISE EXCEPTION 'Jar transfers cannot include account IDs';\r\n        END IF;\r\n        IF NEW.from_jar_id IS NULL OR NEW.to_jar_id IS NULL THEN\r\n            RAISE EXCEPTION 'Jar transfers require both jar IDs';\r\n        END IF;\r\n    END IF;\r\n\r\n    RETURN NEW;\r\nEND;\r\n$function$","CREATE TRIGGER validate_transfer_trigger BEFORE INSERT OR UPDATE ON public.transfer FOR EACH ROW EXECUTE FUNCTION validate_transfer()","CREATE TRIGGER validate_transfer_type_trigger BEFORE INSERT OR UPDATE ON public.transfer FOR EACH ROW EXECUTE FUNCTION validate_transfer_by_type()"}	remote_schema
20250125041815	{"alter table \\"public\\".\\"balance_history\\" drop constraint \\"balance_history_change_type_check\\"","alter table \\"public\\".\\"credit_card_statement\\" drop constraint \\"credit_card_statement_status_check\\"","alter table \\"public\\".\\"financial_goal\\" drop constraint \\"financial_goal_status_check\\"","alter table \\"public\\".\\"installment_purchase\\" drop constraint \\"installment_purchase_status_check\\"","alter table \\"public\\".\\"notification\\" drop constraint \\"notification_notification_type_check\\"","alter table \\"public\\".\\"notification\\" drop constraint \\"notification_urgency_level_check\\"","alter table \\"public\\".\\"recurring_transaction\\" drop constraint \\"recurring_transaction_frequency_check\\"","alter table \\"public\\".\\"transaction\\" drop constraint \\"transaction_sync_status_check\\"","alter table \\"public\\".\\"transfer\\" drop constraint \\"transfer_sync_status_check\\"","alter table \\"public\\".\\"transfer\\" drop constraint \\"transfer_transfer_type_check\\"","drop function if exists \\"public\\".\\"get_transactions_by_date_range\\"(p_user_id uuid, p_start_date timestamp with time zone, p_end_date timestamp with time zone, p_transaction_type_id uuid, p_category_id uuid, p_subcategory_id uuid, p_account_id uuid, p_jar_id uuid)","drop function if exists \\"public\\".\\"get_daily_transaction_totals\\"(p_user_id uuid, p_start_date timestamp with time zone, p_end_date timestamp with time zone, p_transaction_type_id uuid)","drop index if exists \\"public\\".\\"idx_transfer_jars\\"","CREATE INDEX idx_transfer_jars ON public.transfer USING btree (from_jar_id, to_jar_id) WHERE ((transfer_type)::text = ANY ((ARRAY['JAR_TO_JAR'::character varying, 'PERIOD_ROLLOVER'::character varying])::text[]))","alter table \\"public\\".\\"balance_history\\" add constraint \\"balance_history_change_type_check\\" CHECK (((change_type)::text = ANY ((ARRAY['TRANSACTION'::character varying, 'TRANSFER'::character varying, 'ADJUSTMENT'::character varying, 'ROLLOVER'::character varying])::text[]))) not valid","alter table \\"public\\".\\"balance_history\\" validate constraint \\"balance_history_change_type_check\\"","alter table \\"public\\".\\"credit_card_statement\\" add constraint \\"credit_card_statement_status_check\\" CHECK (((status)::text = ANY ((ARRAY['PENDING'::character varying, 'PAID_MINIMUM'::character varying, 'PAID_FULL'::character varying])::text[]))) not valid","alter table \\"public\\".\\"credit_card_statement\\" validate constraint \\"credit_card_statement_status_check\\"","alter table \\"public\\".\\"financial_goal\\" add constraint \\"financial_goal_status_check\\" CHECK (((status)::text = ANY ((ARRAY['IN_PROGRESS'::character varying, 'COMPLETED'::character varying, 'CANCELLED'::character varying])::text[]))) not valid","alter table \\"public\\".\\"financial_goal\\" validate constraint \\"financial_goal_status_check\\"","alter table \\"public\\".\\"installment_purchase\\" add constraint \\"installment_purchase_status_check\\" CHECK (((status)::text = ANY ((ARRAY['ACTIVE'::character varying, 'COMPLETED'::character varying, 'CANCELLED'::character varying])::text[]))) not valid","alter table \\"public\\".\\"installment_purchase\\" validate constraint \\"installment_purchase_status_check\\"","alter table \\"public\\".\\"notification\\" add constraint \\"notification_notification_type_check\\" CHECK (((notification_type)::text = ANY ((ARRAY['RECURRING_TRANSACTION'::character varying, 'INSUFFICIENT_FUNDS'::character varying, 'GOAL_PROGRESS'::character varying, 'SYNC_ERROR'::character varying, 'SYSTEM'::character varying, 'CREDIT_CARD_DUE_DATE'::character varying, 'CREDIT_CARD_CUT_OFF'::character varying, 'CREDIT_CARD_LIMIT'::character varying, 'CREDIT_CARD_MINIMUM_PAYMENT'::character varying])::text[]))) not valid","alter table \\"public\\".\\"notification\\" validate constraint \\"notification_notification_type_check\\"","alter table \\"public\\".\\"notification\\" add constraint \\"notification_urgency_level_check\\" CHECK (((urgency_level)::text = ANY ((ARRAY['LOW'::character varying, 'MEDIUM'::character varying, 'HIGH'::character varying])::text[]))) not valid","alter table \\"public\\".\\"notification\\" validate constraint \\"notification_urgency_level_check\\"","alter table \\"public\\".\\"recurring_transaction\\" add constraint \\"recurring_transaction_frequency_check\\" CHECK (((frequency)::text = ANY ((ARRAY['WEEKLY'::character varying, 'MONTHLY'::character varying, 'YEARLY'::character varying])::text[]))) not valid","alter table \\"public\\".\\"recurring_transaction\\" validate constraint \\"recurring_transaction_frequency_check\\"","alter table \\"public\\".\\"transaction\\" add constraint \\"transaction_sync_status_check\\" CHECK (((sync_status)::text = ANY ((ARRAY['PENDING'::character varying, 'SYNCED'::character varying, 'ERROR'::character varying])::text[]))) not valid","alter table \\"public\\".\\"transaction\\" validate constraint \\"transaction_sync_status_check\\"","alter table \\"public\\".\\"transfer\\" add constraint \\"transfer_sync_status_check\\" CHECK (((sync_status)::text = ANY ((ARRAY['PENDING'::character varying, 'SYNCED'::character varying, 'ERROR'::character varying])::text[]))) not valid","alter table \\"public\\".\\"transfer\\" validate constraint \\"transfer_sync_status_check\\"","alter table \\"public\\".\\"transfer\\" add constraint \\"transfer_transfer_type_check\\" CHECK (((transfer_type)::text = ANY ((ARRAY['ACCOUNT_TO_ACCOUNT'::character varying, 'JAR_TO_JAR'::character varying, 'PERIOD_ROLLOVER'::character varying])::text[]))) not valid","alter table \\"public\\".\\"transfer\\" validate constraint \\"transfer_transfer_type_check\\"","set check_function_bodies = off","CREATE OR REPLACE FUNCTION public.get_transactions_by_date_range(p_user_id uuid, p_start_date timestamp with time zone, p_end_date timestamp with time zone, p_account_id uuid DEFAULT NULL::uuid, p_category_id uuid DEFAULT NULL::uuid, p_subcategory_id uuid DEFAULT NULL::uuid, p_transaction_type_id uuid DEFAULT NULL::uuid, p_jar_id uuid DEFAULT NULL::uuid)\n RETURNS TABLE(id uuid, user_id uuid, transaction_date timestamp with time zone, description text, amount numeric, transaction_type_id uuid, category_id uuid, subcategory_id uuid, account_id uuid, transaction_medium_id uuid, currency_id uuid, exchange_rate numeric, notes text, tags jsonb, is_recurring boolean, parent_recurring_id uuid, sync_status text, created_at timestamp with time zone, modified_at timestamp with time zone)\n LANGUAGE plpgsql\n SECURITY DEFINER\nAS $function$\r\nBEGIN\r\n    RETURN QUERY\r\n    SELECT t.*\r\n    FROM \\"transaction\\" t\r\n    LEFT JOIN subcategory sc ON t.subcategory_id = sc.id\r\n    WHERE t.user_id = p_user_id\r\n    AND t.transaction_date >= p_start_date\r\n    AND t.transaction_date <= p_end_date\r\n    AND (p_transaction_type_id IS NULL OR t.transaction_type_id = p_transaction_type_id)\r\n    AND (p_category_id IS NULL OR t.category_id = p_category_id)\r\n    AND (p_subcategory_id IS NULL OR t.subcategory_id = p_subcategory_id)\r\n    AND (p_account_id IS NULL OR t.account_id = p_account_id)\r\n    AND (p_jar_id IS NULL OR sc.jar_id = p_jar_id)\r\n    ORDER BY t.transaction_date DESC;\r\nEND;\r\n$function$","CREATE OR REPLACE FUNCTION public.get_daily_transaction_totals(p_user_id uuid, p_start_date timestamp with time zone, p_end_date timestamp with time zone, p_transaction_type_id uuid DEFAULT NULL::uuid)\n RETURNS TABLE(transaction_date timestamp with time zone, total_amount numeric, transaction_count bigint)\n LANGUAGE plpgsql\n SECURITY DEFINER\nAS $function$\r\nBEGIN\r\n    RETURN QUERY\r\n    SELECT \r\n        date_trunc('day', t.transaction_date) as transaction_date,\r\n        SUM(t.amount * t.exchange_rate) as total_amount,\r\n        COUNT(*) as transaction_count\r\n    FROM \\"transaction\\" t\r\n    WHERE t.user_id = p_user_id\r\n    AND t.transaction_date >= date_trunc('day', p_start_date)\r\n    AND t.transaction_date < date_trunc('day', p_end_date) + interval '1 day'\r\n    AND (p_transaction_type_id IS NULL OR t.transaction_type_id = p_transaction_type_id)\r\n    GROUP BY date_trunc('day', t.transaction_date)\r\n    ORDER BY date_trunc('day', t.transaction_date);\r\nEND;\r\n$function$"}	remote_schema
20250125153047	{"alter table \\"public\\".\\"balance_history\\" drop constraint \\"balance_history_change_type_check\\"","alter table \\"public\\".\\"credit_card_statement\\" drop constraint \\"credit_card_statement_status_check\\"","alter table \\"public\\".\\"financial_goal\\" drop constraint \\"financial_goal_status_check\\"","alter table \\"public\\".\\"installment_purchase\\" drop constraint \\"installment_purchase_status_check\\"","alter table \\"public\\".\\"notification\\" drop constraint \\"notification_notification_type_check\\"","alter table \\"public\\".\\"notification\\" drop constraint \\"notification_urgency_level_check\\"","alter table \\"public\\".\\"recurring_transaction\\" drop constraint \\"recurring_transaction_frequency_check\\"","alter table \\"public\\".\\"transaction\\" drop constraint \\"transaction_sync_status_check\\"","alter table \\"public\\".\\"transfer\\" drop constraint \\"transfer_sync_status_check\\"","alter table \\"public\\".\\"transfer\\" drop constraint \\"transfer_transfer_type_check\\"","drop function if exists \\"public\\".\\"analyze_jar_distribution\\"(p_user_id uuid, p_start_date date, p_end_date date)","drop function if exists \\"public\\".\\"check_transfer_balance\\"(p_transfer_id uuid, p_amount numeric)","drop function if exists \\"public\\".\\"execute_jar_transfer\\"(p_user_id uuid, p_from_jar_id uuid, p_to_jar_id uuid, p_amount numeric, p_description text, p_is_rollover boolean)","drop function if exists \\"public\\".\\"export_jar_status_to_excel\\"(p_user_id uuid)","drop type \\"public\\".\\"jar_distribution_summary\\"","drop type \\"public\\".\\"transfer_validation_result\\"","drop function if exists \\"public\\".\\"validate_account_transfer\\"(p_user_id uuid, p_from_account_id uuid, p_to_account_id uuid, p_amount numeric, p_exchange_rate numeric)","drop function if exists \\"public\\".\\"validate_jar_transfer\\"(p_user_id uuid, p_from_jar_id uuid, p_to_jar_id uuid, p_amount numeric)","drop index if exists \\"public\\".\\"idx_transfer_jars\\"","CREATE INDEX jar_balance_jar_id_idx ON public.jar_balance USING btree (jar_id)","CREATE INDEX idx_transfer_jars ON public.transfer USING btree (from_jar_id, to_jar_id) WHERE ((transfer_type)::text = ANY ((ARRAY['JAR_TO_JAR'::character varying, 'PERIOD_ROLLOVER'::character varying])::text[]))","alter table \\"public\\".\\"jar\\" add constraint \\"jar_target_percentage_check\\" CHECK (((target_percentage >= (0)::numeric) AND (target_percentage <= (100)::numeric))) not valid","alter table \\"public\\".\\"jar\\" validate constraint \\"jar_target_percentage_check\\"","alter table \\"public\\".\\"balance_history\\" add constraint \\"balance_history_change_type_check\\" CHECK (((change_type)::text = ANY ((ARRAY['TRANSACTION'::character varying, 'TRANSFER'::character varying, 'ADJUSTMENT'::character varying, 'ROLLOVER'::character varying])::text[]))) not valid","alter table \\"public\\".\\"balance_history\\" validate constraint \\"balance_history_change_type_check\\"","alter table \\"public\\".\\"credit_card_statement\\" add constraint \\"credit_card_statement_status_check\\" CHECK (((status)::text = ANY ((ARRAY['PENDING'::character varying, 'PAID_MINIMUM'::character varying, 'PAID_FULL'::character varying])::text[]))) not valid","alter table \\"public\\".\\"credit_card_statement\\" validate constraint \\"credit_card_statement_status_check\\"","alter table \\"public\\".\\"financial_goal\\" add constraint \\"financial_goal_status_check\\" CHECK (((status)::text = ANY ((ARRAY['IN_PROGRESS'::character varying, 'COMPLETED'::character varying, 'CANCELLED'::character varying])::text[]))) not valid","alter table \\"public\\".\\"financial_goal\\" validate constraint \\"financial_goal_status_check\\"","alter table \\"public\\".\\"installment_purchase\\" add constraint \\"installment_purchase_status_check\\" CHECK (((status)::text = ANY ((ARRAY['ACTIVE'::character varying, 'COMPLETED'::character varying, 'CANCELLED'::character varying])::text[]))) not valid","alter table \\"public\\".\\"installment_purchase\\" validate constraint \\"installment_purchase_status_check\\"","alter table \\"public\\".\\"notification\\" add constraint \\"notification_notification_type_check\\" CHECK (((notification_type)::text = ANY ((ARRAY['RECURRING_TRANSACTION'::character varying, 'INSUFFICIENT_FUNDS'::character varying, 'GOAL_PROGRESS'::character varying, 'SYNC_ERROR'::character varying, 'SYSTEM'::character varying, 'CREDIT_CARD_DUE_DATE'::character varying, 'CREDIT_CARD_CUT_OFF'::character varying, 'CREDIT_CARD_LIMIT'::character varying, 'CREDIT_CARD_MINIMUM_PAYMENT'::character varying])::text[]))) not valid","alter table \\"public\\".\\"notification\\" validate constraint \\"notification_notification_type_check\\"","alter table \\"public\\".\\"notification\\" add constraint \\"notification_urgency_level_check\\" CHECK (((urgency_level)::text = ANY ((ARRAY['LOW'::character varying, 'MEDIUM'::character varying, 'HIGH'::character varying])::text[]))) not valid","alter table \\"public\\".\\"notification\\" validate constraint \\"notification_urgency_level_check\\"","alter table \\"public\\".\\"recurring_transaction\\" add constraint \\"recurring_transaction_frequency_check\\" CHECK (((frequency)::text = ANY ((ARRAY['WEEKLY'::character varying, 'MONTHLY'::character varying, 'YEARLY'::character varying])::text[]))) not valid","alter table \\"public\\".\\"recurring_transaction\\" validate constraint \\"recurring_transaction_frequency_check\\"","alter table \\"public\\".\\"transaction\\" add constraint \\"transaction_sync_status_check\\" CHECK (((sync_status)::text = ANY ((ARRAY['PENDING'::character varying, 'SYNCED'::character varying, 'ERROR'::character varying])::text[]))) not valid","alter table \\"public\\".\\"transaction\\" validate constraint \\"transaction_sync_status_check\\"","alter table \\"public\\".\\"transfer\\" add constraint \\"transfer_sync_status_check\\" CHECK (((sync_status)::text = ANY ((ARRAY['PENDING'::character varying, 'SYNCED'::character varying, 'ERROR'::character varying])::text[]))) not valid","alter table \\"public\\".\\"transfer\\" validate constraint \\"transfer_sync_status_check\\"","alter table \\"public\\".\\"transfer\\" add constraint \\"transfer_transfer_type_check\\" CHECK (((transfer_type)::text = ANY ((ARRAY['ACCOUNT_TO_ACCOUNT'::character varying, 'JAR_TO_JAR'::character varying, 'PERIOD_ROLLOVER'::character varying])::text[]))) not valid","alter table \\"public\\".\\"transfer\\" validate constraint \\"transfer_transfer_type_check\\""}	remote_schema
20250125193744	{"create type \\"public\\".\\"transfer_validation_result\\" as enum ('valid', 'invalid')","alter table \\"public\\".\\"balance_history\\" drop constraint \\"balance_history_change_type_check\\"","alter table \\"public\\".\\"credit_card_statement\\" drop constraint \\"credit_card_statement_status_check\\"","alter table \\"public\\".\\"financial_goal\\" drop constraint \\"financial_goal_status_check\\"","alter table \\"public\\".\\"installment_purchase\\" drop constraint \\"installment_purchase_status_check\\"","alter table \\"public\\".\\"notification\\" drop constraint \\"notification_notification_type_check\\"","alter table \\"public\\".\\"notification\\" drop constraint \\"notification_urgency_level_check\\"","alter table \\"public\\".\\"recurring_transaction\\" drop constraint \\"recurring_transaction_frequency_check\\"","alter table \\"public\\".\\"transaction\\" drop constraint \\"transaction_sync_status_check\\"","alter table \\"public\\".\\"transfer\\" drop constraint \\"transfer_sync_status_check\\"","alter table \\"public\\".\\"transfer\\" drop constraint \\"transfer_transfer_type_check\\"","drop function if exists \\"public\\".\\"initialize_system_data\\"()","drop type \\"public\\".\\"transfer_validation_result\\"","drop index if exists \\"public\\".\\"idx_transfer_jars\\"","CREATE INDEX idx_transfer_jars ON public.transfer USING btree (from_jar_id, to_jar_id) WHERE ((transfer_type)::text = ANY ((ARRAY['JAR_TO_JAR'::character varying, 'PERIOD_ROLLOVER'::character varying])::text[]))","alter table \\"public\\".\\"app_user\\" add constraint \\"notification_advance_days_check\\" CHECK (((notification_advance_days >= 0) AND (notification_advance_days <= 30))) not valid","alter table \\"public\\".\\"app_user\\" validate constraint \\"notification_advance_days_check\\"","alter table \\"public\\".\\"balance_history\\" add constraint \\"balance_history_change_type_check\\" CHECK (((change_type)::text = ANY ((ARRAY['TRANSACTION'::character varying, 'TRANSFER'::character varying, 'ADJUSTMENT'::character varying, 'ROLLOVER'::character varying])::text[]))) not valid","alter table \\"public\\".\\"balance_history\\" validate constraint \\"balance_history_change_type_check\\"","alter table \\"public\\".\\"credit_card_statement\\" add constraint \\"credit_card_statement_status_check\\" CHECK (((status)::text = ANY ((ARRAY['PENDING'::character varying, 'PAID_MINIMUM'::character varying, 'PAID_FULL'::character varying])::text[]))) not valid","alter table \\"public\\".\\"credit_card_statement\\" validate constraint \\"credit_card_statement_status_check\\"","alter table \\"public\\".\\"financial_goal\\" add constraint \\"financial_goal_status_check\\" CHECK (((status)::text = ANY ((ARRAY['IN_PROGRESS'::character varying, 'COMPLETED'::character varying, 'CANCELLED'::character varying])::text[]))) not valid","alter table \\"public\\".\\"financial_goal\\" validate constraint \\"financial_goal_status_check\\"","alter table \\"public\\".\\"installment_purchase\\" add constraint \\"installment_purchase_status_check\\" CHECK (((status)::text = ANY ((ARRAY['ACTIVE'::character varying, 'COMPLETED'::character varying, 'CANCELLED'::character varying])::text[]))) not valid","alter table \\"public\\".\\"installment_purchase\\" validate constraint \\"installment_purchase_status_check\\"","alter table \\"public\\".\\"notification\\" add constraint \\"notification_notification_type_check\\" CHECK (((notification_type)::text = ANY ((ARRAY['RECURRING_TRANSACTION'::character varying, 'INSUFFICIENT_FUNDS'::character varying, 'GOAL_PROGRESS'::character varying, 'SYNC_ERROR'::character varying, 'SYSTEM'::character varying, 'CREDIT_CARD_DUE_DATE'::character varying, 'CREDIT_CARD_CUT_OFF'::character varying, 'CREDIT_CARD_LIMIT'::character varying, 'CREDIT_CARD_MINIMUM_PAYMENT'::character varying])::text[]))) not valid","alter table \\"public\\".\\"notification\\" validate constraint \\"notification_notification_type_check\\"","alter table \\"public\\".\\"notification\\" add constraint \\"notification_urgency_level_check\\" CHECK (((urgency_level)::text = ANY ((ARRAY['LOW'::character varying, 'MEDIUM'::character varying, 'HIGH'::character varying])::text[]))) not valid","alter table \\"public\\".\\"notification\\" validate constraint \\"notification_urgency_level_check\\"","alter table \\"public\\".\\"recurring_transaction\\" add constraint \\"recurring_transaction_frequency_check\\" CHECK (((frequency)::text = ANY ((ARRAY['WEEKLY'::character varying, 'MONTHLY'::character varying, 'YEARLY'::character varying])::text[]))) not valid","alter table \\"public\\".\\"recurring_transaction\\" validate constraint \\"recurring_transaction_frequency_check\\"","alter table \\"public\\".\\"transaction\\" add constraint \\"transaction_sync_status_check\\" CHECK (((sync_status)::text = ANY ((ARRAY['PENDING'::character varying, 'SYNCED'::character varying, 'ERROR'::character varying])::text[]))) not valid","alter table \\"public\\".\\"transaction\\" validate constraint \\"transaction_sync_status_check\\"","alter table \\"public\\".\\"transfer\\" add constraint \\"transfer_sync_status_check\\" CHECK (((sync_status)::text = ANY ((ARRAY['PENDING'::character varying, 'SYNCED'::character varying, 'ERROR'::character varying])::text[]))) not valid","alter table \\"public\\".\\"transfer\\" validate constraint \\"transfer_sync_status_check\\"","alter table \\"public\\".\\"transfer\\" add constraint \\"transfer_transfer_type_check\\" CHECK (((transfer_type)::text = ANY ((ARRAY['ACCOUNT_TO_ACCOUNT'::character varying, 'JAR_TO_JAR'::character varying, 'PERIOD_ROLLOVER'::character varying])::text[]))) not valid","alter table \\"public\\".\\"transfer\\" validate constraint \\"transfer_transfer_type_check\\""}	remote_schema
\.


--
-- Data for Name: seed_files; Type: TABLE DATA; Schema: supabase_migrations; Owner: postgres
--

COPY supabase_migrations.seed_files (path, hash) FROM stdin;
\.


--
-- Data for Name: secrets; Type: TABLE DATA; Schema: vault; Owner: supabase_admin
--

COPY vault.secrets (id, name, description, secret, key_id, nonce, created_at, updated_at) FROM stdin;
\.


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE SET; Schema: auth; Owner: supabase_auth_admin
--

SELECT pg_catalog.setval('auth.refresh_tokens_id_seq', 280, true);


--
-- Name: jobid_seq; Type: SEQUENCE SET; Schema: cron; Owner: supabase_admin
--

SELECT pg_catalog.setval('cron.jobid_seq', 5, true);


--
-- Name: runid_seq; Type: SEQUENCE SET; Schema: cron; Owner: supabase_admin
--

SELECT pg_catalog.setval('cron.runid_seq', 107, true);


--
-- Name: key_key_id_seq; Type: SEQUENCE SET; Schema: pgsodium; Owner: supabase_admin
--

SELECT pg_catalog.setval('pgsodium.key_key_id_seq', 1, false);


--
-- Name: subscription_id_seq; Type: SEQUENCE SET; Schema: realtime; Owner: supabase_admin
--

SELECT pg_catalog.setval('realtime.subscription_id_seq', 1, false);


--
-- Name: mfa_amr_claims amr_id_pk; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT amr_id_pk PRIMARY KEY (id);


--
-- Name: audit_log_entries audit_log_entries_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.audit_log_entries
    ADD CONSTRAINT audit_log_entries_pkey PRIMARY KEY (id);


--
-- Name: flow_state flow_state_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.flow_state
    ADD CONSTRAINT flow_state_pkey PRIMARY KEY (id);


--
-- Name: identities identities_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_pkey PRIMARY KEY (id);


--
-- Name: identities identities_provider_id_provider_unique; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_provider_id_provider_unique UNIQUE (provider_id, provider);


--
-- Name: instances instances_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.instances
    ADD CONSTRAINT instances_pkey PRIMARY KEY (id);


--
-- Name: mfa_amr_claims mfa_amr_claims_session_id_authentication_method_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT mfa_amr_claims_session_id_authentication_method_pkey UNIQUE (session_id, authentication_method);


--
-- Name: mfa_challenges mfa_challenges_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_challenges
    ADD CONSTRAINT mfa_challenges_pkey PRIMARY KEY (id);


--
-- Name: mfa_factors mfa_factors_last_challenged_at_key; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_last_challenged_at_key UNIQUE (last_challenged_at);


--
-- Name: mfa_factors mfa_factors_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_pkey PRIMARY KEY (id);


--
-- Name: one_time_tokens one_time_tokens_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.one_time_tokens
    ADD CONSTRAINT one_time_tokens_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_token_unique; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_token_unique UNIQUE (token);


--
-- Name: saml_providers saml_providers_entity_id_key; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_entity_id_key UNIQUE (entity_id);


--
-- Name: saml_providers saml_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_pkey PRIMARY KEY (id);


--
-- Name: saml_relay_states saml_relay_states_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: sso_domains sso_domains_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sso_domains
    ADD CONSTRAINT sso_domains_pkey PRIMARY KEY (id);


--
-- Name: sso_providers sso_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sso_providers
    ADD CONSTRAINT sso_providers_pkey PRIMARY KEY (id);


--
-- Name: users users_phone_key; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_phone_key UNIQUE (phone);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: account account_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account
    ADD CONSTRAINT account_pkey PRIMARY KEY (id);


--
-- Name: account_type account_type_name_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_type
    ADD CONSTRAINT account_type_name_unique UNIQUE (name);


--
-- Name: account_type account_type_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_type
    ADD CONSTRAINT account_type_pkey PRIMARY KEY (id);


--
-- Name: app_user app_user_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.app_user
    ADD CONSTRAINT app_user_pkey PRIMARY KEY (id);


--
-- Name: balance_history balance_history_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.balance_history
    ADD CONSTRAINT balance_history_pkey PRIMARY KEY (id);


--
-- Name: category category_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.category
    ADD CONSTRAINT category_pkey PRIMARY KEY (id);


--
-- Name: credit_card_details credit_card_details_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.credit_card_details
    ADD CONSTRAINT credit_card_details_pkey PRIMARY KEY (id);


--
-- Name: credit_card_interest_history credit_card_interest_history_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.credit_card_interest_history
    ADD CONSTRAINT credit_card_interest_history_pkey PRIMARY KEY (id);


--
-- Name: credit_card_statement credit_card_statement_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.credit_card_statement
    ADD CONSTRAINT credit_card_statement_pkey PRIMARY KEY (id);


--
-- Name: currency currency_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.currency
    ADD CONSTRAINT currency_code_key UNIQUE (code);


--
-- Name: currency currency_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.currency
    ADD CONSTRAINT currency_pkey PRIMARY KEY (id);


--
-- Name: financial_goal financial_goal_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.financial_goal
    ADD CONSTRAINT financial_goal_pkey PRIMARY KEY (id);


--
-- Name: installment_purchase installment_purchase_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.installment_purchase
    ADD CONSTRAINT installment_purchase_pkey PRIMARY KEY (id);


--
-- Name: jar_balance jar_balance_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.jar_balance
    ADD CONSTRAINT jar_balance_pkey PRIMARY KEY (id);


--
-- Name: jar jar_name_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.jar
    ADD CONSTRAINT jar_name_unique UNIQUE (name);


--
-- Name: jar jar_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.jar
    ADD CONSTRAINT jar_pkey PRIMARY KEY (id);


--
-- Name: notification notification_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notification
    ADD CONSTRAINT notification_pkey PRIMARY KEY (id);


--
-- Name: recurring_transaction recurring_transaction_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.recurring_transaction
    ADD CONSTRAINT recurring_transaction_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: subcategory subcategory_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subcategory
    ADD CONSTRAINT subcategory_pkey PRIMARY KEY (id);


--
-- Name: transaction_medium transaction_medium_name_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transaction_medium
    ADD CONSTRAINT transaction_medium_name_unique UNIQUE (name);


--
-- Name: transaction_medium transaction_medium_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transaction_medium
    ADD CONSTRAINT transaction_medium_pkey PRIMARY KEY (id);


--
-- Name: transaction transaction_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transaction
    ADD CONSTRAINT transaction_pkey PRIMARY KEY (id);


--
-- Name: transaction_type transaction_type_name_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transaction_type
    ADD CONSTRAINT transaction_type_name_unique UNIQUE (name);


--
-- Name: transaction_type transaction_type_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transaction_type
    ADD CONSTRAINT transaction_type_pkey PRIMARY KEY (id);


--
-- Name: transfer transfer_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transfer
    ADD CONSTRAINT transfer_pkey PRIMARY KEY (id);


--
-- Name: credit_card_details unique_account_credit_card; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.credit_card_details
    ADD CONSTRAINT unique_account_credit_card UNIQUE (account_id);


--
-- Name: account unique_account_name_per_user; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account
    ADD CONSTRAINT unique_account_name_per_user UNIQUE (user_id, name);


--
-- Name: jar_balance unique_jar_per_user; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.jar_balance
    ADD CONSTRAINT unique_jar_per_user UNIQUE (user_id, jar_id);


--
-- Name: credit_card_statement unique_statement_period; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.credit_card_statement
    ADD CONSTRAINT unique_statement_period UNIQUE (credit_card_id, statement_date);


--
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER TABLE ONLY realtime.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id, inserted_at);


--
-- Name: subscription pk_subscription; Type: CONSTRAINT; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.subscription
    ADD CONSTRAINT pk_subscription PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: buckets buckets_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.buckets
    ADD CONSTRAINT buckets_pkey PRIMARY KEY (id);


--
-- Name: migrations migrations_name_key; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.migrations
    ADD CONSTRAINT migrations_name_key UNIQUE (name);


--
-- Name: migrations migrations_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.migrations
    ADD CONSTRAINT migrations_pkey PRIMARY KEY (id);


--
-- Name: objects objects_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.objects
    ADD CONSTRAINT objects_pkey PRIMARY KEY (id);


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_pkey PRIMARY KEY (id);


--
-- Name: s3_multipart_uploads s3_multipart_uploads_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.s3_multipart_uploads
    ADD CONSTRAINT s3_multipart_uploads_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: supabase_migrations; Owner: postgres
--

ALTER TABLE ONLY supabase_migrations.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: seed_files seed_files_pkey; Type: CONSTRAINT; Schema: supabase_migrations; Owner: postgres
--

ALTER TABLE ONLY supabase_migrations.seed_files
    ADD CONSTRAINT seed_files_pkey PRIMARY KEY (path);


--
-- Name: audit_logs_instance_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX audit_logs_instance_id_idx ON auth.audit_log_entries USING btree (instance_id);


--
-- Name: confirmation_token_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX confirmation_token_idx ON auth.users USING btree (confirmation_token) WHERE ((confirmation_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: email_change_token_current_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX email_change_token_current_idx ON auth.users USING btree (email_change_token_current) WHERE ((email_change_token_current)::text !~ '^[0-9 ]*$'::text);


--
-- Name: email_change_token_new_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX email_change_token_new_idx ON auth.users USING btree (email_change_token_new) WHERE ((email_change_token_new)::text !~ '^[0-9 ]*$'::text);


--
-- Name: factor_id_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX factor_id_created_at_idx ON auth.mfa_factors USING btree (user_id, created_at);


--
-- Name: flow_state_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX flow_state_created_at_idx ON auth.flow_state USING btree (created_at DESC);


--
-- Name: identities_email_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX identities_email_idx ON auth.identities USING btree (email text_pattern_ops);


--
-- Name: INDEX identities_email_idx; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON INDEX auth.identities_email_idx IS 'Auth: Ensures indexed queries on the email column';


--
-- Name: identities_user_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX identities_user_id_idx ON auth.identities USING btree (user_id);


--
-- Name: idx_auth_code; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX idx_auth_code ON auth.flow_state USING btree (auth_code);


--
-- Name: idx_user_id_auth_method; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX idx_user_id_auth_method ON auth.flow_state USING btree (user_id, authentication_method);


--
-- Name: mfa_challenge_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX mfa_challenge_created_at_idx ON auth.mfa_challenges USING btree (created_at DESC);


--
-- Name: mfa_factors_user_friendly_name_unique; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX mfa_factors_user_friendly_name_unique ON auth.mfa_factors USING btree (friendly_name, user_id) WHERE (TRIM(BOTH FROM friendly_name) <> ''::text);


--
-- Name: mfa_factors_user_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX mfa_factors_user_id_idx ON auth.mfa_factors USING btree (user_id);


--
-- Name: one_time_tokens_relates_to_hash_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX one_time_tokens_relates_to_hash_idx ON auth.one_time_tokens USING hash (relates_to);


--
-- Name: one_time_tokens_token_hash_hash_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX one_time_tokens_token_hash_hash_idx ON auth.one_time_tokens USING hash (token_hash);


--
-- Name: one_time_tokens_user_id_token_type_key; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX one_time_tokens_user_id_token_type_key ON auth.one_time_tokens USING btree (user_id, token_type);


--
-- Name: reauthentication_token_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX reauthentication_token_idx ON auth.users USING btree (reauthentication_token) WHERE ((reauthentication_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: recovery_token_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX recovery_token_idx ON auth.users USING btree (recovery_token) WHERE ((recovery_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: refresh_tokens_instance_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_instance_id_idx ON auth.refresh_tokens USING btree (instance_id);


--
-- Name: refresh_tokens_instance_id_user_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_instance_id_user_id_idx ON auth.refresh_tokens USING btree (instance_id, user_id);


--
-- Name: refresh_tokens_parent_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_parent_idx ON auth.refresh_tokens USING btree (parent);


--
-- Name: refresh_tokens_session_id_revoked_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_session_id_revoked_idx ON auth.refresh_tokens USING btree (session_id, revoked);


--
-- Name: refresh_tokens_updated_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_updated_at_idx ON auth.refresh_tokens USING btree (updated_at DESC);


--
-- Name: saml_providers_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX saml_providers_sso_provider_id_idx ON auth.saml_providers USING btree (sso_provider_id);


--
-- Name: saml_relay_states_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX saml_relay_states_created_at_idx ON auth.saml_relay_states USING btree (created_at DESC);


--
-- Name: saml_relay_states_for_email_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX saml_relay_states_for_email_idx ON auth.saml_relay_states USING btree (for_email);


--
-- Name: saml_relay_states_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX saml_relay_states_sso_provider_id_idx ON auth.saml_relay_states USING btree (sso_provider_id);


--
-- Name: sessions_not_after_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX sessions_not_after_idx ON auth.sessions USING btree (not_after DESC);


--
-- Name: sessions_user_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX sessions_user_id_idx ON auth.sessions USING btree (user_id);


--
-- Name: sso_domains_domain_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX sso_domains_domain_idx ON auth.sso_domains USING btree (lower(domain));


--
-- Name: sso_domains_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX sso_domains_sso_provider_id_idx ON auth.sso_domains USING btree (sso_provider_id);


--
-- Name: sso_providers_resource_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX sso_providers_resource_id_idx ON auth.sso_providers USING btree (lower(resource_id));


--
-- Name: unique_phone_factor_per_user; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX unique_phone_factor_per_user ON auth.mfa_factors USING btree (user_id, phone);


--
-- Name: user_id_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX user_id_created_at_idx ON auth.sessions USING btree (user_id, created_at);


--
-- Name: users_email_partial_key; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX users_email_partial_key ON auth.users USING btree (email) WHERE (is_sso_user = false);


--
-- Name: INDEX users_email_partial_key; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON INDEX auth.users_email_partial_key IS 'Auth: A partial unique index that applies only when is_sso_user is false';


--
-- Name: users_instance_id_email_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX users_instance_id_email_idx ON auth.users USING btree (instance_id, lower((email)::text));


--
-- Name: users_instance_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX users_instance_id_idx ON auth.users USING btree (instance_id);


--
-- Name: users_is_anonymous_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX users_is_anonymous_idx ON auth.users USING btree (is_anonymous);


--
-- Name: idx_account_active; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_account_active ON public.account USING btree (id) WHERE (is_active = true);


--
-- Name: idx_account_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_account_type ON public.account USING btree (account_type_id);


--
-- Name: idx_account_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_account_user ON public.account USING btree (user_id);


--
-- Name: idx_app_user_active; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_app_user_active ON public.app_user USING btree (id) WHERE (is_active = true);


--
-- Name: idx_app_user_email; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_app_user_email ON public.app_user USING btree (email);


--
-- Name: idx_balance_history_account; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_balance_history_account ON public.balance_history USING btree (account_id) WHERE (account_id IS NOT NULL);


--
-- Name: idx_balance_history_jar; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_balance_history_jar ON public.balance_history USING btree (jar_id) WHERE (jar_id IS NOT NULL);


--
-- Name: idx_balance_history_reference; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_balance_history_reference ON public.balance_history USING btree (reference_type, reference_id);


--
-- Name: idx_balance_history_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_balance_history_user ON public.balance_history USING btree (user_id);


--
-- Name: idx_category_active; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_category_active ON public.category USING btree (id) WHERE (is_active = true);


--
-- Name: idx_category_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_category_type ON public.category USING btree (transaction_type_id);


--
-- Name: idx_credit_card_cut_off; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_credit_card_cut_off ON public.credit_card_details USING btree (cut_off_day);


--
-- Name: idx_credit_card_details_account; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_credit_card_details_account ON public.credit_card_details USING btree (account_id);


--
-- Name: idx_credit_card_statement_dates; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_credit_card_statement_dates ON public.credit_card_statement USING btree (credit_card_id, statement_date);


--
-- Name: idx_credit_card_statement_due; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_credit_card_statement_due ON public.credit_card_statement USING btree (credit_card_id, due_date) WHERE ((status)::text = 'PENDING'::text);


--
-- Name: idx_currency_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_currency_code ON public.currency USING btree (code);


--
-- Name: idx_currency_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_currency_name ON public.currency USING btree (name);


--
-- Name: idx_financial_goal_active; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_financial_goal_active ON public.financial_goal USING btree (id) WHERE (is_active = true);


--
-- Name: idx_financial_goal_dates; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_financial_goal_dates ON public.financial_goal USING btree (start_date, target_date);


--
-- Name: idx_financial_goal_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_financial_goal_status ON public.financial_goal USING btree (status);


--
-- Name: idx_financial_goal_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_financial_goal_user ON public.financial_goal USING btree (user_id);


--
-- Name: idx_installment_purchase_active; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_installment_purchase_active ON public.installment_purchase USING btree (credit_card_id, next_installment_date) WHERE ((status)::text = 'ACTIVE'::text);


--
-- Name: idx_jar_active; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_jar_active ON public.jar USING btree (id) WHERE (is_active = true);


--
-- Name: idx_jar_balance_jar; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_jar_balance_jar ON public.jar_balance USING btree (jar_id);


--
-- Name: idx_jar_balance_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_jar_balance_user ON public.jar_balance USING btree (user_id);


--
-- Name: idx_jar_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_jar_name ON public.jar USING btree (name);


--
-- Name: idx_notification_entity; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_notification_entity ON public.notification USING btree (related_entity_type, related_entity_id) WHERE (related_entity_id IS NOT NULL);


--
-- Name: idx_notification_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_notification_type ON public.notification USING btree (notification_type);


--
-- Name: idx_notification_unread; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_notification_unread ON public.notification USING btree (id) WHERE (NOT is_read);


--
-- Name: idx_notification_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_notification_user ON public.notification USING btree (user_id);


--
-- Name: idx_recurring_transaction_next_no_end; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_recurring_transaction_next_no_end ON public.recurring_transaction USING btree (next_execution_date) WHERE ((is_active = true) AND (end_date IS NULL));


--
-- Name: idx_recurring_transaction_next_with_end; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_recurring_transaction_next_with_end ON public.recurring_transaction USING btree (next_execution_date, end_date) WHERE (is_active = true);


--
-- Name: idx_recurring_transaction_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_recurring_transaction_user ON public.recurring_transaction USING btree (user_id);


--
-- Name: idx_subcategory_active; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_subcategory_active ON public.subcategory USING btree (id) WHERE (is_active = true);


--
-- Name: idx_subcategory_category; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_subcategory_category ON public.subcategory USING btree (category_id);


--
-- Name: idx_subcategory_jar; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_subcategory_jar ON public.subcategory USING btree (jar_id);


--
-- Name: idx_transaction_account; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_transaction_account ON public.transaction USING btree (account_id);


--
-- Name: idx_transaction_category_analysis; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_transaction_category_analysis ON public.transaction USING btree (user_id, category_id, transaction_date);


--
-- Name: idx_transaction_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_transaction_date ON public.transaction USING btree (transaction_date);


--
-- Name: idx_transaction_date_analysis; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_transaction_date_analysis ON public.transaction USING btree (user_id, transaction_date) INCLUDE (amount);


--
-- Name: idx_transaction_notes_search; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_transaction_notes_search ON public.transaction USING gin (to_tsvector('spanish'::regconfig, COALESCE(notes, ''::text)));


--
-- Name: idx_transaction_recurring; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_transaction_recurring ON public.transaction USING btree (parent_recurring_id) WHERE (parent_recurring_id IS NOT NULL);


--
-- Name: idx_transaction_sync; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_transaction_sync ON public.transaction USING btree (sync_status);


--
-- Name: idx_transaction_tags; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_transaction_tags ON public.transaction USING gin (tags);


--
-- Name: idx_transaction_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_transaction_type ON public.transaction USING btree (transaction_type_id);


--
-- Name: idx_transaction_type_active; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_transaction_type_active ON public.transaction_type USING btree (id) WHERE (is_active = true);


--
-- Name: idx_transaction_type_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_transaction_type_name ON public.transaction_type USING btree (name);


--
-- Name: idx_transaction_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_transaction_user ON public.transaction USING btree (user_id);


--
-- Name: idx_transfer_accounts; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_transfer_accounts ON public.transfer USING btree (from_account_id, to_account_id) WHERE ((transfer_type)::text = 'ACCOUNT_TO_ACCOUNT'::text);


--
-- Name: idx_transfer_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_transfer_date ON public.transfer USING btree (transfer_date);


--
-- Name: idx_transfer_jars; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_transfer_jars ON public.transfer USING btree (from_jar_id, to_jar_id) WHERE ((transfer_type)::text = ANY ((ARRAY['JAR_TO_JAR'::character varying, 'PERIOD_ROLLOVER'::character varying])::text[]));


--
-- Name: idx_transfer_sync; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_transfer_sync ON public.transfer USING btree (sync_status);


--
-- Name: idx_transfer_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_transfer_user ON public.transfer USING btree (user_id);


--
-- Name: jar_balance_jar_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX jar_balance_jar_id_idx ON public.jar_balance USING btree (jar_id);


--
-- Name: ix_realtime_subscription_entity; Type: INDEX; Schema: realtime; Owner: supabase_admin
--

CREATE INDEX ix_realtime_subscription_entity ON realtime.subscription USING btree (entity);


--
-- Name: subscription_subscription_id_entity_filters_key; Type: INDEX; Schema: realtime; Owner: supabase_admin
--

CREATE UNIQUE INDEX subscription_subscription_id_entity_filters_key ON realtime.subscription USING btree (subscription_id, entity, filters);


--
-- Name: bname; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE UNIQUE INDEX bname ON storage.buckets USING btree (name);


--
-- Name: bucketid_objname; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE UNIQUE INDEX bucketid_objname ON storage.objects USING btree (bucket_id, name);


--
-- Name: idx_multipart_uploads_list; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE INDEX idx_multipart_uploads_list ON storage.s3_multipart_uploads USING btree (bucket_id, key, created_at);


--
-- Name: idx_objects_bucket_id_name; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE INDEX idx_objects_bucket_id_name ON storage.objects USING btree (bucket_id, name COLLATE "C");


--
-- Name: name_prefix_search; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE INDEX name_prefix_search ON storage.objects USING btree (name text_pattern_ops);


--
-- Name: users on_auth_user_created; Type: TRIGGER; Schema: auth; Owner: supabase_auth_admin
--

CREATE TRIGGER on_auth_user_created AFTER INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();


--
-- Name: transfer after_transfer_notification; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER after_transfer_notification AFTER INSERT ON public.transfer FOR EACH ROW EXECUTE FUNCTION public.notify_transfer();


--
-- Name: transaction record_transaction_history; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER record_transaction_history AFTER INSERT ON public.transaction FOR EACH ROW EXECUTE FUNCTION public.record_balance_history();


--
-- Name: transfer record_transfer_history; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER record_transfer_history AFTER INSERT ON public.transfer FOR EACH ROW EXECUTE FUNCTION public.record_balance_history();


--
-- Name: credit_card_details track_interest_rate_changes_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER track_interest_rate_changes_trigger AFTER UPDATE OF current_interest_rate ON public.credit_card_details FOR EACH ROW EXECUTE FUNCTION public.track_interest_rate_changes();


--
-- Name: account update_modified_timestamp; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_modified_timestamp BEFORE UPDATE ON public.account FOR EACH ROW EXECUTE FUNCTION public.update_modified_timestamp();


--
-- Name: account_type update_modified_timestamp; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_modified_timestamp BEFORE UPDATE ON public.account_type FOR EACH ROW EXECUTE FUNCTION public.update_modified_timestamp();


--
-- Name: app_user update_modified_timestamp; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_modified_timestamp BEFORE UPDATE ON public.app_user FOR EACH ROW EXECUTE FUNCTION public.update_modified_timestamp();


--
-- Name: category update_modified_timestamp; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_modified_timestamp BEFORE UPDATE ON public.category FOR EACH ROW EXECUTE FUNCTION public.update_modified_timestamp();


--
-- Name: currency update_modified_timestamp; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_modified_timestamp BEFORE UPDATE ON public.currency FOR EACH ROW EXECUTE FUNCTION public.update_modified_timestamp();


--
-- Name: financial_goal update_modified_timestamp; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_modified_timestamp BEFORE UPDATE ON public.financial_goal FOR EACH ROW EXECUTE FUNCTION public.update_modified_timestamp();


--
-- Name: jar update_modified_timestamp; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_modified_timestamp BEFORE UPDATE ON public.jar FOR EACH ROW EXECUTE FUNCTION public.update_modified_timestamp();


--
-- Name: jar_balance update_modified_timestamp; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_modified_timestamp BEFORE UPDATE ON public.jar_balance FOR EACH ROW EXECUTE FUNCTION public.update_modified_timestamp();


--
-- Name: recurring_transaction update_modified_timestamp; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_modified_timestamp BEFORE UPDATE ON public.recurring_transaction FOR EACH ROW EXECUTE FUNCTION public.update_modified_timestamp();


--
-- Name: subcategory update_modified_timestamp; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_modified_timestamp BEFORE UPDATE ON public.subcategory FOR EACH ROW EXECUTE FUNCTION public.update_modified_timestamp();


--
-- Name: transaction update_modified_timestamp; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_modified_timestamp BEFORE UPDATE ON public.transaction FOR EACH ROW EXECUTE FUNCTION public.update_modified_timestamp();


--
-- Name: transaction_medium update_modified_timestamp; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_modified_timestamp BEFORE UPDATE ON public.transaction_medium FOR EACH ROW EXECUTE FUNCTION public.update_modified_timestamp();


--
-- Name: transaction_type update_modified_timestamp; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_modified_timestamp BEFORE UPDATE ON public.transaction_type FOR EACH ROW EXECUTE FUNCTION public.update_modified_timestamp();


--
-- Name: transfer update_modified_timestamp; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_modified_timestamp BEFORE UPDATE ON public.transfer FOR EACH ROW EXECUTE FUNCTION public.update_modified_timestamp();


--
-- Name: subscription tr_check_filters; Type: TRIGGER; Schema: realtime; Owner: supabase_admin
--

CREATE TRIGGER tr_check_filters BEFORE INSERT OR UPDATE ON realtime.subscription FOR EACH ROW EXECUTE FUNCTION realtime.subscription_check_filters();


--
-- Name: objects update_objects_updated_at; Type: TRIGGER; Schema: storage; Owner: supabase_storage_admin
--

CREATE TRIGGER update_objects_updated_at BEFORE UPDATE ON storage.objects FOR EACH ROW EXECUTE FUNCTION storage.update_updated_at_column();


--
-- Name: identities identities_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: mfa_amr_claims mfa_amr_claims_session_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT mfa_amr_claims_session_id_fkey FOREIGN KEY (session_id) REFERENCES auth.sessions(id) ON DELETE CASCADE;


--
-- Name: mfa_challenges mfa_challenges_auth_factor_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_challenges
    ADD CONSTRAINT mfa_challenges_auth_factor_id_fkey FOREIGN KEY (factor_id) REFERENCES auth.mfa_factors(id) ON DELETE CASCADE;


--
-- Name: mfa_factors mfa_factors_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: one_time_tokens one_time_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.one_time_tokens
    ADD CONSTRAINT one_time_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: refresh_tokens refresh_tokens_session_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_session_id_fkey FOREIGN KEY (session_id) REFERENCES auth.sessions(id) ON DELETE CASCADE;


--
-- Name: saml_providers saml_providers_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: saml_relay_states saml_relay_states_flow_state_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_flow_state_id_fkey FOREIGN KEY (flow_state_id) REFERENCES auth.flow_state(id) ON DELETE CASCADE;


--
-- Name: saml_relay_states saml_relay_states_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: sessions sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: sso_domains sso_domains_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sso_domains
    ADD CONSTRAINT sso_domains_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: account account_account_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account
    ADD CONSTRAINT account_account_type_id_fkey FOREIGN KEY (account_type_id) REFERENCES public.account_type(id);


--
-- Name: account account_currency_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account
    ADD CONSTRAINT account_currency_id_fkey FOREIGN KEY (currency_id) REFERENCES public.currency(id);


--
-- Name: account account_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account
    ADD CONSTRAINT account_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.app_user(id);


--
-- Name: app_user app_user_default_currency_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.app_user
    ADD CONSTRAINT app_user_default_currency_id_fkey FOREIGN KEY (default_currency_id) REFERENCES public.currency(id);


--
-- Name: app_user app_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.app_user
    ADD CONSTRAINT app_user_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id);


--
-- Name: balance_history balance_history_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.balance_history
    ADD CONSTRAINT balance_history_account_id_fkey FOREIGN KEY (account_id) REFERENCES public.account(id);


--
-- Name: balance_history balance_history_jar_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.balance_history
    ADD CONSTRAINT balance_history_jar_id_fkey FOREIGN KEY (jar_id) REFERENCES public.jar(id);


--
-- Name: balance_history balance_history_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.balance_history
    ADD CONSTRAINT balance_history_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.app_user(id);


--
-- Name: category category_transaction_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.category
    ADD CONSTRAINT category_transaction_type_id_fkey FOREIGN KEY (transaction_type_id) REFERENCES public.transaction_type(id);


--
-- Name: credit_card_details credit_card_details_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.credit_card_details
    ADD CONSTRAINT credit_card_details_account_id_fkey FOREIGN KEY (account_id) REFERENCES public.account(id);


--
-- Name: credit_card_interest_history credit_card_interest_history_credit_card_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.credit_card_interest_history
    ADD CONSTRAINT credit_card_interest_history_credit_card_id_fkey FOREIGN KEY (credit_card_id) REFERENCES public.credit_card_details(id);


--
-- Name: credit_card_statement credit_card_statement_credit_card_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.credit_card_statement
    ADD CONSTRAINT credit_card_statement_credit_card_id_fkey FOREIGN KEY (credit_card_id) REFERENCES public.credit_card_details(id);


--
-- Name: financial_goal financial_goal_jar_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.financial_goal
    ADD CONSTRAINT financial_goal_jar_id_fkey FOREIGN KEY (jar_id) REFERENCES public.jar(id);


--
-- Name: financial_goal financial_goal_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.financial_goal
    ADD CONSTRAINT financial_goal_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.app_user(id);


--
-- Name: installment_purchase installment_purchase_credit_card_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.installment_purchase
    ADD CONSTRAINT installment_purchase_credit_card_id_fkey FOREIGN KEY (credit_card_id) REFERENCES public.credit_card_details(id);


--
-- Name: jar_balance jar_balance_jar_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.jar_balance
    ADD CONSTRAINT jar_balance_jar_id_fkey FOREIGN KEY (jar_id) REFERENCES public.jar(id);


--
-- Name: jar_balance jar_balance_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.jar_balance
    ADD CONSTRAINT jar_balance_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.app_user(id);


--
-- Name: notification notification_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notification
    ADD CONSTRAINT notification_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.app_user(id);


--
-- Name: recurring_transaction recurring_transaction_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.recurring_transaction
    ADD CONSTRAINT recurring_transaction_account_id_fkey FOREIGN KEY (account_id) REFERENCES public.account(id);


--
-- Name: recurring_transaction recurring_transaction_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.recurring_transaction
    ADD CONSTRAINT recurring_transaction_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.category(id);


--
-- Name: recurring_transaction recurring_transaction_jar_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.recurring_transaction
    ADD CONSTRAINT recurring_transaction_jar_id_fkey FOREIGN KEY (jar_id) REFERENCES public.jar(id);


--
-- Name: recurring_transaction recurring_transaction_subcategory_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.recurring_transaction
    ADD CONSTRAINT recurring_transaction_subcategory_id_fkey FOREIGN KEY (subcategory_id) REFERENCES public.subcategory(id);


--
-- Name: recurring_transaction recurring_transaction_transaction_medium_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.recurring_transaction
    ADD CONSTRAINT recurring_transaction_transaction_medium_id_fkey FOREIGN KEY (transaction_medium_id) REFERENCES public.transaction_medium(id);


--
-- Name: recurring_transaction recurring_transaction_transaction_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.recurring_transaction
    ADD CONSTRAINT recurring_transaction_transaction_type_id_fkey FOREIGN KEY (transaction_type_id) REFERENCES public.transaction_type(id);


--
-- Name: recurring_transaction recurring_transaction_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.recurring_transaction
    ADD CONSTRAINT recurring_transaction_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.app_user(id);


--
-- Name: subcategory subcategory_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subcategory
    ADD CONSTRAINT subcategory_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.category(id);


--
-- Name: subcategory subcategory_jar_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subcategory
    ADD CONSTRAINT subcategory_jar_id_fkey FOREIGN KEY (jar_id) REFERENCES public.jar(id);


--
-- Name: transaction transaction_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transaction
    ADD CONSTRAINT transaction_account_id_fkey FOREIGN KEY (account_id) REFERENCES public.account(id);


--
-- Name: transaction transaction_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transaction
    ADD CONSTRAINT transaction_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.category(id);


--
-- Name: transaction transaction_currency_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transaction
    ADD CONSTRAINT transaction_currency_id_fkey FOREIGN KEY (currency_id) REFERENCES public.currency(id);


--
-- Name: transaction transaction_subcategory_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transaction
    ADD CONSTRAINT transaction_subcategory_id_fkey FOREIGN KEY (subcategory_id) REFERENCES public.subcategory(id);


--
-- Name: transaction transaction_transaction_medium_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transaction
    ADD CONSTRAINT transaction_transaction_medium_id_fkey FOREIGN KEY (transaction_medium_id) REFERENCES public.transaction_medium(id);


--
-- Name: transaction transaction_transaction_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transaction
    ADD CONSTRAINT transaction_transaction_type_id_fkey FOREIGN KEY (transaction_type_id) REFERENCES public.transaction_type(id);


--
-- Name: transaction transaction_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transaction
    ADD CONSTRAINT transaction_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.app_user(id);


--
-- Name: transfer transfer_from_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transfer
    ADD CONSTRAINT transfer_from_account_id_fkey FOREIGN KEY (from_account_id) REFERENCES public.account(id);


--
-- Name: transfer transfer_from_jar_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transfer
    ADD CONSTRAINT transfer_from_jar_id_fkey FOREIGN KEY (from_jar_id) REFERENCES public.jar(id);


--
-- Name: transfer transfer_to_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transfer
    ADD CONSTRAINT transfer_to_account_id_fkey FOREIGN KEY (to_account_id) REFERENCES public.account(id);


--
-- Name: transfer transfer_to_jar_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transfer
    ADD CONSTRAINT transfer_to_jar_id_fkey FOREIGN KEY (to_jar_id) REFERENCES public.jar(id);


--
-- Name: transfer transfer_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transfer
    ADD CONSTRAINT transfer_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.app_user(id);


--
-- Name: objects objects_bucketId_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.objects
    ADD CONSTRAINT "objects_bucketId_fkey" FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: s3_multipart_uploads s3_multipart_uploads_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.s3_multipart_uploads
    ADD CONSTRAINT s3_multipart_uploads_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_upload_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_upload_id_fkey FOREIGN KEY (upload_id) REFERENCES storage.s3_multipart_uploads(id) ON DELETE CASCADE;


--
-- Name: audit_log_entries; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.audit_log_entries ENABLE ROW LEVEL SECURITY;

--
-- Name: flow_state; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.flow_state ENABLE ROW LEVEL SECURITY;

--
-- Name: identities; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.identities ENABLE ROW LEVEL SECURITY;

--
-- Name: instances; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.instances ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_amr_claims; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.mfa_amr_claims ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_challenges; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.mfa_challenges ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_factors; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.mfa_factors ENABLE ROW LEVEL SECURITY;

--
-- Name: one_time_tokens; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.one_time_tokens ENABLE ROW LEVEL SECURITY;

--
-- Name: refresh_tokens; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.refresh_tokens ENABLE ROW LEVEL SECURITY;

--
-- Name: saml_providers; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.saml_providers ENABLE ROW LEVEL SECURITY;

--
-- Name: saml_relay_states; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.saml_relay_states ENABLE ROW LEVEL SECURITY;

--
-- Name: schema_migrations; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.schema_migrations ENABLE ROW LEVEL SECURITY;

--
-- Name: sessions; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.sessions ENABLE ROW LEVEL SECURITY;

--
-- Name: sso_domains; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.sso_domains ENABLE ROW LEVEL SECURITY;

--
-- Name: sso_providers; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.sso_providers ENABLE ROW LEVEL SECURITY;

--
-- Name: users; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.users ENABLE ROW LEVEL SECURITY;

--
-- Name: account_type Usuarios autenticados pueden leer; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Usuarios autenticados pueden leer" ON public.account_type FOR SELECT USING ((auth.role() = 'authenticated'::text));


--
-- Name: category Usuarios autenticados pueden leer; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Usuarios autenticados pueden leer" ON public.category FOR SELECT USING ((auth.role() = 'authenticated'::text));


--
-- Name: currency Usuarios autenticados pueden leer; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Usuarios autenticados pueden leer" ON public.currency FOR SELECT USING ((auth.role() = 'authenticated'::text));


--
-- Name: jar Usuarios autenticados pueden leer; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Usuarios autenticados pueden leer" ON public.jar FOR SELECT USING ((auth.role() = 'authenticated'::text));


--
-- Name: subcategory Usuarios autenticados pueden leer; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Usuarios autenticados pueden leer" ON public.subcategory FOR SELECT USING ((auth.role() = 'authenticated'::text));


--
-- Name: transaction_medium Usuarios autenticados pueden leer; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Usuarios autenticados pueden leer" ON public.transaction_medium FOR SELECT USING ((auth.role() = 'authenticated'::text));


--
-- Name: transaction_type Usuarios autenticados pueden leer; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Usuarios autenticados pueden leer" ON public.transaction_type FOR SELECT USING ((auth.role() = 'authenticated'::text));


--
-- Name: category Usuarios pueden actualizar categorías; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Usuarios pueden actualizar categorías" ON public.category FOR UPDATE USING ((auth.role() = 'authenticated'::text));


--
-- Name: app_user Usuarios pueden actualizar su perfil; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Usuarios pueden actualizar su perfil" ON public.app_user FOR UPDATE USING ((auth.uid() = id));


--
-- Name: subcategory Usuarios pueden actualizar subcategorías; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Usuarios pueden actualizar subcategorías" ON public.subcategory FOR UPDATE USING ((auth.role() = 'authenticated'::text));


--
-- Name: jar_balance Usuarios pueden actualizar sus balances; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Usuarios pueden actualizar sus balances" ON public.jar_balance FOR UPDATE USING ((auth.uid() = user_id));


--
-- Name: account Usuarios pueden actualizar sus cuentas; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Usuarios pueden actualizar sus cuentas" ON public.account FOR UPDATE USING ((auth.uid() = user_id));


--
-- Name: financial_goal Usuarios pueden actualizar sus metas; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Usuarios pueden actualizar sus metas" ON public.financial_goal FOR UPDATE USING ((auth.uid() = user_id));


--
-- Name: notification Usuarios pueden actualizar sus notificaciones; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Usuarios pueden actualizar sus notificaciones" ON public.notification FOR UPDATE USING ((auth.uid() = user_id));


--
-- Name: credit_card_details Usuarios pueden actualizar sus tarjetas; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Usuarios pueden actualizar sus tarjetas" ON public.credit_card_details FOR UPDATE USING ((auth.uid() = ( SELECT account.user_id
   FROM public.account
  WHERE (account.id = credit_card_details.account_id))));


--
-- Name: transaction Usuarios pueden actualizar sus transacciones; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Usuarios pueden actualizar sus transacciones" ON public.transaction FOR UPDATE USING ((auth.uid() = user_id));


--
-- Name: recurring_transaction Usuarios pueden actualizar sus transacciones recurrentes; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Usuarios pueden actualizar sus transacciones recurrentes" ON public.recurring_transaction FOR UPDATE USING ((auth.uid() = user_id));


--
-- Name: transfer Usuarios pueden actualizar sus transferencias; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Usuarios pueden actualizar sus transferencias" ON public.transfer FOR UPDATE USING ((auth.uid() = user_id));


--
-- Name: jar_balance Usuarios pueden crear balances; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Usuarios pueden crear balances" ON public.jar_balance FOR INSERT WITH CHECK ((auth.uid() = user_id));


--
-- Name: category Usuarios pueden crear categorías; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Usuarios pueden crear categorías" ON public.category FOR INSERT WITH CHECK ((auth.role() = 'authenticated'::text));


--
-- Name: account Usuarios pueden crear cuentas; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Usuarios pueden crear cuentas" ON public.account FOR INSERT WITH CHECK ((auth.uid() = user_id));


--
-- Name: financial_goal Usuarios pueden crear metas; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Usuarios pueden crear metas" ON public.financial_goal FOR INSERT WITH CHECK ((auth.uid() = user_id));


--
-- Name: balance_history Usuarios pueden crear registros históricos; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Usuarios pueden crear registros históricos" ON public.balance_history FOR INSERT WITH CHECK ((auth.uid() = user_id));


--
-- Name: subcategory Usuarios pueden crear subcategorías; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Usuarios pueden crear subcategorías" ON public.subcategory FOR INSERT WITH CHECK ((auth.role() = 'authenticated'::text));


--
-- Name: transaction Usuarios pueden crear transacciones; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Usuarios pueden crear transacciones" ON public.transaction FOR INSERT WITH CHECK ((auth.uid() = user_id));


--
-- Name: recurring_transaction Usuarios pueden crear transacciones recurrentes; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Usuarios pueden crear transacciones recurrentes" ON public.recurring_transaction FOR INSERT WITH CHECK ((auth.uid() = user_id));


--
-- Name: transfer Usuarios pueden crear transferencias; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Usuarios pueden crear transferencias" ON public.transfer FOR INSERT WITH CHECK ((auth.uid() = user_id));


--
-- Name: category Usuarios pueden eliminar categorías; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Usuarios pueden eliminar categorías" ON public.category FOR DELETE USING ((auth.role() = 'authenticated'::text));


--
-- Name: subcategory Usuarios pueden eliminar subcategorías; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Usuarios pueden eliminar subcategorías" ON public.subcategory FOR DELETE USING ((auth.role() = 'authenticated'::text));


--
-- Name: credit_card_statement Usuarios pueden ver estados de cuenta; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Usuarios pueden ver estados de cuenta" ON public.credit_card_statement FOR SELECT USING ((auth.uid() = ( SELECT a.user_id
   FROM (public.account a
     JOIN public.credit_card_details cc ON ((cc.account_id = a.id)))
  WHERE (cc.id = credit_card_statement.credit_card_id))));


--
-- Name: credit_card_interest_history Usuarios pueden ver historial de sus tarjetas; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Usuarios pueden ver historial de sus tarjetas" ON public.credit_card_interest_history FOR SELECT USING ((auth.uid() = ( SELECT a.user_id
   FROM (public.account a
     JOIN public.credit_card_details cc ON ((cc.account_id = a.id)))
  WHERE (cc.id = credit_card_interest_history.credit_card_id))));


--
-- Name: balance_history Usuarios pueden ver su historial; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Usuarios pueden ver su historial" ON public.balance_history FOR SELECT USING ((auth.uid() = user_id));


--
-- Name: app_user Usuarios pueden ver su perfil; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Usuarios pueden ver su perfil" ON public.app_user FOR SELECT USING ((auth.uid() = id));


--
-- Name: installment_purchase Usuarios pueden ver sus MSI; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Usuarios pueden ver sus MSI" ON public.installment_purchase FOR SELECT USING ((auth.uid() = ( SELECT a.user_id
   FROM (public.account a
     JOIN public.credit_card_details cc ON ((cc.account_id = a.id)))
  WHERE (cc.id = installment_purchase.credit_card_id))));


--
-- Name: jar_balance Usuarios pueden ver sus balances; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Usuarios pueden ver sus balances" ON public.jar_balance FOR SELECT USING ((auth.uid() = user_id));


--
-- Name: account Usuarios pueden ver sus cuentas; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Usuarios pueden ver sus cuentas" ON public.account FOR SELECT USING ((auth.uid() = user_id));


--
-- Name: financial_goal Usuarios pueden ver sus metas; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Usuarios pueden ver sus metas" ON public.financial_goal FOR SELECT USING ((auth.uid() = user_id));


--
-- Name: notification Usuarios pueden ver sus notificaciones; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Usuarios pueden ver sus notificaciones" ON public.notification FOR SELECT USING ((auth.uid() = user_id));


--
-- Name: credit_card_details Usuarios pueden ver sus tarjetas; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Usuarios pueden ver sus tarjetas" ON public.credit_card_details FOR SELECT USING ((auth.uid() = ( SELECT account.user_id
   FROM public.account
  WHERE (account.id = credit_card_details.account_id))));


--
-- Name: transaction Usuarios pueden ver sus transacciones; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Usuarios pueden ver sus transacciones" ON public.transaction FOR SELECT USING ((auth.uid() = user_id));


--
-- Name: recurring_transaction Usuarios pueden ver sus transacciones recurrentes; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Usuarios pueden ver sus transacciones recurrentes" ON public.recurring_transaction FOR SELECT USING ((auth.uid() = user_id));


--
-- Name: transfer Usuarios pueden ver sus transferencias; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Usuarios pueden ver sus transferencias" ON public.transfer FOR SELECT USING ((auth.uid() = user_id));


--
-- Name: account; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.account ENABLE ROW LEVEL SECURITY;

--
-- Name: account_type; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.account_type ENABLE ROW LEVEL SECURITY;

--
-- Name: app_user; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.app_user ENABLE ROW LEVEL SECURITY;

--
-- Name: balance_history; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.balance_history ENABLE ROW LEVEL SECURITY;

--
-- Name: category; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.category ENABLE ROW LEVEL SECURITY;

--
-- Name: credit_card_details; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.credit_card_details ENABLE ROW LEVEL SECURITY;

--
-- Name: credit_card_interest_history; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.credit_card_interest_history ENABLE ROW LEVEL SECURITY;

--
-- Name: credit_card_statement; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.credit_card_statement ENABLE ROW LEVEL SECURITY;

--
-- Name: currency; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.currency ENABLE ROW LEVEL SECURITY;

--
-- Name: financial_goal; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.financial_goal ENABLE ROW LEVEL SECURITY;

--
-- Name: installment_purchase; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.installment_purchase ENABLE ROW LEVEL SECURITY;

--
-- Name: jar; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.jar ENABLE ROW LEVEL SECURITY;

--
-- Name: jar_balance; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.jar_balance ENABLE ROW LEVEL SECURITY;

--
-- Name: notification; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.notification ENABLE ROW LEVEL SECURITY;

--
-- Name: recurring_transaction; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.recurring_transaction ENABLE ROW LEVEL SECURITY;

--
-- Name: subcategory; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.subcategory ENABLE ROW LEVEL SECURITY;

--
-- Name: transaction; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.transaction ENABLE ROW LEVEL SECURITY;

--
-- Name: transaction_medium; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.transaction_medium ENABLE ROW LEVEL SECURITY;

--
-- Name: transaction_type; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.transaction_type ENABLE ROW LEVEL SECURITY;

--
-- Name: transfer; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.transfer ENABLE ROW LEVEL SECURITY;

--
-- Name: messages; Type: ROW SECURITY; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER TABLE realtime.messages ENABLE ROW LEVEL SECURITY;

--
-- Name: objects Public Access; Type: POLICY; Schema: storage; Owner: supabase_storage_admin
--

CREATE POLICY "Public Access" ON storage.objects FOR SELECT USING ((bucket_id = 'avatars'::text));


--
-- Name: buckets; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.buckets ENABLE ROW LEVEL SECURITY;

--
-- Name: migrations; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.migrations ENABLE ROW LEVEL SECURITY;

--
-- Name: objects; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

--
-- Name: s3_multipart_uploads; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.s3_multipart_uploads ENABLE ROW LEVEL SECURITY;

--
-- Name: s3_multipart_uploads_parts; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.s3_multipart_uploads_parts ENABLE ROW LEVEL SECURITY;

--
-- Name: supabase_realtime; Type: PUBLICATION; Schema: -; Owner: postgres
--

CREATE PUBLICATION supabase_realtime WITH (publish = 'insert, update, delete, truncate');


ALTER PUBLICATION supabase_realtime OWNER TO postgres;

--
-- Name: SCHEMA auth; Type: ACL; Schema: -; Owner: supabase_admin
--

GRANT USAGE ON SCHEMA auth TO anon;
GRANT USAGE ON SCHEMA auth TO authenticated;
GRANT USAGE ON SCHEMA auth TO service_role;
GRANT ALL ON SCHEMA auth TO supabase_auth_admin;
GRANT ALL ON SCHEMA auth TO dashboard_user;
GRANT ALL ON SCHEMA auth TO postgres;


--
-- Name: SCHEMA cron; Type: ACL; Schema: -; Owner: supabase_admin
--

GRANT USAGE ON SCHEMA cron TO postgres WITH GRANT OPTION;


--
-- Name: SCHEMA extensions; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA extensions TO anon;
GRANT USAGE ON SCHEMA extensions TO authenticated;
GRANT USAGE ON SCHEMA extensions TO service_role;
GRANT ALL ON SCHEMA extensions TO dashboard_user;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner
--

GRANT USAGE ON SCHEMA public TO postgres;
GRANT USAGE ON SCHEMA public TO anon;
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT USAGE ON SCHEMA public TO service_role;


--
-- Name: SCHEMA realtime; Type: ACL; Schema: -; Owner: supabase_admin
--

GRANT USAGE ON SCHEMA realtime TO postgres;
GRANT USAGE ON SCHEMA realtime TO anon;
GRANT USAGE ON SCHEMA realtime TO authenticated;
GRANT USAGE ON SCHEMA realtime TO service_role;
GRANT ALL ON SCHEMA realtime TO supabase_realtime_admin;


--
-- Name: SCHEMA storage; Type: ACL; Schema: -; Owner: supabase_admin
--

GRANT ALL ON SCHEMA storage TO postgres;
GRANT USAGE ON SCHEMA storage TO anon;
GRANT USAGE ON SCHEMA storage TO authenticated;
GRANT USAGE ON SCHEMA storage TO service_role;
GRANT ALL ON SCHEMA storage TO supabase_storage_admin;
GRANT ALL ON SCHEMA storage TO dashboard_user;


--
-- Name: FUNCTION change_password_by_email(user_email text, new_password text); Type: ACL; Schema: auth; Owner: postgres
--

GRANT ALL ON FUNCTION auth.change_password_by_email(user_email text, new_password text) TO authenticated;


--
-- Name: FUNCTION email(); Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON FUNCTION auth.email() TO dashboard_user;


--
-- Name: FUNCTION jwt(); Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON FUNCTION auth.jwt() TO postgres;
GRANT ALL ON FUNCTION auth.jwt() TO dashboard_user;


--
-- Name: FUNCTION role(); Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON FUNCTION auth.role() TO dashboard_user;


--
-- Name: FUNCTION uid(); Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON FUNCTION auth.uid() TO dashboard_user;


--
-- Name: FUNCTION alter_job(job_id bigint, schedule text, command text, database text, username text, active boolean); Type: ACL; Schema: cron; Owner: supabase_admin
--

GRANT ALL ON FUNCTION cron.alter_job(job_id bigint, schedule text, command text, database text, username text, active boolean) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION job_cache_invalidate(); Type: ACL; Schema: cron; Owner: supabase_admin
--

GRANT ALL ON FUNCTION cron.job_cache_invalidate() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION schedule(schedule text, command text); Type: ACL; Schema: cron; Owner: supabase_admin
--

GRANT ALL ON FUNCTION cron.schedule(schedule text, command text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION schedule(job_name text, schedule text, command text); Type: ACL; Schema: cron; Owner: supabase_admin
--

GRANT ALL ON FUNCTION cron.schedule(job_name text, schedule text, command text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION schedule_in_database(job_name text, schedule text, command text, database text, username text, active boolean); Type: ACL; Schema: cron; Owner: supabase_admin
--

GRANT ALL ON FUNCTION cron.schedule_in_database(job_name text, schedule text, command text, database text, username text, active boolean) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION unschedule(job_id bigint); Type: ACL; Schema: cron; Owner: supabase_admin
--

GRANT ALL ON FUNCTION cron.unschedule(job_id bigint) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION unschedule(job_name text); Type: ACL; Schema: cron; Owner: supabase_admin
--

GRANT ALL ON FUNCTION cron.unschedule(job_name text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION algorithm_sign(signables text, secret text, algorithm text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.algorithm_sign(signables text, secret text, algorithm text) FROM postgres;
GRANT ALL ON FUNCTION extensions.algorithm_sign(signables text, secret text, algorithm text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.algorithm_sign(signables text, secret text, algorithm text) TO dashboard_user;


--
-- Name: FUNCTION armor(bytea); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.armor(bytea) FROM postgres;
GRANT ALL ON FUNCTION extensions.armor(bytea) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.armor(bytea) TO dashboard_user;


--
-- Name: FUNCTION armor(bytea, text[], text[]); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.armor(bytea, text[], text[]) FROM postgres;
GRANT ALL ON FUNCTION extensions.armor(bytea, text[], text[]) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.armor(bytea, text[], text[]) TO dashboard_user;


--
-- Name: FUNCTION crypt(text, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.crypt(text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.crypt(text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.crypt(text, text) TO dashboard_user;


--
-- Name: FUNCTION dearmor(text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.dearmor(text) FROM postgres;
GRANT ALL ON FUNCTION extensions.dearmor(text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.dearmor(text) TO dashboard_user;


--
-- Name: FUNCTION decrypt(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.decrypt(bytea, bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.decrypt(bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.decrypt(bytea, bytea, text) TO dashboard_user;


--
-- Name: FUNCTION decrypt_iv(bytea, bytea, bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.decrypt_iv(bytea, bytea, bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.decrypt_iv(bytea, bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.decrypt_iv(bytea, bytea, bytea, text) TO dashboard_user;


--
-- Name: FUNCTION digest(bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.digest(bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.digest(bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.digest(bytea, text) TO dashboard_user;


--
-- Name: FUNCTION digest(text, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.digest(text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.digest(text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.digest(text, text) TO dashboard_user;


--
-- Name: FUNCTION encrypt(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.encrypt(bytea, bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.encrypt(bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.encrypt(bytea, bytea, text) TO dashboard_user;


--
-- Name: FUNCTION encrypt_iv(bytea, bytea, bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.encrypt_iv(bytea, bytea, bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.encrypt_iv(bytea, bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.encrypt_iv(bytea, bytea, bytea, text) TO dashboard_user;


--
-- Name: FUNCTION gen_random_bytes(integer); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.gen_random_bytes(integer) FROM postgres;
GRANT ALL ON FUNCTION extensions.gen_random_bytes(integer) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.gen_random_bytes(integer) TO dashboard_user;


--
-- Name: FUNCTION gen_random_uuid(); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.gen_random_uuid() FROM postgres;
GRANT ALL ON FUNCTION extensions.gen_random_uuid() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.gen_random_uuid() TO dashboard_user;


--
-- Name: FUNCTION gen_salt(text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.gen_salt(text) FROM postgres;
GRANT ALL ON FUNCTION extensions.gen_salt(text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.gen_salt(text) TO dashboard_user;


--
-- Name: FUNCTION gen_salt(text, integer); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.gen_salt(text, integer) FROM postgres;
GRANT ALL ON FUNCTION extensions.gen_salt(text, integer) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.gen_salt(text, integer) TO dashboard_user;


--
-- Name: FUNCTION grant_pg_cron_access(); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.grant_pg_cron_access() FROM postgres;
GRANT ALL ON FUNCTION extensions.grant_pg_cron_access() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.grant_pg_cron_access() TO dashboard_user;


--
-- Name: FUNCTION grant_pg_graphql_access(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.grant_pg_graphql_access() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION grant_pg_net_access(); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.grant_pg_net_access() FROM postgres;
GRANT ALL ON FUNCTION extensions.grant_pg_net_access() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.grant_pg_net_access() TO dashboard_user;


--
-- Name: FUNCTION hmac(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.hmac(bytea, bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.hmac(bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.hmac(bytea, bytea, text) TO dashboard_user;


--
-- Name: FUNCTION hmac(text, text, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.hmac(text, text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.hmac(text, text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.hmac(text, text, text) TO dashboard_user;


--
-- Name: FUNCTION pg_stat_statements(showtext boolean, OUT userid oid, OUT dbid oid, OUT toplevel boolean, OUT queryid bigint, OUT query text, OUT plans bigint, OUT total_plan_time double precision, OUT min_plan_time double precision, OUT max_plan_time double precision, OUT mean_plan_time double precision, OUT stddev_plan_time double precision, OUT calls bigint, OUT total_exec_time double precision, OUT min_exec_time double precision, OUT max_exec_time double precision, OUT mean_exec_time double precision, OUT stddev_exec_time double precision, OUT rows bigint, OUT shared_blks_hit bigint, OUT shared_blks_read bigint, OUT shared_blks_dirtied bigint, OUT shared_blks_written bigint, OUT local_blks_hit bigint, OUT local_blks_read bigint, OUT local_blks_dirtied bigint, OUT local_blks_written bigint, OUT temp_blks_read bigint, OUT temp_blks_written bigint, OUT blk_read_time double precision, OUT blk_write_time double precision, OUT temp_blk_read_time double precision, OUT temp_blk_write_time double precision, OUT wal_records bigint, OUT wal_fpi bigint, OUT wal_bytes numeric, OUT jit_functions bigint, OUT jit_generation_time double precision, OUT jit_inlining_count bigint, OUT jit_inlining_time double precision, OUT jit_optimization_count bigint, OUT jit_optimization_time double precision, OUT jit_emission_count bigint, OUT jit_emission_time double precision); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pg_stat_statements(showtext boolean, OUT userid oid, OUT dbid oid, OUT toplevel boolean, OUT queryid bigint, OUT query text, OUT plans bigint, OUT total_plan_time double precision, OUT min_plan_time double precision, OUT max_plan_time double precision, OUT mean_plan_time double precision, OUT stddev_plan_time double precision, OUT calls bigint, OUT total_exec_time double precision, OUT min_exec_time double precision, OUT max_exec_time double precision, OUT mean_exec_time double precision, OUT stddev_exec_time double precision, OUT rows bigint, OUT shared_blks_hit bigint, OUT shared_blks_read bigint, OUT shared_blks_dirtied bigint, OUT shared_blks_written bigint, OUT local_blks_hit bigint, OUT local_blks_read bigint, OUT local_blks_dirtied bigint, OUT local_blks_written bigint, OUT temp_blks_read bigint, OUT temp_blks_written bigint, OUT blk_read_time double precision, OUT blk_write_time double precision, OUT temp_blk_read_time double precision, OUT temp_blk_write_time double precision, OUT wal_records bigint, OUT wal_fpi bigint, OUT wal_bytes numeric, OUT jit_functions bigint, OUT jit_generation_time double precision, OUT jit_inlining_count bigint, OUT jit_inlining_time double precision, OUT jit_optimization_count bigint, OUT jit_optimization_time double precision, OUT jit_emission_count bigint, OUT jit_emission_time double precision) FROM postgres;
GRANT ALL ON FUNCTION extensions.pg_stat_statements(showtext boolean, OUT userid oid, OUT dbid oid, OUT toplevel boolean, OUT queryid bigint, OUT query text, OUT plans bigint, OUT total_plan_time double precision, OUT min_plan_time double precision, OUT max_plan_time double precision, OUT mean_plan_time double precision, OUT stddev_plan_time double precision, OUT calls bigint, OUT total_exec_time double precision, OUT min_exec_time double precision, OUT max_exec_time double precision, OUT mean_exec_time double precision, OUT stddev_exec_time double precision, OUT rows bigint, OUT shared_blks_hit bigint, OUT shared_blks_read bigint, OUT shared_blks_dirtied bigint, OUT shared_blks_written bigint, OUT local_blks_hit bigint, OUT local_blks_read bigint, OUT local_blks_dirtied bigint, OUT local_blks_written bigint, OUT temp_blks_read bigint, OUT temp_blks_written bigint, OUT blk_read_time double precision, OUT blk_write_time double precision, OUT temp_blk_read_time double precision, OUT temp_blk_write_time double precision, OUT wal_records bigint, OUT wal_fpi bigint, OUT wal_bytes numeric, OUT jit_functions bigint, OUT jit_generation_time double precision, OUT jit_inlining_count bigint, OUT jit_inlining_time double precision, OUT jit_optimization_count bigint, OUT jit_optimization_time double precision, OUT jit_emission_count bigint, OUT jit_emission_time double precision) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pg_stat_statements(showtext boolean, OUT userid oid, OUT dbid oid, OUT toplevel boolean, OUT queryid bigint, OUT query text, OUT plans bigint, OUT total_plan_time double precision, OUT min_plan_time double precision, OUT max_plan_time double precision, OUT mean_plan_time double precision, OUT stddev_plan_time double precision, OUT calls bigint, OUT total_exec_time double precision, OUT min_exec_time double precision, OUT max_exec_time double precision, OUT mean_exec_time double precision, OUT stddev_exec_time double precision, OUT rows bigint, OUT shared_blks_hit bigint, OUT shared_blks_read bigint, OUT shared_blks_dirtied bigint, OUT shared_blks_written bigint, OUT local_blks_hit bigint, OUT local_blks_read bigint, OUT local_blks_dirtied bigint, OUT local_blks_written bigint, OUT temp_blks_read bigint, OUT temp_blks_written bigint, OUT blk_read_time double precision, OUT blk_write_time double precision, OUT temp_blk_read_time double precision, OUT temp_blk_write_time double precision, OUT wal_records bigint, OUT wal_fpi bigint, OUT wal_bytes numeric, OUT jit_functions bigint, OUT jit_generation_time double precision, OUT jit_inlining_count bigint, OUT jit_inlining_time double precision, OUT jit_optimization_count bigint, OUT jit_optimization_time double precision, OUT jit_emission_count bigint, OUT jit_emission_time double precision) TO dashboard_user;


--
-- Name: FUNCTION pg_stat_statements_info(OUT dealloc bigint, OUT stats_reset timestamp with time zone); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pg_stat_statements_info(OUT dealloc bigint, OUT stats_reset timestamp with time zone) FROM postgres;
GRANT ALL ON FUNCTION extensions.pg_stat_statements_info(OUT dealloc bigint, OUT stats_reset timestamp with time zone) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pg_stat_statements_info(OUT dealloc bigint, OUT stats_reset timestamp with time zone) TO dashboard_user;


--
-- Name: FUNCTION pg_stat_statements_reset(userid oid, dbid oid, queryid bigint); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pg_stat_statements_reset(userid oid, dbid oid, queryid bigint) FROM postgres;
GRANT ALL ON FUNCTION extensions.pg_stat_statements_reset(userid oid, dbid oid, queryid bigint) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pg_stat_statements_reset(userid oid, dbid oid, queryid bigint) TO dashboard_user;


--
-- Name: FUNCTION pgp_armor_headers(text, OUT key text, OUT value text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_armor_headers(text, OUT key text, OUT value text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_armor_headers(text, OUT key text, OUT value text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_armor_headers(text, OUT key text, OUT value text) TO dashboard_user;


--
-- Name: FUNCTION pgp_key_id(bytea); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_key_id(bytea) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_key_id(bytea) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_key_id(bytea) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_decrypt(bytea, bytea); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_decrypt(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_decrypt(bytea, bytea, text, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea, text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea, text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea, text, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_decrypt_bytea(bytea, bytea); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_decrypt_bytea(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_decrypt_bytea(bytea, bytea, text, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea, text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea, text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea, text, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_encrypt(text, bytea); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_pub_encrypt(text, bytea) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt(text, bytea) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt(text, bytea) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_encrypt(text, bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_pub_encrypt(text, bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt(text, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt(text, bytea, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_encrypt_bytea(bytea, bytea); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_pub_encrypt_bytea(bytea, bytea) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt_bytea(bytea, bytea) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt_bytea(bytea, bytea) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_encrypt_bytea(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_pub_encrypt_bytea(bytea, bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt_bytea(bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt_bytea(bytea, bytea, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_sym_decrypt(bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_sym_decrypt(bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt(bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt(bytea, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_sym_decrypt(bytea, text, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_sym_decrypt(bytea, text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt(bytea, text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt(bytea, text, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_sym_decrypt_bytea(bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_sym_decrypt_bytea(bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt_bytea(bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt_bytea(bytea, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_sym_decrypt_bytea(bytea, text, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_sym_decrypt_bytea(bytea, text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt_bytea(bytea, text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt_bytea(bytea, text, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_sym_encrypt(text, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_sym_encrypt(text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt(text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt(text, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_sym_encrypt(text, text, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_sym_encrypt(text, text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt(text, text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt(text, text, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_sym_encrypt_bytea(bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_sym_encrypt_bytea(bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt_bytea(bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt_bytea(bytea, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_sym_encrypt_bytea(bytea, text, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_sym_encrypt_bytea(bytea, text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt_bytea(bytea, text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt_bytea(bytea, text, text) TO dashboard_user;


--
-- Name: FUNCTION pgrst_ddl_watch(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgrst_ddl_watch() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgrst_drop_watch(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgrst_drop_watch() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION set_graphql_placeholder(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.set_graphql_placeholder() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION sign(payload json, secret text, algorithm text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.sign(payload json, secret text, algorithm text) FROM postgres;
GRANT ALL ON FUNCTION extensions.sign(payload json, secret text, algorithm text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.sign(payload json, secret text, algorithm text) TO dashboard_user;


--
-- Name: FUNCTION try_cast_double(inp text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.try_cast_double(inp text) FROM postgres;
GRANT ALL ON FUNCTION extensions.try_cast_double(inp text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.try_cast_double(inp text) TO dashboard_user;


--
-- Name: FUNCTION url_decode(data text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.url_decode(data text) FROM postgres;
GRANT ALL ON FUNCTION extensions.url_decode(data text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.url_decode(data text) TO dashboard_user;


--
-- Name: FUNCTION url_encode(data bytea); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.url_encode(data bytea) FROM postgres;
GRANT ALL ON FUNCTION extensions.url_encode(data bytea) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.url_encode(data bytea) TO dashboard_user;


--
-- Name: FUNCTION uuid_generate_v1(); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.uuid_generate_v1() FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_generate_v1() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_generate_v1() TO dashboard_user;


--
-- Name: FUNCTION uuid_generate_v1mc(); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.uuid_generate_v1mc() FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_generate_v1mc() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_generate_v1mc() TO dashboard_user;


--
-- Name: FUNCTION uuid_generate_v3(namespace uuid, name text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.uuid_generate_v3(namespace uuid, name text) FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_generate_v3(namespace uuid, name text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_generate_v3(namespace uuid, name text) TO dashboard_user;


--
-- Name: FUNCTION uuid_generate_v4(); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.uuid_generate_v4() FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_generate_v4() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_generate_v4() TO dashboard_user;


--
-- Name: FUNCTION uuid_generate_v5(namespace uuid, name text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.uuid_generate_v5(namespace uuid, name text) FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_generate_v5(namespace uuid, name text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_generate_v5(namespace uuid, name text) TO dashboard_user;


--
-- Name: FUNCTION uuid_nil(); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.uuid_nil() FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_nil() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_nil() TO dashboard_user;


--
-- Name: FUNCTION uuid_ns_dns(); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.uuid_ns_dns() FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_ns_dns() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_ns_dns() TO dashboard_user;


--
-- Name: FUNCTION uuid_ns_oid(); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.uuid_ns_oid() FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_ns_oid() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_ns_oid() TO dashboard_user;


--
-- Name: FUNCTION uuid_ns_url(); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.uuid_ns_url() FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_ns_url() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_ns_url() TO dashboard_user;


--
-- Name: FUNCTION uuid_ns_x500(); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.uuid_ns_x500() FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_ns_x500() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_ns_x500() TO dashboard_user;


--
-- Name: FUNCTION verify(token text, secret text, algorithm text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.verify(token text, secret text, algorithm text) FROM postgres;
GRANT ALL ON FUNCTION extensions.verify(token text, secret text, algorithm text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.verify(token text, secret text, algorithm text) TO dashboard_user;


--
-- Name: FUNCTION graphql("operationName" text, query text, variables jsonb, extensions jsonb); Type: ACL; Schema: graphql_public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION graphql_public.graphql("operationName" text, query text, variables jsonb, extensions jsonb) TO postgres;
GRANT ALL ON FUNCTION graphql_public.graphql("operationName" text, query text, variables jsonb, extensions jsonb) TO anon;
GRANT ALL ON FUNCTION graphql_public.graphql("operationName" text, query text, variables jsonb, extensions jsonb) TO authenticated;
GRANT ALL ON FUNCTION graphql_public.graphql("operationName" text, query text, variables jsonb, extensions jsonb) TO service_role;


--
-- Name: FUNCTION get_auth(p_usename text); Type: ACL; Schema: pgbouncer; Owner: postgres
--

REVOKE ALL ON FUNCTION pgbouncer.get_auth(p_usename text) FROM PUBLIC;
GRANT ALL ON FUNCTION pgbouncer.get_auth(p_usename text) TO pgbouncer;


--
-- Name: FUNCTION crypto_aead_det_decrypt(message bytea, additional bytea, key_uuid uuid, nonce bytea); Type: ACL; Schema: pgsodium; Owner: pgsodium_keymaker
--

GRANT ALL ON FUNCTION pgsodium.crypto_aead_det_decrypt(message bytea, additional bytea, key_uuid uuid, nonce bytea) TO service_role;


--
-- Name: FUNCTION crypto_aead_det_encrypt(message bytea, additional bytea, key_uuid uuid, nonce bytea); Type: ACL; Schema: pgsodium; Owner: pgsodium_keymaker
--

GRANT ALL ON FUNCTION pgsodium.crypto_aead_det_encrypt(message bytea, additional bytea, key_uuid uuid, nonce bytea) TO service_role;


--
-- Name: FUNCTION crypto_aead_det_keygen(); Type: ACL; Schema: pgsodium; Owner: supabase_admin
--

GRANT ALL ON FUNCTION pgsodium.crypto_aead_det_keygen() TO service_role;


--
-- Name: FUNCTION archive_completed_goals(p_days_threshold integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.archive_completed_goals(p_days_threshold integer) TO anon;
GRANT ALL ON FUNCTION public.archive_completed_goals(p_days_threshold integer) TO authenticated;
GRANT ALL ON FUNCTION public.archive_completed_goals(p_days_threshold integer) TO service_role;


--
-- Name: FUNCTION calculate_goal_progress(p_current_amount numeric, p_target_amount numeric, p_start_date date, p_target_date date); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.calculate_goal_progress(p_current_amount numeric, p_target_amount numeric, p_start_date date, p_target_date date) TO anon;
GRANT ALL ON FUNCTION public.calculate_goal_progress(p_current_amount numeric, p_target_amount numeric, p_start_date date, p_target_date date) TO authenticated;
GRANT ALL ON FUNCTION public.calculate_goal_progress(p_current_amount numeric, p_target_amount numeric, p_start_date date, p_target_date date) TO service_role;


--
-- Name: FUNCTION calculate_next_cut_off_date(p_cut_off_day integer, p_from_date date); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.calculate_next_cut_off_date(p_cut_off_day integer, p_from_date date) TO anon;
GRANT ALL ON FUNCTION public.calculate_next_cut_off_date(p_cut_off_day integer, p_from_date date) TO authenticated;
GRANT ALL ON FUNCTION public.calculate_next_cut_off_date(p_cut_off_day integer, p_from_date date) TO service_role;


--
-- Name: FUNCTION calculate_next_execution_date(p_frequency character varying, p_start_date date, p_last_execution date); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.calculate_next_execution_date(p_frequency character varying, p_start_date date, p_last_execution date) TO anon;
GRANT ALL ON FUNCTION public.calculate_next_execution_date(p_frequency character varying, p_start_date date, p_last_execution date) TO authenticated;
GRANT ALL ON FUNCTION public.calculate_next_execution_date(p_frequency character varying, p_start_date date, p_last_execution date) TO service_role;


--
-- Name: FUNCTION calculate_next_payment_date(p_payment_day integer, p_cut_off_date date); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.calculate_next_payment_date(p_payment_day integer, p_cut_off_date date) TO anon;
GRANT ALL ON FUNCTION public.calculate_next_payment_date(p_payment_day integer, p_cut_off_date date) TO authenticated;
GRANT ALL ON FUNCTION public.calculate_next_payment_date(p_payment_day integer, p_cut_off_date date) TO service_role;


--
-- Name: FUNCTION export_transactions_to_excel(p_user_id uuid, p_start_date date, p_end_date date); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.export_transactions_to_excel(p_user_id uuid, p_start_date date, p_end_date date) TO anon;
GRANT ALL ON FUNCTION public.export_transactions_to_excel(p_user_id uuid, p_start_date date, p_end_date date) TO authenticated;
GRANT ALL ON FUNCTION public.export_transactions_to_excel(p_user_id uuid, p_start_date date, p_end_date date) TO service_role;


--
-- Name: FUNCTION generate_credit_card_statement(p_credit_card_id uuid, p_statement_date date); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.generate_credit_card_statement(p_credit_card_id uuid, p_statement_date date) TO anon;
GRANT ALL ON FUNCTION public.generate_credit_card_statement(p_credit_card_id uuid, p_statement_date date) TO authenticated;
GRANT ALL ON FUNCTION public.generate_credit_card_statement(p_credit_card_id uuid, p_statement_date date) TO service_role;


--
-- Name: FUNCTION get_credit_card_statements(p_account_id uuid, p_months integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.get_credit_card_statements(p_account_id uuid, p_months integer) TO anon;
GRANT ALL ON FUNCTION public.get_credit_card_statements(p_account_id uuid, p_months integer) TO authenticated;
GRANT ALL ON FUNCTION public.get_credit_card_statements(p_account_id uuid, p_months integer) TO service_role;


--
-- Name: FUNCTION get_transfer_history(p_user_id uuid, p_start_date date, p_end_date date, p_transfer_type text, p_limit integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.get_transfer_history(p_user_id uuid, p_start_date date, p_end_date date, p_transfer_type text, p_limit integer) TO anon;
GRANT ALL ON FUNCTION public.get_transfer_history(p_user_id uuid, p_start_date date, p_end_date date, p_transfer_type text, p_limit integer) TO authenticated;
GRANT ALL ON FUNCTION public.get_transfer_history(p_user_id uuid, p_start_date date, p_end_date date, p_transfer_type text, p_limit integer) TO service_role;


--
-- Name: FUNCTION get_upcoming_recurring_transactions(p_user_id uuid, p_days integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.get_upcoming_recurring_transactions(p_user_id uuid, p_days integer) TO anon;
GRANT ALL ON FUNCTION public.get_upcoming_recurring_transactions(p_user_id uuid, p_days integer) TO authenticated;
GRANT ALL ON FUNCTION public.get_upcoming_recurring_transactions(p_user_id uuid, p_days integer) TO service_role;


--
-- Name: FUNCTION handle_new_user(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.handle_new_user() TO anon;
GRANT ALL ON FUNCTION public.handle_new_user() TO authenticated;
GRANT ALL ON FUNCTION public.handle_new_user() TO service_role;


--
-- Name: FUNCTION notify_credit_card_events(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.notify_credit_card_events() TO anon;
GRANT ALL ON FUNCTION public.notify_credit_card_events() TO authenticated;
GRANT ALL ON FUNCTION public.notify_credit_card_events() TO service_role;


--
-- Name: FUNCTION notify_transfer(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.notify_transfer() TO anon;
GRANT ALL ON FUNCTION public.notify_transfer() TO authenticated;
GRANT ALL ON FUNCTION public.notify_transfer() TO service_role;


--
-- Name: FUNCTION process_recurring_transactions(p_date date); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.process_recurring_transactions(p_date date) TO anon;
GRANT ALL ON FUNCTION public.process_recurring_transactions(p_date date) TO authenticated;
GRANT ALL ON FUNCTION public.process_recurring_transactions(p_date date) TO service_role;


--
-- Name: FUNCTION reactivate_recurring_transaction(p_transaction_id uuid, p_new_start_date date); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.reactivate_recurring_transaction(p_transaction_id uuid, p_new_start_date date) TO anon;
GRANT ALL ON FUNCTION public.reactivate_recurring_transaction(p_transaction_id uuid, p_new_start_date date) TO authenticated;
GRANT ALL ON FUNCTION public.reactivate_recurring_transaction(p_transaction_id uuid, p_new_start_date date) TO service_role;


--
-- Name: FUNCTION record_balance_history(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.record_balance_history() TO anon;
GRANT ALL ON FUNCTION public.record_balance_history() TO authenticated;
GRANT ALL ON FUNCTION public.record_balance_history() TO service_role;


--
-- Name: FUNCTION remove_transaction_tag(p_transaction_id uuid, p_tag text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.remove_transaction_tag(p_transaction_id uuid, p_tag text) TO anon;
GRANT ALL ON FUNCTION public.remove_transaction_tag(p_transaction_id uuid, p_tag text) TO authenticated;
GRANT ALL ON FUNCTION public.remove_transaction_tag(p_transaction_id uuid, p_tag text) TO service_role;


--
-- Name: FUNCTION search_transactions_by_notes(p_user_id uuid, p_search_text text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.search_transactions_by_notes(p_user_id uuid, p_search_text text) TO anon;
GRANT ALL ON FUNCTION public.search_transactions_by_notes(p_user_id uuid, p_search_text text) TO authenticated;
GRANT ALL ON FUNCTION public.search_transactions_by_notes(p_user_id uuid, p_search_text text) TO service_role;


--
-- Name: FUNCTION search_transactions_by_tags(p_user_id uuid, p_tags text[]); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.search_transactions_by_tags(p_user_id uuid, p_tags text[]) TO anon;
GRANT ALL ON FUNCTION public.search_transactions_by_tags(p_user_id uuid, p_tags text[]) TO authenticated;
GRANT ALL ON FUNCTION public.search_transactions_by_tags(p_user_id uuid, p_tags text[]) TO service_role;


--
-- Name: FUNCTION track_interest_rate_changes(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.track_interest_rate_changes() TO anon;
GRANT ALL ON FUNCTION public.track_interest_rate_changes() TO authenticated;
GRANT ALL ON FUNCTION public.track_interest_rate_changes() TO service_role;


--
-- Name: FUNCTION update_installment_purchases(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.update_installment_purchases() TO anon;
GRANT ALL ON FUNCTION public.update_installment_purchases() TO authenticated;
GRANT ALL ON FUNCTION public.update_installment_purchases() TO service_role;


--
-- Name: FUNCTION update_modified_timestamp(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.update_modified_timestamp() TO anon;
GRANT ALL ON FUNCTION public.update_modified_timestamp() TO authenticated;
GRANT ALL ON FUNCTION public.update_modified_timestamp() TO service_role;


--
-- Name: FUNCTION validate_recurring_transaction(p_user_id uuid, p_amount numeric, p_transaction_type_id uuid, p_account_id uuid, p_jar_id uuid); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.validate_recurring_transaction(p_user_id uuid, p_amount numeric, p_transaction_type_id uuid, p_account_id uuid, p_jar_id uuid) TO anon;
GRANT ALL ON FUNCTION public.validate_recurring_transaction(p_user_id uuid, p_amount numeric, p_transaction_type_id uuid, p_account_id uuid, p_jar_id uuid) TO authenticated;
GRANT ALL ON FUNCTION public.validate_recurring_transaction(p_user_id uuid, p_amount numeric, p_transaction_type_id uuid, p_account_id uuid, p_jar_id uuid) TO service_role;


--
-- Name: FUNCTION apply_rls(wal jsonb, max_record_bytes integer); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO postgres;
GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO anon;
GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO authenticated;
GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO service_role;
GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO supabase_realtime_admin;


--
-- Name: FUNCTION broadcast_changes(topic_name text, event_name text, operation text, table_name text, table_schema text, new record, old record, level text); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.broadcast_changes(topic_name text, event_name text, operation text, table_name text, table_schema text, new record, old record, level text) TO postgres;
GRANT ALL ON FUNCTION realtime.broadcast_changes(topic_name text, event_name text, operation text, table_name text, table_schema text, new record, old record, level text) TO dashboard_user;


--
-- Name: FUNCTION build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) TO postgres;
GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) TO anon;
GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) TO authenticated;
GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) TO service_role;
GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) TO supabase_realtime_admin;


--
-- Name: FUNCTION "cast"(val text, type_ regtype); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO postgres;
GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO dashboard_user;
GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO anon;
GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO authenticated;
GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO service_role;
GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO supabase_realtime_admin;


--
-- Name: FUNCTION check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO postgres;
GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO anon;
GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO authenticated;
GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO service_role;
GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO supabase_realtime_admin;


--
-- Name: FUNCTION is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO postgres;
GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO anon;
GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO authenticated;
GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO service_role;
GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO supabase_realtime_admin;


--
-- Name: FUNCTION list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) TO postgres;
GRANT ALL ON FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) TO anon;
GRANT ALL ON FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) TO authenticated;
GRANT ALL ON FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) TO service_role;
GRANT ALL ON FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) TO supabase_realtime_admin;


--
-- Name: FUNCTION quote_wal2json(entity regclass); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO postgres;
GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO anon;
GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO authenticated;
GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO service_role;
GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO supabase_realtime_admin;


--
-- Name: FUNCTION send(payload jsonb, event text, topic text, private boolean); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.send(payload jsonb, event text, topic text, private boolean) TO postgres;
GRANT ALL ON FUNCTION realtime.send(payload jsonb, event text, topic text, private boolean) TO dashboard_user;


--
-- Name: FUNCTION subscription_check_filters(); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO postgres;
GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO dashboard_user;
GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO anon;
GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO authenticated;
GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO service_role;
GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO supabase_realtime_admin;


--
-- Name: FUNCTION to_regrole(role_name text); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO postgres;
GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO anon;
GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO authenticated;
GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO service_role;
GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO supabase_realtime_admin;


--
-- Name: FUNCTION topic(); Type: ACL; Schema: realtime; Owner: supabase_realtime_admin
--

GRANT ALL ON FUNCTION realtime.topic() TO postgres;
GRANT ALL ON FUNCTION realtime.topic() TO dashboard_user;


--
-- Name: TABLE audit_log_entries; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.audit_log_entries TO dashboard_user;
GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.audit_log_entries TO postgres;
GRANT SELECT ON TABLE auth.audit_log_entries TO postgres WITH GRANT OPTION;


--
-- Name: TABLE flow_state; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.flow_state TO postgres;
GRANT SELECT ON TABLE auth.flow_state TO postgres WITH GRANT OPTION;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.flow_state TO dashboard_user;


--
-- Name: TABLE identities; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.identities TO postgres;
GRANT SELECT ON TABLE auth.identities TO postgres WITH GRANT OPTION;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.identities TO dashboard_user;


--
-- Name: TABLE instances; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.instances TO dashboard_user;
GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.instances TO postgres;
GRANT SELECT ON TABLE auth.instances TO postgres WITH GRANT OPTION;


--
-- Name: TABLE mfa_amr_claims; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.mfa_amr_claims TO postgres;
GRANT SELECT ON TABLE auth.mfa_amr_claims TO postgres WITH GRANT OPTION;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.mfa_amr_claims TO dashboard_user;


--
-- Name: TABLE mfa_challenges; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.mfa_challenges TO postgres;
GRANT SELECT ON TABLE auth.mfa_challenges TO postgres WITH GRANT OPTION;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.mfa_challenges TO dashboard_user;


--
-- Name: TABLE mfa_factors; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.mfa_factors TO postgres;
GRANT SELECT ON TABLE auth.mfa_factors TO postgres WITH GRANT OPTION;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.mfa_factors TO dashboard_user;


--
-- Name: TABLE one_time_tokens; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.one_time_tokens TO postgres;
GRANT SELECT ON TABLE auth.one_time_tokens TO postgres WITH GRANT OPTION;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.one_time_tokens TO dashboard_user;


--
-- Name: TABLE refresh_tokens; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.refresh_tokens TO dashboard_user;
GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.refresh_tokens TO postgres;
GRANT SELECT ON TABLE auth.refresh_tokens TO postgres WITH GRANT OPTION;


--
-- Name: SEQUENCE refresh_tokens_id_seq; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON SEQUENCE auth.refresh_tokens_id_seq TO dashboard_user;
GRANT ALL ON SEQUENCE auth.refresh_tokens_id_seq TO postgres;


--
-- Name: TABLE saml_providers; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.saml_providers TO postgres;
GRANT SELECT ON TABLE auth.saml_providers TO postgres WITH GRANT OPTION;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.saml_providers TO dashboard_user;


--
-- Name: TABLE saml_relay_states; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.saml_relay_states TO postgres;
GRANT SELECT ON TABLE auth.saml_relay_states TO postgres WITH GRANT OPTION;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.saml_relay_states TO dashboard_user;


--
-- Name: TABLE schema_migrations; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.schema_migrations TO dashboard_user;
GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.schema_migrations TO postgres;
GRANT SELECT ON TABLE auth.schema_migrations TO postgres WITH GRANT OPTION;


--
-- Name: TABLE sessions; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.sessions TO postgres;
GRANT SELECT ON TABLE auth.sessions TO postgres WITH GRANT OPTION;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.sessions TO dashboard_user;


--
-- Name: TABLE sso_domains; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.sso_domains TO postgres;
GRANT SELECT ON TABLE auth.sso_domains TO postgres WITH GRANT OPTION;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.sso_domains TO dashboard_user;


--
-- Name: TABLE sso_providers; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.sso_providers TO postgres;
GRANT SELECT ON TABLE auth.sso_providers TO postgres WITH GRANT OPTION;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.sso_providers TO dashboard_user;


--
-- Name: TABLE users; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.users TO dashboard_user;
GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.users TO postgres;
GRANT SELECT ON TABLE auth.users TO postgres WITH GRANT OPTION;


--
-- Name: TABLE job; Type: ACL; Schema: cron; Owner: supabase_admin
--

GRANT SELECT ON TABLE cron.job TO postgres WITH GRANT OPTION;


--
-- Name: TABLE job_run_details; Type: ACL; Schema: cron; Owner: supabase_admin
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE cron.job_run_details TO postgres WITH GRANT OPTION;


--
-- Name: TABLE pg_stat_statements; Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE extensions.pg_stat_statements FROM postgres;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE extensions.pg_stat_statements TO postgres WITH GRANT OPTION;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE extensions.pg_stat_statements TO dashboard_user;


--
-- Name: TABLE pg_stat_statements_info; Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE extensions.pg_stat_statements_info FROM postgres;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE extensions.pg_stat_statements_info TO postgres WITH GRANT OPTION;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE extensions.pg_stat_statements_info TO dashboard_user;


--
-- Name: TABLE decrypted_key; Type: ACL; Schema: pgsodium; Owner: supabase_admin
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE pgsodium.decrypted_key TO pgsodium_keyholder;


--
-- Name: TABLE masking_rule; Type: ACL; Schema: pgsodium; Owner: supabase_admin
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE pgsodium.masking_rule TO pgsodium_keyholder;


--
-- Name: TABLE mask_columns; Type: ACL; Schema: pgsodium; Owner: supabase_admin
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE pgsodium.mask_columns TO pgsodium_keyholder;


--
-- Name: TABLE account; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.account TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.account TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.account TO service_role;


--
-- Name: TABLE account_type; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.account_type TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.account_type TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.account_type TO service_role;


--
-- Name: TABLE app_user; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.app_user TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.app_user TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.app_user TO service_role;


--
-- Name: TABLE balance_history; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.balance_history TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.balance_history TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.balance_history TO service_role;


--
-- Name: TABLE category; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.category TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.category TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.category TO service_role;


--
-- Name: TABLE credit_card_details; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.credit_card_details TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.credit_card_details TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.credit_card_details TO service_role;


--
-- Name: TABLE credit_card_interest_history; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.credit_card_interest_history TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.credit_card_interest_history TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.credit_card_interest_history TO service_role;


--
-- Name: TABLE credit_card_statement; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.credit_card_statement TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.credit_card_statement TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.credit_card_statement TO service_role;


--
-- Name: TABLE currency; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.currency TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.currency TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.currency TO service_role;


--
-- Name: TABLE transaction; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.transaction TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.transaction TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.transaction TO service_role;


--
-- Name: TABLE transaction_type; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.transaction_type TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.transaction_type TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.transaction_type TO service_role;


--
-- Name: TABLE expense_trends_analysis; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.expense_trends_analysis TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.expense_trends_analysis TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.expense_trends_analysis TO service_role;


--
-- Name: TABLE financial_goal; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.financial_goal TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.financial_goal TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.financial_goal TO service_role;


--
-- Name: TABLE foreign_keys; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.foreign_keys TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.foreign_keys TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.foreign_keys TO service_role;


--
-- Name: TABLE jar; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.jar TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.jar TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.jar TO service_role;


--
-- Name: TABLE goal_progress_summary; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.goal_progress_summary TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.goal_progress_summary TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.goal_progress_summary TO service_role;


--
-- Name: TABLE installment_purchase; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.installment_purchase TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.installment_purchase TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.installment_purchase TO service_role;


--
-- Name: TABLE jar_balance; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.jar_balance TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.jar_balance TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.jar_balance TO service_role;


--
-- Name: TABLE notification; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.notification TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.notification TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.notification TO service_role;


--
-- Name: TABLE recurring_transaction; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.recurring_transaction TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.recurring_transaction TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.recurring_transaction TO service_role;


--
-- Name: TABLE schema_migrations; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.schema_migrations TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.schema_migrations TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.schema_migrations TO service_role;


--
-- Name: TABLE subcategory; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.subcategory TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.subcategory TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.subcategory TO service_role;


--
-- Name: TABLE transaction_medium; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.transaction_medium TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.transaction_medium TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.transaction_medium TO service_role;


--
-- Name: TABLE transfer; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.transfer TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.transfer TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.transfer TO service_role;


--
-- Name: TABLE transfer_summary; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.transfer_summary TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.transfer_summary TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.transfer_summary TO service_role;


--
-- Name: TABLE transfer_analysis; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.transfer_analysis TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.transfer_analysis TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.transfer_analysis TO service_role;


--
-- Name: TABLE messages; Type: ACL; Schema: realtime; Owner: supabase_realtime_admin
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE realtime.messages TO postgres;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE realtime.messages TO dashboard_user;
GRANT SELECT,INSERT,UPDATE ON TABLE realtime.messages TO anon;
GRANT SELECT,INSERT,UPDATE ON TABLE realtime.messages TO authenticated;
GRANT SELECT,INSERT,UPDATE ON TABLE realtime.messages TO service_role;


--
-- Name: TABLE schema_migrations; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE realtime.schema_migrations TO postgres;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE realtime.schema_migrations TO dashboard_user;
GRANT SELECT ON TABLE realtime.schema_migrations TO anon;
GRANT SELECT ON TABLE realtime.schema_migrations TO authenticated;
GRANT SELECT ON TABLE realtime.schema_migrations TO service_role;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE realtime.schema_migrations TO supabase_realtime_admin;


--
-- Name: TABLE subscription; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE realtime.subscription TO postgres;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE realtime.subscription TO dashboard_user;
GRANT SELECT ON TABLE realtime.subscription TO anon;
GRANT SELECT ON TABLE realtime.subscription TO authenticated;
GRANT SELECT ON TABLE realtime.subscription TO service_role;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE realtime.subscription TO supabase_realtime_admin;


--
-- Name: SEQUENCE subscription_id_seq; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON SEQUENCE realtime.subscription_id_seq TO postgres;
GRANT ALL ON SEQUENCE realtime.subscription_id_seq TO dashboard_user;
GRANT USAGE ON SEQUENCE realtime.subscription_id_seq TO anon;
GRANT USAGE ON SEQUENCE realtime.subscription_id_seq TO authenticated;
GRANT USAGE ON SEQUENCE realtime.subscription_id_seq TO service_role;
GRANT ALL ON SEQUENCE realtime.subscription_id_seq TO supabase_realtime_admin;


--
-- Name: TABLE buckets; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE storage.buckets TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE storage.buckets TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE storage.buckets TO service_role;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE storage.buckets TO postgres;


--
-- Name: TABLE migrations; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE storage.migrations TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE storage.migrations TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE storage.migrations TO service_role;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE storage.migrations TO postgres;


--
-- Name: TABLE objects; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE storage.objects TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE storage.objects TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE storage.objects TO service_role;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE storage.objects TO postgres;


--
-- Name: TABLE s3_multipart_uploads; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE storage.s3_multipart_uploads TO service_role;
GRANT SELECT ON TABLE storage.s3_multipart_uploads TO authenticated;
GRANT SELECT ON TABLE storage.s3_multipart_uploads TO anon;


--
-- Name: TABLE s3_multipart_uploads_parts; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE storage.s3_multipart_uploads_parts TO service_role;
GRANT SELECT ON TABLE storage.s3_multipart_uploads_parts TO authenticated;
GRANT SELECT ON TABLE storage.s3_multipart_uploads_parts TO anon;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: auth; Owner: supabase_auth_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON SEQUENCES TO dashboard_user;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: auth; Owner: supabase_auth_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON FUNCTIONS TO dashboard_user;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: auth; Owner: supabase_auth_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO dashboard_user;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: cron; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA cron GRANT ALL ON SEQUENCES TO postgres WITH GRANT OPTION;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: cron; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA cron GRANT ALL ON FUNCTIONS TO postgres WITH GRANT OPTION;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: cron; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA cron GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO postgres WITH GRANT OPTION;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: extensions; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA extensions GRANT ALL ON SEQUENCES TO postgres WITH GRANT OPTION;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: extensions; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA extensions GRANT ALL ON FUNCTIONS TO postgres WITH GRANT OPTION;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: extensions; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA extensions GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO postgres WITH GRANT OPTION;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: graphql; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON SEQUENCES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON SEQUENCES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON SEQUENCES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: graphql; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON FUNCTIONS TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON FUNCTIONS TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON FUNCTIONS TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: graphql; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: graphql_public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON SEQUENCES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON SEQUENCES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON SEQUENCES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: graphql_public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON FUNCTIONS TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON FUNCTIONS TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON FUNCTIONS TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: graphql_public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: pgsodium; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA pgsodium GRANT ALL ON SEQUENCES TO pgsodium_keyholder;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: pgsodium; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA pgsodium GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO pgsodium_keyholder;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: pgsodium_masks; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA pgsodium_masks GRANT ALL ON SEQUENCES TO pgsodium_keyiduser;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: pgsodium_masks; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA pgsodium_masks GRANT ALL ON FUNCTIONS TO pgsodium_keyiduser;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: pgsodium_masks; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA pgsodium_masks GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO pgsodium_keyiduser;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: realtime; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON SEQUENCES TO dashboard_user;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: realtime; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON FUNCTIONS TO dashboard_user;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: realtime; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO dashboard_user;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: storage; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON SEQUENCES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON SEQUENCES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON SEQUENCES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: storage; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON FUNCTIONS TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON FUNCTIONS TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON FUNCTIONS TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: storage; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO service_role;


--
-- Name: issue_graphql_placeholder; Type: EVENT TRIGGER; Schema: -; Owner: supabase_admin
--

CREATE EVENT TRIGGER issue_graphql_placeholder ON sql_drop
         WHEN TAG IN ('DROP EXTENSION')
   EXECUTE FUNCTION extensions.set_graphql_placeholder();


ALTER EVENT TRIGGER issue_graphql_placeholder OWNER TO supabase_admin;

--
-- Name: issue_pg_cron_access; Type: EVENT TRIGGER; Schema: -; Owner: supabase_admin
--

CREATE EVENT TRIGGER issue_pg_cron_access ON ddl_command_end
         WHEN TAG IN ('CREATE EXTENSION')
   EXECUTE FUNCTION extensions.grant_pg_cron_access();


ALTER EVENT TRIGGER issue_pg_cron_access OWNER TO supabase_admin;

--
-- Name: issue_pg_graphql_access; Type: EVENT TRIGGER; Schema: -; Owner: supabase_admin
--

CREATE EVENT TRIGGER issue_pg_graphql_access ON ddl_command_end
         WHEN TAG IN ('CREATE FUNCTION')
   EXECUTE FUNCTION extensions.grant_pg_graphql_access();


ALTER EVENT TRIGGER issue_pg_graphql_access OWNER TO supabase_admin;

--
-- Name: issue_pg_net_access; Type: EVENT TRIGGER; Schema: -; Owner: postgres
--

CREATE EVENT TRIGGER issue_pg_net_access ON ddl_command_end
         WHEN TAG IN ('CREATE EXTENSION')
   EXECUTE FUNCTION extensions.grant_pg_net_access();


ALTER EVENT TRIGGER issue_pg_net_access OWNER TO postgres;

--
-- Name: pgrst_ddl_watch; Type: EVENT TRIGGER; Schema: -; Owner: supabase_admin
--

CREATE EVENT TRIGGER pgrst_ddl_watch ON ddl_command_end
   EXECUTE FUNCTION extensions.pgrst_ddl_watch();


ALTER EVENT TRIGGER pgrst_ddl_watch OWNER TO supabase_admin;

--
-- Name: pgrst_drop_watch; Type: EVENT TRIGGER; Schema: -; Owner: supabase_admin
--

CREATE EVENT TRIGGER pgrst_drop_watch ON sql_drop
   EXECUTE FUNCTION extensions.pgrst_drop_watch();


ALTER EVENT TRIGGER pgrst_drop_watch OWNER TO supabase_admin;

--
-- PostgreSQL database dump complete
--

