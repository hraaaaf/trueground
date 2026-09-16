# LOT 02 — TrueGround client isolation + OCD capsule contract

Status: READY FOR REVIEW
Date: 2026-09-16

## GOAL

Define the smallest auditable architecture contract that allows TrueGround/OCD to reuse proven IAmina Core primitives while remaining a separate client/product from the Diabetes client under approved Option A.

This lot is architecture-contract work only. It does not authorize runtime implementation, IAmina Core changes, deployment, production mutation, database/schema work, Loop UI, Compulsion Firewall behavior, ERP behavior, or detailed OCD persistence design.

## SUCCESS

LOT 02 succeeds when the contract makes explicit:

- which inspected IAmina primitives are approved for reuse in principle;
- what remains generic Core versus TrueGround/OCD-owned;
- build/deployment, auth, data, memory, AI, prompt/policy/eval, routing and frontend boundaries;
- deletion/export/retention ownership;
- forbidden dependency directions;
- a non-floating shared-Core version/update strategy;
- static/integration checks that prevent OCD logic from leaking into Core;
- checks that prevent TrueGround and Diabetes data/config/runtime coupling;
- the unresolved implementation seams that must not be invented in this lot.

## PROOF BASELINE

### TrueGround repository truth at LOT 02 start

- Repository: `hraaaaf/trueground`
- Default branch: `main`
- `main` HEAD: `e1cdd5485e80c3c8bb4f7f5e3bdf695709111d61`
- Canonical foundation branch: `docs/ocd-canonical-foundation`
- Canonical foundation HEAD: `5921c4b5b89426a41d8100919511593cdcbc40b9`
- Canonical foundation divergence from `main`: ahead 20 / behind 0
- LOT 01 branch: `lot/01-iamina-core-inspection`
- LOT 01 HEAD: `c5380cae770c11b958cb4a0a54152da40030df71`
- LOT 01 divergence from canonical foundation: ahead 5 / behind 0
- PR #1: OPEN / DRAFT / NOT MERGED
- PR #2: OPEN / DRAFT / NOT MERGED
- PR #1 unresolved review threads: none observed
- PR #2 unresolved review threads: none observed
- Combined commit status contexts on `main`, canonical foundation and LOT 01 HEAD: none observed

### IAmina source re-inspected for LOT 02

- Repository: `hraaaaf/IAMINA-MVP`
- Branch: `main`
- Current HEAD inspected: `4e7b04a3387da68374e00ab858e63b914faa1884`
- LOT 01 inspected HEAD: `715e2cc5108992f1347e93a115b0c71c90f47914`
- Current HEAD is 4 commits ahead / 0 behind the LOT 01 inspected SHA.

Files changed between those two IAmina revisions were limited to TD-008 workflow/integration-test work, frontend package metadata/lockfile and documentation. None of the Core/backend contract files re-inspected below changed in that range.

### Current source evidence re-inspected

Backend:

- `backend/core/contracts/manifest.py`
- `backend/core/registry.py`
- `backend/.importlinter`
- `backend/core/companion/ports.py`
- `backend/core/ai_egress.py`
- `backend/core/llm_gateway.py`
- `backend/llm/factory.py`
- `backend/core/models/patient.py`
- `backend/core/models/patient_module.py`
- `backend/core/account_hooks.py`
- `backend/core/api/v1/modules.py`
- `backend/core/api/v1/account.py`
- `backend/diabetes/apps.py`
- `backend/amina/settings.py`

Frontend:

- `frontend/lib/modules/module_config.dart`
- `frontend/lib/modules/module_registry.dart`

TrueGround currently contains documentation only (`README.md` + `docs/`). No TrueGround runtime/package implementation exists yet; this lot therefore does not pretend that a shared package, app shell or deployment composition already exists.

---

# 1. Approved architecture direction

## Option A — APPROVED

TrueGround is a separate client/product with a separate runtime and data plane. It may reuse shared/versioned IAmina Core source and generic infrastructure primitives, but it does not share Diabetes runtime state, identity state, user data, databases, caches, secrets, memory, prompts, evaluations or app packaging.

