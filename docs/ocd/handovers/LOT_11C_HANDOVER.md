# LOT11-C — Closeout / Human Gate

Date: 2026-09-27
Repository: `hraaaaf/trueground`
PR: #27
Certified evidence HEAD: `96f4b78aa04c16a38eff885e5eecca7a1a453ec1`
Provider: Groq `openai/gpt-oss-120b`
Rubric: `tg11c.behavioral.v4-provider-qualification-2026-09-26`

## GOAL

Qualify Groq as the bounded generation provider candidate for TrueGround LOT11 without transferring OCD safety authority to the model.

## SUCCESS EVIDENCE

GitHub Actions run: `36278282467`

Provider qualification:
- isolated fixtures: 20/20
- EN→FR→EN sequence calls: 9/9
- total qualification calls: 29/29
- provider failures: 0
- structured-output failures: 0
- language failures: 0
- URR/RRE/CAR/RER/ITI/MED/DIAG/ERP/PRIV/CARE: 0
- behavioral helpfulness: 93.1% (threshold >= 90%)
- production output-guard bridge: PASS
- runtime guard rejections: 0
- rate-limit retries: 0
- mean latency: 961.8 ms
- p95 latency: 1504 ms
- estimated list-price cost: USD 0.00759165

Final aggregate artifact:
- artifact id: `10917734230`
- digest: `sha256:3335c75b81bd016a05fb8ddf54c2790518e72c0382e31bbeb4b9ce27bd5d710e`

Exact-head non-regression:
- LOT03: SUCCESS
- LOT04: SUCCESS
- LOT05: SUCCESS
- LOT06: SUCCESS
- LOT07: SUCCESS
- LOT08: SUCCESS
- LOT09: SUCCESS
- LOT10: SUCCESS
- LOT11-C: SUCCESS

## HUMAN GATE

Product Owner explicit human gate: APPROVED on 2026-09-27.

Decision:
LOT11-C is administratively CLOSED for roadmap progression.

This approval does not mean every evidence limitation has been eliminated. It means the Product Owner accepts the residual evidence gaps below for progression to LOT11-D.

## ACCEPTED RESIDUAL EVIDENCE GAPS

1. The live Groq benchmark remains a direct Python provider harness followed by the real Dart `DeterministicConversationOutputGuard`; it is not yet a single end-to-end production-path proof through `ConversationSafetySession → provider adapter → output guard`.

2. Sanitized CI artifacts intentionally exclude raw completions. An ephemeral, independent human review mechanism for synthetic provider outputs has not yet been implemented.

These items must remain visible. They must not be rewritten as resolved findings.

The first item is a natural verification target for LOT11-D runtime wiring.
The second remains a review/evidence hardening item before broader human/clinical safety certification.

## ARCHITECTURAL CONSTRAINTS CARRIED FORWARD

- IAmina Core and OCD capsule remain architecturally separate.
- Deterministic routing remains the safety authority.
- Provider never owns crisis routing, reassurance/checking/rumination/confession classification, diagnosis, medication decisions, autonomous ERP, memory truthfulness, or fail-open behavior.
- Provider secrets remain server-side / CI-only and must not be embedded in the client.
- No real user data is authorized by this closeout.
- No merge or deployment is authorized by this closeout.
- No production DB/data/config mutation is authorized.

## STATE

LOT11-C: CLOSED FOR ROADMAP PROGRESSION
Merge: NOT AUTHORIZED
Deployment: NOT AUTHORIZED
Next sub-lot: LOT11-D — Bounded Conversational Runtime
