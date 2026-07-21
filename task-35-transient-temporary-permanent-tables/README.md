# Task 35 — PERMANENT vs. TRANSIENT vs. TEMPORARY tables

**Category:** Table & Data Fundamentals

## About this category
Tasks 35-37 are the DDL fundamentals that shape every table you create
from here on — table types, constraint enforcement, and primary key
generation. Task 1 already picked defaults for all three without
explaining why; this category is that explanation.

## Goal
Time Travel/Fail-safe differences between the three table types, why daily-truncated staging tables usually don't need PERMANENT, and whether a permanent table can live inside a transient schema.

**Real-world scenario:** Your platform team asks "why is our storage
bill so much higher than expected?" — and the answer is often "half
our staging tables that get truncated and reloaded daily are still
PERMANENT, quietly paying for 7 extra days of Fail-safe storage they
never use."

## Steps
1. Run `36_transient_temporary_permanent_tables.sql`.
2. Work through it section by section against your own Snowflake trial
   — don't just read it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `36_transient_temporary_permanent_tables.sql` —
three questions on what a PERMANENT staging table actually wastes,
whether a schema's transient-ness overrides a table's own type, and
where TEMPORARY tables genuinely help vs. genuinely confuse.
