
# Aelion Makefile Auditor (Stable Version)
$ErrorActionPreference = "Stop"

$makefile = "Makefile"

if (!(Test-Path $makefile)) {
    Write-Host "[ERROR] No Makefile found." -ForegroundColor Red
    exit 1
}

$lines = Get-Content $makefile
$targets = @()

$lineNumber = 0

foreach ($line in $lines) {

    # SPACE-INDENTED RECIPE
    if ($line -match "^[ ]+[^ ]") {
        if ($line.Trim() -notmatch "^[A-Za-z0-9_-]+:") {
            $report += ("Line {0} - SPACE-INDENTED RECIPE" -f $lineNumber)
        }
    }

    # MISSING COLON IN TARGET
    if ($line -match "^[A-Za-z0-9_-]+[ ]+$") {
        $report += ("Line {0} - POSSIBLE MISSING COLON IN TARGET" -f $lineNumber)
    }

    # DOUBLE COLON TARGET
    if ($line -match "^[A-Za-z0-9_-]+::") {
        $report += ("Line {0} - DOUBLE-COLON TARGET" -f $lineNumber)
    }

    # EMPTY RECIPE LINE
    if ($line -match "^\t\s*$") {
        $report += ("Line {0} - EMPTY RECIPE LINE" -f $lineNumber)
    }

    # RECIPE NOT ATTACHED TO TARGET
    if ($line -match "^\t" -and $lineNumber -gt 1) {
        $prev = $lines[$lineNumber - 2]
        if ($prev.Trim().Length -eq 0) {
            $report += ("Line {0} - RECIPE NOT ATTACHED TO TARGET" -f $lineNumber)
        }
    }

    # DUPLICATE TARGETS
    if ($line -match "^[A-Za-z0-9_-]+:") {
        $target = $line.Split(":")[0].Trim()
        if ($targets -contains $target) {
            $report += ("Line {0} - DUPLICATE TARGET: {1}" -f $lineNumber, $target)
        } else {
            $targets += $target
        }
    }
Write-Host "=== MAKEFILE AUDIT REPORT ===" -ForegroundColor Cyan

if ($report.Count -eq 0) {
    Write-Host "No issues detected." -ForegroundColor Green
} else {
    foreach ($r in $report) { Write-Host $r -ForegroundColor Yellow }
}

Write-Host "=== END OF REPORT ===" -ForegroundColor Cyan
