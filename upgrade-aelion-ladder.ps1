<#
.SYNOPSIS
Runs a versioned upgrade ladder, rolling back failed rungs.

.DESCRIPTION
Each rung runs in a disposable Git worktree. A rung is committed to the
checkpoint branch only after all validation commands pass. On failure, its
worktree is removed and the next run resumes at the last known-good commit.

.EXAMPLE
.\upgrade-aelion-ladder.ps1 -LadderFile .\upgrade-ladder.json

.NOTES
Runs offline by default. Ladder commands containing known network operations
are rejected unless -AllowNetwork is provided.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$LadderFile,
    [string]$Branch = "aelion/upgrade-ladder",
    [switch]$Restart,
    [switch]$KeepFailedWorktree,
    [switch]$AllowNetwork,
    [switch]$DryRun,
    [switch]$Loop,
    [ValidateRange(1, 86400)]
    [int]$IntervalSeconds = 300
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $PSCommandPath
$LadderPath = if ([IO.Path]::IsPathRooted($LadderFile)) { $LadderFile } else { Join-Path $ProjectRoot $LadderFile }
$PowerShellExe = if ($PSVersionTable.PSEdition -eq "Core") { "pwsh" } else { "powershell" }
$NetworkCommandPattern = '(?i)\b(git\s+(fetch|pull|clone|push)|curl|wget|invoke-webrequest|invoke-restmethod|npm\s+(install|update)|pip\s+install|winget\s+install|choco\s+install)\b'
$FailureLogPath = Join-Path $ProjectRoot "logs\upgrade-ladder-failures.log"
$restartFromHead = $Restart

function Invoke-GitAtRoot {
    param([string[]]$Arguments)

    & git -C $ProjectRoot @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "git $($Arguments -join ' ') failed with exit code $LASTEXITCODE."
    }
}

function Invoke-RungCommand {
    param(
        [string]$Command,
        [string]$Worktree,
        [string]$RungName,
        [string]$Phase
    )

    if (-not $AllowNetwork -and $Command -match $NetworkCommandPattern) {
        throw "Offline mode rejected a possible network command: $Command"
    }

    Write-Host "[$RungName] ${Phase}: $Command" -ForegroundColor Cyan
    if ($DryRun) { return }

    Push-Location $Worktree
    try {
        & $PowerShellExe -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command $Command
        if ($LASTEXITCODE -ne 0) {
            throw "$Phase command failed with exit code $LASTEXITCODE."
        }
    } finally {
        Pop-Location
    }
}

if (-not (Test-Path $LadderPath -PathType Leaf)) {
    throw "Ladder file not found: $LadderPath"
}

$ladder = Get-Content $LadderPath -Raw | ConvertFrom-Json
$rungs = @($ladder.rungs)
if ($rungs.Count -eq 0) {
    throw "The ladder file must contain a non-empty rungs array."
}

& git -C $ProjectRoot rev-parse --is-inside-work-tree | Out-Null
if ($LASTEXITCODE -ne 0) { throw "The script must run from a Git repository." }

$dirty = & git -C $ProjectRoot status --porcelain
if ($LASTEXITCODE -ne 0) { throw "Unable to inspect Git status." }
if ($dirty) {
    Write-Warning "Working tree has local changes. They will not be included in ladder worktrees."
}

function Invoke-LadderPass {
    $head = (& git -C $ProjectRoot rev-parse --verify HEAD).Trim()
    if ($LASTEXITCODE -ne 0) { throw "Unable to resolve HEAD." }

    & git -C $ProjectRoot show-ref --verify --quiet "refs/heads/$Branch"
    $branchExists = $LASTEXITCODE -eq 0
    if ($restartFromHead -or -not $branchExists) {
        Invoke-GitAtRoot @("branch", "-f", $Branch, $head)
        $checkpoint = $head
    } else {
        $checkpoint = (& git -C $ProjectRoot rev-parse $Branch).Trim()
        if ($LASTEXITCODE -ne 0) { throw "Unable to resolve checkpoint branch $Branch." }
    }

    Write-Host "Known-good checkpoint: $checkpoint" -ForegroundColor Yellow
    $worktreeRoot = Join-Path ([IO.Path]::GetTempPath()) "aelion-upgrade-ladder"
    New-Item -ItemType Directory -Path $worktreeRoot -Force | Out-Null

    foreach ($rung in $rungs) {
    if ([string]::IsNullOrWhiteSpace($rung.name)) { throw "Every rung requires a name." }
    if (@($rung.validate).Count -eq 0) { throw "Rung '$($rung.name)' requires validation commands." }

    $safeName = $rung.name -replace '[^A-Za-z0-9._-]', '_'
    $worktree = Join-Path $worktreeRoot ("$safeName-$([guid]::NewGuid().ToString('N'))")
    $passed = $false

    try {
        Invoke-GitAtRoot @("worktree", "add", "--detach", $worktree, $checkpoint)

        foreach ($command in @($rung.upgrade)) {
            if (-not [string]::IsNullOrWhiteSpace($command)) {
                Invoke-RungCommand $command $worktree $rung.name "upgrade"
            }
        }
        foreach ($command in @($rung.validate)) {
            Invoke-RungCommand $command $worktree $rung.name "validate"
        }

        if (-not $DryRun) {
            & git -C $worktree add --all
            if ($LASTEXITCODE -ne 0) { throw "Unable to stage changes." }
            & git -C $worktree diff --cached --quiet
            if ($LASTEXITCODE -eq 1) {
                & git -C $worktree commit -m "upgrade(aelion): $($rung.name)"
                if ($LASTEXITCODE -ne 0) { throw "Unable to commit successful rung." }
                $checkpoint = (& git -C $worktree rev-parse HEAD).Trim()
                if ($LASTEXITCODE -ne 0) { throw "Unable to resolve successful rung commit." }
                Invoke-GitAtRoot @("branch", "-f", $Branch, $checkpoint)
            } elseif ($LASTEXITCODE -gt 1) {
                throw "Unable to inspect staged changes."
            }
        }

        $passed = $true
        Write-Host "[$($rung.name)] passed. Checkpoint: $checkpoint" -ForegroundColor Green
    } catch {
        Write-Host "[$($rung.name)] failed. Rolled back to: $checkpoint" -ForegroundColor Red
        throw
    } finally {
        if ((Test-Path $worktree) -and ($passed -or -not $KeepFailedWorktree)) {
            & git -C $ProjectRoot worktree remove --force $worktree 2>$null
        }
    }
    }

    Write-Host "Ladder complete. Known-good branch: $Branch ($checkpoint)" -ForegroundColor Green
}

do {
    try {
        Invoke-LadderPass
        $restartFromHead = $false
    } catch {
        if (-not $Loop) { throw }

        $timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ssK"
        $logDirectory = Split-Path -Parent $FailureLogPath
        New-Item -ItemType Directory -Path $logDirectory -Force | Out-Null
        Add-Content -Path $FailureLogPath -Value "$timestamp $($_.Exception.Message)"
        $restartFromHead = $false
        Write-Warning "Pass failed and was rolled back. Retrying from $Branch in $IntervalSeconds seconds."
    }
    if ($Loop) {
        Write-Host "Next ladder pass in $IntervalSeconds seconds. Press Ctrl+C to stop." -ForegroundColor Yellow
        Start-Sleep -Seconds $IntervalSeconds
    }
} while ($Loop)