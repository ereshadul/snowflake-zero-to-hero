-- ============================================================
-- Task 42 — SIZE_LIMIT
-- Category: Loading & COPY options
--
-- Uses three small files already on @RAW.IOT_STAGE: Task 38's
-- fixture_clean.csv and fixture_mixed.csv, plus Task 1's
-- iot_sensor_readings_SAMPLE.csv (much bigger, ~44KB). SIZE_LIMIT
-- operates at WHOLE-FILE granularity -- it always loads at least one
-- complete file, then stops picking up additional files once the
-- cumulative size would exceed the limit.
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;
TRUNCATE TABLE RAW.SENSOR_READINGS_STRICT;

-- 1. No SIZE_LIMIT — baseline, all three files load.
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
PATTERN = '(fixture_.*[.]csv)|(iot_sensor_readings_SAMPLE[.]csv)'
FILE_FORMAT = (FORMAT_NAME = RAW.IOT_CSV_FORMAT)
ON_ERROR = 'CONTINUE';

SELECT ingest_batch_id, COUNT(*) FROM RAW.SENSOR_READINGS_STRICT GROUP BY ingest_batch_id;
-- Note which batch_ids/files show up, and roughly how many rows total.

TRUNCATE TABLE RAW.SENSOR_READINGS_STRICT;

-- 2. SIZE_LIMIT = 2000 bytes — smaller than the two fixture files
--    combined but much smaller than the SAMPLE file alone.
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
PATTERN = '(fixture_.*[.]csv)|(iot_sensor_readings_SAMPLE[.]csv)'
FILE_FORMAT = (FORMAT_NAME = RAW.IOT_CSV_FORMAT)
ON_ERROR = 'CONTINUE'
SIZE_LIMIT = 2000;

SELECT ingest_batch_id, COUNT(*) FROM RAW.SENSOR_READINGS_STRICT GROUP BY ingest_batch_id;
-- Compare to step 1 -- how many files actually got loaded this time?

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 43:
--
-- 1. In step 2, how many of the three files actually loaded? Was it
--    zero, one, or more than one? Given SIZE_LIMIT always loads AT
--    LEAST one whole file before checking the limit, does that match
--    what you observed?
--
-- 2. SIZE_LIMIT stopped BEFORE loading the large SAMPLE file (or
--    stopped after it, if that's the one that happened to load
--    first) rather than loading PART of it. What does "operates at
--    whole-file granularity" mean concretely, in contrast to
--    SKIP_FILE_<num> (Task 39), which operates at the ROW level
--    within a single file?
--
-- 3. Give a real scenario where capping a COPY INTO call's total
--    ingested size is actually useful — think about what problem it
--    would prevent in a pipeline that's supposed to load a modest
--    daily batch, but where an upstream mistake occasionally dumps a
--    much bigger file than expected into the stage.
-- ============================================================
