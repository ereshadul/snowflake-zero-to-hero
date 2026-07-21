# Task 57 — Unload to JSON

**Category:** Unloading data

## Goal
Unloading query results as newline-delimited JSON.

**Real-world scenario:** A downstream system consumes nested JSON
documents, not flat rows — unloading a table that has a VARIANT
column as CSV would mangle that structure into an escaped string
blob, while JSON keeps it genuinely nested.

## Steps
1. Run `58_unload_json.sql`.
2. Work through it section by section against your own Snowflake trial
   — don't just read it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `58_unload_json.sql` — three questions on JSON's
newline-delimited structure, comparing nested-data fidelity against
CSV, and when you'd still choose CSV anyway.
