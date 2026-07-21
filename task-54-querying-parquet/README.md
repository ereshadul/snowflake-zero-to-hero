# Task 54 — Querying Parquet directly

**Category:** Semi-structured data

## Goal
Querying a staged Parquet file without loading it into a table first.

**Real-world scenario:** Someone hands you a Parquet file from a data
lake and asks "what's actually in this?" — loading it into a table
just to peek at a few rows is overkill when you can query it directly
off the stage.

## Steps
1. Run `55_querying_parquet.sql`.
2. Work through it section by section against your own Snowflake trial
   — don't just read it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `55_querying_parquet.sql` — three questions on when
querying-in-place beats loading, why Parquet columns come back through
a single $1, and the forward-dependency on Task 58's unload options.
