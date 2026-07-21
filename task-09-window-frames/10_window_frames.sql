-- ============================================================
-- Task 9 — Window frame clauses (ROWS/RANGE BETWEEN)
-- Reuses DAILY_TEMPS from Task 8.
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;
USE SCHEMA ADVANCED;

-- Add a couple more days so a 3-row moving window has something to
-- actually move across.
INSERT INTO DAILY_TEMPS (sensor_id, reading_date, avg_temp) VALUES
    ('SENSOR_001', '2026-06-06', 23.1),
    ('SENSOR_001', '2026-06-07', 20.9);

-- 1. Three different frames, side by side, all on the SAME ORDER BY.
SELECT
    sensor_id,
    reading_date,
    avg_temp,
    SUM(avg_temp) OVER (
        PARTITION BY sensor_id ORDER BY reading_date
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS moving_sum_3day,
    AVG(avg_temp) OVER (
        PARTITION BY sensor_id ORDER BY reading_date
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS moving_avg_3day,
    SUM(avg_temp) OVER (
        PARTITION BY sensor_id ORDER BY reading_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total,
    AVG(avg_temp) OVER (
        PARTITION BY sensor_id ORDER BY reading_date
        ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
    ) AS centered_avg_3day
FROM DAILY_TEMPS
WHERE sensor_id = 'SENSOR_001'
ORDER BY reading_date;

-- 2. ROWS vs RANGE — the difference only shows up with ties in the
--    ORDER BY column. Order by avg_temp itself this time (SENSOR_001
--    has a genuine tie: 2026-06-04 and 2026-06-05 both hit 22.3).
SELECT
    reading_date,
    avg_temp,
    SUM(avg_temp) OVER (
        ORDER BY avg_temp
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS rows_frame_sum,
    SUM(avg_temp) OVER (
        ORDER BY avg_temp
        RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS range_frame_sum
FROM DAILY_TEMPS
WHERE sensor_id = 'SENSOR_001'
ORDER BY avg_temp;

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 10:
--
-- 1. moving_sum_3day for 2026-06-01 (the very first row) can't look
--    back 2 rows -- there's nothing there. Does Snowflake error,
--    return NULL, or just sum whatever rows actually exist in range?
--    Check the actual value and explain what ROWS BETWEEN 2 PRECEDING
--    AND CURRENT ROW means when fewer than 3 rows exist.
--
-- 2. centered_avg_3day (1 PRECEDING AND 1 FOLLOWING) for the LAST row
--    (2026-06-07) — there's no row after it. What's in that average,
--    and how many rows actually got included?
--
-- 3. Look at rows_frame_sum vs range_frame_sum for the two rows tied
--    at avg_temp = 22.3. Are they equal or different between the two
--    tied rows, and equal or different between ROWS vs RANGE for the
--    SAME row? Explain why RANGE treats tied ORDER BY values as one
--    "peer group" while ROWS treats every physical row separately,
--    even when their ORDER BY value is identical.
-- ============================================================
