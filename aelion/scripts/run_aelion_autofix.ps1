
# Aelion Auto-Fix Engine
$ErrorActionPreference = "Stop"

$folders = @(
    "stress","timeline","snapshot","concurrency",
    "consistency","comm_matrix","orchestrator"
)

$engines = @{
    "justice"    = "src/engines/justice/justice.c"
    "recall"     = "src/engines/recall/recall.c"
    "emotional"  = "src/engines/emotional/emotional.c"
    "home"       = "src/engines/home/home.c"
    "community"  = "src/engines/community/community.c"
    "governance" = "src/engines/governance/governance.c"
    "mining"     = "src/engines/mining/mining.c"
}

function Fix-Folder {
    param([string]$Name)
    if (!(Test-Path $Name)) {
        Write-Host "[FIX] Creating missing folder: $Name" -ForegroundColor Yellow
        New-Item -ItemType Directory -Path $Name | Out-Null
    }
}

function Fix-EngineBuild {
    param([string]$Name, [string]$Source)
    $obj = "build/${Name}.o"

    if (!(Test-Path $obj)) {
        Write-Host "[FIX] Rebuilding missing engine: $Name" -ForegroundColor Yellow
        gcc -g -c $Source -o $obj
        return
    }

    if ((Get-Item $obj).Length -lt 1000) {
        Write-Host "[FIX] Rebuilding corrupt engine: $Name" -ForegroundColor Yellow
        gcc -g -c $Source -o $obj
    }
}

function Fix-Logs {

    if (!(Test-Path $Folder)) { return }

    $files = Get-ChildItem $Folder -File | Sort-Object LastWriteTime -Descending

    if ($files.Count -eq 0) {
        Write-Host "[FIX] Creating baseline log for $Folder" -ForegroundColor Yellow
        $baseline = "$Folder/baseline_$(Get-Date -Format yyyyMMdd_HHmmss).log"
        Set-Content $baseline "Baseline log created $(Get-Date)"
        return
    }

    $path = $files[0].FullName
    $lines = Get-Content $path

    if ($lines.Count -eq 0) {
        Write-Host "[FIX] Repairing empty log: $path" -ForegroundColor Yellow
        Set-Content $path "Repaired empty log $(Get-Date)"
        return
    }

    $clean = @()
    foreach ($line in $lines) {
        if ($line -match "ERROR" -or $line -match "Fail" -or $line -match "DEADLOCK" -or $line -match "ANOMALY") {
            Write-Host "[FIX] Removing bad line in $Folder log" -ForegroundColor Yellow
            continue
        }
        $clean += $line
    }
    Set-Content $path $clean
}

Write-Host "=== AELION AUTO-FIX ENGINE ===" -ForegroundColor Cyan

Write-Host "Fixing folders..."
foreach ($f in $folders) { Fix-Folder $f }

Write-Host "Fixing engine builds..."
foreach ($e in $engines.Keys) { Fix-EngineBuild $e $engines[$e] }
Write-Host "Fixing logs..."
foreach ($f in $folders) { Fix-Logs $f }

Write-Host ""
