---
name: finish-aelion
description: |
  Complete and finalize the Aelion performance monitoring system for production deployment.
  
  Use when: 
  - Preparing Aelion for production release
  - Completing build, test, and deployment verification
  - Finalizing documentation and configuration
  - Setting up deployment artifacts (Docker, Systemd)
  - Cleaning up working branch and preparing for release
  
  Triggers: "finish aelion", "complete aelion", "release aelion", "prepare aelion for production", "aelion deployment", "finalize aelion"
  
  NOT for: Development-only changes, debugging, or adding new features
---

# Finish Aelion - Production Completion Guide

## Overview

This skill automates comprehensive project completion for **Aelion**, a modular C performance monitoring system. It performs build verification, testing, documentation finalization, deployment preparation, and release checklist validation.

## Phase 1: Build & Verification

### 1.1 Ensure Clean Build
```bash
cd aelion
make clean
make all
```
**Success Criteria:**
- Binary created at `build/aelion_binary.exe` (Windows) or `build/aelion_binary` (Unix)
- Zero compilation errors
- No critical warnings

### 1.2 Run Unit & Integration Tests
```bash
make test
```
**Expected:** All test binaries pass execution
- Tests should complete without failures
- Core components verified: USP parser, bus, registry, security

### 1.3 Health Check
```bash
make check
```
**Expected:** Binary validation passes
- Confirms binary executable exists
- Verifies file integrity

## Phase 2: Documentation Verification

### 2.1 Check Key Documentation Files
- [ ] [docs/architecture.md](docs/architecture.md) - Architecture overview
- [ ] [docs/deployment.md](docs/deployment.md) - Deployment procedures
- [ ] [docs/engines.md](docs/engines.md) - Engine specifications
- [ ] [docs/governance.md](docs/governance.md) - Governance rules
- [ ] [docs/usp_protocol.md](docs/usp_protocol.md) - USP protocol specification
- [ ] [docs/hud.md](docs/hud.md) - HUD/Dashboard documentation
- [ ] [README.md](README.md) - Project overview

### 2.2 Verify Configuration Files
- [ ] [config/aelion.yml](config/aelion.yml) - Main configuration
- [ ] [config/engines.yml](config/engines.yml) - Engine configuration
- [ ] [config/governance.yml](config/governance.yml) - Governance configuration
- [ ] [config/usp_routes.yml](config/usp_routes.yml) - USP routing

## Phase 3: Deployment Artifacts

### 3.1 Docker Deployment
Located in `deploy/docker/`:
- [ ] Dockerfile exists and is production-ready
- [ ] Docker Compose configuration validated
- [ ] Container images can be built without errors

**Commands:**
```bash
cd deploy/docker
docker build -t aelion:latest .
```

### 3.2 Systemd Deployment
Located in `deploy/systemd/`:
- [ ] Service file properly configured
- [ ] Service can be installed: `sudo systemctl install aelion.service`
- [ ] Service starts and responds to health checks

### 3.3 Oracle Cloud Integration
Located in `deploy/oracle/`:
- [ ] OCI configuration templates present
- [ ] Deployment scripts validated

## Phase 4: Repository Cleanup

### 4.1 Git Status Verification
```bash
git status
```
**Expected state:**
- No uncommitted changes to critical files
- Build artifacts in `.gitignore`
- All meaningful changes committed

### 4.2 Cleanup Steps
```bash
# Clean build artifacts
make clean

# Remove temporary files
rm -rf build/ logs/*

# Stage documentation changes
git add docs/

# Verify final status
git status
```

### 4.3 Branch Validation
```bash
git log --oneline -10
git branch -v
```
**Expected:**
- On `master` branch (or intended release branch)
- Branch is synchronized with remote

## Phase 5: Configuration & Extension Setup

### 5.1 VS Code Workspace
- [x] **Extensions configured** in `.vscode/settings.json`:
  - `ms-vscode.cpptools` - C/C++ language support
  - `ms-vscode.makefile-tools` - Makefile support
  - `ms-vscode.powershell` - PowerShell scripting
  - `ms-vscode.git` - Git integration
  - `ms-vscode.hexeditor` - Binary inspection

### 5.2 Launch Configurations
Verify [.vscode/launch.json](.vscode/launch.json):
- [ ] Debugger configurations present
- [ ] Engine launch targets configured
- [ ] HUD runner configured

### 5.3 Build Tasks
Verify [.vscode/tasks.json](.vscode/tasks.json):
- [ ] `make all` task
- [ ] `make test` task
- [ ] `make clean` task
- [ ] Engine-specific runner tasks

## Phase 6: Engine Validation

Each engine should be independently verified:

### Engines to Validate
- [ ] **CPU Engine** - `run_engine_cpu.ps1`
- [ ] **GPU Engine** - `run_engine_gpu.ps1`
- [ ] **Memory Trace** - `run_engine_memtrace.ps1`
- [ ] **I/O Monitor** - `run_engine_io.ps1`
- [ ] **Network Watch** - `run_engine_net.ps1`
- [ ] **Deadlock Detector** - `run_engine_deadlock.ps1`
- [ ] **Disk Monitor** - `run_engine_disk.ps1`
- [ ] **Thermal Monitor** - (thermal engine)
- [ ] **Power Monitor** - `run_engine_power.ps1`
- [ ] **Consistency Checker** - `run_engine_consistency.ps1`
- [ ] **Concurrency Analyzer** - `run_engine_concurrency.ps1`
- [ ] **Comm Matrix** - `run_engine_comm_matrix.ps1`

