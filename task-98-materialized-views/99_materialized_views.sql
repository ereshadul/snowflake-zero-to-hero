-- ============================================================
-- Task 98 — Materialized views
-- Category: Performance & cost
-- This closes out the Performance & cost group (93-98). A
-- materialized view is a regular view whose RESULT is physically
-- stored and kept in sync by Snowflake in the background -- you pay
-- storage + maintenance credits so that reads become near-instant.
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;
USE SCHEMA ADVANCED;

-- 1. The expensive thing: a daily aggregation over the full
--    50-million-row synthetic sensor table. Time this as a plain view
--    first so you have a "before" number.
CREATE OR REPLACE VIEW DAILY_SENSOR_SUMMARY_VIEW AS
SELECT
    sensor_id,
    DATE_TRUNC('day', event_timestamp) AS reading_date,
    COUNT(*)          AS reading_count,
    AVG(value)        AS avg_value,
    MIN(value)        AS min_value,
    MAX(value)        AS max_value
FROM IOT_LAB.CURATED.SENSOR_READINGS_SYNTHETIC
GROUP BY sensor_id, DATE_TRUNC('day', event_timestamp);

-- Run this and note the elapsed time in the query history / results
-- pane -- every single execution rescans and re-aggregates the whole
-- base table from scratch.
SELECT * FROM DAILY_SENSOR_SUMMARY_VIEW ORDER BY reading_date, sensor_id LIMIT 20;

-- 2. Same logic, but as a materialized view. Snowflake computes the
--    result now and stores it, then incrementally maintains it as the
--    base table changes -- you don't re-pay the full aggregation cost
--    on every read.
CREATE OR REPLACE MATERIALIZED VIEW DAILY_SENSOR_SUMMARY_MV AS
SELECT
    sensor_id,
    DATE_TRUNC('day', event_timestamp) AS reading_date,
    COUNT(*)          AS reading_count,
    AVG(value)        AS avg_value,
    MIN(value)        AS min_value,
    MAX(value)        AS max_value
FROM IOT_LAB.CURATED.SENSOR_READINGS_SYNTHETIC
GROUP BY sensor_id, DATE_TRUNC('day', event_timestamp);

-- Give Snowflake a moment to finish the initial materialization, then
-- run the equivalent query against the MV and compare elapsed time.
SELECT * FROM DAILY_SENSOR_SUMMARY_MV ORDER BY reading_date, sensor_id LIMIT 20;

-- 3. Metadata: confirm it's registered as a materialized view and
--    check its refresh/maintenance state.
SHOW MATERIALIZED VIEWS LIKE 'DAILY_SENSOR_SUMMARY_MV';

-- 4. Clean up -- this MV would otherwise keep consuming background
--    maintenance credits every time the base table changes.
DROP MATERIALIZED VIEW DAILY_SENSOR_SUMMARY_MV;
DROP VIEW DAILY_SENSOR_SUMMARY_VIEW;

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 99:
--
-- 1. Compare the elapsed time of step 1's plain-view query against
--    step 2's materialized-view query (Snowsight's query history shows
--    both). Which one re-scans and re-aggregates the full base table
--    on every single execution, and which one is reading a
--    pre-computed result?
--
-- 2. A materialized view is kept in sync automatically as
--    SENSOR_READINGS_SYNTHETIC changes. Is that background maintenance
--    free, or does Snowflake actually spend compute credits (outside
--    of any query you explicitly run) to keep it current? Given that,
--    would a materialized view make sense on a base table that changes
--    constantly, versus one that's mostly append-only or rarely
--    updated?
--
-- 3. A regular VIEW and a MATERIALIZED VIEW can express the exact same
--    SELECT. What's the actual tradeoff being made by choosing the
--    materialized version -- what do you pay for, and what do you get
--    back in return? Is there a scenario in this lab so far (hint:
--    think about how many times you've re-run the same expensive
--    aggregation) where that tradeoff would clearly have been worth
--    it?
-- ============================================================
