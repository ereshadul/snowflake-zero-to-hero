# Task 47 — Load history (COPY_HISTORY / LOAD_HISTORY)

**Category:** Loading & COPY options

## Goal
Auditing what got loaded, when, and whether it succeeded, after the fact.

**Real-world scenario:** Someone asks "did last night's load actually
work, and were there any errors?" a full day after it ran — you need
to answer from history, not from having watched it happen live.

## Steps
1. Run `48_load_history.sql`.
2. Work through it section by section against your own Snowflake trial
   — don't just read it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `48_load_history.sql` — three questions on
ACCOUNT_USAGE's latency, querying across every table at once, and
reading real status values from your own Tasks 38-46 history.
