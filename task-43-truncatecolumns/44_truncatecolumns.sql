-- ============================================================
-- Task 43 — TRUNCATECOLUMNS
-- Category: Loading & COPY options
--
-- Row m8 in fixtures/fixture_mixed.csv (Task 38) has a firmware_version
-- value that's deliberately way too long -- this task needs a NEW
-- table with a genuinely narrow VARCHAR to actually trigger the
-- overflow (Task 4's SENSOR_READINGS_STRICT uses unlimited STRING,
-- which would never overflow no matter how long the value is).
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;
USE SCHEMA ADVANCED;

CREATE OR REPLACE TABLE TRUNCATE_TEST (
    event_id         STRING,
    firmware_version VARCHAR(10)   -- genuinely narrow, on purpose
);

-- 1. Default behavior (TRUNCATECOLUMNS = FALSE) — an oversized value
--    should error the load.
COPY INTO TRUNCATE_TEST (event_id, firmware_version)
FROM (SELECT $1, $12 FROM @RAW.IOT_STAGE/fixture_mixed.csv)
FILE_FORMAT = (FORMAT_NAME = RAW.IOT_CSV_FORMAT)
ON_ERROR = 'CONTINUE';

SELECT * FROM TRUNCATE_TEST;
-- Notice which event_ids made it in, and which one (m8) is missing.

TRUNCATE TABLE TRUNCATE_TEST;

-- 2. TRUNCATECOLUMNS = TRUE — the same oversized value now loads,
--    silently cut down to fit VARCHAR(10).
COPY INTO TRUNCATE_TEST (event_id, firmware_version)
FROM (SELECT $1, $12 FROM @RAW.IOT_STAGE/fixture_mixed.csv)
FILE_FORMAT = (FORMAT_NAME = RAW.IOT_CSV_FORMAT)
ON_ERROR = 'CONTINUE'
TRUNCATECOLUMNS = TRUE;

SELECT * FROM TRUNCATE_TEST WHERE event_id = 'm8';
-- Look at exactly what firmware_version shows for m8 now.

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 44:
--
-- 1. In step 1, is row m8 present or missing from TRUNCATE_TEST? Given
--    ON_ERROR = 'CONTINUE' was set the whole time, does that setting
--    change how the oversized-column problem gets handled, or is
--    TRUNCATECOLUMNS a completely separate switch from ON_ERROR?
--
-- 2. In step 2, what does m8's firmware_version actually show — the
--    first 10 characters of the original value, or something else?
--    Count the characters to confirm it's exactly 10.
--
-- 3. TRUNCATECOLUMNS silently discards data (everything past
--    character 10, gone with no error, no warning row in the load
--    result). Describe a real situation where that silent data loss
--    could cause a genuinely bad outcome downstream — something worse
--    than just "the value looks a bit short."
-- ============================================================
