-- ============================================================
-- Task 66 — Auto-ingest vs. manual refresh
-- Category: Snowpipe
-- Requires Tasks 5-6 already done: RAW.S3_IOT_STAGE and
-- S3_LAB_INTEGRATION must exist. This is the real event-driven
-- version Task 65's internal-stage pipe couldn't be.
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;

-- 1. A pipe on the S3 external stage, with AUTO_INGEST = TRUE.
CREATE OR REPLACE PIPE RAW.S3_AUTO_PIPE
    AUTO_INGEST = TRUE
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
    FROM @RAW.S3_IOT_STAGE
)
FILE_FORMAT = (FORMAT_NAME = RAW.IOT_CSV_FORMAT)
ON_ERROR = 'CONTINUE';

-- 2. Check notification_channel -- compare this to Task 65's
--    internal-stage pipe. This one should NOT be empty.
SHOW PIPES LIKE 'S3_AUTO_PIPE' IN SCHEMA RAW;

-- ------------------------------------------------------------
-- 3. NOW GO TO THE AWS CONSOLE (outside Snowflake):
--    S3 -> your bucket -> Properties -> Event notifications ->
--    Create event notification.
--      - Event types: All object create events
--      - Prefix: iot_lab/
--      - Destination: SQS queue -> paste in the notification_channel
--        ARN from step 2's SHOW PIPES output.
--    This is what actually wires "a file landed in S3" to "tell
--    Snowflake about it" -- Snowflake created the queue, but YOU
--    have to tell S3 to publish to it.
-- ------------------------------------------------------------

-- 4. Upload a NEW file directly to S3 -- via the AWS Console or AWS
--    CLI, NOT through Snowflake/Snowsight at all -- into the
--    iot_lab/ prefix. Then wait a minute or two (auto-ingest has
--    real latency, unlike REFRESH which processes immediately).

SELECT SYSTEM$PIPE_STATUS('RAW.S3_AUTO_PIPE');

SELECT COUNT(*) AS rows_via_auto_ingest
FROM RAW.SENSOR_READINGS_RAW;

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 67:
--
-- 1. Compare this pipe's notification_channel (step 2) to Task 65's
--    internal-stage pipe. What AWS resource type is that ARN, and
--    who actually created/owns it — you, or Snowflake itself?
--
-- 2. Auto-ingest has real latency (often somewhere around a minute,
--    sometimes more) between the file landing in S3 and the data
--    showing up in your table -- unlike ALTER PIPE REFRESH, which
--    processes as soon as you call it. Why might a real production
--    pipeline happily accept that latency in exchange for never
--    having to manually trigger anything?
--
-- 3. If the S3 event notification from step 3 got misconfigured or
--    accidentally deleted after everything was working, would the
--    pipe throw an error you'd notice, or would it just silently stop
--    receiving new files with no obvious signal anything's wrong?
--    What would you actually monitor to catch that failure mode?
-- ============================================================
