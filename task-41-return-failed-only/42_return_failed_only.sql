-- ============================================================
-- Task 41 — RETURN_FAILED_ONLY
-- Category: Loading & COPY options
--
-- Loads BOTH fixture files (Task 38) in a SINGLE COPY INTO call via
-- PATTERN, so the result set naturally has one row per file --
-- exactly what RETURN_FAILED_ONLY then filters.
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;
TRUNCATE TABLE RAW.SENSOR_READINGS_STRICT;

-- 1. Default behavior — one result row per file, success AND failure.
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
    FROM @RAW.IOT_STAGE
)
PATTERN = 'fixture_.*[.]csv'
FILE_FORMAT = (FORMAT_NAME = RAW.IOT_CSV_FORMAT)
ON_ERROR = 'CONTINUE';
-- Look at the result grid: one row for fixture_clean.csv (status
-- LOADED, 0 errors), one row for fixture_mixed.csv (status
-- LOADED, 2 errors).

TRUNCATE TABLE RAW.SENSOR_READINGS_STRICT;

-- 2. Same load, RETURN_FAILED_ONLY = TRUE this time.
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
    FROM @RAW.IOT_STAGE
)
PATTERN = 'fixture_.*[.]csv'
FILE_FORMAT = (FORMAT_NAME = RAW.IOT_CSV_FORMAT)
ON_ERROR = 'CONTINUE'
RETURN_FAILED_ONLY = TRUE;
-- Compare this result grid's ROW COUNT to step 1's.

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 42:
--
-- 1. How many rows does step 1's result grid have, vs. step 2's?
--    Which specific file (by name) disappears from the output in
--    step 2, and why that one specifically?
--
-- 2. RETURN_FAILED_ONLY changes what the COPY INTO STATEMENT'S OWN
--    RESULT shows you. Does it change how many rows actually landed
--    in RAW.SENSOR_READINGS_STRICT at all? Confirm with a COUNT(*)
--    after step 2 — should it be identical to step 1's post-load
--    count.
--
-- 3. In a real pipeline that loads hundreds of files a day and only
--    2 or 3 typically have any issues, why would RETURN_FAILED_ONLY
--    matter for something like an automated Slack/email alert built
--    on top of the COPY INTO result — what would the alert look like
--    without it, versus with it?
-- ============================================================
