---
title: Backend Architecture
sidebar_position: 3
---

# Backend architecture

The [Architecture Overview](/architecture/overview) shows Covenant's containers, including the Covenant API as a single box. This page zooms one level further into that box — a C4 [Component](https://c4model.com/) view of what's actually running inside a single Covenant API instance, generated from the same [`workspace.dsl`](https://github.com/sszakal/x86cc.Documentation/blob/main/workspace.dsl) as the Context and Container diagrams.

## Instance architecture (C4 model)

```mermaid
graph LR

  subgraph diagram ["Component View: Covenant - Covenant API"]

    subgraph 2 ["Covenant"]

      subgraph 4 ["Covenant API"]

        5["<div style='font-weight: bold'>Contract Endpoints</div><div style='font-size: 70%; margin-top: 0px'>[Component: WolverineFX.Http]</div><div style='font-size: 80%; margin-top:10px'>WolverineFX.Http endpoints<br />for contract lifecycle<br />operations</div>"]
        6["<div style='font-weight: bold'>Command Handlers</div><div style='font-size: 70%; margin-top: 0px'>[Component: WolverineFX]</div><div style='font-size: 80%; margin-top:10px'>Handles write operations,<br />e.g. ExecuteContractCommand</div>"]
        7["<div style='font-weight: bold'>Query Handlers</div><div style='font-size: 70%; margin-top: 0px'>[Component: WolverineFX]</div><div style='font-size: 80%; margin-top:10px'>Handles contract search and<br />listing queries</div>"]
        8["<div style='font-weight: bold'>Contract Aggregate</div><div style='font-size: 70%; margin-top: 0px'>[Component: Domain model]</div><div style='font-size: 80%; margin-top:10px'>Core domain logic and<br />business rules for the<br />contract lifecycle</div>"]
      end

      10[("<div style='font-weight: bold'>Search index</div><div style='font-size: 70%; margin-top: 0px'>[Container: OpenSearch]</div><div style='font-size: 80%; margin-top:10px'>Read-optimized index for<br />contract search and listing</div>")]
      11["<div style='font-weight: bold'>Message bus</div><div style='font-size: 70%; margin-top: 0px'>[Container: LavinMQ]</div><div style='font-size: 80%; margin-top:10px'>Transports commands and<br />domain events between<br />components</div>"]
      3["<div style='font-weight: bold'>Angular UI</div><div style='font-size: 70%; margin-top: 0px'>[Container: Angular, TypeScript]</div><div style='font-size: 80%; margin-top:10px'>Single-page application used<br />by contract managers</div>"]
      9[("<div style='font-weight: bold'>Event store and projections</div><div style='font-size: 70%; margin-top: 0px'>[Container: Marten, PostgreSQL]</div><div style='font-size: 80%; margin-top:10px'>Stores contract aggregate<br />event streams and read-model<br />projections</div>")]
    end

    3-. "<div>Makes API calls to</div><div style='font-size: 70%'>[HTTPS/JSON]</div>" .->5
    5-. "<div>Routes commands to</div><div style='font-size: 70%'></div>" .->6
    5-. "<div>Routes queries to</div><div style='font-size: 70%'></div>" .->7
    6-. "<div>Invokes</div><div style='font-size: 70%'></div>" .->8
    8-. "<div>Appends events to</div><div style='font-size: 70%'>[Marten client]</div>" .->9
    7-. "<div>Queries</div><div style='font-size: 70%'>[HTTP]</div>" .->10
    6-. "<div>Publishes events via</div><div style='font-size: 70%'>[AMQP]</div>" .->11

  end
```

Requests enter through the WolverineFX.Http **Contract Endpoints**, which route write operations to **Command Handlers** and reads to **Query Handlers** — this is the same command/query split shown in the [Command and event flow](/architecture/overview#command-and-event-flow) sequence diagram, just from the "what code exists" angle rather than "what happens over time." Command handlers invoke the **Contract Aggregate** (the domain model, matching the Domain layer in the [Onion architecture](/architecture/overview#onion-architecture-layers) diagram), which appends events to the event store; query handlers bypass the domain model entirely and read straight from the search index, since queries never need business-rule validation.
