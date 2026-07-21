-- ============================================================
-- Task 40 — ON_ERROR = SKIP_FILE_<percent>%
-- Category: Loading & COPY options
--
-- Reuses fixtures/fixture_mixed.csv (Task 38): 2 bad rows out of 10
-- total = a known, exact 20% error rate.
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;

TRUNCATE TABLE RAW.SENSOR_READINGS_STRICT;

-- 1. SKIP_FILE_10% — tolerance is 10%, actual error rate is 20%.
--    Exceeds tolerance -> whole file skipped.
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
ON_ERROR = 'SKIP_FILE_10%';

SELECT COUNT(*) AS rows_after_10pct_tolerance FROM RAW.SENSOR_READINGS_STRICT;
-- Expect 0.

TRUNCATE TABLE RAW.SENSOR_READINGS_STRICT;

-- 2. SKIP_FILE_30% — tolerance is 30%, actual error rate (20%) is
--    within it -> file loads, bad rows dropped like CONTINUE.
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
ON_ERROR = 'SKIP_FILE_30%';

SELECT COUNT(*) AS rows_after_30pct_tolerance FROM RAW.SENSOR_READINGS_STRICT;
-- Expect 8.

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 41:
--
-- 1. fixture_mixed.csv's error rate is fixed at 20% (2 of 10 rows).
--    Confirm the exact cutoff behavior: does SKIP_FILE_20% (tolerance
--    exactly equal to the actual rate) load the file or skip it? Test
--    it and report whether the threshold is inclusive (">=" skips) or
--    exclusive ("> skips").
--
-- 2. SKIP_FILE_<num> (Task 39) uses an absolute count; SKIP_FILE_<pct>%
--    uses a proportion. For a file with exactly 10 rows, these can be
--    tuned to behave identically (e.g. SKIP_FILE_2 and SKIP_FILE_20%
--    both allow exactly 2 bad rows here). What changes between them
--    once file SIZE varies -- would SKIP_FILE_2 and SKIP_FILE_20%
--    still agree on a 1,000-row file with 20 bad rows?
--
-- 3. Give a concrete reason you'd prefer the percentage form over the
--    absolute-count form in a real pipeline where incoming file sizes
--    vary a lot from batch to batch (some files 100 rows, some
--    1 million).
-- ============================================================
