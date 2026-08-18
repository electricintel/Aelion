# Aelion Engine Performance Profiler (PowerShell)

$ErrorActionPreference = "Stop"

function Ensure-BuildDir {
    if (!(Test-Path "build")) {
        New-Item -ItemType Directory -Path "build" | Out-Null
    }
}

function Build-ProfileEngine {
    param(
        [string]$Name,
        [string]$Source
    )

    Write-Host "Building profiled engine: $Name"
    gcc -pg -g $Source -o "build/${Name}_engine_profile"
}

function Run-ProfileEngine {
    param([string]$Name)

    $binary = "build/${Name}_engine_profile"
    $profileDir = "profile/${Name}_$(Get-Date -Format yyyyMMdd_HHmmss)"

    if (!(Test-Path $profileDir)) {
        New-Item -ItemType Directory -Path $profileDir | Out-Null
    }

    if (!(Test-Path $binary)) {
        Write-Host "Profile binary missing — building now..."
        $src = $engineMap[$Name]
        Build-ProfileEngine -Name $Name -Source $src
    }

    if (!(Test-Path $binary)) {
        Write-Host "ERROR: Profile build failed."
        exit 1
    }

    Write-Host "Running performance profiler for $Name engine..."
    Write-Host "Output directory: $profileDir"

    Start-Process -FilePath $binary -WorkingDirectory $profileDir -NoNewWindow

    Write-Host "$Name engine profiling started."
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
Write-Host "=== AELION ENGINE PERFORMANCE PROFILER ==="
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
    "1" { Run-ProfileEngine "justice" }
    "2" { Run-ProfileEngine "recall" }
    "3" { Run-ProfileEngine "emotional" }
    "4" { Run-ProfileEngine "home" }
    "5" { Run-ProfileEngine "community" }
    "6" { Run-ProfileEngine "governance" }
    "7" { Run-ProfileEngine "mining" }
    default {
        Write-Host "Invalid selection."
        exit 1
    }
}

Write-Host ""
Write-Host "Performance profiler complete."
