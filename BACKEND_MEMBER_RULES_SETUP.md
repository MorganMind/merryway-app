# Backend Setup for Member Rules

## Step 1: Create Supabase Table

Run this SQL in your Supabase SQL Editor:

```sql
-- File: supabase_member_rules.sql (already created in your project)
```

Just run the file `/Users/nash/onyxcompany/merryway/supabase_member_rules.sql` in Supabase SQL Editor.

---

## Step 2: Create Django Backend Files

### File 1: `family/models/member_rule.py`

```python
from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class MemberRule(BaseModel):
    """Member rule model"""
    id: Optional[str] = None
    member_id: str
    rule_text: str
    category: Optional[str] = None
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None

class MemberRuleCreate(BaseModel):
    """Request model for creating a member rule"""
    member_id: str
    rule_text: str
    category: Optional[str] = None

class MemberRuleResponse(BaseModel):
    """Response model for member rules"""
    id: str
    member_id: str
    rule_text: str
    category: Optional[str] = None
    created_at: str
    updated_at: str
```

---

### File 2: `family/views/member_rules_view.py`

```python
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status
from django.conf import settings
from supabase import create_client
import logging

logger = logging.getLogger(__name__)
supabase = create_client(settings.SUPABASE_URL, settings.SUPABASE_SERVICE_KEY)

@api_view(['GET'])
def get_member_rules_view(request):
    """
    GET /api/v1/rules/member/?member_id={member_id}
    Get all rules for a member
    """
    try:
        member_id = request.GET.get('member_id')
        if not member_id:
            return Response(
                {'error': 'member_id is required'},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Query rules for this member
        response = supabase.table('member_rules') \
            .select('*') \
            .eq('member_id', member_id) \
            .order('created_at', desc=True) \
            .execute()

        rules = response.data or []
        
        return Response({
            'success': True,
            'rules': rules
        }, status=status.HTTP_200_OK)

    except Exception as e:
        logger.error(f"Error getting member rules: {str(e)}", exc_info=True)
        return Response(
            {'error': str(e)},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )


@api_view(['POST'])
def add_member_rule_view(request):
    """
    POST /api/v1/rules/member/add/
    Add a new rule for a member
    
    Body: {
        "member_id": "uuid",
        "rule_text": "No screen time after 8pm",
        "category": "screen_time"  // optional
    }
    """
    try:
        data = request.data
        member_id = data.get('member_id')
        rule_text = data.get('rule_text')
        category = data.get('category')

        if not member_id or not rule_text:
            return Response(
                {'error': 'member_id and rule_text are required'},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Insert new rule
        rule_data = {
            'member_id': member_id,
            'rule_text': rule_text,
        }
        
        if category:
            rule_data['category'] = category

        response = supabase.table('member_rules') \
            .insert(rule_data) \
            .execute()

        if not response.data:
            raise Exception('Failed to insert rule')

        created_rule = response.data[0]
        logger.info(f"✅ Created member rule: {created_rule['id']} for member {member_id}")

        return Response(created_rule, status=status.HTTP_201_CREATED)

    except Exception as e:
        logger.error(f"Error adding member rule: {str(e)}", exc_info=True)
        return Response(
            {'error': str(e)},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )


@api_view(['DELETE'])
def delete_member_rule_view(request):
    """
    DELETE /api/v1/rules/member/delete/?rule_id={rule_id}
    Delete a member rule
    """
    try:
        rule_id = request.GET.get('rule_id')
        if not rule_id:
            return Response(
                {'error': 'rule_id is required'},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Delete the rule
        response = supabase.table('member_rules') \
            .delete() \
            .eq('id', rule_id) \
            .execute()

        logger.info(f"✅ Deleted member rule: {rule_id}")

        return Response(
            {'success': True, 'message': 'Rule deleted'},
            status=status.HTTP_200_OK
        )

    except Exception as e:
        logger.error(f"Error deleting member rule: {str(e)}", exc_info=True)
        return Response(
            {'error': str(e)},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )
```

---

### File 3: Update `family/urls.py`

Add these URL patterns to your existing `family/urls.py`:

```python
from django.urls import path
from .views import member_rules_view  # Add this import

urlpatterns = [
    # ... your existing URLs ...
    
    # Member Rules endpoints
    path('rules/member/', member_rules_view.get_member_rules_view, name='get_member_rules'),
    path('rules/member/add/', member_rules_view.add_member_rule_view, name='add_member_rule'),
    path('rules/member/delete/', member_rules_view.delete_member_rule_view, name='delete_member_rule'),
]
```

---

### File 4: Update `family/urls.py` (main app urls)

Make sure your main `urls.py` includes the family URLs:

```python
# In your main project urls.py
from django.urls import path, include

urlpatterns = [
    # ... other patterns ...
    path('api/v1/', include('family.urls')),  # This includes all family routes
]
```

---

## Step 3: Test the Endpoints

### Test 1: Get Member Rules (should return empty array initially)

```bash
curl -X GET "http://localhost:8000/api/v1/rules/member/?member_id=YOUR_MEMBER_ID" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### Test 2: Add a Member Rule

```bash
curl -X POST "http://localhost:8000/api/v1/rules/member/add/" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "member_id": "YOUR_MEMBER_ID",
    "rule_text": "No screen time after 8pm",
    "category": "screen_time"
  }'
```

### Test 3: Delete a Member Rule

```bash
curl -X DELETE "http://localhost:8000/api/v1/rules/member/delete/?rule_id=RULE_ID" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

---

## Step 4: Verify in Flutter App

1. Hot restart your Flutter app: `R`
2. Go to Settings → Family Members → Click on a member
3. Scroll down to the "Member Rules" section
4. Try adding a rule
5. The error should be gone! ✅

---

## Quick Setup Checklist

- [ ] Run `supabase_member_rules.sql` in Supabase SQL Editor
- [ ] Create `family/models/member_rule.py` with the models above
- [ ] Create `family/views/member_rules_view.py` with the view functions above
- [ ] Update `family/urls.py` to include the new routes
- [ ] Restart Django server: `python manage.py runserver`
- [ ] Test endpoints with curl or Postman
- [ ] Hot restart Flutter app and test the UI

---

## Done! 🎉

The member rules feature should now work end-to-end.

