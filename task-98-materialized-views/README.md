# Task 98 — Materialized views

**Category:** Performance & cost

## Goal
Trading storage/maintenance cost for query speed on an expensive aggregation.

**Real-world scenario:** A dashboard re-runs the same "daily summary
per device" aggregation over a 50-million-row table dozens of times a
day. Instead of re-aggregating from scratch every time, a materialized
view pre-computes and stores the result, and Snowflake keeps it
current in the background.

## Steps
1. Run `99_materialized_views.sql`, comparing elapsed time between the
   plain view and the materialized view.
2. Work through it section by section against your own Snowflake trial
   — don't just read it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `99_materialized_views.sql` — three questions on the
elapsed-time comparison, background maintenance cost, and the real
tradeoff a materialized view makes.
