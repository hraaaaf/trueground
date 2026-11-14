# AI Machine Bridge P0: local installer for an INERT offline-only repair prototype.
# It never updates agent scripts, Tasks, Cloudflare, Auth0, MCP, or production services.
[CmdletBinding()]
param(
 [switch]$Install,
 [ValidatePattern('^[a-f0-9]{40}$')][string]$ExpectedCommit
)
$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
if($PSVersionTable.PSVersion.Major -lt 5){throw 'NO_GO_POWERSHELL_VERSION'}
if($env:OS -ne 'Windows_NT'){throw 'NO_GO_WINDOWS_ONLY'}
$sourceDir=Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot=(Resolve-Path (Join-Path $sourceDir '..\..\..')).Path
$destination=Join-Path $env:USERPROFILE 'AI_Machine_Bridge_SelfRepair_P0'
$files=@('cadence-core.mjs','repair-cli.mjs','README.md')
$node=Get-Command node -ErrorAction Stop
$version=& $node.Source -p 'process.versions.node'
if($LASTEXITCODE -ne 0 -or ([version]$version).Major -lt 22){throw 'NO_GO_NODE22_REQUIRED'}
$git=Get-Command git -ErrorAction Stop
$head=(& $git.Source -C $repoRoot rev-parse HEAD).Trim().ToLowerInvariant()
if($LASTEXITCODE -ne 0 -or $head -notmatch '^[a-f0-9]{40}$'){throw 'NO_GO_GIT_HEAD'}
$dirty=@(& $git.Source -C $repoRoot status --porcelain)
if($LASTEXITCODE -ne 0 -or $dirty.Count -ne 0){throw 'NO_GO_DIRTY_CHECKOUT'}
if(-not $ExpectedCommit -or $head -ne $ExpectedCommit){throw 'NO_GO_UNREVIEWED_COMMIT'}
function Get-Sha256Hex {
 param([Parameter(Mandatory=$true)][string]$LiteralPath)
 $stream=[System.IO.File]::OpenRead($LiteralPath)
 $sha=[System.Security.Cryptography.SHA256]::Create()
 try {
  $digest=$sha.ComputeHash($stream)
  ([System.BitConverter]::ToString($digest)).Replace('-','').ToLowerInvariant()
 } finally {
  $sha.Dispose()
  $stream.Dispose()
 }
}
$hashes=@{}
foreach($name in $files){
 $file=Join-Path $sourceDir $name
 if(-not(Test-Path -LiteralPath $file -PathType Leaf)){throw ('NO_GO_MISSING_'+$name)}
 $hashes[$name]=(Get-Sha256Hex -LiteralPath $file)
}
if(Test-Path -LiteralPath $destination){throw 'NO_GO_DESTINATION_ALREADY_EXISTS'}
Write-Output ('AIMB_P0_PREFLIGHT_OK HEAD='+$head+' DEST='+$destination)
foreach($name in $files){Write-Output ('SOURCE_SHA256 '+$name+' '+$hashes[$name])}
if(-not $Install){Write-Output 'DRY_RUN_ONLY: no files or tasks changed; use -Install after human review.';return}
try{
 New-Item -Path $destination -ItemType Directory -ErrorAction Stop | Out-Null
 foreach($name in $files){Copy-Item -LiteralPath (Join-Path $sourceDir $name) -Destination (Join-Path $destination $name) -ErrorAction Stop}
 foreach($name in $files){
  $copied=(Get-Sha256Hex -LiteralPath (Join-Path $destination $name))
  if($copied -ne $hashes[$name]){throw ('NO_GO_COPY_SHA_'+$name)}
 }
}catch{
 # Only delete this isolated folder; do not touch the running Bridge agent.
 if(Test-Path -LiteralPath $destination){Remove-Item -LiteralPath $destination -Recurse -Force -ErrorAction SilentlyContinue}
 throw
}
Write-Output 'AIMB_P0_INSTALLED_INERT_ONLY: no Windows task restarted, no MCP endpoint added, no patch applied.'
