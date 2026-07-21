# Task 85 — Zero-copy clone (table)

**Category:** Time Travel & cloning

## Goal
Cloning a table instantly without copying storage.

**Real-world scenario:** A data scientist wants "a full copy of the
50-million-row production table to experiment on freely, without
touching prod" — and needs it in seconds, not however long copying
50 million rows would normally take.

## Steps
1. Requires Task 2/3's CURATED.SENSOR_READINGS_SYNTHETIC to exist.
2. Run `86_zero_copy_clone_table.sql`. **Drop the clone at the end** —
   it's a real 50M-row table once it diverges.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `86_zero_copy_clone_table.sql` — three questions on
why CLONE is so much faster than a real copy, the storage mechanism
that makes it possible, and whether dropping the clone is instant.
