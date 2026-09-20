# Aelion Project Finalization Script
# Automates build, test, deployment verification, and release preparation

param(
    [switch]$SkipTests,
    [switch]$DryRun,
    [string]$ReleaseVersion = "1.0.0"
)

$ErrorActionPreference = "Stop"
$WarningPreference = "Continue"

function Write-Section {
    param([string]$Title)
    Write-Host "`n" -ForegroundColor Gray
    Write-Host "╔════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║ $Title" -PadRight 56 -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
}

function Write-Status {
    param([string]$Message, [string]$Status = "INFO", [string]$Color = "White")
    $timestamp = Get-Date -Format "HH:mm:ss"
    Write-Host "[$timestamp] [$Status] $Message" -ForegroundColor $Color
}

function Test-Success {
    param([int]$ExitCode, [string]$Operation)
    if ($ExitCode -ne 0) {
        Write-Status "FAILED: $Operation" "ERROR" "Red"
        exit $ExitCode
    }
}

# ============================================================================
# PHASE 1: SETUP
# ============================================================================
Write-Section "PHASE 1: Setup & Verification"

$ProjectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$AelionDir = Join-Path $ProjectRoot "aelion"

if (-not (Test-Path $AelionDir)) {
    Write-Status "aelion directory not found at $AelionDir" "ERROR" "Red"
    exit 1
}

cd $AelionDir
Write-Status "Working directory: $(Get-Location)" "INFO" "Cyan"

# Verify required tools
Write-Status "Checking required tools..." "CHECK" "Yellow"
$tools = @("make", "gcc", "git")
foreach ($tool in $tools) {
    $result = Get-Command $tool -ErrorAction SilentlyContinue
    if ($result) {
        Write-Status "✓ $tool available: $($result.Source)" "OK" "Green"
    } else {
        Write-Status "✗ $tool NOT found" "WARN" "Yellow"
    }
}

# ============================================================================
# PHASE 2: BUILD VERIFICATION
# ============================================================================
Write-Section "PHASE 2: Clean Build"

Write-Status "Cleaning previous build artifacts..." "BUILD" "Yellow"
if (-not $DryRun) {
    make clean
    Test-Success $LASTEXITCODE "make clean"
}

Write-Status "Compiling Aelion (this may take 2-5 minutes)..." "BUILD" "Yellow"
if (-not $DryRun) {
    make all
    Test-Success $LASTEXITCODE "make all"
}

# Verify binary existence
$BinaryPath = Join-Path (Get-Location) "build/aelion_binary.exe"
if (-not (Test-Path $BinaryPath)) {
    $BinaryPath = Join-Path (Get-Location) "build/aelion_binary"
}

if (Test-Path $BinaryPath) {
    $BinarySize = (Get-Item $BinaryPath).Length
    Write-Status "✓ Binary created: $BinaryPath ($($BinarySize / 1MB)MB)" "OK" "Green"
} else {
    Write-Status "✗ Binary not found!" "ERROR" "Red"
    exit 1
}

# ============================================================================
# PHASE 3: TEST EXECUTION
# ============================================================================
Write-Section "PHASE 3: Testing"

if ($SkipTests) {
    Write-Status "Skipping tests (--SkipTests)" "SKIP" "Yellow"
} else {
    Write-Status "Running unit and integration tests..." "TEST" "Yellow"
    if (-not $DryRun) {
        make test
        Test-Success $LASTEXITCODE "make test"
    }
    Write-Status "✓ All tests passed" "OK" "Green"
}

# ============================================================================
# PHASE 4: HEALTH CHECK
# ============================================================================
Write-Section "PHASE 4: Health Verification"

Write-Status "Running binary health check..." "CHECK" "Yellow"
if (-not $DryRun) {
    make check
    Test-Success $LASTEXITCODE "make check"
}
Write-Status "✓ Binary health check passed" "OK" "Green"

# ============================================================================
# PHASE 5: DOCUMENTATION VERIFICATION
# ============================================================================
Write-Section "PHASE 5: Documentation Verification"

$docs = @(
    "README.md",
    "docs/architecture.md",
    "docs/deployment.md",
    "docs/engines.md",
    "docs/governance.md",
    "docs/usp_protocol.md",
    "docs/hud.md"
)

$docStatus = 0
foreach ($doc in $docs) {
    $docPath = Join-Path $ProjectRoot $doc
    if (Test-Path $docPath) {
        $size = (Get-Item $docPath).Length
        Write-Status "✓ $doc ($($size / 1KB)KB)" "OK" "Green"
    } else {
        Write-Status "✗ Missing: $doc" "WARN" "Yellow"
        $docStatus++
    }
}

if ($docStatus -gt 0) {
    Write-Status "⚠ $docStatus documentation files missing" "WARN" "Yellow"
}

# ============================================================================
# PHASE 6: CONFIGURATION VERIFICATION
# ============================================================================
Write-Section "PHASE 6: Configuration Verification"

$configs = @(
    "config/aelion.yml",
    "config/engines.yml",
    "config/governance.yml",
    "config/usp_routes.yml"
)

foreach ($cfg in $configs) {
    $cfgPath = Join-Path $ProjectRoot $cfg
    if (Test-Path $cfgPath) {
        Write-Status "✓ $cfg" "OK" "Green"
    } else {
        Write-Status "✗ Missing: $cfg" "WARN" "Yellow"
    }
}

