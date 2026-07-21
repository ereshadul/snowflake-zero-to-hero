# Task 105 — dbt ref() and building a model DAG

**Category:** dbt

## Goal
Using ref() instead of hardcoded table names so dbt can infer dependency order automatically, and reading the resulting DAG.

**Real-world scenario:** Someone reorders a model's schema config and
every hardcoded downstream reference silently breaks or points at
stale data. Using `ref()` everywhere means dbt derives correct run
order from the dependency graph itself — nobody has to remember or
maintain that ordering by hand.

## Steps
1. Work through `106_dbt_ref_and_dag.sql` — build the mart model on
   `ref()`, run the whole project, inspect the DAG with `dbt list`.
2. Do it for real against your own Snowflake trial — don't just read
   it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `106_dbt_ref_and_dag.sql` — three questions on what
`ref()` decouples you from, the `+` operator's direction, and where
dbt actually derives run order from.