The key model is:

```text
                 immutable/versioned Core source
                           │
                ┌──────────┴──────────┐
                │                     │
        Diabetes client        TrueGround client
        own composition        own composition
        own runtime            own runtime
        own auth/data          own auth/data
        own secrets            own secrets
        diabetes capsule       OCD capsule
```

There is no network/runtime dependency from TrueGround to the Diabetes deployment in this architecture.

## Option B — NOT SELECTED

LOT 02 does not introduce a shared multi-client IAmina runtime or shared tenant-aware database.

If future work proposes that model, it is a new architecture decision and must prove tenant/client isolation across every boundary listed in this contract before adoption.

---

# 2. What is actually reusable from the inspected IAmina implementation

Reuse here means reuse of inspected generic source/behavior in a separate TrueGround build/runtime. It does **not** mean sharing Diabetes process state or data.

| Primitive | Current evidence | LOT 02 reuse decision | Boundary |
|---|---|---|---|
| `ModuleManifest` | `core/contracts/manifest.py` | REUSE IN PRINCIPLE | Generic module metadata; `condition` remains a generic module slug, not a client/tenant identity |
| `ModuleRegistry` | `core/registry.py` | REUSE IN PRINCIPLE | Safe only because TrueGround has its own process and registers only its own domain module(s) |
| Core→module import boundary | `backend/.importlinter` | REUSE / EXTEND GUARDRAIL | Generic Core must never import OCD implementation |
| Capability/authority model | inspected in LOT 01, unchanged since | REUSE | OCD-specific behavioral policy remains outside capability enum unless demonstrably cross-domain |
| AI egress authorization | `core/ai_egress.py` | REUSE WITH CONSTRAINT | Generic purposes/consent/DLP can be reused; do not hard-code OCD concepts into shared Core |
| LLM gateway/provider abstraction | `core/llm_gateway.py`, `llm/factory.py` | REUSE | OCD code calls the generic gateway; no direct provider SDK call from OCD feature code |
| Companion persistence ports | `core/companion/ports.py` | REUSE IN TRUEGROUND PROCESS | Current singleton resolution is acceptable only because the runtime is single-client; TrueGround registers only TrueGround/OCD adapters |
| Base account/profile primitives | `core/models/patient.py` | REUSE CODE, NOT ROWS | TrueGround has its own database and identity records; no shared `User` or `BasePatientProfile` rows |
| Account deletion hook orchestration | `core/account_hooks.py`, account API | REUSE | TrueGround registers its own cleanup hooks and proves its own stores are covered |
| Frontend `ModuleConfig` concept | `frontend/lib/modules/module_config.dart` | REUSE CONCEPT/API | Client-owned composition decides which module is packaged |
| Existing frontend `ModuleRegistry` implementation | `frontend/lib/modules/module_registry.dart` | DO NOT REUSE UNCHANGED | It statically imports/registers Diabetes |
| Existing `amina/settings.py` composition | `backend/amina/settings.py` | DO NOT REUSE UNCHANGED | It installs `diabetes.apps.DiabetesConfig` and Diabetes middleware |
| `PatientModule` activation as client isolation | `core/models/patient_module.py`, modules API | NOT A CLIENT BOUNDARY | It models module activation inside one platform identity; it must not be used to separate TrueGround from Diabetes |

## Important consequence

The reusable object is the generic source/primitive, not the current Diabetes application composition.

The current IAmina deployment settings and Flutter registry are Diabetes-coupled. TrueGround therefore needs a client-owned composition layer in a later implementation lot. This contract does not invent its file names or implementation shape before that work begins.

---

# 3. Core versus OCD capsule ownership

## Generic IAmina Core may own

Only domain-independent capabilities, for example:

- generic auth/session/account mechanics;
- generic consent mechanics where applicable;
- generic module contracts/registry mechanics;
- capability/authority enforcement;
- generic AI egress authorization, consent checks and DLP/minimization;
- model/provider abstraction and gateway enforcement;
- generic memory/conversation persistence interfaces;
- account deletion orchestration hooks;
- generic observability and failure primitives;
- localization/tooling primitives that are not condition-specific;
- generic evaluation harness infrastructure.

