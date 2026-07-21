# Task 74 — Consuming/emptying a stream

**Category:** Streams

## Goal
What actually advances a stream's offset, and how to avoid accidentally consuming it.

**Real-world scenario:** Someone on the team writes a "quick" query to
save a stream's contents into a scratch table just to eyeball them —
and accidentally empties the stream before the real downstream task
ever gets to process that data. This task is built entirely around
that gotcha.

## Steps
1. Requires Task 69 already done — reuses STREAM_DEMO_SOURCE and
   STREAM_DEMO_STREAM.
2. Run `75_stream_consuming_emptying.sql`.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `75_stream_consuming_emptying.sql` — three questions
building to the general rule for what actually consumes a stream.
