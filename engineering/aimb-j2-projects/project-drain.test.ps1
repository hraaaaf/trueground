$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
. (Join-Path $PSScriptRoot 'project-drain.ps1')

function Assert-Equal($actual,$expected,[string]$name) {
 if($actual -ne $expected){throw ("TEST_FAIL_{0}: expected={1} actual={2}" -f $name,$expected,$actual)}
}
function Run-Fixture([int]$count,[string]$fault='none'){
 $script:q = New-Object 'System.Collections.Generic.Queue[object]'
 $script:polled=0
 $script:submitted=0
 $script:fault=$fault
 for($i=0;$i -lt $count;$i++){
  $id='00000000-0000-0000-0000-'+$i.ToString('D12')
  $action=if($fault -eq 'bad_action'){'exec'}else{'read_project_text'}
  $script:q.Enqueue([pscustomobject]@{id=$id;action=$action;args_json='{}'})
 }
 $poll={
  $script:polled++
  if($script:fault -eq 'poll_error'){throw 'fake_poll_error'}
  if($script:q.Count -eq 0){return [pscustomobject]@{command=$null}}
  return [pscustomobject]@{command=$script:q.Dequeue()}
 }
 $dispatch={
  param($job)
  if($script:fault -eq 'dispatch_error'){throw 'fake_dispatch_error'}
  return [pscustomobject]@{ok=$true;job_id=$job.id}
 }
 $submit={
  param($job,$result)
  $script:submitted++
  if($script:fault -eq 'result_error'){throw 'fake_result_error'}
  if($script:fault -eq 'ack_missing'){return [pscustomobject]@{received=$false}}
  return [pscustomobject]@{received=$true}
 }
 return Invoke-AimbProjectDrain -Poll $poll -Dispatch $dispatch -SubmitResult $submit -MaxJobs 3
}
$r=Run-Fixture 3
Assert-Equal $r.status 'drained' 'three-status'
Assert-Equal $r.polls 3 'three-polls'
Assert-Equal $r.processed 3 'three-processed'
Assert-Equal $r.acked 3 'three-acks'
Assert-Equal $script:submitted 3 'three-submit'
$r=Run-Fixture 1
Assert-Equal $r.processed 1 'one-processed'
Assert-Equal $r.polls 2 'one-plus-empty-poll'
Assert-Equal $r.reason 'empty' 'one-end-idle'
$r=Run-Fixture 0
Assert-Equal $r.polls 1 'idle-one-poll'
Assert-Equal $r.processed 0 'idle-none'
$r=Run-Fixture 2 'bad_action'
Assert-Equal $r.status 'no_go' 'bad-action-stop'
Assert-Equal $r.reason 'invalid_job' 'bad-action-reason'
Assert-Equal $r.processed 0 'bad-action-no-dispatch'
$r=Run-Fixture 2 'ack_missing'
Assert-Equal $r.status 'no_go' 'ack-stop'
Assert-Equal $r.reason 'ack_missing' 'ack-reason'
Assert-Equal $r.acked 0 'ack-no-credit'
Assert-Equal $r.polls 1 'ack-no-second-poll'
$r=Run-Fixture 2 'poll_error'
Assert-Equal $r.reason 'poll_error' 'transport-stop'
Assert-Equal $r.processed 0 'transport-no-dispatch'
$r=Run-Fixture 2 'dispatch_error'
Assert-Equal $r.reason 'dispatch_error' 'dispatch-stop'
Assert-Equal $script:submitted 0 'dispatch-no-submit'
$r=Run-Fixture 2 'result_error'
Assert-Equal $r.reason 'result_transport_error' 'result-stop'
Assert-Equal $r.polls 1 'result-no-next-poll'
Write-Output 'AIMB_J2_PROJECTS_OFFLINE_TESTS_PASS 8/8'
