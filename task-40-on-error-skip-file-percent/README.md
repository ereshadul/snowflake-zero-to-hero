# Task 40 — ON_ERROR = SKIP_FILE_<percent>%

**Category:** Loading & COPY options

## Goal
Tolerating a percentage of bad rows per file instead of a fixed count.

**Real-world scenario:** Your incoming file sizes vary wildly — some
batches are 100 rows, some are a million. A fixed "tolerate 5 bad
rows" threshold (Task 39) makes no sense across that range; a
percentage does.

**Setup:** requires Task 38's `fixture_mixed.csv` on `@RAW.IOT_STAGE`.

## Steps
1. Run `41_on_error_skip_file_percent.sql`.
2. Work through it section by section against your own Snowflake trial
   — don't just read it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `41_on_error_skip_file_percent.sql` — three
questions on the exact cutoff boundary, comparing to the absolute-count
form, and when percentage genuinely beats a fixed count.
