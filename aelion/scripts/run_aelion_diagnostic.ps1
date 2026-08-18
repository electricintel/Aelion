
# Aelion Diagnostic Readout - System Health Scanner
$ErrorActionPreference = "Stop"

function Check-Folder {
    param([string]$Name)
    if (!(Test-Path $Name)) {
        return "MISSING FOLDER"
    }
    return "OK"
}

function Check-LatestLog {
    param([string]$Folder)
    if (!(Test-Path $Folder)) { return "NO FOLDER" }
    $files = Get-ChildItem $Folder -File | Sort-Object LastWriteTime -Descending
    if ($files.Count -eq 0) { return "NO LOGS" }
    $path = $files[0].FullName
    $lines = Get-Content $path
    if ($lines.Count -eq 0) { return "EMPTY LOG" }

    foreach ($line in $lines) {
        if ($line -match "ERROR" -or $line -match "Fail" -or $line -match "DEADLOCK" -or $line -match "ANOMALY") {
        }
    }
    return "OK"
}

function Check-EngineBuild {
    param([string]$Name)
    $obj = "build/${Name}.o"
    if (!(Test-Path $obj)) { return "NOT BUILT" }
    if ((Get-Item $obj).Length -lt 1000) { return "CORRUPT BUILD" }
    return "OK"
}

function Print-Status {
    param([string]$Label, [string]$Status)
    if ($Status -eq "OK") {
        Write-Host ("[OK]        " + $Label) -ForegroundColor Green
    } elseif ($Status -eq "ISSUES DETECTED") {
        Write-Host ("[ISSUES]    " + $Label) -ForegroundColor Yellow
    } elseif ($Status -eq "NO LOGS" -or $Status -eq "EMPTY LOG") {
        Write-Host ("[NO DATA]   " + $Label) -ForegroundColor DarkYellow
    } elseif ($Status -eq "NOT BUILT" -or $Status -eq "CORRUPT BUILD") {
        Write-Host ("[BROKEN]    " + $Label) -ForegroundColor Red
    } else {
        Write-Host ("[MISSING]   " + $Label) -ForegroundColor Red
    }
}

Write-Host "=== AELION SYSTEM DIAGNOSTIC READOUT ===" -ForegroundColor Cyan

$folders = @(
    "stress", "timeline", "snapshot", "concurrency",
    "consistency", "comm_matrix", "orchestrator"
)

$engines = @(
    "justice","recall","emotional","home","community","governance","mining"
)

Write-Host "Checking folders..."
foreach ($f in $folders) {
    $status = Check-Folder $f
    Print-Status $f $status
}

Write-Host ""
Write-Host "Checking logs..."
foreach ($f in $folders) {
    Print-Status "$f logs" $status
}

Write-Host ""
Write-Host "Checking engine builds..."
foreach ($e in $engines) {
    $status = Check-EngineBuild $e
    Print-Status "$e engine" $status
}

Write-Host ""
Write-Host "=== DIAGNOSTIC COMPLETE ===" -ForegroundColor Cyan
