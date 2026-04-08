# CLAUDE.md — Serapeum App

## Project overview

Flutter multi-platform client (macOS, Android, iOS). **Local-First** library management powered by Realm, extended with **Cloud AI Discovery** via the Serapeum API (Genkit orchestrator).

- **SDK:** Flutter ≥ 3.41.0 · Dart ^3.11.0
- **State:** Riverpod (`StateNotifier` + `@riverpod` annotations)
- **Local DB:** Realm (reactive, offline-first)
- **Auth:** Supabase
- **HTTP:** Dio (with AuthInterceptor for bearer tokens + 401 refresh)

---

## Key commands

```bash
flutter pub get                                        # Install dependencies
flutter run -d macos                                   # Run on macOS desktop
flutter run -d <device_id>                             # Run on mobile emulator
flutter analyze                                        # Lint (must exit 0)
dart format .                                          # Format code
flutter test                                           # Run tests

# Regenerate Realm / Riverpod / JSON code
dart run build_runner build --delete-conflicting-outputs

# Regenerate OpenAPI reference models (requires Java 11+)
./tools/run-codegen.sh
```

---

## Directory structure

```text
lib/
├── core/
│   ├── constants/      # ApiConstants (endpoints, timeouts)
│   ├── enums/          # App-wide enums
│   ├── env/            # Envied secrets (compile-time)
│   ├── localization/   # Locale provider
│   ├── network/        # dio_provider, auth_interceptor, failure.dart
│   ├── realm/          # realm_provider (schema versioning)
│   ├── router/         # GoRouter (AppRouter)
│   ├── theme/          # AppTheme (Cyber-Archaeology, Material 3)
│   └── utils/          # TMDB image helpers, dialogs
├── features/
│   ├── discovery/      # AI Oracle — chat, search, history
│   ├── library/        # Offline media management (Realm)
│   └── settings/       # Auth, model management
├── l10n/               # ARB localisation files
└── shared/
    └── widgets/        # MediaResultCard, CategoryTabBar, etc.

docs/
  openapi.yaml          # OpenAPI spec (synced from serapeum-api via CI)
lib/generated/
  models/               # Reference DTOs from run-codegen.sh (DO NOT import directly)
tools/
  run-codegen.sh        # OpenAPI → Dart reference models
  openapi-config.yaml
  openapi-generator-cli.jar
```

---

## Codegen workflows

### Realm / Riverpod / JSON (`build_runner`)
Run after any `@RealmModel`, `@riverpod`, `@freezed`, or `@JsonSerializable` change:
```bash
dart run build_runner build --delete-conflicting-outputs
```

**⚠️ Realm generator limitation (realm_generator 3.5.0 + analyzer 7.6.0 + SDK 3.11.0):**
The generator crashes on **new** files containing nullable fields.
Workaround: write Realm models manually using `with RealmEntity, RealmObjectBase, RealmObject` — **no** `@RealmModel()`, **no** `part` directive.
See `lib/features/library/data/local/library_item.dart` for the canonical pattern.
Existing `@RealmModel()` files (e.g. `discover_history_item.dart`) continue to work fine.

### OpenAPI reference models
Run after merging a `chore/sync-openapi-*` PR:
```bash
./tools/run-codegen.sh   # outputs to lib/generated/models/ (reference only)
```
Then manually review generated files and update hand-written DTOs in
`lib/features/discovery/data/models/` as needed.

---

## Architecture — key patterns

### API calls (Dio)
- **All API endpoints** (including `/feedback`) are Genkit-managed — wrap payload in `{'data': …}` and expect `{'result': …}`.
- Use the `_post<T>()` helper in `CatalogDiscoverRepository` for endpoints that return a meaningful result.
- For fire-and-forget endpoints (e.g. `/feedback`), call `_dio.post()` directly with `{'data': payload}` and ignore the response body.
- `Failure` sealed class (`NetworkFailure`, `ServerFailure`, `TimeoutFailure`, `UnknownFailure`) for structured error handling.

### Realm schema versioning
Config in `lib/core/realm/realm_provider.dart`. Increment schema version and add a migration block for every model change.

### Feature structure
Each feature follows: `data/` (repos, DTOs, local models, providers) → `domain/` (entities, interfaces) → `presentation/` (screens, widgets, providers).

---

## CI gates (must all pass before merge)

| Check | Command |
|---|---|
| Lint | `flutter analyze` (0 warnings) |
| Format | `dart format .` |
| Tests | `flutter test` |
| PR title | Must match `/^\[DEV-\d+\]/` |

---

## Commit conventions

- Format: `type(scope): description` (Conventional Commits)
- **Never** add `Co-Authored-By: Claude` to commit messages
- `[DEV-XX]` prefix belongs only in the PR/squash-merge title, **not** in local commits

---

## Linear + GitHub workflow

**Linear team:** DEVELOPMENT · **Project:** Serapeum APP · **Identifier prefix:** `DEV`

### Ticket state automation

- **Move to `In Progress` automatically** when starting work on a ticket — no need to ask.
- All other state transitions (`In Review`, `Done`, `Canceled`, etc.) require an explicit request.

### Starting a new feature

1. Create a ticket in Linear (MCP or UI): assign to self, project = Serapeum APP.
2. **Move ticket to `In Progress`** (automatic — no need to ask).
3. Create a branch: `git checkout -b feat/<short-description>` (branch name does NOT need the DEV-XX prefix).
4. Implement, commit with conventional commits (no `[DEV-XX]` prefix — commitlint rejects it).
5. Create the PR: title must start with `[DEV-XX]` or `DEV-XX`. Body should include `Closes DEV-XX`.
6. Move ticket to `In Review` when the PR is open (explicit request required).

### PR title format (enforced by CI)

Both formats accepted:
```text
[DEV-XX] type(scope): description
DEV-XX type(scope): description
```

### Available Linear states

| State | Type | Use when |
|---|---|---|
| Backlog | backlog | Not yet started |
| Todo | unstarted | Ready to pick up |
| In Progress | started | Actively working |
| In Review | started | PR open, awaiting review |
| Done | completed | PR merged |
| Canceled / Duplicate | canceled | — |