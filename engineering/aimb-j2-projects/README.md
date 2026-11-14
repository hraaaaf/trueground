# AI Machine Bridge J2 — Projects bounded sequential drain (OFFLINE ONLY)

**Status: candidate / NOT INSTALLED / NO-GO activation.** This helper exists exclusively on an isolated GitHub branch and has NOT been loaded or executed on the Lenovo.

## Real failure that motivated the candidate

On 14 November 2026, through the **main AI Machine Bridge plugin** and the authorized Lenovo, three near-concurrent Projects requests returned `pending`. Follow-up `get_job_status` confirmed **two `done` and one `expired`** (README.md). Windows `workspace-agent.ps1` was read via the plugin: it has exactly **one Projects poll and at most one Projects result in each loop**, followed by `Start-Sleep -Seconds 60`. Jobs expire after approximately 90 seconds. Therefore bursts can exceed the available processing window despite an online PC. This is a **runtime scheduling/backlog failure**, not evidence that D1 quota is currently exhausted.

## This candidate

`project-drain.ps1` defines a pure `Invoke-AimbProjectDrain` function with externally injected, **already authorized** `Poll`, `Dispatch` and `SubmitResult` callbacks. No HTTP calls, queue reads, Task Scheduler, secrets, file operations or Windows agent mutations are embedded in the helper.

- Up to **three** sequential jobs are consumed per invocation; no parallel job handling or uncontrolled retry.
- Rejects unknown actions/invalid IDs and args. The exact action allowlist is `list_project_files` and `read_project_text`.
- Stops on poll, dispatch or result errors, missing signed result ACK, or malformed commands. No subsequent poll after failed ACK.
- One idle poll when queue empty. A single job can cause **one extra empty poll** to establish an empty queue; full batches stop at cap three.
- `project-drain.test.ps1` uses only synthetic in-memory jobs and callback results. Tests assert triple drain, single/idle, illegal action, missing ACK, and error handling.
- CI is intentionally only **one Windows PowerShell 5.1 job** to minimize GitHub runner load.

## Not yet done — activation gates

This is **not a fix installed on the Lenovo** and does not change actual `workspace-agent.ps1`, `project-read.ps1`, Worker or D1. It does **not** prove that a real poller can process three remote jobs within TTL under network delays. The actual script currently binds a signed `Post-Signed` transport and `Invoke-BridgeProjectRead` and would need a **separately reviewed targeted integration**.

Do NOT graft this helper into the live agent based solely on the offline test. Before a separate human GO for Windows writes, require:

1. Preserve complete SHA-256 of source Windows script and four Task Scheduler XML/PIDs, and create byte-exact backup.
2. Audit exact callback mapping and invocation to preserve signed project poll/result, `args_json` policy, and fail-closed behavior. Test a real PowerShell 5.1 fixture with 3 jobs and matching results.
3. Measure bounded D1/DO request volume: with 1 job, an additional empty poll may increase D1 cost; busy batches can poll up to three times per 60 s. No quota/savings claims without measurements.
4. Avoid automatic changes to the 60s sleep or TTL 90s (neither is necessarily the correct setting for bursts). Preserve the existing Projects flag state.
5. Only after controlled GO: install helper and edit **the sole Projects block** on Windows; no other tasks/agents, no Worker/D1/Cloudflare/Plugin change; compare before/after PID/XML, logs, rollback.
6. Repeat **three real concurrent ChatGPT main-plugin requests**; require `done` and actual content for all three. Stop / rollback safely (after explicit approval) if any expire or cause elevated quotas.
7. Report GOAL / SUCCESS / PROOF and update the [canonical Notion roadmap](https://app.notion.com/p/41377c6633628166bebe-f6ca16a23102).

**Independent J4:** GitHub reading, branch/PR, CI and log analysis already work through the GitHub connector without installing the Windows self-repair updater. Do not let future micro-updater work block J2 readings and normal GitHub development.

**Current canonical roadmap (unearned PE remain unchanged):** V2 13/24 PE = 54.2%; J2 2/4 PE (50%); J4 0/5.
