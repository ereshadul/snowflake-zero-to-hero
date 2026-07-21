-- ============================================================
-- Task 8 — Window functions: LAG and LEAD
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;
USE SCHEMA ADVANCED;

CREATE OR REPLACE TABLE DAILY_TEMPS (
    sensor_id    STRING,
    reading_date DATE,
    avg_temp     FLOAT
);

INSERT INTO DAILY_TEMPS (sensor_id, reading_date, avg_temp) VALUES
    ('SENSOR_001', '2026-06-01', 20.5),
    ('SENSOR_001', '2026-06-02', 21.0),
    ('SENSOR_001', '2026-06-03', 19.8),
    ('SENSOR_001', '2026-06-04', 22.3),
    ('SENSOR_001', '2026-06-05', 22.3),   -- ties the previous day exactly
    ('SENSOR_002', '2026-06-01', 15.0),
    ('SENSOR_002', '2026-06-02', 16.5),
    ('SENSOR_002', '2026-06-03', 14.0);

-- 1. Basic LAG/LEAD: previous day's value, next day's value, and the
--    day-over-day delta computed directly from LAG -- no self-join.
SELECT
    sensor_id,
    reading_date,
    avg_temp,
    LAG(avg_temp)  OVER (PARTITION BY sensor_id ORDER BY reading_date) AS prev_day_temp,
    avg_temp - LAG(avg_temp) OVER (PARTITION BY sensor_id ORDER BY reading_date) AS day_over_day_delta,
    LEAD(avg_temp) OVER (PARTITION BY sensor_id ORDER BY reading_date) AS next_day_temp
FROM DAILY_TEMPS
ORDER BY sensor_id, reading_date;

-- 2. LAG/LEAD take an offset and a default value: LAG(col, 2, 0)
--    means "2 rows back, or 0 if there aren't 2 rows back yet."
SELECT
    sensor_id,
    reading_date,
    avg_temp,
    LAG(avg_temp, 2, 0) OVER (PARTITION BY sensor_id ORDER BY reading_date) AS temp_2_days_ago_or_zero
FROM DAILY_TEMPS
ORDER BY sensor_id, reading_date;

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 9:
--
-- 1. SENSOR_001's first row (2026-06-01) has no day before it in the
--    data. What does prev_day_temp show for that row, and what does
--    next_day_temp show for SENSOR_001's LAST row (2026-06-05)? Why
--    the same value both times?
--
-- 2. Look at SENSOR_001 on 2026-06-05: it's tied exactly with the
--    previous day (both 22.3). What does day_over_day_delta show for
--    that row? Does a tie ever cause LAG to behave differently than
--    a genuine change, or does it just report 0?
--
-- 3. LAG(avg_temp, 2, 0) for SENSOR_002's first row -- there's no
--    row 2 days back, so the DEFAULT (0) kicks in instead of NULL.
--    Why might defaulting to 0 here be a genuinely bad choice for a
--    real temperature dataset, and what would you default to instead
--    if you needed a non-NULL placeholder that couldn't be confused
--    with a real reading?
-- ============================================================
