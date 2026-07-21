# Task 42 — SIZE_LIMIT

**Category:** Loading & COPY options

## Goal
Capping how much data a single COPY INTO will ingest in one call.

**Real-world scenario:** An upstream system that's supposed to send a
small daily file occasionally dumps something 100x larger by mistake.
SIZE_LIMIT lets a scheduled load cap itself rather than accidentally
ingesting (and paying compute for) a runaway file in one shot.

**Setup:** requires Task 38's two fixture files, plus Task 1's
`iot_sensor_readings_SAMPLE.csv`, all on `@RAW.IOT_STAGE`.

## Steps
1. Run `43_size_limit.sql`.
2. Work through it section by section against your own Snowflake trial
   — don't just read it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `43_size_limit.sql` — three questions on how many
files actually loaded, whole-file vs. row-level granularity, and a
real reason to cap ingest size.
