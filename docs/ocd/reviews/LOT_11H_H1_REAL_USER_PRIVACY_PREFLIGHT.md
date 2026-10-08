# LOT11-H H1 — Real-User Privacy & Operational GO/NO-GO Evidence Ledger

Date: 2026-10-08
Repository: `hraaaaf/trueground`
Scope: pre-participant review only; no product-runtime change and no permission to recruit or expose a volunteer.
Baseline technical HEAD: `1c432f481d3cb00244c690c66ea745d63d6f55f7`
Review verdict: **TECHNICAL SYNTHETIC PASS / REAL-PARTICIPANT NO-GO**

## GOAL → SUCCESS → PROOF

**Goal:** distinguish code/public-document proof from external/account/jurisdiction/human approvals for 1–3 supervised adults.

**Success:** ALL required real-user gates below have dated evidence reviewed and accepted by the Product Owner, and the exact participant build has green non-regression. Any unknown remains NO-GO.

**Proof:** GitHub Actions runs + precise repo paths + real Groq organization Data Controls evidence + approved legal/data/incident records. **Never upload participant text, identifiers, confessions, chat transcripts, secrets or tokens to GitHub/Notion.**

## VERIFIED ON BASELINE (NOT REAL-USER PERMISSION)

| Gate | Evidence | Verdict / limitation |
| --- | --- | --- |
| Exact-head offline package | Actions `37294735361` on `1c432f481d3c...`: success, all jobs/steps | PASS at baseline |
| Minimal live provider, synthetic only | Actions `37294735411` on same SHA: success; targeted context via actual server handler/guard, bounded to exactly 2 synthetic calls | PASS at baseline; not real-data authorization |
| Raw live reviewer artifact absent | Same run: sanitize-only metrics artifact, raw reviewer evidence deleted and absence asserted | PASS in H1 CI; other platform logs not assessed |
| Provider endpoint and model | `api/conversation.mjs`: `https://api.groq.com/openai/v1/chat/completions`, model `openai/gpt-oss-120b` | Code-confirmed |
| Key and data shape | `api/conversation.mjs`: reads server `process.env.Llm_Key`; validates 1,200-char message + max 4 context messages; no browser-side key | Code-confirmed, actual deployment secrets/scope not inspected |
| Client transport | `lib/conversation/conversation_server_transport_web.dart`: same-origin `/api/conversation` POST; `lib/conversation/conversation_server_transport_stub.dart` rejects unsupported transport | Code-confirmed |
| Memory footprint | `lib/conversation/conversation_runtime.dart`: in-memory bounded 4-message provider context, reset method; `lib/conversation/conversation_screen.dart`: current screen's in-memory messages | No persistence visible in these files; not a production logging audit |
| Handler raw-content logging | `api/conversation.mjs`: no direct console/request-body logging; `cache-control: no-store` on its responses | Partial PASS (handler only); host/CDN/telemetry/error/crash dashboards remain uninspected |
| Fail-closed / safety | `api/conversation.mjs` maps provider errors to 502, and Flutter runtime guard rejects unsafe model output; LOT11-F/G regressions green | PASS on synthetic tests, not exhaustive human proof |

## PUBLIC PROVIDER FACTS — NOT ACCOUNT ATTESTATION

- Groq publicly states standard inference is not normally stored, but inputs/outputs may be logged for reliability/abuse for up to 30 days, potentially longer if legally required.
- Groq permits ZDR in organization Data Controls, globally or on eligible features; inference `/openai/v1/chat/completions` is ZDR eligible. Usage metadata still persists, but is described as excluding customer content.
- Groq publishes a DPA and US location for retained data, and refers to contractual mechanisms for some transfers.
- **None of this proves TrueGround's actual Groq organization ZDR switch, selected project/key route, contractual acceptance, or legal applicability.**

Public primary references (rechecked 2026-10-08):
- https://console.groq.com/docs/your-data
- https://console.groq.com/settings/data-controls
- https://console.groq.com/docs/legal/customer-data-processing-addendum

## HARD-GATE EVIDENCE STILL REQUIRED

