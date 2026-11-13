/**
 * AIMB J1-H — offline, fail-closed safety gate for a NEW bounded read-only agent.
 * It cannot start tasks, access a PC, modify D1, or authorize production.
 * The 70% buffer is a project guardrail, NOT a Cloudflare plan limit.
 */
export const LEGACY_TASKS = Object.freeze([
  'AI-Machine-Bridge-Commands',
  'AI-Machine-Bridge-Files',
  'AI-Machine-Bridge-Workspace'
]);
const REQUIRED_PROOFS = Object.freeze([
  'signedStagingE2E', 'idempotentAckRecovery', 'replayRejected',
  'windowsIsolation', 'readOnlyAllowlist', 'securityReview', 'humanApproval'
]);
const isNonNegative = v => Number.isSafeInteger(v) && v >= 0;
const isPositive = v => Number.isSafeInteger(v) && v > 0;

export function projected24hBudget(budget) {
  if (!budget || typeof budget !== 'object') throw Error('BUDGET_REQUIRED');
  const keys = ['otherReads24h', 'otherWrites24h', 'batches24h',
    'readsPerBatch', 'writesPerBatch', 'resultCalls24h',
    'readsPerResult', 'writesPerResult'];
  for (const key of keys) if (!isNonNegative(budget[key])) throw Error('INVALID_' + key);
  if (!isPositive(budget.readLimit24h) || !isPositive(budget.writeLimit24h)) throw Error('LIMITS_UNVERIFIED');
  if (budget.sampleHours !== 24 || budget.sampleComplete !== true || budget.sampled === true)
    throw Error('COMPLETE_24H_MEASUREMENT_REQUIRED');
  const projectedReads = budget.otherReads24h + budget.batches24h * budget.readsPerBatch
    + budget.resultCalls24h * budget.readsPerResult;
  const projectedWrites = budget.otherWrites24h + budget.batches24h * budget.writesPerBatch
    + budget.resultCalls24h * budget.writesPerResult;
  if (!Number.isSafeInteger(projectedReads) || !Number.isSafeInteger(projectedWrites))
    throw Error('BUDGET_OVERFLOW');
  return Object.freeze({projectedReads, projectedWrites,
    maxSafeReads:Math.floor(budget.readLimit24h * 0.7),
    maxSafeWrites:Math.floor(budget.writeLimit24h * 0.7)});
}

export function assessResumeGate(input, nowMs = Date.now()) {
  const reasons=[];
  if (!input || typeof input !== 'object')
    return Object.freeze({status:'NO_GO',reasons:['INPUT_REQUIRED'],mayEnableLegacyTasks:false});
  // This preflight is NEVER a shortcut to reenable the old pollers.
  if (input.target !== 'new-bounded-readonly-agent') reasons.push('NEW_AGENT_REQUIRED');
  for (const task of LEGACY_TASKS) {
    if (input.taskStates?.[task] !== 'Disabled') reasons.push('LEGACY_TASK_MUST_STAY_DISABLED:' + task);
  }
  if (input.taskStates?.['AI-Machine-Bridge-Presence'] !== 'Enabled')
    reasons.push('PRESENCE_STATE_NOT_VERIFIED');
  for (const key of REQUIRED_PROOFS) if (input.proofs?.[key] !== true) reasons.push('PROOF_MISSING:' + key);
  if (!/^[a-f0-9]{64}$/i.test(input.sourceSha256 || '')) reasons.push('SOURCE_SHA_NOT_PINNED');
  const observedAt = Date.parse(input.quota?.observedAt || '');
  if (!Number.isFinite(nowMs) || !Number.isFinite(observedAt) || observedAt > nowMs || nowMs - observedAt > 6 * 3600000)
    reasons.push('QUOTA_OBSERVATION_STALE_OR_MISSING');
  try {
    const p = projected24hBudget(input.quota);
    if (p.projectedReads > p.maxSafeReads) reasons.push('D1_READ_BUDGET_EXCEEDED');
    if (p.projectedWrites > p.maxSafeWrites) reasons.push('D1_WRITE_BUDGET_EXCEEDED');
  } catch (e) {reasons.push(e.message);}
  return Object.freeze({status:reasons.length?'NO_GO':'READY_FOR_HUMAN_REVIEW',
    reasons:Object.freeze(reasons), mayEnableLegacyTasks:false,
    productionAuthorized:false, taskSchedulerModified:false});
}
