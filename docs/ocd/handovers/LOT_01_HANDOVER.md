# HANDOVER — TrueGround OCD / LOT 01

Status: READY FOR REVIEW
Date: 2026-09-15

## 1. Identity

- Project: TrueGround OCD
- Repository: `hraaaaf/trueground`
- Lot: `LOT 01 — IAmina Core Inspection`
- Working branch: `lot/01-iamina-core-inspection`
- Parent/base branch for this lot: `docs/ocd-canonical-foundation`
- Parent/base SHA at lot start: `5921c4b5b89426a41d8100919511593cdcbc40b9`
- Repository HEAD immediately before this handover commit: `9bf4ee9e13141b993699b376645a4be72b9839a9`
- Draft PR: `#2 — docs: LOT 01 inspect IAmina Core for TrueGround reuse`
- PR base: `docs/ocd-canonical-foundation`
- PR state at handover preparation: OPEN / DRAFT / NOT MERGED
- Merge authorization: **NOT GRANTED**
- Deployment authorization: **NOT GRANTED**

Important: committing this handover advances the branch HEAD beyond the SHA above. The next window must re-check the live branch/PR state before acting, per `09_LOT_WINDOW_HANDOVER_PROTOCOL.md`.

## 2. GOAL / SUCCESS / PROOF

### GOAL

Inspect the real IAmina implementation and determine which existing machine-level primitives are genuinely reusable for a separate TrueGround/OCD client, without inventing a new architecture or modifying runtime code.

### SUCCESS

- Current IAmina source and exact inspected revision identified: **met**.
- Backend/frontend module seams inspected from code: **met**.
- Reusable Core primitives separated from diabetes-owned logic: **met**.
- Material gaps between current IAmina module model and separate-client requirement documented: **met**.
- No premature OCD contract invented: **met**.
- Mandatory specialist review passes recorded: **met with notes/limitations**.

### PROOF

Primary artifact:

`docs/ocd/lots/LOT_01_IAMINA_CORE_INSPECTION.md`

Specialist review:

`docs/ocd/reviews/LOT_01_SPECIALIST_REVIEW.md`

Next-window prompt:

`docs/ocd/handovers/LOT_02_START_PROMPT.md`

Inspected IAmina source:

- Repository: `hraaaaf/IAMINA-MVP`
- Branch: `main`
- Inspected SHA: `715e2cc5108992f1347e93a115b0c71c90f47914`

## 3. What was done

LOT 01 inspected and documented:

- current IAmina stack and live product posture;
- backend `ModuleManifest` and `ModuleRegistry`;
- diabetes module startup registration;
- Core→diabetes import-linter boundary;
- chassis-owned patient/account identity and `PatientModule` activation;
- capability/authority contract;
- central AI egress/consent/minimization boundary;
- shared LLM gateway/provider abstraction;
- `DomainContext` module→chassis contract;
- companion memory/conversation persistence ports;
- frontend Flutter toolchain;
- frontend `ModuleConfig` / `ModuleRegistry`;
- current diabetes module frontend packaging;
- existing test inventory relevant to AI egress/account guardrails;
- release repository existence as a separate small release/control artifact, not treated as the primary source implementation.

The lot identified the key architecture mismatch:

> Current IAmina modularity models one product/platform identity with condition modules; TrueGround/OCD is a separate client/product.

No inspected code proved a first-class commercial client/tenant boundary across auth, data, memory, provider config, prompts/evals and analytics.

## 4. What was NOT done

LOT 01 did **not**:

- modify `hraaaaf/IAMINA-MVP`;
- create an OCD backend module;
- create an OCD Flutter module;
- change IAmina Core;
- change auth, DB, schemas or migrations;
- choose separate deployment vs shared tenant-aware runtime;
- define exact OCD routes;
- define OCD persistence schema;
- define Loop/Compulsion Firewall algorithms;
- define ERP behavior;
- define crisis policy;
- choose an LLM/provider;
- deploy anything;
- merge any PR;
- touch real user data.

## 5. Files changed in TrueGround

LOT 01 branch adds:

- `docs/ocd/lots/LOT_01_IAMINA_CORE_INSPECTION.md`
- `docs/ocd/reviews/LOT_01_SPECIALIST_REVIEW.md`
- `docs/ocd/handovers/LOT_02_START_PROMPT.md`
- `docs/ocd/handovers/LOT_01_HANDOVER.md`

No runtime source files were changed.

## 6. Tests and non-regression

### Checks executed

