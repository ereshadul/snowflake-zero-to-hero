# Task 11 — PIVOT and UNPIVOT

**Category:** Advanced SQL

## Goal
Turning row values into columns and back, natively, without hand-rolled CASE statements.

**Real-world scenario:** Finance sends you a spreadsheet with one row
per region per quarter and asks for "the version where each quarter
is its own column, like our normal reports" — that's PIVOT. A
different week, someone hands you a wide spreadsheet (one column per
quarter) and asks you to load it into a table shaped one-row-per-
quarter instead, because that's what the BI tool expects — that's
UNPIVOT, the exact reverse problem.

## Steps
1. Run `12_pivot_unpivot.sql`.
2. Work through it section by section against your own Snowflake trial
   — don't just read it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `12_pivot_unpivot.sql` — three questions on what
PIVOT does with duplicate rows, UNPIVOT's default NULL handling, and
how this compares to Task 31's manual CASE-based pivot.