### Validation Command
```bash
# Run a single engine test
PowerShell .\scripts\run_engine_cpu.ps1
```

## Phase 7: Release Checklist

### 7.1 Code Quality
- [ ] No compiler warnings
- [ ] All tests passing
- [ ] Code review completed
- [ ] Security audit completed (if applicable)

### 7.2 Documentation
- [ ] README.md up to date
- [ ] CHANGELOG.md generated (if versioning)
- [ ] API documentation complete
- [ ] Deployment guide finalized

### 7.3 Deployment Readiness
- [ ] Docker images build successfully
- [ ] Systemd service file tested
- [ ] Configuration templates validated
- [ ] Database schema finalized

### 7.4 Performance Baseline
- [ ] Performance metrics captured
- [ ] Stress tests completed
- [ ] Memory profiling verified
- [ ] Baseline established for monitoring

## Phase 8: Version & Release

### 8.1 Tag Release (if applicable)
```bash
git tag -a v1.0.0 -m "Aelion v1.0.0 - Production Release"
git push origin v1.0.0
```

### 8.2 Generate Release Notes
Document:
- Version number
- Build date
- Key features
- Known limitations
- Deployment instructions
- Rollback procedures

## Automated Completion Script

Execute this in PowerShell from the Aelion root:

```powershell
# finish-aelion.ps1
Write-Host "Starting Aelion Production Finalization..." -ForegroundColor Cyan

# Phase 1: Build
Write-Host "`n[Phase 1] Building..." -ForegroundColor Yellow
cd aelion
make clean
make all
if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed!" -ForegroundColor Red
    exit 1
}

# Phase 2: Tests
Write-Host "`n[Phase 2] Testing..." -ForegroundColor Yellow
make test
if ($LASTEXITCODE -ne 0) {
    Write-Host "Tests failed!" -ForegroundColor Red
    exit 1
}

# Phase 3: Health Check
Write-Host "`n[Phase 3] Health Check..." -ForegroundColor Yellow
make check
if ($LASTEXITCODE -ne 0) {
    Write-Host "Health check failed!" -ForegroundColor Red
    exit 1
}

# Phase 4: Git Status
Write-Host "`n[Phase 4] Repository Status..." -ForegroundColor Yellow
git status

# Phase 5: Documentation
Write-Host "`n[Phase 5] Verifying Documentation..." -ForegroundColor Yellow
$docFiles = @(
    "docs/architecture.md",
    "docs/deployment.md", 
    "docs/engines.md",
    "README.md"
)
foreach ($doc in $docFiles) {
    if (Test-Path $doc) {
        Write-Host "  ✓ $doc" -ForegroundColor Green
    } else {
        Write-Host "  ✗ MISSING: $doc" -ForegroundColor Red
    }
}

# Phase 6: Deployment Check
Write-Host "`n[Phase 6] Checking Deployment Artifacts..." -ForegroundColor Yellow
$deployDirs = @("deploy/docker", "deploy/systemd")
foreach ($dir in $deployDirs) {
    if (Test-Path $dir) {
        $fileCount = (Get-ChildItem $dir -Recurse | Measure-Object).Count
        Write-Host "  ✓ $dir ($fileCount files)" -ForegroundColor Green
    }
}

Write-Host "`n[COMPLETE] Aelion Finalization Checklist Complete!" -ForegroundColor Green
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Review documentation changes"
Write-Host "  2. Commit final changes: git commit -m 'Finalize Aelion for production'"
Write-Host "  3. Tag release: git tag -a v1.0.0 -m 'Release v1.0.0'"
Write-Host "  4. Push to remote: git push origin master && git push origin --tags"
```

## Troubleshooting

### Build Fails
- Clear build cache: `make clean`
- Verify GCC installation: `gcc --version`
- Check include paths in Makefile

### Tests Fail
- Review test output in `build/tests/`
- Verify database setup: `make -f sqlite/include/Makefile`
- Check for missing dependencies

### Docker Build Fails
- Verify Dockerfile syntax: `docker build --no-cache`
- Check base image availability
- Review build context

### Git Issues
- Stash changes: `git stash`
- Rebase if behind: `git rebase origin/master`
- Force sync: `git fetch --all && git reset --hard origin/master`

## Success Criteria

✓ All project completion phases passed  
✓ Binary builds without errors or warnings  
✓ All tests pass  
✓ Health check confirms binary validity  
✓ Documentation complete and up to date  
✓ Deployment artifacts ready  
✓ Repository clean and synchronized  
✓ Configuration finalized  

## Support

For issues or questions:
1. Review [docs/deployment.md](docs/deployment.md)
2. Check [README.md](README.md) 
3. Verify build logs in `build/`
4. Inspect test failures in `build/tests/`
