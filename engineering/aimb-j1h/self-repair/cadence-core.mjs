// AI Machine Bridge P0: local-only, allowlisted cadence patching engine.
// This module has NO network, Cloudflare, Task Scheduler, PowerShell, or shell calls.
import { createHash } from 'node:crypto';
import { promises as fs } from 'node:fs';
import path from 'node:path';

const POLICY = Object.freeze({
  commands: Object.freeze({ file: 'command-agent.ps1', transitions: Object.freeze({ 4: [15], 15: [60] }) }),
  files: Object.freeze({ file: 'file-agent.ps1', transitions: Object.freeze({ 4: [60] }) }),
  workspace: Object.freeze({ file: 'workspace-agent.ps1', transitions: Object.freeze({ 8: [60] }) }),
});
export const PATCH_TARGETS = Object.freeze(Object.keys(POLICY));
const MAX_FILE_BYTES = 131072;
const SHA_RE = /^[a-f0-9]{64}$/;
const utf8 = new TextDecoder('utf-8', { fatal: true, ignoreBOM: true });

function fail(code) { throw new Error(code); }
export function sha256(bytes) { return createHash('sha256').update(bytes).digest('hex'); }
function checkSha(hash) { if (typeof hash !== 'string' || !SHA_RE.test(hash)) fail('INVALID_SHA256'); return hash; }
function getPolicy(target) {if (typeof target !== 'string' || !Object.hasOwn(POLICY, target)) fail('TARGET_NOT_ALLOWLISTED'); return POLICY[target];}
async function checkDir(dir) { const s = await fs.lstat(dir); if (!s.isDirectory() || s.isSymbolicLink()) fail('UNSAFE_DIRECTORY'); }
async function targetFile(agentRoot, target) {
  const root = path.resolve(agentRoot);
  await checkDir(root);
  const p = path.join(root, getPolicy(target).file);
  const s = await fs.lstat(p);
  if (!s.isFile() || s.isSymbolicLink() || s.nlink !== 1 || s.size > MAX_FILE_BYTES) fail('UNSAFE_TARGET_FILE');
  return { file: p, stat: s };
}
async function safeRead(agentRoot, target) {
  const {file, stat} = await targetFile(agentRoot, target);
  const bytes = await fs.readFile(file);
  if (bytes.length > MAX_FILE_BYTES || bytes.length !== stat.size) fail('TARGET_CHANGED_DURING_READ');
  return { file, stat, bytes, hash: sha256(bytes) };
}
function lineMatch(bytes) {
  let src;
  try { src = utf8.decode(bytes); } catch { fail('INVALID_UTF8'); }
  if (src.includes('\0')) fail('NUL_IN_SOURCE');
  const lines = src.split(/\r?\n/);
  const hits = [];
  for (let i = 0; i < lines.length; i++) {
    const m = /^([ \t]*)Start-Sleep[ \t]+-Seconds[ \t]+([0-9]+)([ \t]*)$/.exec(lines[i]);
    if (m) hits.push({ index: i, indent: m[1], seconds: Number(m[2]), trailing: m[3] });
  }
  if (hits.length !== 1) fail('EXPECTED_EXACTLY_ONE_SLEEP_LINE');
  const hit = hits[0];
  if (!Number.isSafeInteger(hit.seconds)) fail('INVALID_CADENCE');
  const suffix = lines.slice(hit.index + 1).filter(s => s.trim());
  if (suffix.length !== 1 || suffix[0].trim() !== '}') fail('SLEEP_NOT_TERMINAL_LOOP');
  return { src, hit, lines };
}
export async function inspectCadence({ agentRoot, target }) {
  const x = await safeRead(agentRoot, target);
  const { hit } = lineMatch(x.bytes);
  return Object.freeze({ target, file: getPolicy(target).file, sha256: x.hash, bytes: x.bytes.length, line: hit.index + 1, seconds: hit.seconds });
}
export async function planCadence({ agentRoot, target, expectedSha256, toSeconds }) {
  const policy = getPolicy(target);
  checkSha(expectedSha256);
  if (!Number.isSafeInteger(toSeconds) || toSeconds <= 0) fail('INVALID_NEW_CADENCE');
  const x = await safeRead(agentRoot, target);
  if (x.hash !== expectedSha256) fail('SOURCE_SHA_MISMATCH');
  const { src, hit, lines } = lineMatch(x.bytes);
  if (!policy.transitions[hit.seconds]?.includes(toSeconds)) fail('TRANSITION_NOT_ALLOWLISTED');
  const oldLine = lines[hit.index];
  const newLine = `${hit.indent}Start-Sleep -Seconds ${toSeconds}${hit.trailing}`;
  if (oldLine === newLine) fail('NO_CHANGE');
  const matched = `${src.split(oldLine).length - 1}`;
  if (matched !== '1') fail('NON_UNIQUE_TARGET_LINE');
  const rewritten = src.replace(oldLine, newLine);
  const nextBytes = Buffer.from(rewritten, 'utf8');
  if (nextBytes.length > MAX_FILE_BYTES) fail('OUTPUT_TOO_LARGE');
  const base = {target,file:policy.file,beforeSha256:x.hash,afterSha256:sha256(nextBytes),fromSeconds:hit.seconds,toSeconds,line:hit.index+1,oldLine,newLine};
  const planId = sha256(Buffer.from(JSON.stringify(base)));
  return Object.freeze({ ...base, planId });
}
function safeName(target, hash) {getPolicy(target);checkSha(hash);return `${target}-${hash}`;}
async function makeStateRoot(stateRoot) {
  const root = path.resolve(stateRoot);
  await fs.mkdir(root, { recursive: true, mode: 0o700 });
  await checkDir(root);
  const backupDir = path.join(root, 'backups');
  await fs.mkdir(backupDir, { recursive: true, mode: 0o700 });
  await checkDir(backupDir);
  return {root, backupDir};
}
async function withLock(root, task) {
  const lock = path.join(root, '.lock');
  try { await fs.mkdir(lock, { mode: 0o700 }); } catch { fail('REPAIR_LOCKED'); }
  try {return await task();} finally {await fs.rmdir(lock);}
}
async function writeExclusive(file, bytes, mode = 0o600) {
  const f = await fs.open(file, 'wx', mode);
  try {await f.writeFile(bytes);await f.sync();} finally {await f.close();}
}
async function atomicReplace(dest, bytes, mode) {
  const temp = `${dest}.aimb-${process.pid}-${createHash('sha256').update(bytes).digest('hex').slice(0,12)}.tmp`;
  try {
    await writeExclusive(temp, bytes, mode & 0o777);
    await fs.rename(temp, dest);
  } finally {await fs.rm(temp, {force:true}).catch(()=>{});}
}
// APPLY is callable only by an owner-approved local client: a plan ID is NOT a remote authorization.
export async function applyCadence({agentRoot,stateRoot,target,expectedSha256,toSeconds,approvedPlanId}) {
  checkSha(approvedPlanId);
  const state = await makeStateRoot(stateRoot);
  return withLock(state.root, async () => {
    const plan = await planCadence({agentRoot,target,expectedSha256,toSeconds});
    if (plan.planId !== approvedPlanId) fail('HUMAN_APPROVAL_PLAN_MISMATCH');
    const current = await safeRead(agentRoot,target);
    if (current.hash !== plan.beforeSha256) fail('SOURCE_CHANGED_BEFORE_APPLY');
    const backupPath = path.join(state.backupDir, `${safeName(target,plan.planId)}.before`);
    const receiptPath = path.join(state.root,`${safeName(target,plan.planId)}.receipt.json`);
    try { await fs.lstat(receiptPath); fail('ALREADY_APPLIED'); } catch (e) {if(e.message !== 'ENOENT' && e.code !== 'ENOENT') throw e;}
    // A state/backup cannot be silently reused; a failed partial application needs manual recovery.
    await writeExclusive(backupPath,current.bytes,0o600);
    if (sha256(await fs.readFile(backupPath)) !== current.hash) fail('BACKUP_MISMATCH');
    const rewritten = current.bytes.toString('utf8').replace(plan.oldLine,plan.newLine);
    const next = Buffer.from(rewritten,'utf8');
    if (sha256(next) !== plan.afterSha256) fail('PLAN_OUTPUT_MISMATCH');
    if ((await safeRead(agentRoot,target)).hash !== plan.beforeSha256) fail('SOURCE_CHANGED_DURING_APPLY');
    await atomicReplace(current.file,next,current.stat.mode);
    if ((await safeRead(agentRoot,target)).hash !== plan.afterSha256) fail('POST_APPLY_SHA_MISMATCH');
    const receipt = {version:1,planId:plan.planId,target,beforeSha256:plan.beforeSha256,afterSha256:plan.afterSha256,backupFile:path.basename(backupPath),createdAt:new Date().toISOString(),restarted:false};
    await writeExclusive(receiptPath,Buffer.from(JSON.stringify(receipt,null,2)+'\n'),0o600);
    return Object.freeze({status:'applied_not_restarted',planId:plan.planId,target,sha256:plan.afterSha256,receiptFile:path.basename(receiptPath)});
  });
}
export async function verifyCadence({agentRoot,target,expectedSha256}) {
  checkSha(expectedSha256);
  const x=await inspectCadence({agentRoot,target});
  if(x.sha256 !== expectedSha256)fail('VERIFY_SHA_MISMATCH');
  return Object.freeze({status:'verified_file_only',...x});
}
export async function rollbackCadence({agentRoot,stateRoot,target,planId,approvedPlanId}) {
  getPolicy(target);checkSha(planId);checkSha(approvedPlanId);
  if(planId!==approvedPlanId)fail('HUMAN_APPROVAL_PLAN_MISMATCH');
  const state=await makeStateRoot(stateRoot);
  return withLock(state.root, async()=>{
    const key=safeName(target,planId);
    const receiptPath=path.join(state.root,`${key}.receipt.json`);
    const backupPath=path.join(state.backupDir,`${key}.before`);
    const rollbackPath=path.join(state.root,`${key}.rollback.json`);
    const receipt=JSON.parse(await fs.readFile(receiptPath,'utf8'));
    if(receipt.planId!==planId||receipt.target!==target||!SHA_RE.test(receipt.beforeSha256)||!SHA_RE.test(receipt.afterSha256)||receipt.backupFile!==path.basename(backupPath))fail('INVALID_RECEIPT');
    try {await fs.lstat(rollbackPath);fail('ALREADY_ROLLED_BACK');}catch(e){if(e.message!=='ENOENT'&&e.code!=='ENOENT')throw e;}
    const current=await safeRead(agentRoot,target);
    if(current.hash!==receipt.afterSha256)fail('ROLLBACK_SOURCE_CHANGED');
    const bstat=await fs.lstat(backupPath);
    if(!bstat.isFile()||bstat.isSymbolicLink()||bstat.nlink!==1)fail('UNSAFE_BACKUP');
    const before=await fs.readFile(backupPath);
    if(sha256(before)!==receipt.beforeSha256)fail('ROLLBACK_BACKUP_MISMATCH');
    await atomicReplace(current.file,before,current.stat.mode);
    if((await safeRead(agentRoot,target)).hash!==receipt.beforeSha256)fail('ROLLBACK_VERIFY_FAILED');
    await writeExclusive(rollbackPath,Buffer.from(JSON.stringify({version:1,planId,target,restoredSha256:receipt.beforeSha256,at:new Date().toISOString(),restarted:false},null,2)+'\n'));
    return Object.freeze({status:'rolled_back_not_restarted',target,sha256:receipt.beforeSha256});
  });
}
