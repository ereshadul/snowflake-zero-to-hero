# Task 106 — dbt schema tests (unique, not_null, relationships, accepted_values)

**Category:** dbt

## Goal
The four built-in generic tests declared in YAML, and what each one actually catches.

**Real-world scenario:** A silent upstream bug starts writing a
`status_code` value nobody's ever seen before, and a downstream
dashboard breaks because it wasn't expecting it. A single
`accepted_values` test in YAML would have caught it the next time
`dbt test` ran — before anyone downstream noticed.

## Steps
1. Work through `107_dbt_schema_tests.sql` — declare the four generic
   tests, run them, then deliberately break one to see a real failure.
2. Do it for real against your own Snowflake trial — don't just read
   it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `107_dbt_schema_tests.sql` — three questions on what
a failing test actually reports, where the `relationships` test
executes, and the tradeoff of YAML-only tests versus hand-written SQL.
