-- ============================================================
-- Task 85 — Zero-copy clone (table)
-- Category: Time Travel & cloning
-- Uses CURATED.SENSOR_READINGS_SYNTHETIC (50M+ rows, from Task 2/3)
-- deliberately -- cloning a genuinely large table is where "instant,
-- no storage duplication" actually means something.
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;

-- 1. Clone a 50-million-row table. Time this -- it should complete in
--    roughly the same time regardless of the source table's size.
CREATE OR REPLACE TABLE CURATED.SENSOR_READINGS_SYNTHETIC_CLONE
    CLONE CURATED.SENSOR_READINGS_SYNTHETIC;

SELECT COUNT(*) AS clone_row_count FROM CURATED.SENSOR_READINGS_SYNTHETIC_CLONE;
SELECT COUNT(*) AS original_row_count FROM CURATED.SENSOR_READINGS_SYNTHETIC;
-- Both should match immediately.

-- 2. Modify ONLY the clone.
DELETE FROM CURATED.SENSOR_READINGS_SYNTHETIC_CLONE WHERE device_type = 'temperature';

-- 3. Confirm the original is completely unaffected.
SELECT COUNT(*) AS clone_row_count_after_delete FROM CURATED.SENSOR_READINGS_SYNTHETIC_CLONE;
SELECT COUNT(*) AS original_row_count_unchanged FROM CURATED.SENSOR_READINGS_SYNTHETIC;

-- 4. Clean up — this clone has now diverged and is holding its own
--    storage for the deleted rows (until ITS OWN Time Travel/Fail-safe
--    expires). Drop it once you're done with the exercise.
DROP TABLE CURATED.SENSOR_READINGS_SYNTHETIC_CLONE;

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 86:
--
-- 1. How long did step 1's CREATE TABLE ... CLONE actually take, on a
--    50-million-row source table? Compare that (in principle, you
--    don't need to actually run it) to how long
--    CREATE TABLE ... AS SELECT * FROM the same source would take
--    instead. Why is CLONE so much faster for a table this size?
--
-- 2. Step 3 confirms the original table's row count never changed,
--    even though you deleted rows from the clone. What underlying
--    mechanism makes this possible — does CLONE immediately duplicate
--    ALL of the original's physical storage the moment it runs, or
--    does something more selective happen, only once data actually
--    starts to diverge?
--
-- 3. You dropped the clone in step 4. Given the clone's own
--    DATA_RETENTION_TIME_IN_DAYS and Fail-safe period (same rules as
--    any other permanent table, Task 35), does DROP TABLE instantly
--    stop it from costing anything at all, or does some storage
--    linger for a while after the drop? What would you check to find
--    out for sure?
-- ============================================================
