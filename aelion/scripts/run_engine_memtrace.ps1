# Aelion Engine Memory Trace Analyzer (PowerShell)

$ErrorActionPreference = "Stop"

function Ensure-BuildDir {
    if (!(Test-Path "build")) {
        New-Item -ItemType Directory -Path "build" | Out-Null
    }
}

function Build-MemTraceEngine {
    param(
        [string]$Name,
        [string]$Source
    )

    Write-Host "Building memory-trace engine: $Name"
    gcc -g -fsanitize=address -fno-omit-frame-pointer $Source -o "build/${Name}_engine_mem"
}

function Run-MemTraceEngine {
    param([string]$Name)

    $binary = "build/${Name}_engine_mem"
    $traceDir = "memtrace/${Name}_$(Get-Date -Format yyyyMMdd_HHmmss)"

    if (!(Test-Path $traceDir)) {
        New-Item -ItemType Directory -Path $traceDir | Out-Null
    }

    if (!(Test-Path $binary)) {
        Write-Host "Memory-trace binary missing — building now..."
        $src = $engineMap[$Name]
        Build-MemTraceEngine -Name $Name -Source $src
    }

    if (!(Test-Path $binary)) {
        Write-Host "ERROR: Memory-trace build failed."
        exit 1
    }

    Write-Host "Running memory trace for $Name engine..."
    Write-Host "Trace directory: $traceDir"

    Start-Process -FilePath $binary -WorkingDirectory $traceDir -NoNewWindow

    Write-Host "$Name engine memory trace started."
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
Write-Host "=== AELION ENGINE MEMORY TRACE ANALYZER ==="
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
    "1" { Run-MemTraceEngine "justice" }
    "2" { Run-MemTraceEngine "recall" }
    "3" { Run-MemTraceEngine "emotional" }
    "4" { Run-MemTraceEngine "home" }
    "5" { Run-MemTraceEngine "community" }
    "6" { Run-MemTraceEngine "governance" }
    "7" { Run-MemTraceEngine "mining" }
    default {
        Write-Host "Invalid selection."
        exit 1
    }
}

Write-Host ""
Write-Host "Memory trace analyzer complete."
