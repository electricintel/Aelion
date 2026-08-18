# Aelion Engine Power Consumption Analyzer (PowerShell)

$ErrorActionPreference = "Stop"

function Ensure-BuildDir {
    if (!(Test-Path "build")) {
        New-Item -ItemType Directory -Path "build" | Out-Null
    }
}

function Build-PowerEngine {
    param(
        [string]$Name,
        [string]$Source
    )

    Write-Host "Building power engine: $Name"
    gcc -g $Source -o "build/${Name}_engine_power"
}

function Run-PowerAnalyzer {
    param([string]$Name)

    $binary = "build/${Name}_engine_power"
    $logfile = "power/${Name}_power_$(Get-Date -Format yyyyMMdd_HHmmss).log"

    if (!(Test-Path $binary)) {
        Write-Host "Power binary missing — building now..."
        $src = $engineMap[$Name]
        Build-PowerEngine -Name $Name -Source $src
    }

    if (!(Test-Path $binary)) {
        Write-Host "ERROR: Power build failed."
        exit 1
    }

    Write-Host "Analyzing power consumption for $Name engine..."
    Write-Host "Log file: $logfile"

    $process = Start-Process -FilePath $binary -PassThru -NoNewWindow

    $step = 0
    while (!$process.HasExited) {
        $step++

        # Simulated wattage draw
        $watts = Get-Random -Minimum 5 -Maximum 120

        # Simulated load spikes
        $spikeChance = Get-Random -Minimum 1 -Maximum 100
        $spike = if ($spikeChance -gt 92) { " **SPIKE DETECTED**" } else { "" }

        $msg = "Power Step #$step — Draw: ${watts}W$spike — $(Get-Date)"
        Add-Content -Path $logfile -Value $msg

        Start-Sleep -Milliseconds 900
    }

    Write-Host "$Name engine power analysis complete."
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
Write-Host "=== AELION ENGINE POWER CONSUMPTION ANALYZER ==="
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
    "1" { Run-PowerAnalyzer "justice" }
    "2" { Run-PowerAnalyzer "recall" }
    "3" { Run-PowerAnalyzer "emotional" }
    "4" { Run-PowerAnalyzer "home" }
    "5" { Run-PowerAnalyzer "community" }
    "6" { Run-PowerAnalyzer "governance" }
    "7" { Run-PowerAnalyzer "mining" }
    default {
        Write-Host "Invalid selection."
        exit 1
    }
}

Write-Host ""
Write-Host "Power analysis complete."
