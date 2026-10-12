import base64
import itertools
import json
import math
import zipfile
from collections import defaultdict
from pathlib import Path
import numpy as np

ROOT = Path(__file__).parent
ARCHIVE = ROOT / "isa_BP3D_4.0_obj_99.zip"
OUTPUT_JS = ROOT / "bodyparts3d.js"
OUTPUT_VOL = ROOT / "bodyparts3d_volume.js"

# (パーツ表示名, [FJ番号リスト], 色, 不透明度, クラスタリングcell, ラベルID)
HEART_PARTS = [
    # --- 心室・中隔・心筋 ---
    ("心室心筋/中隔",       ["FJ2428"],           "#c8525b", 0.65, 1.5, 1),
    ("右房壁",             ["FJ2439"],           "#a85565", 0.50, 1.5, 2),
    ("左房壁",             ["FJ2438"],           "#b85c72", 0.50, 1.5, 3),

    # --- 大血管系 ---
    ("上行大動脈 (Ao)",     ["FJ3413"],           "#df565e", 0.55, 1.5, 4),
    ("主肺動脈 (MPA)",     ["FJ2966"],           "#5b92d6", 0.55, 1.5, 5),
    ("上大静脈 (SVC)",     ["FJ3645"],           "#4a7cb9", 0.50, 1.5, 6),
    ("下大静脈 (IVC)",     ["FJ3441", "FJ3659"], "#4a7cb9", 0.50, 1.5, 7),

    # --- 三尖弁 (Tricuspid Valve) ---
    ("TV 前尖 (Anterior)",  ["FJ2421"],           "#ffffcc", 0.95, 0.5, 10),
    ("TV 後尖 (Posterior)", ["FJ2433"],           "#ffffcc", 0.95, 0.5, 11),
    ("TV 中隔尖 (Septal)",  ["FJ2436"],           "#ffffcc", 0.95, 0.5, 12),

    # --- 僧帽弁 (Mitral Valve) ---
    ("MV 前尖 (AML)",       ["FJ2420"],           "#ffffaa", 0.95, 0.5, 13),
    ("MV 後尖 (PML)",       ["FJ2432"],           "#ffffaa", 0.95, 0.5, 14),

    # --- 大動脈弁 (Aortic Valve) ---
    ("AV 右冠尖 (RCC)",     ["FJ2435"],           "#ffffff", 0.95, 0.5, 15),
    ("AV 左冠尖 (LCC)",     ["FJ2431"],           "#ffffff", 0.95, 0.5, 16),
    ("AV 無冠尖 (NCC)",     ["FJ2426"],           "#ffffff", 0.95, 0.5, 17),

    # --- 肺動脈弁 (Pulmonary Valve) ---
    ("PV 前尖 (Anterior)",  ["FJ2417"],           "#ffffff", 0.95, 0.5, 18),
    ("PV 右尖 (Right)",     ["FJ2427"],           "#ffffff", 0.95, 0.5, 19),
    ("PV 左尖 (Left)",      ["FJ2434"],           "#ffffff", 0.95, 0.5, 20),
]

ORIGIN = (-90.0, -180.0, 1050.0)
STEP = 1.0
SHAPE = (181, 161, 261)
def parse_obj(data):
    vertices, faces = [], []
    for line in data.decode("ascii", errors="ignore").splitlines():
        if line.startswith("v "):
            vertices.append(tuple(map(float, line.split()[1:4])))
        elif line.startswith("f "):
            indices = [int(p.split("/")[0]) - 1 for p in line.split()[1:]]
            for i in range(1, len(indices) - 1):
                faces.append((indices[0], indices[i], indices[i + 1]))
    return vertices, faces

def merge_mesh(v_list, f_list):
    all_v, all_f = [], []
    offset = 0
    for v, f in zip(v_list, f_list):
        all_v.extend(v)
        all_f.extend([(a + offset, b + offset, c + offset) for a, b, c in f])
        offset += len(v)
    return all_v, all_f

def cluster(vertices, faces, cell):
    keys = [tuple(math.floor(v / cell) for v in p) for p in vertices]
    sums = {}
    for key, point in zip(keys, vertices):
        cur = sums.setdefault(key, [0.0, 0.0, 0.0, 0])
        for a in range(3): cur[a] += point[a]
        cur[3] += 1
    index = {k: i for i, k in enumerate(sums)}
    points = [tuple(round(s[a] / s[3], 1) for a in range(3)) for s in sums.values()]
    triangles = []
    seen = set()
    for face in faces:
        tri = tuple(index[keys[i]] for i in face)
        if len(set(tri)) < 3 or tuple(sorted(tri)) in seen: continue
        seen.add(tuple(sorted(tri)))
        triangles.extend(tri)
    return points, triangles

