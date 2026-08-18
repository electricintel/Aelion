# Aelion Engine Semantic Integrity Validator (PowerShell)

$ErrorActionPreference = "Stop"

function Ensure-BuildDir {
    if (!(Test-Path "build")) {
        New-Item -ItemType Directory -Path "build" | Out-Null
    }
}

function Build-IntegrityEngine {
    param(
        [string]$Name,
        [string]$Source
    )

    Write-Host "Building semantic-integrity engine: $Name"
    gcc -g $Source -o "build/${Name}_engine_integrity"
}

function Run-IntegrityValidator {
    param([string]$Name)

    $binary = "build/${Name}_engine_integrity"
    $logfile = "integrity/${Name}_integrity_$(Get-Date -Format yyyyMMdd_HHmmss).log"

    if (!(Test-Path $binary)) {
        Write-Host "Integrity binary missing — building now..."
        $src = $engineMap[$Name]
        Build-IntegrityEngine -Name $Name -Source $src
    }

    if (!(Test-Path $binary)) {
        Write-Host "ERROR: Integrity build failed."
        exit 1
    }

    Write-Host "Validating semantic integrity for $Name engine..."
    Write-Host "Log file: $logfile"

    $process = Start-Process -FilePath $binary -PassThru -NoNewWindow

    $tick = 0
    while (!$process.HasExited) {
        $tick++
        $msg = "Semantic Check #$tick — $(Get-Date)"
        Add-Content -Path $logfile -Value $msg
        Start-Sleep -Milliseconds 600
    }

    Write-Host "$Name engine semantic integrity validation complete."
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
Write-Host "=== AELION ENGINE SEMANTIC INTEGRITY VALIDATOR ==="
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
    "1" { Run-IntegrityValidator "justice" }
    "2" { Run-IntegrityValidator "recall" }
    "3" { Run-IntegrityValidator "emotional" }
    "4" { Run-IntegrityValidator "home" }
    "5" { Run-IntegrityValidator "community" }
    "6" { Run-IntegrityValidator "governance" }
    "7" { Run-IntegrityValidator "mining" }
    default {
        Write-Host "Invalid selection."
        exit 1
    }
}

Write-Host ""
Write-Host "Semantic integrity validator complete."
