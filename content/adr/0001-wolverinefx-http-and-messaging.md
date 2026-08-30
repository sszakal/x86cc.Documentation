---
title: "ADR 0001: WolverineFX for HTTP endpoints and messaging"
sidebar_position: 1
---

# ADR 0001: Use WolverineFX for HTTP endpoints and messaging

## Status

Accepted

## Context

Covenant needs two things that are usually solved by separate libraries: (1) a way to define HTTP endpoints and route requests to handlers, and (2) an in-process/out-of-process messaging layer to dispatch commands and publish domain events to LavinMQ. The conventional .NET approach combines ASP.NET Core MVC or Minimal APIs with a mediator library (e.g. MediatR) for in-process dispatch, plus a separate client library for the message broker.

## Decision

Use **WolverineFX** for both concerns:

- **WolverineFX.Http** defines HTTP endpoints as plain methods with explicit input/output types, routed by convention, without controllers or a separate MVC pipeline.
- **WolverineFX** itself is the command/query mediator and the messaging layer, with a LavinMQ (AMQP) transport for publishing and consuming domain events.

The same handler method signature style is used whether a message arrives via HTTP, is dispatched in-process, or is delivered asynchronously from LavinMQ.

## Consequences

- Fewer moving parts: no separate mediator library and no separate broker client — one set of conventions covers both request handling and messaging.
- Handlers stay in the Application layer and are unaware of whether they were invoked from an HTTP endpoint or a queued message, which keeps the Onion Architecture boundary clean.
- The team takes on a dependency on a smaller, less widely-adopted library than ASP.NET Core MVC + MediatR; onboarding engineers unfamiliar with WolverineFX have a learning curve.
- Because WolverineFX's messaging abstraction is transport-agnostic, swapping LavinMQ for another AMQP-compatible broker later would not require touching handler code.
