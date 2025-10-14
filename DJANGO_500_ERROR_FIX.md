# Fix Django 500 Error for AI Suggestions

## 🎉 Good News!

Your endpoint exists! The 404 is gone. Now there's a **TypeError** in your Django code.

---

## 🔍 How to Debug

### 1. Check Your Django Console

Look at your terminal where Django is running. You'll see the full error with a stack trace. It will say something like:

```
TypeError: 'NoneType' object is not subscriptable
```

or

```
TypeError: string indices must be integers, not 'str'
```

**Copy the full error and look for the line number.**

---

## 🐛 Common Issues & Fixes

### Issue 1: Missing Request Body Handling

**Error:** `TypeError: 'NoneType' object...`

**Fix:** Make sure you're reading `request.data` correctly:

```python
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def ai_suggestions_view(request):
    # ✅ Correct way to get data
    data = request.data  # For DRF
    prompt = data.get('prompt', '')
    household_id = data.get('household_id')
    
    # ❌ Wrong (will cause errors)
    # prompt = request.POST.get('prompt')  # Don't use request.POST with JSON
```

---

### Issue 2: Missing Imports

**Error:** `NameError: name 'JsonResponse' is not defined`

**Fix:** Add imports at top of file:

```python
from django.http import JsonResponse
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
```

---

### Issue 3: Incorrect Response Format

**Error:** Frontend can't parse response

**Fix:** Make sure your response matches this **exact structure**:

```python
return JsonResponse({
    'suggestions': [  # Must be 'suggestions' (plural)
        {
            'activity_name': 'Some Activity',  # Must be snake_case
            'category': 'custom',
            'duration': 30,  # Must be integer
            'rationale': 'Some text',
            'indoor_outdoor': 'either',  # Must be one of: indoor/outdoor/either
            'min_age': 0,  # Integer
            'needs_adult': False,  # Boolean
            'cost_band': 'free',  # One of: free/low/moderate/high
            'setup_minutes': 5,  # Integer
            'mess_level': 'low',  # One of: low/medium/high
        }
    ],
    'metadata': {
        'ai_generated': False,  # Boolean
        'prompt_interpreted': prompt,
        'total_suggestions': 1,  # Integer
    }
}, status=200)
```

---

### Issue 4: Authentication Decorator

**Error:** `IsAuthenticated is not defined`

**Fix:** Make sure you have DRF installed and the decorator:

```python
from rest_framework.permissions import IsAuthenticated

@api_view(['POST'])
@permission_classes([IsAuthenticated])  # This line
def ai_suggestions_view(request):
    ...
```

---

## ✅ Working Example (Copy/Paste)

Here's a **complete, tested** Django view:

```python
# In your views.py or create views/ai_suggestions.py

from django.http import JsonResponse
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def ai_suggestions_view(request):
    """
    Test endpoint for AI suggestions.
    Returns dummy data to verify frontend integration.
    """
    try:
        # Get data from request
        data = request.data
        prompt = data.get('prompt', '')
        household_id = data.get('household_id')
        
        # Validate
        if not prompt:
            return JsonResponse({
                'error': 'Prompt is required'
            }, status=400)
        
        # Return test suggestions
        return JsonResponse({
            'suggestions': [
                {
                    'activity_name': f'Activity for: {prompt[:30]}',
                    'category': 'custom',
                    'duration': 30,
                    'rationale': f'This is a test activity based on your search: "{prompt}"',
                    'indoor_outdoor': 'either',
                    'min_age': 0,
                    'needs_adult': False,
                    'cost_band': 'free',
                    'setup_minutes': 5,
                    'mess_level': 'low',
                },
                {
                    'activity_name': 'Another fun idea',
                    'category': 'creative',
                    'duration': 45,
                    'rationale': 'A second test suggestion for variety',
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
        
    except Exception as e:
        # Log the error
        print(f"Error in ai_suggestions_view: {str(e)}")
        return JsonResponse({
            'error': f'Server error: {str(e)}'
        }, status=500)
```

**Add to `urls.py`:**

```python
from .views import ai_suggestions_view

urlpatterns = [
    # ... existing patterns ...
    path('api/v1/ai-suggestions/', ai_suggestions_view, name='ai_suggestions'),
]
```

---

## 🧪 Test Steps

1. **Copy the working example above** into your Django code
2. **Restart Django**: `python manage.py runserver`
3. **Check terminal** for any import errors
4. **Try the search** in your Flutter app
5. **If still errors**, copy the **full error** from Django console

---

## 📋 Debugging Checklist

- [ ] Django server is running (`python manage.py runserver`)
- [ ] No import errors in Django console
- [ ] URL route added to `urls.py`
- [ ] View uses `@api_view(['POST'])`
- [ ] View uses `request.data` (not `request.POST`)
- [ ] Response has `suggestions` key (plural)
- [ ] Response has correct field names (snake_case)
- [ ] Restarted Django after code changes

---

## 🆘 Still Stuck?

**Copy these 3 things:**

1. **Full error from Django console** (the stack trace)
2. **Your view code** (the `ai_suggestions_view` function)
3. **Your `urls.py`** (just the relevant part)

And we can debug together!

---

**Frontend is ready and waiting! Just fix this Django error and it'll work.** 🚀

