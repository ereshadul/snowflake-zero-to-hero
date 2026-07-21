-- ============================================================
-- Task 22 — Reading EXPLAIN and query plans
-- Complements Task 94 (Query Profile): EXPLAIN estimates a plan
-- BEFORE running the query, at zero compute cost; Query Profile
-- shows what ACTUALLY happened after the query runs.
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;

-- 1. EXPLAIN doesn't execute the query at all -- no warehouse time
--    spent, no rows actually scanned. It just returns the plan
--    Snowflake WOULD use.
EXPLAIN
SELECT device_type, COUNT(*) AS reading_count
FROM CURATED.SENSOR_READINGS_SYNTHETIC
WHERE device_type = 'temperature'
GROUP BY device_type;

-- 2. A more structured view of the same plan.
EXPLAIN USING TABULAR
SELECT device_type, COUNT(*) AS reading_count
FROM CURATED.SENSOR_READINGS_SYNTHETIC
WHERE device_type = 'temperature'
GROUP BY device_type;

-- 3. Now actually RUN the same query, and check its real Query
--    Profile (Monitoring -> Query History -> click this query),
--    same as Task 94. Compare the estimated numbers from EXPLAIN to
--    the ACTUAL bytes scanned / rows produced you see there.
SELECT device_type, COUNT(*) AS reading_count
FROM CURATED.SENSOR_READINGS_SYNTHETIC
WHERE device_type = 'temperature'
GROUP BY device_type;

-- 4. EXPLAIN on a join, to see how Snowflake plans to combine two
--    inputs of very different size.
EXPLAIN
SELECT s.device_type, t.category, COUNT(*)
FROM CURATED.SENSOR_READINGS_SYNTHETIC s
JOIN ADVANCED.TEMP_RANGES t
    ON s.reading_value >= t.min_temp AND s.reading_value < t.max_temp
GROUP BY s.device_type, t.category;

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 23:
--
-- 1. In step 1's plan, find the operator that corresponds to the
--    `WHERE device_type = 'temperature'` filter. Is it its own
--    separate step late in the plan, or is it folded into the table
--    scan step itself? What does that placement tell you about when
--    Snowflake actually applies a simple equality filter relative to
--    reading the data off disk?
--
-- 2. Compare EXPLAIN's estimated row/byte numbers from step 1-2 to
--    the ACTUAL numbers you see in step 3's real Query Profile. Are
--    they close, exact, or noticeably different? What would explain
--    a gap between an estimate and reality here?
--
-- 3. EXPLAIN costs zero compute since nothing actually runs. Given
--    that, why wouldn't you just always run the real query and check
--    Query Profile afterward instead of ever bothering with EXPLAIN
--    first? Describe a concrete situation where seeing the plan
--    BEFORE execution is worth the extra step.
-- ============================================================
