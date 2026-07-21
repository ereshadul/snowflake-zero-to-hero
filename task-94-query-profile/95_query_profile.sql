-- ============================================================
-- Task 94 — Query profile
-- Category: Performance & cost
-- Deliberately builds an inefficient query -- a non-selective JOIN
-- condition that causes real row explosion -- so there's something
-- genuine to find in the profile, not a query that's already fine.
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;
USE SCHEMA ADVANCED;

CREATE OR REPLACE TABLE QUERY_PROFILE_DEMO AS
SELECT * FROM CURATED.SENSOR_READINGS_SYNTHETIC SAMPLE (100000 ROWS);

-- A deliberately bad join: device_type only has ~6 distinct values, so
-- this join condition matches roughly 1/6 of the OTHER side for every
-- row -- a genuine row explosion, not a selective join.
SELECT COUNT(*)
FROM QUERY_PROFILE_DEMO a
JOIN QUERY_PROFILE_DEMO b ON a.device_type = b.device_type;

-- Now open this query's Query Profile: Monitoring -> Query History ->
-- click this query -> Query Profile tab.

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 95:
--
-- 1. Which single operator in the profile graph accounts for the
--    largest percentage of total execution time? Click into it and
--    read the row counts flowing IN vs. OUT of that operator.
--
-- 2. Check whether this query spilled any bytes to local or remote
--    storage (visible in the operator detail panel). If it did, what
--    does spilling indicate about whether IOT_LAB_WH was big enough
--    for this specific query -- and what would you check next (Task
--    96 covers this) before deciding to just resize the warehouse up?
--
-- 3. Compare the row count feeding INTO the join operator (should be
--    close to 100,000 x 2, one side each) to the row count coming
--    OUT of it. By roughly what factor did the row count explode,
--    given ~6 distinct device_type values? If the join condition
--    instead matched on a genuinely unique column, what would you
--    expect that output row count to look like instead?
-- ============================================================
