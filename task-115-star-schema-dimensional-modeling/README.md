# Task 115 — Star schema & dimensional modeling

**Category:** Ecosystem & Modeling

## Goal
Fact tables, dimension tables, and a date dimension — Kimball-style
star schema modeling, as a second modeling approach alongside Task
116's Data Vault. Both model the same kind of data differently; this
task is about knowing when star schema is the better fit.

**Real-world scenario:** A BI dashboard needs "average reading by day
of week and device type" to run fast and stay simple to write. A star
schema — one skinny fact table joined out to a handful of dimension
tables — is built exactly for that kind of question.

## Steps
1. Run `116_star_schema_dimensional_modeling.sql`.
2. Work through it section by section against your own Snowflake trial
   — don't just read it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `116_star_schema_dimensional_modeling.sql` — three
questions on why facts reference dimensions by key, the payoff of a
pre-computed date dimension, and where star schema starts to strain.
