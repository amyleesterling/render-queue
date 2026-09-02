# Mobile renders site

A phone-first gallery of every finished **vertical** (portrait) render in the
queue. `index.html` reads `videos/manifest.json` and shows one 9:16 video per
card — autoplaying whichever is on screen, with project filter chips.

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
