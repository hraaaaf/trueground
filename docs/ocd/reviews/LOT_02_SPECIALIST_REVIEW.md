# LOT 02 — Specialist Review Ledger

Status: COMPLETE FOR LOT 02 ARCHITECTURE CONTRACT
Date: 2026-09-16

Artifact reviewed:

`docs/ocd/lots/LOT_02_CLIENT_ISOLATION_CAPSULE_CONTRACT.md`

Mandatory roles applied:

- ARCHITECTURE_AGENT
- DATA_PRIVACY_SECURITY_AGENT
- OCD_SAFETY_AGENT
- QA_NON_REGRESSION_AGENT

## Review method limitation

No independent sub-agent execution interface is available in this working window.

To avoid inventing a reviewer that did not run, the roles below were executed as separate explicit adversarial review passes against the live GitHub evidence and the LOT 02 artifact.

This is not external human review, clinical review, regulatory review or an independently executed second model. Final verification still belongs to the appropriate review/product-owner gate.

---

## ARCHITECTURE_AGENT

### Challenge prompt

**Find the strongest reason this architecture contract should NOT be approved.**

### Strongest rejection argument

The phrase “reuse shared IAmina Core” could hide a false assumption that a clean, independently versioned Core package already exists.

The inspected source contradicts that assumption:

- `backend/amina/settings.py` directly installs `diabetes.apps.DiabetesConfig`;
- the middleware stack contains Diabetes middleware;
- `frontend/lib/modules/module_registry.dart` statically imports/registers `diabetesModule`;
- `ModuleRegistry` and companion persistence registries are process-global;
- TrueGround currently has no runtime/package tree at all.

If LOT 02 had prescribed “import IAmina as-is” or silently introduced a package/submodule that was never inspected, it would create architecture fiction and likely package Diabetes into TrueGround.

### Evidence checked

Current IAmina revision:

`4e7b04a3387da68374e00ab858e63b914faa1884`

Files:

- `backend/core/contracts/manifest.py`
- `backend/core/registry.py`
- `backend/.importlinter`
- `backend/core/companion/ports.py`
- `backend/core/ai_egress.py`
- `backend/core/llm_gateway.py`
- `backend/llm/factory.py`
- `backend/diabetes/apps.py`
- `backend/amina/settings.py`
- `frontend/lib/modules/module_config.dart`
- `frontend/lib/modules/module_registry.dart`

### Findings

1. The contract correctly separates reusable generic primitives from the current Diabetes application composition.
2. It explicitly rejects using `amina/settings.py` unchanged for TrueGround.
3. It explicitly rejects using the current Flutter `ModuleRegistry` unchanged.
4. Process-global registries are allowed only because Option A provides a separate process per client.
5. It defines build-time/source-version reuse and forbids runtime dependence on the Diabetes deployment.
6. It does not pretend a Core package already exists.
7. It deliberately defers the concrete packaging mechanism until a later implementation lot inspects the chosen bootstrap.
8. It defines the immutable Git SHA as the version identity instead of allowing a floating `main` dependency.
9. The inspected SHA `4e7b04a3…` must still be treated as a LOT 02 evidence baseline; any later implementation window must re-check current IAmina `main` before selecting/advancing its immutable pin.

### Verdict

`PASS_WITH_NOTES`

### Non-blocking notes carried forward

- Do not interpret the LOT 02 inspected SHA as permission to skip the next-window freshness check.
- The future client-composition implementation must be proven from actual files rather than invented from this contract.
- If a Core change becomes necessary, it requires its own IAmina change/review and Diabetes non-regression proof.

---

## DATA_PRIVACY_SECURITY_AGENT

### Challenge prompt

**Find the strongest privacy/security reason this architecture contract should NOT be approved.**

### Strongest rejection argument

“Separate deployment” is not sufficient if the two clients still share hidden state such as database credentials, auth issuer/project, Redis/session state, object storage, provider secrets, analytics/log sinks, vector/search indexes, backups or deletion hooks.

A visually separate app could still leak data if those lower-level planes are shared.

### Evidence checked

- `backend/core/models/patient.py`
- `backend/core/models/patient_module.py`
- `backend/core/api/v1/modules.py`
- `backend/core/api/v1/account.py`
- `backend/core/account_hooks.py`
- `backend/core/companion/ports.py`
- `backend/core/ai_egress.py`
- `backend/llm/factory.py`
- `backend/amina/settings.py`
- canonical `docs/ocd/05_DATA_PRIVACY_SECURITY.md`

### Findings

1. The contract explicitly prohibits a shared application database and shared user-content tables.
2. It requires separate credentials and data-plane boundaries for database, auth, cache/session state, storage, search/vector indexes where used, provider configuration and logging/analytics.
3. It rejects `PatientModule` as a client/tenant-isolation mechanism.
4. It requires separate user/account namespace and session/token signing/configuration.
5. It requires TrueGround-owned memory/conversation adapters and storage.
6. It defines negative cross-client access tests once runtime infrastructure exists.
7. It keeps deletion/export/retention responsibility client-owned and requires client-specific deletion proof.
8. It forbids borrowing Diabetes credentials as a failure fallback.
9. It explicitly forbids real Diabetes user data as TrueGround test fixtures.

