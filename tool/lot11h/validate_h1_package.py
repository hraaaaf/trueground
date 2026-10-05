#!/usr/bin/env python3
"""Deterministic LOT11-H H1 documentation gate.

No network access, provider call, secrets, real-user data, or product runtime mutation.
This validates package completeness only; it is not clinical or privacy approval.
"""

from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[2]

FILES = {
    "protocol": ROOT / "docs/ocd/lots/LOT_11H_H1_SUPERVISED_ALPHA_PROTOCOL.md",
    "consent": ROOT / "docs/ocd/templates/LOT_11H_H1_PARTICIPANT_INFO_CONSENT.md",
    "record": ROOT / "docs/ocd/templates/LOT_11H_H1_SESSION_RECORD.md",
}

REQUIRED = {
    "protocol": [
        "REAL H1 EXECUTION NOT AUTHORIZED",
        "## 1. PARTICIPANT ELIGIBILITY",
        "## 2. EXCLUSION / DO-NOT-START CONDITIONS",
        "## 3. PRODUCT BOUNDARIES TO READ ALOUD",
        "## 4. REAL-USER PROVIDER PRIVACY PREFLIGHT — HARD GATE",
        "Zero Data Retention",
        "## 5. DATA MINIMIZATION PLAN",
        "## 6. SESSION FLOW AND BOUNDS",
        "maximum 8 participant messages",
        "maximum 6 provider-eligible/model calls",
        "## 7. USE GUIDANCE — DO NOT PROVOKE SYMPTOMS",
        "## 8. FACILITATOR SCRIPT AND CONDUCT",
        "## 9. OBSERVATION RUBRIC",
        "H2-01 moral/self-checking",
        "H2-03 explanation-before-pivot",
        "H2-04 reconfession recurrence",
        "## 10. HARD STOP CRITERIA",
        "provider/network/schema failure becomes fail-open",
        "unexpectedly appears in routine logs",
        "unsupported diagnosis, medication instruction, autonomous ERP/treatment plan",
        "falsely claims that a human/service was contacted",
        "## 11. INCIDENT / ESCALATION PROCEDURE",
        "## 12. POST-SESSION DEBRIEF",
        "## 13. H1 → H2 GO / NO-GO RULE",
        "Automatic H2 progression is forbidden",
        "NO-GO FOR REAL PARTICIPANTS",
    ],
    "consent": [
        "NOT VALID FOR USE UNTIL PRE-SESSION FIELDS ARE COMPLETED",
        "Groq ZDR confirmed on actual organization/project",
        "## ENGLISH",
        "## FRANÇAIS",
        "not a clinical trial",
        "at most 8 participant messages",
        "6 appels modèle éligibles au maximum",
        "there is no promised clinical benefit",
        "aucun bénéfice clinique n’est promis",
        "Zero Data Retention",
        "no raw confession",
        "Aucun contenu brut de confession",
    ],
    "record": [
        "DO NOT COPY RAW SENSITIVE CHAT INTO THIS RECORD",
        "## A. SESSION PREFLIGHT",
        "Product Owner H1 execution authorization",
        "ZDR confirmed on actual inference configuration",
        "means `NO-GO`",
        "## C. TURN OBSERVATION GRID",
        "H2-01",
        "H2-03",
        "H2-04",
        "## E. STOP / INCIDENT RECORD",
        "Never paste the triggering participant message or model response",
        "## F. DEBRIEF — PRODUCT OBSERVATIONS",
        "Do not ask or record whether OCD symptoms improved",
        "## H. H1 AGGREGATE DECISION",
        "No automatic progression is permitted",
    ],
}

FORBIDDEN_POSITIVE_CLAIMS = [
    "TrueGround treats OCD",
    "TrueGround cures OCD",
    "TrueGround diagnoses OCD",
    "clinically proven to",
    "clinically validated treatment",
]

errors = []

for key, path in FILES.items():
    if not path.exists():
        errors.append(f"missing file: {path.relative_to(ROOT)}")
        continue
    text = path.read_text(encoding="utf-8")
    for phrase in REQUIRED[key]:
        if phrase not in text:
            errors.append(f"{key}: missing required phrase: {phrase!r}")

combined = "\n".join(
    path.read_text(encoding="utf-8") for path in FILES.values() if path.exists()
)
for claim in FORBIDDEN_POSITIVE_CLAIMS:
    for line in combined.splitlines():
        stripped = line.strip().lower()
        if claim.lower() in stripped and not any(
            marker in stripped
            for marker in ("not ", "does not ", "must not ", "n’est pas", "ne ", "no ")
        ):
            errors.append(f"possible unsupported positive claim: {line.strip()}")

if errors:
    print("LOT11-H H1 package validation: FAIL")
    for error in errors:
        print(f"- {error}")
    sys.exit(1)

print("LOT11-H H1 package validation: PASS")
print("- required H1 package files present")
print("- participant boundaries present in EN/FR")
print("- provider privacy/ZDR hard gate present")
print("- H2-01/H2-03 observation targets present")
print("- H2-04 recurrence STOP present")
print("- structured no-raw-text session record present")
print("- H1→H2 explicit GO/NO-GO rule present")
print("This check does not authorize real participants, merge, deploy, clinical claims, or provider data use.")
