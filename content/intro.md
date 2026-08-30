---
title: Overview
sidebar_position: 1
slug: /
---

# Covenant

**Covenant** is a contract management system that records contractual data — parties, clauses, obligations, amendments, and their full history — in a structured, auditable, and searchable way.

This site is a worked example of documentation-as-code for a real-shaped system: a .NET backend, an Angular UI, event sourcing, a search index, a message broker, infrastructure as code, and a CI/CD pipeline. Everything here is fictional, but the shape of the documentation is meant to be reused.

## What Covenant does

- Captures contracts through their full lifecycle: draft, negotiation, execution, active, amended, expired/terminated.
- Stores every change as an immutable event, so the full history of a contract is always reconstructable.
- Indexes contracts for full-text and faceted search across parties, clauses, dates, and status.
- Notifies interested systems (billing, legal review, renewal reminders) as contracts change, via asynchronous events.

## Where to go next

- **[Requirements](/requirements/overview)** — who Covenant is for, and what it must do.
- **[Architecture](/architecture/overview)** — how the system is put together, and how a request flows through it.
- **[Architecture Decision Records](/adr/wolverinefx-http-and-messaging)** — why key technology choices were made.
- **[Operations](/operations/ci-cd)** — how Covenant is built, deployed, and run.

## Core principles

1. Documentation is authored in Markdown, alongside the code it describes.
2. Diagrams are text-based (Mermaid) and versioned like code.
3. The site is generated from the repository, not maintained manually in a CMS.
4. CI/CD ensures the docs can be rebuilt consistently.
