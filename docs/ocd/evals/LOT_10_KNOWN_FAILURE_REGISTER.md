# LOT 10 — KNOWN FAILURE REGISTER

Date: 2026-09-22

## KF-01 — Dedicated high-risk / crisis routing policy absent

Severity: **RELEASE BLOCKER**
Gate impact: **GATE 10 BLOCKED**
Owner decision required: **YES**

### Direct evidence

- `03_OCD_CLINICAL_SAFETY.md` requires a dedicated reviewed policy before release for immediate danger, self-harm, suicide, harm to others, abuse, medical emergencies or inability to stay safe.
- LOT05 eval evidence explicitly records genuine acute-risk handling as blocked for production pending that policy.
- LOT08 safety evidence states that its Support route is not crisis routing.
- `CompulsionFirewallSession` hard-escapes `emergency` and `immediate danger`, so obvious danger text is not swallowed as a compulsive repeat.
- No dedicated crisis/high-risk policy file exists in `docs/ocd`.
- No dedicated high-risk route exists in `lib/app/router.dart`.
- `SupportScreen` provides ordinary human-support choices and explicitly does not perform contact actions.

### Why this cannot be auto-fixed

Choosing crisis/acute-risk behavior is clinically meaningful. It may imply:
- intent/risk classification;
- emergency escalation logic;
- regional resources;
- medical/emergency instructions;
- special data/privacy behavior.

Those decisions require explicit product-owner approval and appropriate specialist/clinical review. LOT10 must not improvise them.

### Resolution criteria

KF-01 can close only when:
1. a dedicated high-risk policy is explicitly approved;
2. its scope/population/regions are defined;
3. required clinical/regulatory/privacy review is recorded;
4. deterministic routing behavior is implemented without pretending external dispatch/contact;
5. ambiguous + explicit high-risk eval cases pass;
6. supported-language/regional copy is reviewed;
7. exact-head non-regression is green.

## Non-blocking limitations

- No physical-device VoiceOver/TalkBack proof is added by LOT10 because this lot is eval/test-only unless the human-gated policy later changes UI.
- No independent human clinician validation is claimed.
- English is the only supported language currently evidenced.
- No authenticated multi-user memory boundary exists; LOT09 remains device-local/single-profile and LOT10 does not broaden that claim.
