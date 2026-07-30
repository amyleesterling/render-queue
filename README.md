# render-queue

**What is scheduled to render, readable from any device.**

`render_queue.json` is the state. `queue.ps1` is the only tool. `RENDER_PROTOCOL.md`
is the rule set.

## The one rule

If you built an animation, **add it to the queue and stop**. Do not render it.
Rendering happens at 23:00 on the machine that owns the GPU.

## From any device

```powershell
git pull
.\queue.ps1 status
.\queue.ps1 add -Project banc -Name shot_x -Script D:\Meshes\x.py `
  -Arguments "frames=576","out=D:\Meshes\renders\x.mp4" -Minutes 90 `
  -Note "beats verified as stills" -AddedBy "which chat"
```

Every write pulls first and pushes after, so two devices cannot silently diverge.
Reading the JSON directly is fine too, and is what a phone or a browser will do.

## Who actually renders

Only **Aurelius**, the Windows machine with the RTX 3090 and the meshes on `D:`.
Other devices can queue and inspect; they cannot render. A job added from
anywhere is picked up by Aurelius' `MeshesRenderQueue` scheduled task at 23:00.

## Job status

`queued` to `running` to `done` or `failed`, written back by the runner, so
`status` is never stale. `added_on` records which machine queued it.
