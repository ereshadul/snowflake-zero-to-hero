# Task 87 — Retention & storage cost

**Category:** Time Travel & cloning

## Goal
How DATA_RETENTION_TIME_IN_DAYS drives storage cost for Time Travel and Fail-safe.

**Real-world scenario:** "Why is this table's storage bill so much
higher than its actual data size?" — the answer is often Time Travel
and Fail-safe storage silently accumulating on tables that never
needed either.

## Steps
1. Requires Task 35 already done — reuses PERMANENT_DEMO and
   TRANSIENT_DEMO.
2. Run `88_time_travel_retention_cost.sql`.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `88_time_travel_retention_cost.sql` — three
questions closing out the Time Travel & cloning category, on
TRANSIENT's zero Fail-safe, whether lowering retention erases existing
history, and where 0-day retention actually makes sense.
