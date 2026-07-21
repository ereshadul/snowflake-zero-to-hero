# Task 69 — STANDARD stream

**Category:** Streams

## About this category — Streams
Tasks 69-76 cover Change Data Capture (CDC) — tracking what changed on
a table since you last looked, instead of diffing full snapshots by
hand the way Task 63 did.

## Goal
Tracking inserts/updates/deletes on a table with a STANDARD stream.

**Real-world scenario:** "Send only the ROWS THAT CHANGED to our
downstream system, not the whole table every time" — a stream tracks
exactly that, automatically, without you having to compare snapshots
or add your own "last modified" bookkeeping to the source table.

## Steps
1. Run `70_stream_standard.sql`.
2. Work through it section by section against your own Snowflake trial
   — don't just read it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `70_stream_standard.sql` — three questions on how an
UPDATE is represented, whether SELECT consumes a stream, and what
SYSTEM$STREAM_HAS_DATA is for.
