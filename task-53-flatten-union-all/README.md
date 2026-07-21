# Task 53 — FLATTEN + UNION ALL multiple records

**Category:** Semi-structured data

## Goal
Flattening many JSON documents at once and stitching the results together.

**Real-world scenario:** You need one combined "all flagged items"
list across an entire table of device events — spanning both an
"alerts" array and a separate "warnings" array on each record — not
just one array from one hand-picked record like Task 52.

## Steps
1. Run `54_flatten_union_all.sql`.
2. Work through it section by section against your own Snowflake trial
   — don't just read it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `54_flatten_union_all.sql` — three questions on how
LATERAL keeps flattened rows attached to their source row, empty
arrays in a UNION ALL, and why ALL specifically matters here.
