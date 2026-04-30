# Alma Diary

> **A mindful journaling companion powered by AI**

Alma Diary is a sophisticated mobile application designed to help users process emotions, gain self-insight, and track personal growth through AI-powered journaling and reflection. The app analyzes journal entries using Google's Gemini AI to identify emotional patterns, psychological archetypes, and provide personalized insights for self-improvement.

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-3.11.4-blue?logo=dart" alt="Dart" />
  <img src="https://img.shields.io/badge/Supabase-Backend-green?logo=supabase" alt="Supabase" />
  <img src="https://img.shields.io/badge/Gemini-AI-orange?logo=google" alt="Gemini AI" />
</p>

---

## 📱 Screenshots

| Dashboard | Journal Entry | Reflections |
|-----------|---------------|-------------|
| *(coming soon)* | *(coming soon)* | *(coming soon)* |

---

## 🌟 Features

### Core Journaling
- **Daily Journal Entries**: Text-based reflections with rich text support
- **AI-Powered Sentiment Analysis**: Real-time emotional analysis using Google Gemini
- **Archetype Identification**: Automatic categorization into psychological archetypes (The Mask, The Mirror, The Moon, The Shadow)
- **Personalized Reflections**: AI-generated insights based on your unique emotional patterns

### AI-Driven Insights
- **Daily Quotes**: Curated quotes tailored to your psychological profile
- **Challenges System**: Self-improvement challenges personalized to your needs
- **Progress Tracking**: Visualize your emotional journey with charts and statistics
- **Reading Recommendations**: Personalized content based on your archetype and pain points

### User Experience
- **Biometric Authentication**: Optional fingerprint/face unlock for secure access
- **End-to-End Encryption**: All journal entries encrypted with AES-256
- **Offline Support**: Local database with automatic cloud sync when online
- **Dark Mode**: Automatic theme switching based on system preference
- **Multi-Platform**: Works on iOS, Android, and Web

### Notifications & Engagement
- **Smart Notifications**: AI-generated insights delivered at optimal times
- **Daily Reminders**: Gentle nudges to maintain journaling habit
- **Progress Badges**: Celebrate milestones and achievements

---

## 🏗️ Architecture

Alma Diary follows a clean, layered architecture with strict separation of concerns:

```
📦 lib/
├── main.dart                    # App entry point & bootstrap
├── auth/                        # Authentication core
│   ├── alma_auth.dart           # Auth orchestration
│   └── alma_auth_session.dart   # Session management
├── ai/                          # AI/ML module
│   ├── analysis/                # Gemini AI sentiment analysis
│   ├── engines/                 # Notification, challenge, quote engines
│   └── prompt/                  # System prompts for LLM
├── core/                        # Shared infrastructure
│   ├── config/                  # Environment configuration
│   ├── error/                   # Error handling & reporting
│   ├── logging/                 # Comprehensive logging system
│   ├── navigation/              # Route observers & analytics
│   ├── session/                 # Auth session service
│   └── theme/                   # Dynamic theme management
├── data/                        # Persistence layer
│   ├── alma_db.dart             # SQLite database implementation
│   └── schema.dart              # Database schema definitions
├── ethics/                      # Ethical guidelines
│   └── crisis_protocol.md       # Crisis detection & response
├── features/                    # Feature modules (Clean Architecture)
│   ├── auth/                    # Login, signup, onboarding
│   ├── dashboard/               # Home screen & navigation hub
│   ├── journal/                 # Journal entry creation & editing
│   ├── notifications/           # Notification center
│   ├── onboarding/              # First-time user flow
│   ├── profile/                 # User settings & preferences
│   ├── reflections/             # Past entries & insights
│   ├── readings/                # Personalized content
│   ├── search/                  # Entry search functionality
│   └── debug/                   # Debug tools (log viewer)
├── models/                      # Data models & DTOs
└── services/                    # Service layer
    ├── supabase_service.dart    # Backend wrapper
    ├── encryption_service.dart  # Crypto utilities
    ├── storage_service.dart     # File system abstraction
    ├── ai_service.dart          # AI service wrapper
    └── notification_seeder.dart # Notification initialization
```

### Design Patterns
- **Controller Pattern**: Feature controllers manage state and business logic
- **Repository Pattern**: Data access abstracted through repositories
- **Singleton Services**: Core services instantiated once at app bootstrap
- **Dependency Injection**: Constructor injection for testability
- **Observer Pattern**: Stream-based auth state monitoring

---

## 🛠️ Tech Stack

### Frontend
| Technology | Version | Purpose |
|------------|---------|---------|
| **Flutter** | 3.x | Cross-platform UI framework |
| **Dart** | 3.11.4 | Programming language |

### Backend & Data
| Technology | Version | Purpose |
|------------|---------|---------|
| **Supabase** | ^2.8.0 | PostgreSQL backend + Auth |
| **SQLite** | ^2.3.0 | Local offline storage |
| **SharedPreferences** | ^2.5.5 | Simple key-value storage |

