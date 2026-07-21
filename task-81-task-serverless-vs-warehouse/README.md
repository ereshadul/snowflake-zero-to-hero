# Task 81 — Serverless vs. warehouse-backed tasks

**Category:** Tasks, deeper

## Goal
Choosing between Snowflake-managed compute and your own warehouse for a task.

**Real-world scenario:** A small, infrequent task doesn't justify
babysitting a dedicated warehouse's sizing and auto-suspend settings —
serverless hands that management to Snowflake. But if a warehouse is
already busy with other work most of the time, piggybacking on it can
be cheaper than paying for separate serverless compute.

## Steps
1. Requires Task 78 already done — reuses DAG_BRONZE.
2. Run `82_task_serverless_vs_warehouse.sql`. Leave the task suspended
   at the end.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `82_task_serverless_vs_warehouse.sql` — three
questions on confirming the serverless-vs-warehouse toggle and when
each actually costs less.
