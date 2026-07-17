-- ============================================================
-- Task 1 — Bulk load the messy CSV
-- Run 01_setup_ddl.sql first. Then, in Snowsight:
--   Data » Add Data » Load files into a Stage
--   -> pick database IOT_LAB, schema RAW, stage IOT_STAGE
--   -> upload iot_sensor_readings.csv.gz (~121 MB, under Snowsight's
--      250MB upload limit — no CLI/SnowSQL needed, no external cloud)
-- (Don't have the file? Regenerate it: python3 gen_iot_data.py)
-- Then come back here and run the statements below in order.
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;

-- 1. Confirm the file actually landed on the stage
LIST @RAW.IOT_STAGE;

-- 2. Dry run — parses the file and reports errors WITHOUT loading
--    anything. This is where you'll see the malformed-timestamp and
--    bad reading_value rows get flagged.
COPY INTO RAW.SENSOR_READINGS_RAW
FROM @RAW.IOT_STAGE/iot_sensor_readings.csv.gz
FILE_FORMAT = (FORMAT_NAME = RAW.IOT_CSV_FORMAT)
VALIDATION_MODE = 'RETURN_ERRORS';

-- 3. Real load. ON_ERROR = 'CONTINUE' means bad rows are skipped
--    instead of failing the whole 2,000,000-row load.
COPY INTO RAW.SENSOR_READINGS_RAW (
    event_id, sensor_id, device_type, event_timestamp, ingested_at,
    reading_value, unit, battery_pct, signal_strength_dbm,
    latitude, longitude, firmware_version, status_code,
    raw_payload, is_duplicate_of, ingest_batch_id, _file_name
)
FROM (
    SELECT
        $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13,
        TRY_PARSE_JSON($14), $15, $16, METADATA$FILENAME
    FROM @RAW.IOT_STAGE/iot_sensor_readings.csv.gz
)
FILE_FORMAT = (FORMAT_NAME = RAW.IOT_CSV_FORMAT)
ON_ERROR = 'CONTINUE';

-- 4. Sanity checks after the load
SELECT COUNT(*) AS total_rows FROM RAW.SENSOR_READINGS_RAW;

SELECT COUNT(*) AS bad_reading_value
FROM RAW.SENSOR_READINGS_RAW
WHERE TRY_TO_DOUBLE(reading_value) IS NULL AND reading_value IS NOT NULL;

SELECT COUNT(*) AS bad_timestamp
FROM RAW.SENSOR_READINGS_RAW
WHERE TRY_TO_TIMESTAMP_NTZ(event_timestamp) IS NULL;

SELECT COUNT(*) AS flagged_duplicates
FROM RAW.SENSOR_READINGS_RAW
WHERE is_duplicate_of IS NOT NULL;

SELECT * FROM TABLE(VALIDATE(RAW.SENSOR_READINGS_RAW, JOB_ID => '_last'));
