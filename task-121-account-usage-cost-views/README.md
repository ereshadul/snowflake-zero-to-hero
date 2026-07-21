# Task 121 — ACCOUNT_USAGE cost views

**Category:** FinOps

## Goal
Querying `WAREHOUSE_METERING_HISTORY`, `METERING_DAILY_HISTORY`, and
`QUERY_HISTORY` in `SNOWFLAKE.ACCOUNT_USAGE` to see exactly where
credits actually went, not just what a warehouse is configured to
cost. This is the difference between guessing at cost and measuring
it.

## Steps
1. Run `122_account_usage_cost_views.sql`.
2. Work through it section by section against your own Snowflake trial
   — don't just read it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `122_account_usage_cost_views.sql` — three questions
on what non-warehouse spend shows up in METERING_DAILY_HISTORY,
ACCOUNT_USAGE's reporting lag, and why elapsed time alone doesn't tell
you credit cost.
