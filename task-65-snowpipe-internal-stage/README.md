# Task 65 — Pipe on internal stage

**Category:** Snowpipe

## About this category — Snowpipe
Tasks 65-68 cover continuous/event-driven ingestion. True event-driven
auto-ingest (Task 66) needs an external stage, which is why this first
task deliberately starts with an internal stage instead — to isolate
what a PIPE object actually is, before cloud event notifications enter
the picture.

## Goal
Standing up a Snowpipe that ingests from an internal stage.

**Real-world scenario:** You want a named, reusable ingestion object
instead of re-typing the same COPY INTO every time a new file lands —
even before wiring up automatic triggering, a pipe gives you that.

## Steps
1. Requires task-38's fixture_clean.csv uploaded to `@RAW.IOT_STAGE`
   (re-upload it if it's no longer there).
2. Run `66_snowpipe_internal_stage.sql`.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `66_snowpipe_internal_stage.sql` — three questions
on why internal-stage pipes can't auto-fire, whether REFRESH re-loads
already-ingested files, and what a pipe actually buys you here.
