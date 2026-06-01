# Workspace Architecture — alma_diary

## 1. High-level overview
**Alma Diary** is a cross-platform journaling app (Flutter) that combines:
- **Client-side state management** (Riverpod)
- **Client-side security** (crypto session + encryption/decryption)
- **Backend services** (Supabase for Auth, Postgres, and Edge Functions)
- **AI-driven insights** (Gemini via the app’s AI modules)
- **Engagement features** (push notifications via FCM, delivered through a Supabase Edge Function)
- **Observability** (structured logging with breadcrumbs + crash reporting)

The codebase is organized around a **feature-first layered architecture** to keep UI, state, and business logic separated and to reduce coupling between modules.

---

## 2. Repository layout (mental model)
The main directories in `lib/` map to architectural responsibilities:

### `lib/`
- **`lib/core/`** — cross-cutting platform concerns
  - environment configuration
  - routing/navigation glue
  - logging pipeline
  - shared error handling
  - session helpers (auth/session integration)
  - crypto-related primitives and session lifecycle

- **`lib/services/`** — infrastructure integrations
  - wraps platform/service SDK initializations (Supabase, storage, FCM listener, etc.)
  - exposes service APIs to the app lifecycle and feature layers

- **`lib/state/`** — state controllers (Riverpod)
  - Riverpod `Notifier` / `AsyncNotifier` controllers represent the “app slice” states
  - controllers coordinate repositories/services, manage loading/error states, and provide UI-ready state

- **`lib/features/`** — feature modules
  - each feature is implemented as a self-contained module:
    - **UI** (`screen/`, widgets)
    - **data layer** (`data/`)
    - **domain/business logic** (`domain/`)
    - **engines/use-cases** (`engine/`)
  - features depend on `core` and `services`, and expose data/actions through `state` controllers

- **`lib/design_system/`** — UI consistency layer
  - tokens (colors, typography, spacing, radius)
  - theme configuration
  - reusable components/layouts

- **`lib/models/`** — cross-feature domain models

### `supabase/`
- **`supabase/config.toml`** — Supabase project + Edge Functions configuration
- **`supabase/functions/`** — serverless functions used by the app
  - e.g. notification delivery and secure server-side operations

---

## 3. Application lifecycle and boot sequence
### `lib/main.dart`
The entry point uses a **safe execution zone** and performs a staged initialization:
1. **`runZonedGuarded`** funnels unhandled exceptions to a centralized error handler.
2. **Environment configuration** is loaded using `flutter_dotenv` from `.env`.
3. **Core startup**:
   - `AppConfig.init(Environment.dev)` for environment-level configuration
   - `LogService.instance.init()` for structured log initialization
   - `ErrorHandlers.init()` to enable global error capturing
4. **Service bootstrap**: `bootstrapServices()` initializes required runtime dependencies.
5. **Telemetry context**: `LogContext.instance.newSession()` starts a new breadcrumb/logging session.
6. **UI mount**: `runApp(ProviderScope(...))` injects Riverpod overrides (e.g. repository instances).

### `lib/bootstrap.dart`
`bootstrapServices()` is a **central orchestrator** for asynchronous startup work. It:
- Preloads fonts (pending fonts via Google Fonts)
- Initializes:
  - Crash reporter
  - Supabase service
  - Firebase initialization
  - FCM listener service
  - i18n/Date formatting (Spanish defaults)
- Initializes a **storage strategy**:
  - non-web: `StorageService.instance.init()`
  - web: storage behavior is delegated (in practice to Supabase/local delegation)

A helper `_safeInit()` logs success/failure for each subsystem without hard-crashing the app.

---

## 4. Navigation and routing
### `lib/core/navigation/`
- **`app_router.dart`** holds the routing table via `onGenerateRoute`.
- **`app_navigator_observer.dart`** provides an observer attached to the `MaterialApp`.

### `lib/app.dart`
- Builds the `MaterialApp` instance.
- Delegates routing to `AppRouter.onGenerateRoute`.
- Attaches `AppNavigatorObserver` to record navigation breadcrumbs for telemetry/logging.
- Theme mode is controlled by Riverpod (`themeControllerProvider`).

---

## 5. State management approach (Riverpod)
### `lib/state/`
State is modeled through Riverpod controllers:
- `Notifier` / `AsyncNotifier`-style providers represent app slices.
- Controllers typically:
  - read repositories/services
  - perform side effects (network calls, AI requests, encryption actions)
  - emit UI state (loading/error/data)