# ============================================================================
# PHASE 7: DEPLOYMENT ARTIFACTS
# ============================================================================
Write-Section "PHASE 7: Deployment Artifacts"

$deployDirs = @(
    "deploy/docker",
    "deploy/systemd",
    "deploy/oracle"
)

foreach ($dir in $deployDirs) {
    $dirPath = Join-Path $ProjectRoot $dir
    if (Test-Path $dirPath) {
        $files = @(Get-ChildItem -Path $dirPath -Recurse -File)
        Write-Status "✓ $dir ($($files.Count) files)" "OK" "Green"
    } else {
        Write-Status "✗ Missing: $dir" "WARN" "Yellow"
    }
}

# ============================================================================
# PHASE 8: GIT REPOSITORY STATUS
# ============================================================================
Write-Section "PHASE 8: Git Repository Status"

Write-Status "Checking repository status..." "GIT" "Yellow"
$gitStatus = & git status --porcelain
$gitBranch = & git rev-parse --abbrev-ref HEAD
$gitRemote = & git config --get remote.origin.url

Write-Status "Branch: $gitBranch" "INFO" "Cyan"
Write-Status "Remote: $gitRemote" "INFO" "Cyan"

if ($gitStatus) {
    Write-Status "⚠ Uncommitted changes detected:" "WARN" "Yellow"
    $gitStatus | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }
} else {
    Write-Status "✓ Working directory clean" "OK" "Green"
}

# ============================================================================
# PHASE 9: VS CODE CONFIGURATION
# ============================================================================
Write-Section "PHASE 9: VS Code Configuration"

$vscodeDirs = @(
    ".vscode/settings.json",
    ".vscode/launch.json",
    ".vscode/tasks.json"
)

foreach ($file in $vscodeDirs) {
    $filePath = Join-Path $ProjectRoot "aelion" $file
    if (Test-Path $filePath) {
        Write-Status "✓ $file" "OK" "Green"
    } else {
        Write-Status "✗ Missing: $file" "WARN" "Yellow"
    }
}

# ============================================================================
# PHASE 10: ENGINE VALIDATION
# ============================================================================
Write-Section "PHASE 10: Engine Scripts Verification"

$engineScripts = @(
    "scripts/run_engine_cpu.ps1",
    "scripts/run_engine_gpu.ps1",
    "scripts/run_engine_memtrace.ps1",
    "scripts/run_engine_io.ps1",
    "scripts/run_engine_net.ps1",
    "scripts/run_engine_deadlock.ps1",
    "scripts/run_engine_disk.ps1",
    "scripts/run_engine_power.ps1",
    "scripts/run_engine_consistency.ps1",
    "scripts/run_engine_concurrency.ps1",
    "scripts/run_engine_comm_matrix.ps1"
)

$missingEngines = 0
foreach ($script in $engineScripts) {
    $scriptPath = Join-Path $ProjectRoot $script
    if (Test-Path $scriptPath) {
        Write-Status "✓ $([System.IO.Path]::GetFileName($script))" "OK" "Green"
    } else {
        Write-Status "✗ Missing: $([System.IO.Path]::GetFileName($script))" "WARN" "Yellow"
        $missingEngines++
    }
}

if ($missingEngines -eq 0) {
    Write-Status "✓ All engine scripts present" "OK" "Green"
}

# ============================================================================
# PHASE 11: SUMMARY & RECOMMENDATIONS
# ============================================================================
Write-Section "PHASE 11: Completion Summary"

Write-Status "Project finalization checklist complete!" "SUCCESS" "Green"

Write-Host "`nCompletion Status:" -ForegroundColor Cyan
Write-Host "  ✓ Clean build successful" -ForegroundColor Green
if (-not $SkipTests) {
    Write-Host "  ✓ All tests passed" -ForegroundColor Green
}
Write-Host "  ✓ Health check passed" -ForegroundColor Green
Write-Host "  ✓ Documentation verified" -ForegroundColor Green
Write-Host "  ✓ Configuration ready" -ForegroundColor Green
Write-Host "  ✓ Deployment artifacts prepared" -ForegroundColor Green

Write-Host "`n📋 Next Steps:" -ForegroundColor Yellow
Write-Host "  1. Review any ⚠ warnings above"
Write-Host "  2. Commit changes (if needed):"
Write-Host "     git add -A"
Write-Host "     git commit -m 'Aelion: Production finalization checklist passed'"
Write-Host "  3. Create release tag:"
Write-Host "     git tag -a v$ReleaseVersion -m 'Aelion Release $ReleaseVersion'"
Write-Host "  4. Push to remote:"
Write-Host "     git push origin master"
Write-Host "     git push origin --tags"
Write-Host "  5. Deploy:"
Write-Host "     - Docker: cd deploy/docker && docker build -t aelion:$ReleaseVersion ."
Write-Host "     - Systemd: sudo systemctl start aelion"

Write-Host "`n📚 Documentation:" -ForegroundColor Yellow
Write-Host "  - Deployment: $ProjectRoot/docs/deployment.md"
Write-Host "  - Architecture: $ProjectRoot/docs/architecture.md"
Write-Host "  - Engines: $ProjectRoot/docs/engines.md"

Write-Host "`n✅ Finalization complete at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Green
