# Task 83 — AT / BEFORE queries

**Category:** Time Travel & cloning

## About this category — Time Travel & cloning
Tasks 83-87 cover querying and recovering past states without a backup
system of your own — Snowflake keeps this history natively.

## Goal
Querying a table as it existed at a past timestamp, offset, or query ID.

**Real-world scenario:** "What did this table look like right before
that bad UPDATE ran?" — and you know which query did it, but not the
exact second it happened. Time Travel answers that by timestamp, by a
relative offset, or by the query ID itself.

## Steps
1. Run `84_time_travel_at_before.sql`.
2. Work through it section by section against your own Snowflake trial
   — don't just read it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `84_time_travel_at_before.sql` — three questions on
what a historical query actually shows, how OFFSET's cutoff moves with
query time, and when BEFORE(STATEMENT) beats AT(TIMESTAMP).
