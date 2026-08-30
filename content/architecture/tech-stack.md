---
title: Tech Stack
sidebar_position: 2
---

# Tech stack

| Concern | Choice | Notes |
|---|---|---|
| Backend language/runtime | .NET | Latest LTS runtime for the API and workers. |
| HTTP endpoints & mediator | [WolverineFX](https://wolverinefx.net) + WolverineFX.Http | Command/query dispatch and HTTP endpoint routing without a separate MVC/MediatR layer. |
| Messaging | WolverineFX message handlers over LavinMQ | Same library handles in-process command dispatch and out-of-process pub/sub over the broker. |
| Message broker | [LavinMQ](https://lavinmq.com) | AMQP 0-9-1 compatible broker; runs as a normal container/StatefulSet, no cloud-managed equivalent required. |
| Write model / event store | [Marten](https://martendb.io) on PostgreSQL | Contract aggregates are event-sourced; Marten also serves as the document store for read-side projections that don't need full-text search. |
| Search / read model | OpenSearch | Denormalized contract documents, updated asynchronously from domain events, power full-text and faceted search. |
| Relational storage | PostgreSQL (Aurora PostgreSQL in AWS) | Backs Marten's event store and document storage. |
| UI | Angular (latest) | Single-page app consuming the WolverineFX.Http JSON API. |
| Local orchestration | .NET Aspire | Runs API, Postgres, OpenSearch, and LavinMQ together locally with service discovery and a dashboard, no manual Docker Compose. |
| Container orchestration | Kubernetes | Chosen over a proprietary PaaS specifically to stay cloud-agnostic. |
| Cloud provider | AWS | EKS for Kubernetes, Aurora PostgreSQL, Amazon OpenSearch Service — the only two AWS-managed dependencies. |
| Infrastructure as code | Terraform | Provisions the EKS cluster, Aurora, OpenSearch domain, networking, and IAM. |
| CI/CD | GitHub Actions | Build, test, containerize, `terraform plan/apply`, and deploy to Kubernetes. |

## Architectural style

Covenant is structured as **Clean (Onion) Architecture**:

- **Domain** — the `Contract` aggregate, value objects, and domain events. No framework or infrastructure references.
- **Application** — command/query handlers (WolverineFX handlers), orchestrating domain logic and depending only on interfaces (`IContractRepository`, `ISearchIndexer`, etc.).
- **Infrastructure** — Marten-based repository implementations, the OpenSearch indexer, and the LavinMQ transport, all implementing Application-layer interfaces.
- **Presentation** — WolverineFX.Http endpoint definitions that map HTTP requests to commands/queries; no business logic lives here.

See [Architecture Overview](/architecture/overview) for how these layers interact end to end, and [ADR 0001](/adr/wolverinefx-http-and-messaging) / [ADR 0002](/adr/event-sourcing-with-marten) for the reasoning behind the WolverineFX and Marten choices.
