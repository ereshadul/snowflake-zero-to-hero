-- ============================================================
-- Task 78 — Task trees/DAGs
-- Category: Tasks, deeper
-- A 3-stage Bronze -> Silver -> Gold pipeline (Task 76's category
-- naming, applied literally in miniature), chained with AFTER.
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;
USE SCHEMA ADVANCED;

CREATE OR REPLACE TABLE DAG_BRONZE (id INT, value INT, loaded_at TIMESTAMP_NTZ);
CREATE OR REPLACE TABLE DAG_SILVER (id INT, value INT, doubled_value INT);
CREATE OR REPLACE TABLE DAG_GOLD   (total_value INT, total_doubled INT, computed_at TIMESTAMP_NTZ);

-- 1. Root task -- the only one with a SCHEDULE. Everything else hangs
--    off of it via AFTER.
CREATE OR REPLACE TASK DAG_ROOT_TASK
    WAREHOUSE = IOT_LAB_WH
    SCHEDULE  = '1 MINUTE'
AS
    INSERT INTO DAG_BRONZE (id, value, loaded_at)
    SELECT SEQ4(), UNIFORM(1, 100, RANDOM()), CURRENT_TIMESTAMP()
    FROM TABLE(GENERATOR(ROWCOUNT => 1));

CREATE OR REPLACE TASK DAG_SILVER_TASK
    WAREHOUSE = IOT_LAB_WH
    AFTER DAG_ROOT_TASK
AS
    INSERT INTO DAG_SILVER (id, value, doubled_value)
    SELECT id, value, value * 2
    FROM DAG_BRONZE
    WHERE loaded_at > DATEADD('minute', -2, CURRENT_TIMESTAMP());

CREATE OR REPLACE TASK DAG_GOLD_TASK
    WAREHOUSE = IOT_LAB_WH
    AFTER DAG_SILVER_TASK
AS
    INSERT INTO DAG_GOLD (total_value, total_doubled, computed_at)
    SELECT SUM(value), SUM(doubled_value), CURRENT_TIMESTAMP()
    FROM DAG_SILVER;

-- 2. Resume BOTTOM-UP: leaves first, root last. If the root fired
--    before the children were resumed, the very first cycle would
--    have nothing downstream ready to catch it.
ALTER TASK DAG_GOLD_TASK   RESUME;
ALTER TASK DAG_SILVER_TASK RESUME;
ALTER TASK DAG_ROOT_TASK   RESUME;

-- 3. See the dependency structure directly.
SHOW TASKS LIKE 'DAG_%_TASK' IN SCHEMA ADVANCED;
-- Look at the "predecessors" column for DAG_SILVER_TASK and
-- DAG_GOLD_TASK.

-- 4. Wait 2-3 minutes, then check all three tables and the actual
--    run order.
SELECT * FROM DAG_BRONZE;
SELECT * FROM DAG_SILVER;
SELECT * FROM DAG_GOLD;

SELECT NAME, STATE, SCHEDULED_TIME, COMPLETED_TIME
FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY())
WHERE NAME IN ('DAG_ROOT_TASK', 'DAG_SILVER_TASK', 'DAG_GOLD_TASK')
ORDER BY SCHEDULED_TIME DESC
LIMIT 10;

-- 5. IMPORTANT — suspend the root first (stops new cycles from
--    starting), then the rest.
ALTER TASK DAG_ROOT_TASK   SUSPEND;
ALTER TASK DAG_SILVER_TASK SUSPEND;
ALTER TASK DAG_GOLD_TASK   SUSPEND;

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 79:
--
-- 1. From step 4's TASK_HISTORY, confirm the actual execution order:
--    did DAG_SILVER_TASK's COMPLETED_TIME come strictly after
--    DAG_ROOT_TASK's, and DAG_GOLD_TASK's after DAG_SILVER_TASK's?
--
-- 2. Step 2 resumed the tasks leaf-first (GOLD, then SILVER, then
--    ROOT). What would have happened to the very first DAG cycle if
--    you'd resumed ROOT first instead, and the root fired before you
--    got around to resuming SILVER and GOLD?
--
-- 3. Step 3's predecessors column shows the DAG structure directly.
--    What's a real, concrete reason to split a pipeline into 3
--    separate tasks (bronze/silver/gold) instead of just writing ONE
--    task whose body runs all three INSERT statements back to back in
--    sequence? Think about failure isolation and re-run granularity,
--    not just organization.
-- ============================================================
