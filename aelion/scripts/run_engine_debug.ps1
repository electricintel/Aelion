# Aelion Engine Debugger Selector (PowerShell)

$ErrorActionPreference = "Stop"

function Ensure-BuildDir {
    if (!(Test-Path "build")) {
        New-Item -ItemType Directory -Path "build" | Out-Null
    }
}

function Build-Engine {
    param(
        [string]$Name,
        [string]$Source
    )

    Write-Host "Building engine: $Name"
    gcc -g $Source -o "build/${Name}_engine_dbg"
}

function Debug-Engine {
    param([string]$Name)

    $binary = "build/${Name}_engine_dbg"

    if (!(Test-Path $binary)) {
        Write-Host "Debug binary missing — building now..."
        $src = $engineMap[$Name]
        Build-Engine -Name $Name -Source $src
    }

    if (!(Test-Path $binary)) {
        Write-Host "ERROR: Debug build failed."
        exit 1
    }

    Write-Host "Launching GDB for $Name engine..."
    Start-Process -FilePath "gdb" -ArgumentList $binary -NoNewWindow
    Write-Host "$Name engine debugger launched."
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
Write-Host "=== AELION ENGINE DEBUGGER SELECTOR ==="
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
    "1" { Debug-Engine "justice" }
    "2" { Debug-Engine "recall" }
    "3" { Debug-Engine "emotional" }
    "4" { Debug-Engine "home" }
    "5" { Debug-Engine "community" }
    "6" { Debug-Engine "governance" }
    "7" { Debug-Engine "mining" }
    default {
        Write-Host "Invalid selection."
        exit 1
    }
}

Write-Host ""
Write-Host "Debugger selector complete."
