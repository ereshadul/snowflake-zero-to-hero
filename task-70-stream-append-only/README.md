# Task 70 — APPEND-ONLY stream

**Category:** Streams

## Goal
Tracking only inserts, cheaper than a STANDARD stream when deletes/updates don't matter.

**Real-world scenario:** An append-only event log (page views, sensor
readings) never gets updated or deleted once written — tracking
updates/deletes on it is pure overhead a STANDARD stream would pay for
nothing.

## Steps
1. Requires Task 69 already done — reuses STREAM_DEMO_SOURCE.
2. Run `71_stream_append_only.sql`.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `71_stream_append_only.sql` — three questions
comparing this stream's output to Task 69's STANDARD stream for
identical inserts, updates, and deletes.
