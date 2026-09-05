#!/usr/bin/env python
"""Condense the per-case reports in compare/results into one table per statistic.

    python ext/summary.py [results_dir] > ext/RESULTS.md

For each case directory with a report.md, the rows `triangles`, `reconstruction time (s)`,
`components`, `boundary edges` and `ball_not_empty` are collected for every tool column
and printed as Markdown tables with the cases as rows.
"""
import os, re, sys

ROWS = ["triangles", "reconstruction time (s)", "components", "boundary edges", "ball_not_empty"]
ORDER = ["sphere2000", "plane40", "torus_r0.10", "torus_r0.05", "torus_jitter", "torus_sampled20k",
         "knot_r0.0188", "knot_r0.03", "plane_uneven", "sphere_uneven", "torus_uneven",
         "bun000", "bunny4_r0.0008", "bunny4_r0.0015",
         "bunny10_r0.00125", "dragon62_r0.0007"]


def parse(path):
    tools, values = None, {}
    with open(path) as f:
        for line in f:
            if not line.startswith("|"):
                continue
            cells = [c.strip() for c in line.strip().strip("|").split("|")]
            if tools is None and cells[0] == "" and len(cells) > 1:
                tools = cells[1:]
            elif tools is not None and cells[0] in ROWS:
                values[cells[0]] = cells[1:]
    return tools, values


def main(results):
    cases = [c for c in ORDER if os.path.isfile(os.path.join(results, c, "report.md"))]
    cases += sorted(c for c in os.listdir(results)
                    if c not in ORDER and os.path.isfile(os.path.join(results, c, "report.md")))
    parsed = {c: parse(os.path.join(results, c, "report.md")) for c in cases}
    tools = max((t for t, _ in parsed.values() if t), key=len)
    for row in ROWS:
        print(f"### {row}\n")
        print("| case | " + " | ".join(tools) + " |")
        print("|---|" + "---|" * len(tools))
        for c in cases:
            t, v = parsed[c]
            if not t or row not in v:
                continue
            by = dict(zip(t, v[row]))
            print(f"| {c} | " + " | ".join(by.get(tool, "n/a") for tool in tools) + " |")
        print()


if __name__ == "__main__":
    main(sys.argv[1] if len(sys.argv) > 1 else os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "results"))
