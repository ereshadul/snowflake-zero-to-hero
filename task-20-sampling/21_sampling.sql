-- ============================================================
-- Task 20 — Sampling (SAMPLE / TABLESAMPLE)
-- Uses CURATED.SENSOR_READINGS_SYNTHETIC from Task 2/3 -- you need a
-- genuinely large table for the timing difference in step 2 to be
-- visible at all.
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;

SELECT COUNT(*) AS baseline_row_count FROM CURATED.SENSOR_READINGS_SYNTHETIC;

-- 1. BERNOULLI (row) sampling -- every row independently has an X%
--    chance of being included. SAMPLE and TABLESAMPLE are synonyms;
--    ROW is a synonym for BERNOULLI.
SELECT COUNT(*) AS bernoulli_1pct
FROM CURATED.SENSOR_READINGS_SYNTHETIC SAMPLE BERNOULLI (1);

-- 2. SYSTEM (block) sampling -- includes or excludes whole
--    micro-partitions at once. SYSTEM and BLOCK are synonyms.
SELECT COUNT(*) AS system_1pct
FROM CURATED.SENSOR_READINGS_SYNTHETIC SAMPLE SYSTEM (1);

-- Look at both queries in Monitoring -> Query History (or the Query
-- Profile, same as Task 94) and compare their actual elapsed time and
-- bytes scanned -- not just the row counts above.

-- 3. A fixed row count instead of a percentage.
SELECT COUNT(*) AS fixed_1000
FROM (SELECT * FROM CURATED.SENSOR_READINGS_SYNTHETIC SAMPLE (1000 ROWS));

-- 4. REPEATABLE makes a sample reproducible across runs, given the
--    exact same seed and the exact same underlying data.
SELECT sensor_id, event_timestamp
FROM CURATED.SENSOR_READINGS_SYNTHETIC SAMPLE BERNOULLI (0.001) REPEATABLE (42)
ORDER BY sensor_id
LIMIT 5;
-- Run this exact statement a second time and compare the 5 rows.

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 21:
--
-- 1. Compare the actual elapsed time (from Query History) of the
--    BERNOULLI(1) query vs. the SYSTEM(1) query in steps 1-2. Which
--    one is faster on your table, and by roughly how much? Relate
--    this to what BERNOULLI has to evaluate (every individual row)
--    vs. what SYSTEM has to evaluate (whole micro-partitions) --
--    the same partition-pruning idea from Task 93's clustering task.
--
-- 2. Run step 4 twice. Do you get the exact same 5 rows both times?
--    Now try it WITHOUT the REPEATABLE clause, twice. Same rows or
--    different? What does REPEATABLE actually pin down?
--
-- 3. Step 3 asks for exactly 1000 rows via `SAMPLE (1000 ROWS)`. Does
--    COUNT(*) actually come back as exactly 1000, or approximately
--    1000? What does that tell you about whether the ROWS form
--    guarantees an exact count or just a target?
-- ============================================================
