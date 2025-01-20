-- #################################################
-- Migration: Recreate Tags and Notes Fields
-- #################################################

-- First, create a backup table for existing data
CREATE TABLE IF NOT EXISTS public.transaction_fields_backup (
    transaction_id uuid PRIMARY KEY,
    tags jsonb,
    notes text,
    backup_date timestamptz DEFAULT CURRENT_TIMESTAMP
);

-- Backup existing data
INSERT INTO public.transaction_fields_backup (transaction_id, tags, notes)
SELECT id, tags, notes
FROM public.transaction
WHERE tags IS NOT NULL OR notes IS NOT NULL
ON CONFLICT (transaction_id) DO NOTHING;

-- Drop existing indexes if they exist
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_transaction_tags') THEN
        DROP INDEX idx_transaction_tags;
    END IF;
    
    IF EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_transaction_notes_search') THEN
        DROP INDEX idx_transaction_notes_search;
    END IF;
END $$;

-- Drop existing functions if they exist
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM pg_proc 
        WHERE proname = 'add_transaction_tag' 
        AND pronamespace = 'public'::regnamespace::oid
    ) THEN
        DROP FUNCTION public.add_transaction_tag;
    END IF;

    IF EXISTS (
        SELECT 1 
        FROM pg_proc 
        WHERE proname = 'remove_transaction_tag' 
        AND pronamespace = 'public'::regnamespace::oid
    ) THEN
        DROP FUNCTION public.remove_transaction_tag;
    END IF;

    IF EXISTS (
        SELECT 1 
        FROM pg_proc 
        WHERE proname = 'search_transactions_by_tags' 
        AND pronamespace = 'public'::regnamespace::oid
    ) THEN
        DROP FUNCTION public.search_transactions_by_tags;
    END IF;

    IF EXISTS (
        SELECT 1 
        FROM pg_proc 
        WHERE proname = 'search_transactions_by_notes' 
        AND pronamespace = 'public'::regnamespace::oid
    ) THEN
        DROP FUNCTION public.search_transactions_by_notes;
    END IF;
END $$;

-- Remove existing columns
ALTER TABLE public.transaction 
    DROP COLUMN IF EXISTS tags,
    DROP COLUMN IF EXISTS notes;

-- Now add the columns back with proper structure
ALTER TABLE public.transaction
    ADD COLUMN tags JSONB DEFAULT '[]'::jsonb,
    ADD COLUMN notes TEXT;

-- Add check constraint to ensure tags is an array
ALTER TABLE public.transaction
    ADD CONSTRAINT transaction_tags_is_array 
    CHECK (jsonb_typeof(tags) = 'array');

-- Add GIN index for efficient tag searching
CREATE INDEX idx_transaction_tags 
    ON public.transaction USING GIN (tags);

-- Add index for text search on notes
CREATE INDEX idx_transaction_notes_search 
    ON public.transaction USING GIN (to_tsvector('spanish', COALESCE(notes, '')));

-- Function to add a tag to a transaction
CREATE OR REPLACE FUNCTION public.add_transaction_tag(
    p_transaction_id uuid,
    p_tag text
)
RETURNS void AS $$
BEGIN
    UPDATE public.transaction
    SET tags = CASE 
        WHEN NOT tags @> jsonb_build_array(p_tag::jsonb)
        THEN tags || jsonb_build_array(p_tag::jsonb)
        ELSE tags
    END
    WHERE id = p_transaction_id;
END;
$$ LANGUAGE plpgsql;

-- Function to remove a tag from a transaction
CREATE OR REPLACE FUNCTION public.remove_transaction_tag(
    p_transaction_id uuid,
    p_tag text
)
RETURNS void AS $$
BEGIN
    UPDATE public.transaction
    SET tags = (
        SELECT jsonb_agg(value)
        FROM jsonb_array_elements(tags) AS t(value)
        WHERE value::text != p_tag::text
    )
    WHERE id = p_transaction_id;
END;
$$ LANGUAGE plpgsql;

-- Function to search transactions by tags
CREATE OR REPLACE FUNCTION public.search_transactions_by_tags(
    p_user_id uuid,
    p_tags text[]
)
RETURNS TABLE (
    id uuid,
    transaction_date date,
    description text,
    amount numeric,
    tags jsonb,
    notes text
) AS $$
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
$$ LANGUAGE plpgsql;

-- Function to search transactions by notes content
CREATE OR REPLACE FUNCTION public.search_transactions_by_notes(
    p_user_id uuid,
    p_search_text text
)
RETURNS TABLE (
    id uuid,
    transaction_date date,
    description text,
    amount numeric,
    tags jsonb,
    notes text
) AS $$
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
$$ LANGUAGE plpgsql;

-- Restore backed up data with proper format
UPDATE public.transaction t
SET 
    tags = CASE 
        WHEN b.tags IS NULL THEN '[]'::jsonb
        WHEN jsonb_typeof(b.tags) = 'array' THEN b.tags
        ELSE jsonb_build_array(b.tags)
    END,
    notes = b.notes
FROM public.transaction_fields_backup b
WHERE t.id = b.transaction_id;

-- Add comment to explain the new columns
COMMENT ON COLUMN public.transaction.tags IS 'Array of tags for transaction classification and searching';
COMMENT ON COLUMN public.transaction.notes IS 'Additional notes and details about the transaction';

-- Verify the changes
DO $$
DECLARE
    v_backup_count integer;
    v_restored_count integer;
BEGIN
    -- Get backup count
    SELECT COUNT(*) INTO v_backup_count 
    FROM public.transaction_fields_backup;
    
    -- Get count of restored records
    SELECT COUNT(*) INTO v_restored_count 
    FROM public.transaction 
    WHERE tags != '[]'::jsonb OR notes IS NOT NULL;
    
    -- Log results
    RAISE NOTICE 'Backed up records: %', v_backup_count;
    RAISE NOTICE 'Restored records: %', v_restored_count;
    
    -- Verify columns and indexes
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_name = 'transaction' 
        AND column_name IN ('tags', 'notes')
    ) THEN
        RAISE EXCEPTION 'Columns were not added correctly';
    END IF;

    IF NOT EXISTS (
        SELECT 1 
        FROM pg_indexes 
        WHERE tablename = 'transaction' 
        AND indexname IN ('idx_transaction_tags', 'idx_transaction_notes_search')
    ) THEN
        RAISE EXCEPTION 'Indexes were not created correctly';
    END IF;

    RAISE NOTICE 'Migration completed successfully';
END $$;

-- Keep the backup table for safety, can be dropped later with:
-- DROP TABLE IF EXISTS public.transaction_fields_backup;