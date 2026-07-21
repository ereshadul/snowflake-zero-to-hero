# Task 64 — A repeatable data quality/validation framework

**Category:** Data Integrity & Quality

## Goal
Designing a repeatable validation/QC process around a load -- combining VALIDATION_MODE, post-load checks, and alerting into one pattern instead of ad hoc queries.

**Real-world scenario:** You've been running Task 1's sanity-check
queries by hand after every load. This task turns that habit into an
actual reusable system: a log table that remembers every check's
history, and a procedure that runs them all in one call.

## Steps
1. Run `65_data_quality_validation_framework.sql`.
2. Work through it section by section against your own Snowflake trial
   — don't just read it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `65_data_quality_validation_framework.sql` — three
questions confirming the checks catch Task 1's known bad data, the
value of a check-history log, and wiring in alerting/scheduling.
