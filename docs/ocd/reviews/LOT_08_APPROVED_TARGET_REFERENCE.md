# LOT 08 — Approved Target Reference

Project: TrueGround OCD
Lot: LOT 08 — Values and Human Support
Product-owner approval: 2026-09-22
Approval status: APPROVED AS LOT08 TARGET REFERENCE
Runtime render compared: `7a5d3fa481a3887eecf0834a44b93a1eec7a7750`
Documentation HEAD at approval time: `df104e3f30bbe8a97c75d574ee434db814c0faaa`

## Source of target

The approved target was reconstructed independently from:
- canonical TrueGround design tokens in `lib/design/app_theme.dart`;
- LOT08 contract/copy;
- the existing Dashboard V3 visual language.

The target was not traced from or pixel-copied from the LOT08 screenshots.

The product owner explicitly approved the resulting Values and Support target comparison on 2026-09-22.

## Required viewports/states

Target ↔ Render comparison covered:
- 360 × 800
- 390 × 844

Values:
- choose area
- choose action
- terminal

Support:
- menu
- trusted person
- care team
- local professional

Total comparison states: 14.

## Target PNG fingerprints

- `target_support_360.png` — sha256 `885d1e0c703c021628466773ddce61f036d9d7d22b8b108dd56044191b30d3bf`
- `target_support_360_care.png` — `59c3cd490228f1e5bc21bda4d66e47c124351839c3d894a2be5c8118e80567b8`
- `target_support_360_local.png` — `7efbad26f46f6ee9388bdd20e99922fd0d3b3b1e7d1cbaeba22178665cf68f6d`
- `target_support_360_trusted.png` — `3e514f18c1a00fbdc9bd559f0868a2d20fc48066999391fb41b50e336cf65e5d`
- `target_support_390.png` — `6cbf01b372097f457961d887274b6607baafb6617fbf373647810f801bee21f5`
- `target_support_390_care.png` — `f76a61d3e8f0fd8751271f6c9f4a7c500ef87aaf9382e95143f4ab5426b847dd`
- `target_support_390_local.png` — `7504a665b3117de29f3ab3ea549a88dbadf00a1dcd3cc3751a0f55fd58afccf0`
- `target_support_390_trusted.png` — `493f33f9fe76b8c12fe8549c113a9faf4d2037c830ad8670dcc439b9e0fab1cd`
- `target_values_360.png` — `4fa47156669e2dbd45dd64d4460cee655365a6c999cc040a14cf46617dba60e6`
- `target_values_360_action.png` — `684a00670a504c6f9c614f5842a291c5512ac3c8fa7e7a5447046221f2ccf842`
- `target_values_360_terminal.png` — `d19129771fd378448a141663eae308e41a0e768b7db9d39e91d73e12ea39aad5`
- `target_values_390.png` — `a54e52339b76cd19c27dd2bd476b28a52728fb1e40d35e60d77017c032980e18`
- `target_values_390_action.png` — `32f82fdf42de2eea22ed057226c6422c912fceda47f8fc2fc1bf330e3c02383f`
- `target_values_390_terminal.png` — `b29068bfa3ec14b8651f4f80012cc4a9cb915614d201608697f81b2456c48e8f`

## Visual review verdict

Across all 14 matched states:
- information hierarchy matches;
- card grouping and order match;
- CTA hierarchy matches;
- navigation placement matches;
- responsive density at 360/390 is materially consistent;
- no material overflow/cutoff mismatch is visible;
- remaining differences are static-mock typography/icon glyph details rather than product-structure divergence.

Verdict: **PASS_WITH_NOTES**.

This approved target removes the canonical `significant UI without real Target ↔ Render` cap for LOT08. It does not grant merge or deployment authorization.
