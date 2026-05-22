
# Alma - Diary 🌟

> A mindful journaling companion powered by AI — *Escribe. Sana. Vive.*

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

## 📸 Screenshots

| Onboarding Flow | Dashboard | Journal Editor |
|:---:|:---:|:---:|
| *(coming soon)* | *(coming soon)* | *(coming soon)* |

| Trajectory | Search | Settings |
|:---:|:---:|:---:|
| *(coming soon)* | *(coming soon)* | *(coming soon)* |

---

## 🌟 Features

### Core Journaling
- **Daily Journal Entries** — Text-based reflections with text support
- **AI-Powered Sentiment Analysis** — Emotional Analysis using LLM via Api.
- **Archetype Identification** — Automatic categorization into psychological archetypes (The Mask, The Mirror, The Moon, The Shadow) (TODO)
- **Personalized Reflections** — AI-generated insights based on your unique emotional patterns (TODO)

### AI-Driven Insights
- **Daily Quotes** — Curated quotes tailored to your psychological profile (TODO)
- **Challenges System** — Self-improvement challenges personalized to your needs
- **Progress Tracking** — Visualize your emotional journey with charts and statistics
- **Reading Recommendations** — Personalized content based on your archetype and pain points

### User Experience
- **Encryption** — All journal entries encrypted with AES-256
- **Offline Support** — Local database with automatic cloud sync when online
- **Dark Mode** — Automatic theme switching based on system preference
- **Multi-Platform** — iOS, Android, and Web

### Notifications & Engagement
- **Smart Notifications** — AI-generated insights delivered at optimal times
- **Daily Reminders** — Gentle nudges to maintain your journaling habit
- **Progress Badges** — Celebrate milestones and achievements

---

## 🏗️ Architecture

Alma follows a **Feature-First Layered Architecture** with strict separation of concerns, powered by Riverpod for reactive state management.

```text
                     +----------------------------+
                     |       Presentación         |
                     |  (Screens, Widgets, UI)    |
                     +-------------+--------------+
                                   |
                                   v
                     +----------------------------+
                     |   Controladores / State    |
                     |   (Riverpod Notifiers)     |
                     +-------------+--------------+
                                   |
                                   v
                     +----------------------------+
                     |   Capa de Datos (Repos)    |
                     |   (Supabase / Log Buffers) |
                     +-------------+--------------+
                                   |
                    +--------------+--------------+
                    |                             |
                    v                             v
       +-------------------------+   +-------------------------+
       |   Servicios Core        |   |  Infraestructura / Ops  |
       | (Encryption, Storage)   |   | (Logging, Crashlytics)  |
       +-------------------------+   +-------------------------+
```

### Layer Breakdown

| Layer | Path | Responsibility |
|---|---|---|
| **Core** | `lib/core/` | Environment config, routing, logging pipeline. No business dependencies. |
| **Services** | `lib/services/` | Low-level infrastructure (DB init, local encryption, file storage) |
| **Features** | `lib/features/` | Self-contained business modules (views, repos, logic) |
| **State** | `lib/state/` | Global Riverpod controllers (`Notifier` / `AsyncNotifier`) |
| **Design System** | `lib/design_system/` | Tokens (colors, spacing, radius, typography) and themes |

### Design Patterns
- **Controller Pattern** — Feature controllers manage state and business logic
- **Repository Pattern** — Data access abstracted through repositories
- **Singleton Services** — Core services instantiated once at bootstrap
- **Dependency Injection** — Constructor injection for testability
- **Observer Pattern** — Stream-based auth state monitoring

---

## 📁 Project Structure

```text
.
├─ assets/                          # Static resources (logos, icons, backgrounds)
├─ data/
│  └─ fine_tuning_dataset.jsonl     # AI fine-tuning dataset
├─ supabase/                        # Serverless config & Edge Functions
│  ├─ config.toml
│  └─ functions/
└─ lib/
   ├─ main.dart                     # App entry point
   ├─ app.dart                      # MaterialApp, themes, breakpoints
   ├─ bootstrap.dart                # Service bootstrap orchestrator
   ├─ firebase_bootstrap.dart       # Firebase init & FCM stubs
   ├─ core/
   │  ├─ config/                    # Environment management (Dev/Staging/Prod)
   │  ├─ logging/                   # Reactive log pipeline, context, error handling
   │  └─ navigation/                # Static routes & observers (breadcrumbs)
   ├─ design_system/                # UI tokens & AlmaTheme
   ├─ ethics/                       # AI ethical guidelines & crisis protocol
   ├─ features/
   │  ├─ auth/                      # Authentication, login, AuthGate
   │  ├─ onboarding/                # 5-step emotional profiling flow
   │  ├─ dashboard/                 # User home hub
   │  ├─ journal/                   # Journal entry creation & editing
   │  ├─ readings/                  # Emotional support readings
   │  ├─ reflections/               # Trajectory visualizations
   │  └─ (...)                      # quotes, search, settings, notifications
   ├─ models/                       # Cross-cutting domain models
   ├─ services/                     # Native services & database integrations
   └─ state/                        # Riverpod state controllers
```

---

## 🚀 Bootstrap & Lifecycle

The app startup follows a critical zoned sequence to prevent production crashes and capture early exceptions:

1. **Safe Capture Zone** — Everything runs inside `runZonedGuarded`. Unhandled exceptions are processed by `ErrorHandlers.handleError`.
2. **Environment Init** — `AppConfig.init(Environment.dev)` sets debug variables and minimum log levels.
3. **Config Load** — Environment variables are mounted from the `.env` file.
4. **Service Bootstrap** (`bootstrapServices`):
   - Pre-loads Google Fonts (`Inter`, `Manrope`, `Roboto`)
   - Async safe initialization of **Firebase Core** and **Supabase**
   - Loads **local encryption** and **crash reporting** services
   - **Conditional storage strategy**: Mobile/Desktop → `StorageService`; Web → Supabase/LocalStorage
