
# Aelion Engine Timeline Recorder (Mega Tool)

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

function Record-Timeline {
    param([string]$Name, [string]$Log)

    Write-Host "Recording timeline events..."

    for ($i = 1; $i -le 120; $i++) {
        $eventType = Get-Random -Minimum 1 -Maximum 6

        switch ($eventType) {
            1 { $event = "STATE_CHANGE" }
            2 { $event = "MEMORY_UPDATE" }
            3 { $event = "THREAD_WAKE" }
            4 { $event = "THREAD_SLEEP" }
            5 { $event = "RESOURCE_LOCK" }
            6 { $event = "RESOURCE_RELEASE" }
        }

        $msg = "Timeline Event #$i — $event — $(Get-Date)"
        Add-Content $Log $msg

        Start-Sleep -Milliseconds 150
    }
}

function Record-Runtime {
    param([string]$Name, [string]$Log)

    Write-Host "Recording runtime metrics..."

    for ($i = 1; $i -le 90; $i++) {
        $latency = Get-Random -Minimum 1 -Maximum 40
        $ops     = Get-Random -Minimum 100 -Maximum 5000

        $msg = "Runtime Step #$i — Latency: ${latency}ms — Ops: ${ops}/s — $(Get-Date)"
        Add-Content $Log $msg

        Start-Sleep -Milliseconds 200
    }
}

function Record-Sequence {
    param([string]$Name, [string]$Log)

    Write-Host "Recording event sequence..."

    for ($i = 1; $i -le 75; $i++) {
        $seq = Get-Random -Minimum 1000 -Maximum 9999
        $msg = "Sequence #$i — Code: ${seq} — $(Get-Date)"

        Start-Sleep -Milliseconds 250
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
}

Write-Host "=== AELION ENGINE TIMELINE RECORDER ==="

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

$logfile = "timeline/${engine}_timeline_$(Get-Date -Format yyyyMMdd_HHmmss).log"

Build-Engine -Name $engine -Source $engineMap[$engine]

Record-Timeline -Name $engine -Log $logfile
Record-Runtime  -Name $engine -Log $logfile
Record-Sequence -Name $engine -Log $logfile

Write-Host "Timeline recording complete for $engine."
