---
title: Architecture Overview
sidebar_position: 1
---

# Architecture overview

Covenant follows **Clean (Onion) Architecture**: business rules live at the center, with infrastructure concerns — HTTP, persistence, search, messaging — pushed to the outer edges and swapped in through interfaces defined by the core.

## System context

```mermaid
flowchart LR
    User[Contract Manager] -->|HTTPS| UI[Angular UI]
    UI -->|HTTPS / JSON| API[Covenant API<br/>WolverineFX.Http]
    API -->|read/write| DB[(PostgreSQL / Marten)]
    API -->|index & query| Search[(OpenSearch)]
    API -->|publish| MQ[[LavinMQ]]
    MQ -->|consume| API
    MQ -->|events| Downstream[Billing / Renewal notifier]
```

## System context (C4 model)

The diagram above gives the shape of the system at a glance; the same boundary redrawn in the [C4 model](https://c4model.com/) below adds explicit actor/system descriptions and named relationships, useful for onboarding material or architecture reviews that expect C4 notation. This diagram is generated from [`workspace.dsl`](https://github.com/your-org/x86cc.Documentation/blob/main/workspace.dsl) (a [Structurizr](https://structurizr.com/) C4 model) via `structurizr export -f mermaid`, not hand-written.

```mermaid
graph LR

  subgraph diagram ["System Context View: Covenant"]

    1["<div style='font-weight: bold'>Contract Manager</div><div style='font-size: 70%; margin-top: 0px'>[Person]</div><div style='font-size: 80%; margin-top:10px'>A user of Covenant who<br />manages contract lifecycle<br />events</div>"]
    2["<div style='font-weight: bold'>Covenant</div><div style='font-size: 70%; margin-top: 0px'>[Software System]</div><div style='font-size: 80%; margin-top:10px'>Lets a contract manager<br />create, execute, and search<br />contracts</div>"]
    8["<div style='font-weight: bold'>Billing System</div><div style='font-size: 70%; margin-top: 0px'>[Software System]</div><div style='font-size: 80%; margin-top:10px'>Consumes contract lifecycle<br />events to trigger billing and<br />renewal workflows</div>"]

    2-. "<div>Publishes contract lifecycle<br />events to</div><div style='font-size: 70%'>[AMQP]</div>" .->8
    1-. "<div>Manages contracts using</div><div style='font-size: 70%'>[HTTPS]</div>" .->2

  end
```

## Containers (C4 model)

Zooming one level into the Covenant boundary shows the same deployable units introduced in the onion architecture diagram below, but from a runtime/technology perspective rather than a dependency-direction one. Also generated from `workspace.dsl` via `structurizr export -f mermaid`.

```mermaid
graph LR

  subgraph diagram ["Container View: Covenant"]

    1["<div style='font-weight: bold'>Contract Manager</div><div style='font-size: 70%; margin-top: 0px'>[Person]</div><div style='font-size: 80%; margin-top:10px'>A user of Covenant who<br />manages contract lifecycle<br />events</div>"]
    8["<div style='font-weight: bold'>Billing System</div><div style='font-size: 70%; margin-top: 0px'>[Software System]</div><div style='font-size: 80%; margin-top:10px'>Consumes contract lifecycle<br />events to trigger billing and<br />renewal workflows</div>"]

    subgraph 2 ["Covenant"]

      3["<div style='font-weight: bold'>Angular UI</div><div style='font-size: 70%; margin-top: 0px'>[Container: Angular, TypeScript]</div><div style='font-size: 80%; margin-top:10px'>Single-page application used<br />by contract managers</div>"]
      4["<div style='font-weight: bold'>Covenant API</div><div style='font-size: 70%; margin-top: 0px'>[Container: WolverineFX.Http, .NET]</div><div style='font-size: 80%; margin-top:10px'>Exposes contract management<br />operations over HTTPS/JSON</div>"]
      5[("<div style='font-weight: bold'>Event store and projections</div><div style='font-size: 70%; margin-top: 0px'>[Container: Marten, PostgreSQL]</div><div style='font-size: 80%; margin-top:10px'>Stores contract aggregate<br />event streams and read-model<br />projections</div>")]
      6[("<div style='font-weight: bold'>Search index</div><div style='font-size: 70%; margin-top: 0px'>[Container: OpenSearch]</div><div style='font-size: 80%; margin-top:10px'>Read-optimized index for<br />contract search and listing</div>")]
      7["<div style='font-weight: bold'>Message bus</div><div style='font-size: 70%; margin-top: 0px'>[Container: LavinMQ]</div><div style='font-size: 80%; margin-top:10px'>Transports commands and<br />domain events between<br />components</div>"]
    end

    1-. "<div>Uses</div><div style='font-size: 70%'>[HTTPS]</div>" .->3
    3-. "<div>Makes API calls to</div><div style='font-size: 70%'>[HTTPS/JSON]</div>" .->4
    4-. "<div>Reads from and appends events<br />to</div><div style='font-size: 70%'>[Marten client]</div>" .->5
    4-. "<div>Indexes and queries</div><div style='font-size: 70%'>[HTTP]</div>" .->6
    4-. "<div>Publishes and consumes events<br />via</div><div style='font-size: 70%'>[AMQP]</div>" .->7
    7-. "<div>Delivers contract lifecycle<br />events to</div><div style='font-size: 70%'>[AMQP]</div>" .->8

  end
```

## Onion architecture layers

```mermaid
flowchart TD
    subgraph Domain["Domain (core)"]
        Entities["Contract aggregate, value objects, domain events"]
    end
    subgraph Application["Application"]
        Handlers["Command & query handlers, WolverineFX message handlers"]
    end
    subgraph Infrastructure["Infrastructure"]
        Marten["Marten (Postgres): event store + document projections"]
        OS["OpenSearch: read-optimized search index"]
        Bus["LavinMQ transport"]
    end
    subgraph Presentation["Presentation"]
        Http["WolverineFX.Http endpoints"]
    end

    Presentation --> Application
    Application --> Domain
    Infrastructure --> Application
```

Dependencies only point inward: the Domain layer has no reference to Marten, OpenSearch, or LavinMQ — those are implemented as infrastructure adapters against interfaces the Application layer defines. WolverineFX endpoints in the Presentation layer translate HTTP requests into commands and dispatch them through the message bus; they contain no business logic.

## Command and event flow

A contract execution, from HTTP request to search index update:

```mermaid
sequenceDiagram
    participant UI as Angular UI
    participant Http as WolverineFX.Http endpoint
    participant Handler as ExecuteContractHandler
    participant Marten as Marten (Postgres)
    participant MQ as LavinMQ
    participant Projector as Search projection handler
    participant OS as OpenSearch

    UI->>Http: POST /contracts/{id}/execute
    Http->>Handler: ExecuteContractCommand
    Handler->>Marten: append ContractExecuted event
    Marten-->>Handler: event stream persisted
    Handler->>MQ: publish ContractExecuted
    Http-->>UI: 202 Accepted
    MQ->>Projector: deliver ContractExecuted
    Projector->>OS: upsert contract document
```

The write path (command → event → append) is synchronous and transactional within Marten. Search indexing is asynchronous: the API returns as soon as the event is durably stored, and OpenSearch catches up via the event handler consuming from LavinMQ. This keeps the write path fast and decouples it from search availability.

## Deployment

Locally, [.NET Aspire](https://learn.microsoft.com/dotnet/aspire/) orchestrates the API, Postgres, OpenSearch, and LavinMQ containers with one `dotnet run` — no manual `docker compose` bookkeeping.

In production, the same containers run on Kubernetes rather than a proprietary PaaS, so the stack is portable across clouds. On AWS specifically:

```mermaid
flowchart TB
    subgraph AWS["AWS Account"]
        subgraph K8s["Kubernetes cluster (EKS)"]
            API["Covenant API pods<br/>(WolverineFX.Http)"]
            UIpod["Angular UI<br/>(static, served via nginx/CDN)"]
            LavinMQpod["LavinMQ (StatefulSet)"]
        end
        Aurora[("Aurora PostgreSQL<br/>(Marten storage)")]
        OSService[("Amazon OpenSearch Service")]
    end

    Client((Browser)) --> UIpod
    UIpod --> API
    API --> Aurora
    API --> OSService
    API --> LavinMQpod
```

Only Postgres and OpenSearch are consumed as managed AWS services (Aurora, Amazon OpenSearch Service); the API, UI, and LavinMQ run as ordinary Kubernetes workloads. Because none of the application code depends on an AWS-specific SDK or service, the same Kubernetes manifests could target another cloud's managed Postgres/OpenSearch-compatible offerings with infrastructure changes only — see [Tech Stack](/architecture/tech-stack) for the full inventory.
