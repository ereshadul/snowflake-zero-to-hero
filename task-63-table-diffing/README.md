# Task 63 — Comparing two tables for drift

**Category:** Data Integrity & Quality

## About this category — Data Integrity & Quality
Tasks 63-64 are about catching problems the database itself won't —
directly following from Task 36's finding that Snowflake doesn't
enforce most constraints. If the platform won't stop bad data, you
need a way to detect it after the fact.

## Goal
Comparing two tables (e.g. QA vs. prod) for drift with MINUS/EXCEPT and hash-based row comparison.

**Real-world scenario:** "Why does QA show different numbers than
production?" — before you can fix drift between two environments, you
need to know exactly which rows differ, which are missing, and which
are extra, not just "something's off."

## Steps
1. Run `64_table_diffing.sql`.
2. Work through it section by section against your own Snowflake trial
   — don't just read it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `64_table_diffing.sql` — three questions on what
MINUS alone can't tell you, why hashing scales better than column-by-
column comparison, and the duplicate-key risk in a diff report.
