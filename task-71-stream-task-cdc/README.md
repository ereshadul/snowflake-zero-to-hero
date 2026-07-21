# Task 71 — Stream + Task CDC pattern

**Category:** Streams

## Goal
Wiring a stream and a task together into a self-driving CDC pipeline.

**Real-world scenario:** "Keep an audit history of every change to
this table, automatically, without anyone running a script by hand" —
the canonical pattern for this is exactly a Stream feeding a
WHEN-gated Task, cheap to leave running because the task only does
real work when there's actually something new.

## Steps
1. Requires Tasks 69-70 already done — reuses STREAM_DEMO_SOURCE and
   STREAM_DEMO_STREAM.
2. Run `72_stream_task_cdc.sql`. **Suspend the task at the end** — same
   habit as Task 3.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `72_stream_task_cdc.sql` — three questions
connecting back to Task 51's WHEN behavior, what actually consumes a
stream, and supporting multiple independent consumers.
