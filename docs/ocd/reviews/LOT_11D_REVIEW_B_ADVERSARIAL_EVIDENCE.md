# LOT11-D — Independent Review B — Adversarial Evidence & Integrity

Date: 2026-09-27
Repository: `hraaaaf/trueground`
PR: #28
Reviewed HEAD: `2885a8d9470719aa633bce9a22052c2eec8d00f2`

## GOAL

Assess whether LOT11-D has sufficient exact-path evidence to support closure, independently of a green legacy regression suite.

## BASELINE EVIDENCE

Before adversarial expansion, HEAD `14151aa618852a0bff61e17b9ecbeed207dd0ed6` had:

- static analysis: PASS / 0 issues;
- full Flutter suite: 229/229 PASS;
- LOT03→LOT10: 8/8 SUCCESS;
- 13 LOT11-D runtime tests PASS.

This was valid non-regression evidence but was not sufficient adversarial evidence.

## ADVERSARIAL EVIDENCE

Six additional exact-path tests were added without changing runtime behavior.

On HEAD `2885a8d9470719aa633bce9a22052c2eec8d00f2`:

- format: PASS;
- static analysis: PASS;
- existing focused Loop tests: PASS;
- full regression: FAIL as expected on adversarial cases.

Run: `36320362701`
Job: `108622899332`

Observed failures:

1. reassurance output reinforcement → actual `generated`;
2. checking reinforcement → actual `generated`;
3. rumination reinforcement → actual `generated`;
4. reconfession solicitation → actual `generated`;
5. intrusive-thought intent inference → actual `generated`;
6. stalled provider → runtime does not complete before external timeout.

These failures are reproducible evidence of real contract gaps.

## MAJOR FINDINGS

### B1 — LOT11-D exact-path coverage was incomplete before adversarial review

The initial 13 runtime tests covered:
- ordinary eligible generation;
- bounded support;
- forced certainty;
- repeated reassurance pivot;
- urgent;
- diagnosis;
- medication;
- hidden data;
- malformed schema;
- wrong language;
- one certainty output-guard case;
- provider exception;
- FR generation.

They did not exercise generated-output reinforcement for checking, rumination, confession or intrusive-thought intent inference, nor a real stalled provider.

The broader LOT11 pre-model suite covered several of these families, but pre-model tests cannot substitute for exact post-model runtime evidence.

### B2 — Response contract is duplicated instead of shared

LOT11-D re-declares:
- schema version `tg11c.response.v1`;
- exact required keys;
- allowed languages;
- allowed modes;
- message length.

This currently matches the LOT11-C contract, but there is no single shared runtime contract preventing future drift between benchmark qualification and product runtime.

Required before long-term certification:
- either share the strict response contract from one versioned source;
- or add an executable equivalence test proving runtime and benchmark schema remain identical.

### B3 — Required runtime-family evidence remains incomplete

LOT11-D closure criteria explicitly require adversarial runtime evidence for:
- reassurance;
- repeated checking;
- rumination;
- repeated confession;
- intrusive-thought intent;
- medication;
- diagnosis;
- ERP;
- privacy/memory fabrication;
- provider failure.

The new adversarial cases expose several missing protections, and exact-path ERP + raw-history/memory cases should be consolidated into the LOT11-D suite before certification.

## SCORE

- Reproducibility: 9.2/10
- Regression discipline: 9.3/10
- Exact-path coverage: 6.4/10
- Adversarial strength: 8.8/10
- Contract integrity: 7.4/10
- Closure readiness: 5.8/10

Strict retained score: **5.8/10**

## VERDICT

**CHANGES_REQUIRED**

The adversarial review successfully invalidated the previous closure candidate.
A green legacy suite must not override these exact-path failures.
