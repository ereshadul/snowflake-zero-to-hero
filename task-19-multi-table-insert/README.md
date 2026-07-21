# Task 19 — Multi-table INSERT

**Category:** Advanced Snowflake SQL

## Goal
Routing rows from one SELECT into multiple target tables in a single statement.

**Real-world scenario:** You're splitting one incoming order feed into
"large orders," "small orders," and "orders with no customer attached
(needs investigation)" — three separate downstream tables — without
scanning and filtering the source three separate times.

## Steps
1. Run `20_multi_table_insert.sql`.
2. Work through it section by section against your own Snowflake trial
   — don't just read it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `20_multi_table_insert.sql` — three questions
tracing exactly which table(s) a row that matches multiple conditions
lands in under INSERT ALL vs. INSERT FIRST, and why clause order only
matters for one of the two.
