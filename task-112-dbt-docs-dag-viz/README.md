# Task 112 — dbt docs and the dependency graph

**Category:** dbt

## Goal
Generating dbt's documentation site and visual DAG so a model's lineage is self-documenting instead of tribal knowledge.

**Real-world scenario:** A new analytics engineer needs to understand
where a dashboard's numbers actually come from before changing
anything, and reconstructing the dependency chain by reading every
model's SQL by hand doesn't scale past a handful of models. `dbt docs
serve` renders the whole lineage graph from information dbt already
has.

## Steps
1. Work through `113_dbt_docs_dag_viz.sql` — add descriptions, generate
   the docs site, and browse the DAG.
2. Do it for real against your own Snowflake trial — don't just read
   it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `113_dbt_docs_dag_viz.sql` — three questions on where
the DAG is actually derived from, YAML docs vs. a separate wiki, and
lineage-graph browsing vs. manual code reading.