### AI & Analytics
| Technology | Version | Purpose |
|------------|---------|---------|
| **Google Generative AI** | ^0.4.7 | Gemini AI for sentiment analysis |
| **Crypto** | ^3.0.3 | Cryptographic utilities |
| **Encrypt** | ^5.0.1 | AES encryption for journal entries |

### UI/UX
| Technology | Version | Purpose |
|------------|---------|---------|
| **FL Chart** | ^0.63.0 | Progress visualization charts |
| **Shimmer** | ^3.0.0 | Loading placeholders |
| **URL Launcher** | any | External links |

### Utilities
| Technology | Version | Purpose |
|------------|---------|---------|
| **Logger** | ^2.5.0 | Structured logging |
| **UUID** | ^4.0.0 | Unique identifiers |
| **Share Plus** | ^10.1.4 | Content sharing |
| **Connectivity Plus** | ^6.1.4 | Network status detection |
| **Local Auth** | ^2.1.6 | Biometric authentication |

---

## 🔒 Security & Privacy

Alma Diary handles sensitive personal information with utmost care:

- **End-to-End Encryption**: Journal entries encrypted client-side using AES-256 before storage
- **Biometric Lock**: Optional fingerprint/face authentication for app access
- **Secure API Key Storage**: Gemini API key stored securely in device storage
- **Minimal Data Collection**: Only essential data needed for functionality
- **No Third-Party Ads**: Your data is never sold or used for advertising

### Crisis Protocol
The app includes ethical safeguards to detect language indicating crisis situations (self-harm, extreme despair, suicidal ideation). When detected, the AI responds with empathy and encourages seeking professional help, never providing medical advice or diagnosis. See [ethics/crisis_protocol.md](lib/ethics/crisis_protocol.md) for details.

---

## 🚀 Getting Started

### Prerequisites
- **Flutter SDK**: 3.11.4 or higher ([Installation Guide](https://flutter.dev/docs/get-started/install))
- **Dart SDK**: Included with Flutter
- **Git**: For version control

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/alma_diary.git
   cd alma_diary
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure environment**
   - Create a `.env` file based on `.env.example` (if available)
   - Add your Supabase credentials
   - Add your Google Gemini API key

4. **Run the app**
   ```bash
   # For mobile development
   flutter run

   # For web development
   flutter run -d chrome

   # For desktop (Windows/macOS/Linux)
   flutter run -d windows
   ```

### Development Tips
- Use `flutter analyze` to check for code issues
- Run `flutter test` for unit tests
- Use `flutter build apk` or `flutter build ios` for production builds

---

## 📁 Project Structure Overview

### Key Files
- `lib/main.dart` - Application entry point, service bootstrap
- `lib/features/auth/auth_gate.dart` - Authentication gate (login/signup vs home)
- `lib/features/journal/alma_journal.dart` - Journal entry screen
- `lib/features/dashboard/dashboard_home.dart` - Main dashboard grid
- `lib/ai/engines/notifications_engine.dart` - AI notification orchestration
- `lib/services/supabase_service.dart` - Supabase backend wrapper
- `lib/data/alma_db.dart` - Local SQLite database

### State Management
The app uses a combination of:
- **ValueListenableBuilder** for theme and simple reactive state
- **Controller pattern** (ProfileController, AuthController) for feature state
- **StreamBuilder** for auth state monitoring
- **Local StatefulWidget** for UI-specific state

---

## 🤝 Contributing

We welcome contributions! Please follow these guidelines:

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/amazing-feature`
3. **Make your changes** with proper tests
4. **Ensure code quality**: `flutter analyze` passes with no errors
5. **Commit your changes**: `git commit -m 'Add amazing feature'`
6. **Push to the branch**: `git push origin feature/amazing-feature`
7. **Open a Pull Request**

### Code Style
- Follow [Effective Dart](https://dart.dev/effective-dart) guidelines
- Use `flutter format` to format code before committing
- Write meaningful commit messages (conventional commits preferred)

---

## 🐛 Known Issues & Roadmap

### Current Status
- **Version**: 1.0.0+1
- **Status**: Active development

### Upcoming Features
- [ ] Rich text editor with formatting
- [ ] Mood tracking with graphs
- [ ] Export journal entries (PDF, TXT)
- [ ] Multi-language support (English, Spanish)
- [ ] Folders/tags for organizing entries
- [ ] Social sharing (opt-in)
- [ ] Web dashboard
- [ ] Apple Watch / Wear OS companion app

See [TODO.md](TODO.md) for detailed task list.

---

## 📄 License

This project is currently **private**. Licensing information will be added when the project is ready for public release.

---

## 🙏 Acknowledgments

- **Google Flutter Team** - Amazing cross-platform framework
- **Supabase** - Backend-as-a-Service that just works
- **Google DeepMind** - Gemini AI powering the insights
- **Mental Health Community** - For feedback on ethical considerations

---

## 📞 Contact & Support

- **Project Maintainer**: [Ellannd]
- **Issues**: [GitHub Issues](https://github.com/Ellannd/alma_diary/issues)

---

> **Disclaimer**: Alma Diary is a self-reflection tool and not a substitute for professional mental health care. If you're experiencing a crisis, please contact a licensed mental health professional or emergency services immediately.
