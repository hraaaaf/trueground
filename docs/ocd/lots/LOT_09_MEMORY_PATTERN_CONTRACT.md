# LOT 09 — Memory / Pattern Review Contract

Status: IMPLEMENTATION CANDIDATE
Decision: Option B approved by product owner on 2026-09-22.

## Scope
LOT09 persists only a bounded local record of approved TrueGround activity types and UTC timestamps.

Allowed record kinds:
- pause practice completed;
- uncertainty practice completed;
- values next-step flow completed.

No free text, intrusive-thought content, trigger content, reassurance question, clinical score, diagnosis, inferred severity or LLM-generated memory is stored.

## Storage boundary
- local device storage only via the existing shared_preferences dependency;
- TrueGround-specific key namespace;
- single-profile prototype only;
- no claim of multi-user isolation because no user identity/auth exists in this prototype;
- no IAmina Core modification.

## Retention
- rolling 30-day retention;
- maximum 30 records;
- expired records are pruned on read/write;
- this is a privacy/product storage policy, not a clinical schedule.

## Review behavior
- user initiated from “Review patterns when useful”;
- at most three unique activity types are shown;
- no counts, dates, streaks, trend charts, better/worse label or prediction;
- no refresh/check-again control;
- empty and unavailable memory states are explicit;
- the app never claims history was checked when storage fails.

## User control
- generated records contain no editable free-text payload;
- correction is supported by removing all records of one activity type;
- all saved pattern-review activity can be deleted immediately;
- there are no downstream indexes/caches in this lot.

## Known limitation
Cross-user isolation is not claimable until a real identity/auth boundary exists. LOT09 must not misrepresent this device-local single-profile store as account-scoped memory.
