$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
Add-Type -Path (Join-Path $PSScriptRoot 'native-read-gate.cs')
$base=Join-Path $env:USERPROFILE 'AI_Machine_Bridge_DEV_FIXTURE'
$baseCreatedByTest=$false
if(Test-Path -LiteralPath $base){$baseItem=Get-Item -LiteralPath $base -Force;if(-not $baseItem.PSIsContainer -or ($baseItem.Attributes -band [IO.FileAttributes]::ReparsePoint)){throw 'FIXTURE_PARENT_UNSAFE'}}else{New-Item -ItemType Directory -Path $base | Out-Null;$baseCreatedByTest=$true}
$root=Join-Path $base ('fixture-' + [guid]::NewGuid().ToString('N'))
$outside=Join-Path $env:USERPROFILE ('AI_Machine_Bridge_DEV_FIXTURE_OUTSIDE_' + [guid]::NewGuid().ToString('N'))
$rootCreatedByTest=$false;$outsideCreatedByTest=$false;$rootJunctionCreatedByTest=$false;$parentLinkCreatedByTest=$false;$ancestorTargetCreatedByTest=$false
$rootJunction=$null;$parentLink=$null;$ancestorTarget=$null;$junctionPath=$null;$symbolicPath=$null;$hardlinkPath=$null;$sid=$null;$icacls=$null
$junctionReady=$false;$symbolicReady=$false;$hardlinkReady=$false;$rootJunctionReady=$false;$ancestorReady=$false
function Assert-TestTargetAbsent([string]$path){if(Test-Path -LiteralPath $path){throw 'TEST_TARGET_COLLISION'}}
$passed=0; $failed=0; $skipped=0; $detail=[Collections.Generic.List[object]]::new()
try {
function Check($name,[scriptblock]$action){ try { & $action; $script:passed++; $script:detail.Add(@{test=$name;result='PASS'}) } catch { $script:failed++; $script:detail.Add(@{test=$name;result='FAIL';error=$_.Exception.Message}) } }
function ExpectReject($name,[scriptblock]$action,[string]$pattern){ try { & $action; throw 'EXPECTED_REJECTION_NOT_RAISED' } catch { if($_.Exception.Message -eq 'EXPECTED_REJECTION_NOT_RAISED'){ $script:failed++;$script:detail.Add(@{test=$name;result='FAIL';error='EXPECTED_REJECTION_NOT_RAISED'}) } elseif($_.Exception.Message -match $pattern){$script:passed++;$script:detail.Add(@{test=$name;result='PASS'})} else {$script:failed++;$script:detail.Add(@{test=$name;result='FAIL';error="WRONG_REJECTION:$($_.Exception.Message)"})} } }
Assert-TestTargetAbsent $root;New-Item -ItemType Directory -Path $root | Out-Null;$rootCreatedByTest=$true
Assert-TestTargetAbsent $outside;New-Item -ItemType Directory -Path $outside | Out-Null;$outsideCreatedByTest=$true
[IO.File]::WriteAllText((Join-Path $root '.aimb-fixture.json'),'{"fixture":"aimb-dev-readonly-v1","project_id":"bridge-agent"}')
[IO.File]::WriteAllText((Join-Path $root 'safe.txt'),'fixture-safe')
[IO.File]::WriteAllBytes((Join-Path $root 'c-oversize.bin'),[byte[]]::new(131073))
[IO.File]::WriteAllText((Join-Path $root 'd-page-000.txt'),'page0')
[IO.File]::WriteAllText((Join-Path $root 'd-page-001.txt'),'page1')
[IO.File]::WriteAllText((Join-Path $root 'd-page-002.txt'),'page2')
[IO.File]::WriteAllText((Join-Path $outside 'outside.txt'),'OUTSIDE-WITNESS-DO-NOT-READ')
$junctionPath=Join-Path $root 'parent-junction'; $junctionReady=$false
try { Assert-TestTargetAbsent $junctionPath;New-Item -ItemType Junction -Path $junctionPath -Target $outside -ErrorAction Stop | Out-Null; $junctionReady=$true } catch { if($_.Exception.Message -eq 'TEST_TARGET_COLLISION'){throw};$skipped++;$detail.Add(@{test='parent-junction-setup';result='SKIP';reason=$_.Exception.Message}) }
$symbolicPath=Join-Path $root 'a-leaf-link.txt'; $symbolicReady=$false
try { Assert-TestTargetAbsent $symbolicPath;New-Item -ItemType SymbolicLink -Path $symbolicPath -Target (Join-Path $outside 'outside.txt') -ErrorAction Stop | Out-Null; $symbolicReady=$true } catch { if($_.Exception.Message -eq 'TEST_TARGET_COLLISION'){throw};$skipped++;$detail.Add(@{test='leaf-symlink-setup';result='SKIP';reason=$_.Exception.Message}) }
$hardlinkReady=$false
try {
  $native=@'
using System;using System.Runtime.InteropServices;public static class HardLinkTest{[DllImport("kernel32.dll",CharSet=CharSet.Unicode,SetLastError=true)]public static extern bool CreateHardLink(string n,string e,IntPtr s);}
'@
  Add-Type -TypeDefinition $native -ErrorAction SilentlyContinue
  $hardlinkPath=Join-Path $root 'b-outside-hardlink.txt';Assert-TestTargetAbsent $hardlinkPath;if(-not [HardLinkTest]::CreateHardLink($hardlinkPath,(Join-Path $outside 'outside.txt'),[IntPtr]::Zero)){throw 'HARDLINK_CREATE_FAILED'}
  $hardlinkReady=$true
} catch { $skipped++;$detail.Add(@{test='hardlink-setup';result='SKIP';reason=$_.Exception.Message}) }
$sid=[Security.Principal.WindowsIdentity]::GetCurrent().User.Value
$icacls=Join-Path $env:SystemRoot 'System32\icacls.exe'
& $icacls $root '/inheritance:r' '/grant:r' "*${sid}:(OI)(CI)(RX)" | Out-Null
if($LASTEXITCODE -ne 0){throw 'FIXTURE_ACL_SETUP_FAILED'}
  Check 'not-elevated' { if([NativeReadGate]::IsElevated()){throw 'ELEVATED_PROCESS_DENIED'} }
  $h=[NativeReadGate]::OpenRoot($root)
  [Console]::Error.WriteLine('NATIVE_ROOT_OPEN_PASS')
  try {
    Check 'pinned-root-final-path' { $actual=[NativeReadGate]::RootFinalPath($h).Replace('\\?\',''); if($actual -ne ([IO.Path]::GetFullPath($root).TrimEnd('\'))){throw 'ROOT_FINAL_PATH_MISMATCH'} }
    [Console]::Error.WriteLine('BEFORE_NATIVE_READ')
    Check 'native-read-valid-fixture' { $b=[NativeReadGate]::Read($h,'safe.txt',131072); if([Text.Encoding]::UTF8.GetString($b) -ne 'fixture-safe'){throw 'CONTENT_MISMATCH'} }
    [Console]::Error.WriteLine('AFTER_NATIVE_READ')
    ExpectReject 'path-traversal' { [NativeReadGate]::Read($h,'../outside/outside.txt',131072) } 'UNSAFE_PATH'
    ExpectReject 'oversize-file-rejected' { [NativeReadGate]::Read($h,'c-oversize.bin',131072) } 'FILE_SIZE_LIMIT'
    [Console]::Error.WriteLine('AFTER_TRAVERSAL_REJECT')
    if($junctionReady){ ExpectReject 'parent-junction-rejected' { [NativeReadGate]::Read($h,'parent-junction/outside.txt',131072) } 'NATIVE_OPEN_DENIED|REPARSE' }
    [Console]::Error.WriteLine('AFTER_JUNCTION_REJECT')
    if($symbolicReady){ ExpectReject 'leaf-symlink-rejected' { [NativeReadGate]::Read($h,'a-leaf-link.txt',131072) } 'NATIVE_OPEN_DENIED|REPARSE' }
    [Console]::Error.WriteLine('AFTER_SYMLINK_REJECT')
    if($hardlinkReady){ ExpectReject 'hardlink-rejected' { [NativeReadGate]::Read($h,'b-outside-hardlink.txt',131072) } 'HARDLINK_DENIED' }
    [Console]::Error.WriteLine('AFTER_HARDLINK_REJECT')
    Check 'pinned-root-denies-rename-substitution' { $moved=Join-Path $base 'moved-fixture';try{[IO.Directory]::Move($root,$moved);[IO.Directory]::Move($moved,$root);throw 'ROOT_RENAME_ALLOWED'}catch{if($_.Exception.Message -eq 'ROOT_RENAME_ALLOWED'){throw}} }
    Check 'concurrent-root-rename-race-fails-closed' {
      $job=Start-Job -ArgumentList $root,$base -ScriptBlock {
        param($raceRoot,$raceBase)
        $success=0
        for($i=0;$i -lt 40;$i++){
          $candidate=Join-Path $raceBase ('race-move-' + [guid]::NewGuid().ToString('N'))
          try { [IO.Directory]::Move($raceRoot,$candidate);$success++;[IO.Directory]::Move($candidate,$raceRoot) } catch { if((Test-Path -LiteralPath $candidate) -and -not (Test-Path -LiteralPath $raceRoot)){try{[IO.Directory]::Move($candidate,$raceRoot)}catch{}} }
          Start-Sleep -Milliseconds 2
        }
        $success
      }
      try {
        $reads=[NativeReadGate]::RepeatRead($h,'safe.txt',131072,250)
        $done=Wait-Job -Job $job -Timeout 8
        if(-not $done){throw 'RACE_JOB_TIMEOUT'}
        $successfulMoves=(Receive-Job -Job $job -ErrorAction Stop | Select-Object -Last 1)
        if($reads -ne 250 -or [int]$successfulMoves -ne 0 -or -not (Test-Path -LiteralPath $root)){throw 'CONCURRENT_ROOT_SUBSTITUTION_NOT_BLOCKED'}
      } finally {Stop-Job -Job $job -ErrorAction SilentlyContinue;Remove-Job -Job $job -Force -ErrorAction SilentlyContinue}
    }
    Check 'outside-witness-intact' { if([IO.File]::ReadAllText((Join-Path $outside 'outside.txt')) -ne 'OUTSIDE-WITNESS-DO-NOT-READ'){throw 'OUTSIDE_WITNESS_CHANGED'} }
  } finally { $h.Dispose() }
  $rootJunction=Join-Path $base ('fixture-' + [guid]::NewGuid().ToString('N'));$rootJunctionReady=$false
  try { Assert-TestTargetAbsent $rootJunction;New-Item -ItemType Junction -Path $rootJunction -Target $outside -ErrorAction Stop | Out-Null;$rootJunctionCreatedByTest=$true;$rootJunctionReady=$true } catch {if($_.Exception.Message -eq 'TEST_TARGET_COLLISION'){throw};$skipped++;$detail.Add(@{test='root-reparse-rejected';result='SKIP';reason=$_.Exception.Message})}
  if($rootJunctionReady){ExpectReject 'root-reparse-rejected' { [void][NativeReadGate]::OpenRoot($rootJunction) } 'ROOT_(COMPONENT_)?REPARSE_DENIED'}
  Check 'writable-acl-rejected' { $w=Join-Path $base ('fixture-' + [guid]::NewGuid().ToString('N'));$wCreated=$false;try{Assert-TestTargetAbsent $w;New-Item -ItemType Directory -Path $w | Out-Null;$wCreated=$true;try{[void][NativeReadGate]::OpenRoot($w);throw 'WRITABLE_ACL_ACCEPTED'}catch{if($_.Exception.Message -eq 'WRITABLE_ACL_ACCEPTED'){throw};if($_.Exception.Message -notmatch 'ACL_WRITE_ALLOWED'){throw}}}finally{if($wCreated -and (Test-Path -LiteralPath $w) -and -not ((Get-Item -LiteralPath $w -Force).Attributes -band [IO.FileAttributes]::ReparsePoint)){Remove-Item -LiteralPath $w -Force -Recurse}} }
  Check 'delete-child-only-acl-rejected' { $w=Join-Path $base ('fixture-' + [guid]::NewGuid().ToString('N'));$wCreated=$false;try{Assert-TestTargetAbsent $w;New-Item -ItemType Directory -Path $w | Out-Null;$wCreated=$true;& $icacls $w '/inheritance:r' '/grant:r' "*${sid}:(OI)(CI)(RX,DC)" | Out-Null;if($LASTEXITCODE -ne 0){throw 'DELETE_CHILD_ACL_SETUP_FAILED'};try{[void][NativeReadGate]::OpenRoot($w);throw 'DELETE_CHILD_ACL_ACCEPTED'}catch{if($_.Exception.Message -eq 'DELETE_CHILD_ACL_ACCEPTED'){throw};if($_.Exception.Message -notmatch 'ACL_WRITE_ALLOWED'){throw}}}finally{if($wCreated -and (Test-Path -LiteralPath $w) -and -not ((Get-Item -LiteralPath $w -Force).Attributes -band [IO.FileAttributes]::ReparsePoint)){& $icacls $w '/reset' '/T' '/C' | Out-Null;Remove-Item -LiteralPath $w -Force -Recurse -ErrorAction SilentlyContinue}} }
  $parentLink=Join-Path $base ('parent-link-' + [guid]::NewGuid().ToString('N'));$ancestorChild=Join-Path $parentLink ('fixture-' + [guid]::NewGuid().ToString('N'));$ancestorTarget=Join-Path $outside (Split-Path $ancestorChild -Leaf);$ancestorReady=$false
  Assert-TestTargetAbsent $ancestorTarget;New-Item -ItemType Directory -Path $ancestorTarget | Out-Null;$ancestorTargetCreatedByTest=$true
  try {Assert-TestTargetAbsent $parentLink;New-Item -ItemType Junction -Path $parentLink -Target $outside -ErrorAction Stop | Out-Null;$parentLinkCreatedByTest=$true;$ancestorReady=$true}catch{if($_.Exception.Message -eq 'TEST_TARGET_COLLISION'){throw};$skipped++;$detail.Add(@{test='ancestor-junction-root-open';result='SKIP';reason=$_.Exception.Message})}
  if($ancestorReady){ExpectReject 'ancestor-junction-root-open' { $mi=[NativeReadGate].GetMethod('OpenRootForTest',[Reflection.BindingFlags]'Static,NonPublic');$nativeArgs=New-Object object[] 2;$nativeArgs[0]=[string]$ancestorChild;$nativeArgs[1]=[string]$base;try{$mi.Invoke($null,$nativeArgs)|Out-Null}catch{throw $_.Exception.InnerException} } 'ROOT_COMPONENT_OPEN_DENIED|ROOT_COMPONENT_REPARSE_DENIED'}
  Check 'foreground-agent-surface-limits' { $scriptText=Get-Content -LiteralPath (Join-Path $PSScriptRoot 'foreground-readonly-agent.ps1') -Raw; if($scriptText -match '(?i)Invoke-WebRequest|Invoke-RestMethod|Start-Process|Set-Content|Add-Content|Remove-Item'){throw 'AGENT_HAS_SIDE_EFFECT_SURFACE'} }
  Check 'foreground-agent-list-read-and-no-shell' {
    $exe=(Get-Process -Id $PID).Path;$agent=Join-Path $PSScriptRoot 'foreground-readonly-agent.ps1'
    $commands=@('{"type":"list","offset":0,"limit":2}','{"type":"list","offset":2,"limit":2}','{"type":"list","offset":4,"limit":2}','{"type":"list","offset":6,"limit":2}','{"type":"read","path":"safe.txt"}','{"type":"exec","command":"whoami"}')
    $lines=$commands | & $exe -NoProfile -File $agent -FixtureRoot $root
    if($LASTEXITCODE -ne 0 -or $lines.Count -ne 6){throw 'AGENT_PROTOCOL_FAILED'}
    $page0=$lines[0]|ConvertFrom-Json;$page1=$lines[1]|ConvertFrom-Json;$page2=$lines[2]|ConvertFrom-Json;$page3=$lines[3]|ConvertFrom-Json;$read=$lines[4]|ConvertFrom-Json;$deny=$lines[5]|ConvertFrom-Json
    $pages=@($page1.files)+@($page2.files)+@($page3.files);$uniquePages=@($pages|Select-Object -Unique);$expectedPages=@('d-page-000.txt','d-page-001.txt','d-page-002.txt','safe.txt')
    if(-not $page0.ok -or $page0.files.Count -ne 0 -or $page0.next_offset -ne 2 -or -not $page1.ok -or $page1.next_offset -ne 4 -or -not $page2.ok -or ($page2.next_offset -ne $null -and $page2.next_offset -ne 6) -or -not $page3.ok -or $page3.next_offset -ne $null -or (($pages|Sort-Object) -join ',') -ne (($expectedPages|Sort-Object) -join ',') -or $uniquePages.Count -ne $pages.Count -or $page3.truncated -or -not $read.ok -or $read.content -ne 'fixture-safe' -or $deny.ok -or $deny.error -ne 'REQUEST_NOT_ALLOWLISTED'){throw "AGENT_POLICY_MISMATCH:$($lines -join '|')"}
  }
  $result=@{pass=$passed;fail=$failed;skip=$skipped;tests=$detail}
  $resultName='native-read-gate-results-' + $PSVersionTable.PSEdition + '.json'
  $result | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath (Join-Path $PSScriptRoot $resultName) -Encoding UTF8
  $result | ConvertTo-Json -Depth 6
  if($failed -ne 0){exit 1}
} finally {
  if($sid -and $rootCreatedByTest -and (Test-Path -LiteralPath $root) -and -not ((Get-Item -LiteralPath $root -Force).Attributes -band [IO.FileAttributes]::ReparsePoint)){ & $icacls $root '/grant:r' "*${sid}:(OI)(CI)(F)" | Out-Null }
  if($parentLinkCreatedByTest -and $parentLink -and (Test-Path -LiteralPath $parentLink) -and ((Get-Item -LiteralPath $parentLink -Force).Attributes -band [IO.FileAttributes]::ReparsePoint)){[IO.Directory]::Delete($parentLink)}
  if($rootJunctionCreatedByTest -and $rootJunction -and (Test-Path -LiteralPath $rootJunction) -and ((Get-Item -LiteralPath $rootJunction -Force).Attributes -band [IO.FileAttributes]::ReparsePoint)){[IO.Directory]::Delete($rootJunction)}
  if($junctionReady -and $junctionPath -and (Test-Path -LiteralPath $junctionPath) -and ((Get-Item -LiteralPath $junctionPath -Force).Attributes -band [IO.FileAttributes]::ReparsePoint)){[IO.Directory]::Delete($junctionPath)}
  if($symbolicReady -and $symbolicPath -and (Test-Path -LiteralPath $symbolicPath) -and ((Get-Item -LiteralPath $symbolicPath -Force).Attributes -band [IO.FileAttributes]::ReparsePoint)){[IO.File]::Delete($symbolicPath)}
  if($hardlinkReady -and $hardlinkPath -and (Test-Path -LiteralPath $hardlinkPath) -and -not ((Get-Item -LiteralPath $hardlinkPath -Force).Attributes -band [IO.FileAttributes]::ReparsePoint)){[IO.File]::Delete($hardlinkPath)}
  if($outsideCreatedByTest -and $outside -and (Test-Path -LiteralPath $outside) -and -not ((Get-Item -LiteralPath $outside -Force).Attributes -band [IO.FileAttributes]::ReparsePoint)){
    $witness=Join-Path $outside 'outside.txt';if(Test-Path -LiteralPath $witness){$wi=Get-Item -LiteralPath $witness -Force;if(-not $wi.PSIsContainer -and -not ($wi.Attributes -band [IO.FileAttributes]::ReparsePoint)){[IO.File]::Delete($witness)}}
    if($ancestorTargetCreatedByTest -and $ancestorTarget -and (Test-Path -LiteralPath $ancestorTarget) -and -not ((Get-Item -LiteralPath $ancestorTarget -Force).Attributes -band [IO.FileAttributes]::ReparsePoint) -and [IO.Directory]::GetFileSystemEntries($ancestorTarget).Length -eq 0){[IO.Directory]::Delete($ancestorTarget)}
    if([IO.Directory]::GetFileSystemEntries($outside).Length -eq 0){[IO.Directory]::Delete($outside)}
  }
  if($rootCreatedByTest -and (Test-Path -LiteralPath $root) -and -not ((Get-Item -LiteralPath $root -Force).Attributes -band [IO.FileAttributes]::ReparsePoint) -and [IO.Path]::GetDirectoryName([IO.Path]::GetFullPath($root)).TrimEnd('\') -eq [IO.Path]::GetFullPath($base).TrimEnd('\')){
    $marker=Join-Path $root '.aimb-fixture.json';$expectedMarker='{"fixture":"aimb-dev-readonly-v1","project_id":"bridge-agent"}'
    if((Test-Path -LiteralPath $marker) -and [IO.File]::ReadAllText($marker) -eq $expectedMarker -and [IO.Directory]::GetFileSystemEntries($root).Length -eq 6){Remove-Item -LiteralPath $root -Recurse -Force -ErrorAction SilentlyContinue}
  }
  if($baseCreatedByTest -and (Test-Path -LiteralPath $base) -and [IO.Directory]::GetFileSystemEntries($base).Length -eq 0){[IO.Directory]::Delete($base)}
}
