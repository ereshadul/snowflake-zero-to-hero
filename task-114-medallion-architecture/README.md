# Task 114 — Medallion Architecture

**Category:** Ecosystem & Modeling

## Goal
Designing a Bronze/Silver/Gold layered pipeline — what belongs in each
layer, why the boundaries exist, and how it maps onto what you've
already built (Task 1's raw landing table is a Bronze layer; the
cleansed `CURATED` tables are Silver; an aggregated reporting table
would be Gold).

**Real-world scenario:** A new hire asks "why do we have three copies
of basically the same sensor data?" The answer is that each layer
serves a different consumer — Bronze is a faithful raw archive for
replay, Silver is a clean general-purpose table for analysts, Gold is
a purpose-built aggregation for one dashboard.

## Steps
1. Run `115_medallion_architecture.sql`.
2. Work through it section by section against your own Snowflake trial
   — don't just read it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `115_medallion_architecture.sql` — three questions on
why Bronze keeps garbage rows Silver drops, how many Gold tables a
mature architecture actually has, and Gold tables vs. materialized
views.
