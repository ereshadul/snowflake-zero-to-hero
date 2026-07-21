# Task 110 — dbt snapshots (SCD Type 2)

**Category:** dbt

## Goal
Capturing how a mutable source table's rows change over time using dbt's built-in Type 2 slowly-changing-dimension pattern.

**Real-world scenario:** `CURATED.SENSOR_CURRENT_STATE` only ever holds
one row per sensor — every update overwrites the previous value for
good. An auditor later asks "what was this sensor reading last
Tuesday before the correction?" and without a snapshot, that history
is already gone.

## Steps
1. Work through `111_dbt_snapshots.sql` — snapshot the current state,
   update a row, snapshot again, and see the Type 2 history it built.
2. Do it for real against your own Snowflake trial — don't just read
   it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `111_dbt_snapshots.sql` — three questions on where
the old value survives, the timestamp vs. check strategy tradeoff, and
how this differs from Time Travel's retention window.
