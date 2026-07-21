# Task 26 — Deduplication strategies

**Category:** SQL Interview Practice

## Goal
Several ways to find and remove duplicate rows, and why ROW_NUMBER is usually the right one.

**Real-world scenario:** A batch load ran twice by accident, so you
have exact duplicate rows — but you ALSO have a customer whose email
changed and now has two legitimately different rows sharing the same
customer_id. "Remove duplicates" means two different things here, and
only one of them is what DISTINCT actually does.

## Steps
1. Run `27_deduplication_strategies.sql`.
2. Work through it section by section against your own Snowflake trial
   — don't just read it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `27_deduplication_strategies.sql` — three questions
on why DISTINCT can't fix a same-key/different-value duplicate, what
definition of "duplicate" ROW_NUMBER uses instead, and the QUALIFY
callback to Task 17.
