-- Add photo_url column to households table
-- This allows families to have a household/family photo

ALTER TABLE households
ADD COLUMN IF NOT EXISTS photo_url TEXT;

-- Add comment to describe the column
COMMENT ON COLUMN households.photo_url IS 'URL to household/family photo stored in Supabase Storage';

