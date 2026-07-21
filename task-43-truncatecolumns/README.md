# Task 43 — TRUNCATECOLUMNS

**Category:** Loading & COPY options

## Goal
Silently truncating oversized string values instead of erroring the load.

**Real-world scenario:** A source system occasionally sends a firmware
version string longer than your column was ever designed to hold.
Should the whole row fail because of one oversized field, or should it
load with the value quietly cut down to fit? TRUNCATECOLUMNS picks the
second option — with real data-loss consequences worth understanding
before flipping it on.

**Setup:** requires Task 38's `fixture_mixed.csv` on `@RAW.IOT_STAGE`.

## Steps
1. Run `44_truncatecolumns.sql`.
2. Work through it section by section against your own Snowflake trial
   — don't just read it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `44_truncatecolumns.sql` — three questions on
whether this depends on ON_ERROR, exactly what the truncated value
looks like, and a real downstream risk of silent truncation.
