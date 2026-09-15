# 04 — IAMINA CAPSULE ARCHITECTURE

Status: DRAFT FOR REVIEW
Date: 2026-09-15

## GOAL

Define the architectural contract between the reusable IAmina Core (the machine) and the OCD capsule (the client-specific vertical) before implementation begins.

The central rule is strict:

> **No OCD-specific domain logic may leak into the generic IAmina Core.**

## Product model

IAmina is the reusable platform/runtime.

The OCD product is a separate client/vertical running on that machine.

Different IAmina clients may have different:

- brands;
- users;
- datasets;
- business models;
- safety policies;
- domain tools;
- user interfaces;
- prompts and evaluations.

A client must not be able to see or depend on another client's private domain state.

## IAmina Core responsibilities

The generic Core may provide reusable primitives such as:

- authentication interfaces;
- generic identity/session handling;
- generic conversation runtime;
- model/provider abstraction;
- generic tool invocation framework;
- generic memory primitives;
- notifications infrastructure;
- generic observability;
- feature flags/configuration primitives;
- billing/usage primitives if later approved;
- localization infrastructure;
- generic safety hooks;
- generic storage interfaces;
- generic evaluation harness infrastructure.

Core code must not understand OCD concepts such as reassurance seeking, ERP hierarchy or compulsions.

## OCD capsule responsibilities

The OCD capsule owns all OCD-specific behavior, including:

- OCD terminology/domain model;
- reassurance-seeking detection;
- checking/rumination/repetition policies;
- Compulsion Firewall behavior;
- ERP-specific logic and content;
- OCD-specific prompts/system policies;
- OCD safety rules;
- OCD-specific tools;
- OCD-specific journal schema/extensions;
- OCD progress definitions;
- OCD-specific UI components/screens where appropriate;
- OCD evaluation datasets and thresholds;
- OCD evidence/source registry;
- crisis/escalation integration rules specific to this product;
- clinician-reviewed content when introduced.

## Capsule contract

The capsule should interact with the Core through explicit interfaces rather than importing Core internals.

Target conceptual contract:

```text
IAmina Core
  │
  ├── Identity
  ├── Generic Memory API
  ├── Model Runtime
  ├── Tool Runtime
  ├── Notification API
  ├── Observability API
  └── Safety Hook Interface
          │
          ▼
      Capsule Contract
          │
          ▼
       OCD Capsule
  ├── Domain Model
  ├── Policies
  ├── Tools
  ├── Prompts
  ├── Evaluations
  ├── UI Domain Layer
  └── OCD Data Extensions
```

The concrete interface is not defined yet. It must be derived from inspected implementation constraints rather than invented prematurely.

## Data isolation

At minimum, architecture must support logical separation of:

- client/tenant identity;
- user identity;
- OCD-specific data;
- prompts/configuration;
- evaluation assets;
- analytics;
- secrets/provider credentials where relevant.

No cross-client read should occur by default.

Any future cross-product/shared-data concept requires an explicit privacy, product and architecture decision.

## Memory isolation

Generic memory infrastructure can live in Core.

OCD memory semantics belong to the capsule.

Examples:

Core may know how to:

- store/retrieve permitted memory records;
- scope memory by tenant/user/session;
- expire/delete data;
- expose an API to capsule logic.

OCD capsule may know how to:

- interpret repeated reassurance attempts;
- classify an entry as a possible loop pattern;
- decide which history is relevant to Compulsion Firewall;
- apply OCD-specific retention/minimization decisions approved by privacy policy.

## Safety architecture

Core can provide generic safety primitives such as:

- provider-failure handling;
- structured policy hooks;
- rate/loop controls;
- audit metadata;
- escalation routing interfaces.

OCD-specific safety policy belongs exclusively to the capsule.

A generic IAmina behavior must never silently encode OCD treatment assumptions.

## Provider independence

OCD product logic should not depend directly on one LLM vendor's proprietary response format unless unavoidable and documented.

Prefer:

`OCD policy/domain layer → Core model abstraction → provider`

rather than:

`OCD screen → vendor SDK directly`.

Any exception must be justified and tested.

## Failure behavior

The capsule must fail safely when Core services fail.

Examples:

- model timeout → safe degraded state, no fabricated success;
- memory unavailable → do not pretend history was checked;
- policy engine unavailable → do not silently fall back to unrestricted generic chat;
- tool failure → disclose failure appropriately and keep user in a safe state.

## Dependency direction

Preferred direction:

`App shell → OCD capsule → Core interfaces → infrastructure/provider`

Forbidden unless explicitly approved:

`IAmina Core → OCD-specific implementation`.

## Versioning

The capsule contract should become versioned once a second independent capsule/client depends on it.

Before that point, avoid premature framework-building. Extract only what has been demonstrated to be genuinely generic.

## Architectural gate

Before implementation is considered architecturally verified, evidence must show:

- no OCD imports/dependencies inside generic Core modules;
- client data/config separation;
- explicit capsule boundary;
- safe provider failure behavior;
- tests covering boundary violations where practical;
- no unapproved cross-client data path.

## Rule for future refactors

Do not move OCD code into Core merely to reduce duplication.

Only extract a capability into Core when it is demonstrably domain-independent and the extraction preserves client isolation and safety behavior.
