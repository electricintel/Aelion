# Aelion Engine Sandbox Runtime (PowerShell)

$ErrorActionPreference = "Stop"

function Ensure-Sandbox {
    if (!(Test-Path "sandbox")) {
        New-Item -ItemType Directory -Path "sandbox" | Out-Null
    }
}

function Ensure-BuildDir {
    if (!(Test-Path "build")) {
        New-Item -ItemType Directory -Path "build" | Out-Null
    }
}

function Build-SandboxEngine {
    param(
        [string]$Name,
        [string]$Source
    )

    Write-Host "Building sandbox engine: $Name"
    gcc -g $Source -o "sandbox/${Name}_sandbox"
}

function Run-Sandbox {
    param([string]$Name)

    $binary = "sandbox/${Name}_sandbox"

    if (!(Test-Path $binary)) {
        Write-Host "Sandbox binary missing — building now..."
        $src = $engineMap[$Name]
        Build-SandboxEngine -Name $Name -Source $src
    }

    if (!(Test-Path $binary)) {
        Write-Host "ERROR: Sandbox build failed."
        exit 1
    }

    Write-Host "Launching sandboxed $Name engine..."
    Start-Process -FilePath $binary -NoNewWindow
    Write-Host "$Name engine sandbox launched."
}

Ensure-Sandbox
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
Write-Host "=== AELION ENGINE SANDBOX RUNTIME ==="
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
    "1" { Run-Sandbox "justice" }
    "2" { Run-Sandbox "recall" }
    "3" { Run-Sandbox "emotional" }
    "4" { Run-Sandbox "home" }
    "5" { Run-Sandbox "community" }
    "6" { Run-Sandbox "governance" }
    "7" { Run-Sandbox "mining" }
    default {
        Write-Host "Invalid selection."
        exit 1
    }
}

Write-Host ""
Write-Host "Sandbox runtime complete."
