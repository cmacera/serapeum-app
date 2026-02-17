# 🤖 AGENTS.md - Operational Manual

## 1. 🛠️ Toolchain & Commands

### Setup & Installation

```bash
# Install dependencies
flutter pub get

# Generate code (Isar, Riverpod, JSON serialization)
dart run build_runner build --delete-conflicting-outputs
```

### Development

```bash
# Run on macOS (Desktop)
flutter run -d macos

# Run on Mobile Emulator
flutter run -d <device_id>

# Run Linter
flutter analyze

# Run Tests
flutter test
```

### Building for Production

```bash
# Build macOS Bundle
flutter build macos --release

# Build Android APK
flutter build apk --release
```

## 2. 📂 Project Structure & Naming

**Pattern:** Feature-First Architecture.

```text
lib/
├── core/                 # Shared utilities, theme, constants
│   ├── theme/            # AppTheme (Stone & Neon styles)
│   ├── router/           # GoRouter configuration
│   └── utils/            # Helpers
├── features/             # Feature modules
│   ├── discovery/        # Chat & Search Logic
│   ├── library/          # Offline/Local Media Management
│   └── settings/         # Auth, AI Model Management
│       ├── data/         # Repositories, DTOs, Data Sources (Isar/API)
│       ├── domain/       # Entities, Failures, Repository Interfaces
│       └── presentation/ # Widgets, Screens, Riverpod Providers
└── main.dart             # Entry point
```

### Naming Conventions

- **Files:** `snake_case.dart` (e.g., `media_repository.dart`)
- **Classes:** `PascalCase` (e.g., `MediaRepository`)
- **Variables/Functions:** `camelCase` (e.g., `getMediaById`)
- **Providers:** `camelCase` ending in `Provider` (e.g., `movieListProvider`)

## 3. 🔄 Workflow & Git Protocol

### Step 1: Linear & Branching

1.  **Select Ticket:** Pick or create a ticket from Linear (Project: Serapeum APP).
2.  **Create Branch:** Must follow format: `SER-<ID>/<short-description>`
    *   Example: `SER-42/implement-isar-schema`

### Step 2: Coding & Commits

1.  **Atomic Commits:** Focus on one logical change per commit.
2.  **Commit Message:** Adhere to Conventional Commits:
    *   `type(scope): description`
    *   Example: `feat(library): add movie entity definition`

### Step 3: Pull Request (PR) Checklist

- [ ] Title starts with `[SER-<ID>]`.
- [ ] Description includes `Closes SER-<ID>`.
- [ ] `flutter analyze` passes with 0 warnings.
- [ ] `dart run build_runner` has been run and committed (if schemas changed).
- [ ] UI changes have been verified on both Mobile and macOS layouts.

### Definition of Done (DoD)

- Feature works on requested platforms.
- Code is formatted (`dart format .`).
- No hardcoded strings (use localization/constants where applicable).