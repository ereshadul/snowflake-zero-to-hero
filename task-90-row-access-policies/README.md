# Task 90 — Row access policies

**Category:** Security

## Goal
Restricting which rows a role can see with a row access policy.

**Real-world scenario:** East-region analysts and West-region analysts
both query the same sales table — but each should only ever see their
own region's rows, enforced by the platform, not by every analyst
remembering to add their own WHERE clause.

## Steps
1. Run `91_row_access_policies.sql`, replacing `<your_username>` with
   your real username.
2. Work through it section by section against your own Snowflake trial
   — don't just read it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `91_row_access_policies.sql` — three questions on
whether the filtering is transparent to the querying role, what
happens with no mapping-table entry, and why a mapping table beats
hardcoded role logic.
