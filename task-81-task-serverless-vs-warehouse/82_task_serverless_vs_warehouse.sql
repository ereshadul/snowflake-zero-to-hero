-- ============================================================
-- Task 81 — Serverless vs. warehouse-backed tasks
-- Category: Tasks, deeper
-- Completes this category. Reuses the DAG_BRONZE table from Task 78.
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;
USE SCHEMA ADVANCED;

-- 1. A task with NO WAREHOUSE clause at all -- this is what makes it
--    serverless. USER_TASK_MANAGED_INITIAL_WAREHOUSE_SIZE sets the
--    STARTING compute size only; Snowflake can scale it from there
--    based on observed run history.
CREATE OR REPLACE TASK SERVERLESS_TASK_DEMO
    SCHEDULE = '1 MINUTE'
    USER_TASK_MANAGED_INITIAL_WAREHOUSE_SIZE = 'XSMALL'
AS
    INSERT INTO DAG_BRONZE (id, value, loaded_at)
    SELECT SEQ4(), UNIFORM(1, 100, RANDOM()), CURRENT_TIMESTAMP()
    FROM TABLE(GENERATOR(ROWCOUNT => 1));

ALTER TASK SERVERLESS_TASK_DEMO RESUME;

-- 2. Confirm it's genuinely serverless -- check the "warehouse"
--    column.
SHOW TASKS LIKE 'SERVERLESS_TASK_DEMO' IN SCHEMA ADVANCED;

-- 3. Wait 2-3 minutes, then check it actually ran.
SELECT NAME, STATE, SCHEDULED_TIME, COMPLETED_TIME
FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY())
WHERE NAME = 'SERVERLESS_TASK_DEMO'
ORDER BY SCHEDULED_TIME DESC;

-- 4. Serverless task compute is tracked separately from warehouse
--    usage. If this view is available on your account:
SELECT *
FROM SNOWFLAKE.ACCOUNT_USAGE.SERVERLESS_TASK_HISTORY
WHERE TASK_NAME = 'SERVERLESS_TASK_DEMO'
ORDER BY START_TIME DESC;

-- 5. Switch it to warehouse-backed instead, to see the toggle
--    (suspend first -- you can't change WAREHOUSE on a running task).
ALTER TASK SERVERLESS_TASK_DEMO SUSPEND;
ALTER TASK SERVERLESS_TASK_DEMO SET WAREHOUSE = IOT_LAB_WH;
SHOW TASKS LIKE 'SERVERLESS_TASK_DEMO' IN SCHEMA ADVANCED;
-- "warehouse" column should now show IOT_LAB_WH instead of empty.

-- 6. IMPORTANT — leave it suspended, don't resume again.

-- ============================================================
-- UNDERSTANDING CHECK — this closes out the Tasks, deeper category:
--
-- 1. Compare step 2's SHOW TASKS output (before the switch) to step
--    5's (after). What did the "warehouse" column show in each case?
--
-- 2. If SERVERLESS_TASK_HISTORY is available on your account, does it
--    show credits tracked separately from IOT_LAB_WH's own usage
--    (which you'd see in WAREHOUSE_METERING_HISTORY instead)? Why do
--    Snowflake's billing systems need to track these two compute
--    sources through entirely separate views?
--
-- 3. IOT_LAB_WH is already being used by other things in this lab —
--    it's realistically warm/shared, not sitting idle. Given what you
--    learned about warehouse idle-time billing back in Tasks 3 and 124,
--    would switching SERVERLESS_TASK_DEMO to run on IOT_LAB_WH
--    (step 5) generally cost MORE or LESS than leaving it serverless,
--    in a scenario where the warehouse is already busy with other
--    work most of the time? Under what condition would the answer
--    flip the other way?
-- ============================================================
