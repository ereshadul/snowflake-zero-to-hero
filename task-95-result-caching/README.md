# Task 95 — Result caching

**Category:** Performance & cost

## Goal
When Snowflake reuses a cached result vs. recomputing, and how to tell.

**Real-world scenario:** A dashboard re-runs the same query every time
someone loads the page. Result caching means most of those loads cost
zero compute — but only if the query text matches exactly and the
underlying data hasn't changed since.

## Steps
1. Run `96_result_caching.sql`, comparing elapsed time at each step.
2. Work through it section by section against your own Snowflake trial
   — don't just read it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `96_result_caching.sql` — three questions on exact
text matching, cache invalidation on data change, and why caching
alone isn't a real performance strategy.
