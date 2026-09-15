# LOT 01 — IAmina Core Inspection

Status: READY FOR REVIEW
Date: 2026-09-15

## GOAL

Inspect the real IAmina implementation and identify which existing primitives are genuinely reusable for the separate TrueGround/OCD client before defining any OCD capsule contract or writing integration code.

This lot is inspection-only. It does not authorize changes to IAmina Core, TrueGround runtime, databases, deployments, providers, schemas or production data.

## SUCCESS

LOT 01 succeeds when:

- the current IAmina source repository and exact inspected revision are identified;
- backend and frontend module seams are inspected from code, not inferred from roadmap language;
- reusable Core primitives are separated from diabetes-owned logic;
- material gaps between IAmina's current module model and the TrueGround separate-client requirement are documented;
- no OCD-specific contract is invented prematurely;
- mandatory architecture and privacy/security reviews are recorded.

## PROOF

Inspected source repository:

- Repository: `hraaaaf/IAMINA-MVP`
- Branch: `main`
- Inspected HEAD: `715e2cc5108992f1347e93a115b0c71c90f47914`
- HEAD observed on 2026-09-15

TrueGround documentation base at lot start:

- Repository: `hraaaaf/trueground`
- Parent branch: `docs/ocd-canonical-foundation`
- Parent HEAD at lot start: `5921c4b5b89426a41d8100919511593cdcbc40b9`
- LOT branch: `lot/01-iamina-core-inspection`

## 1. Current IAmina reality

The current IAmina source is a Flutter + Django modular monolith with one live condition: diabetes.

The repository itself explicitly warns that existing chassis/module seams do not mean IAmina is already a multi-condition platform. That distinction matters for TrueGround: we may reuse proven seams, but we must not pretend that a second independent client already exists as a supported runtime mode.

Observed stack:

- Flutter frontend for web/iOS/Android;
- Django 6 + django-ninja backend;
- PostgreSQL authoritative outside lightweight local SQLite fallback;
- Drift/SQLite offline-first frontend state;
- Django-owned auth/token flows with remaining guarded Firebase migration compatibility;
- provider adapters behind a governed AI/data-egress boundary.

## 2. Backend primitives confirmed reusable in principle

### 2.1 Module manifest and registry

Observed:

- `backend/core/contracts/manifest.py`
- `backend/core/registry.py`
- `backend/diabetes/manifest.py`
- `backend/diabetes/apps.py`

The Core exposes a disease-neutral `ModuleManifest` and append-only `ModuleRegistry`.

A condition module registers:

- name/version;
- condition identifier;
- URL prefix;
- OpenAPI tags;
- supported languages;
- interactive endpoints requiring safety registration;
- acquisition/retention event metadata;
- engine class;
- router.

The diabetes module registers itself from `DiabetesConfig.ready()` and the dependency direction is module → Core.

Assessment:

**Reusable primitive: YES, with adaptation.**

The registry is real and code-backed. It is not merely a roadmap idea.

### 2.2 Import-boundary enforcement

Observed:

- `backend/.importlinter`

The repository enforces:

- `core` must not import diabetes internals;
- companion runtime must not import diabetes internals;
- only documented debt exceptions are allowed.

Assessment:

**Reusable guardrail: YES.**

For TrueGround, an equivalent rule should prohibit generic IAmina Core from importing OCD-specific code.

### 2.3 Shared patient/account identity

Observed:

- `backend/core/models/patient.py`
- `backend/core/models/patient_module.py`
- `backend/core/api/v1/auth.py`
- `backend/core/api/v1/account.py`
- `backend/core/api/v1/modules.py`

`BasePatientProfile` is chassis-owned and holds cross-cutting identity/consent/account fields. Module-specific clinical fields are intended to live outside Core.

`PatientModule` tracks per-patient module activation and `/api/v1/account/modules` exposes the active module list.

Assessment:

**Reusable identity/auth primitives: YES.**

**Current module-activation model for TrueGround: NOT ACCEPTED YET.**

Reason: TrueGround/OCD and diabetes are separate clients/products, not two capsules a single user should necessarily activate inside one consumer app.

### 2.4 AI capability/authority contract

Observed:

- `backend/core/contracts/capabilities.py`

The current Core explicitly separates capability from authority and denies generative-model authority for diagnosis, prescribing, dose calculation, treatment optimization/change, emergency classification and autonomous clinical-record writes.

Assessment:

**Reusable safety primitive: YES.**

However, OCD-specific behavioral permissions such as reassurance handling must remain inside the OCD capsule and must not be added to the generic capability enum merely because TrueGround needs them unless they are demonstrated to be truly cross-domain.

### 2.5 Central AI/data egress boundary

Observed:

