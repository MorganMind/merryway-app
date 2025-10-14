# Merryway

A modern Flutter application built with clean architecture, featuring modular design, BLoC state management, and multi-environment support.

## 📑 Table of Contents

- [Project Scaffolding](#-project-scaffolding)
- [Architecture Overview](#-architecture-overview)
- [Technology Stack](#️-technology-stack)
- [Getting Started](#-getting-started)
- [Task Triage: Frontend vs Backend](#-task-triage-frontend-vs-backend)
- [Module Deep Dive](#-module-deep-dive)
- [Key Concepts](#-key-concepts)
- [Testing](#-testing)
- [Development Workflow](#-development-workflow)
- [Debugging](#-debugging)
- [Project Assets](#-project-assets)
- [Platform Support](#-platform-support)
- [Contributing](#-contributing)
- [Backend Integration](#-backend-integration-iact-api)

## 🏗️ Project Scaffolding

```
merryway/
├── 📱 Platform Configuration
│   ├── android/                    # Android native configuration
│   │   ├── app/
│   │   │   ├── build.gradle
│   │   │   ├── google-services.json
│   │   │   └── src/
│   │   │       ├── debug/AndroidManifest.xml
│   │   │       ├── main/AndroidManifest.xml
│   │   │       └── profile/AndroidManifest.xml
│   │   └── build.gradle
│   ├── ios/                        # iOS native configuration
│   │   ├── Runner/
│   │   │   ├── AppDelegate.swift
│   │   │   ├── Info.plist
│   │   │   └── Assets.xcassets/
│   │   └── Runner.xcodeproj/
│   └── web/                        # PWA configuration
│       ├── index.html
│       ├── manifest.json
│       └── icons/
│
├── 🎨 Assets
│   └── assets/
│       └── img/                    # Application images and icons
│           ├── logo.png
│           ├── logo_full_black.png
│           ├── logo_full_white.png
│           ├── onboarding_bg.png
│           └── [icons...]
│
├── 📦 Core Application
│   └── lib/
│       ├── 🚀 Entry Points
│       │   ├── main.dart                      # Base entry point
│       │   ├── main_development.dart          # Development environment
│       │   ├── main_staging.dart              # Staging environment
│       │   └── main_production.dart           # Production environment
│       │
│       ├── ⚙️ Configuration
│       │   ├── config/
│       │   │   └── environment.dart           # Environment config
│       │   └── firebase_options.dart          # Firebase config (generated)
│       │
│       └── 🧩 Modules (Feature-based Architecture)
│           │
│           ├── 🔐 auth/                       # Authentication module
│           │   ├── blocs/                     # State management
│           │   │   ├── auth_bloc.dart
│           │   │   ├── auth_event.dart
│           │   │   └── auth_state.dart
│           │   ├── pages/                     # UI screens
│           │   │   ├── login_page.dart
│           │   │   ├── signup_page.dart
│           │   │   └── join_page.dart
│           │   └── services/
│           │       └── auth_state_listener.dart
│           │
│           ├── 🎯 core/                       # Shared infrastructure
│           │   ├── blocs/                     # Layout state management
│           │   │   ├── layout_bloc.dart
│           │   │   ├── layout_event.dart
│           │   │   └── layout_state.dart
│           │   ├── di/
│           │   │   └── service_locator.dart   # Dependency injection
│           │   ├── enums/                     # Shared enumerations
│           │   │   ├── avatar_shape.dart
│           │   │   └── avatar_type.dart
│           │   ├── platform/                  # Platform-specific code
│           │   │   ├── url_strategy.dart
│           │   │   ├── url_strategy_web.dart
│           │   │   └── url_strategy_stub.dart
│           │   ├── routing/                   # Navigation
│           │   │   ├── app_router.dart        # Route definitions
│           │   │   ├── router_observer.dart
│           │   │   ├── router_refresh_stream_group.dart
│           │   │   └── router-refresh-stream.dart
│           │   ├── services/                  # Core services
│           │   │   ├── api/                   # API clients
│           │   │   ├── sse/                   # Server-sent events
│           │   │   ├── upload/                # File upload
│           │   │   └── lexorank.dart          # Ordering utility
│           │   ├── theme/                     # Theme configuration
│           │   │   ├── theme_colors.dart
│           │   │   ├── theme_extension.dart
│           │   │   └── theme_provider.dart
│           │   ├── ui/                        # Reusable UI components
│           │   │   ├── dialogs/
│           │   │   ├── pages/
│           │   │   └── widgets/               # 28+ shared widgets
│           │   └── utils/                     # Utilities
│           │       └── invite_code_utils.dart
│           │
│           ├── 🏠 home/                       # Home module
│           │   ├── pages/
│           │   │   ├── home_layout.dart
│           │   │   └── home_page.dart
│           │   └── widgets/
│           │       ├── action_cards.dart
│           │       └── feed_card.dart
│           │
│           ├── ✉️ invites/                    # Invitations module
│           │   ├── blocs/                     # State management
│           │   ├── models/
│           │   │   └── invite.dart
│           │   └── repositories/
│           │       └── invites_repository.dart
│           │
│           ├── 👥 memberships/                # Memberships module
│           │   ├── models/
│           │   ├── repositories/
│           │   └── screens/
│           │
│           ├── 🎓 onboarding/                 # Onboarding flow
│           │   ├── blocs/
│           │   ├── models/
│           │   └── pages/
│           │
│           ├── ⚙️ settings/                   # Settings module
│           │   ├── blocs/
│           │   ├── pages/                     # 9+ settings screens
│           │   └── widgets/
│           │
│           ├── 🏷️ tags/                       # Tagging system
│           │   ├── blocs/
│           │   └── models/
│           │
│           ├── 🎤 transcriptions/             # Audio transcription
│           │   ├── services/
│           │   └── widgets/
│           │
│           └── 👤 user/                       # User management
│               ├── blocs/
│               ├── models/
│               └── repositories/
│
├── 🧪 Testing
│   └── test/
│       └── widget_test.dart
│
└── 📄 Configuration Files
    ├── pubspec.yaml                # Dependencies & flavors
    ├── pubspec.lock
    ├── analysis_options.yaml       # Linter configuration
    ├── devtools_options.yaml
    ├── firebase.json
    └── README.md
```

## 🎯 Architecture Overview

### **Clean Architecture + Feature Modules**
- **Feature-based organization**: Each module is self-contained with its own BLoCs, models, repositories, and UI
- **Separation of concerns**: Business logic (BLoC), data (repositories), and UI (widgets/pages) are clearly separated
- **Core module**: Shared infrastructure, services, and UI components used across features

### **State Management: BLoC Pattern**
Each feature module typically contains:
- `*_bloc.dart` - Business logic and state transitions
- `*_event.dart` - User actions and system events
- `*_state.dart` - UI states

### **Dependency Injection**
- Uses `get_it` package
- All services and repositories registered in `service_locator.dart`
- Enables testing and loose coupling

## 🛠️ Technology Stack

### **Core Framework**
- **Flutter 3.6.0+** - Cross-platform UI framework
- **Dart** - Programming language

### **State Management & Architecture**
- **flutter_bloc (8.1.6)** - BLoC pattern implementation
- **get_it (8.0.3)** - Dependency injection
- **watch_it (1.6.2)** - Reactive state observation
- **equatable (2.0.7)** - Value equality

### **Navigation**
- **go_router (14.6.2)** - Declarative routing

### **Backend & Services**
- **supabase_flutter (2.8.2)** - Backend as a service
- **firebase_core (3.10.0)** - Firebase integration
- **http (1.1.0)** & **dio (5.7.0)** - HTTP clients
- **flutter_client_sse (2.0.3)** - Server-sent events
- **fetch_client (1.1.2)** - HTTP fetch API

### **UI Components & Theming**
- **shadcn_ui (0.17.6)** - UI component library
- **google_fonts (6.2.1)** - Typography
- **font_awesome_flutter (10.8.0)** - Icons
- **cupertino_icons (1.0.8)** - iOS-style icons
- **auto_size_text (3.0.0)** - Responsive text
- **dotted_border (2.1.0)** - Custom borders
- **flutter_markdown (0.7.5)** - Markdown rendering

### **Media & File Handling**
- **record (4.4.4)** - Audio recording
- **flutter_sound (9.19.1)** - Audio playback
- **file_picker (8.3.1)** - File selection
- **desktop_drop (0.5.0)** - Drag & drop support
- **cross_file (0.3.4+2)** - Cross-platform file handling
- **path_provider (2.1.5)** - File system paths

### **Utilities**
- **intl (0.19.0)** - Internationalization
- **timeago (3.7.0)** - Human-readable timestamps
- **permission_handler (11.3.1)** - Device permissions
- **shared_preferences (2.5.3)** - Local storage
- **url_launcher (6.2.1)** - URL handling
- **http_parser (4.1.2)** - HTTP parsing

### **Development Tools**
- **flutter_lints (5.0.0)** - Linting rules
- **flutter_test** - Testing framework

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.6.0 or higher
- Dart SDK
- Firebase project configured
- iOS/Android development environment setup

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd merryway
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Add your `google-services.json` to `android/app/`
   - Configure iOS Firebase in Xcode
   - Run Firebase configuration generator if needed

4. **Run the app**
   
   **Development environment:**
   ```bash
   flutter run -t lib/main_development.dart
   ```
   
   **Staging environment:**
   ```bash
   flutter run -t lib/main_staging.dart
   ```
   
   **Production environment:**
   ```bash
   flutter run -t lib/main_production.dart
   ```

### Environment Flavors

The app supports three flavors defined in `pubspec.yaml`:

| Flavor | App Name | Entry Point |
|--------|----------|-------------|
| Development | Merryway Dev | `lib/main_development.dart` |
| Staging | Merryway Staging | `lib/main_staging.dart` |
| Production | Merryway | `lib/main_production.dart` |

## 📋 Task Triage: Frontend vs Backend

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
1. Implement the UI and API calls on the frontend
2. Document any missing/changed backend APIs in the issue and mark as "Backend needs to handle" with clear inputs/outputs and expected behavior

## 📚 Module Deep Dive

### 🔐 Authentication Module (`lib/modules/auth/`)
Handles all authentication flows including login, signup, and invite-based joining.

**Components:**
- `AuthBloc` - Manages authentication state
- `LoginPage` - User login interface
- `SignupPage` - New user registration
- `JoinPage` - Invite-based joining
- `AuthStateListener` - Monitors auth state changes

### 🎯 Core Module (`lib/modules/core/`)
The backbone of the application providing shared infrastructure.

**Key Services:**
- **API Client** - HTTP communication with backend
- **SSE Service** - Real-time server-sent events
- **Upload Service** - File upload handling
- **LexoRank** - Ordering system for sortable lists

**Routing:**
- `AppRouter` - Centralized route definitions using GoRouter
- `RouterObserver` - Navigation analytics and debugging
- Route refresh streams for reactive navigation

**Theme System:**
- `ThemeProvider` - Theme state management
- `ThemeColors` - Color palette definitions
- `ThemeExtension` - Extended theme properties

**UI Components:**
- 28+ reusable widgets
- Custom dialogs
- Shared page templates

### 🏠 Home Module (`lib/modules/home/`)
Main application interface and feed display.

**Components:**
- `HomeLayout` - Main layout structure
- `HomePage` - Primary home screen
- `ActionCards` - Quick action widgets
- `FeedCard` - Content feed items

### ✉️ Invites Module (`lib/modules/invites/`)
Manages invitation system for user onboarding.

**Components:**
- `InviteBloc` - Invitation state management
- `Invite` model - Invitation data structure
- `InvitesRepository` - Data access layer

### 👥 Memberships Module (`lib/modules/memberships/`)
Handles group memberships and permissions.

**Structure:**
- Models for membership data
- Repository for data access
- Screens for membership management

### 🎓 Onboarding Module (`lib/modules/onboarding/`)
First-time user experience and setup flow.

**Components:**
- `OnboardingBloc` - Flow state management
- Onboarding models
- Step-by-step pages

### ⚙️ Settings Module (`lib/modules/settings/`)
Comprehensive application settings management.

**Features:**
- 9+ settings screens
- `SettingsBloc` - Settings state
- Custom settings widgets
- Profile management
- Preferences configuration

### 🏷️ Tags Module (`lib/modules/tags/`)
Content organization and categorization system.

**Components:**
- `TagsBloc` - Tag state management
- Tag models and data structures
- Tag association logic

### 🎤 Transcriptions Module (`lib/modules/transcriptions/`)
Audio transcription functionality.

**Features:**
- Transcription services
- Audio processing
- Transcription display widgets

### 👤 User Module (`lib/modules/user/`)
User profile and account management.

**Components:**
- `UserBloc` - User state management
- User models (profile, preferences, etc.)
- User repositories
- Account management

## 🔑 Key Concepts

### BLoC Pattern
Each feature follows the BLoC (Business Logic Component) pattern:
```
Feature/
├── blocs/
│   ├── feature_bloc.dart      # Logic & state transitions
│   ├── feature_event.dart     # User actions
│   └── feature_state.dart     # UI states
├── models/                     # Data models
├── repositories/               # Data layer
└── pages/ or widgets/          # UI layer
```

### Service Locator Pattern
All dependencies are registered at app startup:
```dart
// In service_locator.dart
getIt.registerSingleton<ApiService>(ApiService());
getIt.registerFactory<UserRepository>(() => UserRepository());

// Usage in widgets
final apiService = getIt<ApiService>();
```

### Environment Configuration
Different configurations for different environments:
- **Development**: Debug mode, development backend
- **Staging**: Testing with production-like setup
- **Production**: Live production environment

## 🧪 Testing

### Running Tests
```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test file
flutter test test/widget_test.dart
```

### Test Structure
Tests are organized in the `test/` directory, mirroring the `lib/` structure.

## 🔧 Development Workflow

### Code Style
The project follows Flutter's recommended linting rules defined in `analysis_options.yaml`.

**Check for issues:**
```bash
flutter analyze
```

**Format code:**
```bash
flutter format .
```

### Common Commands
```bash
# Clean build artifacts
flutter clean

# Get dependencies
flutter pub get

# Update dependencies
flutter pub upgrade

# Build for specific platform
flutter build apk          # Android APK
flutter build appbundle    # Android App Bundle
flutter build ios          # iOS
flutter build web          # Web

# Run on specific device
flutter devices            # List available devices
flutter run -d chrome      # Run on Chrome
flutter run -d <device-id> # Run on specific device
```

### Hot Reload vs Hot Restart
- **Hot Reload** (r): Updates UI without losing state
- **Hot Restart** (R): Restarts app, loses state
- **Full Restart** (q): Quit and restart

### Adding New Features

1. **Create Module Structure**
   ```
   lib/modules/new_feature/
   ├── blocs/
   │   ├── new_feature_bloc.dart
   │   ├── new_feature_event.dart
   │   └── new_feature_state.dart
   ├── models/
   ├── repositories/
   ├── pages/
   └── widgets/
   ```

2. **Register Dependencies** in `service_locator.dart`

3. **Add Routes** in `app_router.dart`

4. **Implement BLoC Pattern**
   - Define events
   - Define states
   - Implement bloc logic

5. **Build UI**
   - Create pages/widgets
   - Use BlocBuilder/BlocListener
   - Inject dependencies via GetIt

### Best Practices

✅ **DO:**
- Use BLoC for business logic
- Keep widgets small and focused
- Reuse components from `core/ui/widgets`
- Follow the existing module structure
- Use dependency injection (GetIt)
- Write descriptive commit messages
- Test your changes

❌ **DON'T:**
- Put business logic in widgets
- Create duplicate widgets (check core/ui first)
- Hard-code values (use theme/constants)
- Mix multiple responsibilities in one class
- Skip error handling

## 🐛 Debugging

### Flutter DevTools
```bash
# Open DevTools
flutter pub global activate devtools
flutter pub global run devtools
```

### Debug Modes
```bash
# Run in debug mode (default)
flutter run

# Run in profile mode (performance testing)
flutter run --profile

# Run in release mode
flutter run --release
```

### Common Issues

**Issue: Dependencies not found**
```bash
flutter pub get
flutter clean
flutter pub get
```

**Issue: Build errors**
```bash
flutter clean
cd ios && pod install && cd ..  # iOS only
flutter run
```

**Issue: Firebase configuration**
- Verify `google-services.json` is in `android/app/`
- Check `firebase_options.dart` is generated
- Ensure Firebase project is properly configured

## 📦 Project Assets

All assets are located in `assets/img/` and declared in `pubspec.yaml`:
- Application logos (light/dark/full variants)
- Onboarding backgrounds
- Icons (SVG format)
- Default group images

**Usage:**
```dart
Image.asset('assets/img/logo.png')
```

## 🌐 Platform Support

| Platform | Status | Notes |
|----------|--------|-------|
| Android | ✅ Full Support | API 21+ (Android 5.0+) |
| iOS | ✅ Full Support | iOS 12.0+ |
| Web | ✅ Full Support | Modern browsers |
| macOS | ⚠️ Partial | Not primary target |
| Windows | ⚠️ Partial | Not primary target |
| Linux | ⚠️ Partial | Not primary target |

## 📝 Contributing

1. Create a feature branch from `master`
2. Make your changes following the project structure
3. Test thoroughly on all target platforms
4. Submit a pull request with clear description

---

## 🔌 Backend Integration (iact-api)

This Flutter frontend connects to a Django backend (`iact-api`) for all data operations.

### Backend Structure Overview

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

---

## 📖 Additional Resources

### Flutter Resources
- [Flutter Documentation](https://docs.flutter.dev/)
- [Flutter Cookbook](https://docs.flutter.dev/cookbook)
- [BLoC Pattern Guide](https://bloclibrary.dev/)
- [GoRouter Documentation](https://pub.dev/packages/go_router)

### Design & UI
- [shadcn/ui Components](https://ui.shadcn.com/)
- [Material Design Guidelines](https://material.io/design)
- [Flutter Widget Catalog](https://docs.flutter.dev/development/ui/widgets)

### Backend Integration
- [Supabase Documentation](https://supabase.com/docs)
- [Firebase for Flutter](https://firebase.google.com/docs/flutter/setup)
- [REST API Best Practices](https://restfulapi.net/)

---

## 📄 License

This project is proprietary software. All rights reserved.

---

**Built with ❤️ using Flutter**

