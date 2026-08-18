
# Aelion Engine Load & Stress Analyzer (Mega Tool)

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

function Simulate-CPU {
    param([string]$Name, [string]$Log)
    Write-Host "Simulating CPU load..."
    for ($i = 1; $i -le 50; $i++) {
        $cpu = Get-Random -Minimum 5 -Maximum 100
        Add-Content $Log "CPU Load Step $i — ${cpu}% — $(Get-Date)"
        Start-Sleep -Milliseconds 200
    }
}

function Simulate-GPU {
    param([string]$Name, [string]$Log)
    Write-Host "Simulating GPU load..."
    for ($i = 1; $i -le 40; $i++) {
        $gpu = Get-Random -Minimum 10 -Maximum 95
        Add-Content $Log "GPU Load Step $i — ${gpu}% — $(Get-Date)"
        Start-Sleep -Milliseconds 250
    }
}

function Simulate-Thermal {
    param([string]$Name, [string]$Log)
    Write-Host "Simulating thermal output..."
    for ($i = 1; $i -le 60; $i++) {
        $temp = Get-Random -Minimum 40 -Maximum 98
        Add-Content $Log "Thermal Step $i — ${temp}°C — $(Get-Date)"
        Start-Sleep -Milliseconds 180
    }
}

function Simulate-Power {
    param([string]$Name, [string]$Log)
    Write-Host "Simulating power draw..."
    for ($i = 1; $i -le 45; $i++) {
        $watts = Get-Random -Minimum 5 -Maximum 130
        Add-Content $Log "Power Step $i — ${watts}W — $(Get-Date)"
        Start-Sleep -Milliseconds 220
    }
}

function Simulate-Disk {
    param([string]$Name, [string]$Log)
    Write-Host "Simulating disk I/O..."
    for ($i = 1; $i -le 35; $i++) {
        $io = Get-Random -Minimum 1 -Maximum 300
        Add-Content $Log "Disk I/O Step $i — ${io}MB/s — $(Get-Date)"
        Start-Sleep -Milliseconds 260
    }
}

function Simulate-Network {
    param([string]$Name, [string]$Log)
    Write-Host "Simulating network activity..."
    for ($i = 1; $i -le 55; $i++) {
        $net = Get-Random -Minimum 0 -Maximum 1000
        Add-Content $Log "Network Step $i — ${net}KB/s — $(Get-Date)"
        Start-Sleep -Milliseconds 150
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

Write-Host "=== AELION ENGINE LOAD & STRESS ANALYZER ==="

$choice = Read-Host "Select engine number (1-7)"

switch ($choice) {
    "1" { $engine = "justice" }
    "2" { $engine = "recall" }
    "3" { $engine = "emotional" }
    "4" { $engine = "home" }
    "5" { $engine = "community" }
    "7" { $engine = "mining" }
    default { Write-Host "Invalid selection."; exit 1 }
}

$logfile = "stress/${engine}_stress_$(Get-Date -Format yyyyMMdd_HHmmss).log"

Build-Engine -Name $engine -Source $engineMap[$engine]

Simulate-CPU     -Name $engine -Log $logfile
Simulate-GPU     -Name $engine -Log $logfile
Simulate-Thermal -Name $engine -Log $logfile
Simulate-Power   -Name $engine -Log $logfile
Simulate-Disk    -Name $engine -Log $logfile
Simulate-Network -Name $engine -Log $logfile

Write-Host "Stress analysis complete for $engine."
