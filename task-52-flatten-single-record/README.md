# Task 52 — FLATTEN a single JSON record

**Category:** Semi-structured data

## Goal
Exploding a single nested JSON document into relational rows.

**Real-world scenario:** One device's event payload has an "alerts"
array with a variable number of entries — sometimes zero, sometimes
several. You need one row per alert to actually query/count them, not
one row per device event with a buried array inside it.

## Steps
1. Run `53_flatten_single_record.sql`.
2. Work through it section by section against your own Snowflake trial
   — don't just read it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `53_flatten_single_record.sql` — three questions on
what an empty array produces, whether FLATTEN is genuinely different
from Task 21's LATERAL lesson, and the seq vs. index columns.
