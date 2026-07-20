# Task 54 — Incremental load strategy

**Category:** Tasks, deeper

## Goal
Deciding between full-reload and incremental load, and the
watermarking approaches (timestamp-based, CDC-based via Streams) that
make incremental loading actually correct instead of silently
dropping or duplicating rows. Sits right after Streams+Tasks CDC
mechanics (Tasks 41-53) on purpose — this is the design-level question
those mechanics exist to answer.

## Steps
1. Run `55_incremental_load_strategy.sql`.
2. Work through it section by section against your own Snowflake trial
   — don't just read it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `55_incremental_load_strategy.sql`. Answer by
actually running the diagnostic queries it points to, not from
memory.

*(Status: scaffolded — SQL content not yet written.)*
