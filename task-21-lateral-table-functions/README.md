# Task 21 — LATERAL joins with table functions

**Category:** Advanced Snowflake SQL

## Goal
Calling a table function once per row of an outer query -- the general mechanism behind FLATTEN.

**Real-world scenario:** A `product_tags` column stores comma-separated
tags as one string per row ('electronics,sale,new'), and you need one
row per tag instead — the tag-splitting has to happen differently for
every single row, using that row's own value as the input. That
per-row correlation is exactly what LATERAL enables and a plain join
can't.

## Steps
1. Run `22_lateral_table_functions.sql`.
2. Work through it section by section against your own Snowflake trial
   — don't just read it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `22_lateral_table_functions.sql` — three questions
on whether LATERAL is required or just one valid syntax, how row
count changes under a lateral join, and how this connects to FLATTEN.
