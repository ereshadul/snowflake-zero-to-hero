-- ============================================================
-- Task 38 — ON_ERROR = SKIP_FILE
-- Category: Loading & COPY options
--
-- Uses fixtures/fixture_clean.csv (10 valid rows) and
-- fixtures/fixture_mixed.csv (10 rows, 2 with a non-numeric
-- reading_value that fails a strict FLOAT cast). Upload both to
-- @RAW.IOT_STAGE via Snowsight before running this.
--
-- Targets RAW.SENSOR_READINGS_STRICT from Task 4 -- reused
-- specifically because strict typing is what turns "ERR" into a real
-- load error at all (the loose RAW.SENSOR_READINGS_RAW table would
-- swallow it silently as a plain string, with nothing to skip).
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;

-- Clear out whatever Task 4 left behind, for a clean before/after.
TRUNCATE TABLE RAW.SENSOR_READINGS_STRICT;

-- 1. SKIP_FILE — if a file has EVEN ONE error, drop the WHOLE file,
--    but keep processing any OTHER files in this same COPY call.
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
ON_ERROR = 'SKIP_FILE';

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
    FROM @RAW.IOT_STAGE/fixture_mixed.csv
)
FILE_FORMAT = (FORMAT_NAME = RAW.IOT_CSV_FORMAT)
ON_ERROR = 'SKIP_FILE';

-- 2. Check what actually made it in.
SELECT ingest_batch_id, COUNT(*) AS row_count
FROM RAW.SENSOR_READINGS_STRICT
GROUP BY ingest_batch_id;
-- Expect BATCH_CLEAN fully present (10 rows), BATCH_MIXED completely
-- absent (0 rows) -- not "8 good rows out of 10," ZERO.

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 39:
--
-- 1. fixture_mixed.csv has 8 perfectly good rows and only 2 bad ones.
--    Confirm the query in step 2 shows 0 rows for BATCH_MIXED, not 8.
--    What does that tell you about the actual unit SKIP_FILE operates
--    on — is it "skip individual bad rows" (like CONTINUE) or "skip
--    the entire file if it contains any bad row at all"?
--
-- 2. fixture_clean.csv loaded in full because it ran in a SEPARATE
--    COPY INTO statement from fixture_mixed.csv. What would have
--    happened to fixture_clean.csv's rows if BOTH files had been
--    loaded in a SINGLE COPY INTO call instead (e.g. via a PATTERN
--    matching both), given SKIP_FILE evaluates each file
--    independently? Would fixture_clean.csv's good rows still have
--    made it in?
--
-- 3. Compare SKIP_FILE's behavior here to Task 4's ABORT_STATEMENT
--    (the default). If fixture_mixed.csv had been loaded with
--    ABORT_STATEMENT instead of SKIP_FILE, and fixture_clean.csv had
--    already loaded successfully first in the SAME COPY session, would
--    fixture_clean.csv's already-loaded rows get rolled back too, or
--    does ABORT_STATEMENT only affect the file it's actively failing
--    on?
-- ============================================================
