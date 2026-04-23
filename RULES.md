# ⚖️ RULES.md - Behavioral Guidelines

## 1. 🛡️ The "Always" Rules (Non-Negotiable)

### Security & Privacy

- **No Secrets:** Never commit API Keys, Supabase Service Roles, or Genkit secrets to the client code. Use `envied` to securely obfuscate secrets at compile-time.
- **Data Privacy:** User notes and ratings stored in Realm remain local-first. Do not sync sensitive user data to the cloud without explicit consent.

### Quality & Standards

- **Language:** All code, comments, and docs must be in English.
- **Type Safety:** `dynamic` is forbidden unless strictly necessary for external libraries. Use strict typing.
- **Async Safety:** Always handle `Future` errors (`try/catch`) or use Riverpod's `AsyncValue` to manage loading/error states in UI.
- **Linting:** Zero tolerance for linter warnings.

### Accessibility (a11y) & UX

- **Responsiveness:** UI must adapt to pointer types (Touch for Mobile, Mouse/Hover for macOS).

## 2. 🚦 The "When" Rules (Triggers)

> **IF** you modify a Data Model (`@RealmModel` or `@freezed`):
> **THEN** you MUST run `dart run build_runner build` immediately.
>
> **IF** you add a new screen:
> **THEN** you MUST define it in the `AppRouter` and test navigation on both mobile bottom bar and desktop rail.
>
> **IF** you implement an AI feature:
> **THEN** provide a fallback UI in case the model is offline or the API fails.

## 3. 🚫 IRONCLAD LIMITS (AI Agent Boundaries)

The AI Assistant is a tool, not the architect. It is **forbidden** from doing the following without explicit user command:

### 🛑 Git & Version Control

- **NO Auto-Commits:** You are forbidden from running `git commit`. You may only stage files (`git add`) to prepare them.
- **NO Auto-Push:** You are forbidden from running `git push`.
- **NO Branch Switching:** Do not change branches unless instructed to start a new task.

### 🛑 Linear & Project Management

- **In Progress (automatic):** Move the active ticket to `In Progress` when work begins — no need to ask.
- **All other transitions require explicit instruction:** Do not move tickets to `In Review`, `Done`, or `Canceled` automatically.
- **NO Project Confusion:** Never touch tickets belonging to "Serapeum API".
- **NO Auto-Assignment:** Do not assign tickets to users unless asked.

### 🛑 Architecture

- **Dependency Lockdown:** Do not add new packages to `pubspec.yaml` without asking.
- **File Deletion:** Do not delete business logic files without confirmation.
- **Massive Refactors:** Do not rewrite core architectural layers (e.g., swapping Riverpod for Bloc) without a dedicated ticket.