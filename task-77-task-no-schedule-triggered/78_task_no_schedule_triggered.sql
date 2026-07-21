-- ============================================================
-- Task 77 — No-schedule/triggered tasks
-- Category: Tasks, deeper
--
-- About this category: Tasks 77-82 go past Task 3's basics into more
-- advanced task mechanics -- DAGs, conditional WHEN logic, monitoring,
-- compute choice, and load strategy.
--
-- This task specifically tests whether your account supports a task
-- with NO SCHEDULE at all, triggered purely by a stream having data --
-- an evolving area of Snowflake's Task feature, worth confirming
-- directly rather than assuming.
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;
USE SCHEMA ADVANCED;

-- 1. A task with NO SCHEDULE clause -- only a WHEN condition
--    referencing a stream. Compare this to Task 71's SENSOR_PIPE
--    task, which used SCHEDULE = '1 MINUTE' alongside its WHEN.
CREATE OR REPLACE TASK TRIGGERED_TASK_DEMO
    WAREHOUSE = IOT_LAB_WH
    WHEN SYSTEM$STREAM_HAS_DATA('STREAM_DEMO_STREAM')
AS
    INSERT INTO STREAM_DEMO_HISTORY (id, name, value, change_type, changed_at)
    SELECT id, name, value, METADATA$ACTION, CURRENT_TIMESTAMP()
    FROM STREAM_DEMO_STREAM;

ALTER TASK TRIGGERED_TASK_DEMO RESUME;

-- 2. Give it something to react to, and note the exact time.
SELECT CURRENT_TIMESTAMP() AS inserted_at;
INSERT INTO STREAM_DEMO_SOURCE (id, name, value) VALUES (20, 'Test', 999);

-- 3. Check how quickly it actually ran.
SELECT NAME, STATE, SCHEDULED_TIME, COMPLETED_TIME
FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY())
WHERE NAME = 'TRIGGERED_TASK_DEMO'
ORDER BY SCHEDULED_TIME DESC;

SELECT * FROM STREAM_DEMO_HISTORY WHERE id = 20;

-- 4. IMPORTANT — suspend it.
ALTER TASK TRIGGERED_TASK_DEMO SUSPEND;

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 78:
--
-- 1. Did step 1's CREATE TASK succeed at all, with no SCHEDULE clause
--    present? Report exactly what happened on your account — this is
--    a genuinely worth-testing question, not something to assume.
--
-- 2. Compare COMPLETED_TIME from step 3 to the timestamp you captured
--    in step 2. How much delay was there between the INSERT and the
--    task actually reacting? Compare that gap to how Task 71's
--    fixed 1-minute SCHEDULE task behaved — is a no-schedule triggered
--    task noticeably faster, slower, or roughly the same?
--
-- 3. Given a no-schedule/triggered task reacts to stream data
--    automatically, why would you ever still choose a fixed SCHEDULE
--    (like Task 71's 1-minute interval) for a CDC pipeline instead of
--    this triggered approach? Think about predictability and resource
--    planning, not just raw reaction speed.
-- ============================================================
