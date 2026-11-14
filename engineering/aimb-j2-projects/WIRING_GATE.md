# J2 Projects — offline Windows source wiring (not installed)

Branch stacked on PR #49 -> PR #48. The transformer takes a PowerShell source STRING and emits another source STRING. No filesystem access, no installer, no Task Scheduler or cloud actions.

## Hard gate before touching the Lenovo

1. Read entire ACTIVE workspace-agent.ps1 as exact bytes, independently record its SHA-256, ACL, reparse/junction/symlink check, encoding and last-modified metadata. The 80-line plugin excerpt is not a complete source attestation.
2. Review generated diff and preserve the existing signed Post-Signed poll/result channel, the restricted Invoke-BridgeProjectRead allowlist, Projects enable flag and 60-second main loop.
3. Have a local, narrow allowlisted operator explicitly approved per exact source/target hashes; no arbitrary remote shell or broad PowerShell tool. The current AI Machine Bridge plugin CANNOT perform this installation.
4. Capture all four Bridge Task Scheduler XML definitions and PID/task owner before changing anything; create byte-for-byte backup, verify backup SHA-256 and test recovery. Do not modify unrelated agents.
5. Under an independently verified native Windows file-handle and ACL/reparse/TOCTOU policy, apply only pinned bytes to the single Projects source section and copy pinned helper and adapter. Revalidate source hash before any write.
6. If separately approved, controlled Workspace-only restart. Fail closed and rollback on hash/task/heartbeat discrepancy; preserve existing flag. No background auto-apply.
7. Live E2E through main plugin: three concurrent Projects reads DONE, actual content, no expired jobs, measured queue latency and Cloudflare/D1 costs.
8. NO-GO for merge or deployment until security review and separate owner approval; source fixture CI is NOT proof of a safe installer or production reliability.

Current GitHub artifacts are preparatory; J2 stays 2/4 and V2 stays 13/24 until live evidence.
