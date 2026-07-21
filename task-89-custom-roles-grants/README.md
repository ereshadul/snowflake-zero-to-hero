# Task 89 — Custom roles & grants

**Category:** Security

## Goal
Creating a custom role and granting it object and role privileges.

**Real-world scenario:** A pipeline creates new tables constantly.
Without `GRANT ... ON FUTURE TABLES`, someone has to remember to
re-grant access to every single new table by hand — and inevitably
forgets, until a report breaks.

## Steps
1. Run `90_custom_roles_grants.sql`, replacing `<your_username>` with
   your real username.
2. Work through it section by section against your own Snowflake trial
   — don't just read it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `90_custom_roles_grants.sql` — three questions on
what FUTURE actually covers, whether revoking the current-tables grant
also revokes the future one, and what manual process this eliminates.
