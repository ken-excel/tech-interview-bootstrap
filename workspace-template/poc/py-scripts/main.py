"""Scripting starter.

Examples:
    uv run main.py                         # summarise the sample data
    uv run main.py --api http://127.0.0.1:3000   # also hit the Rust API health check
"""

from __future__ import annotations

import argparse
import json
import math
from pathlib import Path

import httpx
from pydantic import BaseModel, Field
from rich.console import Console
from rich.table import Table

console = Console()


class Record(BaseModel):
    service: str
    latency_ms: float = Field(ge=0)
    ok: bool


def load_records(path: Path) -> list[Record]:
    return [Record.model_validate(r) for r in json.loads(path.read_text())]


def summarise(records: list[Record]) -> dict[str, dict[str, float]]:
    """Per-service request count, error rate and p50/p95 latency."""
    by_service: dict[str, list[Record]] = {}
    for r in records:
        by_service.setdefault(r.service, []).append(r)

    out: dict[str, dict[str, float]] = {}
    for service, rs in sorted(by_service.items()):
        lat = sorted(r.latency_ms for r in rs)
        out[service] = {
            "count": len(rs),
            "error_rate": sum(not r.ok for r in rs) / len(rs),
            "p50_ms": percentile(lat, 50),
            "p95_ms": percentile(lat, 95),
        }
    return out


def percentile(sorted_values: list[float], p: float) -> float:
    """Nearest-rank percentile on pre-sorted values."""
    if not sorted_values:
        raise ValueError("percentile of empty list")
    rank = math.ceil(p / 100 * len(sorted_values))
    return sorted_values[max(0, min(len(sorted_values), rank) - 1)]


def check_api(base_url: str) -> str:
    try:
        res = httpx.get(f"{base_url}/health", timeout=2)
        res.raise_for_status()
        return f"[green]{res.json()}[/green]"
    except httpx.HTTPError as exc:
        return f"[red]unreachable: {exc}[/red]"


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--data", type=Path, default=Path(__file__).parent / "sample.json")
    parser.add_argument("--api", help="base URL of the Rust API to health-check")
    args = parser.parse_args()

    table = Table(title="Latency summary")
    for col in ("service", "count", "error rate", "p50 ms", "p95 ms"):
        table.add_column(col, justify="right" if col != "service" else "left")
    for service, s in summarise(load_records(args.data)).items():
        table.add_row(
            service,
            f"{s['count']:.0f}",
            f"{s['error_rate']:.0%}",
            f"{s['p50_ms']:.0f}",
            f"{s['p95_ms']:.0f}",
        )
    console.print(table)

    if args.api:
        console.print(f"API health: {check_api(args.api)}")


if __name__ == "__main__":
    main()
