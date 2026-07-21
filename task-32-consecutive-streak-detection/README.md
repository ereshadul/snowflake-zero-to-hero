# Task 32 — Consecutive/streak detection

**Category:** SQL Interview Practice

## Goal
Finding the longest run of consecutive days/values per group -- a direct application of the gaps-and-islands technique.

**Real-world scenario:** "What's each user's longest login streak?" —
the natural follow-up question once Task 25 already found every
streak; now you just need the biggest one, with its actual dates
attached, not just a number.

## Steps
1. Run `33_consecutive_streak_detection.sql`.
2. Work through it section by section against your own Snowflake trial
   — don't just read it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `33_consecutive_streak_detection.sql` — three
questions tracing Alice's islands by hand, why MAX()+GROUP BY loses
the streak's actual dates, and handling a tie for longest streak.
