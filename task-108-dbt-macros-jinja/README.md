# Task 108 — dbt macros and Jinja templating

**Category:** dbt

## Goal
Writing a reusable macro with Jinja to stop copy-pasting the same SQL pattern across models.

**Real-world scenario:** The same `TRY_TO_DECIMAL(...)` casting pattern
is copy-pasted into a dozen staging models, and a bug in the casting
logic means fixing all twelve by hand. One macro definition means
fixing it in exactly one place.

## Steps
1. Work through `109_dbt_macros_jinja.sql` — write the macro, call it
   from a model, and inspect the compiled SQL dbt actually sends to
   Snowflake.
2. Do it for real against your own Snowflake trial — don't just read
   it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `109_dbt_macros_jinja.sql` — three questions on what
Snowflake actually receives, the one-place-to-fix payoff of reuse, and
how a test relates to a macro under the hood.
