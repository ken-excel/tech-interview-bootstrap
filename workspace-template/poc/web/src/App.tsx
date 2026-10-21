import { useEffect, useMemo, useState } from "react";
import { rank, type Weights } from "./lib/score";
import { initialWeights, options, title } from "./options";

const PALETTE = ["#4f6bed", "#2a9d8f", "#e9a23b", "#d1495b", "#7a5cfa", "#5c946e"];

type ApiStatus = "checking" | "up" | "down";

async function fetchHealth(): Promise<ApiStatus> {
  try {
    const res = await fetch("/health");
    return res.ok ? "up" : "down";
  } catch {
    return "down";
  }
}

export default function App() {
  const [weights, setWeights] = useState<Weights>(initialWeights);
  const [api, setApi] = useState<ApiStatus>("checking");
  const criteria = Object.keys(weights);
  const ranked = useMemo(() => rank(options, weights), [weights]);

  useEffect(() => {
    void fetchHealth().then(setApi);
  }, []);

  return (
    <main>
      <header>
        <h1>{title}</h1>
        <span className={`pill ${api}`}>Rust API: {api}</span>
      </header>

      <section className="weights">
        <h2>Weights</h2>
        {criteria.map((c) => (
          <label key={c}>
            <span>{c}</span>
            <input
              type="range"
              min={0}
              max={5}
              value={weights[c]}
              onChange={(e) => setWeights({ ...weights, [c]: Number(e.target.value) })}
            />
            <output>{weights[c]}</output>
          </label>
        ))}
      </section>

      <section>
        <h2>Ranking</h2>
        {ranked.map((r, i) => (
          <div className="row" key={r.name}>
            <span className="name">
              {i + 1}. {r.name}
            </span>
            <div className="bar" title={`${r.score.toFixed(2)} / 5`}>
              {criteria.map((c, j) => (
                <div
                  key={c}
                  className="seg"
                  style={{ width: `${((r.breakdown[c] ?? 0) / 5) * 100}%`, background: PALETTE[j % PALETTE.length] }}
                  title={`${c}: ${(r.breakdown[c] ?? 0).toFixed(2)}`}
                />
              ))}
            </div>
            <span className="score">{r.score.toFixed(2)}</span>
          </div>
        ))}
        <div className="legend">
          {criteria.map((c, j) => (
            <span key={c}>
              <i style={{ background: PALETTE[j % PALETTE.length] }} /> {c}
            </span>
          ))}
        </div>
      </section>
    </main>
  );
}
