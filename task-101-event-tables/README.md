# Task 101 — Event Tables

**Category:** Newer table types

## Goal
The special table type that captures logs/traces from procedures and functions.

**Real-world scenario:** A stored procedure fails intermittently in
production and nobody can tell why without adding print statements and
re-deploying. An event table captures structured log output from
procedures and functions automatically, queryable with the same SQL
you already know — no separate logging system required.

## Steps
1. Run `102_event_tables.sql`.
2. Work through it section by section against your own Snowflake trial
   — don't just read it. Note that event delivery is asynchronous, so
   give it a minute before querying.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `102_event_tables.sql` — three questions on
asynchronous event delivery, one-event-table-per-account, and why
logs living in queryable SQL matters during an incident.
