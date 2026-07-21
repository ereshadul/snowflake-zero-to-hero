# Task 20 — Sampling (SAMPLE / TABLESAMPLE)

**Category:** Advanced Snowflake SQL

## Goal
Querying a random subset of a huge table cheaply, and the difference between ROW and BERNOULLI/SYSTEM sampling.

**Real-world scenario:** A data scientist wants "a random 1% sample of
our 50-million-row table to prototype a model against" — running the
full table every time they iterate would be slow and wasteful. Which
sampling method you pick changes both how fast that sample comes back
and how statistically "random" it really is.

## Steps
1. Run `21_sampling.sql`.
2. Work through it section by section against your own Snowflake trial
   — don't just read it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `21_sampling.sql` — three questions comparing
BERNOULLI vs. SYSTEM timing via Query History, what REPEATABLE
actually pins down, and whether a row-count sample is exact.
