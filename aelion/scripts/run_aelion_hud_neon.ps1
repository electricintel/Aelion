
# Aelion HUD v1 - Neon Pulse Edition
$ErrorActionPreference = "Stop"

function Glow-Bar {
    param([int]$Value)
    $len = [math]::Floor($Value / 5)
    $bar = ("¦" * $len)
    return $bar
}

function Glow-Color {
    param([int]$Value)
    if ($Value -gt 80) { return "Red" }
    if ($Value -gt 60) { return "Magenta" }
    if ($Value -gt 40) { return "Yellow" }
    return "Green"
}

function Pulse {
    param([int]$Step)
    $wave = @("·","•","?","•")
    return $wave[$Step % $wave.Count]
}

function Read-Latest {
    if (!(Test-Path $Folder)) { return "no data" }
    $files = Get-ChildItem $Folder -File | Sort-Object LastWriteTime -Descending
    if ($files.Count -eq 0) { return "empty" }
    $lines = Get-Content $files[0].FullName
    if ($lines.Count -eq 0) { return "empty" }
    return $lines[-1]
}

function Render-NeonHUD {
    param([int]$Step)
    Clear-Host
    Write-Host "+------------------------------------------------------+" -ForegroundColor Cyan
    Write-Host "¦                AELION HUD — NEON PULSE               ¦" -ForegroundColor Cyan
    Write-Host "+------------------------------------------------------+" -ForegroundColor Cyan

    $cpu = Get-Random -Minimum 5 -Maximum 95
    $gpu = Get-Random -Minimum 5 -Maximum 90
    $mem = Get-Random -Minimum 500 -Maximum 16000
    $net = Get-Random -Minimum 0 -Maximum 2000

    $pulse = Pulse -Step $Step

    Write-Host ""
    Write-Host "   SYSTEM PULSE: $pulse" -ForegroundColor Magenta

    Write-Host "   CPU  [$cpu%] $(Glow-Bar $cpu)" -ForegroundColor (Glow-Color $cpu)
    Write-Host "   GPU  [$gpu%] $(Glow-Bar $gpu)" -ForegroundColor (Glow-Color $gpu)
    Write-Host "   MEM  [$mem MB]" -ForegroundColor Cyan
    Write-Host "   NET  [$net KB/s]" -ForegroundColor Blue

    Write-Host ""
    Write-Host "   ENGINE FEEDS:" -ForegroundColor Yellow

    Write-Host "     Stress:       $(Read-Latest "stress")" -ForegroundColor DarkYellow
    Write-Host "     Timeline:     $(Read-Latest "timeline")" -ForegroundColor DarkYellow
    Write-Host "     Snapshot:     $(Read-Latest "snapshot")" -ForegroundColor DarkYellow
    Write-Host "     Consistency:  $(Read-Latest "consistency")" -ForegroundColor DarkYellow
    Write-Host "     Comm Matrix:  $(Read-Latest "comm_matrix")" -ForegroundColor DarkYellow
    Write-Host "     Orchestrator: $(Read-Latest "orchestrator")" -ForegroundColor DarkYellow

    Write-Host ""
    Write-Host "   Press Ctrl+C to exit." -ForegroundColor Gray
}

$step = 0
while ($true) {
    Render-NeonHUD -Step $step
    $step++
    Start-Sleep -Milliseconds 200
}

Write-Host "Aelion Neon HUD terminated."
