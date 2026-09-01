#!/usr/bin/env python3
"""Download behavior-cell meshes from the public BANC bucket into a local folder.

Reads manifest.json (next to this script), fetches each cell's mesh from the
public precomputed layer, and writes one binary PLY per cell, named
    <group>/<cell_type>_<side>_<root_id>.ply

No dependencies beyond the standard library; uses numpy for the triangle
repack if it is importable (much faster), otherwise falls back to pure Python.

Usage (defaults to core groups only; EPG and DNg12 are large populations):
    python download_behavior_cells.py --out D:\\Meshes\\behavior_cells
    python download_behavior_cells.py --out D:\\Meshes\\behavior_cells --all
    python download_behavior_cells.py --groups compass_EPG --scale 0.001

Coordinates are in nanometers (native BANC voxel space at 1nm units).
Pass --scale 0.001 for micrometers if that matches the rest of D:\\Meshes.
"""
import argparse
import json
import struct
import sys
import urllib.request
from pathlib import Path

MESH_BASE = ("https://storage.googleapis.com/"
             "lee-lab_brain-and-nerve-cord-fly-connectome/neuron_meshes/meshes/")


def fetch(url):
    with urllib.request.urlopen(url) as r:
        return r.read()


def write_ply(path, raws, scale):
    # Each fragment is its own (num_verts, verts, indices) blob; merge them
    # by offsetting the later fragments' indices past the earlier vertices.
    vert_blocks, tri_blocks = [], []
    n_verts = n_tris = 0
    for raw in raws:
        nv = struct.unpack_from("<I", raw, 0)[0]
        vert_end = 4 + nv * 12
        vert_blocks.append(raw[4:vert_end])
        tri_blocks.append((n_verts, raw[vert_end:]))
        n_verts += nv
        n_tris += (len(raw) - vert_end) // 12

    header = (
        "ply\nformat binary_little_endian 1.0\n"
        f"element vertex {n_verts}\n"
        "property float x\nproperty float y\nproperty float z\n"
        f"element face {n_tris}\n"
        "property list uchar uint vertex_indices\n"
        "end_header\n"
    ).encode()

    try:
        import numpy as np
    except ImportError:
        np = None

    with open(path, "wb") as f:
        f.write(header)
        for verts in vert_blocks:
            if scale != 1.0:
                if np is not None:
                    verts = (np.frombuffer(verts, dtype="<f4") * scale
                             ).astype("<f4").tobytes()
                else:
                    nv3 = len(verts) // 4
                    v = struct.unpack(f"<{nv3}f", verts)
                    verts = struct.pack(f"<{nv3}f", *(x * scale for x in v))
            f.write(verts)
        for offset, tri_raw in tri_blocks:
            if np is not None:
                tris = np.frombuffer(tri_raw, dtype="<u4").reshape(-1, 3)
                if offset:
                    tris = tris + offset
                block = np.empty((len(tris), 13), dtype=np.uint8)
                block[:, 0] = 3
                block[:, 1:] = tris.astype("<u4").view(np.uint8).reshape(-1, 12)
                f.write(block.tobytes())
            else:
                three = struct.Struct("<BIII")
                for a, b, c in struct.iter_unpack("<III", tri_raw):
                    f.write(three.pack(3, a + offset, b + offset, c + offset))
    return n_verts, n_tris


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", default="D:\\Meshes\\behavior_cells")
    ap.add_argument("--all", action="store_true",
                    help="include the large EPG and DNg12 populations")
    ap.add_argument("--groups", nargs="*", default=None,
                    help="download only these group names")
    ap.add_argument("--scale", type=float, default=1.0,
                    help="multiply coordinates (1.0 = nm, 0.001 = um)")
    args = ap.parse_args()

    manifest = json.loads(
        (Path(__file__).parent / "manifest.json").read_text())
    out_root = Path(args.out)
    out_root.mkdir(parents=True, exist_ok=True)
    (out_root / "manifest.json").write_text(json.dumps(manifest, indent=2))

    failures = []
    for group in manifest["groups"]:
        name = group["group"]
        if args.groups is not None:
            if name not in args.groups:
                continue
        elif not group["core"] and not args.all:
            print(f"skipping {name} ({len(group['cells'])} cells; use --all)")
            continue
        gdir = out_root / name
        gdir.mkdir(exist_ok=True)
        for cell in group["cells"]:
            rid, side, ctype = cell["root_id"], cell["side"], cell["cell_type"]
            dest = gdir / f"{ctype}_{side}_{rid}.ply"
            if dest.exists():
                print(f"exists    {dest.name}")
                continue
            try:
                fragments = json.loads(fetch(f"{MESH_BASE}{rid}:0"))["fragments"]
                raws = [fetch(f"{MESH_BASE}{f}") for f in fragments]
                nv, nt = write_ply(dest, raws, args.scale)
                print(f"wrote     {dest.name}  ({nv:,} verts, {nt:,} tris)")
            except Exception as e:
                failures.append((rid, str(e)))
                print(f"FAILED    {ctype} {rid}: {e}", file=sys.stderr)

    if failures:
        print(f"\n{len(failures)} failures", file=sys.stderr)
        sys.exit(1)
    print("\nall requested meshes downloaded")


if __name__ == "__main__":
    main()
