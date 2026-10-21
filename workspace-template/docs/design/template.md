# <Design title>

## 1. Problem & goals
<One paragraph. What are we solving and for whom?>

**Goals:** …  
**Non-goals:** …

## 2. Requirements
- Functional: …
- Non-functional: scale (users, QPS, data size), latency (p95), availability,
  consistency, security, cost.

## 3. Back-of-envelope
<QPS = …; storage/day = …; bandwidth = …. Show the arithmetic.>

## 4. High-level design
![architecture](../../diagrams/out/architecture.svg)

<Components and responsibilities, one line each.>

## 5. Key flows
![request flow](../../diagrams/out/request-flow.svg)

## 6. Data model
<Entities, keys, access patterns; why this store.>

## 7. Decisions
- ADR-NNNN: …

## 8. Risks & open questions
- …

## 9. Rollout / what's next
- …
