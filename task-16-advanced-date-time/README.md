# Task 16 — Advanced date/time manipulation

**Category:** Advanced SQL

## Goal
Date truncation, date diffing, and business-day-aware date math.

**Real-world scenario:** Support asks "what's our average ticket
resolution time, in business days, not counting weekends?" Snowflake
has no built-in NETWORKDAYS-style function for that — you have to
build the business-day logic yourself, and the naive `DATEDIFF('day', ...)`
answer will overstate every ticket that happened to span a weekend.

## Steps
1. Run `17_advanced_date_time.sql`.
2. Work through it section by section against your own Snowflake trial
   — don't just read it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `17_advanced_date_time.sql` — three questions on
calendar-day vs. business-day counts, why DAYOFWEEKISO beats plain
DAYOFWEEK for this, and the risk of a hardcoded date-spine size.
