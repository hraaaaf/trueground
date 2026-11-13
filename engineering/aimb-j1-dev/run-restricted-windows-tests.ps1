param(
  [Parameter(Mandatory=$true)]
  [ValidateSet('Node','PowerShell7','PowerShell51')]
  [string]$Suite
)
$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot
Set-Location -LiteralPath $root

switch ($Suite) {
  'Node' {
    $exe = (Get-Command node.exe -ErrorAction Stop).Source
    $testArgs = @('--test','--test-reporter=spec') + @(Get-ChildItem -LiteralPath $root -Recurse -Filter '*.test.mjs' -File | ForEach-Object { $_.FullName })
  }
  'PowerShell7' {
    $exe = (Get-Command pwsh.exe -ErrorAction Stop).Source
    $testArgs = @('-NoProfile','-NonInteractive','-File',(Join-Path $root 'native-read-gate.test.ps1'))
  }
  'PowerShell51' {
    $exe = (Get-Command powershell.exe -ErrorAction Stop).Source
    $testArgs = @('-NoProfile','-NonInteractive','-ExecutionPolicy','Bypass','-File',(Join-Path $root 'native-read-gate.test.ps1'))
  }
}

$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = [Security.Principal.WindowsPrincipal]::new($identity)
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
  & $exe @testArgs
  exit $LASTEXITCODE
}

# GitHub-hosted Windows jobs run elevated, while the candidate intentionally fails closed there.
# Create a disposable standard account for this fixed test suite and remove it in finally.
Import-Module Microsoft.PowerShell.LocalAccounts -ErrorAction Stop
$username = 'ac' + [guid]::NewGuid().ToString('N').Substring(0,16)
$plainPassword = [guid]::NewGuid().ToString('N') + [guid]::NewGuid().ToString('N') + 'Aa1!'
$password = ConvertTo-SecureString $plainPassword -AsPlainText -Force
$plainPassword = $null
$account = $null
$rootAcl = $null
$logAcl = $null
$rootRule = $null
$logRule = $null
$logDir = Join-Path $env:RUNNER_TEMP ("aimb-test-" + [guid]::NewGuid().ToString('N'))
$started = $false
try {
  $account = New-LocalUser -Name $username -Password $password -Description 'Ephemeral AIMB offline CI test account' -AccountNeverExpires -PasswordNeverExpires
  $sid = $account.SID
  $adminGroup = Get-LocalGroup | Where-Object { $_.SID.Value -eq 'S-1-5-32-544' }
  if (-not $adminGroup) { throw 'ADMIN_GROUP_NOT_FOUND' }
  $adminMember = Get-LocalGroupMember -Group $adminGroup.Name | Where-Object { $_.SID.Value -eq $sid.Value }
  if ($adminMember) { throw 'TEST_ACCOUNT_MUST_NOT_BE_ADMIN' }
  $usersGroup = Get-LocalGroup | Where-Object { $_.SID.Value -eq 'S-1-5-32-545' }
  if (-not $usersGroup) { throw 'USERS_GROUP_NOT_FOUND' }
  $userMember = Get-LocalGroupMember -Group $usersGroup.Name | Where-Object { $_.SID.Value -eq $sid.Value }
  if (-not $userMember) { Add-LocalGroupMember -Group $usersGroup.Name -Member $username }

  $rootAcl = Get-Acl -LiteralPath $root
  $rootRule = [System.Security.AccessControl.FileSystemAccessRule]::new($sid,'ReadAndExecute','ContainerInherit,ObjectInherit','None','Allow')
  [void]$rootAcl.AddAccessRule($rootRule)
  Set-Acl -LiteralPath $root -AclObject $rootAcl

  New-Item -ItemType Directory -Path $logDir -Force | Out-Null
  $logAcl = Get-Acl -LiteralPath $logDir
  $logRule = [System.Security.AccessControl.FileSystemAccessRule]::new($sid,'Modify','ContainerInherit,ObjectInherit','None','Allow')
  [void]$logAcl.AddAccessRule($logRule)
  Set-Acl -LiteralPath $logDir -AclObject $logAcl

  $stdout = Join-Path $logDir "$Suite.stdout.txt"
  $stderr = Join-Path $logDir "$Suite.stderr.txt"
  $argumentLine = ($testArgs | ForEach-Object { '"' + ([string]$_).Replace('"','\"') + '"' }) -join ' '
  $credential = [PSCredential]::new("$env:COMPUTERNAME\$username",$password)
  $process = Start-Process -FilePath $exe -ArgumentList $argumentLine -Credential $credential -LoadUserProfile -WorkingDirectory $root -RedirectStandardOutput $stdout -RedirectStandardError $stderr -PassThru -Wait -WindowStyle Hidden
  $started = $true
  if (Test-Path -LiteralPath $stdout) { Get-Content -LiteralPath $stdout }
  if ((Test-Path -LiteralPath $stderr) -and (Get-Item -LiteralPath $stderr).Length -gt 0) { Get-Content -LiteralPath $stderr | ForEach-Object { Write-Host $_ } }
  if ($process.ExitCode -ne 0) { throw "TEST_SUITE_FAILED suite=$Suite exit=$($process.ExitCode)" }
  Write-Host "STANDARD_USER_TEST_SUITE_PASS suite=$Suite exit=0"
} finally {
  if ($password) { $password.Dispose() }
  if ($logRule -and $logAcl) { [void]$logAcl.RemoveAccessRuleSpecific($logRule); Set-Acl -LiteralPath $logDir -AclObject $logAcl -ErrorAction SilentlyContinue }
  if ($rootRule -and $rootAcl) { [void]$rootAcl.RemoveAccessRuleSpecific($rootRule); Set-Acl -LiteralPath $root -AclObject $rootAcl -ErrorAction SilentlyContinue }
  if ($account) { Remove-LocalUser -SID $account.SID -ErrorAction SilentlyContinue }
}