- `backend/core/ai_egress.py`
- `backend/core/ai_processor_policy.py`
- associated core tests, including egress boundary and payload tests.

The egress layer requires patient scope, registered purpose, modality, current consent and payload constraints before external provider calls. It includes DLP-style identifier checks and purpose/modality allowlisting.

Assessment:

**Reusable privacy/security primitive: YES.**

Important limitation:

The purpose registry is currently hard-coded in Core. Adding an OCD-specific purpose directly to `_PURPOSE_MODALITIES` would make Core know about an OCD client concern. LOT 02 must decide whether a generic extension/registration seam is required or whether TrueGround uses a separately configured deployment without contaminating shared Core.

### 2.6 Shared LLM gateway/provider abstraction

Observed:

- `backend/core/llm_gateway.py`
- `backend/llm/` provider layer referenced by the gateway.

`GatewayLLM` is the sanctioned shared LLM call surface and applies capability checks, egress authorization, generative-context minimization, PHI stripping/pseudonymization, provider abstraction and usage telemetry.

Assessment:

**Reusable primitive: YES, subject to OCD-specific policy being applied before/around the generic gateway rather than encoded inside it.**

The gateway must never become the place where reassurance-seeking logic is hardcoded.

### 2.7 Condition-agnostic DomainContext

Observed:

- `backend/core/contracts/domain_context.py`

The Core defines a condition-agnostic structured output contract used between a module and shared companion/narrative layers.

Assessment:

**Partially reusable.**

Fields such as analysis status, degradations, sufficient-data state, language and generic structured outputs are useful. Fields such as KPI summary, `primary_label`, trend and pattern semantics were designed around quantitative condition analysis and may not be the right contract for OCD flows.

LOT 02 must not force OCD into diabetes-shaped fields merely to reuse an existing dataclass.

### 2.8 Companion persistence ports

Observed:

- `backend/core/companion/ports.py`
- diabetes adapters registered from `backend/diabetes/apps.py`.

Core has narrow condition-agnostic ports for conversation history and memory snapshots.

Assessment:

**Reusable concept: YES. Current registry shape: INSUFFICIENT for shared multi-client/multi-module runtime.**

Critical observation:

`SnapshotStore` and `ConversationStore` are registered into module-level singleton slots. One active adapter wins globally. This is coherent with the repository's current single-module deployment posture, but it is not a safe multi-client tenant-routing mechanism.

For a separate TrueGround deployment, these ports may be reusable as-is initially. For a shared IAmina multi-client runtime, they require an explicit client/module resolution contract first.

### 2.9 Shared safety, account lifecycle and observability seams

Observed from architecture/current module wiring:

- shared safety registry and emergency response ownership;
- account deletion hooks;
- audit sink registration;
- observability/retention primitives;
- locale/account APIs.

Assessment:

**Reusable infrastructure candidates: YES.**

OCD-specific safety policy remains capsule-owned. Shared emergency/crisis primitives may be reused only after TrueGround's crisis routing requirements are separately defined and clinically/regulatorily reviewed where applicable.

## 3. Frontend primitives confirmed reusable in principle

### 3.1 Flutter shell/toolchain

Observed:

- `frontend/pubspec.yaml`
- `frontend/lib/`

Current reusable foundation includes:

- Flutter/Dart;
- `go_router`;
- localization infrastructure;
- secure token storage;
- Drift offline persistence;
- networking/connectivity primitives;
- provider-based state management;
- shared app/core/services structure.

Assessment:

**Reusable app-shell technology: YES.**

### 3.2 Frontend ModuleConfig / ModuleRegistry

Observed:

- `frontend/lib/modules/module_config.dart`
- `frontend/lib/modules/module_registry.dart`
- `frontend/lib/modules/diabetes_module.dart`

`ModuleConfig` is a real generic contract for module navigation and routes.

However, `ModuleRegistry` statically imports and registers `diabetesModule`, and the frontend currently assumes a single IAmina application that knows registered condition modules.

Assessment:

**Reusable concept: YES. Current client packaging model: NOT sufficient for TrueGround as a separate branded client.**

TrueGround should not ship diabetes screens/routes merely because the shared source tree can register them.

## 4. The most important architecture finding

### Existing IAmina modularity and TrueGround's business model are not the same thing

Current IAmina modularity mainly models:

`one IAmina product → one patient identity → condition modules`

The TrueGround requirement is:

`one reusable IAmina machine → separate client/product deployments → isolated users/data/branding/domain policy`

These are related but materially different architectures.

The current code proves that IAmina has reusable seams. It does **not** yet prove client/tenant isolation suitable for two separate customers/products sharing one runtime/database.

No inspected code established a first-class `Client`, `Tenant` or equivalent isolation boundary across auth, data, prompts, provider configuration and analytics.

