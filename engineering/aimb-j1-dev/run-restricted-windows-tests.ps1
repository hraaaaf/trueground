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
    $tests = @(Get-ChildItem -LiteralPath $root -Recurse -Filter '*.test.mjs' -File | ForEach-Object { $_.FullName })
    $testArgs = @('--test','--test-reporter=spec') + $tests
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

function Quote-WindowsArgument([string]$Value) {
  '"' + $Value.Replace('"','\"') + '"'
}
$commandLine = (Quote-WindowsArgument $exe) + ' ' + (($testArgs | ForEach-Object { Quote-WindowsArgument ([string]$_) }) -join ' ')

$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = [Security.Principal.WindowsPrincipal]::new($identity)
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
  & $exe @testArgs
  exit $LASTEXITCODE
}

$outPath = Join-Path $env:RUNNER_TEMP "aimb-j1-dev-$Suite.stdout.txt"
$errPath = Join-Path $env:RUNNER_TEMP "aimb-j1-dev-$Suite.stderr.txt"
$native = @'
using System;
using System.ComponentModel;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Text;
public static class AimbRestrictedTestProcess {
  const uint TOKEN_ASSIGN_PRIMARY=0x0001, TOKEN_DUPLICATE=0x0002, TOKEN_QUERY=0x0008;
  const uint DISABLE_MAX_PRIVILEGE=0x00000001, LUA_TOKEN=0x00000004;
  const uint CREATE_UNICODE_ENVIRONMENT=0x00000400, STARTF_USESTDHANDLES=0x00000100;
  const uint GENERIC_WRITE=0x40000000, FILE_SHARE_READ=0x00000001, CREATE_ALWAYS=2, FILE_ATTRIBUTE_NORMAL=0x80;
  [StructLayout(LayoutKind.Sequential, CharSet=CharSet.Unicode)] struct STARTUPINFO {
    public uint cb; public string lpReserved; public string lpDesktop; public string lpTitle;
    public uint dwX,dwY,dwXSize,dwYSize,dwXCountChars,dwYCountChars,dwFillAttribute,dwFlags;
    public short wShowWindow,cbReserved2; public IntPtr lpReserved2,hStdInput,hStdOutput,hStdError;
  }
  [StructLayout(LayoutKind.Sequential)] struct PROCESS_INFORMATION { public IntPtr hProcess,hThread; public uint dwProcessId,dwThreadId; }
  [StructLayout(LayoutKind.Sequential)] struct SECURITY_ATTRIBUTES { public int nLength; public IntPtr lpSecurityDescriptor; [MarshalAs(UnmanagedType.Bool)] public bool bInheritHandle; }
  [DllImport("kernel32.dll")] static extern IntPtr GetCurrentProcess();
  [DllImport("kernel32.dll", SetLastError=true)] [return:MarshalAs(UnmanagedType.Bool)] static extern bool CloseHandle(IntPtr h);
  [DllImport("kernel32.dll", SetLastError=true)] static extern IntPtr GetStdHandle(int nStdHandle);
  [DllImport("kernel32.dll", CharSet=CharSet.Unicode, SetLastError=true)] static extern IntPtr CreateFileW(string name,uint access,uint share,ref SECURITY_ATTRIBUTES sa,uint creation,uint flags,IntPtr template);
  [DllImport("advapi32.dll", SetLastError=true)] [return:MarshalAs(UnmanagedType.Bool)] static extern bool OpenProcessToken(IntPtr process,uint access,out IntPtr token);
  [DllImport("advapi32.dll", SetLastError=true)] [return:MarshalAs(UnmanagedType.Bool)] static extern bool CreateRestrictedToken(IntPtr existing,uint flags,uint disableCount,IntPtr sids,uint deleteCount,IntPtr privileges,uint restrictCount,IntPtr restrictingSids,out IntPtr token);
  [DllImport("advapi32.dll", CharSet=CharSet.Unicode, SetLastError=true)] [return:MarshalAs(UnmanagedType.Bool)] static extern bool CreateProcessAsUserW(IntPtr token,string app,StringBuilder command,IntPtr processAttributes,IntPtr threadAttributes,[MarshalAs(UnmanagedType.Bool)] bool inherit,uint flags,IntPtr environment,string cwd,ref STARTUPINFO startup,out PROCESS_INFORMATION info);
  [DllImport("kernel32.dll", SetLastError=true)] static extern uint WaitForSingleObject(IntPtr h,uint ms);
  [DllImport("kernel32.dll", SetLastError=true)] [return:MarshalAs(UnmanagedType.Bool)] static extern bool GetExitCodeProcess(IntPtr h,out uint code);
  public static int Run(string app,string command,string cwd,string stdout,string stderr) {
    IntPtr source=IntPtr.Zero, restricted=IntPtr.Zero, outHandle=IntPtr.Zero, errHandle=IntPtr.Zero;
    PROCESS_INFORMATION pi=new PROCESS_INFORMATION();
    try {
      if(!OpenProcessToken(GetCurrentProcess(),TOKEN_DUPLICATE|TOKEN_ASSIGN_PRIMARY|TOKEN_QUERY,out source)) throw new Win32Exception(Marshal.GetLastWin32Error(),"OPEN_PROCESS_TOKEN_FAILED");
      if(!CreateRestrictedToken(source,DISABLE_MAX_PRIVILEGE|LUA_TOKEN,0,IntPtr.Zero,0,IntPtr.Zero,0,IntPtr.Zero,out restricted)) throw new Win32Exception(Marshal.GetLastWin32Error(),"CREATE_RESTRICTED_TOKEN_FAILED");
      SECURITY_ATTRIBUTES sa=new SECURITY_ATTRIBUTES(); sa.nLength=Marshal.SizeOf(typeof(SECURITY_ATTRIBUTES)); sa.bInheritHandle=true;
      outHandle=CreateFileW(stdout,GENERIC_WRITE,FILE_SHARE_READ,ref sa,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,IntPtr.Zero);
      if(outHandle==new IntPtr(-1)) throw new Win32Exception(Marshal.GetLastWin32Error(),"CREATE_STDOUT_FAILED");
      errHandle=CreateFileW(stderr,GENERIC_WRITE,FILE_SHARE_READ,ref sa,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,IntPtr.Zero);
      if(errHandle==new IntPtr(-1)) throw new Win32Exception(Marshal.GetLastWin32Error(),"CREATE_STDERR_FAILED");
      STARTUPINFO si=new STARTUPINFO(); si.cb=(uint)Marshal.SizeOf(typeof(STARTUPINFO)); si.dwFlags=STARTF_USESTDHANDLES;
      si.hStdInput=GetStdHandle(-10); si.hStdOutput=outHandle; si.hStdError=errHandle;
      StringBuilder cmd=new StringBuilder(command);
      if(!CreateProcessAsUserW(restricted,app,cmd,IntPtr.Zero,IntPtr.Zero,true,CREATE_UNICODE_ENVIRONMENT,IntPtr.Zero,cwd,ref si,out pi)) throw new Win32Exception(Marshal.GetLastWin32Error(),"CREATE_RESTRICTED_PROCESS_FAILED");
      if(WaitForSingleObject(pi.hProcess,1200000)!=0) throw new TimeoutException("RESTRICTED_TEST_PROCESS_TIMEOUT");
      uint code; if(!GetExitCodeProcess(pi.hProcess,out code)) throw new Win32Exception(Marshal.GetLastWin32Error(),"GET_TEST_EXIT_CODE_FAILED");
      return unchecked((int)code);
    } finally {
      if(pi.hThread!=IntPtr.Zero) CloseHandle(pi.hThread); if(pi.hProcess!=IntPtr.Zero) CloseHandle(pi.hProcess);
      if(outHandle!=IntPtr.Zero&&outHandle!=new IntPtr(-1)) CloseHandle(outHandle); if(errHandle!=IntPtr.Zero&&errHandle!=new IntPtr(-1)) CloseHandle(errHandle);
      if(restricted!=IntPtr.Zero) CloseHandle(restricted); if(source!=IntPtr.Zero) CloseHandle(source);
    }
  }
}
'@
Add-Type -TypeDefinition $native -Language CSharp
$exit = [AimbRestrictedTestProcess]::Run($exe,$commandLine,$root,$outPath,$errPath)
if (Test-Path -LiteralPath $outPath) { Get-Content -LiteralPath $outPath }
if ((Test-Path -LiteralPath $errPath) -and (Get-Item -LiteralPath $errPath).Length -gt 0) { Get-Content -LiteralPath $errPath | ForEach-Object { Write-Host $_ } }
if ($exit -ne 0) { throw "RESTRICTED_TEST_SUITE_FAILED suite=$Suite exit=$exit" }
Write-Host "RESTRICTED_TEST_SUITE_PASS suite=$Suite exit=$exit"
