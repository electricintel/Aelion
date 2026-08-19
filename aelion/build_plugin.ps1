param(
    [string]$Name = "hello"
)

$root = (Get-Location).Path

$src  = Join-Path $root "plugins\$Name.c"
$dll  = Join-Path $root "plugins\$Name.dll"

if (-not (Test-Path $src)) {
    Write-Host "Source not found: $src"
    exit 1
}

Write-Host "Building plugin $Name..."

# Include paths
$includeArgs = @(
    "-I$root\include",
    "-I$root\aelion\include",
    "-I$root\aelion\src\core",
    "-I$root\aelion\src\db",
    "-I$root\third_party\sqlite"
)

# Build arguments
$gccArgs = @(
    "-shared",
    "-o", $dll,
    $src,
    "$root\third_party\sqlite\sqlite3.c"
) + $includeArgs

& gcc $gccArgs

if (Test-Path $dll) {
    Write-Host "`nSUCCESS: Built plugin DLL → $dll"
} else {
    Write-Host "`nFAILED: Plugin did not build."
}
