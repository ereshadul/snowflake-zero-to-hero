# Task 41 — RETURN_FAILED_ONLY

**Category:** Loading & COPY options

## Goal
Getting COPY INTO to report only the files/rows that failed, not a full success dump.

**Real-world scenario:** Your load pipeline processes 200 files
tonight, all but 2 load perfectly clean. An automated alert built on
the raw COPY INTO result would need to scroll through 198 boring
"success" rows to find the 2 that matter — RETURN_FAILED_ONLY hands
you just the 2.

**Setup:** requires both of Task 38's fixture files on `@RAW.IOT_STAGE`.

## Steps
1. Run `42_return_failed_only.sql`.
2. Work through it section by section against your own Snowflake trial
   — don't just read it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `42_return_failed_only.sql` — three questions on
which file disappears from the result, whether it changes what
actually loaded, and why it matters for automated alerting.
