# AI Machine Bridge J1-H: isolated local Windows validation. No task or deployment changes.
# Default: only download vetted public test code, pin SHA-256 and run offline tests.
# Opt-in -RunStaging: connects ONLY to the hard-pinned staging fixture with LOCAL RSA key.
[CmdletBinding()]
param([switch]$RunStaging)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$git=(Get-Command git -ErrorAction Stop).Source
$node=(Get-Command node -ErrorAction Stop).Source
$branch='chore/aimb-j1h-github-actions-validation'
$repo='https://github.com/hraaaaf/trueground.git'
$root=Join-Path $env:TEMP ('AIMB_J1H_V074_GATE_'+[guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $root -Force | Out-Null
$checkout=Join-Path $root 'readonly-source'
Write-Output ('GOAL: J1-H V074 Windows isolated staging. PROOF_DIR='+$root)
& $git clone --quiet --single-branch --depth 1 --branch $branch $repo $checkout
if($LASTEXITCODE -ne 0){throw 'GIT_CLONE_FAILED'}
$src=Join-Path $checkout 'engineering/aimb-j1h/src'
$expected=@{
  'e2e-windows-runner.mjs'='c2d9662d388be15b31d8360999e07c4d2a44d5885d1a9599975938e56b7ca0c7'
  'e2e-windows-runner.test.mjs'='0977a96d9e1b97f1066046d2fd9568b91e61ca58725af7019f673828f5ad6e40'
  'observability-v073.test.mjs'='f78b9041edcb9824a9a8c87ec188b8ce7d4c06fd6d97acd2b1ccf4862e2d328a'
  'poll-scheduler.mjs'='c4d9270cd1dcd29685d0c1d2a838d4d1683b5d47f4f1b812a4e06496af300e24'
  'poll-scheduler.test.mjs'='5d2452c9e24096a4a8dc8baaea6ae6b4d8961daaaf383332af753ca34a4897b0'
  'startup-v074.test.mjs'='963cc46618250357f33f3906967e986a348c950d352f7621ff65b9d6407ad382'
  'supervisor-v07.mjs'='fbc0674f592880f8b3f91bbfe80cad7dd19f8a276fb9329bdd67a027aea9d136'
  'supervisor-v07.test.mjs'='1195f9e1432270336a569dfbf9c17ef354a8bbb88c48f6a0393714fb7676adbf'
}
foreach($file in $expected.Keys){
  $p=Join-Path $src $file
  if(-not(Test-Path -LiteralPath $p -PathType Leaf)){throw ('MISSING_SOURCE_'+$file)}
  $sha=(Get-FileHash -LiteralPath $p -Algorithm SHA256).Hash.ToLowerInvariant()
  if($sha -ne $expected[$file]){throw ('SHA_MISMATCH_'+$file)}
}
Write-Output 'SUCCESS: all eight source SHA-256 exact.'
Push-Location $src
try {
  & $node --check supervisor-v07.mjs
  if($LASTEXITCODE -ne 0){throw 'SYNTAX_SUPERVISOR_FAIL'}
  & $node --check e2e-windows-runner.mjs
  if($LASTEXITCODE -ne 0){throw 'SYNTAX_RUNNER_FAIL'}
  & $node --test 1> (Join-Path $root 'tests.stdout.txt') 2> (Join-Path $root 'tests.stderr.txt')
  if($LASTEXITCODE -ne 0){throw 'OFFLINE_TESTS_FAIL'}
} finally { Pop-Location }
$testlog=Get-Content -LiteralPath (Join-Path $root 'tests.stdout.txt') -Raw
if($testlog -notmatch '(?m)^(?:#|ℹ) tests 80\s*$' -or $testlog -notmatch '(?m)^(?:#|ℹ) fail 0\s*$'){
  throw 'EXPECTED_78_TESTS_NOT_PROVEN'
}
Write-Output 'SUCCESS: 80/80 offline tests, no Windows task changes.'
if(-not $RunStaging){
  Write-Output ('NO-GO live test not requested. Run again with -RunStaging after staging V7 verification. PROOF_DIR='+$root)
  exit 0
}
if(-not $env:AIMB_J1H_PRIVATE_KEY_PATH){throw 'LOCAL_FIXTURE_KEY_ENV_REQUIRED'}
if(-not(Test-Path -LiteralPath $env:AIMB_J1H_PRIVATE_KEY_PATH -PathType Leaf)){throw 'LOCAL_FIXTURE_KEY_FILE_REQUIRED'}
Write-Output 'STAGING ONLY: local fixture key verified as regular file. No fixture creation.'

function Run-Supervisor([int]$seconds){
  $stdout=Join-Path $root ('supervisor-'+$seconds+'.stdout.txt')
  $stderr=Join-Path $root ('supervisor-'+$seconds+'.stderr.txt')
  $proc=Start-Process -FilePath $node -WorkingDirectory $src -ArgumentList @('--trace-uncaught','supervisor-v07.mjs','--duration-sec',"$seconds") -NoNewWindow -PassThru -RedirectStandardOutput $stdout -RedirectStandardError $stderr
  try { Wait-Process -Id $proc.Id -Timeout ($seconds+36) -ErrorAction Stop }
  catch {
    Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue
    throw ('SUPERVISOR_HARD_TIMEOUT_'+$seconds)
  }
  $proc.Refresh()
  if($proc.ExitCode -ne 0){throw ('SUPERVISOR_EXIT_NONZERO_'+$seconds+'_LOGS='+$root)}
  $trace=Get-Content -LiteralPath $stdout -Raw
  foreach($marker in @('STAGE_BOOT','"type":"supervisor_started"','"type":"websocket_connected"','"type":"poll_started"','"type":"poll_finished"')){
    if(-not $trace.Contains($marker)){throw ('SUPERVISOR_MISSING_EVENT_'+$seconds+'_'+$marker)}
  }
  Write-Output ('SUCCESS: staging supervisor '+$seconds+' seconds, WSS and poll observed. Logs: '+$stdout)
}
Run-Supervisor 70
Run-Supervisor 180
Write-Output ('SUCCESS: J1-H local staging diagnostics 70s + 180s. PROOF_DIR='+$root)
Write-Output 'Review pollTrace reasons including +5.1s and independently verify D1/DO and four tasks before human GO.'
