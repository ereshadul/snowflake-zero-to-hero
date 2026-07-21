# Task 93 — Clustering keys

**Category:** Performance & cost

## About this category — Performance & cost
Tasks 93-98 are about making queries faster and warehouses cheaper
with evidence, not guesswork — the same instinct behind the
SMALL-vs-MEDIUM tests you ran back in Task 2.

## Goal
Choosing a clustering key and reading clustering depth to judge if it's helping.

**⚠️ Cost note:** automatic reclustering costs real, ongoing credits.
This task demonstrates the syntax on a small throwaway table rather
than altering the real 50-million-row table, to avoid triggering
background reclustering costs on a trial account.

**Real-world scenario:** A query that filters `WHERE sensor_id = 'X'`
against a huge table scans every micro-partition unless rows for that
sensor are physically co-located — clustering is what makes that
co-location happen.

## Steps
1. Run `94_clustering_keys.sql`.
2. Work through it section by section against your own Snowflake trial
   — don't just read it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `94_clustering_keys.sql` — three questions on
reading clustering depth, why it doesn't improve instantly, and
deciding whether a table is even worth clustering.
