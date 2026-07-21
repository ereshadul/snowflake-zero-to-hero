# Task 100 — Hybrid Tables

**Category:** Newer table types

## Goal
Row-oriented, OLTP-style tables with enforced primary keys and fast point lookups.

**Real-world scenario:** An application needs to look up a single
device's metadata by ID, thousands of times a second, right next to
the big analytical tables in the same Snowflake account. A Hybrid
Table is built for exactly that access pattern — fast single-row
reads/writes with an actually-enforced primary key — instead of the
big-scan pattern standard tables are optimized for.

**Note:** Hybrid Tables can require account enrollment on some trial
accounts. If `CREATE HYBRID TABLE` errors, read through the SQL and
understanding check anyway — the concepts still apply.

## Steps
1. Run `101_hybrid_tables.sql`.
2. Work through it section by section against your own Snowflake trial
   — don't just read it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `101_hybrid_tables.sql` — three questions on enforced
vs. documented constraints, why Hybrid Tables aren't a fit for big
analytical scans, and mixing table types in one architecture.