Therefore LOT 02 must explicitly choose the deployment/isolation model before any OCD implementation begins.

## 5. Candidate architecture options for LOT 02 decision

This lot does not choose between them; it records the real options exposed by the inspection.

### OPTION A — Separate TrueGround deployment using shared IAmina Core code

Characteristics:

- separate TrueGround app branding;
- separate runtime/deployment;
- separate database/data plane;
- same audited generic Core primitives reused;
- OCD capsule is the only active domain module in that client deployment;
- no diabetes user/data visibility.

Advantages:

- strongest isolation with the current architecture;
- compatible with global singleton companion persistence ports;
- smallest architectural change;
- easiest to audit early.

Cost:

- less infrastructure sharing at runtime;
- Core updates require controlled synchronization/versioning between client deployments.

### OPTION B — Shared multi-client IAmina runtime with explicit tenant/client isolation

Would require at minimum:

- first-class client/tenant identity;
- tenant-scoped auth/data/provider config;
- tenant-aware module registration/resolution;
- tenant-aware memory/conversation stores;
- prompt/config/eval isolation;
- analytics/logging isolation;
- cross-client access tests;
- likely new migration/authorization surface.

Advantages:

- stronger long-term platform centralization.

Cost/risk:

- materially larger architecture/security project;
- changes proven diabetes Core behavior;
- creates migration and non-regression risk before TrueGround has validated product demand.

## 6. Reuse matrix

| Primitive | Exists now | Reuse for TrueGround | Caveat |
|---|---:|---|---|
| Django auth/token/account | Yes | Strong candidate | Keep client data isolation explicit |
| BasePatientProfile | Yes | Candidate | Contains current IAmina assumptions; review fields before reuse |
| ModuleManifest | Yes | Strong candidate | Do not treat module as client/tenant |
| ModuleRegistry | Yes | Candidate | Global registry, not tenant routing |
| Import-linter Core→module boundary | Yes | Strong candidate | Add OCD boundary tests |
| PatientModule activation | Yes | Not automatically | Models one user activating modules, not separate clients |
| Capability authority contract | Yes | Strong candidate | OCD policy remains capsule-owned |
| AI egress authorization | Yes | Strong candidate | Hard-coded purpose registry needs design review |
| LLM gateway | Yes | Strong candidate | Must remain domain-neutral |
| DomainContext | Yes | Partial | Avoid forcing OCD into diabetes/KPI semantics |
| Companion conversation/memory ports | Yes | Concept reusable | Global singleton resolution is a key limitation |
| Safety registry/emergency seam | Yes | Candidate | OCD crisis policy is separate |
| Account deletion hooks | Yes | Strong candidate | OCD data adapter must participate |
| Frontend Flutter shell | Yes | Strong candidate | Branding/client packaging must be separate |
| Frontend ModuleConfig | Yes | Strong candidate | Current registry statically includes diabetes |
| Localization framework | Yes | Strong candidate | OCD safety parity per language still required |
| Offline Drift layer | Yes | Candidate | OCD schema/data minimization must be redesigned |

## 7. What is explicitly NOT decided in LOT 01

LOT 01 does not decide:

- whether TrueGround shares a deployment/database with diabetes;
- whether `PatientModule` is reused;
- exact OCD API routes;
- exact OCD database schema;
- exact OCD memory model;
- exact LLM provider;
- exact egress purpose names;
- exact Loop/Compulsion Firewall implementation;
- clinical/ERP behavior;
- crisis protocol;
- production infrastructure.

Those belong to later lots and must be evidence-driven.

## 8. Recommended LOT 02 scope

LOT 02 should be narrowly titled:

**LOT 02 — TrueGround client isolation + OCD capsule contract**

Its job should be to decide and document:

1. separate deployment vs shared tenant-aware runtime;
2. exact Core primitives reused unchanged;
3. exact OCD-owned surfaces;
4. required generic extension seams, if any;
5. explicit forbidden dependencies;
6. minimum route/data/memory/config boundary;
7. tests that will enforce the boundary before implementation.

No UI, Loop flow or clinical feature implementation should start before that contract is accepted.

## 9. Conclusion

The inspection confirms that IAmina already contains substantial reusable machine-level infrastructure. The useful foundation is real: module contracts, import boundaries, auth/account primitives, capability authority, governed AI egress, shared LLM gateway, companion persistence ports, Flutter module configuration and localization/offline infrastructure.

The inspection also exposes the central mismatch we must not hide: current IAmina modularity was built for one product with condition modules, while TrueGround is a separate client/product. The existing code does not yet prove safe shared-runtime client isolation.

That mismatch is the architectural question LOT 02 must resolve before code reuse begins.
