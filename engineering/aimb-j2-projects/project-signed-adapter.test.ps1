$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
. (Join-Path $PSScriptRoot 'project-signed-adapter.ps1')
function Assert-True($condition,[string]$label) { if(-not $condition){throw ('FAIL_'+$label)} }
function Run-Case([int]$count,[string]$mode='normal') {
 $script:queue = New-Object 'System.Collections.Generic.Queue[object]'
 $script:seen = @()
 $script:acks = 0
 for($i=0;$i -lt $count;$i++){
  $id='00000000-0000-0000-0000-'+$i.ToString('D12')
  $json = if($mode -eq 'badjson') {'{broken'} else {'{"project_id":"bridge-agent","relative_path":"README.md","action":"exec"}'}
  $script:queue.Enqueue([pscustomobject]@{id=$id;action='read_project_text';args_json=$json})
 }
 $poll={ if($script:queue.Count -eq 0){return [pscustomobject]@{command=$null}}; [pscustomobject]@{command=$script:queue.Dequeue()} }
 $read={param($argsObject) $script:seen += $argsObject.action; [pscustomobject]@{ok=$true;content='fixture'} }
 $submit={param($job,$result) $script:acks++; if($mode -eq 'badack'){return [pscustomobject]@{received=$false}}; [pscustomobject]@{received=$true}}
 Invoke-AimbProjectsSignedCycle -PollSigned $poll -ReadProject $read -SubmitSigned $submit
}
$r=Run-Case 3
Assert-True ($r.status -eq 'drained' -and $r.processed -eq 3 -and $r.acked -eq 3) 'three_ack'
Assert-True ($script:seen.Count -eq 3 -and @($script:seen | Where-Object {$_ -cne 'read_project_text'}).Count -eq 0) 'json_action_overridden'
$r=Run-Case 1
Assert-True ($r.processed -eq 1 -and $r.polls -eq 2) 'one_plus_idle'
$r=Run-Case 0
Assert-True ($r.processed -eq 0 -and $r.polls -eq 1) 'empty_queue'
$r=Run-Case 2 'badjson'
Assert-True ($r.status -eq 'no_go' -and $r.acked -eq 0 -and $r.reason -eq 'dispatch_error') 'invalid_json'
$r=Run-Case 2 'badack'
Assert-True ($r.status -eq 'no_go' -and $r.acked -eq 0 -and $r.polls -eq 1) 'missing_ack'
Write-Output 'AIMB_J2_SIGNED_ADAPTER_OFFLINE_PASS 6/6'
