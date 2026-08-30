---
title: "ADR 0002: Event sourcing on Marten"
sidebar_position: 2
---

# ADR 0002: Event-source the Contract aggregate using Marten

## Status

Accepted

## Context

Auditability is a hard requirement: every change to a contract must be individually attributable and reconstructable, and nothing may be silently overwritten. A conventional CRUD model (update rows in place, optionally with a separate audit-log table kept in sync by hand) makes it easy for the audit trail to drift from the actual data, and doesn't naturally give a "what did this contract look like on date X" view.

## Decision

Model `Contract` as an event-sourced aggregate, using **Marten** as the event store on top of PostgreSQL:

- Every state change is appended as an immutable domain event (`ContractDrafted`, `ContractExecuted`, `ContractAmended`, `ContractExpired`, ...) to a per-contract stream.
- The current state of a contract is a left-fold over its event stream, computed via a Marten projection.
- Marten also produces the write-side read models (e.g. "contracts for party X") used by the API for queries that don't need full-text search; OpenSearch (see [Architecture Overview](/architecture/overview)) handles search-shaped queries from the same events, consumed asynchronously via LavinMQ.

## Consequences

- The audit trail is the data model, not a bolt-on log — there is no way to change a contract without producing an event that records it.
- Historical reconstruction ("what did this contract look like after amendment 2") is a replay of the stream up to that point, not a separate feature to build.
- Marten being a library on top of PostgreSQL (rather than a bespoke event-store product) means the team keeps operating a single relational database (Aurora PostgreSQL in AWS) instead of adding another stateful system to run.
- Read models must be treated as eventually consistent and rebuildable: any projection (including the OpenSearch index) can and must be able to be rebuilt from the event stream from scratch.
- Schema evolution of events (e.g. renaming a field) requires explicit upcasting logic, which is more ceremony than editing a column on a CRUD table.
