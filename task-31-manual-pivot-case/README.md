# Task 31 — Manual pivot with CASE (crosstab without PIVOT)

**Category:** SQL Interview Practice

## Goal
Building a pivot table by hand for interviews that don't allow the PIVOT keyword.

**Real-world scenario:** "Show me a leaderboard: one row per team,
with columns for the 1st, 2nd, 3rd, and 4th place scores" — and unlike
Task 11's quarter columns, "finishing place" isn't a value that
already exists in the data. It has to be computed before it can be
pivoted on at all, which is exactly the kind of thing native PIVOT
can't do in a single step.

## Steps
1. Run `32_manual_pivot_case.sql`.
2. Work through it section by section against your own Snowflake trial
   — don't just read it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `32_manual_pivot_case.sql` — three questions on why
PIVOT can't key on a computed rank directly, tie-breaking, and what a
missing rank position actually returns.
