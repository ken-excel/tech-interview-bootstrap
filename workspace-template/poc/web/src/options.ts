import type { Option, Weights } from "./lib/score";

// Edit freely during the interview: criteria weights and 1–5 scores.
export const title = "Message broker for order events";

export const initialWeights: Weights = {
  throughput: 3,
  "ops cost": 2,
  "team familiarity": 2,
  ordering: 3,
};

export const options: Option[] = [
  { name: "Kafka", scores: { throughput: 5, "ops cost": 2, "team familiarity": 3, ordering: 5 } },
  { name: "RabbitMQ", scores: { throughput: 3, "ops cost": 4, "team familiarity": 4, ordering: 3 } },
  { name: "SQS FIFO", scores: { throughput: 2, "ops cost": 5, "team familiarity": 4, ordering: 4 } },
];
