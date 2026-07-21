-- ============================================================
-- Task 45 — PATTERN
-- Category: Loading & COPY options
--
-- @RAW.IOT_STAGE has several files sitting on it by now: Task 1's
-- iot_sensor_readings.csv.gz and iot_sensor_readings_SAMPLE.csv, plus
-- Task 38's fixture_clean.csv and fixture_mixed.csv. PATTERN lets you
-- select a subset by regex instead of loading everything at once.
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;

-- 1. See everything currently on the stage first.
LIST @RAW.IOT_STAGE;

TRUNCATE TABLE RAW.SENSOR_READINGS_STRICT;

-- 2. PATTERN matching only the two fixture_* files, explicitly
--    excluding Task 1's files even though they're in the same stage.
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

SELECT ingest_batch_id, COUNT(*) FROM RAW.SENSOR_READINGS_STRICT GROUP BY ingest_batch_id;
-- Confirm ONLY the fixture batches show up, nothing from Task 1.

TRUNCATE TABLE RAW.SENSOR_READINGS_STRICT;

-- 3. A narrower pattern -- only fixture_clean specifically, not
--    fixture_mixed, using an anchored regex.
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
PATTERN = '.*fixture_clean[.]csv$'
FILE_FORMAT = (FORMAT_NAME = RAW.IOT_CSV_FORMAT)
ON_ERROR = 'CONTINUE';

SELECT ingest_batch_id, COUNT(*) FROM RAW.SENSOR_READINGS_STRICT GROUP BY ingest_batch_id;
-- Confirm ONLY BATCH_CLEAN shows up this time -- not BATCH_MIXED.

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 46:
--
-- 1. Step 2's pattern 'fixture_.*[.]csv' has no anchors (^ or $).
--    Would it also match a hypothetical file named
--    'my_fixture_data.csv.backup'? Reason through what the regex
--    actually requires versus what it doesn't, then decide.
--
-- 2. Step 3 tightened the pattern to exclude fixture_mixed.csv while
--    still matching fixture_clean.csv. What specific part of the
--    regex is doing that exclusion — is PATTERN matching the FULL
--    staged file path, or just the file's base name? Check the LIST
--    output from step 1 to see what the full path actually looks
--    like, and reason from there.
--
-- 3. PATTERN is evaluated against every file in the stage location on
--    every COPY INTO call, including files that already loaded and
--    are sitting in load history. Combined with what you learned in
--    Task 44 about load history — does PATTERN change WHICH files get
--    re-checked against load history, or does it just narrow what's
--    considered from the whole stage before that check even happens?
-- ============================================================
