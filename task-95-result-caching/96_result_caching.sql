-- ============================================================
-- Task 95 — Result caching
-- Category: Performance & cost
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;

-- 1. Run this, note the elapsed time (bottom-right in Snowsight).
SELECT COUNT(*), AVG(reading_value)
FROM CURATED.SENSOR_READINGS_SYNTHETIC
WHERE device_type = 'temperature';

-- 2. Run the EXACT same query again, unchanged.
SELECT COUNT(*), AVG(reading_value)
FROM CURATED.SENSOR_READINGS_SYNTHETIC
WHERE device_type = 'temperature';

-- 3. Run it again, with a trivial whitespace difference (an extra
--    space at the end of this line).
SELECT COUNT(*), AVG(reading_value)
FROM CURATED.SENSOR_READINGS_SYNTHETIC
WHERE device_type = 'temperature';

-- 4. Now actually change the underlying data.
INSERT INTO CURATED.SENSOR_READINGS_SYNTHETIC
SELECT
    UUID_STRING(),
    'SENSOR_' || LPAD(MOD(SEQ4(), 5000)::STRING, 5, '0'),
    'temperature',
    CURRENT_TIMESTAMP()::TIMESTAMP_NTZ,
    ROUND(UNIFORM(-40, 150, RANDOM())::FLOAT, 3),
    UNIFORM(0, 100, RANDOM()),
    ROUND(UNIFORM(-110, -30, RANDOM())::FLOAT, 1),
    OBJECT_CONSTRUCT('calibration_offset', 0, 'alerts', ARRAY_CONSTRUCT())
FROM TABLE(GENERATOR(ROWCOUNT => 1));

-- 5. Re-run the ORIGINAL exact query text from step 1 again.
SELECT COUNT(*), AVG(reading_value)
FROM CURATED.SENSOR_READINGS_SYNTHETIC
WHERE device_type = 'temperature';

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 96:
--
-- 1. Compare the elapsed times across steps 1, 2, and 3. Did step 3
--    (with the trivial trailing-whitespace difference) still get a
--    fast, cached result, or did it get recomputed like step 1? What
--    does that tell you about exactly how strictly Snowflake matches
--    query text before reusing a cached result?
--
-- 2. Compare step 5's elapsed time to step 2's. After step 4 inserted
--    one new row, did the EXACT ORIGINAL query text still hit the
--    cache, or did it recompute? What does that confirm invalidates a
--    cached result?
--
-- 3. Result caching is genuinely free — a cache hit costs zero
--    compute. Given questions 1 and 2, why can't you rely on it as
--    your main performance strategy for a report that runs
--    repeatedly? Think about both the whitespace-sensitivity you just
--    found and the fact that cached results expire after a fixed
--    window (24 hours) regardless of anything else.
-- ============================================================
