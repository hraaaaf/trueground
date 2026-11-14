# J2 strictly OFFLINE evidence contract.
# No file, process, task, network or registry I/O. This file never applies a patch.
function Test-AimbProjectsInstallEvidence {
 [CmdletBinding()]
 param(
  [Parameter(Mandatory=$true)][hashtable]$Manifest,
  [Parameter(Mandatory=$true)][hashtable]$Observation
 )
 $result=[ordered]@{status='NO_GO';reason='invalid_evidence';live_install_allowed=$false}
 $hashPattern='^[a-f0-9]{64}$'
 $taskNames=@('AI-Machine-Bridge-Presence','AI-Machine-Bridge-Commands','AI-Machine-Bridge-Files','AI-Machine-Bridge-Workspace')
 $requiredManifest=@('schema','action','target_name','source_sha256','candidate_sha256','backup_sha256','approval_kind')
 $requiredObservation=@('source_sha256','backup_sha256','root_reparse','target_reparse','unsafe_acl','task_identity_stable','task_names','task_run_levels')
 foreach($key in $requiredManifest){if(-not $Manifest.ContainsKey($key)){return [pscustomobject]$result}}
 foreach($key in $requiredObservation){if(-not $Observation.ContainsKey($key)){return [pscustomobject]$result}}
 # Explicitly fixture-only: a live installer must independently verify identities and signatures.
 if($Manifest.schema -cne 'aimb-j2-install-evidence-fixture-v1' -or
    $Manifest.action -cne 'projects-drain-only' -or
    $Manifest.target_name -cne 'workspace-agent.ps1' -or
    $Manifest.approval_kind -cne 'untrusted-fixture'){ $result.reason='unapproved_action';return [pscustomobject]$result }
 foreach($hash in @($Manifest.source_sha256,$Manifest.candidate_sha256,$Manifest.backup_sha256,$Observation.source_sha256,$Observation.backup_sha256)){
  if($hash -isnot [string] -or $hash -cnotmatch $hashPattern){$result.reason='invalid_hash';return [pscustomobject]$result}
 }
 if($Manifest.source_sha256 -cne $Observation.source_sha256){
  $result.reason='source_hash_mismatch';return [pscustomobject]$result
 }
 if($Manifest.backup_sha256 -cne $Observation.backup_sha256 -or
    $Manifest.backup_sha256 -cne $Manifest.source_sha256){
  $result.reason='backup_hash_mismatch';return [pscustomobject]$result
 }
 if($Manifest.source_sha256 -ceq $Manifest.candidate_sha256){
  $result.reason='no_op_or_candidate_collision';return [pscustomobject]$result
 }
 foreach($check in @('root_reparse','target_reparse','unsafe_acl')){
  if($Observation[$check] -isnot [bool] -or $Observation[$check] -eq $true){
   $result.reason='unsafe_filesystem';return [pscustomobject]$result
  }
 }
 if($Observation.task_identity_stable -isnot [bool] -or -not $Observation.task_identity_stable){
  $result.reason='task_identity_changed';return [pscustomobject]$result
 }
 $reported=@($Observation.task_names)
 if($reported.Count -ne 4 -or (@($reported | Sort-Object -Unique) -join '|') -cne (@($taskNames|Sort-Object -Unique) -join '|')){
  $result.reason='task_set_changed';return [pscustomobject]$result
 }
 $levels=@($Observation.task_run_levels)
 if($levels.Count -ne 4 -or @($levels|Where-Object {$_ -cne 'Limited'}).Count -gt 0){
  $result.reason='task_privilege_changed';return [pscustomobject]$result
 }
 $result.status='READY_FOR_OFFLINE_REVIEW'
 $result.reason='fixture_contract_pass'
 return [pscustomobject]$result
}
function Get-AimbProjectsRecoveryDirective {
 [CmdletBinding()]
 param([Parameter(Mandatory=$true)][ValidateSet('preflight','backup','stage','commit','verify','complete')][string]$Phase,
       [bool]$BackupVerified=$false,
       [bool]$CandidateCommitted=$false,
       [bool]$Incident=$false)
 # Advisory state only; never performs restoration or restarts Windows.
 if($Incident -and $CandidateCommitted){
  if($BackupVerified){return 'STOP_AND_REQUEST_LOCAL_RESTORE_REVIEW'}
  return 'STOP_CRITICAL_BACKUP_UNVERIFIED'
 }
 if($Incident){return 'STOP_NO_WRITE'}
 if($Phase -eq 'complete' -and $CandidateCommitted -and $BackupVerified){return 'REQUEST_LIVE_E2E_VERIFICATION'}
 return 'CONTINUE_OFFLINE_REVIEW_ONLY'
}
