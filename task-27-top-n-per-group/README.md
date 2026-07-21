# Task 27 — Top-N per group

**Category:** SQL Interview Practice

## Goal
The "top 3 per category" problem -- QUALIFY vs. window function vs. correlated subquery.

**Real-world scenario:** "Give me our top 2 highest scorers on each
team" sounds like an easy ask — until two players are exactly tied
for 2nd place, and the person asking hasn't decided whether they want
"exactly 2, pick one arbitrarily" or "everyone tied for that spot."

## Steps
1. Run `28_top_n_per_group.sql`.
2. Work through it section by section against your own Snowflake trial
   — don't just read it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `28_top_n_per_group.sql` — three questions comparing
ROW_NUMBER vs. RANK's row counts under ties, and which the correlated
subquery matches.
