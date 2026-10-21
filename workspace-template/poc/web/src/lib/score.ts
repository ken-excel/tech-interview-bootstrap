/** Weighted scoring for comparing technical options. Pure functions: easy to test. */

export type Weights = Record<string, number>;

export interface Option {
  name: string;
  /** criterion → score (1–5). Missing criteria count as 0. */
  scores: Record<string, number>;
}

export interface Ranked {
  name: string;
  /** Weighted average, on the same scale as the input scores. */
  score: number;
  /** criterion → weighted contribution; contributions sum to `score`. */
  breakdown: Record<string, number>;
}

export function weightedScore(
  scores: Record<string, number>,
  weights: Weights,
): { total: number; breakdown: Record<string, number> } {
  const totalWeight = Object.values(weights).reduce((sum, w) => sum + Math.max(0, w), 0);
  const breakdown: Record<string, number> = {};
  let total = 0;
  for (const [criterion, w] of Object.entries(weights)) {
    const contribution =
      totalWeight === 0 ? 0 : (Math.max(0, w) * (scores[criterion] ?? 0)) / totalWeight;
    breakdown[criterion] = contribution;
    total += contribution;
  }
  return { total, breakdown };
}

export function rank(options: Option[], weights: Weights): Ranked[] {
  return options
    .map((o) => {
      const { total, breakdown } = weightedScore(o.scores, weights);
      return { name: o.name, score: total, breakdown };
    })
    .sort((a, b) => b.score - a.score || a.name.localeCompare(b.name));
}