| ID | External/human item | Minimum acceptance proof | Current |
| --- | --- | --- | --- |
| H1-P01 | Identify actual Groq organization/project/key owner | Authorized owner records non-secret org/project identifiers and confirms which project owns the credential used by TrueGround | OPEN |
| H1-P02 | ZDR actually ON for eligible inference path | Dated admin-view evidence from https://console.groq.com/settings/data-controls; confirm effective scope, no exclusion/override, no raw inputs/outputs in monitoring. **Redact secrets, billing or member data.** | OPEN |
| H1-P03 | Features/endpoint | Confirm actual deployment matches inspected `chat/completions`, no batch/files/fine-tuning/provider memory, no tools | CODE PASS / RUNTIME OPEN |
| H1-P04 | DPA, subprocessor list and geographic transfer | Review current DPA, vendor/subprocessor list, intended participant jurisdiction, host/provider transfer routes; obtain relevant legal/privacy sign-off | OPEN |
| H1-P05 | Lawful basis and filings for participant jurisdiction | Authorized legal/privacy reviewer records which rules, notices, registration/filing/transfer requirements apply; obtain approvals **before** real data processing where required | OPEN |
| H1-P06 | Actual hosting and logging | Validate production/staging host, edge/request logs, crash telemetry, analytics, error collection, retention/exports; no raw prompts/completions; review exact build | OPEN |
| H1-P07 | Structured notes | PO chooses approved encrypted location, access roles, deletion owner, realistic retention and deletion procedure; no raw chat, no GitHub/Notion participant records | OPEN |
| H1-P08 | Facilitator / incident | Named facilitator and named incident responder, human/local procedure and contact method appropriate to session jurisdiction; no unsupported clinical crisis protocol | OPEN |
| H1-P09 | Consent & authorization | Exact session fields completed, notice understood, adult participation, PO explicit authorization for *real* supervised H1, build and exact-head gate fixed | OPEN |

A public privacy policy, a green CI, a synthetic test, or a non-identifying-looking chat is **not** sufficient to mark these as passed.

### Conditional Morocco jurisdiction branch — not an assumption

If the H1 session's applicable jurisdiction is **Morocco**, the CNDP publishes rules concerning notification/authorization for sensitive or health-related personal-data processing and international transfers. Determine whether the actual H1 data and controller/processor arrangements fall within these rules with a qualified privacy/legal reviewer; **do not infer that consent alone settles every filing requirement** or that ZDR removes processing/transfer.

Official CNDP references (accessed 2026-10-08):
- https://www.cndp.ma/notifier-un-traitement/
- https://www.cndp.ma/conditions/
- https://www.cndp.ma/transfert-de-donnees-a-letranger/

If jurisdiction differs, replace this branch with verified rules applicable to the actual session. The participant jurisdiction is currently **UNKNOWN**.

## PRODUCT OWNER CHOICES REQUIRED — NOT YET APPROVED

**OPTION A — recommended:** de-identified structured notes only, stored in a PO-designated encrypted local vault with restricted access and a documented deletion owner; candidate upper limit 30 days. No sensitive verbatim content.

**OPTION B:** de-identified structured notes in an access-controlled, explicitly approved encrypted workspace with the same deletion/retention limits; approve vendor/hosting and data transfer separately.

**Impact:** both need an approved location, lawful processing basis, access control, deletion test, consent wording and named owner. The 30-day limit is a *proposal*, not a factual policy or a granted approval.

For human incident/escalation, choose a **named local responder and contact plan** tailored to the participant/session location; no AI-generated clinical intervention protocol is authorized.

## HOW TO CLOSE H1-P01/H1-P02 WITHOUT SHARING SECRETS

1. Authorized Groq admin opens https://console.groq.com/settings/data-controls in the organization actually used by TrueGround.
2. Confirm ZDR applies to the used `chat/completions` inference endpoint. Capture current organization/project *context* and effective ZDR setting (not API keys).
3. Share only a redacted screenshot or a signed/dated admin attestation. The reviewer must ensure the attestation corresponds to the **real** credential routing, not another Groq organization.
4. Verify host logging and participant jurisdiction separately; ZDR is provider-side retention only.

## DECISION

**H1 TECHNICAL PACKAGE:** PASS at baseline `1c432f...`; rerun exact-head offline CI after this documentation commit.

**REAL HUMAN H1:** **NO-GO**, pending H1-P01...P09 (except proven code-only subfields).

**NEXT:** collect concrete account/admin evidence plus participant jurisdiction; obtain PO decisions on note storage, incident owner and real participant authorization; repeat GO/NO-GO review. No merge, deploy, production config/data modification or participant exposure is authorized by this document.
