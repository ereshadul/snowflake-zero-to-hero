-- ============================================================
-- Task 65 — Pipe on internal stage
-- Category: Snowpipe
--
-- About this category: Tasks 65-68 cover continuous/event-driven
-- ingestion. True event-driven auto-ingest (Task 66) needs an
-- external stage (S3), which is why this first task deliberately
-- uses an internal stage instead -- to isolate what a PIPE object
-- itself is, before adding cloud event notifications into the mix.
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;

-- 1. A pipe wraps a COPY INTO statement -- same shape you've written
--    many times by hand, just wrapped in a long-lived object.
CREATE OR REPLACE PIPE RAW.SENSOR_PIPE
AS
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
    FROM @RAW.IOT_STAGE
)
FILE_FORMAT = (FORMAT_NAME = RAW.IOT_CSV_FORMAT)
ON_ERROR = 'CONTINUE';

-- 2. Confirm it exists, and check its notification_channel property.
SHOW PIPES LIKE 'SENSOR_PIPE' IN SCHEMA RAW;

-- 3. Upload task-38's fixture_clean.csv onto @RAW.IOT_STAGE again
--    (via Snowsight, or PUT from Task 34) if it isn't already there,
--    then manually trigger the pipe -- internal stages have no cloud
--    event source to trigger this automatically.
ALTER PIPE RAW.SENSOR_PIPE REFRESH;

-- 4. Check the pipe's own status and load history.
SELECT SYSTEM$PIPE_STATUS('RAW.SENSOR_PIPE');

SELECT COUNT(*) AS rows_via_pipe
FROM RAW.SENSOR_READINGS_RAW
WHERE ingest_batch_id = 'BATCH_CLEAN';

-- 5. Refresh again without adding any new file.
ALTER PIPE RAW.SENSOR_PIPE REFRESH;
SELECT COUNT(*) AS rows_via_pipe_after_second_refresh
FROM RAW.SENSOR_READINGS_RAW
WHERE ingest_batch_id = 'BATCH_CLEAN';

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 66:
--
-- 1. Look at the notification_channel column from step 2's SHOW
--    PIPES output. Is it populated with a real value, or empty/NULL?
--    Given Task 66 is specifically about auto-ingest via cloud
--    notifications, what does an empty notification_channel tell you
--    about whether THIS pipe (on an internal stage) can ever fire on
--    its own without ALTER PIPE REFRESH?
--
-- 2. Compare step 5's row count to step 3-4's. Did the second REFRESH
--    reload fixture_clean.csv's rows a second time, or did the count
--    stay the same? What does that tell you about whether a pipe
--    tracks which files it's already ingested, the same way a manual
--    COPY INTO does (recall Task 44's FORCE task)?
--
-- 3. A pipe is, structurally, just a COPY INTO statement with a name
--    and a trigger mechanism wrapped around it. What's the actual
--    functional difference between running that COPY INTO yourself
--    by hand once, versus wrapping it in a pipe and calling
--    ALTER PIPE REFRESH — for THIS internal-stage scenario
--    specifically, is there any practical benefit at all, or does the
--    real value only show up once auto-ingest (Task 66) enters the
--    picture?
-- ============================================================
