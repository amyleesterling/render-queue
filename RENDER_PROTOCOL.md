# Render protocol

**Any agent building an animation follows this. It is short on purpose.**

Several Claude sessions work on this machine at once and there is **one GPU**.
Without a shared queue, sessions either collide, which has already killed two
overnight runs, or each keeps a private list nobody else can see. This document
fixes both.

---

## The one rule

> **If you built an animation, add it to the queue and stop. Do not render it.**

Rendering is the queue's job, at 02:00, when nobody is competing for the GPU.

---

## The three commands

Everything lives in **`D:\Meshes\queue.ps1`**. There is no other queue.

```powershell
# what is queued, running, done, across every project
D:\Meshes\queue.ps1 status

# add a job
D:\Meshes\queue.ps1 add -Project banc -Name shotA_loop `
  -Script D:\Meshes\banc_shotA_anim.py `
  -Arguments "frames=576","res=1080x1920","samples=64","out=D:\Meshes\renders\banc_shotA.mp4" `
  -Minutes 90 -Note "beats verified as stills" -AddedBy "chat: shot A"

# take one back out
D:\Meshes\queue.ps1 remove -Id 3
```

`queue.ps1 run` is what the scheduled task calls. **Do not call it by hand** unless
you mean to start rendering right now.

## What the queue does for you

- **Waits for a free GPU** before every job, up to four hours, then skips rather
  than fighting.
- **Moves any existing output aside** with a timestamp instead of overwriting it.
- **Web encodes** every mp4 on success, same treatment as the CA3 masters.
- **Logs everything** to `D:\Meshes\renders\queue_log.txt` with timestamps.
- **Writes status back** into `render_queue.json`, so `status` is always true:
  `queued` to `running` to `done` or `failed`.
- **Locks** while writing, so two sessions adding at the same moment cannot
  clobber each other.

## Before you add a job

The queue will happily render 100 minutes of black. It has no idea what the
picture should look like. So:

1. **Render single stills at each beat and LOOK at them.** Use the `stills=`
   argument so several beats come from one import; checking them one at a time
   costs a full re-import each, which is what makes people skip the check.
2. **A 2 second frame where 30 is normal means the scene is empty.** Check the
   object or collection count in the log before believing a fast render.
3. Put the beat check in the `-Note`, so the next person knows it was done.

## Where renders end up

| project | production | site repo | live |
|---|---|---|---|
| ca3 | `D:\Meshes\` | `C:\Users\amyle\ca3` | amyleesterling.github.io/ca3/ |
| banc | `D:\Meshes\banc\` | `C:\Users\amyle\banc` | amyleesterling.github.io/banc/ |
| microns | `D:\Meshes\` | `C:\Users\amyle\microns` | amyleesterling.github.io/microns/ |

**Production is one directory, publishing is many repos.** The reasoning is in
`ORGANISATION.md`. Adding a project means adding a row to `$Projects` at the top
of `queue.ps1` and a row here.

## The nightly task

`MeshesRenderQueue`, daily at 02:00, ten hour limit, starts late if the machine
was asleep. Retime it with:

```powershell
Set-ScheduledTask -TaskName MeshesRenderQueue `
  -Trigger (New-ScheduledTaskTrigger -Daily -At 03:00)
```

## If something looks stuck

- `render_queue.lock` left behind after a crash blocks all writes. Delete it.
- A job stuck at `running` means the run was interrupted. Edit its `status` back
  to `queued` in `render_queue.json`.
- A silently dead render with a truncated log and a missing output file is almost
  always **GPU contention**, not a code bug. Check what else was running first.
