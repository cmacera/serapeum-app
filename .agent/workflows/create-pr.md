---
description: How to create a Pull Request for the Serapeum APP project
---

# 🚀 Creating a Pull Request for Serapeum APP

This workflow outlines the mandatory steps to prepare and submit a Pull Request (PR) in the Serapeum APP project. Following these steps ensures consistency, avoids CI failures, and maintains high code quality.

## 1. Preparation & Branching

1.  **Select a Ticket:** Identify the task in Linear (Project: Serapeum APP).
2.  **Create a Branch:**
    - Branch names MUST follow the format: `SER-<ID>/<short-description>`.
    - Example: `git checkout -b SER-42/implement-realm-schema`

## 2. Development & Commits

1.  **Atomic Commits:** Make small, logical commits.
2.  **Conventional Commits:** Use the `type(scope): description` format.
    - Example: `feat(library): add movie entity definition`
3.  **No Secrets:** Ensure no API keys or secrets are committed. Use `envied` for obfuscation.
4.  **Formatting:** Code MUST be in English and follow strict typing (avoid `dynamic`).

## 3. Pre-Flight Checks

Before opening a PR, run the following commands locally:

// turbo
```bash
# 1. Update generated code (if models or providers changed)
dart run build_runner build --delete-conflicting-outputs

# 2. Format the code
dart format .

# 3. Static Analysis (Must have 0 warnings)
flutter analyze

# 4. Run Unit & Widget Tests
flutter test
```

## 4. UI Verification

- **Responsive Check:** Verify UI changes on both **Mobile** (touch/small screen) and **macOS** (mouse/hover/large screen) layouts.
- **Navigation:** Ensure new screens are correctly added to `AppRouter` and accessible.

## 5. Submitting the PR

1.  **Push Branch:** Push your changes to the remote repository.
2.  **PR Title:** Must start with `[SER-<ID>]`.
    - Example: `[SER-42] Implement Realm Schema for Library`
3.  **PR Description:**
    - Ensure it includes `Closes SER-<ID>` to link the Linear issue.
    - Use the provided PR template.
4.  **CI Wait:** Wait for the GitHub Actions (CI) to finish. Merging is blocked by failing tests or lint warnings.

## 🛑 Forbidden Actions (For AI Agents)

- NEVER run `git commit` or `git push` without explicit user permission.
- NEVER move Linear tickets automatically.
- NEVER bypass Husky hooks (`--no-verify`).