### Pattern intent
- **UI remains “thin”**: widgets read state and trigger actions.
- **State controllers remain “orchestrators”**: they coordinate domain operations.
- **Features remain modular**: domain/data/engines under `features/` remain cohesive.

---

## 6. Crypto session and data protection
### `lib/core/crypto/crypto_provider.dart`
The app uses the concept of a **crypto session** built from:
- local key material stored in secure storage
- encryption/decryption utilities
- local key recovery and per-user initialization

Key responsibilities:
- `cryptoSessionProvider` is kept alive for the active authentication lifecycle.
- On sign-in (when a user exists in Supabase auth state):
  - initializes crypto key material (secure keychain → backend recovery → fallback generation)
  - sets the active crypto session into `JournalService`
  - triggers notification device registration for the user

Crypto operations (`encryptText`, `decryptText`) depend on secure key availability and fail gracefully if the session is not initialized.

---

## 7. Logging, error handling, and observability
### `lib/core/logging/`
This project implements a layered observability pipeline:
- **`LogService`** (`lib/core/logging/log_service.dart`)
  - stores log entries in memory
  - snapshots breadcrumb context from `LogContext`
  - flushes logs to persistence in batches (batching every 10 logs)
  - emits console output for visibility during development
  - triggers crash reporting capture when encountering `error`/`fatal`

- **`ErrorHandlers`**
  - global initialization to catch uncaught errors
  - integration with `runZonedGuarded`

- **`LogContext` + navigation breadcrumbs**
  - `AppNavigatorObserver` records navigation events
  - breadcrumbs are attached to logs and crash metadata

Net effect: a developer can correlate UI navigation paths with failures and reconstruct the context around errors.

---

## 8. Backend: Supabase Edge Functions and FCM notifications
### Supabase function: `supabase/functions/send-notification/index.ts`
This function implements server-side notification delivery using:
- **FCM v1** (HTTP v1 API)
- **OAuth2 JWT exchange** signed by a Service Account RSA key

Core flow:
1. **CORS + HTTP method checks**
2. Read required secrets/environment variables:
   - Supabase URL
   - FCM service account email and private key
   - FCM project id
3. Parse request JSON: `{ userId, title, body }`
4. **Caller authentication**:
   - accepts either a service-role token (internal calls)
   - or accepts a user JWT and validates it with Supabase auth
   - enforces authorization: a user can only notify themselves (`data.user.id === userId`)
5. Read FCM tokens from `user_devices` table by `user_id`
6. Send to tokens individually (FCM v1 multicast is not used)
7. **Token hygiene**:
   - if FCM reports invalid/unregistered tokens (e.g. `UNREGISTERED`), the function deletes them from the database

This design keeps token handling secure and centralized on the server.

---

## 9. How modules depend on each other (dependency direction)
While exact import relationships vary, the architectural intent is:
- `features/*` depend on:
  - `core/*` for shared infrastructure (routing conventions, logging, shared types)
  - `services/*` for integration boundaries
- `state/*` coordinates:
  - UI-facing behavior by invoking feature/data/domain functionality
  - service/repository calls
- `app.dart` / `main.dart` depend on:
  - `core` for observability and routing glue
  - `bootstrap.dart` for initialization

This produces a stable dependency flow:
**UI → state → feature logic/data/services → core infrastructure**

---

## 10. Practical development guidance
- Treat `lib/core/` as “infrastructure”: avoid feature-specific logic there.
- Implement new behavior in a `features/<feature>/` module first, then expose it via a controller in `lib/state/`.
- Use the `LogService` breadcrumbs to make failures diagnosable.
- For anything requiring privileged access or secrets (e.g. notification delivery), prefer **Supabase Edge Functions**.

---

## 11. Where to look for key concepts in the code
- **App lifecycle**: `lib/main.dart`, `lib/bootstrap.dart`
- **Routing/navigation**: `lib/core/navigation/app_router.dart`, `lib/core/navigation/app_navigator_observer.dart`, `lib/app.dart`
- **Logging**: `lib/core/logging/log_service.dart`, `lib/core/logging/log_context.dart`, `lib/core/logging/error_handlers.dart`
- **Crypto**: `lib/core/crypto/crypto_provider.dart`
- **Notification delivery**: `supabase/functions/send-notification/index.ts`

---

## 12. Notes about current README status
A `README.md` already exists in the repository and contains a high-level architecture section. This file (`WORKSPACE_ARCHITECTURE_README.md`) is intended to be a more professional “workspace architecture” document focused on structural understanding and dependency direction.

