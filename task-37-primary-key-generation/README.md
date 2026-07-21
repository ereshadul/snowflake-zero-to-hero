# Task 37 — Generating primary keys

**Category:** Table & Data Fundamentals

## Goal
Generating primary key values in Snowflake with sequences and AUTOINCREMENT/IDENTITY columns, given PRIMARY KEY itself isn't enforced.

**Real-world scenario:** Since Task 36 showed Snowflake won't stop a
duplicate PRIMARY KEY value from being inserted, the real defense
against duplicates is making sure you never hand-pick a colliding
value in the first place — which is exactly what SEQUENCE and
IDENTITY are for.

## Steps
1. Run `38_primary_key_generation.sql`.
2. Work through it section by section against your own Snowflake trial
   — don't just read it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `38_primary_key_generation.sql` — three questions on
whether gaps are expected, standalone SEQUENCE vs. per-table IDENTITY,
and whether generated keys are truly duplicate-proof.
