# Task 126 — Storage cost monitoring

**Category:** FinOps

## Goal
Querying `STORAGE_USAGE` and `TABLE_STORAGE_METRICS` to see how much
you're paying for active data vs. Time Travel vs. Fail-safe vs.
clones — and which of those is actually the expensive one.

## Steps
1. Run `127_storage_cost_monitoring.sql`.
2. Work through it section by section against your own Snowflake trial
   — don't just read it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `127_storage_cost_monitoring.sql` — three questions
on whether Fail-safe retention is tunable, whose storage a diverged
clone's rows count against, and whether compute or storage is more
likely to dominate this lab's own bill.
