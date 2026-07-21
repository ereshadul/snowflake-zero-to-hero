# Task 51 — VARIANT data type

**Category:** Semi-structured data

## Goal
The type that holds arbitrary JSON and how dot/bracket notation traverses it.

**Real-world scenario:** An upstream API sometimes sends a field as
`null`, sometimes just omits the field, and sometimes sends a genuine
value — and your downstream logic needs to tell those three cases
apart, not treat them all as "empty."

## Steps
1. Run `52_variant_type.sql`.
2. Work through it section by section against your own Snowflake trial
   — don't just read it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `52_variant_type.sql` — three questions on SQL NULL
vs. JSON null, VARIANT holding bare scalars, and breaking down a
nested traversal expression.
