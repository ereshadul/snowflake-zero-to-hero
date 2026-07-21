# Task 15 — Advanced string and regex functions

**Category:** Advanced SQL

## Goal
REGEXP_SUBSTR, SPLIT, and pattern-based extraction instead of chained SUBSTRING/POSITION calls.

**Real-world scenario:** Someone hands you a table of raw application
log lines — one big unstructured string per row — and asks you to
"pull out the user, the status code, and the timestamp so we can
actually query this." Nobody gave you separate columns; you have to
carve them out of text yourself.

## Steps
1. Run `16_advanced_string_regex.sql`.
2. Work through it section by section against your own Snowflake trial
   — don't just read it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `16_advanced_string_regex.sql` — three questions on
group-capture vs. whole-match, what happens when a row doesn't match
at all, and when SPLIT_PART stops being enough.
