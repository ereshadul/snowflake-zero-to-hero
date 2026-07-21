# Task 60 — UDF basics & supported languages

**Category:** Programmability

## About this category — Programmability
Tasks 60-62 are about extending Snowflake with your own logic — UDFs,
stored procedures, and notifications — instead of only ever composing
built-in functions.

## Goal
What a UDF is and which languages Snowflake supports (SQL, JavaScript, Python, Java, Scala) -- and what a UDF fundamentally can and can't do (no DDL/DML side effects).

**Real-world scenario:** A teammate asks "can we write a UDF that
truncates a table when called?" — and the honest answer is no,
structurally, no matter what language you write it in. A UDF is
always an expression that returns a value; it can't run DML.

## Steps
1. Run `61_udf_basics.sql`.
2. Work through it section by section against your own Snowflake trial
   — don't just read it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `61_udf_basics.sql` — three questions on why Python
needs a HANDLER when SQL/JS don't, what error a DML-attempting UDF
actually throws, and what object type you'd reach for instead.
