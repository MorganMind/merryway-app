# app

Morgan

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Task Triage: Frontend vs Backend

Whenever you create an issue or request a change, first decide if it is a frontend or backend task:

- **Frontend (this repo: Flutter app)**
  - UI, navigation, theming, widgets, pages, and local state (BLoC)
  - Client-side validation and data presentation
  - Invoking APIs, handling responses, and rendering results

- **Backend (separate repo: iact-api / Django)**
  - New/changed API endpoints, business logic, data models, async tasks/events
  - File processing, transcription, LLM pipelines, tagging logic, invite lifecycle
  - Integrations (GCP, Supabase) and system-side validation/auth

When in doubt, split the work:
1) Implement the UI and API calls on the frontend. 2) Document any missing/changed backend APIs in the issue and mark as "Backend needs to handle" with clear inputs/outputs and expected behavior.

## Project Structure

This app is organized by feature modules under `lib/modules`, with shared infrastructure in `lib/modules/core`. It uses BLoC for state management, GoRouter for navigation, and custom theming.

### Entry Points
- `lib/main.dart`: Base entry
- `lib/main_development.dart`, `lib/main_staging.dart`, `lib/main_production.dart`: Environment-specific bootstraps
- `lib/config/environment.dart`: Environment configuration
- `lib/firebase_options.dart`: Firebase configuration (generated)

### Routing
- `lib/modules/core/routing/app_router.dart`: Route definitions
- `lib/modules/core/routing/router_observer.dart`: Navigation observer
- `lib/modules/core/routing/router_refresh_stream_group.dart` and `router-refresh-stream.dart`: Router refresh utilities

### Dependency Injection
- `lib/modules/core/di/service_locator.dart`: Registers app-wide services and repositories

### State Management (BLoC)
Feature BLoCs live within each module, typically with `*_bloc.dart`, `*_event.dart`, `*_state.dart`:
- `lib/modules/auth/blocs/*`
- `lib/modules/core/blocs/*`
- `lib/modules/invites/blocs/*`
- `lib/modules/onboarding/blocs/*`
- `lib/modules/settings/blocs/*`
- `lib/modules/tags/blocs/*`
- `lib/modules/user/blocs/*`

### Feature Modules
- `lib/modules/auth/`: Auth pages (login, signup, join) and listeners
- `lib/modules/home/`: Home layout and feed widgets
- `lib/modules/invites/`: Invite model, repository, and state
- `lib/modules/onboarding/`: Onboarding flow
- `lib/modules/settings/`: Settings pages and state
- `lib/modules/tags/`: Tag models and state
- `lib/modules/transcriptions/`: Transcription services and widgets
- `lib/modules/user/`: User models, repositories, and state

### Core Layer
- `lib/modules/core/enums/`: UI-related enums
- `lib/modules/core/platform/`: URL strategy (web vs stub)
- `lib/modules/core/services/`:
  - `api/`: API clients
  - `sse/`: Server-sent events
  - `upload/`: Upload helpers
  - `lexorank.dart`: Ordering utility (LexoRank)
- `lib/modules/core/theme/`: Theme colors, extensions, provider
- `lib/modules/core/ui/`: Reusable pages, dialogs, widgets
- `lib/modules/core/utils/`: Shared utilities (e.g., invite code helpers)

### UI/Theme
- `lib/modules/core/theme/*`: Centralized theme configuration
- `lib/modules/core/ui/widgets/*`: Reusable components across features

### Assets
- `assets/img/*`: Logos, icons, onboarding images
- `pubspec.yaml`: Declares assets and dependencies

### Platform & Web
- `web/`: PWA assets (`index.html`, `manifest.json`, icons)
- `ios/Runner/*`: iOS configuration (Info.plist, storyboards, assets)
- `android/app/*`: Android configuration (manifests, Gradle, google-services.json)

### Testing
- `test/widget_test.dart`: Sample Flutter widget test

### Run Targets
Use the environment-specific entry points:

```bash
flutter run -t lib/main_development.dart
```

```bash
flutter run -t lib/main_staging.dart
```

```bash
flutter run -t lib/main_production.dart
```

---

## iact-api — Backend Structure Overview

