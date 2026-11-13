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
$sid = $null
$rootAcl = $null
$logAcl = $null
$rootRule = $null
$logRule = $null
$profilePath = $null
$profileAcl = $null
$profileRule = $null
$systemRule = $null
$adminsRule = $null
$logDir = Join-Path $env:RUNNER_TEMP ("aimb-test-" + [guid]::NewGuid().ToString('N'))
$started = $false
$oldTemp = $env:TEMP
$oldTmp = $env:TMP
$oldUserProfile = $env:USERPROFILE
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
  $credential = [PSCredential]::new("$env:COMPUTERNAME\$username",$password)
  # Let Windows create and register the disposable account's profile, then pin
  # the child environment to the profile path resolved from that account SID.
  $profileBootstrap = Start-Process -FilePath (Join-Path $env:SystemRoot 'System32\cmd.exe') -ArgumentList '/c exit 0' -Credential $credential -LoadUserProfile -PassThru -Wait -WindowStyle Hidden
  if ($profileBootstrap.ExitCode -ne 0) { throw 'EPHEMERAL_PROFILE_BOOTSTRAP_FAILED' }
  $profile = Get-CimInstance -ClassName Win32_UserProfile | Where-Object { $_.SID -eq $sid.Value -and -not $_.Special } | Select-Object -First 1
  if (-not $profile -or -not $profile.LocalPath -or -not (Test-Path -LiteralPath $profile.LocalPath)) { throw 'EPHEMERAL_PROFILE_NOT_RESOLVED' }
  $profilePath = [string]$profile.LocalPath
  $usersRoot = (Join-Path $env:SystemDrive 'Users').TrimEnd('\') + '\'
  if (-not $profilePath.StartsWith($usersRoot,[StringComparison]::OrdinalIgnoreCase) -or (Split-Path -Leaf $profilePath) -ne $username) { throw 'EPHEMERAL_PROFILE_PATH_UNEXPECTED' }
  # The restricted user cannot write to the hosted runner administrator's profile.
  # Point all child temp-file usage at this ACL-scoped directory.
  $env:TEMP = $logDir
  $env:TMP = $logDir
  $env:USERPROFILE = $profilePath
  $argumentLine = ($testArgs | ForEach-Object { '"' + ([string]$_).Replace('"','\"') + '"' }) -join ' '
  $process = Start-Process -FilePath $exe -ArgumentList $argumentLine -Credential $credential -LoadUserProfile -WorkingDirectory $root -RedirectStandardOutput $stdout -RedirectStandardError $stderr -PassThru -Wait -WindowStyle Hidden
  $started = $true
  if (Test-Path -LiteralPath $stdout) { Get-Content -LiteralPath $stdout }
  if ((Test-Path -LiteralPath $stderr) -and (Get-Item -LiteralPath $stderr).Length -gt 0) { Get-Content -LiteralPath $stderr | ForEach-Object { Write-Host $_ } }
  if ($process.ExitCode -ne 0) { throw "TEST_SUITE_FAILED suite=$Suite exit=$($process.ExitCode)" }
  Write-Host "STANDARD_USER_TEST_SUITE_PASS suite=$Suite exit=0"
} finally {
  $env:TEMP = $oldTemp
  $env:TMP = $oldTmp
  $env:USERPROFILE = $oldUserProfile
  if ($password) { $password.Dispose() }
  if ($logRule -and $logAcl) { [void]$logAcl.RemoveAccessRuleSpecific($logRule); Set-Acl -LiteralPath $logDir -AclObject $logAcl -ErrorAction SilentlyContinue }
  if ($rootRule -and $rootAcl) { [void]$rootAcl.RemoveAccessRuleSpecific($rootRule); Set-Acl -LiteralPath $root -AclObject $rootAcl -ErrorAction SilentlyContinue }
  if ($account) { Remove-LocalUser -SID $account.SID -ErrorAction SilentlyContinue }
  $profile = $null
  if ($sid) { $profile = Get-CimInstance -ClassName Win32_UserProfile -ErrorAction SilentlyContinue | Where-Object { $_.SID -eq $sid.Value -and -not $_.Special } | Select-Object -First 1 }
  if ($profile -and -not $profile.Loaded) { Remove-CimInstance -InputObject $profile -ErrorAction SilentlyContinue }
  if ($profilePath -and (Test-Path -LiteralPath $profilePath)) { Remove-Item -LiteralPath $profilePath -Recurse -Force -ErrorAction SilentlyContinue }
}
