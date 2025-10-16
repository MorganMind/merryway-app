# Chat Persistence Frontend Changes

## Overview
The frontend has been updated to handle chat persistence properly. The backend needs to ensure it can handle the data structure and endpoints described below.

## Frontend Implementation Details

### 1. Message Structure
The frontend now sends messages with this structure:
```json
{
  "plan_id": "uuid",
  "message": "user message text",
  "household_id": "uuid", 
  "participant_names": ["Member1", "Member2"],
  "plan_title": "Plan Title",
  "family_members": ["Member1", "Member2", "Member3"],
  "active_pods": ["Pod1", "Pod2"],
  "member_interests": ["interest1", "interest2"],
  "learning_data": {
    "recent_activities": [],
    "preferences": {}
  }
}
```

### 2. Expected Backend Response
The backend should return a `PlanMessage` object with these fields:
```json
{
  "id": "uuid",
  "plan_id": "uuid", 
  "author_type": "member" | "morgan",
  "author_member_id": "uuid" | null,
  "body_md": "message content",
  "created_at": "timestamp",
  "updated_at": "timestamp"
}
```

### 3. Frontend Chat Flow
1. **User sends message**: Frontend immediately adds user message to local UI
2. **AI response**: Frontend calls backend chat endpoint, gets Morgan's response
3. **UI update**: Frontend immediately adds Morgan's response to local UI  
4. **Background persistence**: Frontend calls `_saveMessagesToDatabase()` to persist both messages

### 4. Required Backend Endpoints

#### POST `/api/v1/plans/{plan_id}/chat/`
- **Purpose**: Send user message and get Morgan's AI response
- **Request Body**: See message structure above
- **Response**: `PlanMessage` object for Morgan's response
- **Note**: Backend should save the user message with `author_type: "member"` and Morgan's response with `author_type: "morgan"`

#### GET `/api/v1/plans/{plan_id}/messages/`
- **Purpose**: Retrieve chat history for a plan
- **Response**: Array of `PlanMessage` objects
- **Note**: Should return messages in chronological order

### 5. Database Schema Requirements
The backend needs these fields in the messages table:
- `id` (UUID, primary key)
- `plan_id` (UUID, foreign key)
- `author_type` (string: "member" or "morgan")
- `author_member_id` (UUID, nullable - null for Morgan messages)
- `body_md` (text, markdown content)
- `created_at` (timestamp)
- `updated_at` (timestamp)

### 6. Frontend Service Methods

#### ChatService.sendChatMessage()
- Sends message to Morgan chat endpoint
- Returns Morgan's response as `PlanMessage`
- Includes context gathering (family members, pods, interests, learning data)

#### PlansService.sendMessage() 
- Persists both user and Morgan messages to database
- Called in background after UI updates

### 7. Context Data Being Sent
The frontend now sends comprehensive context to help Morgan provide better responses:
- **Plan details**: Title, participants
- **Family members**: All household members
- **Active pods**: Current pod selections  
- **Member interests**: Activity preferences
- **Learning data**: Recent activities and preferences

### 8. Error Handling
- If chat endpoint fails, user message still appears in UI
- If persistence fails, messages remain in local state
- Graceful fallbacks for missing data

## Backend Action Items

1. **Implement chat endpoint**: `POST /api/v1/plans/{plan_id}/chat/`
2. **Implement messages endpoint**: `GET /api/v1/plans/{plan_id}/messages/`
3. **Update database schema**: Ensure messages table has required fields
4. **Handle context data**: Use the context data for better AI responses
5. **Prevent duplicates**: Ensure user messages aren't duplicated
6. **Proper author types**: Set `author_type` correctly for user vs Morgan messages

## Testing
- Send a message in the chat
- Refresh the page
- Messages should persist and display correctly
- User messages should show "You" as sender
- Morgan messages should show Morgan's avatar
