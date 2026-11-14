# J2 Projects — offline signed-transport adapter gate

Status: CANDIDATE ONLY. No Windows agent was modified. No permission to edit the live script is implied.

## Boundary

`project-signed-adapter.ps1` composes the existing bounded drain with three dependency-injected scriptblocks. Those callbacks MUST be supplied by a separately reviewed caller using the already established signed Projects poll/result endpoints and the existing `Invoke-BridgeProjectRead` restricted reader. This file does not implement transport, tokens, service control or installation.

## Before any Windows integration

1. Independently review and attest the exact source SHA-256 of `workspace-agent.ps1`, the four Task Scheduler task XML definitions and running PIDs; take a byte-exact backup outside an attacker-writable location.
2. Reject reparse/junction/symlink paths; do not replace by path without reviewing native Win32 handle / ACL / TOCTOU constraints. A general-purpose remote shell is explicitly out of scope.
3. Test signed poll/result wiring, ACK failure, idempotence, JSON rejection and bounded D1/DO volume with isolated fixtures.
4. Require explicit operator approval to change exactly the Projects section and restart only Workspace; preserve the previous flag state. Verify restored SHA and task identity on rollback.
5. E2E from the principal ChatGPT plugin: three near-concurrent reads MUST reach DONE with nonempty actual content, without expiry.
6. NO-GO for live application until a specialized narrowly allowlisted tool exists and the operator approves its exact patch, hashes and rollback.

This PR does not establish a safe Windows install channel, provide a privileged MCP tool, or replace J4 micro-updater controls. No merge, live deployment or activation.
