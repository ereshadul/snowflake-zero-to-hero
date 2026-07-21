# Task 111 — dbt seeds

**Category:** dbt

## Goal
Version-controlling small static reference/lookup data as CSV files that dbt loads directly into tables.

**Real-world scenario:** A small device-model lookup table lives as a
spreadsheet someone emails around and nobody's sure which copy is
current. A dbt seed puts that same lookup data in a CSV under version
control, loaded with `dbt seed` and referenced with `ref()` just like
any other model.

## Steps
1. Work through `112_dbt_seeds.sql` — add the seed CSV, load it, join
   it into a model.
2. Do it for real against your own Snowflake trial — don't just read
   it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `112_dbt_seeds.sql` — three questions on whether a
seed is a different kind of DAG node, why full-replace is fine for
seeds specifically, and what data shouldn't be loaded as a seed.
