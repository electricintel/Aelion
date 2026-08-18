# Generate the diagnostic engine tools once.

$ErrorActionPreference = "Stop"

$root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$targetDir = Join-Path $root "scripts\generated"
New-Item -ItemType Directory -Path $targetDir -Force | Out-Null

$toolNames = @(
    "net",
    "disk",
    "thermal",
    "power",
    "gpu",
    "threads",
    "timeline",
    "snapshot",
    "integrity",
    "consistency",
    "logicflow",
    "deadlock"
)

$template = @'
param(
    [string]$OutputPath = ""
)

$ErrorActionPreference = "Stop"
$tool = "__TOOL__"
$root = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path

function Get-SafeValue {
    param([scriptblock]$Action)
    try { & $Action } catch { $null }
}

$report = [ordered]@{
    tool = $tool
    timestamp_utc = (Get-Date).ToUniversalTime().ToString("o")
    host = $env:COMPUTERNAME
    os = Get-SafeValue { (Get-CimInstance Win32_OperatingSystem -ErrorAction Stop).Caption }
    cpu_count = Get-SafeValue { (Get-CimInstance Win32_ComputerSystem -ErrorAction Stop).NumberOfLogicalProcessors }
    memory_bytes = Get-SafeValue { (Get-CimInstance Win32_OperatingSystem -ErrorAction Stop).TotalVisibleMemorySize * 1024 }
    build_present = (Test-Path (Join-Path $root "build\aelion_binary")) -or (Test-Path (Join-Path $root "build\aelion_binary.exe"))
}

$json = $report | ConvertTo-Json -Depth 4
if ($OutputPath) {
    $parent = Split-Path -Parent $OutputPath
    if ($parent) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
    Set-Content -Path $OutputPath -Value $json -Encoding UTF8
} else {
    $json
}
'@

foreach ($name in $toolNames) {
    $content = $template.Replace("__TOOL__", $name)
    $path = Join-Path $targetDir "run_engine_$name.ps1"
    Set-Content -Path $path -Value $content -Encoding UTF8
    Write-Host "Generated $path"
}

Write-Host "Generated $($toolNames.Count) diagnostic tools in $targetDir"
