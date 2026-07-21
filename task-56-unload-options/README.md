# Task 56 — Unload options (SINGLE/MAX_FILE_SIZE/HEADER/OVERWRITE)

**Category:** Unloading data

## Goal
Controlling file splitting, headers, and overwrite behavior on unload.

**Real-world scenario:** Task 55's unload left two open questions —
why did it produce more than one file for 8 rows, and why was there
no header row? A downstream tool needs exactly one CSV file with
column headers; this task is how you actually get that.

## Steps
1. Run `57_unload_options.sql`.
2. Work through it section by section against your own Snowflake trial
   — don't just read it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `57_unload_options.sql` — three questions on the
tradeoff of forcing SINGLE = TRUE, OVERWRITE's actual default, and
whether MAX_FILE_SIZE is an exact or approximate target.
