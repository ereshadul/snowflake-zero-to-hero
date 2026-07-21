# Task 84 — UNDROP

**Category:** Time Travel & cloning

## Goal
Recovering a dropped table/schema/database within its retention window.

**Real-world scenario:** Someone runs `DROP TABLE` against the wrong
environment. Instead of restoring from a backup system, UNDROP brings
it back instantly — as long as the name isn't already taken by
something new.

## Steps
1. Run `85_undrop.sql`.
2. Work through it section by section against your own Snowflake trial
   — don't just read it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `85_undrop.sql` — three questions on the retention
window, why the name-collision error happens, and whether transient
tables get the same recovery guarantee.
