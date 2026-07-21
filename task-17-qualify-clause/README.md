# Task 17 — QUALIFY clause

**Category:** Advanced Snowflake SQL

## About this category — Advanced Snowflake SQL
Tasks 17-22 are Snowflake-specific syntax and mechanisms — things
that don't transfer directly to Postgres/MySQL/SQL Server, but come
up constantly once you're actually working in Snowflake day to day.
Where Advanced SQL (7-16) was portable knowledge, this category is
about the shortcuts and mechanics that are genuinely unique to this
platform.

## Goal
Filtering on a window function's result without wrapping the query in a subquery -- a Snowflake-native shortcut most other dialects don't have.

**Real-world scenario:** You've written a query with `RANK() OVER (...)`
and now need "only the #1 row per group." In most SQL dialects that
means wrapping the whole query in a subquery just to filter on the
rank column. QUALIFY skips that — filter on the window function
result directly, in the same query.

## Steps
1. Run `18_qualify_clause.sql`.
2. Work through it section by section against your own Snowflake trial
   — don't just read it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `18_qualify_clause.sql` — three questions on
combining WHERE + QUALIFY, why QUALIFY can reference a window function
alias when WHERE can't, and inlining vs. aliasing the window function.