## TrueGround/OCD owns exclusively

- OCD terminology and domain model;
- reassurance-seeking semantics;
- checking, rumination, confession/repetition semantics;
- Compulsion Firewall policy and behavior;
- ERP/practice behavior and any clinically reviewed treatment-like logic;
- OCD-specific prompts/system policies;
- OCD-specific safety policies and thresholds;
- OCD-specific evaluation cases/datasets/thresholds;
- OCD-specific memory semantics and relevance rules;
- OCD-specific data/schema extensions;
- OCD-specific routes/tools/domain adapters;
- TrueGround copy, navigation, branding and product UI;
- TrueGround support/crisis integration rules when later approved;
- TrueGround retention/minimization decisions for OCD content, subject to privacy/legal review.

## Extraction rule

Duplication is preferable to contaminating Core when genericity is not proven.

A capability may move from the OCD capsule into Core only when all of the following are true:

1. it is demonstrably domain-independent;
2. Diabetes can consume or ignore it without OCD semantics;
3. the extraction does not create cross-client runtime/data coupling;
4. both clients' relevant non-regression tests pass;
5. the Core change receives separate explicit review/approval.

---

# 4. Deployment boundary

TrueGround and Diabetes must have separate deployable application compositions.

Minimum production isolation:

- separate backend runtime/service;
- separate frontend build/app identity;
- separate environment configuration;
- separate database/data plane;
- separate cache/session/runtime-memory plane if used;
- separate object/blob storage if used;
- separate background-worker/queue state if later used;
- separate secret set and credentials;
- separate observability/log/analytics destination or a provider-enforced project boundary with distinct credentials;
- separate backup/recovery scope;
- separate release/deployment authorization.

A common infrastructure vendor is not, by itself, a violation. Sharing the same database, tables, cache namespace, secret, runtime process or user-data store is a violation unless separately approved in a future architecture decision.

TrueGround runtime must not require the Diabetes deployment to be available in order to boot or operate.

---

# 5. Authentication and account boundary

Reuse of generic auth/account code is allowed; account state is not shared.

Required properties:

- separate user/account namespace;
- separate session/token signing/configuration;
- separate application secrets;
- separate Firebase project/credentials if Firebase compatibility is retained in TrueGround;
- no automatic mapping of a Diabetes account to a TrueGround account;
- no cross-client login/session cookie reuse;
- no `PatientModule` row used as the mechanism that turns a Diabetes account into a TrueGround account;
- server-side ownership checks remain mandatory inside the TrueGround data plane.

A future SSO or account-linking feature would require a separate product/privacy/security decision.

---

# 6. Data and storage boundary

For production and production-like environments, TrueGround and Diabetes must not share user-content tables or a common application database.

Required minimum:

- distinct database/project and credentials;
- no cross-client ORM/query path;
- no shared primary keys relied on as identity bridges;
- no shared OCD/Diabetes object-storage namespace;
- no shared cache/session namespace;
- no shared search/vector index containing both clients' private content;
- no shared analytics event payload containing raw private content;
- no test fixture sourced from real Diabetes user data for TrueGround work.

If a common managed vendor is used, isolation must be enforced at the provider project/database/bucket/index boundary with different credentials; a mere application-level `client_id` filter is not the approved V1 isolation model.

---

# 7. Memory and conversation boundary

The inspected `SnapshotStore` and `ConversationStore` use process-global singleton registration. That is acceptable under Option A only because each client has its own process.

TrueGround requirements:

- only TrueGround/OCD adapters may register in the TrueGround process;
- those adapters point only to TrueGround storage;
- Diabetes adapters are not imported, instantiated or registered in the TrueGround runtime;
- memory retrieval is scoped to the authenticated TrueGround account/user;
- OCD-specific interpretation of repetition, reassurance or relevance lives in the OCD capsule;
- memory failure must not be presented as successful history retrieval.

The singleton ports are **not** approved as a multi-client router.

