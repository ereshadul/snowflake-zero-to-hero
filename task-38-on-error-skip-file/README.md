# Task 38 — ON_ERROR = SKIP_FILE

**Category:** Loading & COPY options

## About this category — Loading & COPY options
Tasks 38-48 go deep on `COPY INTO`'s options — the fine-grained
control over what happens when a file (or a row inside it) doesn't
load cleanly. Task 1 and Task 4 already showed the two extremes
(`CONTINUE` and `ABORT_STATEMENT`); this category is everything in
between and around them.

## Goal
Skipping an entire file the moment it hits an error, vs. skipping just the bad rows.

**Real-world scenario:** A vendor sends you a batch of files every
night. Most nights they're clean; occasionally one file in the batch
has a data quality problem. You don't want one bad file silently
corrupting your table with partial data, but you also don't want one
bad file to block the other, perfectly good files in the same batch.

**Setup:** two fixture files live in `fixtures/` — upload both
(`fixture_clean.csv`, `fixture_mixed.csv`) to `@RAW.IOT_STAGE` via
Snowsight before running the SQL below.

## Steps
1. Run `39_on_error_skip_file.sql`.
2. Work through it section by section against your own Snowflake trial
   — don't just read it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `39_on_error_skip_file.sql` — three questions on
what unit SKIP_FILE actually operates on, multi-file COPY behavior,
and contrasting with Task 4's ABORT_STATEMENT.
