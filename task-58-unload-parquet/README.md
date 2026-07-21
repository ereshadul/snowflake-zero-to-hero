# Task 58 — Unload to Parquet

**Category:** Unloading data

## Goal
Unloading query results as Parquet.

**Real-world scenario:** A data lake consumer needs the actual data
TYPES preserved (a number stays a number, not text that merely looks
numeric) — CSV/JSON can't do that, since both are plain text formats
under the hood. Parquet, being binary and columnar, can.

## Steps
1. Run `59_unload_parquet.sql`. Note: this task deliberately includes
   a broken query (using the wrong file format) as the first
   understanding-check question — fixing it is part of the exercise.
2. Work through it section by section against your own Snowflake trial
   — don't just read it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `59_unload_parquet.sql` — three questions covering
fixing the file-format bug, whether direct multi-column Parquet
unload works on your account, and type preservation vs. CSV.