### Verdict

`PASS_WITH_NOTES`

### Non-blocking notes carried forward

- When infrastructure is later selected, “separate project/database/bucket/index” must be proven by configuration/credential evidence without printing secrets.
- Logs/analytics must also satisfy the canonical rule against routine raw OCD conversation/journal content.
- Backup/restore and provider-retention behavior remain future implementation/privacy gates; the contract correctly does not claim they exist today.

---

## OCD_SAFETY_AGENT

### Challenge prompt

**Find the strongest OCD-safety reason this architecture contract should NOT be approved.**

### Strongest rejection argument

A shared-Core architecture can accidentally move reassurance-seeking detection, checking/rumination logic, repetition semantics or ERP behavior into generic infrastructure in the name of “reuse.”

That would contaminate IAmina Core with OCD-specific behavior and could also make future Core changes alter OCD safety behavior without the OCD eval gate.

### Evidence checked

- canonical `docs/ocd/03_OCD_CLINICAL_SAFETY.md` boundaries as carried by the canonical review matrix/roadmap
- `docs/ocd/04_IAMINA_CAPSULE_ARCHITECTURE.md`
- `docs/ocd/08_SPECIALIST_REVIEW_MATRIX.md`
- `backend/core/contracts/capabilities.py` finding from LOT 01
- `backend/core/llm_gateway.py`
- `backend/core/ai_egress.py`
- LOT 02 contract sections on Core/OCD ownership, AI egress, prompts/evals and OCD safety ownership

### Findings

1. Reassurance, checking, rumination and repetition semantics remain explicitly OCD-owned.
2. Compulsion Firewall policy remains explicitly OCD-owned.
3. ERP/practice behavior remains OCD-owned and outside this lot.
4. OCD prompts, policies, eval datasets and thresholds are explicitly outside Core.
5. The generic LLM gateway/provider layer is not allowed to contain OCD-specific safety behavior.
6. New OCD-specific egress-purpose constants are explicitly not authorized inside generic Core.
7. Failure of OCD policy is not allowed to fall back to unrestricted generic chat.
8. No clinical claim, diagnosis, treatment promise or ERP algorithm is introduced by this lot.

### Verdict

`PASS_WITH_NOTES`

### Non-blocking clarification carried forward

Any reference to generic “loop/rate” infrastructure must be interpreted narrowly as domain-neutral transport/rate-control or policy-hook machinery. Recognition of an OCD loop, reassurance seeking, compulsive checking or rumination is always capsule-owned and requires OCD safety/eval review.

---

## QA_NON_REGRESSION_AGENT

### Challenge prompt

**Find the strongest reason the stated LOT 02 result does not match the observable repository change.**

### Strongest rejection argument

Architecture documentation could claim isolation while accidentally modifying IAmina runtime code or TrueGround runtime files in the same branch, making the “contract-only” non-regression statement false.

### Evidence checked

Before specialist review:

- LOT 02 base: `lot/01-iamina-core-inspection` at `c5380cae770c11b958cb4a0a54152da40030df71`
- LOT 02 branch after first contract commit: `5c15bae48278879dbfc6759fecaabfd08888ae7a`
- branch comparison: ahead 1 / behind 0
- changed files: only `docs/ocd/lots/LOT_02_CLIENT_ISOLATION_CAPSULE_CONTRACT.md`
- additions: 592 / deletions: 0

IAmina source repository was read only; no IAmina branch/file was modified by LOT 02.

### Findings

1. The LOT 02 implementation is documentation-only so far.
2. No runtime source, schema, DB, dependency or production config change is present.
3. IAmina current source was re-inspected at `4e7b04a3…` rather than relying on the LOT 01 SHA.
4. The four IAmina commits since LOT 01 do not modify the inspected Core/backend contract files.
5. Runtime isolation checks are correctly defined as future executable gates rather than falsely reported as passing today.

### Verdict

`PASS`

### Limitation

No full IAmina test suite was rerun because LOT 02 made no IAmina source change. No TrueGround runtime tests exist because the repository has no runtime implementation yet.

---

## Final review status

| Reviewer | Result | Blocking LOT 02? | Carries requirement forward? |
|---|---|---:|---:|
| ARCHITECTURE_AGENT | PASS_WITH_NOTES | No | Yes |
| DATA_PRIVACY_SECURITY_AGENT | PASS_WITH_NOTES | No | Yes |
| OCD_SAFETY_AGENT | PASS_WITH_NOTES | No | Yes |
| QA_NON_REGRESSION_AGENT | PASS | No | Yes |

## Final specialist conclusion

No material contradiction with approved Option A was found.

The contract is suitable for `READY FOR REVIEW` as an architecture artifact because it:

- distinguishes source reuse from current Diabetes app composition;
- keeps runtime/data/auth/secrets/memory separate;
- keeps OCD safety behavior in the capsule;
- does not invent an existing shared package or implementation;
- defines future enforcement checks without claiming they have run against non-existent runtime code.

This review does **not** authorize merge, deployment, IAmina Core modification, production data changes, or LOT 03 execution.
