# 05 — DATA, PRIVACY & SECURITY

Status: DRAFT FOR REVIEW
Date: 2026-09-15

## GOAL

Define minimum data, privacy and security requirements before storing sensitive OCD-related user information.

This is a product/security baseline, not legal advice. Applicable privacy, health-data and consumer-protection obligations must be reviewed for each launch jurisdiction before production release.

## Data principle

Collect the minimum data necessary for the approved product behavior.

Sensitive conversation content must never be collected, retained or exported merely because it is technically convenient.

## Data categories

Expected categories may include:

- account identity data;
- authentication/session metadata;
- user preferences;
- journal entries;
- conversation content;
- user-entered triggers/urges/compulsion-related information;
- progress/activity events;
- safety/escalation events;
- product analytics;
- subscription/billing references;
- technical logs.

The concrete schema must be defined only after inspecting the chosen stack and approved V1 scope.

## Sensitive-data classification

OCD-related content can reveal highly sensitive mental-health information.

Therefore:

- treat conversation/journal/domain content as high-sensitivity data;
- avoid raw content in routine logs;
- avoid raw content in analytics platforms by default;
- avoid exposing content in crash-report breadcrumbs unless explicitly scrubbed;
- ensure debug tooling cannot casually expose production user data.

## Client isolation

The OCD client must be isolated from other IAmina clients.

Required properties:

- tenant/client scope on all relevant data access;
- no cross-client search or memory retrieval;
- no shared user content tables without enforced tenant boundaries;
- no reuse of one client's private prompts, datasets or analytics as another client's content;
- no production admin shortcut that bypasses isolation without explicit authorization and audit.

## Environment isolation

Keep at minimum:

- local/dev;
- test/CI;
- staging/preproduction if used;
- production.

Rules:

- no production database for local development;
- no real user data in fixtures/tests unless explicitly authorized and properly de-identified under an approved process;
- no production secrets in test environments;
- destructive testing only on isolated data.

## Authentication and authorization

Before V1 production readiness:

- every protected resource must require authenticated access where appropriate;
- authorization must be enforced server-side, not merely hidden in the UI;
- tenant/user ownership checks must be tested;
- session expiration/revocation behavior must be defined;
- privileged/admin access must be explicit and auditable.

## Secrets

Never commit:

- API keys;
- model-provider tokens;
- database passwords;
- private signing keys;
- production credentials;
- service-account secrets.

Secrets belong in approved secret/environment management.

Screenshots, logs, CI artifacts and issue descriptions must also be checked for accidental secret leakage.

## Encryption

Production architecture must document:

- transport encryption requirements;
- encryption-at-rest capabilities of chosen providers;
- secret storage;
- backup encryption where relevant.

Do not claim end-to-end encryption unless the implemented architecture genuinely provides it.

## Logging

Default principle:

**metadata first, sensitive content only when strictly justified.**

Logs should prefer:

- request ID;
- timestamp;
- component;
- outcome/status;
- safe structured reason codes;
- latency;
- model/tool version identifiers where appropriate.

Avoid raw prompts, journal entries and user messages in standard logs.

## AI provider data flow

Before connecting any model/provider in production, document:

- which user data is sent;
- purpose;
- retention/training terms applicable to the chosen integration;
- geographic/data-processing implications where relevant;
- identifiers included or removed;
- failure/retry behavior;
- deletion implications.

Provider choice is a security/privacy decision, not just a model-quality decision.

## Memory

Longitudinal memory requires explicit rules for:

- what may be stored;
- why it is stored;
- scope (session/user/client);
- source/provenance;
- retention/expiry;
- user review/edit/delete behavior where required;
- retrieval authorization;
- removal from downstream derived indexes/caches when deletion applies.

Do not implement "remember everything" as a shortcut.

## Analytics

Analytics must be privacy-minimized.

Prefer events such as:

- `sos_flow_started`;
- `sos_flow_completed`;
- `journal_entry_created`;
- `feature_opened`;

rather than copying the user's sensitive free text into event properties.

Any event containing health-related semantic content needs explicit review.

## Data deletion

Before production, define and test:

- account deletion flow;
- content deletion behavior;
- backups/retention exceptions;
- derived memory/index deletion;
- audit records that may need legitimate retention;
- expected completion semantics communicated to users.

Never display "deleted" if downstream copies are knowingly still active contrary to the stated behavior.

## Backups and recovery

If persistent user data exists, define:

- backup strategy;
- restore test procedure;
- recovery objectives appropriate to product stage;
- access restrictions;
- how deletion/retention policies interact with backups.

A backup that has never been restored in a test is not proven recovery.

## Dependency and supply-chain security

Before adding a dependency:

- verify necessity;
- review maintenance status;
- review license;
- review obvious security risk/advisories;
- pin/manage versions according to stack conventions;
- avoid unnecessary SDKs with broad data access.

## Security testing baseline

Before V1 production gate, test at least:

- unauthorized resource access;
- cross-user access;
- cross-client/tenant access;
- IDOR-style object access attempts;
- input validation;
- rate/abuse controls where relevant;
- sensitive-data leakage in logs/errors;
- provider failure paths;
- secret scanning/dependency checks where supported;
- account/session edge cases.

## No real-data mutation without approval

No migration, backfill, destructive query, production schema change or modification of real user data may be performed without explicit product-owner approval and a documented rollback/verification plan.

## Release blocker

Known cross-client leakage, unauthorized user-data access, secret exposure, raw sensitive-content logging, unsafe production-data access or misleading deletion behavior blocks release.
