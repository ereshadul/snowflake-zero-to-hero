# Task 79 — WHEN clause

**Category:** Tasks, deeper

## Goal
Conditionally skipping a task run based on a predicate, e.g. SYSTEM$STREAM_HAS_DATA.

**Real-world scenario:** A single downstream log needs updates from
TWO independent sources — a task that only fires when BOTH have
changed would miss updates for weeks; one that fires when EITHER has
changed (an OR condition) catches everything, at the cost of the task
body needing to figure out which source(s) actually triggered it.

## Steps
1. Requires Task 72 already done — reuses TEAM_ROSTER_STREAM and
   PLAYER_STATS_STREAM.
2. Run `80_task_when_clause.sql`. **Suspend the task at the end.**
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `80_task_when_clause.sql` — three questions on OR
vs. AND across multiple stream conditions, and why the procedure still
needs its own per-stream checks.
