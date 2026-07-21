-- ============================================================
-- Task 105 — dbt ref() and building a model DAG
-- Category: dbt
-- ============================================================

-- 1. A downstream MART model built on TOP OF Task 104's staging
--    model -- using ref(), never a hardcoded table name. Save as
--    iot_lab_dbt/models/marts/fct_daily_sensor_summary.sql:
--
-- SELECT
--     sensor_id,
--     DATE_TRUNC('day', event_timestamp) AS reading_date,
--     COUNT(*)          AS reading_count,
--     AVG(reading_value) AS avg_reading_value,
--     MIN(reading_value) AS min_reading_value,
--     MAX(reading_value) AS max_reading_value
-- FROM {{ ref('stg_sensor_readings') }}
-- GROUP BY sensor_id, DATE_TRUNC('day', event_timestamp)

-- 2. Run the WHOLE project. Notice you don't have to run staging
--    before marts yourself -- dbt parses every ref() in the project,
--    builds a dependency graph, and runs things in the right order
--    automatically.
--
--    dbt run

-- 3. See the DAG dbt actually built, as plain text, without a full
--    docs site (Task 112 covers the visual version):
--
--    dbt list --select stg_sensor_readings+
--    -- The '+' after a model name means "this model AND everything
--    -- downstream of it." Confirm fct_daily_sensor_summary shows up.
--
--    dbt list --select +fct_daily_sensor_summary
--    -- The '+' BEFORE a model name means "this model AND everything
--    -- upstream of it." Confirm stg_sensor_readings (and the source)
--    -- shows up.

-- 4. Prove the dependency order actually matters -- run ONLY the mart
--    in a project where nothing has been built yet (use --full-refresh
--    on a scratch profile/schema if you want to see this cleanly), and
--    read the error dbt gives you if the staging model's underlying
--    table doesn't exist yet. Then run the normal way and see it work:
--
--    dbt run --select fct_daily_sensor_summary
--    -- dbt still runs stg_sensor_readings first automatically, because
--    -- ref() told it that's a dependency, even though you only asked
--    -- for the mart by name.

-- 5. Verify in Snowflake -- real SQL, run in a worksheet:
USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;
SELECT * FROM DBT_DEV.FCT_DAILY_SENSOR_SUMMARY
ORDER BY reading_date, sensor_id
LIMIT 20;

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 106:
--
-- 1. fct_daily_sensor_summary.sql never mentions stg_sensor_readings'
--    ACTUAL Snowflake object name (DBT_DEV.STG_SENSOR_READINGS) --
--    only {{ ref('stg_sensor_readings') }}. If stg_sensor_readings
--    were reconfigured to materialize into a completely different
--    schema, would fct_daily_sensor_summary.sql need to change at all?
--
-- 2. Step 3's `dbt list --select stg_sensor_readings+` and
--    `dbt list --select +fct_daily_sensor_summary` use the '+'
--    operator on opposite sides of the model name. Explain in your own
--    words what each direction of '+' actually selects, and why they
--    produced overlapping but not identical results.
--
-- 3. You never told dbt "run staging before marts" anywhere in a
--    config file -- there's no explicit ordering, no AFTER clause like
--    Snowflake Tasks use (Tasks 77-82). Where does dbt actually derive
--    the correct run order from, and what would happen if
--    fct_daily_sensor_summary.sql used a hardcoded table name instead
--    of ref() -- would dbt still know to run stg_sensor_readings
--    first?
-- ============================================================
