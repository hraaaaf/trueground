$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
. (Join-Path $PSScriptRoot 'install-evidence-contract.ps1')
function Fixture {
 $tasks=@('AI-Machine-Bridge-Presence','AI-Machine-Bridge-Commands','AI-Machine-Bridge-Files','AI-Machine-Bridge-Workspace')
 $manifest=@{schema='aimb-j2-install-evidence-fixture-v1';action='projects-drain-only';
  target_name='workspace-agent.ps1';source_sha256=('a'*64);candidate_sha256=('b'*64);
  backup_sha256=('a'*64);approval_kind='untrusted-fixture'}
 $observed=@{source_sha256=('a'*64);backup_sha256=('a'*64);
  root_reparse=$false;target_reparse=$false;unsafe_acl=$false;task_identity_stable=$true;
  task_names=$tasks;task_run_levels=@('Limited','Limited','Limited','Limited')}
 return @{manifest=$manifest;observation=$observed}
}
function Assert-Equal($got,$want,[string]$name) {
 if($got -cne $want){throw ('FAIL '+$name+' expected='+$want+' actual='+$got)}
}
function Result($f) {return Test-AimbProjectsInstallEvidence -Manifest $f.manifest -Observation $f.observation}
$f=Fixture
$r=Result $f
Assert-Equal $r.status 'READY_FOR_OFFLINE_REVIEW' 'valid_fixture'
Assert-Equal $r.live_install_allowed $false 'never_grant_live'
$f=Fixture;$f.manifest.approval_kind='self_approved'
Assert-Equal (Result $f).reason 'unapproved_action' 'deny_approval'
$f=Fixture;$f.observation.source_sha256=('c'*64)
Assert-Equal (Result $f).reason 'source_hash_mismatch' 'deny_source_drift'
$f=Fixture;$f.observation.backup_sha256=('c'*64)
Assert-Equal (Result $f).reason 'backup_hash_mismatch' 'deny_corrupt_backup'
$f=Fixture;$f.manifest.candidate_sha256=('a'*64)
Assert-Equal (Result $f).reason 'no_op_or_candidate_collision' 'deny_collision'
$f=Fixture;$f.observation.root_reparse=$true
Assert-Equal (Result $f).reason 'unsafe_filesystem' 'deny_junction_root'
$f=Fixture;$f.observation.target_reparse=$true
Assert-Equal (Result $f).reason 'unsafe_filesystem' 'deny_symlink_target'
$f=Fixture;$f.observation.unsafe_acl=$true
Assert-Equal (Result $f).reason 'unsafe_filesystem' 'deny_acl'
$f=Fixture;$f.observation.task_names=@('AI-Machine-Bridge-Workspace')
Assert-Equal (Result $f).reason 'task_set_changed' 'deny_missing_tasks'
$f=Fixture;$f.observation.task_identity_stable=$false
Assert-Equal (Result $f).reason 'task_identity_changed' 'deny_task_drift'
$f=Fixture;$f.observation.task_run_levels=@('Limited','Limited','Highest','Limited')
Assert-Equal (Result $f).reason 'task_privilege_changed' 'deny_elevation'
$f=Fixture;$f.manifest.candidate_sha256='BAD'
Assert-Equal (Result $f).reason 'invalid_hash' 'deny_bad_digest'
$f=Fixture;$f.manifest.Remove('target_name')
Assert-Equal (Result $f).reason 'invalid_evidence' 'deny_missing_field'
Assert-Equal (Get-AimbProjectsRecoveryDirective -Phase 'stage' -Incident $true) 'STOP_NO_WRITE' 'precommit_abort'
Assert-Equal (Get-AimbProjectsRecoveryDirective -Phase 'verify' -Incident $true -CandidateCommitted $true -BackupVerified $true) 'STOP_AND_REQUEST_LOCAL_RESTORE_REVIEW' 'restore_review'
Assert-Equal (Get-AimbProjectsRecoveryDirective -Phase 'verify' -Incident $true -CandidateCommitted $true) 'STOP_CRITICAL_BACKUP_UNVERIFIED' 'critical_unbacked'
Assert-Equal (Get-AimbProjectsRecoveryDirective -Phase 'complete' -CandidateCommitted $true -BackupVerified $true) 'REQUEST_LIVE_E2E_VERIFICATION' 'e2e_still_required'
Write-Output 'AIMB_J2_INSTALL_EVIDENCE_OFFLINE_PASS 18/18'
