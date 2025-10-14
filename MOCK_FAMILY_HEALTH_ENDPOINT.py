# MOCK Family Health Endpoint - For Testing Only
# Add this to your Django views to test the dashboard UI

from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_family_health_metrics(request):
    """
    MOCK endpoint that returns fake data so you can see the dashboard.
    Replace this with real implementation from BACKEND_FAMILY_HEALTH_REQUIREMENTS.md
    """
    household_id = request.GET.get('household_id')
    
    # Return mock data
    return Response({
        "household_id": household_id,
        "last_activity_date": "2025-10-12T14:30:00Z",
        "days_since_last_activity": 0,
        "current_streak": 7,
        "longest_streak": 15,
        "total_activities_this_week": 5,
        "total_activities_this_month": 18,
        "total_activities_all_time": 42,
        "total_hours_together_this_week": 12.5,
        "total_hours_together_this_month": 45.0,
        "average_rating": 4.6,
        "most_active_pod": {
            "pod_id": "mock-pod-123",
            "pod_name": "The Whole Gang",
            "icon": "👨‍👩‍👧‍👦",
            "activity_count": 12,
            "total_hours": 20.5
        },
        "most_active_inviter": {
            "member_id": "mock-member-123",
            "member_name": "Sarah",
            "avatar_emoji": "👩",
            "initiated_count": 15,
            "participated_count": 40
        },
        "recent_achievements": [
            {
                "id": "achievement-1",
                "title": "First Steps",
                "description": "Completed your first family activity",
                "icon": "🎉",
                "unlocked_at": "2025-10-10T10:00:00Z",
                "tier": "bronze",
                "points": 10
            },
            {
                "id": "achievement-2",
                "title": "Week Warrior",
                "description": "Active 7 days in a row",
                "icon": "🔥",
                "unlocked_at": "2025-10-11T15:30:00Z",
                "tier": "silver",
                "points": 25
            },
            {
                "id": "achievement-3",
                "title": "Quality Champions",
                "description": "Achieved 20 hours together this month",
                "icon": "⏰",
                "unlocked_at": "2025-10-12T09:15:00Z",
                "tier": "gold",
                "points": 75
            }
        ],
        "milestones": [
            {
                "id": "milestone-1",
                "title": "First 25",
                "description": "Complete 25 family activities",
                "target_value": 25,
                "current_value": 18,
                "completed": False,
                "reward_description": "Unlock 'Memory Lane' feature",
                "icon": "🎯"
            },
            {
                "id": "milestone-2",
                "title": "50 Hours Together",
                "description": "Spend 50 hours in activities",
                "target_value": 50,
                "current_value": 33,
                "completed": False,
                "reward_description": "Unlock 'Time Capsule' photo album",
                "icon": "⏳"
            }
        ],
        "weekly_trend": {
            "daily_counts": [1, 2, 0, 1, 3, 0, 2],
            "percent_change": 15.5,
            "direction": "up"
        },
        "days_active_this_week": 5,
        "days_active_this_month": 18,
        "connection_score": {
            "score": 85,
            "level": "Thriving",
            "description": "Your family is creating wonderful memories together!",
            "encouragement": "You're doing amazing! Keep up the great work.",
            "strengths": [
                "Consistent activity",
                "High engagement",
                "Diverse experiences"
            ],
            "suggestions": [
                "Try a weekend adventure",
                "Involve all pod groups"
            ]
        }
    }, status=200)

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_achievements(request):
    """Mock achievements endpoint"""
    return Response([
        {
            "id": "1",
            "title": "First Steps",
            "description": "Completed your first activity",
            "icon": "🎉",
            "unlocked_at": "2025-10-10T10:00:00Z",
            "tier": "bronze",
            "points": 10
        }
    ])

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_milestones(request):
    """Mock milestones endpoint"""
    return Response([
        {
            "id": "1",
            "title": "First 25",
            "description": "Complete 25 activities",
            "target_value": 25,
            "current_value": 18,
            "completed": False,
            "reward_description": "Unlock Memory Lane",
            "icon": "🎯"
        }
    ])