---

# 8. AI egress and provider boundary

## Generic Core responsibility

The inspected generic pipeline may continue to provide:

- capability/authority enforcement;
- explicit egress scope;
- consent checks;
- payload limits;
- identifier/DLP checks;
- PHI minimization/pseudonymization mechanisms;
- provider abstraction;
- processor-policy and FinOps enforcement;
- provider failure normalization.

## TrueGround responsibility

- TrueGround owns the OCD prompt/policy decision before content reaches the generic gateway;
- TrueGround uses its own provider configuration and credentials;
- TrueGround does not share Diabetes provider secrets, rate state or runtime telemetry state;
- OCD feature code does not call a vendor SDK directly;
- OCD-specific safety behavior is never implemented inside `GatewayLLM` or provider adapters.

## Egress-purpose rule

`core/ai_egress.py` currently has a hard-coded generic purpose registry.

LOT 02 does **not** authorize adding `ocd_*`, reassurance, ERP or other OCD-specific purpose names directly into shared Core.

For an initial text companion call, an existing genuinely generic purpose such as `companion_chat` may be reused only when its semantics and processor policy actually match the operation.

If a future TrueGround feature requires a purpose that cannot honestly map to an existing generic purpose, the required change is a separately reviewed **generic registration/configuration seam**, not a direct OCD constant added to shared Core.

---

# 9. Prompt, policy and evaluation boundary

All OCD prompt/policy/evaluation assets are TrueGround-owned.

They must be separately versioned from Core and must not be bundled into the generic Core source merely for convenience.

This includes:

- system prompts;
- anti-reassurance instructions;
- repetition/checking/rumination policies;
- Compulsion Firewall policy;
- OCD-specific safe-fallback copy/policy;
- OCD-specific eval cases and expected behavior;
- OCD-specific thresholds/decision tables;
- clinically reviewed content when later introduced.

Core may provide only the generic harness/interfaces needed to execute or test these assets.

---

# 10. Routing and module-registration boundary

## Backend

The current `ModuleRegistry` is global per process. Under Option A this is acceptable if the TrueGround process registers only TrueGround/OCD module(s).

TrueGround must not boot with `diabetes.apps.DiabetesConfig` or Diabetes middleware/routes merely because the source repository currently does.

The later client-composition implementation must prove:

- Diabetes is absent from TrueGround installed-app composition;
- Diabetes middleware is absent from TrueGround middleware composition;
- Diabetes routes are not mounted;
- Diabetes companion adapters are not registered;
- only approved TrueGround/OCD routes/modules are discoverable.

## Frontend

The current Flutter `ModuleRegistry` statically imports `diabetes_module.dart`; it therefore cannot be reused unchanged for the separate TrueGround app.

The later TrueGround app composition must prove:

- no Diabetes screen/route/module is statically imported into the TrueGround application package;
- the TrueGround package has its own branding/application identity;
- only approved shared shell/components and TrueGround/OCD feature surfaces are compiled into the client.

This lot does not design the TrueGround navigation or Dashboard implementation.

---

# 11. Frontend packaging and branding boundary

TrueGround is not a Diabetes feature flag.

It requires a separate client artifact with, when implementation begins:

- separate app/site identity and branding;
- separate route/module composition;
- separate environment endpoints;
- separate release channel;
- no Diabetes assets/screens/routes in the shipping package unless a future explicit product decision says otherwise.

Generic visual/component primitives may be reused only if they carry no Diabetes-specific semantics.

---

# 12. Account deletion, export and retention responsibility

Generic Core may orchestrate account lifecycle through hooks, but TrueGround owns the completeness of its own domain cleanup.

Before TrueGround persistence is production-ready, prove that deletion covers every TrueGround-owned store that exists at that time, including as applicable:

- primary database rows;
- memory/conversation records;
- object/blob content;
- derived search/vector indexes;
- caches;
- provider-side retained data where the contract/API permits deletion;
- analytics identifiers/content where deletion is required;
- backups according to the documented retention policy.

Rules:

