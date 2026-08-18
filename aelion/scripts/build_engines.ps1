$ErrorActionPreference = "Stop"

$root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
Push-Location $root
try {
    if (-not (Get-Command make -ErrorAction SilentlyContinue)) {
        throw "make is required. Use the root Makefile to build engine objects."
    }
    & make engines
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
} finally {
    Pop-Location
}
