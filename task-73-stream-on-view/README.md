# Task 73 — Stream on a view

**Category:** Streams

## Goal
Change tracking on a view instead of a base table.

**Real-world scenario:** Downstream only cares about "currently active"
rows, defined by a filtered view — and needs to know when a row starts
or stops being active, which can happen from an UPDATE that never
touches the row count of the base table at all.

## Steps
1. Run `74_stream_on_view.sql`.
2. Work through it section by section against your own Snowflake trial
   — don't just read it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `74_stream_on_view.sql` — three questions on how a
row entering/leaving a filtered view shows up as INSERT/DELETE, and
why views need explicit CHANGE_TRACKING setup that base tables don't.
