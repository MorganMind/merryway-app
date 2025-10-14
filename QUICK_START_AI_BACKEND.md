# Quick Start: Fix OpenAI 404 Error

## 🚨 Current Error

```
POST http://localhost:8000/api/v1/ai-suggestions/
404 Not Found - Page not found
```

**Problem:** Your Django backend doesn't have the AI endpoints yet.

---

## ⚡ Quick Fix (5 Minutes)

### Step 1: Install Package
```bash
pip install openai==1.3.0
```

### Step 2: Set API Key
```bash
export OPENAI_API_KEY=sk-...your-key...
```

### Step 3: Create Minimal Stub Endpoint

Add to your Django `views.py`:

```python
from django.http import JsonResponse
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def ai_suggestions_view(request):
    """Quick stub for AI suggestions - replace with full implementation later"""
    prompt = request.data.get('prompt', '')
    
    return JsonResponse({
        'suggestions': [
            {
                'activity_name': f'Activity based on: {prompt}',
                'category': 'custom',
                'duration': 30,
                'rationale': f'Generated from your search: "{prompt}"',
                'indoor_outdoor': 'either',
                'min_age': 0,
                'needs_adult': False,
                'cost_band': 'free',
                'setup_minutes': 5,
                'mess_level': 'low',
            },
            {
                'activity_name': 'Another creative idea',
                'category': 'creative',
                'duration': 45,
                'rationale': 'A fun alternative for your family',
                'indoor_outdoor': 'indoor',
                'min_age': 3,
                'needs_adult': True,
                'cost_band': 'low',
                'setup_minutes': 10,
                'mess_level': 'medium',
            },
        ],
        'metadata': {
            'ai_generated': False,
            'prompt_interpreted': prompt,
            'total_suggestions': 2,
        }
    }, status=200)
```

### Step 4: Add URL Route

In your Django `urls.py`:

```python
from .views import ai_suggestions_view

urlpatterns = [
    # ... existing patterns ...
    path('api/v1/ai-suggestions/', ai_suggestions_view, name='ai_suggestions'),
]
```

### Step 5: Restart Django
```bash
# Restart your Django server
python manage.py runserver
```

---

## ✅ Test It

1. Type something in the search box: "fun indoor activity"
2. Press Enter
3. You should see 2 test suggestions appear

---

## 🚀 Full Implementation (Later)

Once the stub works, implement the full OpenAI integration:

1. **AI Suggestions**: See `BACKEND_AI_SUGGESTIONS_ENDPOINT.md`
   - Full OpenAI integration with GPT-3.5-turbo
   - Context-aware suggestions
   - ~$0.001 per request

2. **Journal Parsing**: See `BACKEND_JOURNAL_PARSING_ENDPOINT.md`
   - Natural language parsing for manual moments
   - "today me and sarah went to the park" → structured data
   - ~$0.0005 per parse

Both docs have complete code ready to copy/paste.

---

## 📝 Summary

**Quick fix (now):**
- Add stub endpoint (5 min)
- Returns test data
- Frontend works immediately

**Full fix (later):**
- Implement full OpenAI integration
- Use complete code from docs
- Add proper error handling

---

## 🐛 Still Getting 404?

1. Check Django is running: `http://localhost:8000/admin/`
2. Check URL patterns in Django debug page
3. Verify route is exactly: `/api/v1/ai-suggestions/` (with trailing slash)
4. Restart Django server after adding route

---

**Frontend is ready! Just add the backend endpoint and it works.** 🎉

