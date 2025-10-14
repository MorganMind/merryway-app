# User-Created Ideas - Frontend Implementation Progress

## ✅ Completed Components

### 1. Data Models (`lib/modules/ideas/models/idea_models.dart`)
- ✅ `Idea` model with all fields
- ✅ `IdeaComment` model
- ✅ `IdeaLike` model
- ✅ Enums: `IdeaState`, `IdeaVisibility`, `RecurrenceUnit`
- ✅ Extension methods for DB serialization
- ✅ `fromJson` / `toJson` methods

### 2. API Service (`lib/modules/ideas/services/ideas_api_service.dart`)
- ✅ `createIdea`
- ✅ `updateIdea`
- ✅ `getIdea`
- ✅ `listIdeas` (with filters: state, visibility, pod, search, creator)
- ✅ `likeIdea` / `unlikeIdea`
- ✅ `getComments`
- ✅ `postComment`
- ✅ `updateComment`
- ✅ `deleteComment`
- ✅ `approveIdea` (parent action)
- ✅ `promoteToExperience`

### 3. Idea Composer (`lib/modules/ideas/widgets/idea_composer.dart`)
- ✅ Full create/edit form
- ✅ Title, summary, details (markdown)
- ✅ Tags, location hint
- ✅ Feasibility hints: indoor/outdoor, duration, setup, min age, needs adult, mess level, cost
- ✅ Default pod selector
- ✅ Visibility selector (household, private, pod-only)
- ✅ Pod visibility multi-selector for pod-only mode
- ✅ Form validation
- ✅ Save/Update with loading states
- ✅ Success/error feedback

---

## 🚧 In Progress

### 4. Idea Detail Page (`lib/modules/ideas/pages/idea_detail_page.dart`)
**Status**: Starting next
**Components**:
- View full idea with all fields
- Comments section (threaded)
- Like/unlike button (Wishbook)
- Make it an Experience button
- Edit button (creator/parent)
- Archive button (creator/parent)
- Approve button (parent, if pending)
- Pending approval banner

### 5. Idea Card (`lib/modules/ideas/widgets/idea_card.dart`)
**Status**: Queued
**Features**:
- Compact card for feed display
- Title, summary, badges (duration, cost, indoor/outdoor)
- Creator chip
- Visibility chip
- Like count
- Comment count
- "Due soon" badge (if applicable)
- Tap to open detail

### 6. My Ideas Page (`lib/modules/ideas/pages/my_ideas_page.dart`)
**Status**: Queued
**Features**:
- List user's own ideas
- Tabs: Draft, Pending Approval, Active, Archived
- Search/filter
- FAB to create new idea
- Tap card to edit

### 7. Feed Integration
**Status**: Queued
**Changes to make**:
- Modify `home_page.dart` to inject Ideas into feed
- Merge Ideas with system suggestions
- Respect pod-aware ranking from backend
- Display faithful rationales

### 8. Promote to Experience Flow
**Status**: Queued
**Components**:
- Sheet/dialog to collect:
  - Participants (default to active pod)
  - Start time (now/later)
  - Place (pre-filled from idea.locationHint)
  - Prep notes (pre-filled from idea hints)
- Call `promoteToExperience` API
- Navigate to Experience or show success

### 9. Routes & Navigation
**Status**: Queued
**Routes to add**:
- `/ideas/new` - IdeaComposer
- `/ideas/:id` - IdeaDetailPage
- `/ideas/my` - MyIdeasPage

---

## 📋 TODO Components (Ranked by Priority)

### High Priority
1. **Idea Detail Page** - Core viewing/interaction UI
2. **Idea Card** - Display in feed
3. **My Ideas Page** - User's idea management
4. **Feed Integration** - Merge with existing suggestions
5. **Promote to Experience** - Core conversion flow

### Medium Priority
6. **Comments Widget** - Threaded discussion UI
7. **Offline Queue** - Queue create/edit/like/comment actions
8. **Error Handling** - Policy blocks, approval needed, etc.

### Nice to Have
9. **Media Upload** - Add photos to ideas
10. **Recurrence UI** - Visual editor for recurrence rules
11. **Advanced Search** - Filter ideas page

---

## 🎨 Design Patterns Used

- **Stateful widgets** for forms and interactive UI
- **Controllers** for text input management
- **Form validation** with `GlobalKey<FormState>`
- **Async/await** for API calls
- **Try-catch** for error handling
- **Loading states** with `CircularProgressIndicator`
- **SnackBars** for user feedback
- **Navigator.pop(result)** to return success state
- **Chip selectors** for multi-choice fields
- **RadioListTile** for visibility picker
- **DropdownButton** for pod selector

---

## 🔌 Backend Dependency

**Required Django Endpoints** (as per spec):
- `POST /api/ideas/` - Create idea
- `PATCH /api/ideas/{id}/` - Update/transition
- `GET /api/ideas/` - List with filters
- `GET /api/ideas/{id}/` - Detail
- `POST /api/ideas/{id}/like/`, `DELETE /api/ideas/{id}/like/`
- `GET /api/ideas/{id}/comments/`, `POST /api/ideas/{id}/comments/`
- `PATCH /api/ideas/{id}/comments/{comment_id}/`, `DELETE ...`
- `POST /api/ideas/{id}/approve/` - Parent approval
- `POST /api/ideas/{id}/promote-to-experience/`
- `GET /api/feed/?pod_id=...&context=...` - Feed injection

**Backend Status**: User will implement separately

---

## 🧪 Testing Checklist

### Models
- [x] Idea serialization/deserialization
- [x] Enum conversions (state, visibility, recurrence)
- [x] Nullable fields handled correctly

### API Service
- [ ] Create idea with valid data
- [ ] Update idea
- [ ] List ideas with filters
- [ ] Like/unlike idea
- [ ] Post/edit/delete comments
- [ ] Approve idea (parent)
- [ ] Promote to experience

### UI Components
- [x] Idea composer form validation
- [x] Visibility selector logic
- [x] Pod selector logic
- [ ] Idea detail view renders correctly
- [ ] Comments section works
- [ ] Like button toggles
- [ ] Make it an Experience flow
- [ ] Edit/Archive/Approve buttons show conditionally

### Integration
- [ ] Ideas appear in feed
- [ ] Tap idea opens detail
- [ ] Create new idea from FAB
- [ ] Edit idea from detail
- [ ] Promote idea creates experience
- [ ] Offline queue works

---

## 📖 Next Steps

1. ✅ Complete Idea Detail Page
2. ✅ Complete Idea Card
3. ✅ Complete My Ideas Page
4. ✅ Integrate into Feed
5. ✅ Add routes to `app_router.dart`
6. ✅ Test end-to-end flow
7. ✅ Document for user

---

## 💡 Notes

- All components use `MerryWayTheme` colors for consistency
- Extensive `print` debugging in API service
- Offline support to be added in phase 2
- Media upload to be added later
- Recurrence UI is minimal for now (backend will compute next_due_at)