- a Diabetes deletion must never delete TrueGround data;
- a TrueGround deletion must never delete Diabetes data;
- TrueGround must not claim complete deletion while known active downstream copies remain contrary to its stated policy;
- export functionality is client-owned and is not considered implemented by this architecture contract;
- retention periods for OCD content remain a later privacy/product decision and must not be inherited blindly from Diabetes.

---

# 13. Forbidden dependency directions

The following are forbidden unless a future explicitly approved architecture decision changes them:

```text
IAmina Core        -> TrueGround/OCD implementation     FORBIDDEN
IAmina Core        -> OCD prompts/policies/evals        FORBIDDEN
TrueGround/OCD     -> Diabetes implementation           FORBIDDEN
TrueGround runtime -> Diabetes API/runtime              FORBIDDEN
TrueGround runtime -> Diabetes DB/cache/storage         FORBIDDEN
TrueGround auth    -> Diabetes account/session state    FORBIDDEN
TrueGround secrets -> Diabetes secret values            FORBIDDEN
Diabetes runtime   -> TrueGround private data/capsule   FORBIDDEN
```

Allowed direction:

```text
TrueGround composition
    -> OCD capsule
        -> approved generic IAmina Core interfaces/primitives
            -> TrueGround-owned infrastructure/provider configuration
```

A direct import of a shared Core implementation detail not listed as an approved surface requires architecture review rather than being normalized by convenience.

---

# 14. Shared Core versioning and update strategy

## Current reality

No independently published/versioned IAmina Core package was found in the inspected repositories, and TrueGround has no runtime yet.

LOT 02 therefore must not invent a package registry, submodule or extraction that does not exist.

## Contract

Shared Core reuse is **build-time/source-version reuse**, never runtime service sharing.

The source baseline for the next implementation lot is pinned to the exact inspected IAmina revision:

`4e7b04a3387da68374e00ab858e63b914faa1884`

Rules:

1. TrueGround must not consume a floating `main`/branch as its implicit production Core version.
2. Any implementation must record an immutable IAmina source revision (exact Git SHA; an immutable release tag may additionally reference it later).
3. Client builds must not contact the Diabetes runtime to obtain Core behavior.
4. A Core upgrade is an explicit TrueGround change from one immutable revision to another.
5. Every upgrade must review the diff for the reused surfaces and their transitive dependencies.
6. A Core change needed by TrueGround must be generic before it is upstreamed; OCD-specific patches stay in the capsule.
7. Shared-Core fixes must prove Diabetes non-regression in `IAMINA-MVP` and TrueGround non-regression in `trueground` before the TrueGround pin is advanced.
8. No automatic unreviewed Core upgrade is permitted.
9. The concrete packaging mechanism (for example package extraction, source snapshot, subtree or another build-time mechanism) is deliberately deferred until a later implementation lot inspects the chosen client bootstrap. Whichever mechanism is selected must preserve the immutable-pin and no-runtime-coupling rules above.

This avoids prematurely creating a new framework while still making Core upgrades auditable.

---

# 15. Required future static and integration checks

These checks become mandatory as soon as relevant runtime code exists. LOT 02 defines them; it does not falsely claim they have already run against a non-existent TrueGround application.

## A. Prevent OCD logic leaking into Core

1. Import-boundary check:
   - generic Core must not import TrueGround/OCD modules;
   - companion/generic runtime must not import OCD implementation.
2. Static source check:
   - shared Core contains no OCD domain terms/constants/prompt assets unless separately approved as truly generic metadata.
3. Prompt/eval placement check:
   - OCD prompts, policies and eval datasets resolve from the capsule/client tree, not Core.
4. AI-provider check:
   - OCD feature code reaches providers only through the approved Core gateway/egress path.
5. Generic-change review:
   - any IAmina Core PR caused by a TrueGround need requires Architecture + QA non-regression review before adoption.

## B. Prevent Diabetes coupling into TrueGround

1. Backend composition test:
   - Diabetes app/middleware/routes/adapters are absent from the TrueGround runtime.
2. Frontend package test:
   - Diabetes module/screens/routes are absent from the TrueGround dependency/build graph.
