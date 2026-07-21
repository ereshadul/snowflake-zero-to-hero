-- ============================================================
-- Task 67 — Monitoring (PIPE_STATUS, SYSTEM$PIPE_STATUS)
-- Category: Snowpipe
-- Reuses RAW.SENSOR_PIPE (Task 65).
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;

-- 1. SYSTEM$PIPE_STATUS returns JSON as a STRING -- PARSE_JSON it to
--    actually navigate specific fields instead of eyeballing raw text.
SELECT SYSTEM$PIPE_STATUS('RAW.SENSOR_PIPE');

SELECT
    PARSE_JSON(SYSTEM$PIPE_STATUS('RAW.SENSOR_PIPE')):executionState::STRING     AS execution_state,
    PARSE_JSON(SYSTEM$PIPE_STATUS('RAW.SENSOR_PIPE')):pendingFileCount::INT      AS pending_files,
    PARSE_JSON(SYSTEM$PIPE_STATUS('RAW.SENSOR_PIPE')):notificationChannelName::STRING AS notification_channel;

-- 2. Historical credit/file-count usage for this specific pipe.
SELECT *
FROM TABLE(INFORMATION_SCHEMA.PIPE_USAGE_HISTORY(
    DATE_RANGE_START => DATEADD('day', -7, CURRENT_TIMESTAMP()),
    PIPE_NAME        => 'RAW.SENSOR_PIPE'
));

-- 3. Per-FILE load results and errors, for the table this pipe loads
--    into -- filtered to show only pipe-driven loads, not manual ones.
SELECT *
FROM TABLE(INFORMATION_SCHEMA.COPY_HISTORY(
    TABLE_NAME => 'RAW.SENSOR_READINGS_RAW',
    START_TIME => DATEADD('day', -7, CURRENT_TIMESTAMP())
))
WHERE PIPE_NAME IS NOT NULL
ORDER BY LAST_LOAD_TIME DESC;

-- 4. Pause and resume a pipe -- e.g. if it's repeatedly choking on a
--    bad file and you need to stop it from retrying while you fix
--    the upstream problem.
ALTER PIPE RAW.SENSOR_PIPE SET PIPE_EXECUTION_PAUSED = TRUE;
SELECT PARSE_JSON(SYSTEM$PIPE_STATUS('RAW.SENSOR_PIPE')):executionState::STRING AS execution_state;

ALTER PIPE RAW.SENSOR_PIPE SET PIPE_EXECUTION_PAUSED = FALSE;
SELECT PARSE_JSON(SYSTEM$PIPE_STATUS('RAW.SENSOR_PIPE')):executionState::STRING AS execution_state;

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 68:
--
-- 1. Confirm execution_state actually changes to reflect the paused
--    state after step 4's first ALTER PIPE, then back after the
--    second. What exact string values does executionState show for
--    each? Look up what OTHER execution states are documented besides
--    the ones you saw directly.
--
-- 2. PIPE_USAGE_HISTORY (step 2) and COPY_HISTORY (step 3) both give
--    you information about the same pipe. What's the actual
--    difference in what each reports — one is about credits/file
--    counts over time, the other is about individual file-level
--    success/failure. Which one would you check first if someone
--    asked "did file X actually load, and if not, why"?
--
-- 3. Imagine a pipe repeatedly failing on the same malformed file
--    every time auto-ingest retries it. What does pausing the pipe
--    (step 4) actually accomplish in that scenario? What would you
--    need to do to the offending file BEFORE resuming the pipe, to
--    stop it from just failing on that same file again immediately?
-- ============================================================
