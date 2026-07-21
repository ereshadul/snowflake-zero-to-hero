# Task 10 — CTEs and recursive CTEs

**Category:** Advanced SQL

## Goal
WITH clauses for readable multi-step queries, then a recursive CTE for hierarchical/graph-shaped data.

**Real-world scenario:** Your manager asks: "Can you pull a report
showing every employee and who they ultimately roll up to, so we can
see how many layers of management we actually have?" You don't know
in advance how many levels deep the org chart goes — some managers
have 2 layers above them, some have 6 — so a fixed number of JOINs
can't answer it. That's exactly the shape a recursive CTE is for:
"keep joining until there's nothing left to find," not "join a known
number of times."

## Steps
1. Run `11_ctes_recursive.sql`.
2. Work through it section by section against your own Snowflake trial
   — don't just read it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `11_ctes_recursive.sql`. Answer by actually running the
diagnostic queries it points to, not from memory.

*(Status: scaffolded — SQL content not yet written.)*
