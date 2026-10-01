# LOT11-D — Independent Review B V2 — Adversarial Evidence & Integrity

Date: 2026-09-27
Repository: `hraaaaf/trueground`
PR: #28
Reviewed HEAD: `3d67930a204cfe1dc9bfee75e318866a1d0a1e2f`
Base: `50d6acd4e406ed6dabe04c0713eb1643df011494`

## GOAL

Re-assess LOT11-D closure evidence after hardening, independently of legacy green CI.

## EXACT-HEAD EVIDENCE

GitHub Actions on `3d67930a204cfe1dc9bfee75e318866a1d0a1e2f`:

- LOT03 run `36324918586` — SUCCESS
- LOT04 run `36324918518` — SUCCESS
- LOT05 run `36324918550` — SUCCESS
- LOT06 run `36324918566` — SUCCESS
- LOT07 run `36324918520` — SUCCESS
- LOT08 run `36324918623` — SUCCESS
- LOT09 run `36324918576` — SUCCESS
- LOT10 run `36324918509` — SUCCESS

Full Flutter suite:
**244 tests PASS**.

Static analysis:
PASS.

## PREVIOUS FINDINGS

### B1 — Exact-path runtime coverage incomplete

CLOSED for LOT11-D scope.

Runtime tests now cover:
- eligible generation;
- deterministic bypass;
- repeated reassurance;
- repeated checking;
- repeated rumination;
- repeated confession;
- urgent/human gate;
- diagnosis;
- medication;
- autonomous ERP;
- privacy boundary;
- raw-history truthfulness;
- fabricated memory output;
- malformed schema;
- wrong language;
- provider exception;
- stalled provider timeout;
- rejected provider output;
- EN/FR;
- safe false-positive controls.

### B2 — LOT11-C response contract duplicated without drift proof

CLOSED.

Runtime contract constants remain local to product code, but an executable equivalence test reads `tool/lot11c/lot11c_response.schema.json` and checks:
- required keys;
- schema version;
- max message length;
- languages;
- modes;
- additional properties disabled.

This provides executable drift detection without importing tool-only code into product runtime.

### B3 — Required runtime-family evidence incomplete

CLOSED for the required LOT11-D families.

The previously failing six adversarial cases all pass after hardening.

## CARRIED RESIDUAL EVIDENCE GAP

### R1 — No single live server-side provider transport chain is proven in this repository

NOT RESOLVED.

LOT11-D proves the exact product runtime path through an injectable `ConversationProviderAdapter`, including timeout, exception, schema, language and output-guard behavior.

However, this repository still has no concrete server-side Groq/network adapter. Therefore it does **not** prove a single live chain:

`ConversationSafetySession → real provider transport → provider response → production output guard`.

Adding a direct Groq HTTP client to Flutter would violate the current secret/isolation architecture, so this review does not recommend doing that merely to make the evidence green.

This residual must remain explicit until a server-side provider bridge is implemented and tested.

### R2 — Ephemeral independent human review of raw synthetic completions

Still absent by design and not claimed as resolved.

This remains suitable for later human/clinical review hardening (LOT11-G) rather than the Flutter runtime layer.

## INTEGRITY ASSESSMENT

The current evidence is materially stronger than the original 229-test candidate because it includes adversarial failures that first reproduced the defects and then passed only after targeted fixes.

No legacy green suite is being used to erase the earlier failures.

## SCORE

- Reproducibility: 9.7/10
- Regression discipline: 9.8/10
- Exact-path product-runtime coverage: 9.6/10
- Adversarial strength for LOT11-D scope: 9.5/10
- Contract integrity: 9.6/10
- Live provider-transport evidence: 8.0/10

Strict retained score: **9.3/10**

## VERDICT

**PASS_WITH_NOTES**

The LOT11-D product runtime is evidence-complete for its provider-neutral client boundary.

The historical live-provider-chain residual is **not** closed and must not be described as closed.

A human architecture/product gate is required to decide whether:
- LOT11-D closes with R1 carried forward to the future server-side provider integration; or
- LOT11-D scope is expanded to build and prove that server-side transport now.
