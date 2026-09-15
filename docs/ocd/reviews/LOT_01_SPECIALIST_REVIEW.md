# LOT 01 — Specialist Review Ledger

Status: COMPLETE FOR LOT 01 INSPECTION ARTIFACT
Date: 2026-09-15

Artifact reviewed:

`docs/ocd/lots/LOT_01_IAMINA_CORE_INSPECTION.md`

Mandatory roles from `08_SPECIALIST_REVIEW_MATRIX.md` for Phase 1 / existing-system inspection:

- ARCHITECTURE_AGENT
- DATA_PRIVACY_SECURITY_AGENT

## Review method limitation

No independent sub-agent execution interface is available in this working window. To avoid inventing a reviewer that did not actually run, the reviews below were performed as explicit separate adversarial review passes using the mandatory specialist rubrics and the inspected repository evidence.

This is sufficient to challenge the documentation artifact for this inspection-only lot, but it must not be misrepresented as external human review, clinical review, regulatory review or a separate model instance.

## ARCHITECTURE_AGENT

### Challenge prompt

**Find the strongest reason this inspection should NOT be approved.**

### Strongest rejection argument

The existing IAmina module architecture could be mistaken for the target TrueGround client architecture. `PatientModule`, `ModuleRegistry`, frontend `ModuleRegistry`, and companion persistence ports were built around a single IAmina product/single-module deployment trajectory, not proven independent client tenancy.

If LOT 01 had concluded “just add OCD as another module,” the inspection would be architecturally unsafe and inconsistent with the product-owner clarification that diabetes and OCD are different clients.

### Evidence checked

- `backend/core/contracts/manifest.py`
- `backend/core/registry.py`
- `backend/diabetes/manifest.py`
- `backend/diabetes/apps.py`
- `backend/.importlinter`
- `backend/core/companion/ports.py`
- `backend/core/contracts/domain_context.py`
- `backend/core/contracts/capabilities.py`
- `backend/core/llm_gateway.py`
- `frontend/lib/modules/module_config.dart`
- `frontend/lib/modules/module_registry.dart`
- `frontend/lib/modules/diabetes_module.dart`
- `docs/architecture/ARCHITECTURE.md`
- `docs/architecture/module-contract-spec.md`
- IAmina inspected revision: `715e2cc5108992f1347e93a115b0c71c90f47914`

### Findings

1. The Core→condition dependency boundary is real and enforced with import-linter.
2. Backend module manifest/registry seams are real.
3. Frontend module configuration seams are real.
4. Companion persistence adapters are globally registered singletons, which matches the current single-module posture but is not tenant/client routing.
5. Current frontend module registry statically imports diabetes.
6. Existing `PatientModule` activation models one patient activating modules inside the same platform identity.
7. No inspected first-class tenant/client isolation object was established.
8. The LOT 01 report explicitly distinguishes reusable module seams from separate-client tenancy instead of hiding that mismatch.

### Verdict

`PASS_WITH_NOTES`

### Blocking note carried into LOT 02

Do not implement OCD as a second consumer module inside the existing diabetes app merely because the registries exist.

LOT 02 must decide the separate-client isolation/deployment contract first.

---

## DATA_PRIVACY_SECURITY_AGENT

### Challenge prompt

**Find the strongest privacy/security reason this inspection should NOT be approved.**

### Strongest rejection argument

If TrueGround and diabetes were placed in one shared runtime/database using current module activation alone, the inspected architecture does not yet provide evidence of a first-class client/tenant boundary across identity, memory, conversation persistence, prompts/config, analytics and provider policy. Treating module activation as tenancy could create cross-client data leakage risk.

### Evidence checked

- `backend/core/models/patient.py`
- `backend/core/models/patient_module.py`
- `backend/core/api/v1/modules.py`
- `backend/core/ai_egress.py`
- `backend/core/ai_processor_policy.py`
- `backend/core/companion/ports.py`
- `backend/core/account_hooks.py` via current architecture/module wiring
- `backend/core/tests/` inventory for AI-egress/account guard coverage
- IAmina security reviewer contract: `.agents/security-auditor.md`

### Findings

1. Shared patient identity/consent primitives are substantial and potentially reusable.
2. AI egress is centrally governed by patient/purpose/modality and explicit consent.
3. Purpose/modality allowlisting is hard-coded in Core today.
4. Memory/conversation persistence resolution is global, not client-aware.
5. `PatientModule` does not itself establish commercial-client/tenant isolation.
6. No runtime/data modification was performed in LOT 01.
7. The inspection correctly refuses to claim shared-runtime isolation and pushes that decision into LOT 02.

### Verdict

`PASS_WITH_NOTES`

### Blocking note carried into LOT 02

Before any shared-runtime approach can be accepted, demonstrate tenant/client scope for:

- auth/authorization;
- database access;
- memory and conversation retrieval;
- provider configuration and egress policy;
- prompts/config/evals;
- logs/analytics;
- deletion/export/retention.

If those guarantees are not deliberately introduced and tested, the safer V1 architecture is a separate TrueGround deployment/data plane reusing generic Core code rather than sharing patient/module state.

---

## Final review status

| Reviewer | Result | Blocking LOT 01? | Carries requirement to LOT 02? |
|---|---|---:|---:|
| ARCHITECTURE_AGENT | PASS_WITH_NOTES | No | Yes |
| DATA_PRIVACY_SECURITY_AGENT | PASS_WITH_NOTES | No | Yes |

LOT 01 inspection artifact may proceed to handover.

This review does **not** approve a specific LOT 02 architecture option and does **not** authorize implementation, merge, deployment or real-data changes.
