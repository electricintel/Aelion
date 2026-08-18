
# Aelion Engine Communication Matrix (Mega Tool)

$ErrorActionPreference = "Stop"

function Ensure-BuildDir {
    if (!(Test-Path "build")) {
        New-Item -ItemType Directory -Path "build" | Out-Null
    }
}

function Build-Engine {
    param([string]$Name, [string]$Source)
    Write-Host "Building engine: $Name"
    gcc -g -c $Source -o "build/${Name}.o"
}

function Generate-Signal {
    param([string]$Name)

    $signals = @(
        "PING", "PONG", "SYNC", "DESYNC", "REQ", "ACK",
        "UPDATE", "FLUSH", "LOCK", "UNLOCK", "PULSE", "DROP"
    )

    $index = Get-Random -Minimum 0 -Maximum ($signals.Count - 1)
    return $signals[$index]
}

function Simulate-CommFlow {
    param([string]$Primary, [string]$Secondary, [string]$Log)

    Write-Host "Simulating communication flow..."

    for ($i = 1; $i -le 120; $i++) {
        $sig1 = Generate-Signal -Name $Primary
        $sig2 = Generate-Signal -Name $Secondary

        $latency = Get-Random -Minimum 1 -Maximum 80
        $drift   = Get-Random -Minimum 0 -Maximum 20

        $msg = "CommFlow #$i � ${Primary}:$sig1 ? ${Secondary}:$sig2 � Latency:${latency}ms � Drift:${drift} � $(Get-Date)"
        Add-Content $Log $msg

        Start-Sleep -Milliseconds 150
    }
}

function MultiEngineMatrix {
    param([string]$Name, [string]$Log)

    Write-Host "Building multi-engine communication matrix..."

    $engines = @("justice","recall","emotional","home","community","governance","mining")

    for ($i = 1; $i -le 90; $i++) {
        $row = "Matrix #$i � $(Get-Date)"

        foreach ($e in src/engines/justice/justice.c src/engines/recall/recall.c src/engines/emotional/emotional.c src/engines/home/home.c src/engines/community/community.c src/engines/governance/governance.c src/engines/mining/mining.c) {
            $sig = Generate-Signal -Name $e
            $row += " | ${e}:$sig"
        }

        Add-Content $Log $row
        Start-Sleep -Milliseconds 200
    }
}

function Detect-SignalAnomalies {
    param([string]$Name, [string]$Log)

    Write-Host "Detecting signal anomalies..."

    for ($i = 1; $i -le 70; $i++) {
        $chance = Get-Random -Minimum 1 -Maximum 100

        if ($chance -gt 92) {
            $msg = "Anomaly #$i � SIGNAL DROP DETECTED � $(Get-Date)"
        } elseif ($chance -gt 80) {
            $msg = "Anomaly #$i � HIGH LATENCY � $(Get-Date)"
        } else {
            $msg = "Anomaly #$i � Normal � $(Get-Date)"
        }

        Add-Content $Log $msg
        Start-Sleep -Milliseconds 220
    }
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

Write-Host "=== AELION ENGINE COMMUNICATION MATRIX ==="

$choice = Read-Host "Select engine number (1-7)"

switch ($choice) {
    "1" { $engine = "justice" }
    "3" { $engine = "emotional" }
    "4" { $engine = "home" }
    "5" { $engine = "community" }
    "6" { $engine = "governance" }
    "7" { $engine = "mining" }
    default { Write-Host "Invalid selection."; exit 1 }
}

$logfile = "comm_matrix/${engine}_comm_$(Get-Date -Format yyyyMMdd_HHmmss).log"

Build-Engine -Name $engine -Source $engineMap[$engine]

Simulate-CommFlow      -Primary $engine -Secondary "justice" -Log $logfile
MultiEngineMatrix      -Name $engine -Log $logfile
Detect-SignalAnomalies -Name $engine -Log $logfile

Write-Host "Communication matrix analysis complete for $engine."
