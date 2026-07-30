# The shared render queue. One file, one command, every session, every device.
#
#   .\queue.ps1 status
#   .\queue.ps1 add -Project banc -Name shotA_loop -Script D:\Meshes\banc_shotA_anim.py `
#                   -Arguments "frames=576","out=D:\Meshes\renders\x.mp4" `
#                   -Minutes 90 -Note "beats verified" -AddedBy "which chat"
#   .\queue.ps1 remove -Id 3
#   .\queue.ps1 run                # what the nightly scheduled task calls
#
# WHY THIS EXISTS. Several Claude sessions work on this machine at once and there
# is one GPU. Without a shared queue they collide, which has killed two overnight
# runs, or each keeps a private list nobody else can see.
#
# WHY IT IS A REPO. The queue state lives in git so it can be read and added to
# from any device, not just the machine that owns the GPU. Every write pulls
# first and pushes after, so a phone and a workstation cannot silently diverge.
#
# THE ONE RULE: if you built an animation, ADD IT AND STOP. Do not render it.
# Rendering happens at 23:00 when nothing is competing for the GPU.

[CmdletBinding()]
param(
  [Parameter(Position = 0)][ValidateSet('status', 'add', 'remove', 'run')]
  [string]$Command = 'status',
  [string]$Project,
  [string]$Name,
  [string]$Script,
  [string[]]$Arguments = @(),
  [int]$Minutes = 60,
  [string]$Note = '',
  [string]$AddedBy = '',
  [int]$Id,
  [switch]$NoSync          # work offline; state stays local until the next sync
)

$ErrorActionPreference = 'Continue'
$RepoDir   = Split-Path -Parent $MyInvocation.MyCommand.Path
$QueueFile = Join-Path $RepoDir 'render_queue.json'
$LockFile  = Join-Path $RepoDir '.queue.lock'
$LogFile   = 'D:\Meshes\renders\queue_log.txt'
$Blender   = 'C:\Program Files\Blender Foundation\Blender 4.4\blender.exe'
$ThisHost  = $env:COMPUTERNAME

function Say($m) {
  $line = '[{0}] {1}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $m
  Write-Output $line
  try { Add-Content -Path $LogFile -Value $line -Encoding utf8 } catch {}
}

