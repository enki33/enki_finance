-- Function to handle new user creation
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
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
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to automatically handle new user creation
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user(); 