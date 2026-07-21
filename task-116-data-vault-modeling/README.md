# Task 116 — Data Vault modeling

**Category:** Ecosystem & Modeling

## Goal
Hubs, links, and satellites applied to a small Snowflake schema, as an
alternative to Task 115's star schema for a source system that keeps
changing shape.

**Real-world scenario:** A new relationship type (sensor-to-technician,
say) needs to be added without touching any existing table. Data
Vault's Hub/Link/Satellite split makes that an additive change — a new
Link table — instead of a schema migration on something already in
production.

## Steps
1. Run `117_data_vault_modeling.sql`.
2. Work through it section by section against your own Snowflake trial
   — don't just read it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `117_data_vault_modeling.sql` — three questions on
adding new relationships without altering existing tables, Data
Vault's built-in history vs. dbt snapshots, and what a team is actually
optimizing for when they accept more joins.
