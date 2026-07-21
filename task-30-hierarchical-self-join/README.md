# Task 30 — Self-join for hierarchical data (manager-employee)

**Category:** SQL Interview Practice

## Goal
Walking an org chart with a self-join, then with a recursive CTE, and when each is the right tool.

**Real-world scenario:** "How many management layers deep are we,
company-wide?" A fixed self-join can answer "who's my manager's
manager" (2 hops, hardcoded) but has no way to answer "how deep does
this go" for an org chart whose depth you don't know in advance.

## Steps
1. Run `31_hierarchical_self_join.sql`.
2. Work through it section by section against your own Snowflake trial
   — don't just read it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `31_hierarchical_self_join.sql` — three questions
tracing the recursive termination condition and exactly where a
fixed-depth self-join stops scaling.
