param([Parameter(Mandatory=$true)][string]$FixtureRoot)
$ErrorActionPreference='Stop'
$MaxFileBytes=131072; $MaxRequestBytes=2048; $MaxResponseBytes=65536; $MaxRequests=100; $MaxPage=100
$source=Join-Path $PSScriptRoot 'native-read-gate.cs'
Add-Type -Path $source
$rootHandle=[NativeReadGate]::OpenRoot($FixtureRoot)
try {
  $marker=[NativeReadGate]::Read($rootHandle,'.aimb-fixture.json',1024)
  if([Text.Encoding]::UTF8.GetString($marker) -ne '{"fixture":"aimb-dev-readonly-v1","project_id":"bridge-agent"}') { throw 'FIXTURE_MARKER_INVALID' }
  $listSnapshot=$null
  for($requestIndex=0;$requestIndex -lt $MaxRequests;$requestIndex++) {
    $builder=New-Object Text.StringBuilder
    while($true) {
      $char=[Console]::In.Read()
      if($char -lt 0 -or $char -eq 10){break}
      if($char -ne 13){[void]$builder.Append([char]$char)}
      if($builder.Length -gt $MaxRequestBytes){throw 'REQUEST_TOO_LARGE'}
    }
    if($char -lt 0 -and $builder.Length -eq 0){break}
    $line=$builder.ToString()
    if([Text.Encoding]::UTF8.GetByteCount($line) -gt $MaxRequestBytes){throw 'REQUEST_TOO_LARGE'}
    try {
      $request=$line | ConvertFrom-Json -ErrorAction Stop
      $keys=@($request.PSObject.Properties.Name)
      if($request.type -eq 'list' -and ($keys | Where-Object {$_ -notin @('type','offset','limit')}).Count -eq 0) {
        $offset=0; $limit=$MaxPage
        if($null -ne $request.offset){$offset=[int]$request.offset};if($null -ne $request.limit){$limit=[int]$request.limit}
        if($offset -lt 0 -or $offset -gt 9999 -or $limit -lt 1 -or $limit -gt $MaxPage){throw 'PAGE_LIMIT_INVALID'}
        if($null -eq $listSnapshot){$listSnapshot=@([NativeReadGate]::ListFiles($rootHandle,10101) | Where-Object {$_ -ne '.git' -and $_ -ne '.aimb-fixture.json'} | Sort-Object)}
        $names=$listSnapshot
        $page=@($names | Select-Object -Skip $offset -First ($limit+1))
        $hasMore=$page.Count -gt $limit;if($hasMore){$page=$page | Select-Object -First $limit}
        $safe=@();$nameBytes=0
        foreach($item in $page){$name=[string]$item;try{[void][NativeReadGate]::Read($rootHandle,$name,$MaxFileBytes);$nameBytes+=[Text.Encoding]::UTF8.GetByteCount($name);$safe+=$name}catch{if($_.Exception.Message -notmatch 'ACL_WRITE_ALLOWED|REPARSE|HARDLINK|NATIVE_OPEN_DENIED|HANDLE_OUTSIDE_ROOT|FILE_SIZE_LIMIT|NOT_REGULAR_FILE'){throw}}}
        if($nameBytes -gt $MaxResponseBytes){throw 'RESPONSE_TOO_LARGE'}
        $truncated=$hasMore -and ($offset+$page.Count -ge 10000)
        $hasMore=$hasMore -and -not $truncated
        $response=@{ok=$true;files=$safe;next_offset=$(if($hasMore){$offset+$page.Count}else{$null});truncated=$truncated}
      } elseif($request.type -eq 'read' -and $keys.Count -eq 2 -and ($keys | Where-Object {$_ -notin @('type','path')}).Count -eq 0 -and $request.path -is [string]) {
        $bytes=[NativeReadGate]::Read($rootHandle,$request.path,$MaxFileBytes)
        $utf8=New-Object System.Text.UTF8Encoding($false,$true);$content=$utf8.GetString($bytes)
        $sha=([BitConverter]::ToString([Security.Cryptography.SHA256]::Create().ComputeHash($bytes))).Replace('-','').ToLowerInvariant()
        $response=@{ok=$true;path=$request.path;sha256=$sha;size=$bytes.Length;content=$content}
      } else { throw 'REQUEST_NOT_ALLOWLISTED' }
      $json=$response | ConvertTo-Json -Compress -Depth 8
      if([Text.Encoding]::UTF8.GetByteCount($json) -gt $MaxResponseBytes){$json=@{ok=$false;error='RESPONSE_TOO_LARGE'}|ConvertTo-Json -Compress}
      [Console]::Out.WriteLine($json)
    } catch { [Console]::Out.WriteLine((@{ok=$false;error=$_.Exception.Message}|ConvertTo-Json -Compress)) }
  }
} finally { $rootHandle.Dispose() }
