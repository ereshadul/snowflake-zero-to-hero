# Task 50 — ARRAY data type

**Category:** Semi-structured data

## Goal
Storing and querying ordered lists natively with ARRAY.

**Real-world scenario:** Each device can have any number of free-form
tags — 'outdoor', 'critical', 'battery-powered' — and forcing that
into a fixed number of tag1/tag2/tag3 columns would cap how many tags
a device could ever have and waste space on devices with fewer.

## Steps
1. Run `51_array_type.sql`.
2. Work through it section by section against your own Snowflake trial
   — don't just read it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `51_array_type.sql` — three questions on
out-of-bounds indexing, ARRAY_CONTAINS type matching, and persisting
an ARRAY_APPEND result back into the table.
