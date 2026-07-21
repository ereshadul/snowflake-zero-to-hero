# Task 78 — Task trees/DAGs

**Category:** Tasks, deeper

## Goal
Chaining tasks into a dependency graph with AFTER.

**Real-world scenario:** A real pipeline is rarely one step — raw data
lands, gets cleaned, then gets aggregated. Each stage should be its
own task so a failure in one stage is isolated and re-runnable, not
buried inside one giant multi-step script.

## Steps
1. Run `79_task_trees_dag.sql`. **Suspend all three tasks at the end**
   (root first).
2. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `79_task_trees_dag.sql` — three questions on
confirming execution order from TASK_HISTORY, why tasks resume
leaf-first, and why separate tasks beat one big multi-step task body.
