# Task 7 — Window functions: ROW_NUMBER, RANK, DENSE_RANK, NTILE

**Category:** Advanced SQL

## About this category — Advanced SQL
Tasks 7-16 are general SQL techniques — nothing here is Snowflake-
specific, this is the stuff that separates "can write a SELECT" from
"can actually answer the messy questions a stakeholder asks." Every
task in this category maps to a real recurring request, not an
academic exercise: ranking/leaderboards, period-over-period deltas,
running totals, reshaping data for a report, deduplicating messy
joins, and so on. If you already know standard SQL window functions
and CTEs cold, skim rather than grind — but the SQL Interview Practice
category (23-32) later assumes you're fluent in everything here.

## Goal
Assigning per-row rank within a partition, and the real differences between the three ranking functions when ties happen.

**Real-world scenario:** Ops asks "who are our top 2 sensors by
signal strength on each device type, and what happens when two
sensors report the exact same value?" That's this task — `RANK`,
`DENSE_RANK`, and `ROW_NUMBER` all answer "who's #1" differently the
moment a tie shows up, and picking the wrong one silently changes
which sensors get flagged.

## Steps
1. Run `08_window_ranking_functions.sql`.
2. Work through it section by section against your own Snowflake trial
   — don't just read it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `08_window_ranking_functions.sql`. Answer by actually running the
diagnostic queries it points to, not from memory.

*(Status: scaffolded — SQL content not yet written.)*
