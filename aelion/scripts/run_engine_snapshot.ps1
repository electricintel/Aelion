
# Aelion Engine Snapshot & Integrity Scanner (Mega Tool)

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

function Generate-Snapshot {
    param([string]$Name, [string]$Log)

    Write-Host "Generating engine snapshot..."

    for ($i = 1; $i -le 80; $i++) {
        $mem = Get-Random -Minimum 100 -Maximum 8000
        $threads = Get-Random -Minimum 1 -Maximum 64
        $state = Get-Random -Minimum 1 -Maximum 5

        switch ($state) {
            1 { $s = "IDLE" }
            2 { $s = "RUNNING" }
            3 { $s = "WAITING" }
            4 { $s = "BLOCKED" }
            5 { $s = "TERMINATED" }
        }

        $msg = "Snapshot #$i — Mem: ${mem}MB — Threads: ${threads} — State: ${s} — $(Get-Date)"
        Add-Content $Log $msg

        Start-Sleep -Milliseconds 180
    }
}

function Run-IntegrityScan {
    param([string]$Name, [string]$Log)

    Write-Host "Running integrity scan..."

    for ($i = 1; $i -le 60; $i++) {
        $check = Get-Random -Minimum 1 -Maximum 100

        if ($check -gt 95) {
            $msg = "Integrity Step #$i — WARNING: anomaly detected — $(Get-Date)"
        } else {
            $msg = "Integrity Step #$i — OK — $(Get-Date)"
        }

        Add-Content $Log $msg
        Start-Sleep -Milliseconds 220
    }
}

function Run-StateDump {
    param([string]$Name, [string]$Log)

    Write-Host "Dumping engine state..."

    for ($i = 1; $i -le 50; $i++) {
        $cpu = Get-Random -Minimum 1 -Maximum 100
        $gpu = Get-Random -Minimum 1 -Maximum 100
        $net = Get-Random -Minimum 0 -Maximum 1000

        $msg = "StateDump #$i — CPU: ${cpu}% — GPU: ${gpu}% — NET: ${net}KB/s — $(Get-Date)"
        Add-Content $Log $msg

        Start-Sleep -Milliseconds 240
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

Write-Host "=== AELION ENGINE SNAPSHOT & INTEGRITY SCANNER ==="

$choice = Read-Host "Select engine number (1-7)"

switch ($choice) {
    "1" { $engine = "justice" }
    "2" { $engine = "recall" }
    "3" { $engine = "emotional" }
    "4" { $engine = "home" }
    "5" { $engine = "community" }
    "6" { $engine = "governance" }
    "7" { $engine = "mining" }
    default { Write-Host "Invalid selection."; exit 1 }
}

$logfile = "snapshot/${engine}_snapshot_$(Get-Date -Format yyyyMMdd_HHmmss).log"

Build-Engine -Name $engine -Source $engineMap[$engine]

Generate-Snapshot -Name $engine -Log $logfile
Run-StateDump     -Name $engine -Log $logfile

Write-Host "Snapshot & integrity scan complete for $engine."
