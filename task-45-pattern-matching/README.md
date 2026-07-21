# Task 45 — PATTERN

**Category:** Loading & COPY options

## Goal
Loading only a subset of staged files by regex instead of everything in the stage.

**Real-world scenario:** Multiple upstream systems dump files into the
same stage/folder, but a given pipeline should only ever pick up its
own files — PATTERN filters the stage down to just the files that
actually belong to this load.

**Setup:** requires Task 38's two fixture files still on `@RAW.IOT_STAGE`
alongside Task 1's files.

## Steps
1. Run `46_pattern_matching.sql`.
2. Work through it section by section against your own Snowflake trial
   — don't just read it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `46_pattern_matching.sql` — three questions on
unanchored regex matching, whether PATTERN matches the full path or
just the filename, and its interaction with load history.
