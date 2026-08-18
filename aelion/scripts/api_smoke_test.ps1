param(
    [int]$Port = 18095,
    [string]$Token = "aelion-smoke-token"
)

$ErrorActionPreference = "Stop"
$root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$dataDir = Join-Path $root "build\api-smoke-data"
$binary = Join-Path $root "build\aelion_binary.exe"
if (!(Test-Path $binary)) { $binary = Join-Path $root "build\aelion_binary" }

Remove-Item $dataDir -Recurse -Force -ErrorAction SilentlyContinue
$env:AELION_API_TOKEN = $Token
$env:AELION_DATA_DIR = $dataDir
$process = Start-Process -FilePath $binary -ArgumentList "--serve", $Port -PassThru -WindowStyle Hidden
try {
    $headers = @{ Authorization = "Bearer $Token" }
    $ready = $false
    for ($attempt = 0; $attempt -lt 30; $attempt++) {
        try {
            Invoke-RestMethod "http://127.0.0.1:$Port/api/v1/health" -Headers $headers | Out-Null
            $ready = $true
            break
        } catch { Start-Sleep -Milliseconds 100 }
    }
    if (!$ready) { throw "API did not become ready." }

    $body = @{ request = "justice.review" } | ConvertTo-Json -Compress
    $result = Invoke-RestMethod "http://127.0.0.1:$Port/api/v1/requests" -Method Post -Headers $headers -ContentType "application/json" -Body $body
    $metrics = Invoke-RestMethod "http://127.0.0.1:$Port/api/v1/metrics" -Headers $headers
    if (!$result.accepted -or $metrics.last_event -ne "justice.review") { throw "API smoke assertions failed." }
    Write-Host "API_SMOKE=passed"
    Write-Host "REQUEST_ACCEPTED=$($result.accepted)"
    Write-Host "LAST_EVENT=$($metrics.last_event)"
} finally {
    if (!$process.HasExited) { Stop-Process -Id $process.Id -Force }
    Remove-Item Env:AELION_API_TOKEN -ErrorAction SilentlyContinue
    Remove-Item Env:AELION_DATA_DIR -ErrorAction SilentlyContinue
}
