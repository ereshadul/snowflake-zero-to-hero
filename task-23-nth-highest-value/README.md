# Task 23 — Nth highest value (the second-highest-salary problem)

**Category:** SQL Interview Practice

## About this category — SQL Interview Practice
Tasks 23-32 are the named classics — the problems that show up over
and over in SQL interviews regardless of company or industry. If
you've made it through Advanced SQL (7-16) and Advanced Snowflake SQL
(17-22), you already have every tool needed for these; this category
is about recognizing the *shape* of the problem fast and knowing which
tool fits, since these tend to arrive as vague word problems, not
labeled "use a window function here."

## Goal
The classic interview question, solved three ways (DISTINCT+OFFSET, DENSE_RANK, correlated subquery) with the tradeoffs of each.

**Real-world scenario:** This is close to word-for-word the most
commonly asked SQL interview question there is: "write a query to find
the second-highest salary." It sounds trivial until someone points out
two employees are tied for it, and your query needs to actually decide
what "second highest" means when that happens.

## Steps
1. Run `24_nth_highest_value.sql`.
2. Work through it section by section against your own Snowflake trial
   — don't just read it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `24_nth_highest_value.sql` — three questions on how
each approach handles ties, how easily each generalizes to the Nth
value instead of just the 2nd, and where the correlated-subquery
approach stops scaling.
