# Task 66 — Auto-ingest vs. manual refresh

**Category:** Snowpipe

## Goal
The difference between event-driven auto-ingest and manually refreshing a pipe.

**Real-world scenario:** Files land in your S3 bucket around the
clock from an upstream system you don't control — nobody's available
to call ALTER PIPE REFRESH every time one shows up. Auto-ingest wires
S3's own event notifications to Snowflake so it happens on its own.

**Requires Tasks 5-6** (the S3 bucket, IAM role, and STORAGE
INTEGRATION) already set up.

## Steps
1. Run `67_snowpipe_auto_vs_manual.sql` — partway through it, you'll
   switch to the AWS Console to wire up an S3 event notification.
2. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `67_snowpipe_auto_vs_manual.sql` — three questions
on who owns the notification queue, why auto-ingest's latency is an
acceptable tradeoff, and how you'd notice a silently broken pipe.
