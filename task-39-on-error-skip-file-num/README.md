# Task 39 — ON_ERROR = SKIP_FILE_<num>

**Category:** Loading & COPY options

## Goal
Tolerating up to N bad rows per file before Snowflake gives up on that file.

**Real-world scenario:** A vendor's files always have a handful of
malformed rows — a known, tolerable amount of noise — but if a file
shows up mostly broken, you want it rejected outright instead of
silently loading a near-empty result.

**Setup:** requires Task 38's `fixture_mixed.csv` already sitting on
`@RAW.IOT_STAGE`.

## Steps
1. Run `40_on_error_skip_file_num.sql`.
2. Work through it section by section against your own Snowflake trial
   — don't just read it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `40_on_error_skip_file_num.sql` — three questions on
the threshold comparison, how this diverges from CONTINUE, and
choosing a sensible number instead of guessing.
