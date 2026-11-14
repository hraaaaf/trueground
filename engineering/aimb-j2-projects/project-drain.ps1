# J2 Projects bounded sequential drain — OFFLINE candidate only.
# Intended to be called by the existing signed workspace-agent poller AFTER separate owner GO.
# This file is pure orchestration: no files, network, task scheduler or cloud operations.
# All I/O must be injected as reviewed scriptblocks by a later authorized integration.
function Invoke-AimbProjectDrain {
 [CmdletBinding()]
 param(
  [Parameter(Mandatory=$true)][scriptblock]$Poll,
  [Parameter(Mandatory=$true)][scriptblock]$Dispatch,
  [Parameter(Mandatory=$true)][scriptblock]$SubmitResult,
  [ValidateRange(1,3)][int]$MaxJobs=3
 )
 $status=[ordered]@{status='idle';polls=0;processed=0;acked=0;reason='empty'}
 for($i=0;$i -lt $MaxJobs;$i++){
  try {$response=& $Poll} catch {$status.status='no_go';$status.reason='poll_error';break}
  $status.polls++
  if($null -eq $response -or $null -eq $response.command){break}
  $job=$response.command
  if($null -eq $job.id -or ([string]$job.id) -cnotmatch '^[a-f0-9-]{36}$' -or
     $job.action -cnotin @('list_project_files','read_project_text') -or
     $job.args_json -isnot [string] -or $job.args_json.Length -gt 512){
   $status.status='no_go';$status.reason='invalid_job';break
  }
  try {$result=& $Dispatch $job} catch {$status.status='no_go';$status.reason='dispatch_error';break}
  $status.processed++
  try {$ack=& $SubmitResult $job $result} catch {$status.status='no_go';$status.reason='result_transport_error';break}
  if($null -eq $ack -or $ack.received -ne $true){
   $status.status='no_go';$status.reason='ack_missing';break
  }
  $status.acked++
  $status.status='drained'
  $status.reason='max_jobs'
 }
 return [pscustomobject]$status
}
