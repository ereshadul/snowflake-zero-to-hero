# Task 14 — CASE expressions and conditional aggregation

**Category:** Advanced SQL

## Goal
Turning row-level conditions into pivoted aggregate columns with CASE inside SUM/COUNT.

**Real-world scenario:** Your manager wants "one row per customer,
with columns for how many big orders vs. small orders they placed" —
a shape no plain GROUP BY can produce by itself, because GROUP BY
collapses to one row per group, not one column per condition. That's
exactly what `SUM(CASE WHEN ...)` and `COUNT(CASE WHEN ...)` are for.

## Steps
1. Run `15_case_conditional_aggregation.sql`.
2. Work through it section by section against your own Snowflake trial
   — don't just read it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `15_case_conditional_aggregation.sql` — three
questions on why COUNT()'s implicit ELSE NULL matters, why SUM needs
an explicit ELSE 0, and how this compares to Task 11's native PIVOT.
