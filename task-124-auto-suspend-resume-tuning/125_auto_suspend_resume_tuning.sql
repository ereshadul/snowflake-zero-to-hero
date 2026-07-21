-- ============================================================
-- Task 124 — Tuning AUTO_SUSPEND vs. cold-start cost
-- Category: FinOps
-- Task 3's understanding check already flagged the tension: a task
-- scheduled every minute against a warehouse with AUTO_SUSPEND = 60
-- means the warehouse may never actually get to suspend at all. This
-- task tunes that tradeoff deliberately instead of leaving it as an
-- afterthought.
-- ============================================================

USE ROLE ACCOUNTADMIN;
USE DATABASE IOT_LAB;

-- 1. Check how IOT_LAB_WH's suspend/resume behavior actually looks in
--    practice -- every resume is a small cold-start cost (a few
--    seconds of provisioning before your query even starts running).
SELECT
    warehouse_name,
    start_time,
    end_time,
    DATEDIFF('second', start_time, end_time) AS duration_seconds
FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_EVENTS_HISTORY
WHERE warehouse_name = 'IOT_LAB_WH'
    AND event_name IN ('RESUME_WAREHOUSE', 'SUSPEND_WAREHOUSE')
ORDER BY start_time DESC
LIMIT 50;

-- 2. Model the actual tradeoff with two throwaway warehouses --
--    identical except for AUTO_SUSPEND. SHORT saves credits between
--    queries but eats a resume cost on every single query if queries
--    are frequent. LONG stays warm (no resume delay) but burns idle
--    credits if queries are sparse.
CREATE OR REPLACE WAREHOUSE SUSPEND_TEST_SHORT_WH
    WAREHOUSE_SIZE = 'XSMALL' AUTO_SUSPEND = 60  AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE;
CREATE OR REPLACE WAREHOUSE SUSPEND_TEST_LONG_WH
    WAREHOUSE_SIZE = 'XSMALL' AUTO_SUSPEND = 600 AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE;

-- 3. Simulate a workload that queries roughly every 90 seconds --
--    LONGER than SHORT's 60-second suspend window, so SHORT keeps
--    paying resume cost, while LONG (600s) stays warm across the whole
--    burst.
USE WAREHOUSE SUSPEND_TEST_SHORT_WH;
SELECT COUNT(*) FROM CURATED.SENSOR_READINGS_HISTORY;
-- (in a real test, wait ~90 seconds here between each query so
-- SUSPEND_TEST_SHORT_WH actually suspends and has to resume again)
SELECT COUNT(*) FROM CURATED.SENSOR_READINGS_HISTORY;

USE WAREHOUSE SUSPEND_TEST_LONG_WH;
SELECT COUNT(*) FROM CURATED.SENSOR_READINGS_HISTORY;
SELECT COUNT(*) FROM CURATED.SENSOR_READINGS_HISTORY;

-- 4. Compare resume events between the two -- this is where the
--    tradeoff becomes visible as actual numbers, not theory.
SELECT
    warehouse_name,
    COUNT(*) AS resume_count
FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_EVENTS_HISTORY
WHERE warehouse_name IN ('SUSPEND_TEST_SHORT_WH', 'SUSPEND_TEST_LONG_WH')
    AND event_name = 'RESUME_WAREHOUSE'
GROUP BY warehouse_name;

-- 5. Clean up.
USE WAREHOUSE IOT_LAB_WH;
DROP WAREHOUSE SUSPEND_TEST_SHORT_WH;
DROP WAREHOUSE SUSPEND_TEST_LONG_WH;

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 125:
--
-- 1. Task 3's task ran every MINUTE against a warehouse with
--    AUTO_SUSPEND = 60. Given step 1's real resume/suspend history for
--    IOT_LAB_WH, does a 60-second query cadence against a 60-second
--    suspend window actually let the warehouse suspend between runs at
--    all, or does it end up staying essentially always-on -- and is
--    that closer in behavior to the SHORT or LONG test warehouse from
--    step 2?
--
-- 2. A warehouse that resumes constantly (like SUSPEND_TEST_SHORT_WH
--    under a 90-second query cadence) pays a small cold-start cost
--    EVERY time. Is that cold-start cost purely wasted CREDITS, or does
--    it also cost something in query LATENCY that a user waiting on a
--    dashboard would actually notice? Which one matters more for a
--    background batch job versus an interactive BI dashboard?
--
-- 3. Given step 3's simulated ~90-second query spacing, would a
--    THIRD option -- AUTO_SUSPEND tuned to something like 120 seconds,
--    between SHORT's 60 and LONG's 600 -- actually be the right answer
--    here? What's the general principle for picking AUTO_SUSPEND: pick
--    a round number that feels safe, or tune it against the ACTUAL
--    gap between queries for this specific warehouse's real workload?
-- ============================================================
