
$ErrorActionPreference = "Stop"
$makefile = "Makefile"

if (!(Test-Path $makefile)) { Write-Host "[ERROR] Makefile not found." -ForegroundColor Red; exit 1 }

$lines = Get-Content $makefile
$lineNumber = 0

foreach ($line in $lines) {
    $lineNumber++
    Write-Host ("{0}: {1}" -f $lineNumber, $line)
}
