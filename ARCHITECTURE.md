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
- **Isar:** High-performance local NoSQL database for "My Library".
- **Genkit/API:** HTTP client (Dio/Http) connecting to Serapeum API (Orchestrator).
- **Supabase:** Auth and optional sync.

## 2. 🌊 Key Flows

### A. Discovery (The Oracle)
```mermaid
graph LR
    UserQuery --> DiscoveryProvider
    DiscoveryProvider --> SerapeumAPI[Serapeum API (Genkit)]
    SerapeumAPI --> JSONResponse
    JSONResponse --> UI[UI Rendering (Rich Cards)]
```

### B. Library (My Vault)
```mermaid
graph LR
    UIAction[UI Action (Save)] --> IsarRepo[Isar Repository]
    IsarRepo --> LocalStorage[Local Storage (Disk)]
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
- **Model Download:** Managing large local LLM downloads in the "Settings" section requires robust background service handling to avoid OS termination.
- **Orchestrator Cost:** Heavy usage of the "Discovery" feature depends on API costs (mitigated by Gemini Flash).