# Aelion Engine Deadlock & Race Condition Detector (PowerShell)

$ErrorActionPreference = "Stop"

function Ensure-BuildDir {
    if (!(Test-Path "build")) {
        New-Item -ItemType Directory -Path "build" | Out-Null
    }
}

function Build-DeadlockEngine {
    param(
        [string]$Name,
        [string]$Source
    )

    Write-Host "Building deadlock-detection engine: $Name"
    gcc -g -pthread -fsanitize=thread $Source -o "build/${Name}_engine_deadlock"
}

function Run-DeadlockDetector {
    param([string]$Name)

    $binary = "build/${Name}_engine_deadlock"
    $logfile = "deadlock/${Name}_deadlock_$(Get-Date -Format yyyyMMdd_HHmmss).log"

    if (!(Test-Path $binary)) {
        Write-Host "Deadlock binary missing — building now..."
        $src = $engineMap[$Name]
        Build-DeadlockEngine -Name $Name -Source $src
    }

    if (!(Test-Path $binary)) {
        Write-Host "ERROR: Deadlock build failed."
        exit 1
    }

    Write-Host "Detecting deadlocks & race conditions for $Name engine..."
    Write-Host "Log file: $logfile"

    $process = Start-Process -FilePath $binary -RedirectStandardError $logfile -PassThru -NoNewWindow

    while (!$process.HasExited) {
        Add-Content -Path $logfile -Value "$(Get-Date) Monitoring thread sanitizer output..."
        Start-Sleep -Seconds 1
    }

    Write-Host "$Name engine deadlock & race condition detection complete."
}

Ensure-BuildDir

$engineMap = @{
    "justice"    = "src/engines/justice/justice.c"
    "recall"     = "src/engines/recall/recall.c"
    "emotional"  = "src/engines/emotional/emotional.c"
    "home"       = "src/engines/home/home.c"
    "community"  = "src/engines/community/community.c"
    "governance" = "src/engines/governance/governance.c"
    "mining"     = "src/engines/mining/mining.c"
}

Write-Host ""
Write-Host "=== AELION ENGINE DEADLOCK & RACE CONDITION DETECTOR ==="
Write-Host ""
Write-Host "Available engines:"
Write-Host "  1) justice"
Write-Host "  2) recall"
Write-Host "  3) emotional"
Write-Host "  4) home"
Write-Host "  5) community"
Write-Host "  6) governance"
Write-Host "  7) mining"
Write-Host ""

$choice = Read-Host "Select engine number"

switch ($choice) {
    "1" { Run-DeadlockDetector "justice" }
    "2" { Run-DeadlockDetector "recall" }
    "3" { Run-DeadlockDetector "emotional" }
    "4" { Run-DeadlockDetector "home" }
    "5" { Run-DeadlockDetector "community" }
    "6" { Run-DeadlockDetector "governance" }
    "7" { Run-DeadlockDetector "mining" }
    default {
        Write-Host "Invalid selection."
        exit 1
    }
}

Write-Host ""
Write-Host "Deadlock & race condition detector complete."
