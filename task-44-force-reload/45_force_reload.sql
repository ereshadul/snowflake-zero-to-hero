-- ============================================================
-- Task 44 — FORCE
-- Category: Loading & COPY options
--
-- Reuses fixtures/fixture_clean.csv (Task 38). Snowflake tracks, per
-- table, which staged files it has already loaded (by file name +
-- checksum) for roughly 64 days, and silently skips them on a repeat
-- COPY INTO -- unless you override that with FORCE.
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;
TRUNCATE TABLE RAW.SENSOR_READINGS_STRICT;

-- 1. First load — this genuinely loads the 10 rows.
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
ON_ERROR = 'CONTINUE';

SELECT COUNT(*) AS after_first_load FROM RAW.SENSOR_READINGS_STRICT;
-- Expect 10.

-- 2. Run the EXACT same COPY INTO again, no changes at all.
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
ON_ERROR = 'CONTINUE';
-- Read the result grid closely -- does it say rows were loaded, or
-- does it report the file as already loaded / skipped?

SELECT COUNT(*) AS after_second_attempt FROM RAW.SENSOR_READINGS_STRICT;
-- Compare to step 1's count.

-- 3. Now FORCE it — reload the same file regardless of load history.
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
FORCE = TRUE;

SELECT COUNT(*) AS after_force FROM RAW.SENSOR_READINGS_STRICT;
-- Compare to step 1's count again -- what happened to the 10 rows
-- from the first load?

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 45:
--
-- 1. Compare after_first_load and after_second_attempt. Did the
--    second, unchanged COPY INTO add any new rows? What does
--    Snowflake actually track to know this file was already loaded --
--    is it purely the file NAME, or something else that would change
--    if the file's content changed even slightly?
--
-- 2. Compare after_second_attempt to after_force. FORCE = TRUE
--    reloaded the file — did the table end up with 10 rows (replacing
--    the original 10) or 20 rows (the original 10, plus 10 more
--    duplicates)? What does that confirm about what FORCE actually
--    bypasses — load-history checking, or duplicate-row prevention at
--    the table level?
--
-- 3. Give a real, legitimate reason you'd actually want FORCE = TRUE
--    in a production pipeline, despite the duplicate-row risk it
--    creates. What would you need to do ALONGSIDE using FORCE to make
--    that reload safe (hint: think about what you'd need to clean up
--    either before or after the forced reload).
-- ============================================================
