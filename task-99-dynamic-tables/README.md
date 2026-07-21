# Task 99 — Dynamic Tables

**Category:** Newer table types

## Goal
Declarative, incrementally-refreshed tables defined by a query instead of a pipeline.

**Real-world scenario:** A team keeps hand-rolling Stream + Task
pipelines (Tasks 69-82) for every new incremental aggregation, and
each one is a slightly different bespoke pile of SQL to maintain. A
Dynamic Table replaces the whole pipeline with one `CREATE DYNAMIC
TABLE ... AS SELECT` — describe the result you want, tell Snowflake
how fresh it needs to be, and it handles the rest.

## Steps
1. Run `100_dynamic_tables.sql`.
2. Work through it section by section against your own Snowflake trial
   — don't just read it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `100_dynamic_tables.sql` — three questions comparing
Dynamic Tables to the Stream+Task pattern, how TARGET_LAG actually
drives refresh cadence, and chaining Dynamic Tables into pipelines.
