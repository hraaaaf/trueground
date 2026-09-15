# TrueGround OCD — Canonical Dashboard Target V3

Status: APPROVED PRODUCT TARGET
Approved by: Product owner
Date: 2026-09-15

## GOAL

Freeze the third dashboard mockup as the visual and product North Star for the OCD mobile experience.

This target supersedes the earlier dashboard concepts that emphasized status scoring, daily task completion and weekly numerical progress.

## Why V3 supersedes V1/V2

Early user feedback from a person living with OCD identified a material product risk: a dashboard centered on symptom status, counts, progress scores and repeated self-monitoring may itself increase anxiety or invite checking/perfectionistic behavior.

V3 therefore moves the home experience from **monitoring and grading** toward **choice, practice, values and bounded support**.

## Canonical visual cues

The approved target contains these product cues:

- `Less checking. More living.`
- `Choose your next move.`
- `Make room for uncertainty. Choose what matters.`
- Primary action: `I'm stuck in a loop`.
- Supporting line: `Notice the urge. Pause before the ritual.`
- `Pause the ritual`.
- `Practice uncertainty`.
- `Continue planned practice`.
- `Return to what matters`.
- `Need a person, not an answer?`.
- `Review patterns when useful`.
- Bottom navigation: `Home / Loop / Practice / Support / Profile`.
- Product principles visible in the art direction: `Uncertainty without grading`, `Practice, not perfect`, `Values over rituals`.

## Explicit anti-targets

The home dashboard must not default to:

- OCD severity badges such as `mild / moderate / severe`;
- streaks;
- daily completion pressure;
- reassurance-resisted counters;
- exposure counts as a competitive score;
- anxiety trend charts on the main home screen;
- compulsive checking incentives disguised as progress tracking.

Progress review may exist, but it must be user-initiated, bounded and designed according to `03_OCD_CLINICAL_SAFETY.md`.

## Stored visual preview

Because the current GitHub connector cannot write binary image bytes directly, the repository stores a portable Base64-encoded JPEG preview at:

`docs/ocd/assets/dashboard_target_v3.jpg.b64`

Decode locally with:

```bash
base64 -d docs/ocd/assets/dashboard_target_v3.jpg.b64 > dashboard_target_v3.jpg
```

Stored preview dimensions: `512 × 341`.

Stored preview SHA-256 after decoding:

`117f1121fa2cec0d3319d5e2c93cf514ec5f40be3a05950ed7b8b89db97210a5`

The approved source mockup generated in the product session was `1536 × 1024` with SHA-256:

`43e7b30bbb75f87a237012cb70f491c4941b60115ef532d2c8b4170baff59435`

The Base64 asset is a compressed visual reference derived from that approved source, not a pixel-identical archival original.

## Implementation rule

**MATCH THE PRODUCT LOGIC FIRST.**

The implementation must converge on the hierarchy, calm visual density and anti-grading philosophy represented here. Pixel-level matching is not considered verified until a full-resolution canonical source image is committed and screenshot comparison is possible.

Any material change to this target requires explicit product-owner approval and an update to `01_PRODUCT_NORTH_STAR.md`.
