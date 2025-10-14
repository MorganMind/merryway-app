# Backend Journal Parsing Endpoint

## 🎯 Purpose

When users create a manual Merry Moment using natural language (journaling), the frontend calls this backend endpoint to parse the text using OpenAI.

**Why backend?** The OpenAI API key is stored securely on the backend, not exposed in the Flutter app.

---

## 📡 Endpoint Specification

### POST `/api/v1/parse-journal-entry/`

**Description**: Parse a natural language journal entry into structured data

**Authentication**: Required (JWT Bearer token)

**Request Headers**:
```
Content-Type: application/json
Authorization: Bearer {supabase_jwt_token}
```

**Request Body**:
```json
{
  "text": "Today me and Sarah went to the park, then the whole family went for pizza",
  "family_member_names": ["Nash", "Sarah", "Emma", "Oliver"]
}
```

**Response (Success - 200)**:
```json
{
  "title": "Park Day & Pizza",
  "description": "Park visit with Sarah, followed by family pizza dinner",
  "participants": ["Nash", "Sarah"],
  "place": "Park",
  "occurred_at": "2025-10-13T14:30:00Z"
}
```

**Response (Error - 400/500)**:
```json
{
  "error": "Error message here"
}
```

---

## 🐍 Django Implementation

### 1. Add to `urls.py`

```python
from django.urls import path
from .views import parse_journal_entry_view

urlpatterns = [
    # ... existing patterns ...
    path('parse-journal-entry/', parse_journal_entry_view, name='parse_journal_entry'),
]
```

### 2. Create `views/parse_journal_entry.py`

```python
import os
import json
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
import openai
from datetime import datetime

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def parse_journal_entry_view(request):
    """
    Parse a natural language journal entry using OpenAI.
    
    Expects:
    - text: The journal entry text
    - family_member_names: List of family member names for context
    
    Returns parsed structured data.
    """
    try:
        data = request.data
        text = data.get('text', '')
        family_member_names = data.get('family_member_names', [])
        
        if not text:
            return JsonResponse({'error': 'Text is required'}, status=400)
        
        # Get OpenAI API key from environment
        openai.api_key = os.environ.get('OPENAI_API_KEY')
        
        if not openai.api_key:
            return JsonResponse({'error': 'OpenAI API key not configured'}, status=500)
        
        # Build the prompt
        system_prompt = """You are a helpful assistant that parses family activity journal entries. 
Extract the following from the user's input:
1. title: A short, friendly title for the activity
2. description: A brief description
3. participants: List of participant names mentioned (must match provided family member names)
4. place: The location if mentioned
5. occurred_at: When it happened (as ISO 8601 datetime, relative to today)

Return ONLY valid JSON in this format:
{
  "title": "string",
  "description": "string",
  "participants": ["name1", "name2"],
  "place": "string or null",
  "occurred_at": "ISO 8601 datetime or null"
}

If occurred_at is not specified, assume it happened today. Use relative terms like "today", "yesterday", "last Friday" to calculate the date."""
        
        user_prompt = f"Family members: {', '.join(family_member_names)}\n\nEntry: {text}"
        
        # Call OpenAI (using GPT-3.5-turbo for cost efficiency)
        response = openai.ChatCompletion.create(
            model='gpt-3.5-turbo',
            messages=[
                {'role': 'system', 'content': system_prompt},
                {'role': 'user', 'content': user_prompt}
            ],
            temperature=0.3,
        )
        
        # Extract and parse the response
        content = response.choices[0].message.content
        parsed = json.loads(content)
        
        # Validate and clean up the response
        result = {
            'title': parsed.get('title', 'Merry Moment'),
            'description': parsed.get('description'),
            'participants': parsed.get('participants', []),
            'place': parsed.get('place'),
            'occurred_at': parsed.get('occurred_at'),
        }
        
        return JsonResponse(result, status=200)
        
    except json.JSONDecodeError as e:
        return JsonResponse({'error': f'Failed to parse OpenAI response: {str(e)}'}, status=500)
    except Exception as e:
        return JsonResponse({'error': str(e)}, status=500)
```

### 3. Install OpenAI Package

```bash
pip install openai
```

### 4. Add to `requirements.txt`

```
openai==1.3.0
```

### 5. Set Environment Variable

Add to your `.env` or environment:

```bash
OPENAI_API_KEY=sk-...your-key...
```

---

## 🧪 Testing

### Test with curl:

```bash
curl -X POST http://localhost:8000/api/v1/parse-journal-entry/ \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_SUPABASE_JWT_TOKEN" \
  -d '{
    "text": "Today me and Sarah went to the park at 2pm, then the whole family went for pizza at 6pm",
    "family_member_names": ["Nash", "Sarah", "Emma", "Oliver"]
  }'
```

### Expected Response:

```json
{
  "title": "Park Day & Pizza",
  "description": "Afternoon park visit with Sarah, followed by family pizza dinner",
  "participants": ["Nash", "Sarah"],
  "place": "Park",
  "occurred_at": "2025-10-13T14:00:00Z"
}
```

---

## 🔒 Security Notes

1. ✅ OpenAI API key is stored on the backend (environment variable)
2. ✅ Endpoint requires authentication (JWT token)
3. ✅ User can only parse entries for their own household
4. ✅ No sensitive data is logged

---

## 📝 Frontend Changes Made

**File**: `lib/modules/experiences/widgets/add_manual_moment_sheet.dart`

**Changes**:
- ✅ Changed from calling OpenAI directly to calling backend endpoint
- ✅ Removed `Environment.openAIApiKey` dependency
- ✅ Now calls `POST ${Environment.apiUrl}/parse-journal-entry/`
- ✅ Sends `text` and `family_member_names` to backend
- ✅ Expects parsed JSON directly in response (not wrapped in OpenAI format)

---

## 🚀 Benefits

1. **Security**: API key never exposed in frontend code
2. **Control**: Backend can log, rate-limit, or modify parsing logic
3. **Flexibility**: Can switch AI providers without frontend changes
4. **Cost**: Backend can cache common patterns or implement fallbacks

---

## ⚡ Quick Setup

1. Add the view code to your Django app
2. Add the URL route
3. `pip install openai`
4. Set `OPENAI_API_KEY` environment variable
5. Restart Django server
6. Test with the curl command above

**Frontend is already updated and ready to use!** 🎉

