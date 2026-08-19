Write-Host "Building Aelion shell..."

# Ensure bin directory exists
if (-not (Test-Path "bin")) {
    New-Item -ItemType Directory -Path "bin" | Out-Null
}

# Run make
& make

if (Test-Path "bin/aelion.exe") {
    Write-Host "`nSUCCESS: bin/aelion.exe built."
} else {
    Write-Host "`nFAILED: Aelion shell did not build."
}
