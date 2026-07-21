-- ============================================================
-- Task 80 — Task monitoring & error handling
-- Category: Tasks, deeper
-- A deliberately failing root task, with a dependent child, to
-- observe exactly what happens to the rest of a DAG when one link
-- fails.
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;
USE SCHEMA ADVANCED;

CREATE OR REPLACE TABLE MONITORING_CHILD_LOG (message STRING, logged_at TIMESTAMP_NTZ);

CREATE OR REPLACE TASK FAILING_ROOT_TASK
    WAREHOUSE = IOT_LAB_WH
    SCHEDULE  = '1 MINUTE'
AS
    SELECT 1/0;  -- deliberately fails every single run

CREATE OR REPLACE TASK DEPENDENT_CHILD_TASK
    WAREHOUSE = IOT_LAB_WH
    AFTER FAILING_ROOT_TASK
AS
    INSERT INTO MONITORING_CHILD_LOG (message, logged_at)
    VALUES ('child ran', CURRENT_TIMESTAMP());

-- 1. Resume leaf-first (Task 78's lesson).
ALTER TASK DEPENDENT_CHILD_TASK RESUME;
ALTER TASK FAILING_ROOT_TASK    RESUME;

-- 2. Wait 2-3 minutes, then inspect what actually happened to BOTH
--    tasks.
SELECT NAME, STATE, SCHEDULED_TIME, COMPLETED_TIME, ERROR_MESSAGE
FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY())
WHERE NAME IN ('FAILING_ROOT_TASK', 'DEPENDENT_CHILD_TASK')
ORDER BY SCHEDULED_TIME DESC
LIMIT 10;

-- 3. Did the child ever actually run?
SELECT * FROM MONITORING_CHILD_LOG;

-- 4. IMPORTANT — suspend both.
ALTER TASK FAILING_ROOT_TASK    SUSPEND;
ALTER TASK DEPENDENT_CHILD_TASK SUSPEND;

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 81:
--
-- 1. What STATE does FAILING_ROOT_TASK show in TASK_HISTORY, and what
--    does the ERROR_MESSAGE column actually say? Read the real error
--    text, don't just note that it failed.
--
-- 2. Does DEPENDENT_CHILD_TASK show up in TASK_HISTORY at all for
--    those cycles, and is MONITORING_CHILD_LOG empty or populated?
--    Compare this to what a SKIPPED state (Task 79, from a WHEN
--    evaluating false) looks like — is "parent failed" the same
--    outcome as "parent's WHEN was false," or genuinely different?
--
-- 3. Nothing here notifies anyone that FAILING_ROOT_TASK is failing
--    every single cycle — you'd only find out by manually checking
--    TASK_HISTORY. Combining with Task 62's notification pattern,
--    sketch (in words) how you'd get emailed automatically the moment
--    a critical task fails, instead of discovering it days later.
-- ============================================================
