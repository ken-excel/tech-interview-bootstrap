from pathlib import Path

import pytest

from main import Record, load_records, percentile, summarise


def test_percentile_nearest_rank():
    values = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0]
    assert percentile(values, 50) == 5.0
    assert percentile(values, 95) == 10.0


def test_percentile_empty_raises():
    with pytest.raises(ValueError):
        percentile([], 50)


def test_summarise_error_rate():
    records = [
        Record(service="a", latency_ms=10, ok=True),
        Record(service="a", latency_ms=20, ok=False),
    ]
    assert summarise(records)["a"]["error_rate"] == 0.5


def test_sample_data_loads():
    records = load_records(Path(__file__).parent.parent / "sample.json")
    assert {r.service for r in records} == {"api", "web", "worker"}
