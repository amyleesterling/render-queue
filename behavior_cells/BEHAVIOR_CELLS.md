# Behavior cells — BANC

Color-coded neuroglancer view and mesh download for the behavior descending
neurons (plus the compass EPGs). IDs come from the public BANC static mesh
layer (`gs://lee-lab_brain-and-nerve-cord-fly-connectome/neuron_meshes`,
segment properties snapshot 2026-09-01), so they load in the public viewer
without a CAVE token.

## Open the color-coded view

Paste the link below into a browser (same viewer as https://ng.banc.community/view).
Each behavior is its own layer, so you can toggle them individually. The
`alt_grooming_DNg12` layer starts archived/off.

<details><summary>Neuroglancer link (long URL)</summary>

https://spelunker.cave-explorer.org/#!%7B%22title%22%3A%22Behavior%20DNs%20color-coded%22%2C%22dimensions%22%3A%7B%22x%22%3A%5B4e-09%2C%22m%22%5D%2C%22y%22%3A%5B4e-09%2C%22m%22%5D%2C%22z%22%3A%5B4.5e-08%2C%22m%22%5D%7D%2C%22position%22%3A%5B125097.5%2C122589.5%2C2827.5%5D%2C%22projectionOrientation%22%3A%5B0.7071%2C0%2C0%2C0.7071%5D%2C%22projectionScale%22%3A400000%2C%22showSlices%22%3Afalse%2C%22layout%22%3A%223d%22%2C%22layers%22%3A%5B%7B%22type%22%3A%22segmentation%22%2C%22source%22%3A%7B%22url%22%3A%22precomputed%3A%2F%2Fgs%3A%2F%2Flee-lab_brain-and-nerve-cord-fly-connectome%2Fregion_outlines%22%2C%22subsources%22%3A%7B%22bounds%22%3Atrue%2C%22properties%22%3Atrue%2C%22mesh%22%3Atrue%7D%2C%22enableDefaultSubsources%22%3Afalse%7D%2C%22pick%22%3Afalse%2C%22tab%22%3A%22segments%22%2C%22meshSilhouetteRendering%22%3A2%2C%22segments%22%3A%5B%221%22%5D%2C%22segmentColors%22%3A%7B%221%22%3A%22%23666666%22%7D%2C%22objectAlpha%22%3A0.15%2C%22name%22%3A%22CNS%20outline%22%7D%2C%7B%22type%22%3A%22segmentation%22%2C%22source%22%3A%22precomputed%3A%2F%2Fgs%3A%2F%2Flee-lab_brain-and-nerve-cord-fly-connectome%2Fneuron_meshes%22%2C%22tab%22%3A%22segments%22%2C%22segments%22%3A%5B%22720575941626500746%22%2C%22720575941500851362%22%5D%2C%22segmentDefaultColor%22%3A%22%2300d26a%22%2C%22name%22%3A%22Forward%20walking%20-%20DNg100%20%28green%29%22%7D%2C%7B%22type%22%3A%22segmentation%22%2C%22source%22%3A%22precomputed%3A%2F%2Fgs%3A%2F%2Flee-lab_brain-and-nerve-cord-fly-connectome%2Fneuron_meshes%22%2C%22tab%22%3A%22segments%22%2C%22segments%22%3A%5B%22720575941510475536%22%5D%2C%22segmentDefaultColor%22%3A%22%232979ff%22%2C%22name%22%3A%22Turn%20LEFT%20-%20DNa02%20L%20%28blue%29%22%7D%2C%7B%22type%22%3A%22segmentation%22%2C%22source%22%3A%22precomputed%3A%2F%2Fgs%3A%2F%2Flee-lab_brain-and-nerve-cord-fly-connectome%2Fneuron_meshes%22%2C%22tab%22%3A%22segments%22%2C%22segments%22%3A%5B%22720575941456897005%22%5D%2C%22segmentDefaultColor%22%3A%22%23ff9500%22%2C%22name%22%3A%22Turn%20RIGHT%20-%20DNa02%20R%20%28orange%29%22%7D%2C%7B%22type%22%3A%22segmentation%22%2C%22source%22%3A%22precomputed%3A%2F%2Fgs%3A%2F%2Flee-lab_brain-and-nerve-cord-fly-connectome%2Fneuron_meshes%22%2C%22tab%22%3A%22segments%22%2C%22segments%22%3A%5B%22720575941533807082%22%2C%22720575941655117012%22%2C%22720575941439740895%22%2C%22720575941448922717%22%2C%22720575941438719967%22%5D%2C%22segmentDefaultColor%22%3A%22%23ff5ce1%22%2C%22name%22%3A%22Grooming%20-%20DNg11%20%28pink%29%22%7D%2C%7B%22type%22%3A%22segmentation%22%2C%22source%22%3A%22precomputed%3A%2F%2Fgs%3A%2F%2Flee-lab_brain-and-nerve-cord-fly-connectome%2Fneuron_meshes%22%2C%22tab%22%3A%22segments%22%2C%22segments%22%3A%5B%22720575941509145950%22%2C%22720575941451068597%22%5D%2C%22segmentDefaultColor%22%3A%22%23ff3b30%22%2C%22name%22%3A%22Escape%20-%20DNp01%20Giant%20Fiber%20%28red%29%22%7D%2C%7B%22type%22%3A%22segmentation%22%2C%22source%22%3A%22precomputed%3A%2F%2Fgs%3A%2F%2Flee-lab_brain-and-nerve-cord-fly-connectome%2Fneuron_meshes%22%2C%22tab%22%3A%22segments%22%2C%22segments%22%3A%5B%22720575941551589181%22%2C%22720575941478215985%22%5D%2C%22segmentDefaultColor%22%3A%22%23ffd60a%22%2C%22name%22%3A%22Takeoff%20-%20DNp11%20%28yellow%29%22%7D%2C%7B%22type%22%3A%22segmentation%22%2C%22source%22%3A%22precomputed%3A%2F%2Fgs%3A%2F%2Flee-lab_brain-and-nerve-cord-fly-connectome%2Fneuron_meshes%22%2C%22tab%22%3A%22segments%22%2C%22segments%22%3A%5B%22720575941593683051%22%2C%22720575941440683743%22%5D%2C%22segmentDefaultColor%22%3A%22%2300e0c6%22%2C%22name%22%3A%22Landing%20-%20DNp10%20%28teal%29%22%7D%2C%7B%22type%22%3A%22segmentation%22%2C%22source%22%3A%22precomputed%3A%2F%2Fgs%3A%2F%2Flee-lab_brain-and-nerve-cord-fly-connectome%2Fneuron_meshes%22%2C%22tab%22%3A%22segments%22%2C%22segments%22%3A%5B%22720575941432144632%22%2C%22720575941575965800%22%2C%22720575941574135912%22%2C%22720575941535506698%22%2C%22720575941536820629%22%2C%22720575941601934521%22%2C%22720575941401716003%22%2C%22720575941412066961%22%2C%22720575941553465939%22%2C%22720575941483979842%22%2C%22720575941547561588%22%2C%22720575941353100336%22%2C%22720575941433596192%22%2C%22720575941533800792%22%2C%22720575941475541825%22%2C%22720575941472363818%22%2C%22720575941469187703%22%2C%22720575941685212655%22%2C%22720575941521625847%22%2C%22720575941572937288%22%2C%22720575941686438006%22%2C%22720575941579379321%22%2C%22720575941456244208%22%2C%22720575941460051270%22%2C%22720575941557402350%22%2C%22720575941592825558%22%2C%22720575941439306587%22%2C%22720575941573294088%22%2C%22720575941546910241%22%2C%22720575941556150500%22%2C%22720575941496157639%22%2C%22720575941474920234%22%2C%22720575941405938735%22%2C%22720575941730684971%22%2C%22720575941551738247%22%2C%22720575941654968532%22%2C%22720575941609869741%22%2C%22720575941429594327%22%2C%22720575941408776239%22%2C%22720575941632499616%22%2C%22720575941552623873%22%2C%22720575941588727436%22%2C%22720575941566154599%22%2C%22720575941515235587%22%2C%22720575941412215407%22%5D%2C%22segmentDefaultColor%22%3A%22%23bd9bd1%22%2C%22name%22%3A%22Compass%20-%20EPG%20%28lavender%29%22%7D%2C%7B%22type%22%3A%22segmentation%22%2C%22source%22%3A%22precomputed%3A%2F%2Fgs%3A%2F%2Flee-lab_brain-and-nerve-cord-fly-connectome%2Fneuron_meshes%22%2C%22tab%22%3A%22segments%22%2C%22segments%22%3A%5B%22720575941493928064%22%2C%22720575941547473268%22%2C%22720575941535811562%22%2C%22720575941536326805%22%2C%22720575941489195724%22%2C%22720575941557512307%22%2C%22720575941572392201%22%2C%22720575941629386732%22%2C%22720575941429383521%22%2C%22720575941465737814%22%2C%22720575941454124781%22%2C%22720575941428365193%22%2C%22720575941480105039%22%2C%22720575941563064071%22%2C%22720575941480673154%22%2C%22720575941501608939%22%2C%22720575941510509072%22%2C%22720575941518261932%22%2C%22720575941588123902%22%2C%22720575941433235744%22%2C%22720575941545120361%22%2C%22720575941652493524%22%2C%22720575941412623215%22%2C%22720575941554354259%22%2C%22720575941642868385%22%2C%22720575941399380515%22%2C%22720575941480942499%22%2C%22720575941446894612%22%2C%22720575941479434720%22%2C%22720575941626302858%22%2C%22720575941554228481%22%2C%22720575941439919295%22%2C%22720575941537718653%22%2C%22720575941569306874%22%2C%22720575941531334373%22%2C%22720575941513793612%22%2C%22720575941489036494%22%2C%22720575941589678078%22%2C%22720575941577482585%22%2C%22720575941456665581%22%2C%22720575941563201687%22%2C%22720575941551093639%22%2C%22720575941730244651%22%2C%22720575941580309081%22%2C%22720575941666925745%22%5D%2C%22segmentDefaultColor%22%3A%22%239457eb%22%2C%22name%22%3A%22ALT%20grooming%20-%20DNg12%20%28violet%2C%20off%29%22%2C%22archived%22%3Atrue%7D%5D%2C%22selectedLayer%22%3A%7B%22layer%22%3A%22Forward%20walking%20-%20DNg100%20%28green%29%22%2C%22visible%22%3Atrue%7D%7D

</details>

## Cells

| group | cell type | side | root id | color |
|---|---|---|---|---|
| forward_walking_DNg100 | DNg100 | left | `720575941626500746` | #00d26a |
| forward_walking_DNg100 | DNg100 | right | `720575941500851362` | #00d26a |
| turn_left_DNa02 | DNa02 | left | `720575941510475536` | #2979ff |
| turn_right_DNa02 | DNa02 | right | `720575941456897005` | #ff9500 |
| grooming_DNg11 | DNg11 | left | `720575941533807082` | #ff5ce1 |
| grooming_DNg11 | DNg11 | right | `720575941655117012` | #ff5ce1 |
| grooming_DNg11 | DNg11 | left | `720575941439740895` | #ff5ce1 |
| grooming_DNg11 | DNg11 | right | `720575941448922717` | #ff5ce1 |
| grooming_DNg11 | DNg11 | left | `720575941438719967` | #ff5ce1 |
| escape_DNp01_giant_fiber | DNp01 | left | `720575941509145950` | #ff3b30 |
| escape_DNp01_giant_fiber | DNp01 | right | `720575941451068597` | #ff3b30 |
| takeoff_DNp11 | DNp11 | left | `720575941551589181` | #ffd60a |
| takeoff_DNp11 | DNp11 | right | `720575941478215985` | #ffd60a |
| landing_DNp10 | DNp10 | right | `720575941593683051` | #00e0c6 |
| landing_DNp10 | DNp10 | left | `720575941440683743` | #00e0c6 |
| compass_EPG | EPG ×45 | both | see manifest.json | #bd9bd1 |
| alt_grooming_DNg12 | DNg12_a ×45 | both | see manifest.json | #9457eb |

Notes:

- **Courtship song has no cell here.** BANC is a female CNS; the song command
  pathway (P1 → pIP10 → VNC song circuits) is male. Options: use the male CNS
  dataset (MCNS in Codex) for that one behavior, or swap in escape (giant
  fiber), takeoff, or backward walking (MDN).
- **DNg11 caveat:** the BANC behavior tags label DNg11 as *flight power*
  (hemilineage LB6), while the cells BANC tags as *grooming* include the
  DNg12 population (the one banc-explorer's head-grooming scene already
  uses), DNg21, DNg62, and several DNge types. DNg11 is included here as
  requested (the grooming literature does implicate it), but double-check
  before museum use — the DNg12 layer is included as the alternative.
- The five cells previously noted as EPG in cell_info are labeled **PEG** in
  the current release; this view uses the 45 cells actually labeled EPG.
- DNg11 has 5 annotated members (3 left, 2 right); DNp11, DNp10, DNp01 and
  DNa02 are clean left/right pairs; DNg100 is one per side.

## Download the meshes (run on Aurelius)

```powershell
git pull
python behavior_cells\download_behavior_cells.py --out D:\Meshes\behavior_cells
# add --all for the 45 EPGs and 45 DNg12s (several GB)
```

Writes one binary PLY per cell, `<group>\<cell_type>_<side>_<root_id>.ply`,
coordinates in nanometers (use --scale 0.001 for µm). Blender imports PLY
natively. Expect ~50 MB per DN; the two-cell test (DNa02 left) verified the
files import cleanly.
