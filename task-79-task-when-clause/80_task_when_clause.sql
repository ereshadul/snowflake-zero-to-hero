-- ============================================================
-- Task 79 — WHEN clause
-- Category: Tasks, deeper
-- Goes past the single-stream WHEN you've already used (Tasks 3, 71,
-- 77) into combining MULTIPLE conditions with OR -- a fan-in pattern
-- reusing TEAM_ROSTER_STREAM and PLAYER_STATS_STREAM from Task 72.
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;
USE SCHEMA ADVANCED;

CREATE OR REPLACE TABLE COMBINED_CHANGES_LOG (source STRING, detail STRING, logged_at TIMESTAMP_NTZ);

-- 1. The actual work lives in a procedure (Task 61's pattern) with
--    its OWN internal per-stream checks -- the task's WHEN only
--    guarantees "at least one" stream has something, not which one.
CREATE OR REPLACE PROCEDURE PROCESS_MULTI_STREAM_CHANGES()
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
    IF (SYSTEM$STREAM_HAS_DATA('TEAM_ROSTER_STREAM')) THEN
        INSERT INTO COMBINED_CHANGES_LOG (source, detail, logged_at)
        SELECT 'ROSTER', player_id || ':' || team, CURRENT_TIMESTAMP()
        FROM TEAM_ROSTER_STREAM;
    END IF;
    IF (SYSTEM$STREAM_HAS_DATA('PLAYER_STATS_STREAM')) THEN
        INSERT INTO COMBINED_CHANGES_LOG (source, detail, logged_at)
        SELECT 'STATS', player_id || ':' || TO_VARCHAR(score), CURRENT_TIMESTAMP()
        FROM PLAYER_STATS_STREAM;
    END IF;
    RETURN 'done';
END;
$$;

-- 2. A task whose WHEN combines both streams with OR -- fires if
--    EITHER one has data, not only when both do.
CREATE OR REPLACE TASK MULTI_STREAM_WHEN_TASK
    WAREHOUSE = IOT_LAB_WH
    SCHEDULE  = '1 MINUTE'
    WHEN SYSTEM$STREAM_HAS_DATA('TEAM_ROSTER_STREAM') OR SYSTEM$STREAM_HAS_DATA('PLAYER_STATS_STREAM')
AS
    CALL PROCESS_MULTI_STREAM_CHANGES();

ALTER TASK MULTI_STREAM_WHEN_TASK RESUME;

-- 3. Change only ONE of the two streams first.
INSERT INTO TEAM_ROSTER (player_id, team) VALUES ('P2', 'Blue');
-- Wait ~1-2 minutes, then check.
SELECT * FROM COMBINED_CHANGES_LOG ORDER BY logged_at;
SELECT NAME, STATE, SCHEDULED_TIME FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY())
WHERE NAME = 'MULTI_STREAM_WHEN_TASK' ORDER BY SCHEDULED_TIME DESC LIMIT 5;

-- 4. Now change the OTHER stream.
INSERT INTO PLAYER_STATS (player_id, score) VALUES ('P2', 200);
-- Wait again, then re-check both queries above.

-- 5. IMPORTANT — suspend it.
ALTER TASK MULTI_STREAM_WHEN_TASK SUSPEND;

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 80:
--
-- 1. When only TEAM_ROSTER_STREAM had data (step 3), did the task run
--    (SUCCEEDED) or skip? Confirm via TASK_HISTORY that the OR
--    condition let it fire even though PLAYER_STATS_STREAM was empty
--    at that point.
--
-- 2. If the WHEN clause had used AND instead of OR, what would have
--    happened during step 3's cycle, when only ONE of the two streams
--    had data? Would the task have run or skipped?
--
-- 3. The task's WHEN clause already confirms "at least one stream has
--    data" before the task ever runs. Given that, why does
--    PROCESS_MULTI_STREAM_CHANGES still need its OWN internal
--    SYSTEM$STREAM_HAS_DATA checks per stream, rather than just
--    unconditionally reading both streams every time it runs?
-- ============================================================
