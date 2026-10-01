# LOT11-C — Independent Review B — Evaluation Integrity & Reproducibility

Date: 2026-09-26
Repository: hraaaaf/trueground
PR: #27
Reviewed HEAD: 157f88970b54db5fed93449232c67c2b7997452f

## GOAL
Independently test whether the LOT11-C provider benchmark is strong enough to support a provider decision without evaluator overfit or missing frozen requirements.

## EVIDENCE INSPECTED
- frozen LOT11-C start prompt thresholds and proof requirements
- exact 20-fixture × 3-repeat corpus
- Python scoring logic and CI threshold enforcement
- 60-call successful run 36236892327
- artifact digest sha256:3ab9c40c8098ef6748fdd0c7a8e872e1442ca06016237bb90c3319cc76e5712a
- exact-head regression workflows

## PASS FINDINGS
- 60/60 provider calls completed successfully on final automated run.
- schema failures = 0.
- language failures = 0.
- current critical lexical safety metrics = 0.
- current behavioral helpfulness = 93.33% against >=90% threshold.
- repeated-run stability is explicitly measured.
- latency, token counts, list-price estimate and retries are recorded.
- CI fails closed when a zero-tolerance metric is non-zero.

## BLOCKERS

### B1 — Helpfulness evaluator was changed after observing benchmark failures
The behavioral helpfulness scorer was materially changed after prior outputs produced 73.33% then 11.67%.
Even if the final rubric is reasonable, this creates evaluator-overfit risk.

Required:
- freeze an evaluation rubric before the next evidence run;
- version the rubric;
- rerun unchanged corpus after freeze;
- add independent blinded review on the frozen rubric.

### B2 — EN→FR→EN provider quality requirement is not exercised
The direct provider benchmark consists of isolated single-turn fixtures.
The pre-model Dart tests contain EN→FR→EN routing state, but the provider generation itself is not tested across an EN→FR→EN sequence.

Required:
- add synthetic multi-turn EN→FR→EN provider fixtures and measure language/state consistency.

### B3 — Exact provider model revision/fingerprint is not captured
Only model name openai/gpt-oss-120b is recorded.
The frozen proof asks for exact model/version; provider aliases may change.

Required:
- record sanitized provider-returned model id and system fingerprint/version when available.

### B4 — Reasoning-token behavior is not captured in the real benchmark
The benchmark records prompt/completion/total tokens but not provider reasoning token details, despite the frozen requirement “where observable”.

Required:
- capture reasoning token count/details when the API response exposes them; null is acceptable when not exposed.

### B5 — Frozen LOT11-A threshold traceability is incomplete
LANG and several safety families are explicitly summarized, but FAIL truthfulness, FP curated controls and the distinction between pre-model vs provider-layer evidence are not consolidated in one traceability matrix.

Required:
- create a threshold-to-proof matrix mapping every frozen metric to exact tests/runs/artifacts.

## SCORE
Coverage: 8.2/10
Methodology: 7.8/10
Reproducibility: 8.0/10
Stability evidence: 9.0/10
Cost/performance evidence: 9.2/10

Strict retained score: 7.8/10

## VERDICT
CHANGES_REQUIRED

The provider is promising, but the current evidence package is not yet sufficient for LOT11-C human certification.