3. Registry smoke test:
   - TrueGround process registry contains only approved TrueGround/OCD module(s).
4. Dependency scan:
   - no `trueground/ocd -> diabetes` imports.

## C. Prevent cross-client data/config coupling

1. Isolated test environments with distinct fake client datasets.
2. Negative access tests proving TrueGround credentials cannot read/write Diabetes storage and vice versa.
3. Separate database configuration identity; no common application DB URL.
4. Separate auth issuer/project/configuration identity.
5. Separate cache/session namespace and credentials where used.
6. Separate AI/provider secrets and processor configuration.
7. Separate logging/analytics sinks or provider-enforced project boundaries with distinct credentials.
8. Deletion tests proving each client deletes only its own data.
9. Memory/conversation tests proving the TrueGround adapter cannot resolve Diabetes records.
10. Secret/config scan that compares identifiers without printing secret values.

## D. Shared-Core upgrade gate

For every Core pin bump:

- record old SHA and new SHA;
- inspect changed files in reused Core surfaces;
- run relevant IAMINA Core/Diabetes tests;
- run TrueGround tests;
- run import/dependency boundary checks;
- run client-isolation/config tests;
- record specialist review;
- update the pin only after the evidence passes.

---

# 16. Failure-isolation rules

A failure in one client must not require unsafe fallback to the other client.

Examples of required behavior:

- TrueGround DB unavailable → fail/degrade inside TrueGround; never query Diabetes DB;
- TrueGround memory unavailable → disclose/handle missing memory according to approved OCD policy; never consult Diabetes memory;
- TrueGround provider credential/config failure → approved local/degraded behavior; never borrow Diabetes credentials;
- OCD policy unavailable → do not fall back to unrestricted generic chat;
- Diabetes deployment outage → TrueGround remains independently bootable/operable except for any deliberately shared external vendor that is itself down.

---

# 17. OCD safety ownership at the architecture boundary

Option A changes infrastructure ownership, not clinical/OCD policy ownership.

The following must remain inside TrueGround/OCD even if generic Core supplies runtime hooks:

- recognition/handling of reassurance seeking;
- checking and rumination handling;
- repetition/confession-loop behavior;
- Compulsion Firewall decisions;
- practice/ERP safety behavior;
- OCD-specific memory relevance;
- OCD-specific safe fallback content;
- OCD-specific evaluation acceptance thresholds.

Generic Core may supply generic rate limiting, loop-prevention primitives, provider-failure hooks or policy interfaces only when those primitives do not encode an OCD treatment assumption.

No medical claim, diagnostic behavior or therapeutic promise is introduced by this contract.

---

# 18. Explicitly deferred from LOT 02

LOT 02 does not define or implement:

- exact TrueGround source-tree/package layout;
- exact backend settings file names;
- exact OCD API routes;
- exact database tables or migrations;
- exact memory schema;
- Loop UI or conversation behavior;
- Compulsion Firewall algorithm;
- ERP/practice algorithm;
- crisis protocol;
- LLM/provider choice;
- production cloud vendor;
- deployment pipeline;
- app-store configuration;
- detailed Dashboard V3 implementation.

Those items require later lots and their own acceptance/specialist gates.

---

# 19. LOT 02 acceptance assessment

Against `GATE 1 — ARCHITECTURE_BOUNDARY_VERIFIED`:

- actual IAmina code inspected: YES;
- no invented existing interface treated as real: YES;
- reusable Core primitives identified from code: YES;
- OCD-specific concepts kept outside generic Core: YES by contract;
- client isolation path documented: YES — separate deployment/data plane;
- provider/model dependency direction explicit: YES;
- failure modes documented: YES;
- boundary/static checks defined where practical: YES, to become executable when runtime exists.

No runtime code exists in TrueGround yet, so runtime boundary checks cannot honestly be reported as executed in this lot.

## Current status

`READY FOR REVIEW`

This contract is sufficient to guide the next implementation lot without silently creating a shared multi-tenant runtime or contaminating IAmina Core.
