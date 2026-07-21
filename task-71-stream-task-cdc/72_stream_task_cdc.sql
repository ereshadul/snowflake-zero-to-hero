-- ============================================================
-- Task 71 — Stream + Task CDC pattern
-- Category: Streams
-- The canonical pattern: a Task (Task 3) that fires only when a
-- Stream (Task 69) actually has data, using the exact same free
-- WHEN SYSTEM$STREAM_HAS_DATA check from Task 51.
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;
USE SCHEMA ADVANCED;

CREATE OR REPLACE TABLE STREAM_DEMO_HISTORY (
    id          INT,
    name        STRING,
    value       INT,
    change_type STRING,
    changed_at  TIMESTAMP_NTZ
);

-- 1. A task that's cheap to leave running: it only actually does work
--    when the stream has something in it.
CREATE OR REPLACE TASK STREAM_DEMO_CDC_TASK
    WAREHOUSE = IOT_LAB_WH
    SCHEDULE  = '1 MINUTE'
    WHEN SYSTEM$STREAM_HAS_DATA('STREAM_DEMO_STREAM')
AS
    INSERT INTO STREAM_DEMO_HISTORY (id, name, value, change_type, changed_at)
    SELECT id, name, value, METADATA$ACTION, CURRENT_TIMESTAMP()
    FROM STREAM_DEMO_STREAM;

ALTER TASK STREAM_DEMO_CDC_TASK RESUME;

-- 2. Make some changes to the source table -- give the task
--    something to actually pick up.
INSERT INTO STREAM_DEMO_SOURCE (id, name, value) VALUES (5, 'Eve', 500);
UPDATE STREAM_DEMO_SOURCE SET value = 999 WHERE id = 5;

-- 3. Wait 1-2 minutes for the task to fire, then check what landed.
SELECT * FROM STREAM_DEMO_HISTORY ORDER BY changed_at;

-- 4. Check whether the task actually ran vs. skipped, per cycle.
SELECT NAME, STATE, SCHEDULED_TIME, COMPLETED_TIME
FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY())
WHERE NAME = 'STREAM_DEMO_CDC_TASK'
ORDER BY SCHEDULED_TIME DESC;

-- 5. Check whether the stream itself is now empty.
SELECT SYSTEM$STREAM_HAS_DATA('STREAM_DEMO_STREAM');

-- 6. IMPORTANT — suspend it. Same habit as Task 3.
ALTER TASK STREAM_DEMO_CDC_TASK SUSPEND;

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 72:
--
-- 1. Look at TASK_HISTORY from step 4. Do you see SUCCEEDED runs only
--    for the cycles where the stream actually had data, and SKIPPED
--    for the ones where it didn't — matching the WHEN behavior you
--    first saw in Task 51?
--
-- 2. Step 5 checks whether the stream is empty AFTER the task ran.
--    What specifically caused the stream to advance/empty here — was
--    it the SELECT alone, or the fact that a committed DML statement
--    (INSERT INTO ... SELECT FROM the stream) actually consumed it?
--    (Task 74 goes deeper on this — for now just confirm what you
--    observe.)
--
-- 3. This pattern works cleanly for ONE downstream consumer
--    (STREAM_DEMO_HISTORY). What would break if a SECOND, independent
--    consumer also needed to read the exact same set of changes —
--    given that consuming a stream in one place advances/empties it
--    for everyone? What would you need to add to support two
--    independent readers of the same change set?
-- ============================================================
