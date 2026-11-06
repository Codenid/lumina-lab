#!/usr/bin/env python3
"""Genera SVG editables del recorrido técnico a partir de definicion-figuras.json."""
from __future__ import annotations

import html
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent
DATA = json.loads((ROOT / "definicion-figuras.json").read_text(encoding="utf-8"))
OUT = ROOT.parent / "assets" / "figuras"
OUT.mkdir(parents=True, exist_ok=True)

WIDTH, HEIGHT, BOX_W, BOX_H = 850, 330, 150, 68

def box(node: list[object], palette: dict[str, str]) -> tuple[str, float, float]:
    label, kind, x, y = node
    color = palette[str(kind)]
    lines = str(label).split("\\n")
    text = "".join(
        f'<text x="{x + BOX_W / 2}" y="{y + 29 + i * 16}" text-anchor="middle">{html.escape(line)}</text>'
        for i, line in enumerate(lines)
    )
    return (f'<g><rect x="{x}" y="{y}" width="{BOX_W}" height="{BOX_H}" rx="10" fill="{color}"/>'
            f'<rect x="{x}" y="{y}" width="{BOX_W}" height="{BOX_H}" rx="10" fill="none" stroke="#1e293b"/>{text}</g>', float(x), float(y))

for figure in DATA["figures"]:
    nodes = figure["nodes"]
    rendered = [box(node, DATA["palette"]) for node in nodes]
    edges = []
    for src, dst, label in figure["edges"]:
        _, sx, sy = rendered[src]
        _, dx, dy = rendered[dst]
        x1, y1, x2, y2 = sx + BOX_W, sy + BOX_H / 2, dx, dy + BOX_H / 2
        mx, my = (x1 + x2) / 2, (y1 + y2) / 2 - 7
        edges.append(f'<path d="M{x1},{y1} L{x2},{y2}" marker-end="url(#arrow)"/>'
                     f'<text class="edge" x="{mx}" y="{my}" text-anchor="middle">{html.escape(label)}</text>')
    svg = f'''<svg xmlns="http://www.w3.org/2000/svg" width="{WIDTH}" height="{HEIGHT}" viewBox="0 0 {WIDTH} {HEIGHT}" role="img">
<defs><marker id="arrow" markerWidth="10" markerHeight="10" refX="8" refY="3" orient="auto"><path d="M0,0 L0,6 L9,3 z" fill="#475569"/></marker></defs>
<style>text{{font-family:Arial,sans-serif;font-size:14px;fill:#fff;font-weight:600}}.edge{{fill:#334155;font-size:12px;font-weight:400}}path{{stroke:#475569;stroke-width:2;fill:none}}.title{{fill:#0f172a;font-size:21px;font-weight:700}}</style>
<rect width="100%" height="100%" fill="#f8fafc"/><text class="title" x="25" y="35">{html.escape(figure["title"])}</text>
{''.join(edges)}{''.join(item[0] for item in rendered)}</svg>'''
    (OUT / figure["file"]).write_text(svg, encoding="utf-8")
    print(OUT / figure["file"])
