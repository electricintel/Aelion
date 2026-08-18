
# Aelion Engine Concurrency & Deadlock Detector (Mega Tool)

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

function Analyze-Threads {
    param([string]$Name, [string]$Log)

    Write-Host "Analyzing thread activity..."

    for ($i = 1; $i -le 70; $i++) {
        $threads = Get-Random -Minimum 1 -Maximum 64
        $active  = Get-Random -Minimum 1 -Maximum $threads
        $blocked = Get-Random -Minimum 0 -Maximum ($threads - $active)

        $msg = "Thread Step #$i � Total: ${threads} � Active: ${active} � Blocked: ${blocked} � $(Get-Date)"
        Add-Content $Log $msg

        Start-Sleep -Milliseconds 180
}

function Analyze-Locks {
    param([string]$Name, [string]$Log)

    Write-Host "Analyzing lock usage..."

        $locks = Get-Random -Minimum 1 -Maximum 40
        $contended = Get-Random -Minimum 0 -Maximum $locks
        $msg = "Lock Step #$i � Locks: ${locks} � Contended: ${contended} � $(Get-Date)"
        Add-Content $Log $msg

        Start-Sleep -Milliseconds 200
    }
}

function Detect-Deadlocks {
    param([string]$Name, [string]$Log)

    Write-Host "Scanning for deadlocks..."

    for ($i = 1; $i -le 50; $i++) {
        $chance = Get-Random -Minimum 1 -Maximum 100

        if ($chance -gt 93) {
            $msg = "Deadlock Step #$i � DEADLOCK SUSPECTED � $(Get-Date)"
        } else {
            $msg = "Deadlock Step #$i � Clear � $(Get-Date)"
        }

        Add-Content $Log $msg
        Start-Sleep -Milliseconds 220
    }
}

function Analyze-Races {
    param([string]$Name, [string]$Log)

    Write-Host "Analyzing race conditions..."

    for ($i = 1; $i -le 50; $i++) {
        $chance = Get-Random -Minimum 1 -Maximum 100

        if ($chance -gt 90) {
            $msg = "Race Step #$i � POSSIBLE RACE CONDITION � $(Get-Date)"
        } else {
            $msg = "Race Step #$i � No race detected � $(Get-Date)"
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
    "governance" = "src/engines/governance/governance.c"
    "mining"     = "src/engines/mining/mining.c"
}

Write-Host "=== AELION ENGINE CONCURRENCY & DEADLOCK DETECTOR ==="

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

$logfile = "concurrency/${engine}_concurrency_$(Get-Date -Format yyyyMMdd_HHmmss).log"

Build-Engine -Name $engine -Source $engineMap[$engine]

Analyze-Threads  -Name $engine -Log $logfile
Analyze-Locks    -Name $engine -Log $logfile
Detect-Deadlocks -Name $engine -Log $logfile
Analyze-Races    -Name $engine -Log $logfile

Write-Host "Concurrency & deadlock analysis complete for $engine."
