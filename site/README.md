# Mobile renders site

A phone-first gallery of the vertical / mobile renders — one 9:16 card per
video, section filter chips. Two sources:

- **`videos/manifest.json`** — finished portrait renders from the render
  queue, copied in as real files by the collect script below.
- **`videos/drive.json`** — the earlier vertical/mobile renders (2021-2025:
  the named `*_vertical` / `*mobile*` set, CA3, synapse, and build-in
  animations) played as Google Drive embeds straight from the archive
  folder "amy sterling videos file as of oct 11 2025". Nothing is copied;
  entries are just `{id, title, year}` and are easy to add or prune.
  Drive embeds play for anyone signed into an account with access to the
  files (your phone, signed into your Google account, works). To make them
  playable for others, share the files or folder with them.

## Updating it (on Aurelius)

```powershell
.\site\collect_mobile_renders.ps1
```

Scans `render_queue.json` for `done` jobs whose `res=WxH` is portrait (H > W),
copies their outputs from `D:\Meshes\renders\` into `site/videos/`, regenerates
the manifest, commits, and pushes. Files over 95 MB are skipped with a warning
(GitHub's hard limit is 100 MB per file) — re-encode those smaller first.

## Viewing it

- **Phone / anywhere:** enable GitHub Pages on this repo (Settings → Pages →
  Deploy from branch → `main`, root). The gallery is then at
  `https://amyleesterling.github.io/render-queue/site/`.
- **Locally:** any static server from the repo root, e.g.
  `python -m http.server` → http://localhost:8000/site/ (the manifest fetch
  doesn't work from a `file://` URL).
