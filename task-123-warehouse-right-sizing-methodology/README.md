# Task 123 — A repeatable warehouse right-sizing methodology

**Category:** FinOps

## Goal
Formalizing the SMALL-vs-MEDIUM test from Task 2 into a repeatable
process: when a bigger warehouse actually pays for itself, and how to
tell from the query profile instead of guessing or upsizing by
default.

## Steps
1. Run `124_warehouse_right_sizing_methodology.sql`.
2. Work through it section by section against your own Snowflake trial
   — don't just read it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `124_warehouse_right_sizing_methodology.sql` — three
questions on distinguishing a queuing problem from a slow-query
problem, converting speedup into actual credit cost, and why profiling
comes before the controlled size test.
