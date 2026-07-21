# Task 29 — Median and percentile calculation

**Category:** SQL Interview Practice

## Goal
MEDIAN, PERCENTILE_CONT, and PERCENTILE_DISC -- and why they can disagree.

**Real-world scenario:** HR asks for "the median salary" — a
seemingly unambiguous request until your headcount is an even number
and the "middle" falls between two people. Do you report an
interpolated number that no one actually earns, or an actual salary
someone on the team really has?

## Steps
1. Run `30_median_percentile.sql`.
2. Work through it section by section against your own Snowflake trial
   — don't just read it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `30_median_percentile.sql` — three questions on
where CONT and DISC disagree, which one MEDIAN() actually is, and when
you'd deliberately want DISC's "real value" guarantee.
