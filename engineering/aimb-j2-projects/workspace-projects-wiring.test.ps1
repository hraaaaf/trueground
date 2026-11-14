$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
. (Join-Path $PSScriptRoot 'workspace-projects-wiring.ps1')
function Assert-True([bool]$ok,[string]$name){if(-not $ok){throw ('TEST_FAIL_'+$name)}}
function Assert-Throws([scriptblock]$f,[string]$name){
 $did=$false;try{& $f|Out-Null}catch{$did=$true};Assert-True $did $name
}
$src=@'
$root='fixture'
. (Join-Path $root 'project-read.ps1')
function Post-Signed {param($purpose,$payload,$channel)}
function Invoke-BridgeProjectRead {param($args)}
$x='keep_unrelated'
while($true){
 if(Test-Path -LiteralPath (Join-Path $root 'enable-project-tools.flag')){
  try{
   $pr=Post-Signed 'poll' @{} 'projects'
   if($pr.command){
    $data=Invoke-BridgeProjectRead $pr.command
    if($pr.command.action -eq 'exec'){Add-Content 'blocked_project_action'}
    $ack=Post-Signed 'result' $data 'projects'
   }
  }catch{}
 }
 Start-Sleep -Seconds 60
}
'@
$out=Convert-AimbWorkspaceProjectsSource $src
Assert-True ($out.Contains('project-signed-adapter.ps1')) 'import'
Assert-True ($out.Contains('Invoke-AimbProjectsSignedCycle')) 'cycle'
Assert-True ($out.Contains("Post-Signed 'poll'")) 'signed_poll'
Assert-True ($out.Contains("Post-Signed 'result'")) 'signed_result'
Assert-True ($out.Contains('Invoke-BridgeProjectRead')) 'restricted_reader'
Assert-True ($out.Contains('Start-Sleep -Seconds 60')) 'preserved_sleep'
Assert-True ($out.Contains('keep_unrelated')) 'preserved_other'
Assert-True (-not $out.Contains('if($pr.command)')) 'replaced'
Assert-Throws {Convert-AimbWorkspaceProjectsSource $out} 'no_double_patch'
Assert-Throws {Convert-AimbWorkspaceProjectsSource ($src.Replace('Start-Sleep -Seconds 60','Start-Sleep -Seconds 10'))} 'missing_boundary'
Assert-Throws {Convert-AimbWorkspaceProjectsSource ($src.Replace('project-read.ps1','missing.ps1'))} 'missing_import'
Assert-Throws {Convert-AimbWorkspaceProjectsSource ($src.Replace('blocked_project_action','wrong_action'))} 'drift'
Assert-Throws {Convert-AimbWorkspaceProjectsSource ($src+[char]10+' Start-Sleep -Seconds 60')} 'ambiguous'
Write-Output 'AIMB_J2_WIRING_OFFLINE_PASS 13/13'
