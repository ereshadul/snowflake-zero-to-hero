# Task 67 — Monitoring (PIPE_STATUS, SYSTEM$PIPE_STATUS)

**Category:** Snowpipe

## Goal
Checking whether a pipe is healthy and what's queued or failed.

**Real-world scenario:** Data stopped showing up in a table an hour
ago. Before assuming the worst, you need to check: is the pipe
actually paused, backed up with pending files, or quietly failing on
every file it touches?

## Steps
1. Run `68_snowpipe_monitoring.sql`.
2. Work through it section by section against your own Snowflake trial
   — don't just read it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `68_snowpipe_monitoring.sql` — three questions on
execution states, PIPE_USAGE_HISTORY vs. COPY_HISTORY, and what
pausing a pipe actually accomplishes.
