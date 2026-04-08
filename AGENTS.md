# 🤖 AGENTS.md - Operational Manual

## 1. 🛠️ Toolchain & Commands

### Setup & Installation

```bash
# Install dependencies
flutter pub get

# Wire Husky hooks (required for pre-commit automation)
dart run husky install

# Generate code (Realm, Riverpod, JSON serialization)
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

### OpenAPI schema sync (after merging a `chore/sync-openapi-*` PR)

```bash
# 1. Pull latest main
git pull origin main

# 2. Regenerate reference models (requires Java 11+)
./tools/run-codegen.sh

# 3. Review lib/generated/models/ and update hand-written DTOs if needed
# 4. Re-run build_runner
dart run build_runner build --delete-conflicting-outputs

# 5. Verify
flutter analyze
```

### Building for Production

```bash
# Build macOS Bundle
flutter build macos --release

# Build Android APK
flutter build apk --release
```

### Realm models — generator limitation

`realm_generator 3.5.0` + `analyzer 7.6.0` + SDK 3.11.0 crashes on **new** files with nullable fields.

- **Existing** `@RealmModel()` files: keep as-is, build_runner works fine.
- **New** Realm models: write manually using `with RealmEntity, RealmObjectBase, RealmObject` — **no** `@RealmModel()`, **no** `part` directive.
- Reference: `lib/features/library/data/local/library_item.dart`.

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
│       ├── data/         # Repositories, DTOs, Data Sources (Realm/API)
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
2.  **Create Branch:** Must follow format: `DEV-<ID>/<short-description>`
    *   Example: `DEV-42/implement-realm-schema`

### Step 2: Coding & Commits

1.  **Atomic Commits:** Focus on one logical change per commit.
2.  **Commit Message:** Adhere to Conventional Commits:
    *   `type(scope): description`
    *   Example: `feat(library): add movie entity definition`

### Step 3: Pull Request (PR) Checklist

When creating a PR, a **template** will be automatically applied. Ensure you:
- [ ] Title starts with `[DEV-<ID>]`.
- [ ] Description includes `Closes DEV-<ID>`.
- [ ] `flutter analyze` passes with 0 warnings.
- [ ] `dart run build_runner` has been run and committed (if schemas changed).
- [ ] UI changes have been verified on both Mobile and macOS layouts.

### Step 4: Continuous Integration (CI)

Our GitHub CI will automatically run analysis, tests, and a build check. Merging is blocked if:
- Lint errors or warnings are found.
- Code is not properly formatted.
- Tests fail.

### Troubleshooting Hooks

- **Missing Scripts:** If you see errors about `husky.sh` not found, run `dart run husky install`.
- **Bypassing:** Bypassing hooks (`--no-verify`) is strictly regulated; check project guidelines before doing so. 

### Definition of Done (DoD)

- Feature works on requested platforms.
- Code is formatted (`dart format .`).
- No hardcoded strings (use localization/constants where applicable).