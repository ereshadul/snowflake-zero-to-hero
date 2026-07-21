# Task 119 — Snowflake Cortex

**Category:** Ecosystem & Modeling

## Goal
Calling Cortex's built-in LLM functions directly from SQL.

**Real-world scenario:** A pile of free-text maintenance notes sits
next to structured sensor data, and nobody has time to read them all
to spot the urgent ones. `SNOWFLAKE.CORTEX.SENTIMENT` and
`CLASSIFY_TEXT` turn that into a plain `ORDER BY`/`WHERE` — no data
ever leaves Snowflake to reach a third-party AI API.

## Steps
1. Run `120_cortex.sql`.
2. Work through it section by section against your own Snowflake trial
   — don't just read it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `120_cortex.sql` — three questions on what actually
runs behind a Cortex function call, why constrained outputs are more
queryable than free text, and why staying inside Snowflake's boundary
matters for sensitive data.
