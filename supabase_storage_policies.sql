-- Storage policies for media bucket (household photos, experience media, etc.)

-- First, ensure the media bucket exists and is public (for reading)
-- You'll need to create this bucket in Supabase Dashboard: Storage > Create bucket
-- Name: media
-- Public: Yes (so photos can be viewed via public URLs)

-- Enable RLS on storage.objects (if not already enabled)
-- This is automatically enabled for storage buckets

-- Policy: Allow authenticated users to upload to household_photos folder
CREATE POLICY "Users can upload household photos"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'media' 
  AND (storage.foldername(name))[1] = 'household_photos'
);

-- Policy: Allow authenticated users to view all media
CREATE POLICY "Anyone can view media"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'media');

-- Policy: Allow users to update their own household photos
CREATE POLICY "Users can update their household photos"
ON storage.objects
FOR UPDATE
TO authenticated
USING (
  bucket_id = 'media' 
  AND (storage.foldername(name))[1] = 'household_photos'
)
WITH CHECK (
  bucket_id = 'media' 
  AND (storage.foldername(name))[1] = 'household_photos'
);

-- Policy: Allow users to delete their own household photos
CREATE POLICY "Users can delete their household photos"
ON storage.objects
FOR DELETE
TO authenticated
USING (
  bucket_id = 'media' 
  AND (storage.foldername(name))[1] = 'household_photos'
);

-- Additional policies for experience media (photos from completed moments)
CREATE POLICY "Users can upload experience media"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'media' 
  AND (storage.foldername(name))[1] = 'experience_media'
);

CREATE POLICY "Users can update experience media"
ON storage.objects
FOR UPDATE
TO authenticated
USING (
  bucket_id = 'media' 
  AND (storage.foldername(name))[1] = 'experience_media'
)
WITH CHECK (
  bucket_id = 'media' 
  AND (storage.foldername(name))[1] = 'experience_media'
);

CREATE POLICY "Users can delete experience media"
ON storage.objects
FOR DELETE
TO authenticated
USING (
  bucket_id = 'media' 
  AND (storage.foldername(name))[1] = 'experience_media'
);

-- Policies for member photos
CREATE POLICY "Users can upload member photos"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'media' 
  AND (storage.foldername(name))[1] = 'member_photos'
);

CREATE POLICY "Users can update member photos"
ON storage.objects
FOR UPDATE
TO authenticated
USING (
  bucket_id = 'media' 
  AND (storage.foldername(name))[1] = 'member_photos'
)
WITH CHECK (
  bucket_id = 'media' 
  AND (storage.foldername(name))[1] = 'member_photos'
);

CREATE POLICY "Users can delete member photos"
ON storage.objects
FOR DELETE
TO authenticated
USING (
  bucket_id = 'media' 
  AND (storage.foldername(name))[1] = 'member_photos'
);

-- Note: These policies allow any authenticated user to upload/manage files
-- For production, you may want to add additional checks to ensure users
-- can only manage their own household's files by joining with the households table

