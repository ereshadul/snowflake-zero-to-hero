# Task 59 — Partitioned unload

**Category:** Unloading data

## Goal
Using PARTITION BY to fan a single unload out into a folder structure.

**Real-world scenario:** A downstream Spark job expects data organized
as `region=East/`, `region=West/` folders (Hive-style partitioning) —
one COPY INTO with PARTITION BY produces that layout directly, instead
of running a separate unload per region by hand.

## Steps
1. Run `60_unload_partitioned.sql`.
2. Work through it section by section against your own Snowflake trial
   — don't just read it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `60_unload_partitioned.sql` — three questions on
raw-column vs. Hive-style expression partitioning, what PARTITION BY
saves you from doing manually, and high-cardinality partition keys.
