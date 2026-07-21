-- ============================================================
-- Task 114 — Medallion Architecture
-- Category: Ecosystem & Modeling
-- About this category: Tasks 114-120 step back from individual
-- Snowflake features to how a whole warehouse gets ORGANIZED --
-- layering, modeling style, deployment process, and how end users
-- (including AI) actually consume the result.
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;

-- 1. You've actually been building a Medallion architecture since
--    Task 1, without naming it that. Confirm the three layers already
--    exist and map them explicitly:
--
--    BRONZE (raw, untyped, as-landed)
SELECT COUNT(*) AS bronze_row_count FROM RAW.SENSOR_READINGS_RAW;
DESCRIBE TABLE RAW.SENSOR_READINGS_RAW;
-- Every column is STRING/VARIANT -- no cleansing, no typing, nothing
-- thrown away, not even the malformed ~0.6%. That's the point of
-- Bronze: a faithful, replayable copy of what arrived.

--    SILVER (cleansed, typed, deduplicated, business-key enforced)
SELECT COUNT(*) AS silver_row_count FROM CURATED.SENSOR_READINGS_HISTORY;
DESCRIBE TABLE CURATED.SENSOR_READINGS_HISTORY;
-- Proper TIMESTAMP_NTZ/FLOAT/NUMBER types, clustered for time-series
-- access. Garbage rows from Bronze are gone. This is queryable by
-- anyone on the data team, but still row-level, not yet aggregated
-- for a specific business question.

-- 2. GOLD doesn't exist yet in this lab as a distinct object --
--    build one now: a business-ready, aggregated table meant for a
--    specific consumer (a dashboard, in this case), not for general
--    analysis.
CREATE OR REPLACE TABLE CURATED.GOLD_DAILY_FLEET_HEALTH AS
SELECT
    DATE_TRUNC('day', event_timestamp) AS reporting_date,
    device_type,
    COUNT(DISTINCT sensor_id)           AS active_sensor_count,
    AVG(reading_value)                  AS avg_reading_value,
    AVG(battery_pct)                    AS avg_battery_pct,
    SUM(IFF(status_code = 'ERROR', 1, 0)) AS error_event_count
FROM CURATED.SENSOR_READINGS_HISTORY
GROUP BY DATE_TRUNC('day', event_timestamp), device_type;

SELECT * FROM CURATED.GOLD_DAILY_FLEET_HEALTH
ORDER BY reporting_date, device_type
LIMIT 20;

-- 3. Clean up the demo Gold table (a real one would stay, refreshed by
--    a Task or dbt model -- Tasks 77-82 and 103-113 already covered
--    how).
DROP TABLE CURATED.GOLD_DAILY_FLEET_HEALTH;

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 115:
--
-- 1. Step 1's Bronze layer (RAW.SENSOR_READINGS_RAW) keeps even the
--    ~0.6% of malformed rows that Task 1's own notes describe. Why is
--    "keep everything, exactly as it arrived, even the garbage" the
--    right design for Bronze specifically, given that Silver
--    (CURATED.SENSOR_READINGS_HISTORY) already drops those same rows?
--    What would you lose if Bronze also filtered out bad rows?
--
-- 2. GOLD_DAILY_FLEET_HEALTH in step 2 is aggregated specifically for
--    a fleet-health dashboard question ("how many sensors are active
--    and erroring per day, per device type"). If a completely
--    different team needed a DIFFERENT aggregation over the same
--    underlying Silver data (say, average battery drain per firmware
--    version), would you add more columns to this SAME Gold table, or
--    build a SEPARATE Gold table? What does that tell you about how
--    many Gold tables a mature medallion architecture typically has,
--    compared to how many Bronze/Silver tables it has?
--
-- 3. Task 98's materialized views and this task's Gold tables solve a
--    similar-sounding problem: pre-computed, business-ready
--    aggregations. What's actually different about WHO decides the
--    shape of a materialized view (a query author, ad hoc) versus a
--    Gold table (a deliberate architectural layer with a specific
--    downstream consumer in mind)?
-- ============================================================
