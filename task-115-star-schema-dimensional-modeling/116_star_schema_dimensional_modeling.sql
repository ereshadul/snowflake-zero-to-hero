-- ============================================================
-- Task 115 — Star schema & dimensional modeling
-- Category: Ecosystem & Modeling
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;
USE SCHEMA ADVANCED;

-- 1. A DATE DIMENSION -- a Kimball staple. Instead of computing
--    day-of-week/month/quarter with functions every query, pre-compute
--    them once as rows you can JOIN against.
CREATE OR REPLACE TABLE DIM_DATE AS
SELECT
    d::DATE                          AS date_key,
    YEAR(d)                          AS year,
    QUARTER(d)                       AS quarter,
    MONTH(d)                         AS month,
    MONTHNAME(d)                     AS month_name,
    DAYOFWEEK(d)                     AS day_of_week,
    DAYNAME(d)                       AS day_name,
    IFF(DAYOFWEEK(d) IN (0, 6), TRUE, FALSE) AS is_weekend
FROM (
    SELECT DATEADD(day, SEQ4(), '2026-01-01'::DATE) AS d
    FROM TABLE(GENERATOR(ROWCOUNT => 365))
);

-- 2. A DIMENSION TABLE -- descriptive attributes about sensors,
--    changing slowly if at all. One row per sensor.
CREATE OR REPLACE TABLE DIM_SENSOR AS
SELECT DISTINCT
    sensor_id,
    device_type,
    firmware_version
FROM CURATED.SENSOR_READINGS_HISTORY;

-- 3. A FACT TABLE -- the numeric, event-level measurements, referencing
--    dimensions by key instead of repeating their descriptive
--    attributes on every row. This is the "star": one fact table in
--    the middle, dimensions radiating out around it.
CREATE OR REPLACE TABLE FCT_SENSOR_READINGS AS
SELECT
    h.event_id,
    h.sensor_id,
    DATE(h.event_timestamp) AS date_key,
    h.reading_value,
    h.battery_pct,
    h.signal_strength_dbm
FROM CURATED.SENSOR_READINGS_HISTORY h;

-- 4. The whole POINT of the star: a business question answered by
--    joining the skinny fact table out to descriptive dimensions,
--    instead of the fact table itself carrying all those columns.
SELECT
    dd.day_name,
    dd.is_weekend,
    ds.device_type,
    AVG(f.reading_value) AS avg_reading_value,
    AVG(f.battery_pct)   AS avg_battery_pct
FROM FCT_SENSOR_READINGS f
JOIN DIM_DATE   dd ON f.date_key  = dd.date_key
JOIN DIM_SENSOR ds ON f.sensor_id = ds.sensor_id
GROUP BY dd.day_name, dd.is_weekend, ds.device_type
ORDER BY dd.is_weekend, dd.day_name;

-- 5. Clean up.
DROP TABLE FCT_SENSOR_READINGS;
DROP TABLE DIM_SENSOR;
DROP TABLE DIM_DATE;

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 116:
--
-- 1. FCT_SENSOR_READINGS stores only sensor_id and date_key, not
--    device_type or day_name directly. Step 4's query JOINs back out
--    to DIM_SENSOR and DIM_DATE to get those. What would happen to the
--    size of the fact table (and how easy it'd be to fix a typo in a
--    device_type label across history) if device_type were repeated on
--    every single fact row instead of looked up through a dimension?
--
-- 2. DIM_DATE was pre-computed once, covering a whole year of calendar
--    attributes, instead of computing DAYNAME()/QUARTER()/is_weekend
--    with functions inside every single query that needs them. What's
--    the actual benefit of a physical date dimension table over just
--    calling those date functions directly in step 4's query?
--
-- 3. Task 116 covers Data Vault modeling (hubs/links/satellites) as an
--    alternative way to model this exact same sensor domain. Star
--    schema is optimized for ONE thing very well: a specific set of
--    business questions answered fast with simple joins. Based on what
--    you just built, what would make star schema a POOR fit for a
--    frequently-changing source system with many different upstream
--    feeds that need to be integrated flexibly (a preview of what
--    you'll compare against in Task 116)?
-- ============================================================
