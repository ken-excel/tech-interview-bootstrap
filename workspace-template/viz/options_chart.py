#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.12"
# dependencies = ["matplotlib>=3.9"]
# ///
"""Weighted option comparison → ranked Markdown table + stacked bar chart.

    uv run viz/options_chart.py viz/example-options.json -o viz/out/example.png

Input JSON: {"title": str, "criteria": {name: weight}, "options": {name: {criterion: 1-5}}}
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path

PALETTE = ["#4f6bed", "#2a9d8f", "#e9a23b", "#d1495b", "#7a5cfa", "#5c946e"]


def score(data: dict) -> list[tuple[str, float, dict[str, float]]]:
    weights = {c: max(0.0, float(w)) for c, w in data["criteria"].items()}
    total_w = sum(weights.values()) or 1.0
    rows = []
    for name, scores in data["options"].items():
        breakdown = {
            c: w * float(scores.get(c, 0)) / total_w for c, w in weights.items()
        }
        rows.append((name, sum(breakdown.values()), breakdown))
    return sorted(rows, key=lambda r: (-r[1], r[0]))


def markdown(data: dict, rows: list[tuple[str, float, dict[str, float]]]) -> str:
    crit = list(data["criteria"])
    head = "| # | Option | " + " | ".join(
        f"{c} (w={data['criteria'][c]})" for c in crit
    )
    lines = [head + " | Weighted |", "|" + "---|" * (len(crit) + 3)]
    for i, (name, total, _) in enumerate(rows, 1):
        raw = data["options"][name]
        cells = " | ".join(str(raw.get(c, "–")) for c in crit)
        lines.append(f"| {i} | {name} | {cells} | **{total:.2f}** |")
    return "\n".join(lines)


def chart(data: dict, rows, out: Path) -> None:
    import matplotlib

    matplotlib.use("Agg")
    import matplotlib.pyplot as plt

    crit = list(data["criteria"])
    names = [r[0] for r in rows][::-1]
    fig, ax = plt.subplots(figsize=(8, 0.6 * len(rows) + 1.6), dpi=150)
    breakdowns = {name: bd for name, _, bd in rows}
    left = [0.0] * len(names)
    for j, c in enumerate(crit):
        vals = [breakdowns[n][c] for n in names]
        ax.barh(
            names, vals, left=left, color=PALETTE[j % len(PALETTE)], label=c, height=0.6
        )
        left = [a + b for a, b in zip(left, vals, strict=True)]
    for y, total in enumerate(left):
        ax.text(total + 0.05, y, f"{total:.2f}", va="center", fontsize=9)
    ax.set_xlim(0, 5.5)
    ax.set_xlabel("weighted score (1–5)")
    ax.set_title(data.get("title", "Options"), loc="left", fontsize=11)
    ax.spines[["top", "right"]].set_visible(False)
    ax.legend(
        ncol=min(len(crit), 4),
        fontsize=8,
        frameon=False,
        loc="upper center",
        bbox_to_anchor=(0.5, -0.25),
    )
    fig.tight_layout()
    out.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(out, bbox_inches="tight")


def main() -> None:
    p = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawTextHelpFormatter
    )
    p.add_argument("input", type=Path)
    p.add_argument("-o", "--out", type=Path, help="PNG/SVG path (omit for table only)")
    args = p.parse_args()

    data = json.loads(args.input.read_text())
    rows = score(data)
    print(markdown(data, rows))
    if args.out:
        chart(data, rows, args.out)
        print(f"\nchart → {args.out}")


if __name__ == "__main__":
    main()
