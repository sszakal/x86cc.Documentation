---
title: Frontend Architecture
sidebar_position: 4
---

# Frontend architecture

The Angular UI (see the [Architecture Overview](/architecture/overview)) follows Angular's own Core/Shared/Feature module convention — a similar "dependencies only point one way" rule to the backend's [Onion architecture](/architecture/overview#onion-architecture-layers), just applied to frontend modules instead of backend layers.

```mermaid
flowchart TD
    subgraph Feature["Feature modules"]
        Dashboard["Dashboard module<br/>contract summary views"]
        Contracts["Contracts module<br/>list, detail, execute workflows"]
    end
    subgraph Shared["Shared module"]
        Components["Reusable UI components, pipes, directives"]
    end
    subgraph Core["Core module"]
        Auth["Auth guard &amp; HTTP interceptors"]
        ApiClient["Covenant API client services"]
    end

    Feature --> Shared
    Feature --> Core
    ApiClient -->|HTTPS/JSON| API[Covenant API]
```

Feature modules (`Dashboard`, `Contracts`) depend on `Shared` and `Core`, never on each other — cross-feature navigation goes through the router, not direct imports. `Core` is imported once at the application root and provides singletons every feature needs: the auth guard and HTTP interceptors (attaching auth tokens, handling 401s), and the API client services that are the only thing in the app allowed to call the Covenant API directly. `Shared` holds presentational building blocks (components, pipes, directives) with no knowledge of any specific feature. Each feature module manages its own local view state with Angular signals; there's no cross-feature global store, since Covenant's UI doesn't share view state across features.
