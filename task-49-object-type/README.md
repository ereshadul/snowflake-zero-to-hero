# Task 49 — OBJECT data type

**Category:** Semi-structured data

## About this category — Semi-structured data
Tasks 49-54 cover Snowflake's native support for JSON-shaped data —
OBJECT, ARRAY, VARIANT, and the FLATTEN operations that turn nested
structures back into rows. This is what lets you skip designing a
rigid schema upfront when the source data genuinely varies row to row.

## Goal
Storing and querying key-value data natively with OBJECT.

**Real-world scenario:** Different device models report wildly
different config fields — some have a sample_rate, some have a
firmware channel, some have neither — and forcing all of that into
fixed columns would mean a table full of mostly-NULL fields. An
OBJECT column holds whatever shape each device actually has.

## Steps
1. Run `50_object_type.sql`.
2. Work through it section by section against your own Snowflake trial
   — don't just read it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `50_object_type.sql` — three questions on the raw
type of a `:field` access before casting, OBJECT_INSERT's overwrite
behavior, and the real tradeoff of OBJECT vs. fixed columns.
