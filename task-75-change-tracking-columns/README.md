# Task 75 — Change-tracking columns (METADATA$...)

**Category:** Streams

## Goal
Reading METADATA$ACTION/ISUPDATE/ROW_ID to interpret stream output correctly.

**Real-world scenario:** An audit log needs "old value → new value" in
ONE row per change — but a stream represents every update as two
separate rows (a DELETE and an INSERT). METADATA$ROW_ID is what lets
you pair those two rows back together correctly.

## Steps
1. Run `76_change_tracking_columns.sql`.
2. Work through it section by section against your own Snowflake trial
   — don't just read it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `76_change_tracking_columns.sql` — three questions
closing out the Streams category, on what ROW_ID enables that ACTION/
ISUPDATE alone can't, and when matching by a data column would fail.
