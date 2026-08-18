# Aelion Engine Thread Concurrency Analyzer (PowerShell)

$ErrorActionPreference = "Stop"

function Ensure-BuildDir {
    if (!(Test-Path "build")) {
        New-Item -ItemType Directory -Path "build" | Out-Null
    }
}

function Build-ThreadEngine {
    param(
        [string]$Name,
        [string]$Source
    )

    Write-Host "Building thread-analysis engine: $Name"
    gcc -g -pthread $Source -o "build/${Name}_engine_threads"
}

function Run-ThreadAnalyzer {
    param([string]$Name)

    $binary = "build/${Name}_engine_threads"
    $logfile = "threads/${Name}_threads_$(Get-Date -Format yyyyMMdd_HHmmss).log"

    if (!(Test-Path $binary)) {
        Write-Host "Thread binary missing — building now..."
        $src = $engineMap[$Name]
        Build-ThreadEngine -Name $Name -Source $src
    }

    if (!(Test-Path $binary)) {
        Write-Host "ERROR: Thread build failed."
        exit 1
    }

    Write-Host "Analyzing thread concurrency for $Name engine..."
    Write-Host "Log file: $logfile"

    $process = Start-Process -FilePath $binary -PassThru -NoNewWindow

    while (!$process.HasExited) {
        $threads = (Get-Process -Id $process.Id).Threads.Count
        Add-Content -Path $logfile -Value "$(Get-Date) Active Threads: $threads"
        Start-Sleep -Milliseconds 500
    }

    Write-Host "$Name engine thread concurrency analysis complete."
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
Write-Host "=== AELION ENGINE THREAD CONCURRENCY ANALYZER ==="
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
    "1" { Run-ThreadAnalyzer "justice" }
    "2" { Run-ThreadAnalyzer "recall" }
    "3" { Run-ThreadAnalyzer "emotional" }
    "4" { Run-ThreadAnalyzer "home" }
    "5" { Run-ThreadAnalyzer "community" }
    "6" { Run-ThreadAnalyzer "governance" }
    "7" { Run-ThreadAnalyzer "mining" }
    default {
        Write-Host "Invalid selection."
        exit 1
    }
}

Write-Host ""
Write-Host "Thread concurrency analyzer complete."
