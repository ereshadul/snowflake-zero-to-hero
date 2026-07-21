# Task 68 — Snowpipe cost model

**Category:** Snowpipe

## Goal
How Snowpipe billing (serverless compute per file) differs from warehouse billing.

**Real-world scenario:** A team's Snowpipe bill is way higher than
expected, even though total data volume didn't change — the actual
culprit is usually upstream systems producing thousands of tiny files
instead of a few larger ones, because Snowpipe bills a per-FILE
overhead on top of per-byte compute.

## Steps
1. Run `69_snowpipe_cost.sql`.
2. Work through it section by section against your own Snowflake trial
   — don't just read it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `69_snowpipe_cost.sql` — three questions on billing
granularity at low volume, why file count drives cost independent of
data volume, and the upstream fix.
