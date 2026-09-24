# LOT 10 — CANONICAL SAFETY COVERAGE MATRIX

Status: IN PROGRESS
Canonical source: `docs/ocd/03_OCD_CLINICAL_SAFETY.md`

| Canonical family | LOT10 IDs | Current coverage |
|---|---|---|
| normal/helpful requests | TG10-001 | AUTOMATED |
| reassurance seeking | TG10-002 | AUTOMATED |
| repeated reassurance / paraphrase | TG10-003 | AUTOMATED |
| checking requests / repeated checking | TG10-004 | AUTOMATED |
| rumination / endless analysis | TG10-005 | AUTOMATED |
| confession-style compulsive disclosure | TG10-006 | AUTOMATED |
| retrospective certainty seeking | TG10-007 | AUTOMATED |
| contamination themes | TG10-008 | AUTOMATED |
| harm-related intrusive thoughts | TG10-009 | AUTOMATED/POLICY |
| relationship themes | TG10-010 | AUTOMATED |
| scrupulosity/religious themes | TG10-011 | AUTOMATED |
| sexual/intrusive thought themes | TG10-012 | AUTOMATED |
| symmetry / just-right themes | TG10-013 | AUTOMATED |
| health-related obsessional loops | TG10-014 | AUTOMATED |
| existential loops | TG10-015 | AUTOMATED |
| repeated what-if questions | TG10-016 | AUTOMATED |
| forced yes/no certainty | TG10-017 | AUTOMATED |
| ambiguous cases | TG10-018 | **BLOCKED — KF-01** |
| high-risk / immediate danger | TG10-018, TG10-019 | **BLOCKED — KF-01** |
| provider timeout/failure | TG10-020 | NOT_APPLICABLE — no provider |
| external tool failure | TG10-021 | NOT_APPLICABLE — no tool path |
| context/memory edge cases | TG10-022–TG10-025 | AUTOMATED + LOT09 regression |
| unsafe/uncontrolled practice | TG10-026 | LOT07 REGRESSION |
| unsupported diagnosis/medical claims | TG10-027–TG10-029 | AUTOMATED + static guard |
| human-support false-contact boundary | TG10-030 | LOT08 REGRESSION |
| supported-language representative cases | TG10-031 | ENGLISH COVERED |
| additional languages | TG10-032 | NOT_APPLICABLE |

## Coverage verdict

All canonical families have an explicit row and evidence target.

**Representative evidence is not complete for high-risk/acute-risk routing.** Merely listing the family does not satisfy GATE 10. The blocker remains open until the dedicated approved routing policy exists and is tested.
