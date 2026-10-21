---
name: compare-options
description: Compare technical options (libraries, databases, architectures, algorithms) with weighted criteria and produce a scored table plus a chart. Use when asked "which should we use", "compare X vs Y", "pros and cons", or when a decision has more than one credible option.
---

# Compare options

## Steps

1. Agree on **3–6 criteria** that matter for *this* problem (e.g. latency,
   operational cost, team familiarity, time to PoC, scalability) and a weight
   for each (weights need not sum to 1; they are normalised).
2. Score each option **1–5** per criterion. Write a one-line justification
   per score — the justifications are what make this defensible.
3. Write the data as JSON in `viz/` (shape below) and render:

   ```bash
   uv run viz/options_chart.py viz/<name>.json -o viz/out/<name>.png
   ```

   The script prints a ranked Markdown table and writes a horizontal bar
   chart of weighted scores (with a per-criterion breakdown).
4. Paste the table into the ADR (`adr` skill) and link the chart.
5. Sanity-check: if the winner feels wrong, the weights are wrong — say so
   and adjust openly rather than fudging scores.

## JSON shape

```json
{
  "title": "Message broker for order events",
  "criteria": {"throughput": 3, "ops cost": 2, "team familiarity": 2, "ordering": 3},
  "options": {
    "Kafka":    {"throughput": 5, "ops cost": 2, "team familiarity": 3, "ordering": 5},
    "RabbitMQ": {"throughput": 3, "ops cost": 4, "team familiarity": 4, "ordering": 3},
    "SQS FIFO": {"throughput": 2, "ops cost": 5, "team familiarity": 4, "ordering": 4}
  }
}
```

For a quick interactive version during a screen share, the web starter
(`poc/web`) already renders a live weighted-scoring table with sliders.
