# Task 72 — Stream on multiple tables

**Category:** Streams

## Goal
Coordinating streams across more than one source table.

**Real-world scenario:** A player's roster assignment and their stats
live in two related tables. A downstream system needs BOTH sets of
changes to advance together, atomically — if consuming one stream
succeeds while the other silently fails, the two systems drift out of
sync with each other.

## Steps
1. Run `73_stream_multiple_tables.sql`.
2. Work through it section by section against your own Snowflake trial
   — don't just read it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `73_stream_multiple_tables.sql` — three questions on
transaction-level (not statement-level) stream advancement, and why
that atomicity matters for keeping two related streams in sync.
