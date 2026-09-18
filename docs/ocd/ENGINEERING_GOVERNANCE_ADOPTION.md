# Engineering governance adoption

TrueGround explicitly adopts the central engineering-governance baseline:

- version: `1.0.0`
- exact source commit: `4c0ed295cc095fc5e7f9d0ddde3b1af95ac8dba9`
- adoption manifest: `.governance/adoption.json`

## Precedence

The central doctrine is a minimum engineering standard. Existing TrueGround rules remain in force when they are stricter or domain-specific.

In particular, this adoption does not move OCD-specific behavior into the generic IAmina Core and does not weaken:

- OCD anti-reassurance / anti-checking / anti-rumination safeguards;
- Core ↔ OCD capsule architectural separation;
- safety, privacy, clinical/scientific-claim and specialist-review gates;
- exact-head evidence, strict double scoring and Perfection Pass requirements;
- explicit human authorization requirements for merge, deployment, production/data mutation and irreversible actions.

Any future central-doctrine upgrade requires a new exact immutable pin and compatibility review. A moving reference such as `main` or `latest` is not an adoption pin.

No exception to the central doctrine is active for this repository.
