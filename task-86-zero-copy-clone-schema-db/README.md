# Task 86 — Zero-copy clone (schema/database)

**Category:** Time Travel & cloning

## Goal
Cloning at the schema/database level, e.g. for a full env snapshot.

**Real-world scenario:** Before a risky migration, you want a
complete, instant snapshot of an entire environment — every table,
view, and stream — so you can roll back to it if anything goes wrong,
without a lengthy backup/restore process.

## Steps
1. Run `87_zero_copy_clone_schema_db.sql`. Clean up both clones at the
   end.
2. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `87_zero_copy_clone_schema_db.sql` — three questions
on whether a stream's consumption state survives cloning, database-
vs. schema-level cloning use cases, and what happens to a running task.
