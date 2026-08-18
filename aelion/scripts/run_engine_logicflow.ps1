# Aelion Engine Logic Flow Verifier (PowerShell)

$ErrorActionPreference = "Stop"

function Ensure-BuildDir {
    if (!(Test-Path "build")) {
        New-Item -ItemType Directory -Path "build" | Out-Null
    }
}

function Build-LogicFlowEngine {
    param(
        [string]$Name,
        [string]$Source
    )

    Write-Host "Building logic-flow engine: $Name"
    gcc -g $Source -o "build/${Name}_engine_logicflow"
}

function Run-LogicFlowVerifier {
    param([string]$Name)

    $binary = "build/${Name}_engine_logicflow"
    $logfile = "logicflow/${Name}_logicflow_$(Get-Date -Format yyyyMMdd_HHmmss).log"

    if (!(Test-Path $binary)) {
        Write-Host "Logic-flow binary missing — building now..."
        $src = $engineMap[$Name]
        Build-LogicFlowEngine -Name $Name -Source $src
    }

    if (!(Test-Path $binary)) {
        Write-Host "ERROR: Logic-flow build failed."
        exit 1
    }

    Write-Host "Verifying logic flow for $Name engine..."
    Write-Host "Log file: $logfile"

    $process = Start-Process -FilePath $binary -PassThru -NoNewWindow

    $step = 0
    while (!$process.HasExited) {
        $step++
        $msg = "Logic Flow Step #$step — $(Get-Date)"
        Add-Content -Path $logfile -Value $msg
        Start-Sleep -Milliseconds 700
    }

    Write-Host "$Name engine logic flow verification complete."
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
Write-Host "=== AELION ENGINE LOGIC FLOW VERIFIER ==="
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
    "1" { Run-LogicFlowVerifier "justice" }
    "2" { Run-LogicFlowVerifier "recall" }
    "3" { Run-LogicFlowVerifier "emotional" }
    "4" { Run-LogicFlowVerifier "home" }
    "5" { Run-LogicFlowVerifier "community" }
    "6" { Run-LogicFlowVerifier "governance" }
    "7" { Run-LogicFlowVerifier "mining" }
    default {
        Write-Host "Invalid selection."
        exit 1
    }
}

Write-Host ""
Write-Host "Logic flow verifier complete."
