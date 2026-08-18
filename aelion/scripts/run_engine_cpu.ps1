# Aelion Engine CPU Usage Tracker (PowerShell)

$ErrorActionPreference = "Stop"

function Ensure-BuildDir {
    if (!(Test-Path "build")) {
        New-Item -ItemType Directory -Path "build" | Out-Null
    }
}

function Build-CPUEngine {
    param(
        [string]$Name,
        [string]$Source
    )

    Write-Host "Building CPU-tracked engine: $Name"
    gcc -g $Source -o "build/${Name}_engine_cpu"
}

function Run-CPUEngine {
    param([string]$Name)

    $binary = "build/${Name}_engine_cpu"
    $logfile = "cpu/${Name}_cpu_$(Get-Date -Format yyyyMMdd_HHmmss).log"

    if (!(Test-Path $binary)) {
        Write-Host "CPU binary missing — building now..."
        $src = $engineMap[$Name]
        Build-CPUEngine -Name $Name -Source $src
    }

    if (!(Test-Path $binary)) {
        Write-Host "ERROR: CPU build failed."
        exit 1
    }

    Write-Host "Tracking CPU usage for $Name engine..."
    Write-Host "Log file: $logfile"

    $process = Start-Process -FilePath $binary -PassThru -NoNewWindow

    while (!$process.HasExited) {
        $cpu = (Get-Process -Id $process.Id).CPU
        Add-Content -Path $logfile -Value "$(Get-Date) CPU: $cpu"
        Start-Sleep -Milliseconds 500
    }

    Write-Host "$Name engine CPU tracking complete."
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
Write-Host "=== AELION ENGINE CPU USAGE TRACKER ==="
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
    "1" { Run-CPUEngine "justice" }
    "2" { Run-CPUEngine "recall" }
    "3" { Run-CPUEngine "emotional" }
    "4" { Run-CPUEngine "home" }
    "5" { Run-CPUEngine "community" }
    "6" { Run-CPUEngine "governance" }
    "7" { Run-CPUEngine "mining" }
    default {
        Write-Host "Invalid selection."
        exit 1
    }
}

Write-Host ""
Write-Host "CPU usage tracker complete."
