# Task 2 — Generate huge data with SQL alone

## Goal
Synthesize millions of rows entirely inside Snowflake — no CSV, no
upload, no external cloud — using `GENERATOR()` and `SEQ4()`. This is
the pattern you'd actually use for load-testing or building fixtures
without shipping a giant file anywhere.

## Steps
1. Run `03_generate_huge_data.sql`.
2. Try changing `ROWCOUNT` up and down and watch how long the
   `CREATE TABLE AS SELECT` takes on your MEDIUM warehouse.
3. Do the two sanity-check queries at the top before touching the
   "going bigger" cross-join example — that one's there to be broken,
   not copied.

## Understanding check
See the bottom of `03_generate_huge_data.sql` — three questions, work
through them by actually running the diagnostic queries it points to,
not just reasoning about it in your head.
