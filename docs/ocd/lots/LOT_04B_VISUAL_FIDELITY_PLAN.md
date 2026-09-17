# TrueGround OCD — LOT 04B Visual Fidelity Remediation

Status: IN PROGRESS
Authorized by: Product owner
Date: 2026-09-16

## GOAL

Bring the existing LOT 04 static Dashboard V3 implementation into visual alignment with the product-owner-supplied 1536 × 1024 Dashboard V3 target, without implementing LOT 05 behavior.

## SUCCESS

At 360 px and 390 px the rendered Home screen must reproduce the target's visual hierarchy and art direction:

- warm ivory background;
- centered TrueGround leaf mark and serif wordmark;
- moon control affordance at top right, visual only in this lot;
- serif `Choose your next move.` hero heading;
- navy/blue primary Loop card with subtle landscape treatment;
- three compact practice cards in one row at normal text scale;
- two supporting cards in one row at normal text scale;
- quiet `Review patterns when useful` row;
- navy/ivory bottom navigation styling;
- target microcopy visible without adding LOT 05 behavior;
- no grading, severity, streak, reassurance counter or competitive progress UI;
- no overflow at 360 × 800 or 390 × 844;
- 200% text scaling remains usable by adapting card layout;
- LOT 03 shell navigation and LOT 04 static routing remain non-regressed.

## PRODUCT-OWNER SOURCE

The product owner supplied the full target directly in the product session on 2026-09-16.

Observed source dimensions: `1536 × 1024`.

SHA-256 of the exact uploaded bytes received in this session:

`7bd3cc0db8dcba14a4a3af1ef2e4de25558daa8e62a1708baae4db91584b04b6`

This hash differs from the historical source hash recorded in `DASHBOARD_TARGET_V3.md`. Therefore this file is treated as the newly supplied canonical visual source for LOT 04B; no claim is made that the bytes are identical to the unavailable historical original.

The GitHub connector used for this task cannot directly commit arbitrary binary bytes. The source image is therefore used for live visual comparison in this lot, while repository text records its dimensions and hash. The previously corrupted Base64 preview is not treated as evidence.

## SCOPE

Allowed:

- Dashboard Home visual composition;
- shared design tokens needed to match the target;
- bottom navigation visual styling without route/behavior changes;
- target microcopy shown in the supplied mockup;
- responsive/accessibility adaptations;
- CI screenshot evidence;
- specialist review and handover updates for LOT 04B.

Out of scope:

- LOT 05 behavior;
- ERP engine or exercise logic;
- AI/provider integration;
- persistence/auth/data;
- IAmina Core changes;
- deployment;
- production mutation.

## PROOF REQUIRED

Before LOT 04B can be closed:

1. exact-head CI success;
2. screenshots at 360 × 800 and 390 × 844;
3. target-versus-render side-by-side inspection;
4. UI/UX, OCD safety, accessibility, QA non-regression and content-copy adversarial reviews;
5. no unresolved review thread;
6. no merge without explicit product-owner approval.
