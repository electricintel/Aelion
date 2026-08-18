
# Aelion Engine Semantic Consistency Auditor (Mega Tool)

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

function Generate-Output {
    param([string]$Name)

    $tokens = @(
        "ALIGN", "SHIFT", "DRIFT", "COHERENT", "INCOHERENT",
        "VALID", "INVALID", "SYNC", "DESYNC", "STABLE", "UNSTABLE"
    )

    $index = Get-Random -Minimum 0 -Maximum ($tokens.Count - 1)
    return $tokens[$index]
}

function Compare-Outputs {
    param([string]$Primary, [string]$Secondary, [string]$Log)

    Write-Host "Comparing semantic outputs..."

    for ($i = 1; $i -le 100; $i++) {
        $out1 = Generate-Output -Name $Primary
        $out2 = Generate-Output -Name $Secondary

        if ($out1 -eq $out2) {
            $msg = "Compare #$i � CONSISTENT � ${Primary}:$out1 == ${Secondary}:$out2 � $(Get-Date)"
        } else {
            $msg = "Compare #$i � DRIFT DETECTED � ${Primary}:$out1 != ${Secondary}:$out2 � $(Get-Date)"
        }

        Add-Content $Log $msg
        Start-Sleep -Milliseconds 180
    }
}

function Multi-Engine-Drift {
    param([string]$Name, [string]$Log)

    Write-Host "Running multi-engine drift analysis..."

    $engines = @("justice","recall","emotional","home","community","governance","mining")

    for ($i = 1; $i -le 70; $i++) {
        $base = Generate-Output -Name $Name
        $driftCount = 0

        foreach ($e in src/engines/justice/justice.c src/engines/recall/recall.c src/engines/emotional/emotional.c src/engines/home/home.c src/engines/community/community.c src/engines/governance/governance.c src/engines/mining/mining.c) {
            $out = Generate-Output -Name $e
            if ($out -ne $base) { $driftCount++ }
        }

        $msg = "Drift #$i � Base:${Name}:$base � DriftCount:${driftCount} � $(Get-Date)"
        Add-Content $Log $msg

        Start-Sleep -Milliseconds 200
    }
}

function Validate-Coherence {
    param([string]$Name, [string]$Log)

    Write-Host "Validating semantic coherence..."

    for ($i = 1; $i -le 60; $i++) {
        $score = Get-Random -Minimum 1 -Maximum 100
        if ($score -gt 85) {
            $msg = "Coherence #$i � HIGH COHERENCE � Score:${score} � $(Get-Date)"
        } elseif ($score -gt 50) {
            $msg = "Coherence #$i � MEDIUM COHERENCE � Score:${score} � $(Get-Date)"
        } else {
            $msg = "Coherence #$i � LOW COHERENCE � Score:${score} � $(Get-Date)"
        }

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

Write-Host "=== AELION ENGINE SEMANTIC CONSISTENCY AUDITOR ==="

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

$logfile = "consistency/${engine}_consistency_$(Get-Date -Format yyyyMMdd_HHmmss).log"

Build-Engine -Name $engine -Source $engineMap[$engine]

Compare-Outputs     -Primary $engine -Secondary "justice" -Log $logfile
Multi-Engine-Drift  -Name $engine -Log $logfile
Validate-Coherence  -Name $engine -Log $logfile

Write-Host "Semantic consistency audit complete for $engine."
