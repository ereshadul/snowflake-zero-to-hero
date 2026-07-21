# Task 48 — Transforming data mid-COPY

**Category:** Loading & COPY options

## Goal
Using a SELECT inside COPY INTO to reshape columns during the load instead of after.

**Real-world scenario:** You'd rather land data already cleaned up
(rounded, normalized case, a combined label field) than load it raw
and run a second transformation pass afterward — one less step, one
less intermediate table.

## Steps
1. Run `49_transform_during_copy.sql`.
2. Work through it section by section against your own Snowflake trial
   — don't just read it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `49_transform_during_copy.sql` — three questions on
inline vs. post-load transformation, defensive TRY_ casting, and a
real limitation of transforming during COPY.
