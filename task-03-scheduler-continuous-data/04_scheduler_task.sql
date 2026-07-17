-- ============================================================
-- Task 3 — Schedule the SAME SQL to run repeatedly, generating
-- continuous data. This is a Snowflake TASK: a scheduled job that
-- runs SQL on a warehouse, on a cron-like schedule, with no external
-- scheduler (no Airflow, no cron box, nothing outside Snowflake).
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;

-- 1. The repeated statement: append one more batch of synthetic
--    readings each time it runs. Same shape as Task 2's generator,
--    just smaller per run and wrapped as an INSERT instead of CTAS.
CREATE OR REPLACE TASK CURATED.GENERATE_BATCH_TASK
  WAREHOUSE = IOT_LAB_WH
  SCHEDULE = '1 MINUTE'
AS
  INSERT INTO CURATED.SENSOR_READINGS_SYNTHETIC
  SELECT
      UUID_STRING(),
      'SENSOR_' || LPAD(MOD(SEQ4(), 5000)::STRING, 5, '0'),
      ARRAY_CONSTRUCT('temperature','humidity','pressure','motion','gps','vibration')
          [MOD(SEQ4(), 6)]::STRING,
      CURRENT_TIMESTAMP()::TIMESTAMP_NTZ,
      ROUND(UNIFORM(-40, 150, RANDOM())::FLOAT, 3),
      UNIFORM(0, 100, RANDOM()),
      ROUND(UNIFORM(-110, -30, RANDOM())::FLOAT, 1),
      OBJECT_CONSTRUCT(
          'calibration_offset', ROUND(UNIFORM(-2, 2, RANDOM())::FLOAT, 3),
          'alerts', ARRAY_CONSTRUCT_COMPACT(
              IFF(UNIFORM(0, 100, RANDOM()) < 5, 'LOW_BATTERY', NULL)
          )
      )
  FROM TABLE(GENERATOR(ROWCOUNT => 500));  -- 500 new rows every run

-- 2. Tasks are created SUSPENDED by default — nothing runs until you
--    explicitly resume it. (Requires a role with EXECUTE TASK, e.g.
--    ACCOUNTADMIN or SYSADMIN with the privilege granted.)
ALTER TASK CURATED.GENERATE_BATCH_TASK RESUME;

-- 3. Let it run for a few minutes, then check on it.
SELECT * FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY())
  WHERE NAME = 'GENERATE_BATCH_TASK'
  ORDER BY SCHEDULED_TIME DESC;

SELECT COUNT(*) AS row_count, MAX(event_timestamp) AS latest_row
FROM CURATED.SENSOR_READINGS_SYNTHETIC;

-- 4. IMPORTANT — suspend it when you're done watching it, or it will
--    keep running (and keep waking the warehouse, and keep billing)
--    forever.
ALTER TASK CURATED.GENERATE_BATCH_TASK SUSPEND;

-- ============================================================
-- UNDERSTANDING CHECK — work through these with the task actually
-- running, don't just read them:
--
-- 1. The warehouse has AUTO_SUSPEND = 60 (seconds). The task schedule
--    is '1 MINUTE'. Watch the warehouse's activity — does it ever
--    actually go idle/suspended between task runs? What would you
--    change (on the warehouse, or the schedule) to control cost here,
--    and what's the tradeoff?
--
-- 2. Try suspending the task, then querying TASK_HISTORY again a
--    minute later. What's the difference between a task that's
--    SUSPENDED and one that's still SCHEDULED but skipped a run
--    because SYSTEM$STREAM_HAS_DATA was false (not used in this
--    script, but common in real ones — worth knowing the difference)?
--
-- 3. This task runs on a fixed WAREHOUSE you own. Snowflake also
--    offers "serverless" tasks with no WAREHOUSE clause, where
--    Snowflake manages the compute. What would make you choose one
--    over the other for a job like this one?
-- ============================================================
