# Aelion Engine I/O Monitor (PowerShell)

$ErrorActionPreference = "Stop"

function Ensure-BuildDir {
    if (!(Test-Path "build")) {
        New-Item -ItemType Directory -Path "build" | Out-Null
    }
}

function Build-IOMonitorEngine {
    param(
        [string]$Name,
        [string]$Source
    )

    Write-Host "Building I/O monitor engine: $Name"
    gcc -g $Source -o "build/${Name}_engine_io"
}

function Run-IOMonitor {
    param([string]$Name)

    $binary = "build/${Name}_engine_io"
    $logfile = "iomonitor/${Name}_io_$(Get-Date -Format yyyyMMdd_HHmmss).log"

    if (!(Test-Path $binary)) {
        Write-Host "I/O monitor binary missing — building now..."
        $src = $engineMap[$Name]
        Build-IOMonitorEngine -Name $Name -Source $src
    }

    if (!(Test-Path $binary)) {
        Write-Host "ERROR: I/O monitor build failed."
        exit 1
    }

    Write-Host "Monitoring I/O for $Name engine..."
    Write-Host "Log file: $logfile"

    Start-Process -FilePath $binary -RedirectStandardOutput $logfile -RedirectStandardError $logfile -NoNewWindow

    Write-Host "$Name engine I/O monitor launched."
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
Write-Host "=== AELION ENGINE I/O MONITOR ==="
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
    "1" { Run-IOMonitor "justice" }
    "2" { Run-IOMonitor "recall" }
    "3" { Run-IOMonitor "emotional" }
    "4" { Run-IOMonitor "home" }
    "5" { Run-IOMonitor "community" }
    "6" { Run-IOMonitor "governance" }
    "7" { Run-IOMonitor "mining" }
    default {
        Write-Host "Invalid selection."
        exit 1
    }
}

Write-Host ""
Write-Host "I/O monitor complete."
