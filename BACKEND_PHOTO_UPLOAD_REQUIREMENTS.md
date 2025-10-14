# Photo Upload Implementation Summary

## ✅ Frontend Implementation Complete

### Changes Made

1. **Fixed Web Compatibility Issue**
   - Changed from `dart:io` to `dart:typed_data` for web support
   - Using `Uint8List` for image bytes instead of `File`
   - Using `.uploadBinary()` method with proper `FileOptions`

2. **Added Member Photo Support**
   - Updated `FamilyMember` model with `photoUrl` field
   - Updated `fromJson`, `toJson`, and `props` to include photoUrl
   - Members can now have profile photos

3. **Created Reusable Upload Helper**
   - `_uploadPhotoToStorage(prefix, id)` - generic photo upload function
   - Handles both household and member photos
   - Uses Supabase Storage's `media` bucket

4. **Updated UI**
   - Household photo shows in settings with camera button to upload
   - Member photos show as CircleAvatar in member list
   - Camera icon button on each member card to upload their photo
   - Photos display if available, otherwise shows emoji/initial

5. **Storage Structure**
   - Household photos: `household_photos/household_{id}_{timestamp}.jpg`
   - Member photos: `member_photos/member_{id}_{timestamp}.jpg`

## 📋 Backend Requirements

### Database Migration

Run the provided SQL migration in your Supabase SQL Editor:

```bash
supabase_add_member_photo_url.sql
```

This adds the `photo_url` column to the `household_members` table.

### Storage Bucket Configuration

Ensure the `media` bucket exists in Supabase Storage with the following policies:

1. **Upload Policy** (already should exist from previous setup):
   ```sql
   CREATE POLICY "Allow authenticated upload of household photos"
   ON storage.objects FOR INSERT TO authenticated WITH CHECK (
     bucket_id = 'media' AND 
     auth.uid() IS NOT NULL AND 
     (path_prefix(name) = 'household_photos/' OR path_prefix(name) = 'member_photos/')
   );
   ```

2. **Read Policy** (public access):
   ```sql
   CREATE POLICY "Allow public read access"
   ON storage.objects FOR SELECT TO public USING (
     bucket_id = 'media'
   );
   ```

3. **Update/Delete Policies** (for authenticated users):
   ```sql
   CREATE POLICY "Allow authenticated update of photos"
   ON storage.objects FOR UPDATE TO authenticated USING (
     bucket_id = 'media' AND 
     auth.uid() IS NOT NULL AND 
     (path_prefix(name) = 'household_photos/' OR path_prefix(name) = 'member_photos/')
   );

   CREATE POLICY "Allow authenticated delete of photos"
   ON storage.objects FOR DELETE TO authenticated USING (
     bucket_id = 'media' AND 
     auth.uid() IS NOT NULL AND 
     (path_prefix(name) = 'household_photos/' OR path_prefix(name) = 'member_photos/')
   );
   ```

### Verification Steps

1. Run the migration to add `photo_url` column to `household_members`
2. Verify the `media` storage bucket exists and has proper RLS policies
3. Test uploading a household photo from settings
4. Test uploading a member photo from the member card
5. Verify photos display correctly after upload
6. Verify photos persist after page reload

## 🎨 User Experience

### Household Photo
- Click camera icon next to "Household Name" in settings
- Select photo from gallery (max 800x800px, 85% quality)
- Photo uploads to Supabase Storage
- Photo URL saved to households.photo_url
- Displays as family avatar in header and settings

### Member Photos
- Each member card shows their photo as CircleAvatar
- Camera icon button on each member card
- Click to upload photo (same size/quality constraints)
- Photo uploads to Supabase Storage
- Photo URL saved to household_members.photo_url
- Immediately reflects in UI after upload

## 🔒 Security Notes

- All uploads require authentication
- Photos stored in Supabase Storage `media` bucket
- Public read access (photos are visible to anyone with the URL)
- Only authenticated users can upload/update/delete
- File size limited by ImagePicker settings (800x800, 85% quality)

## 🐛 Troubleshooting

If you see errors like "NoSuchMethodError: 'readAsBytesSync'":
- This means `dart:io` is still being imported somewhere
- Check all imports use `dart:typed_data` instead
- Verify `.uploadBinary()` is used with `Uint8List` bytes

If photos don't appear after upload:
- Check Supabase Storage RLS policies are correct
- Verify the `media` bucket exists and is public-readable
- Check browser console for CORS or 403 errors
- Ensure photo_url is being saved to the database correctly

