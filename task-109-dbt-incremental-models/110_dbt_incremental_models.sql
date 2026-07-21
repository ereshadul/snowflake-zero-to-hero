-- ============================================================
-- Task 109 — dbt incremental models
-- Category: dbt
-- Task 103's understanding check flagged this tradeoff already: a
-- VIEW is recomputed on every query; a TABLE is stored but needs an
-- explicit rebuild. INCREMENTAL is the third option -- a stored table
-- that only processes NEW/CHANGED rows on each run, instead of a full
-- rebuild every time. This is dbt's version of the timestamp-watermark
-- incremental strategy from Task 81.
-- ============================================================

-- 1. Convert fct_daily_sensor_summary (Task 105) to incremental. Save
--    as iot_lab_dbt/models/marts/fct_daily_sensor_summary.sql,
--    replacing the earlier version entirely:
--
-- {{
--     config(
--         materialized='incremental',
--         unique_key=['sensor_id', 'reading_date'],
--         incremental_strategy='merge'
--     )
-- }}
--
-- SELECT
--     sensor_id,
--     DATE_TRUNC('day', event_timestamp) AS reading_date,
--     COUNT(*)          AS reading_count,
--     AVG(reading_value) AS avg_reading_value,
--     MIN(reading_value) AS min_reading_value,
--     MAX(reading_value) AS max_reading_value
-- FROM {{ ref('stg_sensor_readings') }}
--
-- {% if is_incremental() %}
-- WHERE event_timestamp > (SELECT MAX(reading_date) FROM {{ this }})
-- {% endif %}
--
-- GROUP BY sensor_id, DATE_TRUNC('day', event_timestamp)

-- 2. First run: the table doesn't exist yet, so is_incremental()
--    evaluates FALSE and the WHERE clause is skipped entirely -- a
--    full build, same as a plain table materialization.
--
--    dbt run --select fct_daily_sensor_summary --full-refresh

-- 3. Second run, with no new data: is_incremental() now evaluates
--    TRUE (the table exists), so the WHERE clause filters to "only
--    rows newer than what's already in the table." Watch how much
--    less work this run does (check the query duration/rows in
--    Snowflake's query history).
--
--    dbt run --select fct_daily_sensor_summary

-- 4. Verify in Snowflake -- real SQL, run in a worksheet. Also inspect
--    what MERGE strategy actually produced under the hood:
USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;
SELECT COUNT(*) AS row_count FROM DBT_DEV.FCT_DAILY_SENSOR_SUMMARY;

-- Query history: find the statement dbt just ran for step 3 and
-- confirm it's a MERGE, not a full CREATE OR REPLACE TABLE.
SELECT query_text, execution_status, total_elapsed_time
FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY())
WHERE query_text ILIKE '%FCT_DAILY_SENSOR_SUMMARY%'
ORDER BY start_time DESC
LIMIT 10;

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 110:
--
-- 1. Step 2's --full-refresh forced a complete rebuild even though the
--    model is incremental. When would you actually NEED to pass
--    --full-refresh on an incremental model that's already running
--    fine day to day (hint: think about what happens if you change the
--    SELECT logic itself, not just the filter condition)?
--
-- 2. {% if is_incremental() %} wraps the WHERE clause so it only
--    applies on runs AFTER the first one. What specific condition does
--    is_incremental() actually check to decide true vs. false --
--    is it about whether NEW rows exist upstream, or about whether the
--    target table already exists in Snowflake?
--
-- 3. Compare this dbt incremental model to the Stream+Task
--    timestamp-watermark pattern from Task 81 (same underlying idea:
--    only process rows newer than what's already landed). What did dbt
--    handle for you here (the MERGE logic, the "does the table exist
--    yet" check) that you had to hand-write yourself with Streams and
--    Tasks? What's the late-arriving-row gotcha Task 81 flagged for
--    timestamp watermarks, and does switching to dbt's is_incremental()
--    pattern make that gotcha go away, or is it the exact same risk in
--    a different syntax?
-- ============================================================
