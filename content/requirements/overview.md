---
title: Requirements Overview
sidebar_position: 1
---

# Requirements overview

Covenant exists to give an organization a single, auditable source of truth for its contracts — replacing spreadsheets and shared drives with a system that understands contract structure and history.

## Stakeholders

| Stakeholder | Interest |
|---|---|
| Legal / contract managers | Author, negotiate, and approve contracts; need full history and clause search. |
| Finance | Needs accurate contract value and payment terms for forecasting and audits. |
| Business owners | Track obligations, renewal dates, and SLAs for contracts they own. |
| Auditors | Require an immutable, timestamped record of every change made to a contract. |
| Engineering | Builds and operates the system; needs it to be observable and safely deployable. |

## Functional requirements

- Record contracts with structured metadata: parties, effective/expiry dates, value, currency, clauses, and obligations.
- Support the full contract lifecycle: `Draft → InNegotiation → Executed → Active → Amended → Expired/Terminated`.
- Every state transition and field change is captured as an immutable, append-only event — never an in-place update.
- Full-text and faceted search across all contracts (by party, status, clause type, value range, date range).
- Amendments create a new version linked to the original contract, without losing prior versions.
- Emit domain events (e.g. `ContractExecuted`, `ContractAmended`, `ContractExpiring`) for downstream consumers such as billing and renewal notifications.

### Contract value indexation

Certain contracts escalate in value on each anniversary, indexed to a published price index (e.g. CPI). The adjusted contract value $V_n$ after $n$ indexation periods, given a base value $V_0$ and per-period index delta $\delta_i$, is:

$$
V_n = V_0 \prod_{i=1}^{n} (1 + \delta_i)
$$

For a constant escalation rate $\delta$, this simplifies to the familiar compounding form $V_n = V_0 (1 + \delta)^n$.

## Non-functional requirements

- **Auditability** — the full history of any contract must be reconstructable from stored events alone, with no destructive updates.
- **Availability** — the read path (search, contract lookup) must remain available independently of write-path incidents where possible.
- **Consistency** — writes are strongly consistent per contract (single aggregate); search results are eventually consistent with a bounded, monitored lag.
- **Security & compliance** — contract data is sensitive; access is role-based, and all changes are attributable to a user.
- **Portability** — the system must not depend on AWS-proprietary services, so it can be redeployed to another cloud with infrastructure changes only.

## Out of scope

- E-signature collection (Covenant assumes contracts arrive already executed, or integrates with an external signing provider).
- Payment processing (Covenant emits events for billing systems to act on; it does not move money).
