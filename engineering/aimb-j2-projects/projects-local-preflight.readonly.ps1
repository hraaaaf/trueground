# Local READ-ONLY diagnostic prototype for the Windows owner.
# Not called by ChatGPT. No filesystem writes, Task Scheduler changes, or elevation.
# Output is diagnostic and NOT a race-free Win32/ACL attestation.
function Get-AimbProjectsLocalPreflight {
 [CmdletBinding()]
 param([Parameter(Mandatory=$true)][string]$AgentRoot)
 $dir=Get-Item -LiteralPath $AgentRoot -ErrorAction Stop
 if(-not $dir.PSIsContainer){throw 'not_agent_directory'}
 $linkFound=$false
 $cursor=$dir
 while($null -ne $cursor){
  if(($cursor.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0){$linkFound=$true}
  $cursor=$cursor.Parent
 }
 $files=@()
 foreach($name in @('workspace-agent.ps1','project-read.ps1','project-drain.ps1','project-signed-adapter.ps1')){
  $p=Join-Path $dir.FullName $name
  $item=Get-Item -LiteralPath $p -Force -ErrorAction SilentlyContinue
  if($null -eq $item){
   $files+= [ordered]@{name=$name;present=$false;reparse=$null;sha256=$null}
   continue
  }
  $reparse=(($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0)
  $digest=$null
  if(-not $reparse -and -not $linkFound -and -not $item.PSIsContainer){
   $digest=(Get-FileHash -LiteralPath $p -Algorithm SHA256 -ErrorAction Stop).Hash.ToLowerInvariant()
  }
  $files+= [ordered]@{name=$name;present=$true;reparse=$reparse;sha256=$digest}
 }
 $acl=Get-Acl -LiteralPath $dir.FullName -ErrorAction Stop
 $tasks=@()
 foreach($taskName in @('AI-Machine-Bridge-Presence','AI-Machine-Bridge-Commands','AI-Machine-Bridge-Files','AI-Machine-Bridge-Workspace')){
  try {
   $task=Get-ScheduledTask -TaskName $taskName -ErrorAction Stop
   $tasks+= [ordered]@{name=$taskName;present=$true;state=[string]$task.State;
       run_level=[string]$task.Principal.RunLevel}
  } catch {
   $tasks+= [ordered]@{name=$taskName;present=$false;state=$null;run_level=$null}
  }
 }
 return [pscustomobject][ordered]@{
  source='local_read_only_observation_not_attestation'
  agent_root=$dir.FullName
  ancestor_reparse_found=$linkFound
  root_acl_owner=$acl.Owner
  root_acl_rules_count=@($acl.Access).Count
  files=$files
  projects_flag_present=(Test-Path -LiteralPath (Join-Path $dir.FullName 'enable-project-tools.flag'))
  tasks=$tasks
  assessment='MANUAL_NATIVE_HANDLE_ACL_REPARSE_AND_PID_REVIEW_REQUIRED'
 }
}
