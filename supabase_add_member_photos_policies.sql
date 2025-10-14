-- Add storage policies for member photos
-- Run this in your Supabase SQL Editor to fix the photo upload error

-- Policies for member photos folder
CREATE POLICY IF NOT EXISTS "Users can upload member photos"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'media' 
  AND (storage.foldername(name))[1] = 'member_photos'
);

CREATE POLICY IF NOT EXISTS "Users can update member photos"
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

CREATE POLICY IF NOT EXISTS "Users can delete member photos"
ON storage.objects
FOR DELETE
TO authenticated
USING (
  bucket_id = 'media' 
  AND (storage.foldername(name))[1] = 'member_photos'
);

