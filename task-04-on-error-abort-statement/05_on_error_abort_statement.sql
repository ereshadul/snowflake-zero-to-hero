-- ============================================================
-- Task 4 — ON_ERROR = ABORT_STATEMENT
-- Requires Task 1 already done: the stage @RAW.IOT_STAGE must still
-- have iot_sensor_readings.csv.gz sitting on it.
--
-- Task 1 deliberately landed everything as STRING/VARIANT so nothing
-- could fail to parse. This task asks: what if we HADN'T done that?
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;

-- 1. A strictly-typed table -- reading_value as FLOAT and
--    event_timestamp as TIMESTAMP_NTZ directly, no STRING landing
--    buffer this time.
CREATE OR REPLACE TABLE RAW.SENSOR_READINGS_STRICT (
    event_id             STRING,
    sensor_id            STRING,
    device_type          STRING,
    event_timestamp      TIMESTAMP_NTZ,
    ingested_at          TIMESTAMP_NTZ,
    reading_value        FLOAT,
    unit                 STRING,
    battery_pct          NUMBER(5,2),
    signal_strength_dbm  NUMBER(5,1),
    latitude             FLOAT,
    longitude            FLOAT,
    firmware_version     STRING,
    status_code          STRING,
    raw_payload          VARIANT,
    is_duplicate_of      STRING,
    ingest_batch_id      STRING
);

-- 2. Load the SAME file from Task 1 into this strict table.
--    ON_ERROR = 'ABORT_STATEMENT' is the default -- it's spelled out
--    here just to be explicit about what's being tested. The moment
--    Snowflake hits a row it can't cast into FLOAT/TIMESTAMP_NTZ,
--    the ENTIRE load aborts -- not just that row.
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
    FROM @RAW.IOT_STAGE/iot_sensor_readings.csv.gz
)
FILE_FORMAT = (FORMAT_NAME = RAW.IOT_CSV_FORMAT)
ON_ERROR = 'ABORT_STATEMENT';
-- Expect this to fail with an error message. That's the point --
-- read the error message before doing anything else.

-- 3. Check what actually landed.
SELECT COUNT(*) AS row_count FROM RAW.SENSOR_READINGS_STRICT;

-- 4. VALIDATE() again -- but this time for a failed load, not a
--    successful one. Compare this output to what you saw in Task 1.
SELECT * FROM TABLE(VALIDATE(RAW.SENSOR_READINGS_STRICT, JOB_ID => '_last'));

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 5:
--
-- 1. RAW.SENSOR_READINGS_RAW (Task 1) ended up with 2,000,000 rows
--    from this exact file. RAW.SENSOR_READINGS_STRICT should have
--    0. Same file, same COPY INTO shape -- why such a different
--    outcome? What single design choice caused it?
--
-- 2. Read the actual error text Snowflake returned in step 2. What
--    row number and column does it cite? Does it match one of the
--    two deliberately-injected corruption types from Task 1's
--    generator (bad reading_value, bad event_timestamp), or
--    something else entirely?
--
-- 3. In Task 1, VALIDATE(RAW.SENSOR_READINGS_RAW, JOB_ID => '_last')
--    came back EMPTY -- because nothing failed. Here, VALIDATE()
--    on RAW.SENSOR_READINGS_STRICT comes back with something --
--    because everything failed. Same function, opposite reason for
--    its result. What does that tell you about what VALIDATE()
--    actually reports: failures, or a full parse log regardless of
--    outcome?
-- ============================================================
