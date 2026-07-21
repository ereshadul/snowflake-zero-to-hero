-- ============================================================
-- Task 99 — Dynamic Tables
-- Category: Newer table types
-- About this category: Tasks 99-102 cover table types that go beyond
-- the plain permanent table you've used everywhere else in this lab
-- -- each one trades away some flexibility for a specific guarantee
-- (freshness, point-lookup speed, structured logging, or an open
-- storage format).
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;
USE SCHEMA ADVANCED;

-- 1. The old way you've been doing incremental aggregation so far in
--    this lab: a Stream + Task pair (Tasks 69-82) that you write and
--    orchestrate yourself. A Dynamic Table replaces that whole
--    pipeline with ONE declarative object -- you just describe the
--    query, and Snowflake figures out how to keep it fresh.
CREATE OR REPLACE DYNAMIC TABLE SENSOR_HOURLY_DT
    TARGET_LAG = '1 minute'
    WAREHOUSE  = IOT_LAB_WH
AS
SELECT
    sensor_id,
    DATE_TRUNC('hour', event_timestamp) AS reading_hour,
    COUNT(*)   AS reading_count,
    AVG(value) AS avg_value
FROM IOT_LAB.CURATED.SENSOR_READINGS_SYNTHETIC
GROUP BY sensor_id, DATE_TRUNC('hour', event_timestamp);

-- 2. Query it like any other table.
SELECT * FROM SENSOR_HOURLY_DT ORDER BY reading_hour, sensor_id LIMIT 20;

-- 3. Inspect its refresh state -- this is what TARGET_LAG actually
--    drives: Snowflake decides how often to refresh based on how far
--    behind you told it you're willing to tolerate.
SHOW DYNAMIC TABLES LIKE 'SENSOR_HOURLY_DT';

SELECT *
FROM TABLE(INFORMATION_SCHEMA.DYNAMIC_TABLE_REFRESH_HISTORY(
    NAME => 'SENSOR_HOURLY_DT'
))
ORDER BY refresh_start_time DESC;

-- 4. Force a manual refresh (useful right after creation, or for
--    testing) instead of waiting for the scheduled one.
ALTER DYNAMIC TABLE SENSOR_HOURLY_DT REFRESH;

-- 5. Clean up.
DROP DYNAMIC TABLE SENSOR_HOURLY_DT;

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 100:
--
-- 1. Compare what you just did in ONE CREATE DYNAMIC TABLE statement
--    against the Stream + Task pattern from Tasks 69-82 (a stream to
--    detect changes, a task to run on a schedule, and hand-written SQL
--    to merge results). What specifically did the Dynamic Table do FOR
--    you that you had to build yourself with Streams and Tasks?
--
-- 2. TARGET_LAG = '1 minute' is a target, not a guarantee of an exact
--    schedule. Based on step 3's refresh history, does Snowflake
--    refresh the table on a fixed timer, or does it decide the refresh
--    cadence itself based on the lag target and the cost of
--    refreshing? What would happen to warehouse credit consumption if
--    you set TARGET_LAG to something extremely tight, like '1 second',
--    on a genuinely large base table?
--
-- 3. A Dynamic Table's query can reference OTHER dynamic tables,
--    chaining them into a pipeline. Compared to writing that same
--    multi-stage pipeline as several Stream+Task pairs, what's the
--    tradeoff -- what do you gain in simplicity, and what control do
--    you give up (hint: think about how much you can customize each
--    individual step's logic vs. just writing a SELECT)?
-- ============================================================
