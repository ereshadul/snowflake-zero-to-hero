# Task 82 — Incremental load strategy

**Category:** Tasks, deeper

## Goal
Deciding between full-reload and incremental load, and the
watermarking approaches (timestamp-based, CDC-based via Streams) that
make incremental loading actually correct instead of silently
dropping or duplicating rows. Sits right after Streams (Tasks 69-76)
and this category's own Task/DAG mechanics on purpose — this is the
design-level question those mechanics exist to answer.

**Real-world scenario:** A "sync only what changed since last time"
pipeline works fine for months, then silently drops a row — because a
backfilled or clock-skewed record arrived with a timestamp OLDER than
the watermark already saved, and the watermark approach has no way to
know it was ever supposed to catch it.

## Steps
1. Run `83_incremental_load_strategy.sql`.
2. Work through it section by section against your own Snowflake trial
   — don't just read it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `83_incremental_load_strategy.sql` — three questions
closing out the Tasks, deeper category, tracing exactly why watermarks
can miss a late-arriving row while CDC catches it, and when
watermarking is still the right call anyway.
