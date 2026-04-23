# 🏛️ Serapeum App

[![CI](https://github.com/cmacera/serapeum-app/actions/workflows/ci.yml/badge.svg)](https://github.com/cmacera/serapeum-app/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/release/cmacera/serapeum-app)](https://github.com/cmacera/serapeum-app/releases/latest)

Serapeum is a Hybrid AI Client built with Flutter, designed with a **Local-First** philosophy for the library and extended by **Cloud Orchestration** for AI-powered discovery.

> [!NOTE]
> This is part of the **Serapeum Project**, which consists of this Flutter client and the [Serapeum API](https://github.com/cmacera/serapeum-api) orchestrator.

---

## ✨ Features

### 🔮 The Oracle — AI Discovery
Ask in natural language. The Oracle searches books, movies, TV shows, and video games in parallel using Google Books, TMDB, and IGDB, then synthesizes a rich response via Gemini and Genkit.

### 📚 My Vault — Local Library
A fast, offline-first personal library powered by Realm. Add, organize, and browse your collection without any internet connection. Fully reactive — changes reflect instantly.

### ☁️ Cloud Backup & Restore
Securely back up and restore your local Vault to Supabase Storage. Your data stays private and is always recoverable.

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| Framework | [Flutter](https://flutter.dev) (macOS, Android, iOS) |
| State Management | [Riverpod](https://riverpod.dev) |
| Local Database | [Realm](https://realm.io) (reactive, offline-first) |
| Authentication | [Supabase](https://supabase.com) |
| API Client | [Dio](https://pub.dev/packages/dio) |
| Navigation | [GoRouter](https://pub.dev/packages/go_router) |
| Error Tracking | [Sentry](https://sentry.io) |

---

## 🌐 Backend Integration

This application consumes the **[Serapeum API](https://github.com/cmacera/serapeum-api)**, a Genkit-based orchestrator that handles:
- AI Discovery (The Oracle) — LLM + Genkit flows
- External catalog integration — TMDB, Google Books, IGDB, Tavily
- Cloud Synchronization — Supabase Storage

---

## 📥 Download

| Platform | Link | Notes |
|---|---|---|
| Android | [app-release.apk](https://github.com/cmacera/serapeum-app/releases/latest) | Enable "Install from unknown sources" |
| macOS | [Serapeum.dmg](https://github.com/cmacera/serapeum-app/releases/latest) | Right-click → Open to bypass Gatekeeper |
| iOS | — | Coming soon |

---

## 📚 Documentation

Detailed guides and specifications:
- **[ARCHITECTURE.md](ARCHITECTURE.md):** System design, conceptual layers, and data flows.
- **[AGENTS.md](AGENTS.md):** Toolchain, git workflow, and operational manual for contributors/agents.
- **[RULES.md](RULES.md):** Behavioral guidelines and development constraints.

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>= 3.41.0)
- Dart SDK (^3.11.0)

### Setup
1. Clone the repository.
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. **Wire Husky hooks (mandatory for first-time setup):**
   ```bash
   dart run husky install
   ```
4. Copy environment template and fill in values:
   ```bash
   cp .env.example .env
   ```
5. Generate required code (Realm/Riverpod):
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```
6. Run the application:
   ```bash
   flutter run -d macos   # macOS desktop
   flutter run            # connected device
   ```

---

## 🛡️ Developer Experience

We use **Husky** for local checks and **GitHub Actions** for remote CI.

### Local Quality (Husky)
Every commit triggers:
1. `dart format` (formatting check)
2. `flutter analyze` (linter validation)

### Remote Quality (CI)
Our [GitHub Actions workflow](.github/workflows/ci.yml) runs on every PR:
- **Analyze:** Linting and formatting validation.
- **Test:** Unit and widget test execution.
- **Build Check:** Verifies macOS build success.

### Troubleshooting Hooks
If hooks are not running or you are adding them manually:
- **Add new hooks:** `dart run husky add .husky/pre-commit "command"`
- **Hook wiring:** If `.husky/_/husky.sh` is missing, ensure you have run `dart run husky install`.
