$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
. (Join-Path $PSScriptRoot 'projects-fixture-transaction.ps1')
function Assert-Equal($got,$want,[string]$label){
 if($got -cne $want){throw ("FAIL {0} expected={1} got={2}" -f $label,$want,$got)}
}
function New-Fixture {
 $dir=Join-Path ([IO.Path]::GetTempPath()) ('AIMB_J2_Fixture_'+[guid]::NewGuid().ToString('N'))
 [void](New-Item -ItemType Directory -Path $dir -ErrorAction Stop)
 [IO.File]::WriteAllText((Join-Path $dir 'workspace-agent.ps1'),'original', (New-Object System.Text.UTF8Encoding($false)))
 return $dir
}
function Hash-Text([string]$s){
 $sha=[Security.Cryptography.SHA256]::Create()
 try{return ([BitConverter]::ToString($sha.ComputeHash([Text.Encoding]::UTF8.GetBytes($s)))).Replace('-','').ToLowerInvariant()}
 finally{$sha.Dispose()}
}
$old=Hash-Text 'original'
$new=Hash-Text 'candidate'
$root=New-Fixture
try {
 $r=Invoke-AimbProjectsFixtureTransaction -FixtureRoot $root -ExpectedOriginalSha256 $old -ExpectedCandidateSha256 $new -CandidateText 'candidate'
 Assert-Equal $r.status 'PASS_FIXTURE' 'replace_pass'
 Assert-Equal ((Get-FileHash (Join-Path $root 'workspace-agent.ps1') -Algorithm SHA256).Hash.ToLowerInvariant()) $new 'target_candidate'
 Assert-Equal ((Get-FileHash (Join-Path $root 'aimb-projects.backup') -Algorithm SHA256).Hash.ToLowerInvariant()) $old 'backup_original'
 $r=Invoke-AimbProjectsFixtureTransaction -FixtureRoot $root -ExpectedOriginalSha256 $old -ExpectedCandidateSha256 $new -CandidateText 'candidate'
 Assert-Equal $r.reason 'unsafe_fixture_files' 'deny_reapply_with_backup'
} finally {Remove-Item -LiteralPath $root -Recurse -Force}
$root=New-Fixture
try{
 $r=Invoke-AimbProjectsFixtureTransaction -FixtureRoot $root -ExpectedOriginalSha256 ('f'*64) -ExpectedCandidateSha256 $new -CandidateText 'candidate'
 Assert-Equal $r.reason 'original_hash_mismatch' 'deny_wrong_original'
 Assert-Equal ((Get-FileHash (Join-Path $root 'workspace-agent.ps1') -Algorithm SHA256).Hash.ToLowerInvariant()) $old 'preserve_original'
 $r=Invoke-AimbProjectsFixtureTransaction -FixtureRoot $root -ExpectedOriginalSha256 $old -ExpectedCandidateSha256 ('f'*64) -CandidateText 'candidate'
 Assert-Equal $r.reason 'candidate_hash_mismatch' 'deny_wrong_candidate'
 $r=Invoke-AimbProjectsFixtureTransaction -FixtureRoot $root -ExpectedOriginalSha256 $old -ExpectedCandidateSha256 $old -CandidateText 'original'
 Assert-Equal $r.reason 'preflight' 'deny_digest_collision'
 [IO.File]::WriteAllText((Join-Path $root 'aimb-projects.stage'),'stale')
 $r=Invoke-AimbProjectsFixtureTransaction -FixtureRoot $root -ExpectedOriginalSha256 $old -ExpectedCandidateSha256 $new -CandidateText 'candidate'
 Assert-Equal $r.reason 'unsafe_fixture_files' 'deny_stale_stage'
 [IO.File]::Delete((Join-Path $root 'aimb-projects.stage'))
 $r=Invoke-AimbProjectsFixtureTransaction -FixtureRoot $root -ExpectedOriginalSha256 $old -ExpectedCandidateSha256 $new -CandidateText 'candidate' -InjectFailure before_replace
 Assert-Equal $r.status 'NO_GO' 'precommit_aborted'
 Assert-Equal ((Get-FileHash (Join-Path $root 'workspace-agent.ps1') -Algorithm SHA256).Hash.ToLowerInvariant()) $old 'precommit_original'
 $r=Invoke-AimbProjectsFixtureTransaction -FixtureRoot $root -ExpectedOriginalSha256 $old -ExpectedCandidateSha256 $new -CandidateText 'candidate' -InjectFailure after_replace
 Assert-Equal $r.restored $true 'postcommit_rollback'
 Assert-Equal ((Get-FileHash (Join-Path $root 'workspace-agent.ps1') -Algorithm SHA256).Hash.ToLowerInvariant()) $old 'rollback_byte_hash'
} finally {Remove-Item -LiteralPath $root -Recurse -Force}
$r=Invoke-AimbProjectsFixtureTransaction -FixtureRoot ([IO.Path]::GetTempPath()) -ExpectedOriginalSha256 $old -ExpectedCandidateSha256 $new -CandidateText 'candidate'
 Assert-Equal $r.reason 'outside_fixture_boundary' 'deny_nontemp_root'
Write-Output 'AIMB_J2_FIXTURE_TRANSACTION_PASS 14/14'
