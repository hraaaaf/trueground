# OFFLINE WINDOWS FIXTURE ONLY. NEVER deploy this as an installer.
# Allows writes only inside a direct child of the process TEMP directory named AIMB_J2_Fixture_*.
# Not a native handle / ACL / TOCTOU hardened production implementation.
function Invoke-AimbProjectsFixtureTransaction {
 [CmdletBinding()]
 param(
  [Parameter(Mandatory=$true)][string]$FixtureRoot,
  [Parameter(Mandatory=$true)][string]$ExpectedOriginalSha256,
  [Parameter(Mandatory=$true)][string]$ExpectedCandidateSha256,
  [Parameter(Mandatory=$true)][string]$CandidateText,
  [ValidateSet('none','before_replace','after_replace')][string]$InjectFailure='none'
 )
 $result=[ordered]@{status='NO_GO';reason='preflight';restored=$false}
 $hashRe='^[a-f0-9]{64}$'
 if($ExpectedOriginalSha256 -cnotmatch $hashRe -or
    $ExpectedCandidateSha256 -cnotmatch $hashRe -or
    $ExpectedOriginalSha256 -ceq $ExpectedCandidateSha256){return [pscustomobject]$result}
 $temp=[IO.Path]::GetFullPath([IO.Path]::GetTempPath()).TrimEnd('\')
 $root=[IO.Path]::GetFullPath($FixtureRoot).TrimEnd('\')
 $parent=[IO.Path]::GetDirectoryName($root)
 if($parent -ine $temp -or
    -not ([IO.Path]::GetFileName($root) -cmatch '^AIMB_J2_Fixture_[A-Za-z0-9-]{8,80}$')){
  $result.reason='outside_fixture_boundary';return [pscustomobject]$result
 }
 $folder=Get-Item -LiteralPath $root -Force -ErrorAction SilentlyContinue
 if($null -eq $folder -or -not $folder.PSIsContainer -or
    ($folder.Attributes -band [IO.FileAttributes]::ReparsePoint)){
  $result.reason='unsafe_fixture_root';return [pscustomobject]$result
 }
 $target=Join-Path $root 'workspace-agent.ps1'
 $stage=Join-Path $root 'aimb-projects.stage'
 $backup=Join-Path $root 'aimb-projects.backup'
 $targetItem=Get-Item -LiteralPath $target -Force -ErrorAction SilentlyContinue
 if($null -eq $targetItem -or $targetItem.PSIsContainer -or
    ($targetItem.Attributes -band [IO.FileAttributes]::ReparsePoint) -or
    (Test-Path -LiteralPath $stage) -or (Test-Path -LiteralPath $backup)){
  $result.reason='unsafe_fixture_files';return [pscustomobject]$result
 }
 $oldHash=(Get-FileHash -LiteralPath $target -Algorithm SHA256).Hash.ToLowerInvariant()
 if($oldHash -cne $ExpectedOriginalSha256){
  $result.reason='original_hash_mismatch';return [pscustomobject]$result
 }
 $candidateBytes=(New-Object System.Text.UTF8Encoding($false,$true)).GetBytes($CandidateText)
 $sha=[Security.Cryptography.SHA256]::Create()
 try{$candidateHash=([BitConverter]::ToString($sha.ComputeHash($candidateBytes))).Replace('-','').ToLowerInvariant()}
 finally{$sha.Dispose()}
 if($candidateHash -cne $ExpectedCandidateSha256){
  $result.reason='candidate_hash_mismatch';return [pscustomobject]$result
 }
 $committed=$false
 try {
  $stream=[IO.File]::Open($stage,[IO.FileMode]::CreateNew,[IO.FileAccess]::Write,[IO.FileShare]::None)
  try{$stream.Write($candidateBytes,0,$candidateBytes.Length);$stream.Flush($true)}
  finally{$stream.Dispose()}
  if($InjectFailure -eq 'before_replace'){throw 'fault_before_replace'}
  # File.Replace creates a byte-exact backup during replacement (fixture only).
  [IO.File]::Replace($stage,$target,$backup)
  $committed=$true
  if($InjectFailure -eq 'after_replace'){throw 'fault_after_replace'}
  if((Get-FileHash -LiteralPath $target -Algorithm SHA256).Hash.ToLowerInvariant() -cne $candidateHash){throw 'candidate_verify_failed'}
  if((Get-FileHash -LiteralPath $backup -Algorithm SHA256).Hash.ToLowerInvariant() -cne $oldHash){throw 'backup_verify_failed'}
  $result.status='PASS_FIXTURE'
  $result.reason='synthetic_transaction_only'
 } catch {
  $result.reason='fixture_transaction_failed'
  if($committed){
   try {
    if((Get-FileHash -LiteralPath $backup -Algorithm SHA256).Hash.ToLowerInvariant() -cne $oldHash){
      throw 'backup_corrupted'
    }
    [IO.File]::Replace($backup,$target,$null)
    if((Get-FileHash -LiteralPath $target -Algorithm SHA256).Hash.ToLowerInvariant() -cne $oldHash){
      throw 'restored_hash_mismatch'
    }
    $result.restored=$true
    $result.reason='fixture_restored'
   } catch {$result.status='CRITICAL';$result.reason='rollback_failed'}
  }
 } finally {
  if(Test-Path -LiteralPath $stage){Remove-Item -LiteralPath $stage -Force -ErrorAction SilentlyContinue}
 }
 return [pscustomobject]$result
}
