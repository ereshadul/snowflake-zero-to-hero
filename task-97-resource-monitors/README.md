# Task 97 — Resource monitors

**Category:** Performance & cost

## Goal
Capping credit spend with a resource monitor and suspend actions.

**Real-world scenario:** A badly written query (or a forgotten
running Task, like the one from Task 3) quietly burns through credits
with nobody watching. A resource monitor is the safety net that
notices before the bill does.

## Steps
1. Run `98_resource_monitors.sql`.
2. Work through it section by section against your own Snowflake trial
   — don't just read it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `98_resource_monitors.sql` — three questions on
SUSPEND vs. SUSPEND_IMMEDIATE, sharing one monitor across warehouses,
and why this matters even on a trial account.
