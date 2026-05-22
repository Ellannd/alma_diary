
# Alma - Diary 🌟(MVP)

> A mindful journaling companion powered by AI — *Escribe. Sana. Vive.*
Alma is a mobile-first journaling application designed to help users build a consistent self-reflection habit. It combines end-to-end encrypted journal entries, AI-generated emotional insights, gamified daily challenges, personalized readings, and a push notification system into a single focused experience.
All journal content is encrypted client-side using AES-256-GCM before it reaches the server. The backend never has access to plaintext entries.

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.11.4-blue?logo=flutter" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-3.11.4-blue?logo=dart" alt="Dart" />
  <img src="https://img.shields.io/badge/Supabase-Backend-green?logo=supabase" alt="Supabase" />
  <img src="https://img.shields.io/badge/Gemini-AI-orange?logo=google" alt="Gemini AI" />
  <img src="https://img.shields.io/badge/Hugging-Face-yellow?logo=HuggingFace" alt="Hugging Face" />
  <img src="https://img.shields.io/badge/Version-3.4.14-purple" alt="Version" />
  <img src="https://img.shields.io/badge/Status-Active%20Development-brightgreen" alt="Status" />
</p>

---

## 📸 App Screenshots

| Onboarding Flow | Dashboard (Light) | Journal Editor |
|:---:|:---:|:---:|
| *(coming soon)* | <img width="412" height="917" alt="Android Compact - 10" src="https://github.com/user-attachments/assets/d0705726-02f8-4709-a3c8-92fcc25c4c94" /> | <img width="403" height="896" alt="f33d64ae-1bb7-49f1-b49e-457ca58e5693" src="https://github.com/user-attachments/assets/4a1027a3-2652-47f9-b184-b1e92af62a5f" /> |

| Trajectory | Search | Challenges |
|:---:|:---:|:---:|
| <img width="576" height="1280" alt="33740b9c-217d-491b-bd3a-8372f63639b4" src="https://github.com/user-attachments/assets/b86d93d2-1626-4550-bf1c-12b07a9e6bc0" /> | <img width="576" height="1280" alt="fabbbd27-5c3b-489a-a456-550ce2666479" src="https://github.com/user-attachments/assets/6e87aff0-c845-49e4-9d07-12ff4ced7476" /> | <img width="576" height="1280" alt="1c30c73b-e179-4b85-b1ce-c00f588c26be" src="https://github.com/user-attachments/assets/6f8c61d1-b5b6-4b4c-a09f-daba9753fcb6" /> |

## 📸 Figma Wireframes

| Light| Dark | Journal Screen |
|:---:|:---:|:---:|
| <img width="412" height="917" alt="Android Compact - 10" src="https://github.com/user-attachments/assets/8665731c-ffdf-4a19-9918-990f7ef9be49" /> | <img width="412" height="917" alt="Android Compact - 11" src="https://github.com/user-attachments/assets/57703873-4109-4889-9746-fe2b51041aa9" /> | <img width="412" height="917" alt="Android Compact - 12" src="https://github.com/user-attachments/assets/40d595b9-fb2b-4dda-b3f0-b697d3dfe511" /> |
---

## 🌟 Feature Set


### Journal
	• Create, edit, and delete encrypted diary entries
	• Mood and emotion tagging per entry
	• Full-text search across entries (client-side decryption before search)
	• Entry-level AI analysis: generates reflections and emotional insights from a single entry
### AI Insights (Reflections)
	• Powered by Hugging Face inference API via direct HTTP requests
	• Analyzes journal entries and generates structured reflections
	• Emotion pattern recognition across entries
	• Readings generation method available (not yet connected — pending UX design for psychological mechanics)
	• Roadmap: RAG integration (v2+), on-device inference (v4.0)
### Challenges
	• Gamified self-improvement tasks with defined difficulty levels and categories
	• Progress tracking with percentage completion
	• Point-based reward system on challenge completion
	• Push notifications on challenge start and completion
	• Validation engine prevents duplicate or conflicting challenge enrollment
### Trajectory
	• Visual progress tracking over time using fl_chart
	• Tracks both emotional state history and challenge points
	• Provides a longitudinal view of the user's self-improvement journey
### Quotes
	• Daily quote surfaced from a curated pool
	• Quote selection is deterministic per user per day (seed based on userId + date)
	• Delivered as an in-app notification and optionally as a push
### Readings
	• Personalized reading content module
	• Engine implemented, content delivery mechanics in design phase
### Search
	• Cross-feature search engine
	• Searches across journal entries (with decryption), challenges, and notifications