5. **Log Session** — `LogContext.instance.newSession()` opens a unique session, auto-injecting breadcrumbs on each navigation event.
6. **Mount** — The widget tree is launched with `ProviderScope` injecting required repository overrides.

---

## 🔄 Runtime Scenarios

### Scenario A: First-Time User (Onboarding Flow)

```text
[Boot] → [AuthGate] → [Not Authenticated] → [AuthScreen] → [Sign Up]
                                                                │
[Dashboard] ← [Onboarding Complete] ← [Saved to Supabase] ← [OnboardingScreen (5 steps)]
```

1. `AuthGate` intercepts — no session found → redirects to `AuthScreen`
2. User registers → `AuthController` (AsyncNotifier) calls `AuthRepository` → Supabase
3. On auth, `AuthGate` detects uninitialized profile → fires `profileController.loadProfile()` via post-frame callback
4. `profile.isOnboardingComplete == false` → routes to 5-step `OnboardingScreen` (emotional state, pain points, goals)
5. On finish → saves to `profiles` table, sets `is_onboarding_complete = true` → unlocks `DashboardScreen`

### Scenario B: Returning User

1. `AuthGate` detects active Supabase session
2. Verifies `profile.isOnboardingComplete == true`
3. Routes directly to `DashboardScreen` in under one second

---

## 📊 Observability & Telemetry

Alma includes a robust logging engine in `lib/core/logging/`:

- **Dynamic Log Buffering** — Events (`info`, `warning`, `debug`, `error`, `fatal`) are buffered in memory. Logs are flushed to local disk in batches of 10 via `LogRepository`.
- **UI Breadcrumbs** — `AppNavigatorObserver` is coupled to the router. Every screen change saves a navigation breadcrumb (max 50 records) in `LogContext`. On critical failure, the trail is attached as metadata to the crash report.

---

## 🛠️ Tech Stack

### Frontend
| Technology | Version | Purpose |
|---|---|---|
| **Flutter** | 3.x | Cross-platform UI framework |
| **Dart** | 3.11.4 | Programming language |
| **Riverpod** | ^2.x | Reactive state management |

### Backend & Data
| Technology | Version | Purpose |
|---|---|---|
| **Supabase** | ^2.8.0 | PostgreSQL backend + Auth |
| **SQLite** | ^2.3.0 | Local offline storage |
| **SharedPreferences** | ^2.5.5 | Simple key-value storage |

### AI & Analytics
| Technology | Version | Purpose |
|---|---|---|
| **Google Generative AI** | ^0.4.7 | Gemini AI for sentiment analysis |
| **Crypto** | ^3.0.3 | Cryptographic utilities |
| **Encrypt** | ^5.0.1 | AES-256 journal encryption |

### UI/UX
| Technology | Version | Purpose |
|---|---|---|
| **FL Chart** | ^0.63.0 | Progress visualization charts |
| **Shimmer** | ^3.0.0 | Loading placeholders |
| **Font Awesome Flutter** | ^10.7.0 | Social auth icons |

### Utilities
| Technology | Version | Purpose |
|---|---|---|
| **Logger** | ^2.5.0 | Structured logging |
| **UUID** | ^4.0.0 | Unique identifiers |
| **Share Plus** | ^10.1.4 | Content sharing |
| **Connectivity Plus** | ^6.1.4 | Network status detection |
| **Local Auth** | ^2.1.6 | Biometric authentication |

---

## 🔒 Security & Privacy

- **End-to-End Encryption** — Journal entries encrypted client-side with AES-256 before storage (TODO)
- **Biometric Lock** — Optional fingerprint/face authentication (TODO)
- **Secure API Key Storage** — Gemini API key stored in secure device storage (TODO)
- **Minimal Data Collection** — Only essential data for functionality (TODO)
- **No Third-Party Ads** — Your data is never sold or used for advertising (TODO)

### Crisis Protocol
The app detects language indicating crisis situations (self-harm, extreme despair, suicidal ideation). When detected, the AI responds with empathy and directs users to professional help — never providing medical advice or diagnosis. See [`lib/ethics/crisis_protocol.md`](lib/ethics/crisis_protocol.md) for details.

---

## ⚙️ Getting Started

### Prerequisites
- **Flutter SDK** 3.11.4+ — [Installation Guide](https://flutter.dev/docs/get-started/install)
- **Git**

### Setup

```bash
# 1. Clone
git clone https://github.com/yourusername/alma_diary.git
cd alma_diary

# 2. Install dependencies
flutter pub get

# 3. Configure environment
# Create .env in the project root:
# SUPABASE_URL=https://your-project.supabase.co
# SUPABASE_ANON_KEY=your-anon-key

# 4. Run
flutter run                  # Mobile (connected device)
flutter run -d chrome        # Web
flutter run -d windows       # Desktop
```

---

## ⚠️ Known Technical Debt

> **Note for developers:** In v3.0.0, `AlmaTrajectoryScreen` and `SearchScreen` use a default static passphrase for biometric testing (`passphrase: "alma_biometric_pass"`). There is a prioritized `// TODO` to decouple this key and migrate it to the device secure keychain via native channels before production deployment.

---

## 🗺️ Roadmap

- [ ] Rich text editor with formatting
- [ ] Mood tracking with graphs
- [ ] Export entries (PDF, TXT)
- [ ] Multi-language support (EN / ES)
- [ ] Folders & tags for entries
- [ ] Social sharing (opt-in)
- [ ] Web dashboard
- [ ] Apple Watch / Wear OS companion

---

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
