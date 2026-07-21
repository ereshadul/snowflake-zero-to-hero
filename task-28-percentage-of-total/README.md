# Task 28 — Percentage of total / ratio-to-report

**Category:** SQL Interview Practice

## Goal
Expressing each row as a share of its group's total using window functions instead of a self-join.

**Real-world scenario:** "Show me each quarter's sales as a percentage
of that region's yearly total" — a report request that used to mean
joining a table to its own aggregated summary, and now doesn't need a
join at all.

## Steps
1. Run `29_percentage_of_total.sql`.
2. Work through it section by section against your own Snowflake trial
   — don't just read it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `29_percentage_of_total.sql` — three questions on
scan cost vs. the self-join, what RATIO_TO_REPORT buys you over manual
division, and grand-total vs. per-group percentages.
