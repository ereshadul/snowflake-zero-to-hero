# Task 120 — Semantic layer & "Talk to Data"

**Category:** Ecosystem & Modeling

## Goal
Building a semantic model so Cortex Analyst can answer
natural-language questions over your data directly — the layer that
turns the star schema from Task 115 into something a non-SQL user can
query in plain English.

**Real-world scenario:** A business stakeholder wants to ask "what's
the average battery percentage by device type?" without waiting on an
analyst to write the JOIN. A semantic model describing the star
schema's tables, columns, and synonyms is what lets Cortex Analyst
translate that into real SQL correctly.

## Steps
1. Run `121_semantic_layer_talk_to_data.sql`.
2. Work through it section by section against your own Snowflake trial
   — don't just read it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `121_semantic_layer_talk_to_data.sql` — three
questions on what the semantic model gives Cortex Analyst that raw
table names don't, synonym coverage, and why a clean star schema makes
this layer easier to build.
