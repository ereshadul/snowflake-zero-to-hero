# Task 3 — Scheduler for continuous data (Snowflake Tasks)

## Goal
Get a piece of SQL to run repeatedly on its own, on a schedule, inside
Snowflake — no cron box, no Airflow, no external cloud. This is what a
Snowflake **Task** is for.

## Steps
1. Run `04_scheduler_task.sql`. It creates a task on a 1-minute
   schedule that appends 500 synthetic rows each run, resumes it,
   then shows you how to check on it.
2. Let it run for 3-5 minutes. Re-run the row-count query a few times
   and watch it grow.
3. **Suspend the task before you move on** — the script does this at
   the end, but double check it actually got suspended
   (`SHOW TASKS;` and look at the `state` column) so it doesn't keep
   burning credits in the background after you close the worksheet.

## Understanding check
See the bottom of `04_scheduler_task.sql` — three questions about
warehouse auto-suspend interacting with task schedules, what
"suspended" vs "skipped" actually means for a task, and serverless
vs. warehouse-backed tasks. Answer them with the task actually running
in front of you, not from memory.
