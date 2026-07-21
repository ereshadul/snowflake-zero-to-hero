-- ============================================================
-- Task 46 — PURGE
-- Category: Loading & COPY options
--
-- Reuses fixtures/fixture_clean.csv (Task 38). FORCE = TRUE is added
-- here purely so this COPY actually reprocesses the file regardless
-- of load history (Task 44) -- PURGE only deletes files it actually
-- loaded in THIS call, not ones it skipped.
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;

-- 1. Confirm the file exists on the stage before touching anything.
LIST @RAW.IOT_STAGE/fixture_clean.csv;

TRUNCATE TABLE RAW.SENSOR_READINGS_STRICT;

-- 2. Load it with PURGE = TRUE.
COPY INTO RAW.SENSOR_READINGS_STRICT (
    event_id, sensor_id, device_type, event_timestamp, ingested_at,
    reading_value, unit, battery_pct, signal_strength_dbm,
    latitude, longitude, firmware_version, status_code,
    raw_payload, is_duplicate_of, ingest_batch_id
)
FROM (
    SELECT
        $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13,
        TRY_PARSE_JSON($14), $15, $16
    FROM @RAW.IOT_STAGE/fixture_clean.csv
)
FILE_FORMAT = (FORMAT_NAME = RAW.IOT_CSV_FORMAT)
ON_ERROR = 'CONTINUE'
FORCE = TRUE
PURGE = TRUE;

SELECT COUNT(*) AS rows_loaded FROM RAW.SENSOR_READINGS_STRICT;

-- 3. Check the stage again.
LIST @RAW.IOT_STAGE/fixture_clean.csv;
-- Compare this result to step 1's.

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 47:
--
-- 1. Confirm step 3's LIST returns nothing, while step 1's did. If
--    you needed to run this exact load again next week using the same
--    source data, what would you now have to do FIRST, given the
--    original file is gone from the stage?
--
-- 2. Every row from fixture_clean.csv loaded successfully in step 2.
--    What do you think would happen to the file if it had FAILED
--    entirely (e.g. under ON_ERROR='ABORT_STATEMENT' with a genuinely
--    bad row) — would PURGE still delete it, or does PURGE only
--    remove files that were actually, successfully processed? Reason
--    through why the answer basically has to be the latter, given
--    what PURGE is actually for.
--
-- 3. PURGE permanently deletes the file — no archive, no recycle bin,
--    nothing to undo it from the stage side. What's a real safeguard
--    you'd want in place BEFORE turning PURGE=TRUE on for a
--    production pipeline, in case you ever need to reprocess that
--    exact file again (hint: think about where else a copy of the
--    file could live besides the Snowflake stage).
-- ============================================================
