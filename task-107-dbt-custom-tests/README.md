# Task 107 — dbt custom and singular tests

**Category:** dbt

## Goal
Writing your own SQL-based test when the four generic tests aren't enough to express a real business rule.

**Real-world scenario:** "Battery percentage should never be negative"
isn't something `unique`/`not_null`/`accepted_values`/`relationships`
can express — it's a business rule specific to this data, so it needs
a hand-written test query instead.

## Steps
1. Work through `108_dbt_custom_tests.sql` — write a singular test,
   then a reusable generic test, and run both.
2. Do it for real against your own Snowflake trial — don't just read
   it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `108_dbt_custom_tests.sql` — three questions on the
pass/fail contract every dbt test shares, singular vs. generic
reusability, and what the four built-in tests can't express.