### Notifications
#### In-app notifications (bell icon, unread count):
	• Stored in the notifications table in Supabase
	• Types: daily_quote, challenge_started, challenge_completed, insight, daily_reminder
	• Managed by AlmaNotificationEngine
### Push notifications (device-level):
	• Delivered via Firebase Cloud Messaging (FCM v1)
	• Sent through Supabase Edge Function send-notification
	• Triggered on: post-login daily reminder, challenge events
	• User-configurable via notification_settings
### Onboarding
#### Multi-step flow that collects:
	• Emotional state at signup
	• Pain points and main challenges
	• Hopeful goals
	• Stress level (scale)
	• Sleep quality
	• Preferred language
	• Display name
#### This data drives AI personalization and reading recommendations.
### Profile & Settings
	• Profile (name, avatar)
	• Notification preferences (daily reminder toggle)
	• Theme selection (light / dark)
	• Account management
### Dashboard
	• Central hub surfacing recent journal activity, active challenges, daily quote, and unread notifications
#### Responsive layout adapting to screen size via responsive_framework
---

## Architecture

Alma follows a feature-first layered architecture where UI, state, and business logic are strictly separated. Features are self-contained modules; cross-feature coordination goes exclusively through state/ controllers.

```text
lib/
├── core/                # Cross-cutting infrastructure
│   ├── crypto/          # AES-256-GCM encryption, secure storage, key lifecycle
│   ├── navigation/      # Router, navigator observer, route definitions
│   ├── logging/         # Structured log service, breadcrumbs, crash pipeline
│   ├── error/           # Global error handlers (Flutter, Platform, Zone)
│   ├── session/         # Auth session coordination
│   └── constants.dart
│
├── services/            # SDK integrations (singletons)
│   ├── fcm_listener_service.dart   # FCM token lifecycle
│   ├── supabase_service.dart       # Supabase client wrapper
│   ├── ai_service.dart             # Hugging Face HTTP client
│   └── storage_service.dart        # Local storage abstraction
│
├── state/               # Riverpod controllers (app-slice state)
│   ├── auth/            # AuthController, AuthAppState
│   ├── profile/         # ProfileController, currentUserProvider
│   ├── notifications/
│   ├── journal/
│   ├── reflections/
│   ├── emotion/
│   ├── theme/
│   └── dashboard/
│
├── features/            # Feature modules (UI + data + domain + engine)
│   ├── auth/
│   ├── dashboard/
│   ├── journal/
│   ├── challenges/
│   ├── reflections/
│   ├── trajectory/
│   ├── readings/
│   ├── quotes/
│   ├── search/
│   ├── profile/
│   ├── onboarding/
│   └── notifications/
│
├── models/              # Shared domain models
└── design_system/       # Tokens, components, layouts, theme
    ├── tokens/          # Colors, typography, spacing, radius
    ├── components/      # Reusable widgets
    └── layouts/         # Layout primitives
```

### Dependency direction

UI → state → feature logic / data / services → core infrastructure

## Application Lifecycle

```text
main.dart
└── runZonedGuarded
    ├── flutter_dotenv → loads .env
    ├── AppConfig.init(Environment.dev)
    ├── LogService.instance.init()
    ├── ErrorHandlers.init()
    ├── bootstrapServices()
    │   ├── Google Fonts preload
    │   ├── CrashReporter.init()
    │   ├── Firebase.init()
    │   ├── FcmService.instance.init()  ← local notification channel + FCM listeners
    │   ├── SupabaseService.init()
    │   ├── Date formatting (es)
    │   └── StorageService.init()       ← mobile only
    │
    └── runApp(ProviderScope)
        └── AuthGate
            ├── No session → AuthScreen
            └── Session → ProfileController.build()
                ├── await cryptoSessionProvider  ← crypto + FCM + notifications
                ├── profile == null              → OnboardingScreen
                └── onboardingComplete           → DashboardScreen
```


## Auth & Session Flow

### User signs in
* Supabase issues JWT
* `authChangesProvider` emits `AuthChangeEvent.signedIn`
* `cryptoSessionProvider` invalidates and re-runs
    * Loads or generates encryption key (Keychain → backend recovery → new)
    * Sets active session in `JournalService`
    * `FcmService.registerDevice(userId)`
        * Upserts FCM token in `user_devices`
* `currentUserProvider` emits User
* `ProfileController.build()` re-runs
    * Fetches / creates profile
    * `NotificationController.handlePostLogin(userId)`
        * `generateDailyQuote`
        * `generateDailyReminder` → `sendPush()` if not sent today
    * `trackLoginEvent`

