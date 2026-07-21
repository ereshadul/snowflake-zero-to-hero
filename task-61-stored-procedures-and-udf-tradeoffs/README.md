# Task 61 — Stored procedures vs. UDFs

**Category:** Programmability

## Goal
Why TRUNCATE (or any DDL/DML) requires a stored procedure, not a UDF, and when to reach for each.

**Real-world scenario:** Task 60 ended on a cliffhanger — a UDF
genuinely can't TRUNCATE a table. This is the object type that can:
a stored procedure, callable with `CALL`, with real procedural control
flow and full DDL/DML access.

## Steps
1. Run `62_stored_procedures_and_udf_tradeoffs.sql`.
2. Work through it section by section against your own Snowflake trial
   — don't just read it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `62_stored_procedures_and_udf_tradeoffs.sql` — three
questions on what a procedure's body can access that a UDF's can't,
why CALL is required instead of inline SELECT, and procedural control
flow vs. expression-based CASE.
