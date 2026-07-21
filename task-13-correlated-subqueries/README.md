# Task 13 — Correlated subqueries vs. EXISTS vs. IN vs. JOIN

**Category:** Advanced SQL

## Goal
Four ways to ask "does a related row exist," and why they don't always perform or behave the same.

**Real-world scenario:** Marketing asks for "a list of customers who
have never placed an order, so we can send them a welcome discount."
Sounds trivial — until your orders table has one row with a NULL
customer_id (a guest checkout, a data entry gap) and your first
instinct (`NOT IN`) silently returns an empty list instead of an
error, because nobody told you `NOT IN` and NULL don't mix.

## Steps
1. Run `14_correlated_subqueries.sql`.
2. Work through it section by section against your own Snowflake trial
   — don't just read it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `14_correlated_subqueries.sql` — three questions on
the NOT IN/NULL trap, why EXISTS is immune to it, and why the JOIN
version needs DISTINCT when the others don't.
