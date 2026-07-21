# Task 96 — Warehouse scaling up vs. out

**Category:** Performance & cost

## Goal
Bigger warehouse (scale up) vs. multi-cluster (scale out) for different bottlenecks.

**Real-world scenario:** Dozens of analysts hit the same warehouse
every morning and their queries start queuing behind each other — a
BIGGER warehouse won't fix that (each individual query might already
be fast), but MORE clusters of the same size will, since the real
problem is concurrency, not per-query speed.

## Steps
1. Run `97_warehouse_scaling.sql`.
2. Work through it section by section against your own Snowflake trial
   — don't just read it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `97_warehouse_scaling.sql` — three questions on
spotting queuing in load history, when a 2nd/3rd cluster actually
spins up, and why scale-out wouldn't have helped Task 2's single query.
