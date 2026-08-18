
# Aelion HUD v0 - Terminal Dashboard
$ErrorActionPreference = "Stop"

function Get-LatestLog {
    param([string]$Folder)
    if (!(Test-Path $Folder)) { return $null }
    $files = Get-ChildItem $Folder -File | Sort-Object LastWriteTime -Descending
    if ($files.Count -eq 0) { return $null }
    return $files[0].FullName
}

function Summarize-Log {
    param([string]$Path)
    if (-not $Path) { return "No data" }
    $lines = Get-Content $Path
    if ($lines.Count -eq 0) { return "Empty log" }
    $last = $lines[-1]
    return $last
}

function Render-HUD {
    Clear-Host
    Write-Host "=== AELION HUD v0 ==="
    $stressLog       = Get-LatestLog "stress"
    $timelineLog     = Get-LatestLog "timeline"
    $snapshotLog     = Get-LatestLog "snapshot"
    $concurrencyLog  = Get-LatestLog "concurrency"
    $consistencyLog  = Get-LatestLog "consistency"
    $commLog         = Get-LatestLog "comm_matrix"
    $orchLog         = Get-LatestLog "orchestrator"

    Write-Host "Stress:       " (Summarize-Log $stressLog)
    Write-Host "Timeline:     " (Summarize-Log $timelineLog)
    Write-Host "Snapshot:     " (Summarize-Log $snapshotLog)
    Write-Host "Concurrency:  " (Summarize-Log $concurrencyLog)
    Write-Host "Consistency:  " (Summarize-Log $consistencyLog)
    Write-Host "Comm Matrix:  " (Summarize-Log $commLog)
    Write-Host "Orchestrator: " (Summarize-Log $orchLog)

    Write-Host ""
    Write-Host "Press Ctrl+C to exit."
}

while ($true) {
    Render-HUD
    Start-Sleep -Seconds 2
}

Write-Host "Aelion HUD terminated."
