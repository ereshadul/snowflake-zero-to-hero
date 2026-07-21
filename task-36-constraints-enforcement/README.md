# Task 36 — What constraints Snowflake actually enforces

**Category:** Table & Data Fundamentals

## Goal
What Snowflake actually validates for PRIMARY KEY, FOREIGN KEY, UNIQUE, and NOT NULL constraints, and what's purely documentation the optimizer trusts but never checks.

**Real-world scenario:** A teammate migrating from Postgres declares a
PRIMARY KEY on a staging table and assumes Snowflake will reject
duplicate loads the same way Postgres would. It won't — and the first
time they find out is when duplicate rows show up downstream in a
report, not when the load itself fails.

## Steps
1. Run `37_constraints_enforcement.sql`.
2. Work through it section by section against your own Snowflake trial
   — don't just read it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `37_constraints_enforcement.sql` — three questions
on what PRIMARY KEY actually is in Snowflake, why NOT NULL is the one
exception, and whose job data integrity actually becomes instead.
