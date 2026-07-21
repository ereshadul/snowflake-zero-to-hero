# Task 94 — Query profile

**Category:** Performance & cost

## Goal
Reading the query profile graph to find the actual bottleneck in a slow query.

**Real-world scenario:** A query someone wrote "just works" but takes
much longer than it should — usually because of exactly this pattern:
a join condition that isn't selective enough, quietly exploding the
row count mid-query.

## Steps
1. Run `95_query_profile.sql`, then open its Query Profile in Snowsight.
2. Work through it section by section against your own Snowflake trial
   — don't just read it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `95_query_profile.sql` — three questions on finding
the dominant operator, checking for spilling, and quantifying the
join's row explosion.
