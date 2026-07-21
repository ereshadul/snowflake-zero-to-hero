# Task 24 — Running totals and cumulative sums

**Category:** SQL Interview Practice

## Goal
The most commonly asked window-function interview problem, plus the reset-per-group variant.

**Real-world scenario:** "Show me a running total of sales by region,
so I can see the trend build up day over day" — the single most
common window-function request there is. The twist interviewers love
to add: what happens when two sales land on the exact same day?

## Steps
1. Run `25_running_totals.sql`.
2. Work through it section by section against your own Snowflake trial
   — don't just read it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `25_running_totals.sql` — three questions
reconnecting to Task 9's RANGE vs. ROWS distinction, this time in the
running-total pattern where it actually matters most.
