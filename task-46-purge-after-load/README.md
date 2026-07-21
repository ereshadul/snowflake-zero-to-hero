# Task 46 — PURGE

**Category:** Loading & COPY options

## Goal
Auto-deleting staged files after a successful load, and the recovery risk that comes with it.

**Real-world scenario:** A stage that never gets cleaned up
accumulates years of already-loaded files, quietly costing storage
forever. PURGE keeps a stage tidy automatically — at the cost of no
longer having that exact file around if you ever need to reprocess it.

**Setup:** requires Task 38's `fixture_clean.csv` on `@RAW.IOT_STAGE`.
**Note:** this task deletes that file from the stage as part of the
exercise — later tasks in this category use different files.

## Steps
1. Run `47_purge_after_load.sql`.
2. Work through it section by section against your own Snowflake trial
   — don't just read it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `47_purge_after_load.sql` — three questions on
recovering from a purge, whether failed loads get purged too, and a
real safeguard to pair with PURGE in production.
