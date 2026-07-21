# Task 55 — Unload to CSV

**Category:** Unloading data

## About this category — Unloading data
Tasks 55-59 are the mirror image of Loading & COPY (38-48): getting
data back OUT of Snowflake into files, whether for another system,
an archive, or a one-off export someone asked for.

## Goal
COPY INTO <location> to push a table/query result out to CSV.

**Real-world scenario:** A finance stakeholder wants "the raw
quarterly sales numbers as a CSV I can open in Excel" — the same
`COPY INTO` you know from loading, running in reverse.

## Steps
1. Run `56_unload_csv.sql`.
2. Work through it section by section against your own Snowflake trial
   — don't just read it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `56_unload_csv.sql` — three questions on why
unloading a tiny table still produces multiple files, unloading a
query vs. a table, and header rows.
