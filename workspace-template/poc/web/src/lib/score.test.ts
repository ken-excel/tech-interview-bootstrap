import { describe, expect, it } from "vitest";
import { rank, weightedScore } from "./score";

describe("weightedScore", () => {
  it("is a weighted average on the input scale", () => {
    const { total } = weightedScore({ a: 5, b: 1 }, { a: 3, b: 1 });
    expect(total).toBeCloseTo(4); // (5*3 + 1*1) / 4
  });

  it("treats missing scores as 0 and zero weights as no-op", () => {
    expect(weightedScore({}, { a: 1 }).total).toBe(0);
    expect(weightedScore({ a: 5 }, { a: 0 }).total).toBe(0);
  });

  it("breakdown sums to total", () => {
    const { total, breakdown } = weightedScore({ a: 4, b: 2 }, { a: 1, b: 1 });
    expect(Object.values(breakdown).reduce((s, v) => s + v, 0)).toBeCloseTo(total);
  });
});

describe("rank", () => {
  it("orders by score, then name", () => {
    const ranked = rank(
      [
        { name: "B", scores: { x: 3 } },
        { name: "A", scores: { x: 3 } },
        { name: "C", scores: { x: 5 } },
      ],
      { x: 1 },
    );
    expect(ranked.map((r) => r.name)).toEqual(["C", "A", "B"]);
  });
});
