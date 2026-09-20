#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Run Aelion Production Finalization
    
.DESCRIPTION
    Executes the complete Aelion project finalization workflow:
    - Clean build verification
    - Unit & integration test execution
    - Health checks
    - Documentation verification
    - Deployment artifact validation
    - Repository status
    - Release preparation checklist
    
.PARAMETER SkipTests
    Skip test execution (use with caution)
    
.PARAMETER DryRun
    Preview what would run without executing commands
    
.PARAMETER ReleaseVersion
    Version number for release tag (default: 1.0.0)
    
.PARAMETER Verbose
    Enable verbose output
    
.EXAMPLE
    .\run-finish-aelion.ps1
    # Runs full finalization workflow
    
.EXAMPLE
    .\run-finish-aelion.ps1 -SkipTests
    # Skips test phase
    
.EXAMPLE
    .\run-finish-aelion.ps1 -DryRun
    # Preview without executing
    
.EXAMPLE
    .\run-finish-aelion.ps1 -ReleaseVersion 2.1.0
    # Use custom version for release
#>

param(
    [switch]$SkipTests,
    [switch]$DryRun,
    [string]$ReleaseVersion = "1.0.0",
    [switch]$Verbose
)

$ErrorActionPreference = "Stop"

# Get the script directory
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$FinishScript = Join-Path $ScriptDir "finish-aelion.ps1"

if (-not (Test-Path $FinishScript)) {
    Write-Host "❌ Error: finish-aelion.ps1 not found at $FinishScript" -ForegroundColor Red
    exit 1
}

Write-Host @"
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║          🚀 AELION PROJECT FINALIZATION WORKFLOW 🚀           ║
║                                                               ║
║  Performance Monitoring System - Production Release          ║
║  Repository: https://github.com/electricintel/Aelion        ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
"@ -ForegroundColor Cyan

Write-Host "Starting finalization..." -ForegroundColor Yellow
Write-Host "Version: $ReleaseVersion" -ForegroundColor Yellow
if ($DryRun) { Write-Host "Mode: DRY RUN (preview only)" -ForegroundColor Yellow }
if ($SkipTests) { Write-Host "Tests: SKIPPED" -ForegroundColor Yellow }
Write-Host ""

# Build parameters
$params = @{}
if ($SkipTests) { $params["SkipTests"] = $true }
if ($DryRun) { $params["DryRun"] = $true }
if ($ReleaseVersion) { $params["ReleaseVersion"] = $ReleaseVersion }

# Run finalization script
try {
    & $FinishScript @params
    $exitCode = $LASTEXITCODE
}
catch {
    Write-Host "❌ Error during execution: $_" -ForegroundColor Red
    exit 1
}

if ($exitCode -ne 0) {
    Write-Host "`n❌ Finalization failed with exit code $exitCode" -ForegroundColor Red
    exit $exitCode
}

Write-Host @"
`n╔═══════════════════════════════════════════════════════════════╗
║                     ✅ FINALIZATION COMPLETE                  ║
╚═══════════════════════════════════════════════════════════════╝

To deploy Aelion to production:

  1️⃣  Review changes:
      git log --oneline -5

  2️⃣  Commit if needed:
      git add -A
      git commit -m "Finalize Aelion v$ReleaseVersion for production"

  3️⃣  Create release tag:
      git tag -a v$ReleaseVersion -m "Aelion Release $ReleaseVersion"

  4️⃣  Push to GitHub:
      git push origin master
      git push origin --tags

  5️⃣  Build and deploy:
      cd aelion/deploy/docker
      docker build -t aelion:$ReleaseVersion .
      docker run -d aelion:$ReleaseVersion

For more info, see:
  • docs/deployment.md
  • docs/architecture.md
  • README.md

"@ -ForegroundColor Green

exit 0
