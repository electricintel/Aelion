param(
    [string]$Name
)

if (-not $Name) {
    Write-Host "Usage: .\new_plugin.ps1 -Name MyPlugin"
    exit 1
}

$root = (Get-Location).Path
$path = Join-Path $root "plugins\$Name.c"

if (Test-Path $path) {
    Write-Host "File already exists: $path"
    exit 1
}

$code = @"
#include <stdio.h>
#include "aelion_db.h"

__declspec(dllexport)
void aelion_plugin_entry(aelion_db_t *db, const char *cmd) {
    printf("\x1b[35m[$Name PLUGIN] Command: %s\x1b[0m\n", cmd);
}
"@

Set-Content -LiteralPath $path -Value $code

Write-Host "Created plugin template: $path"
Write-Host "Build it with: .\build_plugin.ps1 -Name $Name"
Write-Host "Then in Aelion shell: plugin load $Name; plugin call $Name test123"