`AuthController` is intentionally thin — it only handles sign-in / sign-up / sign-out mechanics and exposes `isLoading` and `error`. It does not own user or profile state.

---

## Crypto System

Every user gets a per-device AES-256-GCM encryption key stored in the platform keychain. The server never receives or stores plaintext journal content.

### `cryptoSessionProvider` (FutureProvider, keepAlive)
* Triggered by: `authChangesProvider` (invalidates on every auth change)
* Key resolution order:
    1. Load from platform Keychain / Android Keystore
    2. Recover from backend (reinstall scenario)
    3. Generate new key + persist
* On success:
    * `JournalService.setCryptoSession()`
    * `FcmService.registerDevice()`
* On sign out: `clearSession()` removes key from secure storage

Encryption / decryption is available via `CryptoSession.encryptText()` and `decryptText()`. Both fail gracefully if called before session initialization.

---

## Push Notification Pipeline

### Client (Flutter)
`FcmService.init()` — *called in bootstrap*
* Initializes local notification channel (`alma_channel`)
* Sets up foreground message listener → shows local notification
* Sets up background tap listener → routes to relevant screen

`FcmService.registerDevice(userId)` — *called post-login via cryptoSessionProvider*
* Requests notification permission (Android 13+ / iOS)
* Gets FCM token
* Removes any existing rows with same token (multi-account safety)
* Upserts `{ user_id, fcm_token, platform }` in `user_devices`

`onTokenRefresh` — *auto-updates token on Firebase rotation*

### Server (Supabase Edge Function: send-notification)
`POST /functions/v1/send-notification`
`{ userId, title, body }`
* **Auth:** service role key (internal) OR user JWT (app)
* **Authorization:** user JWT callers can only notify themselves
* Reads FCM tokens from `user_devices` `WHERE user_id = userId`
* Exchanges Service Account → OAuth2 Bearer token (FCM v1)
* Sends to each token individually (FCM v1 — no multicast)
* Cleans `UNREGISTERED` tokens from `user_devices` automatically

---

## Observability

### `LogService` (structured, in-memory + persistent)
* Buffers up to 500 entries in memory
* Persists in batches of 10 via `LogRepository`
* Attaches `LogContext` breadcrumbs to every entry
* Outputs to console in debug mode (`message` + `error` + `stack trace`)
* Routes error/fatal entries to `CrashReporter`

### `LogContext`
* Maintains a breadcrumb trail (actions, navigation events)

### `AppNavigatorObserver`
* Records every route change as a breadcrumb automatically

### Error Handlers
* `FlutterError.onError`
* `PlatformDispatcher.instance.onError`
* `runZonedGuarded` zone handler

---

## Database Schema


| Table | Purpose |
|---|---|
| **profiles** | User profile, onboarding data, preferences |
| **entries** | Encrypted journal entries |
| **user_devices** | FCM token registry — unique per (`user_id`, `platform`) |
| **notifications** | In-app notification inbox |
| **notification_settings** | Per-user push preferences (daily_reminder_enabled) |
| **challenges** | Challenge definitions (title, category, difficulty, points) |
| **user_challenges** | Per-user challenge enrollment and progress |
| **quotes** | Daily quote pool |
| **events** | Behavioral event log (login, onboarding_completed, etc.) |


## 🛠️ Tech Stack

### Frontend

| Technology | Version | Purpose |
|---|---|---|
| **Flutter (Dart)** | SDK ^3.11.4 | Mobile framework and programming language |
| **Riverpod** | ^3.3.1 | State management |
| **responsive_framework** | ^1.5.1 | Responsive layout |
| **google_fonts** | ^8.1.0 | Typography and fonts |

### Backend & Data

| Technology | Version | Purpose |
|---|---|---|
| **Supabase** | ^2.9.0 | Postgres, Auth, and Edge Functions backend |
| **flutter_secure_storage** | ^10.2.0 | Secure storage |

### AI & Analytics

| Technology | Version | Purpose |
|---|---|---|
| **Hugging Face (HTTP)** | — | AI inference |

### UI/UX

| Technology | Version | Purpose |
|---|---|---|
| **fl_chart** | ^0.63.0 | Charts and progress visualization |

### Utilities

| Technology | Version | Purpose |
|---|---|---|
| **Firebase Cloud Messaging (FCM v1)** | ^16.2.2 | Push notifications |
| **AES-256-GCM via PointyCastle** | ^3.9.1 | Encryption |
| **google_sign_in** | ^7.2.0 | Auth (Google) |
| **flutter_local_notifications** | ^17.2.2 | Local notifications |

---

