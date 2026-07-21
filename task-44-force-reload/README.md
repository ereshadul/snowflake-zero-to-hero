# Task 44 — FORCE

**Category:** Loading & COPY options

## Goal
Reloading files Snowflake thinks it already loaded, and why that's normally a bad idea.

**Real-world scenario:** You re-run last night's load script by
accident (or on purpose, thinking a fix needs a re-run) — by default
Snowflake quietly skips files it already loaded, protecting you from
duplicating data. FORCE overrides that safety net, which is sometimes
genuinely what you want and sometimes exactly how duplicate rows get
into production.

**Setup:** requires Task 38's `fixture_clean.csv` on `@RAW.IOT_STAGE`.

## Steps
1. Run `45_force_reload.sql`.
2. Work through it section by section against your own Snowflake trial
   — don't just read it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `45_force_reload.sql` — three questions on what load
history actually tracks, whether FORCE creates duplicates, and when
you'd legitimately want it anyway.
