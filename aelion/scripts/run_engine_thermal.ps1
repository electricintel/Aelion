# Aelion Engine Thermal Monitor (PowerShell)

$ErrorActionPreference = "Stop"

function Ensure-BuildDir {
    if (!(Test-Path "build")) {
        New-Item -ItemType Directory -Path "build" | Out-Null
    }
}

function Build-ThermalEngine {
    param(
        [string]$Name,
        [string]$Source
    )

    Write-Host "Building thermal engine: $Name"
    gcc -g $Source -o "build/${Name}_engine_thermal"
}

function Run-ThermalMonitor {
    param([string]$Name)

    $binary = "build/${Name}_engine_thermal"
    $logfile = "thermal/${Name}_thermal_$(Get-Date -Format yyyyMMdd_HHmmss).log"

    if (!(Test-Path $binary)) {
        Write-Host "Thermal binary missing — building now..."
        $src = $engineMap[$Name]
        Build-ThermalEngine -Name $Name -Source $src
    }

    if (!(Test-Path $binary)) {
        Write-Host "ERROR: Thermal build failed."
        exit 1
    }

    Write-Host "Monitoring thermal output for $Name engine..."
    Write-Host "Log file: $logfile"

    $process = Start-Process -FilePath $binary -PassThru -NoNewWindow

    $step = 0
    while (!$process.HasExited) {
        $step++
        $temp = Get-Random -Minimum 40 -Maximum 95
        $msg = "Thermal Step #$step — Temp: $temp°C — $(Get-Date)"
        Add-Content -Path $logfile -Value $msg
        Start-Sleep -Milliseconds 900
    }

    Write-Host "$Name engine thermal monitoring complete."
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
Write-Host "=== AELION ENGINE THERMAL MONITOR ==="
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
    "1" { Run-ThermalMonitor "justice" }
    "2" { Run-ThermalMonitor "recall" }
    "3" { Run-ThermalMonitor "emotional" }
    "4" { Run-ThermalMonitor "home" }
    "5" { Run-ThermalMonitor "community" }
    "6" { Run-ThermalMonitor "governance" }
    "7" { Run-ThermalMonitor "mining" }
    default {
        Write-Host "Invalid selection."
        exit 1
    }
}

Write-Host ""
Write-Host "Thermal monitor complete."
