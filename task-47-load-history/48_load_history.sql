-- ============================================================
-- Task 47 — Load history (COPY_HISTORY)
-- Category: Loading & COPY options
--
-- Pure querying task -- no new files needed. By now you have plenty
-- of real load history across RAW.SENSOR_READINGS_STRICT from Tasks
-- 4, 38-46: successes, skips, and at least one real failure.
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;

-- 1. INFORMATION_SCHEMA.COPY_HISTORY — near real-time, but scoped to
--    ONE table per call and requires a time window.
SELECT
    file_name, status, row_count, row_parsed, error_count, last_load_time
FROM TABLE(INFORMATION_SCHEMA.COPY_HISTORY(
    TABLE_NAME => 'RAW.SENSOR_READINGS_STRICT',
    START_TIME => DATEADD('hour', -6, CURRENT_TIMESTAMP())
))
ORDER BY last_load_time DESC;

-- 2. SNOWFLAKE.ACCOUNT_USAGE.COPY_HISTORY — account-wide (every
--    table, no need to name one), but with real latency before a
--    load shows up here.
SELECT
    table_name, file_name, status, row_count, error_count, last_load_time
FROM SNOWFLAKE.ACCOUNT_USAGE.COPY_HISTORY
WHERE table_name = 'SENSOR_READINGS_STRICT'
ORDER BY last_load_time DESC
LIMIT 50;

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 48:
--
-- 1. Run step 2 right after running a brand-new COPY INTO against
--    RAW.SENSOR_READINGS_STRICT. Does that load show up in
--    ACCOUNT_USAGE.COPY_HISTORY immediately, or is it missing for a
--    while? Look up ACCOUNT_USAGE's documented latency for this view
--    and compare to what you actually observed.
--
-- 2. INFORMATION_SCHEMA.COPY_HISTORY requires you to name ONE
--    specific table. If you wanted a single query covering load
--    activity across every table in IOT_LAB at once, which of the two
--    sources would actually let you do that in one shot, and why
--    can't INFORMATION_SCHEMA.COPY_HISTORY do it directly?
--
-- 3. Look at the STATUS column across everything step 1 returns for
--    RAW.SENSOR_READINGS_STRICT. You should see more than just
--    "LOADED" — what other status value(s) show up from your work in
--    Tasks 38-46, and for each one, what actually happened during that
--    specific COPY INTO call to produce it?
-- ============================================================
