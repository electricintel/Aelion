# Aelion Finalization Workflow

Complete and automated production release preparation for the Aelion performance monitoring system.

## Quick Start

```powershell
# Navigate to Aelion root directory
cd C:\dev\Aelion

# Run the finalization workflow
.\run-finish-aelion.ps1
```

## Scripts

### `run-finish-aelion.ps1` (Recommended Entry Point)
User-friendly wrapper with progress visualization and deployment guidance.

**Usage:**
```powershell
.\run-finish-aelion.ps1                    # Full finalization
.\run-finish-aelion.ps1 -SkipTests         # Skip test phase
.\run-finish-aelion.ps1 -DryRun            # Preview only
.\run-finish-aelion.ps1 -ReleaseVersion 2.0.0   # Custom version
```

### `finish-aelion.ps1` (Core Automation)
The main finalization automation engine. Called by `run-finish-aelion.ps1`.

**Phases:**
1. **Setup & Verification** - Validate environment
2. **Clean Build** - Full rebuild from scratch
3. **Testing** - Unit & integration tests
4. **Health Check** - Binary validation
5. **Documentation** - Verify docs complete
6. **Configuration** - Check config files
7. **Deployment** - Validate Docker/Systemd artifacts
8. **Git Status** - Repository state
9. **VS Code** - IDE configuration
10. **Engines** - Validate engine scripts
11. **Summary** - Release readiness report

## Skill File

**Location:** `.github/skills/finish-aelion/SKILL.md`

The skill defines all finalization phases, checklists, troubleshooting, and success criteria. Use this as reference documentation for manual finalization steps.

## What Gets Verified

### Build & Binaries
- ✓ Clean compilation (no errors/warnings)
- ✓ Binary creation: `build/aelion_binary.exe`
- ✓ Binary size and integrity

### Testing
- ✓ All unit tests pass
- ✓ Integration tests pass
- ✓ Test binaries exist and execute

### Documentation
- ✓ README.md present
- ✓ Architecture documentation
- ✓ Deployment guide
- ✓ Engine specifications
- ✓ Protocol documentation
- ✓ Governance documentation

### Configuration
- ✓ aelion.yml
- ✓ engines.yml
- ✓ governance.yml
- ✓ usp_routes.yml

### Deployment
- ✓ Docker support
- ✓ Systemd service files
- ✓ Oracle Cloud integration

### Repository
- ✓ Git branch state
- ✓ Working directory cleanliness
- ✓ Remote synchronization

### Development Environment
- ✓ VS Code settings
- ✓ Debug configurations
- ✓ Build tasks

### Engine Scripts
All 11 engine runners verified:
- CPU, GPU, Memory, I/O, Network, Deadlock
- Disk, Thermal, Power, Consistency, Concurrency, CommMatrix

## Release Workflow

```
┌─────────────────────────────────────┐
│  run-finish-aelion.ps1              │
│  (Entry point with UI)              │
└────────────┬────────────────────────┘
             │
             ↓
┌─────────────────────────────────────┐
│  finish-aelion.ps1                  │
│  (11-phase automation)              │
└────────────┬────────────────────────┘
             │
    ┌────────┴────────┬──────────┬─────────────┐
    ↓                 ↓          ↓             ↓
  Build           Tests    Documentation  Deployment
  ✓               ✓        ✓               ✓
    │                 │          │             │
    └────────┬────────┴──────────┴─────────────┘
             ↓
    ┌─────────────────────────────────────┐
    │  Release Ready Summary              │
    │  - All phases passed                │
    │  - Deployment instructions          │
    │  - Next steps                       │
    └─────────────────────────────────────┘
             ↓
    ┌─────────────────────────────────────┐
    │  Post-Finalization Steps:           │
    │  1. Commit changes                  │
    │  2. Create git tag                  │
    │  3. Push to GitHub                  │
    │  4. Deploy Docker image             │
    │  5. Start Systemd service           │
    └─────────────────────────────────────┘
```

