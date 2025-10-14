# Django CORS Fix for Merryway

Your Flutter frontend (running on `http://localhost:8686`) is being blocked by Django's CORS policy.

## Step 1: Install django-cors-headers

In your Django backend directory:

```bash
pip install django-cors-headers
```

## Step 2: Update Django Settings

Add to your `settings.py`:

```python
INSTALLED_APPS = [
    # ... existing apps
    'corsheaders',  # Add this
]

MIDDLEWARE = [
    'corsheaders.middleware.CorsMiddleware',  # Add this at the top
    'django.middleware.common.CommonMiddleware',
    # ... other middleware
]

# CORS Configuration for Development
CORS_ALLOWED_ORIGINS = [
    "http://localhost:8686",  # Flutter web-server
    "http://127.0.0.1:8686",
]

# For development only - allow credentials
CORS_ALLOW_CREDENTIALS = True

# Optional: Allow all origins for development (less secure)
# CORS_ALLOW_ALL_ORIGINS = True  # Uncomment only if needed
```

## Step 3: Verify Django is Running

Make sure your Django server is running:

```bash
python manage.py runserver 8000
```

You should see:
```
Starting development server at http://127.0.0.1:8000/
```

## Step 4: Test the Connection

After making these changes, hot restart your Flutter app and try fetching suggestions again.

## Debugging

If you still see CORS errors:

1. **Check Django terminal** - You should see incoming requests
2. **Check browser console** - Look for the exact error
3. **Try the API directly** in your browser:
   - `http://localhost:8000/api/v1/household/`
   - If this works but Flutter doesn't, it's definitely CORS

## Alternative: Use a Proxy (Quick Workaround)

If you can't modify Django settings, you could proxy requests through Flutter's dev server, but the above solution is cleaner.

---

**Need help with Django setup? Let me know!**

