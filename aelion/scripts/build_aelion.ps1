$ErrorActionPreference = "Stop"

$root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
Push-Location $root
try {
    if (-not (Get-Command make -ErrorAction SilentlyContinue)) {
        throw "make is required. Use scripts/build_all.sh or install a make-compatible tool."
    }
    & make all
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
} finally {
    Pop-Location
}
