# 🏛️ Serapeum App

Serapeum is a Hybrid AI Client built with Flutter, designed with a "Local-First" philosophy for the library and extended by "Cloud Orchestration" for discovery.

> [!NOTE]
> This is part of the **Serapeum Project**, which consists of this Flutter client and the [Serapeum API](https://github.com/cmacera/serapeum-api) orchestrator.

---

## 🛠️ Tech Stack

- **Framework:** [Flutter](https://flutter.dev) (Multi-platform: macOS, Android, iOS)
- **State Management:** [Riverpod](https://riverpod.dev)
- **Local Database:** [Realm](https://realm.io) (Reactive, High-performance)
- **Authentication:** [Supabase](https://supabase.com)
- **API Client:** [Dio](https://pub.dev/packages/dio) & [Retrofit](https://pub.dev/packages/retrofit)

## 🌐 Backend Integration

This application consumes the **[Serapeum API](https://github.com/cmacera/serapeum-api)**, a Genkit-based orchestrator that handles:
- AI Discovery (The Oracle)
- Cloud Synchronization
- Distributed Knowledge Management

## 📚 Documentation

Detailed guides and specifications:
- **[ARCHITECTURE.md](ARCHITECTURE.md):** System design, conceptual layers, and database schemas.
- **[AGENTS.md](AGENTS.md):** Toolchain, git workflow, and operational manual for contributors/agents.
- **[RULES.md](RULES.md):** Behavioral guidelines and development constraints.

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>= 3.38.0)
- Dart SDK (^3.11.0)

### Setup
1. Clone the repository.
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. **Wire Husky hooks (Mandatory for first-time setup):**
   ```bash
   dart run husky install
   ```
4. Generate required code (Realm/Riverpod):
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```
5. Run the application:
   ```bash
   flutter run
   ```

## 🛡️ Developer Experience

We use **Husky** for local checks and **GitHub Actions** for remote CI.

### Local Quality (Husky)
Every commit triggers:
1. `dart format` (Formatting check)
2. `flutter analyze` (Linter validation)

### Remote Quality (CI)
Our [GitHub Actions workflow](.github/workflows/ci.yml) runs on every PR:
- **Analyze:** Linting and formatting validation.
- **Test:** Unit and widget test execution.
- **Build Check:** Verifies macOS build success.

### Troubleshooting Hooks
If hooks are not running or you are adding them manually:
- **Add new hooks:** `dart run husky add .husky/pre-commit "command"`
- **Hook wiring:** If `.husky/_/husky.sh` is missing, ensure you have run `dart run husky install`.
