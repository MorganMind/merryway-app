-- Add photo_url column to family_members table
-- This allows members to have profile photos

ALTER TABLE family_members
ADD COLUMN IF NOT EXISTS photo_url TEXT;

-- Add comment to describe the column
COMMENT ON COLUMN family_members.photo_url IS 'URL to member profile photo stored in Supabase Storage';

-- Update RLS policies for member_photos (if not already covered by existing media policies)
-- The existing media bucket policies should already allow authenticated users to upload/view

