# Collect every finished vertical (portrait) render into site/videos/ and
# regenerate the manifest the gallery page reads. Run on Aurelius:
#   .\site\collect_mobile_renders.ps1
# Follows the repo rule: pull first, push after.

$ErrorActionPreference = 'Stop'
$repo = Split-Path $PSScriptRoot -Parent
Set-Location $repo

git pull --quiet

$queue = Get-Content (Join-Path $repo 'render_queue.json') -Raw | ConvertFrom-Json
$videosDir = Join-Path $repo 'site\videos'
New-Item -ItemType Directory -Force -Path $videosDir | Out-Null

$entries = @()
foreach ($job in $queue.jobs) {
    if ($job.status -ne 'done' -or -not $job.output) { continue }

    $res = ($job.args | Where-Object { $_ -like 'res=*' }) -replace 'res=', ''
    if (-not $res) { continue }
    $w, $h = $res -split 'x' | ForEach-Object { [int]$_ }
    if ($h -le $w) { continue }   # portrait only

    if (-not (Test-Path $job.output)) {
        Write-Warning "job $($job.id) $($job.name): output missing: $($job.output)"
        continue
    }

    $file = Split-Path $job.output -Leaf
    $dest = Join-Path $videosDir $file
    $srcItem = Get-Item $job.output
    if ($srcItem.Length -gt 95MB) {
        Write-Warning "job $($job.id) ${file}: $([math]::Round($srcItem.Length/1MB)) MB exceeds GitHub's 100 MB file limit - skipped. Re-encode smaller (e.g. ffmpeg -crf 26) or host it elsewhere."
        continue
    }
    if (-not (Test-Path $dest) -or $srcItem.LastWriteTimeUtc -gt (Get-Item $dest).LastWriteTimeUtc) {
        Copy-Item $job.output $dest -Force
        Write-Host "copied  $file"
    } else {
        Write-Host "current $file"
    }

    $entries += [ordered]@{
        file     = $file
        name     = $job.name
        project  = $job.project
        job_id   = $job.id
        res      = $res
        finished = $job.finished
        note     = $job.note
    }
}

# Later jobs win when two jobs wrote the same output file.
$byFile = [ordered]@{}
foreach ($e in $entries) { $byFile[$e.file] = $e }

$manifest = [ordered]@{
    generated = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
    videos    = @($byFile.Values)
}
$manifest | ConvertTo-Json -Depth 4 | Set-Content (Join-Path $videosDir 'manifest.json') -Encoding UTF8
Write-Host "manifest: $($byFile.Count) videos"

git add site/videos
if (git status --porcelain site/videos) {
    git commit --quiet -m "site: update mobile renders [$env:COMPUTERNAME]"
    git push --quiet
    Write-Host 'pushed'
} else {
    Write-Host 'no changes'
}
