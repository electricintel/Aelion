# Aelion Run Script (PowerShell)

$ErrorActionPreference = "Stop"

$root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$binary = Join-Path $root "build\aelion_binary.exe"
$buildScript = Join-Path $PSScriptRoot "build_aelion.ps1"

if (!(Test-Path $binary) -and !(Test-Path (Join-Path $root "build\aelion_binary"))) {
    & $buildScript
}

$nativeBinary = if (Test-Path $binary) { $binary } else { Join-Path $root "build\aelion_binary" }
if (!(Test-Path $nativeBinary)) {
    throw "Aelion build failed: binary was not produced."
}

Push-Location $root
try {
    & $nativeBinary @args
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
} finally {
    Pop-Location
}
