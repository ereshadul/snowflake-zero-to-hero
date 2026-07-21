# Task 113 — dbt deployment and CI/CD for dbt

**Category:** dbt

## Goal
Running dbt on a schedule/in a pipeline (dbt Cloud vs. a self-hosted dbt run in GitHub Actions) instead of only ever running it from your laptop.

**Real-world scenario:** Every project so far has run from a single
laptop with `dbt run`. Production needs it running unattended on a
schedule, and needs a failing test to block a pull request from
merging — not just print a warning nobody reads.

## Steps
1. Work through `114_dbt_deployment_cicd.sql` — compare a dbt Cloud job
   against a self-hosted GitHub Actions workflow running `dbt build`.
2. Do it for real against your own Snowflake trial where you can (the
   CI workflow can be read/adapted even without a live GitHub Actions
   run).
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `114_dbt_deployment_cicd.sql` — three questions on
secrets in CI, why CI needs its own target/schema, and the managed vs.
self-hosted tradeoff.
