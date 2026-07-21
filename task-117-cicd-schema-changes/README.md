# Task 117 — CI/CD for schema changes

**Category:** Ecosystem & Modeling

## Goal
Driving SQL deployments through GitHub Actions instead of hand-running
worksheets — plain DDL migrations this time, not dbt models (that was
Task 113).

**Real-world scenario:** A schema change gets pasted into a worksheet
by whoever's around that day, with no record of what ran, when, or by
whom. A migration file in git plus a CI workflow means every schema
change is reviewed, ordered, and reproducible.

## Steps
1. Run `118_cicd_schema_changes.sql`.
2. Work through it section by section against your own Snowflake trial
   — don't just read it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `118_cicd_schema_changes.sql` — three questions on
why migrations must tolerate re-runs, path-filtering a workflow
trigger, and what dbt's CI/CD gives you that a bare loop-over-files
script doesn't.
