# Aelion Engine Runtime Selector (PowerShell)

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
    gcc $Source -o "build/${Name}_engine"
}

function Run-Engine {
    param([string]$Name)

    $binary = "build/${Name}_engine"

    if (!(Test-Path $binary)) {
        Write-Host "Engine binary missing — building now..."
        $src = $engineMap[$Name]
        Build-Engine -Name $Name -Source $src
    }

    if (!(Test-Path $binary)) {
        Write-Host "ERROR: Engine build failed."
        exit 1
    }

    Write-Host "Launching $Name engine..."
    Start-Process -FilePath $binary -NoNewWindow
    Write-Host "$Name engine launched."
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
Write-Host "=== AELION ENGINE RUNTIME SELECTOR ==="
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
    "1" { Run-Engine "justice" }
    "2" { Run-Engine "recall" }
    "3" { Run-Engine "emotional" }
    "4" { Run-Engine "home" }
    "5" { Run-Engine "community" }
    "6" { Run-Engine "governance" }
    "7" { Run-Engine "mining" }
    default {
        Write-Host "Invalid selection."
        exit 1
    }
}

Write-Host ""
Write-Host "Engine runtime selector complete."
