# Offline integration candidate. This file has NO network, filesystem, or scheduler access.
# A trusted Windows caller must supply the existing authenticated/signed transport.
# Never source this file in the active agent without a separately audited install.
. (Join-Path $PSScriptRoot 'project-drain.ps1')

function Invoke-AimbProjectsSignedCycle {
 [CmdletBinding()]
 param(
  [Parameter(Mandatory=$true)][scriptblock]$PollSigned,
  [Parameter(Mandatory=$true)][scriptblock]$ReadProject,
  [Parameter(Mandatory=$true)][scriptblock]$SubmitSigned
 )
 $poll = { & $PollSigned }.GetNewClosure()
 $dispatch = {
  param($job)
  $parsed = ConvertFrom-Json -InputObject $job.args_json -ErrorAction Stop
  if($null -eq $parsed -or $parsed -isnot [pscustomobject]) { throw 'invalid_args' }
  # Never trust action supplied by JSON: use the already allowlisted job action.
  $parsed | Add-Member -MemberType NoteProperty -Name action -Value ([string]$job.action) -Force
  & $ReadProject $parsed
 }.GetNewClosure()
 $submit = {
  param($job,$result)
  & $SubmitSigned $job $result
 }.GetNewClosure()
 Invoke-AimbProjectDrain -Poll $poll -Dispatch $dispatch -SubmitResult $submit -MaxJobs 3
}
