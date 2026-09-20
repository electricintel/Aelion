# AELION PROJECT DUMP SCRIPT (PowerShell)
# Dumps entire folder into upload-safe text chunks.

$AelionDir = "$HOME\Aelion"
$DumpDir   = "$HOME\Aelion_Dump"
$ChunkSize = 20000   # 20KB chunks

New-Item -ItemType Directory -Force -Path $DumpDir | Out-Null

$Manifest = "$DumpDir\manifest.txt"
"AEION DUMP MANIFEST" | Out-File $Manifest
"Generated: $(Get-Date)" | Out-File $Manifest -Append
"" | Out-File $Manifest -Append

function Dump-File {
    param([string]$FilePath)

    $RelPath = $FilePath.Replace($AelionDir + "\", "")
    $OutBase = ($RelPath -replace "\\", "__")
    $OutBaseFull = Join-Path $DumpDir $OutBase

    $FileSize = (Get-Item $FilePath).Length

    if ($FileSize -le $ChunkSize) {
        # Single chunk
        $OutFile = "$OutBaseFull.txt"
        "FILE: $RelPath -> $(Split-Path $OutFile -Leaf)" | Out-File $Manifest -Append
        "----- BEGIN $RelPath -----" | Out-File $OutFile
        Get-Content $FilePath | Out-File $OutFile -Append
        "----- END $RelPath -----" | Out-File $OutFile -Append
    }
    else {
        # Multi-chunk
        "FILE: $RelPath -> MULTI-CHUNK" | Out-File $Manifest -Append

        $Bytes = [System.IO.File]::ReadAllBytes($FilePath)
        $TotalChunks = [math]::Ceiling($Bytes.Length / $ChunkSize)

        for ($i = 0; $i -lt $TotalChunks; $i++) {
            $Start = $i * $ChunkSize
            $Length = [math]::Min($ChunkSize, $Bytes.Length - $Start)
            $ChunkBytes = $Bytes[$Start..($Start + $Length - 1)]

            $ChunkFile = "{0}_chunk_{1:D3}.txt" -f $OutBaseFull, $i
            [System.Text.Encoding]::UTF8.GetString($ChunkBytes) | Out-File $ChunkFile

            "  CHUNK: $(Split-Path $ChunkFile -Leaf)" | Out-File $Manifest -Append
        }
    }
}

Get-ChildItem -Path $AelionDir -Recurse -File | ForEach-Object {
    Dump-File $_.FullName
}

Write-Host ""
Write-Host "Dump complete."
Write-Host "Output directory: $DumpDir"
