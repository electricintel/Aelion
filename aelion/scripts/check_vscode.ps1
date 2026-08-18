# Aelion VS Code Diagnostic Script
# Run from repo root: pwsh ./scripts/check_vscode.ps1

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "=== AELION VS CODE DIAGNOSTIC ==="
Write-Host ""

function Check-Item {
    param([string]$Path)

    if (Test-Path $Path) {
        Write-Host "[OK]   $Path exists"
    } else {
        Write-Host "[MISS] $Path missing"
    }
}

function Check-Folder {
    param([string]$Path)

    if (Test-Path $Path) {
        $count = (Get-ChildItem $Path).Count
        Write-Host "[OK]   $Path folder found ($count items)"
    } else {
        Write-Host "[MISS] $Path folder missing"
    }
}

Write-Host "Checking .vscode configuration..."
Check-Folder ".vscode"
Check-Item ".vscode/settings.json"
Check-Item ".vscode/tasks.json"
Check-Item ".vscode/launch.json"
Check-Item ".vscode/extensions.json"

Write-Host ""
Write-Host "Checking build scripts..."
Check-Folder "scripts"
Check-Item "scripts/build_aelion.ps1"
Check-Item "scripts/run_aelion.ps1"
Check-Item "scripts/build_engines.ps1"

Write-Host ""
Write-Host "Checking Makefile..."
Check-Item "Makefile"

Write-Host ""
Write-Host "Checking source folders..."
Check-Folder "src/core"
Check-Folder "src/engines"
Check-Folder "src/services"
Check-Folder "src/storage"

Write-Host ""
Write-Host "Checking engine files..."
$engines = @(
    "src/engines/justice/justice.c",
    "src/engines/recall/recall.c",
    "src/engines/emotional/emotional.c",
    "src/engines/home/home.c",
    "src/engines/community/community.c",
    "src/engines/governance/governance.c",
    "src/engines/mining/mining.c"
)

foreach ($e in $engines) {
    Check-Item $e
}

Write-Host ""
Write-Host "Checking build output..."
Check-Folder "build"
Check-Item "build/aelion_binary"

Write-Host ""
Write-Host "Checking VS Code task validity..."

if (Test-Path ".vscode/tasks.json") {
    $tasks = Get-Content ".vscode/tasks.json" -Raw
    if ($tasks -match "Build Aelion") {
        Write-Host "[OK]   Build task detected"
    } else {
        Write-Host "[MISS] Build task not found"
    }

    if ($tasks -match "Run Aelion") {
        Write-Host "[OK]   Run task detected"
    } else {
        Write-Host "[MISS] Run task not found"
    }
} else {
    Write-Host "[MISS] Cannot validate tasks.json (file missing)"
}

Write-Host ""
Write-Host "=== DIAGNOSTIC COMPLETE ==="
Write-Host "If you want, I can generate a repair script based on this output."
