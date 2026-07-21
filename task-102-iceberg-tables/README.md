# Task 102 — Iceberg Tables

**Category:** Newer table types

## Goal
Snowflake reading/writing the open Iceberg table format on external storage.

**Real-world scenario:** A company already runs Spark and Trino jobs
against a data lake in open Iceberg format, and wants Snowflake to
query the SAME files — not a duplicated copy that can drift out of
sync. Iceberg Tables let Snowflake read and write that open format
directly, on storage you control (or, more simply, storage Snowflake
manages for you).

**Note:** This task stays within the lab's scope of using AWS only in
Tasks 5-6 — the external-volume/S3 example is reference material to
read, not run. Step 2's Snowflake-managed variant is safe to actually
try.

## Steps
1. Run `103_iceberg_tables.sql`.
2. Work through it section by section against your own Snowflake trial
   — don't just read it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `103_iceberg_tables.sql` — three questions on where
Iceberg data actually lives, bring-your-own-storage vs.
Snowflake-managed, and avoiding data duplication across engines.
