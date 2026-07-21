# Task 25 — Gaps and islands problem

**Category:** SQL Interview Practice

## Goal
Finding consecutive-value groups and the gaps between them -- a named classic in SQL interviews.

**Real-world scenario:** Product wants "each user's login streaks —
when did each unbroken run of consecutive days start and end, and how
long was it?" There's no built-in function for that; you have to
derive streak boundaries from plain dates yourself.

## Steps
1. Run `26_gaps_and_islands.sql`.
2. Work through it section by section against your own Snowflake trial
   — don't just read it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `26_gaps_and_islands.sql` — three questions tracing
the date-minus-row-number trick by hand, counting Bob's islands, and
generalizing the technique to a numeric column.
