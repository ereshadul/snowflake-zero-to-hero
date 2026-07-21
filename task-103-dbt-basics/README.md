# Task 103 — dbt basics on Snowflake

**Category:** dbt

## Goal
Wiring up a dbt project against Snowflake and running a first model + test.

**Real-world scenario:** A new analytics engineer joins the team and
needs to go from "nothing installed" to "my first model is running
against our Snowflake account" without breaking anyone else's setup —
that's exactly the profiles.yml / dbt_project.yml split this task
walks through.

**Note:** This task (and the rest of the dbt category) uses the dbt
CLI outside of Snowflake, not a worksheet. `104_dbt_basics.sql`
contains the actual dbt project files to save, plus the CLI commands
to run — read it like a guide, not a single script to paste in.

## Steps
1. Work through `104_dbt_basics.sql` — install dbt, wire up
   profiles.yml, run your first model.
2. Do it for real against your own Snowflake trial — don't just read
   it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `104_dbt_basics.sql` — three questions on why
credentials and project code live in separate files, where dbt gets a
model's target object type/schema from, and the view-vs-table
materialization tradeoff.
