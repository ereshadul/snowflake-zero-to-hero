# Task 109 — dbt incremental models

**Category:** dbt

## Goal
Materializing a model so it only processes new/changed rows on subsequent runs instead of rebuilding the whole table every time.

**Real-world scenario:** A nightly model rebuild takes 40 minutes
because it reprocesses years of history every single run, when only
today's rows actually changed. Incremental materialization turns that
into a MERGE of just the new rows — most runs finish in seconds.

## Steps
1. Work through `110_dbt_incremental_models.sql` — convert the mart
   model to incremental, run a full refresh, then a normal incremental
   run.
2. Do it for real against your own Snowflake trial — don't just read
   it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `110_dbt_incremental_models.sql` — three questions on
when `--full-refresh` is actually needed, what `is_incremental()`
checks, and comparing this to Task 81's Stream+Task watermark pattern.
