-- ============================================================
-- Task 54 — Querying Parquet directly
-- Category: Semi-structured data
-- Needs an actual Parquet file to query. Task 58 covers UNLOADING to
-- Parquet properly, later -- for now we just need SOME parquet file
-- to practice reading, so we generate one quickly first.
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;
USE SCHEMA ADVANCED;

CREATE OR REPLACE FILE FORMAT PARQUET_FORMAT TYPE = PARQUET;

-- 1. Generate a small Parquet file from DEVICE_TAGS (Task 50) onto
--    the stage.
COPY INTO @RAW.IOT_STAGE/parquet_demo.parquet
FROM (SELECT device_id, tags FROM DEVICE_TAGS)
FILE_FORMAT = (TYPE = PARQUET)
OVERWRITE = TRUE
SINGLE = TRUE;

LIST @RAW.IOT_STAGE/parquet_demo.parquet;

-- 2. Query it DIRECTLY off the stage -- no table, no COPY INTO, no
--    load step at all.
SELECT
    $1:device_id::STRING AS device_id,
    $1:tags               AS tags
FROM @RAW.IOT_STAGE/parquet_demo.parquet (FILE_FORMAT => 'PARQUET_FORMAT');

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 55:
--
-- 1. Confirm step 2 returns the correct device_id/tags values without
--    ever loading anything into a table. Name a real use case for
--    querying a staged file directly like this instead of loading it
--    into a table first — think about a one-off "let me just peek at
--    what's in this file" situation versus a real pipeline.
--
-- 2. With a CSV file, columns come back through positional references
--    ($1, $2, $3...). Here, everything comes back through a SINGLE
--    $1, and you traverse INTO it with :device_id / :tags instead.
--    Why does that make sense given how Parquet actually stores its
--    schema — what does a Parquet file carry about its own columns
--    that a plain CSV file doesn't?
--
-- 3. This task needed Task 58's unload technique just to generate
--    something to read. Does that ordering (query-Parquet before
--    unload-to-Parquet) bother you conceptually, or does it make
--    sense that you need SOME file to practice reading before you'd
--    learn the full menu of unload options?
-- ============================================================
