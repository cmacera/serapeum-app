# 🏛️ ARCHITECTURE.md - System Design

## 1. 🧠 Mental Model

**Serapeum** is a Hybrid AI Client built with Flutter. It operates on a **Local-First** philosophy for the library, extended by **Cloud Orchestration** for discovery.

### Conceptual Layers

#### Presentation (UI)
- **Adaptive Shell:** Uses `Scaffold` with logic to switch between `NavigationBar` (Mobile) and `NavigationRail` (Desktop).
- **State:** Managed by **Riverpod**. UI consumes `AsyncValue` streams.
- **Style:** "Cyber-Archaeology" aesthetic (Material 3).
    - **Typography:**
        - **Headings/Titles:** Cinzel.
        - **Body Text:** Inter.

#### Domain (Business Logic)
- Pure Dart classes (Entities).
- Repository Interfaces (Contracts).
- Use Cases (if logic is complex).

#### Data (Infrastructure)
- **Realm:** High-performance local NoSQL database for "My Library".
- **Genkit/API:** HTTP client (Dio/Http) connecting to Serapeum API (Orchestrator).
- **Supabase:** Auth and optional sync.

## 2. 🌊 Key Flows

### A. Discovery (The Oracle)
```mermaid
graph LR
    UserQuery --> DiscoveryProvider
    DiscoveryProvider --> SerapeumAPI[Serapeum API (Genkit)]
    SerapeumAPI --> JSONResponse
    JSONResponse --> UI[UI Rendering (Rich Cards + Feedback)]
    UI --> FeedbackAPI[POST /feedback → Langfuse]
```

### B. Library (My Vault)
```mermaid
graph LR
    UIAction[UI Action (Save)] --> RealmRepo[Realm Repository]
    RealmRepo --> LocalStorage[Local Storage (Disk)]
    LocalStorage --> UIUpdate[UI Update (Reactive Watcher)]
```

### C. Authentication
`Supabase SDK` -> `Auth State Provider` -> `Router Redirect` (Login vs Home).

## 3. 🏗️ Architectural Decisions (ADR Summary)

| Decision | Context | Rationale |
| :--- | :--- | :--- |
| **Riverpod** | State Management | Better testability, compile-time safety, and independence from Flutter tree compared to Provider. |
| **Realm** | Local DB | Faster than SQLite, reactive architecture (live objects), and officially maintained by Atlas (MongoDB). |
| **GoRouter** | Navigation | Declarative routing is essential for handling Deep Links and Desktop navigation states. |
| **Feature-First** | Folder Structure | Scalability. Keeps related code (UI, Logic, Data) together, making it easier to extract modules later. |

## 4. ⚠️ Risks & Technical Debt

- **Desktop Polish:** Flutter macOS requires specific tuning for keyboard shortcuts and window management.
- **Orchestrator Cost:** Heavy usage of the "Discovery" feature depends on API costs (mitigated by Gemini Flash).
- **Realm Generator:** `realm_generator 3.5.0` crashes on new files with nullable fields. New Realm models must be written manually (see `lib/features/library/data/local/library_item.dart` pattern).
- **Observability:** Sentry integrated for crash reporting (SER-35). Langfuse collects AI response quality feedback via `traceId` (SER-97/SER-100).