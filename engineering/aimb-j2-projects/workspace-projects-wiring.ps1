# Pure offline transformer: returns candidate text; never reads or writes Windows files.
function Convert-AimbWorkspaceProjectsSource {
 [CmdletBinding()]
 param([Parameter(Mandatory=$true)][string]$Source)
 $import=". (Join-Path "+'$root'+" 'project-read.ps1')"
 $start=" if(Test-Path -LiteralPath (Join-Path "+'$root'+" 'enable-project-tools.flag')){"
 $end=' Start-Sleep -Seconds 60'
 if(-not $Source.Contains($import) -or -not $Source.Contains('function Post-Signed') -or
    -not $Source.Contains('Invoke-BridgeProjectRead')){throw 'dependency_mismatch'}
 if($Source.Contains('project-signed-adapter.ps1')){throw 'already_wired'}
 $a=$Source.IndexOf($start,[StringComparison]::Ordinal)
 $z=$Source.IndexOf($end,[StringComparison]::Ordinal)
 if($a -lt 0 -or $z -lt $a){throw 'block_missing'}
 if($Source.IndexOf($start,$a+1,[StringComparison]::Ordinal) -ge 0 -or
    $Source.IndexOf($end,$z+1,[StringComparison]::Ordinal) -ge 0){throw 'ambiguous'}
 $old=$Source.Substring($a,$z-$a)
 foreach($required in @("Post-Signed 'poll'","Post-Signed 'result'",'Invoke-BridgeProjectRead','blocked_project_action')){
  if(-not $old.Contains($required)){throw 'block_drift'}
 }
 $new=@'
 if(Test-Path -LiteralPath (Join-Path $root 'enable-project-tools.flag')){
  try{
   $cycle=Invoke-AimbProjectsSignedCycle -PollSigned {
    Post-Signed 'poll' ([ordered]@{device_id=$config.device_id;purpose='poll';agent_version='0.6.0'}) 'projects'
   } -ReadProject {
    param($parsed)
    Invoke-BridgeProjectRead $parsed
   } -SubmitSigned {
    param($job,$data)
    $reply=[ordered]@{device_id=$config.device_id;purpose='result';agent_version='0.6.0';job_id=$job.id;action=$job.action;result=$data}
    $ack=Post-Signed 'result' $reply 'projects'
    if($ack.received){Add-Content -LiteralPath $log ((Get-Date).ToString('o')+' project='+$job.action+' ok='+$data.ok)}
    return $ack
   }
   if($cycle.status -eq 'no_go'){Add-Content -LiteralPath $log ((Get-Date).ToString('o')+' project_cycle_no_go='+$cycle.reason)}
  }catch{Add-Content -LiteralPath $log ((Get-Date).ToString('o')+' project_transport_error='+$_.Exception.GetType().Name)}
 }
'@
 $nl=if($Source.Contains(([string][char]13+[char]10))){[string][char]13+[char]10}else{[string][char]10}
 $new=$new.Replace(([string][char]13+[char]10),([string][char]10)).Replace(([string][char]10),$nl).TrimEnd([char]13,[char]10)+$nl
 $result=$Source.Substring(0,$a)+$new+$Source.Substring($z)
 $result=$result.Replace($import,$import+$nl+". (Join-Path "+'$root'+" 'project-signed-adapter.ps1')")
 if($result -eq $Source){throw 'no_change'}
 return $result
}