# ---- git sync ------------------------------------------------------------------
function Sync-Pull {
  if ($NoSync) { return }
  Push-Location $RepoDir
  try { git pull --rebase --quiet origin main 2>&1 | Out-Null } catch {}
  Pop-Location
}
function Sync-Push($msg) {
  if ($NoSync) { return }
  Push-Location $RepoDir
  try {
    git add render_queue.json 2>&1 | Out-Null
    $dirty = git status --porcelain render_queue.json
    if ($dirty) {
      git -c user.name='render-queue' -c user.email='noreply@localhost' `
          commit -q -m "$msg [$ThisHost]" 2>&1 | Out-Null
      git pull --rebase --quiet origin main 2>&1 | Out-Null
      git push --quiet origin main 2>&1 | Out-Null
    }
  } catch { Write-Warning "queue: could not sync to git, state is local only" }
  Pop-Location
}

# ---- local lock, for two sessions on the SAME machine --------------------------
function Lock-Queue {
  for ($i = 0; $i -lt 60; $i++) {
    try { $fs = [IO.File]::Open($LockFile, 'CreateNew', 'Write', 'None'); $fs.Close(); return $true }
    catch { Start-Sleep -Milliseconds 500 }
  }
  Write-Warning 'Could not take the queue lock after 30s. Is a stale .queue.lock left behind?'
  return $false
}
function Unlock-Queue { try { Remove-Item $LockFile -Force -ErrorAction Stop } catch {} }

function Read-Queue {
  if (-not (Test-Path $QueueFile)) { return [pscustomobject]@{ version = 1; next_id = 1; jobs = @() } }
  # strip a byte order mark if some other tool left one, so ConvertFrom-Json cannot choke
  ((Get-Content $QueueFile -Raw) -replace "^﻿", '') | ConvertFrom-Json
}
function Write-Queue($q) {
  # UTF-8 WITHOUT a BOM. PowerShell 5.1's `Out-File -Encoding utf8` writes one,
  # and a BOM makes this file unreadable to every other tool that matters here:
  # Python's json.load raises "Unexpected UTF-8 BOM", and so does jq. The whole
  # point of the queue is that another device or another agent can read it, so a
  # BOM quietly breaks the feature.
  $json = $q | ConvertTo-Json -Depth 8
  [IO.File]::WriteAllText($QueueFile, $json, (New-Object Text.UTF8Encoding($false)))
}

$Projects = @{
  ca3     = 'https://amyleesterling.github.io/ca3/'
  banc    = 'https://amyleesterling.github.io/banc/'
  microns = 'https://amyleesterling.github.io/microns/'
}

switch ($Command) {

  'status' {
    Sync-Pull
    $q = Read-Queue
    $gpu = Get-Process blender -ErrorAction SilentlyContinue
    Write-Output ''
    Write-Output "  RENDER QUEUE            (shared repo, read from any device)"
    Write-Output '  ------------'
    if ($gpu) {
      Write-Output ('  GPU on {0}: BUSY, {1} blender process(es)' -f $ThisHost, @($gpu).Count)
    } else {
      Write-Output ('  GPU on {0}: free' -f $ThisHost)
    }
    $task = Get-ScheduledTask -TaskName 'MeshesRenderQueue' -ErrorAction SilentlyContinue
    if ($task) {
      Write-Output ('  Nightly task: {0}, next {1}' -f $task.State,
                    (Get-ScheduledTaskInfo -TaskName 'MeshesRenderQueue').NextRunTime)
    } else {
      Write-Output ('  Nightly task: not registered on {0} (renders happen on Aurelius)' -f $ThisHost)
    }
    Write-Output ''
    if (-not $q.jobs -or @($q.jobs).Count -eq 0) {
      Write-Output '  (no jobs)'
    } else {
      '  {0,-3} {1,-8} {2,-20} {3,-8} {4,5}  {5}' -f 'id','project','name','status','min','note'
      '  {0,-3} {1,-8} {2,-20} {3,-8} {4,5}  {5}' -f '---','-------','--------------------','-------','---','----'
      foreach ($j in @($q.jobs)) {
        '  {0,-3} {1,-8} {2,-20} {3,-8} {4,5}  {5}' -f $j.id,$j.project,$j.name,$j.status,$j.expect_minutes,$j.note
      }
      Write-Output ''
      foreach ($s in 'queued','running','done','failed') {
        $n = @($q.jobs | Where-Object { $_.status -eq $s }).Count
        if ($n) { Write-Output ('  {0}: {1}' -f $s, $n) }
      }
      $m = (@($q.jobs | Where-Object { $_.status -eq 'queued' }) | Measure-Object expect_minutes -Sum).Sum
      if ($m) { Write-Output ('  queued GPU time: about {0} min' -f $m) }
    }
    Write-Output ''
  }

  'add' {
    if (-not $Project -or -not $Name -or -not $Script) { Write-Error 'add needs -Project, -Name and -Script'; break }
    if (-not $Projects.ContainsKey($Project)) {
      Write-Warning ("project '{0}' is not one of: {1}" -f $Project, ($Projects.Keys -join ', '))
    }
    Sync-Pull
    if (-not (Lock-Queue)) { break }
    try {
      $q = Read-Queue
      $job = [pscustomobject]@{
        id = $q.next_id; project = $Project; name = $Name; script = $Script
        args = $Arguments; expect_minutes = $Minutes; status = 'queued'; note = $Note
        added_by = $(if ($AddedBy) { $AddedBy } else { 'unattributed' })
        added_on = $ThisHost
        added = (Get-Date -Format 's'); started = $null; finished = $null; output = $null
      }
      $q.jobs = @($q.jobs) + $job
      $q.next_id = $q.next_id + 1
      Write-Queue $q
      Say ("QUEUED #{0} {1}/{2}, about {3} min" -f $job.id, $Project, $Name, $Minutes)
    } finally { Unlock-Queue }
    Sync-Push ("queue: add #{0} {1}/{2}" -f ($q.next_id - 1), $Project, $Name)
  }

  'remove' {
    Sync-Pull
    if (-not (Lock-Queue)) { break }
    try {
      $q = Read-Queue
      $q.jobs = @($q.jobs | Where-Object { $_.id -ne $Id })
      Write-Queue $q
      Say ("removed #{0}" -f $Id)
    } finally { Unlock-Queue }
    Sync-Push ("queue: remove #{0}" -f $Id)
  }

  'run' {
    Say '=== queue run starting ==='
    Sync-Pull
    $q = Read-Queue
    $todo = @($q.jobs | Where-Object { $_.status -eq 'queued' })
    Say ("{0} queued job(s)" -f $todo.Count)

    foreach ($j in $todo) {
      $waited = 0
      while (Get-Process blender -ErrorAction SilentlyContinue) {
        if ($waited -eq 0) { Say ("#{0} {1}: another Blender is running, waiting" -f $j.id, $j.name) }
        Start-Sleep -Seconds 60; $waited++
        if ($waited -ge 240) { break }
      }
      if ($waited -ge 240) { Say ("#{0}: SKIPPED, GPU busy 4h" -f $j.id); continue }

      $out = ''
      foreach ($a in @($j.args)) { if ($a -like 'out=*') { $out = $a -replace '^out=', '' } }
      if ($out -and (Test-Path $out)) {
        $stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
        Move-Item $out ([IO.Path]::ChangeExtension($out, $null) + "prev_$stamp" + [IO.Path]::GetExtension($out)) -Force
        Say ("#{0}: previous output moved aside" -f $j.id)
      }

      if (Lock-Queue) {
        try { $qq = Read-Queue
              foreach ($x in $qq.jobs) { if ($x.id -eq $j.id) { $x.status='running'; $x.started=(Get-Date -Format 's') } }
              Write-Queue $qq } finally { Unlock-Queue }
        Sync-Push ("queue: #{0} running" -f $j.id)
      }

      Say ("#{0} {1}/{2}: starting, about {3} min" -f $j.id, $j.project, $j.name, $j.expect_minutes)
      $t0 = Get-Date
      $argv = @('--background','--python',$j.script,'--') + @($j.args)
      & $Blender @argv 2>&1 |
        Select-String -Pattern 'rendered in|frames in|s/frame|Error|Traceback|DONE' |
        Select-Object -Last 4 | ForEach-Object { Say ("#{0}:   {1}" -f $j.id, $_.Line.Trim()) }
      $mins = [math]::Round(((Get-Date) - $t0).TotalMinutes, 1)

      $ok = $out -and (Test-Path $out)
      if ($ok) {
        Say ("#{0}: DONE in {1} min, {2} MB" -f $j.id, $mins, [math]::Round((Get-Item $out).Length/1MB,1))
        if ($out -like '*.mp4') {
          $web = [IO.Path]::ChangeExtension($out, $null) + 'web.mp4'
          ffmpeg -y -v error -i $out -c:v libx264 -preset slow -crf 23 -pix_fmt yuv420p `
                 -movflags +faststart -an $web 2>$null
          if (Test-Path $web) { Say ("#{0}: web encode {1} MB" -f $j.id, [math]::Round((Get-Item $web).Length/1MB,1)) }
        }
      } else { Say ("#{0}: FAILED, no output after {1} min" -f $j.id, $mins) }

      if (Lock-Queue) {
        try { $qq = Read-Queue
              foreach ($x in $qq.jobs) {
                if ($x.id -eq $j.id) {
                  if ($ok) { $x.status='done' } else { $x.status='failed' }
                  $x.finished=(Get-Date -Format 's'); $x.output=$out
                } }
              Write-Queue $qq } finally { Unlock-Queue }
        Sync-Push ("queue: #{0} {1}" -f $j.id, $(if ($ok) { 'done' } else { 'failed' }))
      }
    }
    Say '=== queue run finished ==='
  }
}