## Success Criteria

All of the following must pass:

- [x] Binary builds without errors or warnings
- [x] All unit tests pass
- [x] All integration tests pass
- [x] Health check confirms binary validity
- [x] Documentation complete (6+ files)
- [x] Configuration files present (4+ files)
- [x] Deployment artifacts ready (Docker + Systemd)
- [x] Repository clean and synchronized
- [x] VS Code configuration complete
- [x] All 11 engine scripts present
- [x] Git status verified

## Error Handling

### Build Fails
```powershell
# Clear cache and rebuild
make clean
make all

# Check compiler
gcc --version

# Verify includes
head -20 Makefile
```

### Tests Fail
```powershell
# Run individual test
.\build\tests\test_usp.bin

# Check logs
ls -l build/tests/

# Verify database
sqlite3 :memory: .tables
```

### Git Issues
```powershell
# Check status
git status

# View recent commits
git log --oneline -10

# Stash changes if needed
git stash

# Sync with remote
git fetch origin
git reset --hard origin/master
```

## Advanced Usage

### Dry Run (Preview)
See what would execute without making changes:
```powershell
.\run-finish-aelion.ps1 -DryRun
```

### Skip Tests
If tests are already passing and you need speed:
```powershell
.\run-finish-aelion.ps1 -SkipTests
```

### Custom Release Version
Prepare for v2.0.0 instead of default v1.0.0:
```powershell
.\run-finish-aelion.ps1 -ReleaseVersion "2.0.0"
```

### Verbose Output
Enable detailed logging:
```powershell
.\run-finish-aelion.ps1 -Verbose
```

## Deployment After Finalization

### Docker
```bash
cd deploy/docker
docker build -t aelion:1.0.0 .
docker run -d --name aelion aelion:1.0.0
docker ps
```

### Systemd (Linux)
```bash
sudo cp deploy/systemd/aelion.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable aelion
sudo systemctl start aelion
sudo systemctl status aelion
```

### Verify Deployment
```bash
# Check binary is running
ps aux | grep aelion_binary

# View logs
tail -f logs/aelion.log

# Health check
curl http://localhost:8080/health
```

## Documentation References

- **Skill Details:** `.github/skills/finish-aelion/SKILL.md`
- **Architecture:** `docs/architecture.md`
- **Deployment:** `docs/deployment.md`
- **Engines:** `docs/engines.md`
- **README:** `README.md`

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Build times out | Build is running in background, wait 2-5 min |
| Tests fail | Run `make clean` then `make test` |
| Binary not found | Check `build/` directory exists and has .o files |
| Git conflicts | Run `git status` to see conflicts, then resolve |
| VS Code config missing | Restore from repo: `git checkout .vscode/` |

## Support

For detailed information on each phase, see:
- **SKILL.md** - Complete finalization guide with checklists
- **docs/** folder - Architecture and deployment docs
- **Makefile** - Build system details

## Examples

### Minimal Finalization
```powershell
cd C:\dev\Aelion
.\run-finish-aelion.ps1 -SkipTests  # Quick check (3-5 min)
```

### Full Production Release
```powershell
cd C:\dev\Aelion
.\run-finish-aelion.ps1 -ReleaseVersion "1.0.0"
# ... wait for completion ...
git tag -a v1.0.0 -m "Aelion Production Release v1.0.0"
git push origin master && git push origin --tags
cd aelion/deploy/docker
docker build -t aelion:1.0.0 .
```

### Continuous Integration
```powershell
# In CI/CD pipeline
.\run-finish-aelion.ps1 -DryRun  # Validation only
if ($LASTEXITCODE -eq 0) {
    # Deploy to staging
    docker build -t aelion:ci .
}
```

---

**Aelion** — Advanced System Performance Monitoring & Optimization  
Repository: https://github.com/electricintel/Aelion