def voxelize(vertices, faces):
    nx, ny, nz = SHAPE
    hits = defaultdict(list)
    xyz = np.asarray(vertices, dtype=np.float64)
    for ia, ib, ic in faces:
        tri = xyz[[ia, ib, ic]]
        ya, yb, yc = tri[:, 1]; za, zb, zc = tri[:, 2]
        denom = (yb-ya)*(zc-za) - (yc-ya)*(zb-za)
        if abs(denom) < 1e-8: continue
        iy0 = max(0, math.ceil((min(ya, yb, yc)-ORIGIN[1])/STEP))
        iy1 = min(ny-1, math.floor((max(ya, yb, yc)-ORIGIN[1])/STEP))
        iz0 = max(0, math.ceil((min(za, zb, zc)-ORIGIN[2])/STEP))
        iz1 = min(nz-1, math.floor((max(za, zb, zc)-ORIGIN[2])/STEP))
        if iy0 > iy1 or iz0 > iz1: continue
        yy, zz = np.meshgrid(np.arange(iy0, iy1+1), np.arange(iz0, iz1+1))
        yyv = ORIGIN[1] + yy * STEP; zzv = ORIGIN[2] + zz * STEP
        u = ((yyv-ya)*(zc-za) - (yc-ya)*(zzv-za)) / denom
        v = ((yb-ya)*(zzv-za) - (yyv-ya)*(zb-za)) / denom
        inside = (u >= -1e-8) & (v >= -1e-8) & (u+v <= 1+1e-8)
        if not inside.any(): continue
        xx = tri[0, 0] + u*(tri[1, 0]-tri[0, 0]) + v*(tri[2, 0]-tri[0, 0])
        for key, x in zip((zz[inside]*ny + yy[inside]).flat, xx[inside].flat):
            hits[int(key)].append(float(x))
    mask = np.zeros((nz, ny, nx), dtype=np.bool_)
    for key, intersections in hits.items():
        intersections.sort()
        unique = []
        for x in intersections:
            if not unique or x-unique[-1] > 0.12: unique.append(x)
        for left, right in itertools.zip_longest(unique[::2], unique[1::2]):
            if right is None: break
            first = max(0, math.ceil((left-ORIGIN[0])/STEP))
            last = min(nx-1, math.floor((right-ORIGIN[0])/STEP))
            if first <= last: mask[key//ny, key%ny, first:last+1] = True
    return mask

def encode_rle(labels):
    flat = labels.ravel()
    change = np.flatnonzero(flat[1:] != flat[:-1]) + 1
    starts = np.r_[0, change]; ends = np.r_[change, len(flat)]
    output = bytearray()
    for s, e in zip(starts, ends):
        rem = int(e - s); val = int(flat[s])
        while rem:
            c = min(rem, 65535)
            output.extend((c & 255, c >> 8, val))
            rem -= c
    return base64.b64encode(output).decode("ascii"), len(output)

def main():
    print("心臓モデルとボクセルデータの抽出を開始...")
    nx, ny, nz = SHAPE
    labels = np.zeros((nz, ny, nx), dtype=np.uint8)
    parts_js = []
    
    with zipfile.ZipFile(ARCHIVE) as archive:
        for name, fj_list, color, alpha, cell, val in HEART_PARTS:
            v_list, f_list = [], []
            for fj in fj_list:
                path = f"isa_BP3D_4.0_obj_99/{fj}.obj"
                try:
                    v, f = parse_obj(archive.read(path))
                    v_list.append(v)
                    f_list.append(f)
                except KeyError:
                    print(f"  警告: {path} が見つかりません")
            
            if not v_list:
                print(f"スキップ: {name}")
                continue
            
            mv, mf = merge_mesh(v_list, f_list)
            pts, tri = cluster(mv, mf, cell)
            pts = [[round(x - ORIGIN[0] - nx/2, 1), round(y - ORIGIN[1] - ny/2, 1), round(z - ORIGIN[2] - nz/2, 1)] for x, y, z in pts]
            parts_js.append(dict(name=name, fileId=",".join(fj_list), color=color, alpha=alpha,
                                 vertices=[c for p in pts for c in p], faces=tri))
            mask = voxelize(mv, mf)
            labels[mask] = val
            print(f"抽出完了: {name:<18} ({len(fj_list)}パーツ) - ボクセル数: {int(mask.sum()):,}")

    OUTPUT_JS.write_text("globalThis.BP3D=" + json.dumps({"version":"heart_1.1","parts":parts_js}, ensure_ascii=False) + ";\n", encoding="utf-8")
    rle, blen = encode_rle(labels)
    OUTPUT_VOL.write_text("globalThis.BP3D_VOLUME=" + json.dumps({"origin":ORIGIN,"step":STEP,"shape":SHAPE,"rle":rle}, ensure_ascii=False) + ";\n", encoding="utf-8")
    print(f"\n生成成功!\n- {OUTPUT_JS.name}\n- {OUTPUT_VOL.name} (RLE: {blen:,} bytes)")

if __name__ == "__main__":
    main()