## Environment Setup

### Prerequisites
* Flutter SDK >=3.11.4
* Supabase project
* Firebase project with Android app configured
* Google Cloud Service Account with Firebase Cloud Messaging Admin role
* Hugging Face API key

### .env (project root)
```text
SUPABASE_URL=https://supabase.co
SUPABASE_ANON_KEY=your_anon_key
GOOGLE_WEB_CLIENT_ID=your_web_client_id
HUGGING_FACE_API_KEY=your_hf_key
```

### Firebase — Android
1. Download `google-services.json` from Firebase Console and place it at `android/app/google-services.json`
2. Register the SHA-1 and SHA-256 of your signing certificate under **Firebase Console** → **Project Settings** → **Your Android app** → **SHA certificate fingerprints**

To get your debug certificate fingerprint:
* **macOS / Linux**
  ```bash
  keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
  ```
* **Windows**
  ```cmd
  keytool -list -v -keystore %USERPROFILE%\.android\debug.keystore -alias androiddebugkey -storepass android -keypass android
  ```

### Supabase Edge Function secrets
Set these in **Supabase Dashboard** → **Project Settings** → **Edge Functions** → **Secrets**:
```text
FCM_CLIENT_EMAIL   service account client_email
FCM_PRIVATE_KEY    service account private_key (escape newlines as \n)
FCM_PROJECT_ID     Firebase project ID
```

### Install and run
```bash
flutter pub get
flutter run
```

---

## Build & Release

### Debug build (uses debug keystore — for testing FCM)
```bash
flutter build apk --debug
```

### Release build
1. Generate a production keystore:
   ```bash
   keytool -genkey -v -keystore ~/alma-release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias alma
   ```
2. Create `android/key.properties` (never commit this file):
   ```properties
   storePassword=your_password
   keyPassword=your_key_password
   keyAlias=alma
   storeFile=/absolute/path/to/alma-release.jks
   ```
3. Register the production SHA-1 and SHA-256 in Firebase Console and re-download `google-services.json`.
4. Build:
   ```bash
   flutter build apk --release # APK
   flutter build appbundle --release # App Bundle (Play Store)
   ```

---

## Supabase Edge Functions

### Deploy
```bash
supabase link --project-ref your_project_ref
supabase functions deploy send-notification --no-verify-jwt
```
* `--no-verify-jwt` is required because the function handles its own auth validation (supports both service-role key and user JWT callers).

---

## Roadmap


| Version | Planned |
|---|---|
| **v3.4.14 (MVP)** | Journal, challenges, AI reflections, push notifications, onboarding |
| **v4.0** | RAG integration for context-aware AI insights, Personalized readings engine (psychology-backed content delivery) (in private development)|
| **v5.0** | On-device AI inference (in private development) |

---

## Security Model

* Journal entries are encrypted with AES-256-GCM before leaving the device
* Encryption keys live exclusively in platform secure storage (iOS Keychain / Android Keystore) — never transmitted to the server
* Key recovery supports reinstallation scenarios via a backend fallback
* The `send-notification` Edge Function enforces that a user JWT caller can only send notifications to themselves
* FCM tokens are unique per (`user_id`, `platform`) — on new device registration, tokens belonging to other users are removed before upsert
* The `.env` file and `key.properties` are excluded from version control

---

## Project Conventions

* New features go under `features/<feature>/` with their own `data/`, `domain/`, `engine/`, and `UI` directories
* State is exposed via a Riverpod controller in `state/<feature>/`
* Privileged server operations (anything requiring secrets or cross-user access) go in Supabase Edge Functions
* Logging: use `LogService.instance` throughout — never `print()` in production code
* The `LogService` automatically captures breadcrumbs, batches persistence, and routes errors to crash reporting


## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit your changes: `git commit -m 'feat: add amazing feature'`
4. Push: `git push origin feature/amazing-feature`
5. Open a Pull Request

Run `flutter analyze` and `flutter format .` before submitting.

---

## 📄 License

Currently **private**. Licensing will be added prior to public release.

---

## 🙏 Acknowledgments

- **Google Flutter Team** — Amazing cross-platform framework
- **Supabase** — Backend-as-a-Service that just works
- **Google DeepMind** — Gemini AI powering the insights
- **Mental Health Community** — For feedback on ethical considerations

---

> **Disclaimer:** Alma Diary is a self-reflection tool and is not a substitute for professional mental health care. If you are experiencing a crisis, please contact a licensed mental health professional or emergency services immediately.

---

*Developed by **Arnaldo Ramos** · For ethics and data handling details, see `lib/ethics/`*
```
