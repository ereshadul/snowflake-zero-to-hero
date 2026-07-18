# Task 4 — ON_ERROR = ABORT_STATEMENT

**Category:** Loading & COPY options

## Goal
How ABORT_STATEMENT halts the whole COPY on the first bad row, and when you'd actually want that over a more forgiving mode.

## Steps
1. Requires Task 1 already done — `@RAW.IOT_STAGE` needs
   `iot_sensor_readings.csv.gz` still sitting on it.
2. Run `05_on_error_abort_statement.sql`. Step 2 in it is *expected*
   to throw an error — read the error message before moving on, don't
   just retry it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `05_on_error_abort_statement.sql` — three questions
comparing this load's outcome to Task 1's, using the actual error
message and `VALIDATE()` output you get back.