A Django-based backend organized by domains ("apps") with clear separation between HTTP views, services, models, and integrations.

### Tech Stack

- **Framework**: Django (ASGI/WSGI ready)
- **Queue/Events**: Google Cloud Tasks, Pub/Sub
- **Storage/Auth**: Google Cloud Storage, Supabase
- **LLM**: Pluggable providers (OpenAI, GTE small)
- **Container/Deploy**: Docker, Procfile, Cloud Build

### Project Layout

- **Root**
  - `manage.py`: Django management entrypoint
  - `requirements.txt`: Python dependencies
  - `Dockerfile`, `Procfile`, `cloudbuild.yaml`: Container and deployment config
  - `migrations.sql`, `pydantic_to_sql.py`: SQL migrations/pydantic tooling
- **Project config**
  - `iact_api/`: Django project module (settings, ASGI/WSGI, root `urls.py`)
- **Shared libraries**
  - `common/`: Cross-cutting utilities
    - `auth_routes.py`, `decorators.py`
    - `events/domain_event_manager.py`: Domain event dispatching
    - `google/`: GCP clients (Pub/Sub, Storage, Tasks)
    - `logger/logger_service.py`
    - `supabase/supabase_client.py`
    - `task_queue/task_queue.py`: Queue abstraction
  - `config/`: Config for Cloud Tasks and Pub/Sub
- **Domain apps**
  - `files/`: File upload/serve
    - `services/file_service.py`
    - `views/file_view.py`, `urls.py`
  - `invite/`: Invites lifecycle
    - `models/invite.py`
    - `services/invite_service.py`
    - `views/invite_view.py`, `urls.py`
  - `knowledgebase/`: Source ingestion, chunking, metadata, background tasks
    - `services/`: `chunking_service.py`, `content_extractor.py`, `metadata_service.py`, etc.
    - `tasks/`: `ingestion_task_queue.py`, `deletion_task_queue.py`
    - `event_handlers/`: Source created/deleted handlers
    - `views/knowledgebase_task_handlers.py`
    - `urls/pubsub_urls.py`
  - `llm/`: LLM abstraction and providers
    - `services/llm_service.py`, `llm_provider.py`, `llm_utils.py`
    - `providers/openai_provider.py`, `gte_small_provider.py`
  - `tag/`: Tagging and associations
    - `models/tag.py`, `taggable_type.py`, `tagging.py`
    - `services/tag_service.py`, `tag_service_admin.py`
    - `views/tag_view.py`, `urls.py`
  - `tasks/`: Generic task endpoints
    - `views/task_view.py`, `urls.py`
  - `transcription/`: Audio transcription workflows
    - `services/transcription_service.py`
    - `views/transcription_view.py`, `urls.py`
  - `user/`: User profiles, settings, analytics
    - `models/`: `user_data.py`, `user_settings.py`, `user_analytics.py`, `user_context.py`, `onboarding_payload.py`
    - `services/`: `user_service.py`, `user_settings_service.py`, `analytics_service.py`
    - `views/`: `user_view.py`, `user_settings_view.py`, `analytics_view.py`
    - `urls.py`

### Architectural Conventions

- **App structure**: Each domain app keeps `views/` (HTTP endpoints), `services/` (business logic), `models/` (pydantic/dataclasses or ORM), and `urls.py`.
- **Routing**: The project-level `iact_api/urls.py` aggregates each app’s `urls.py`.
- **Services-first**: Views are thin; core logic lives in `services/` for testability.
- **Events/Tasks**: Domain events flow via `common/events`, async work via `common/task_queue` and app `tasks/`.
- **Integrations**: External clients are wrapped in `common/google/*` and `common/supabase/*`.

### Local Development

1. Create a virtualenv and install dependencies:

   ```bash
   python3 -m venv .venv
   source .venv/bin/activate
   pip install -r requirements.txt
   ```

2. Set required environment variables (DB, secrets, GCP, Supabase). Ensure `DJANGO_SETTINGS_MODULE=iact_api.settings`.

3. Run the server:

   ```bash
   python manage.py runserver
   ```

4. Optional: Run with Docker/Procfile.

### Notes

- The legacy `api/` module is being replaced by `iact_api/` (see git status). Ensure the new settings module is used in local and deploy environments.