- inspected IAmina `main` exact HEAD before drawing architecture conclusions;
- inspected canonical architecture/module contract documentation;
- inspected concrete backend module/registry/manifest code;
- inspected concrete frontend module config/registry code;
- inspected Core import-linter boundary;
- inspected central AI egress and LLM gateway code;
- inspected companion persistence ports;
- inspected auth/module activation models and endpoints;
- compared LOT branch against the canonical-foundation parent branch.

### Branch comparison before handover commit

- base: `docs/ocd-canonical-foundation`
- head: `lot/01-iamina-core-inspection`
- ahead: `3`
- behind: `0`
- changed files before handover: `3`, all documentation files

### CI/checks before handover commit

No GitHub Actions workflow run was associated with HEAD `9bf4ee9e13141b993699b376645a4be72b9839a9` at inspection time.

### Non-regression statement

Because LOT 01 modified only TrueGround documentation and did not change IAmina or TrueGround runtime code, no application behavior was altered by this lot.

No claim is made that IAmina's full test suite was re-run; source code was not modified in this lot.

## 7. Specialist review ledger

Canonical review artifact:

`docs/ocd/reviews/LOT_01_SPECIALIST_REVIEW.md`

| Reviewer | Verdict | Evidence | Unresolved note |
|---|---|---|---|
| ARCHITECTURE_AGENT | PASS_WITH_NOTES | inspection report + concrete Core/module files | existing module architecture must not be mistaken for separate-client tenancy |
| DATA_PRIVACY_SECURITY_AGENT | PASS_WITH_NOTES | identity/module/egress/memory inspection | shared runtime requires first-class client/tenant isolation proof |

Review-method limitation is explicitly documented: no separate sub-agent execution interface was available in the window, so the mandatory roles were executed as separate adversarial review passes rather than falsely claiming an independent model/human review.

No clinical/regulatory review was required because LOT 01 introduced no clinical behavior or claims.

## 8. Current risks / blockers

### R1 — Client isolation is not established

Current IAmina condition-module support is not evidence of safe multi-client tenancy.

### R2 — Companion persistence uses global singleton adapters

Current `SnapshotStore` / `ConversationStore` resolution fits the single-module posture but not a shared multi-client routing model without further design.

### R3 — AI egress purposes are hard-coded in Core

An OCD-specific purpose must not simply be inserted into generic Core without deciding the correct generic extension/configuration boundary.

### R4 — Frontend registry statically imports diabetes

TrueGround must not accidentally package diabetes screens/routes merely because the current Flutter registry does.

### R5 — `DomainContext` may be diabetes-shaped in places

Do not distort OCD behavior into KPI/trend fields solely for reuse.

## 9. Repository truth at handover preparation

### TrueGround canonical foundation

- PR #1: OPEN / DRAFT / NOT MERGED at LOT 01 start
- canonical branch SHA at LOT 01 start: `5921c4b5b89426a41d8100919511593cdcbc40b9`

### LOT 01

- PR #2: OPEN / DRAFT / NOT MERGED
- PR #2 base: `docs/ocd-canonical-foundation`
- pre-handover branch HEAD: `9bf4ee9e13141b993699b376645a4be72b9839a9`
- ahead/behind before handover commit: `3 / 0`
- CI runs observed for that HEAD: none

### IAmina source inspected

- `hraaaaf/IAMINA-MVP main`
- inspected HEAD: `715e2cc5108992f1347e93a115b0c71c90f47914`

These values are snapshots. LOT 02 must verify them again.

## 10. Next lot

Recommended and already within the approved roadmap:

**LOT 02 — TrueGround client isolation + OCD capsule contract**

Starter prompt:

`docs/ocd/handovers/LOT_02_START_PROMPT.md`

LOT 02 must first present the two architecture options and obtain explicit product-owner validation before any irreversible architecture change:

- OPTION A — separate TrueGround deployment/data plane reusing shared/versioned Core code;
- OPTION B — shared runtime with a first-class tenant/client isolation layer.

LOT 02 must not start in this window.

## Closeout

### Résultat
Real IAmina reusable seams have been inspected and separated from assumptions. The central separate-client mismatch is now explicit.

### Modifications
Documentation only, four LOT artifacts.

### Tests
Repository/code inspection, branch comparison and CI-state check. No source test suite rerun because no runtime source changed.

### Non-régression
No runtime, schema, DB, provider or production changes.

### Preuves
Inspection report, specialist review ledger, PR #2, exact inspected IAmina SHA and branch diff.

### Risques
Client isolation, singleton persistence resolution, hard-coded egress purposes, frontend diabetes packaging and partial DomainContext fit remain unresolved architecture inputs for LOT 02.

### État
`READY FOR REVIEW`

### Prochaine étape
Open a fresh window with `LOT_02_START_PROMPT.md`; re-check live repository state; decide the client-isolation architecture before writing OCD integration code.
