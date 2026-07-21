# Task 124 — Tuning AUTO_SUSPEND vs. cold-start cost

**Category:** FinOps

## Goal
The tradeoff between a short `AUTO_SUSPEND` (saves idle credits, but
pays repeated resume latency) and a long one (stays warm, but burns
credits doing nothing) — tuned against a real workload's query
spacing. Directly follows from what Task 3's understanding check
raised about a 1-minute task schedule against a 60-second
`AUTO_SUSPEND`.

## Steps
1. Run `115_auto_suspend_resume_tuning.sql`.
2. Work through it section by section against your own Snowflake trial
   — don't just read it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `115_auto_suspend_resume_tuning.sql`. Answer by
actually running the diagnostic queries it points to, not from
memory.

*(Status: scaffolded — SQL content not yet written.)*
