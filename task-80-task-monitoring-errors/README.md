# Task 80 — Task monitoring & error handling

**Category:** Tasks, deeper

## Goal
Inspecting task run history and handling failures in a DAG.

**Real-world scenario:** A DAG's downstream tasks silently stop
running, and nobody notices for days — because the actual root cause
was the FIRST task in the chain failing, quietly, with nothing
downstream ever getting a chance to run at all.

## Steps
1. Run `81_task_monitoring_errors.sql`. **Suspend both tasks at the
   end** — this one is designed to fail on every cycle, so don't leave
   it running.
2. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `81_task_monitoring_errors.sql` — three questions on
reading the real error message, what happens to a child when its
parent fails, and wiring in failure notifications.
