# AI Machine Bridge J1-DEV candidate (offline import)

This directory is a sanitized source snapshot for code review and offline Windows CI. It is not an enabled plugin, agent, or staging deployment.

The exported staging-facing modules use reserved example values (`example.invalid`, `tenant.example.auth0.com`, and synthetic UUIDs). Do not replace these values in this public repository with live tenant, Worker, D1, device, or key material. Any later staging configuration requires a separate review and authorization.

No private key, access token, `.env` file, user fixture, local database, local proof bundle, or Git history is part of the published snapshot. The native PowerShell tests use isolated synthetic fixtures. Network-facing code is covered here only by offline mocks; this CI workflow does not contact Cloudflare, Auth0, or a Lenovo agent.

See `G2_IMPORT_REPORT.md` for provenance, audit scope, and limitations. `SHA256SUMS.txt` covers the allowlisted published files other than itself.
