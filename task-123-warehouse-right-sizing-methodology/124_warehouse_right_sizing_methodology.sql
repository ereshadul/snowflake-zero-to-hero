-- ============================================================
-- Task 123 — A repeatable warehouse right-sizing methodology
-- Category: FinOps
-- Task 2 ran ONE test: SMALL vs. MEDIUM on a single big query, ad hoc.
-- This task turns that into a repeatable PROCESS you'd actually run
-- whenever someone asks "should we upsize this warehouse."
-- ============================================================

USE ROLE ACCOUNTADMIN;
USE DATABASE IOT_LAB;

-- 1. STEP ONE of the methodology: never guess -- measure the CURRENT
--    warehouse's actual behavior first. Queuing is the single biggest
--    signal that a warehouse is UNDERSIZED for its concurrency (Task
--    96 covered this same signal for scale-OUT decisions).
SELECT
    warehouse_name,
    DATE_TRUNC('hour', start_time) AS hour,
    AVG(avg_running)      AS avg_running,
    AVG(avg_queued_load)  AS avg_queued_load
FROM TABLE(INFORMATION_SCHEMA.WAREHOUSE_LOAD_HISTORY(
    WAREHOUSE_NAME   => 'IOT_LAB_WH',
    DATE_RANGE_START => DATEADD('day', -7, CURRENT_TIMESTAMP())
))
GROUP BY warehouse_name, DATE_TRUNC('hour', start_time)
ORDER BY hour DESC;

-- 2. STEP TWO: for a SPECIFIC slow query (not general concurrency),
--    check whether it's actually bottlenecked on COMPUTE (more/bigger
--    nodes would help) or on something upsizing can't fix at all --
--    read the Query Profile (Task 94) for the slowest query from Task
--    121's QUERY_HISTORY pull, looking specifically for spilling to
--    local/remote storage (a sign the warehouse is too small for the
--    working set) versus a query that's simply I/O-bound on scanning
--    a huge unfiltered table (upsizing barely helps that at all).

-- 3. STEP THREE: run the CONTROLLED comparison itself, holding
--    everything but warehouse size constant -- this is Task 2's test,
--    formalized as a repeatable procedure instead of a one-off.
CREATE OR REPLACE WAREHOUSE RIGHTSIZE_TEST_SMALL_WH
    WAREHOUSE_SIZE = 'SMALL' AUTO_SUSPEND = 60 AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE;
CREATE OR REPLACE WAREHOUSE RIGHTSIZE_TEST_MEDIUM_WH
    WAREHOUSE_SIZE = 'MEDIUM' AUTO_SUSPEND = 60 AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE;

USE WAREHOUSE RIGHTSIZE_TEST_SMALL_WH;
SELECT sensor_id, AVG(reading_value), COUNT(*)
FROM CURATED.SENSOR_READINGS_HISTORY
GROUP BY sensor_id;

USE WAREHOUSE RIGHTSIZE_TEST_MEDIUM_WH;
SELECT sensor_id, AVG(reading_value), COUNT(*)
FROM CURATED.SENSOR_READINGS_HISTORY
GROUP BY sensor_id;

-- 4. STEP FOUR: turn elapsed time into a COST comparison, not just a
--    speed comparison -- MEDIUM costs 2 credits/hour to SMALL's 1, so
--    "twice as fast" is cost-NEUTRAL, and "less than twice as fast" is
--    a genuine loss even though it finished sooner.
SELECT
    warehouse_name,
    query_id,
    total_elapsed_time / 1000 AS elapsed_seconds
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE warehouse_name IN ('RIGHTSIZE_TEST_SMALL_WH', 'RIGHTSIZE_TEST_MEDIUM_WH')
ORDER BY start_time DESC
LIMIT 5;

-- 5. Clean up.
USE WAREHOUSE IOT_LAB_WH;
DROP WAREHOUSE RIGHTSIZE_TEST_SMALL_WH;
DROP WAREHOUSE RIGHTSIZE_TEST_MEDIUM_WH;

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 124:
--
-- 1. Step 1 checks for QUEUING, and step 2/3 check for a single
--    query's raw SPEED on different sizes. These are testing for TWO
--    DIFFERENT problems. If step 1 shows real queuing but a single
--    query in step 3 runs fine on SMALL, would upsizing to MEDIUM
--    actually fix the queuing problem, or is that Task 96's
--    scale-OUT territory instead?
--
-- 2. Step 4's framing: MEDIUM costs 2x SMALL's credits per hour. If
--    MEDIUM ran a query in exactly HALF the time SMALL took, what's the
--    actual credit cost difference between the two runs? What would
--    the query need to do (relative speed vs. size) for upsizing to be
--    a genuine credit-cost WIN, not just a wall-clock-time win?
--
-- 3. This methodology has four explicit steps, in a specific order
--    (measure queuing, profile the query, run a controlled test,
--    convert to cost). Why does profiling the SPECIFIC slow query
--    (step 2) before running the controlled size comparison (step 3)
--    matter -- what would you risk wasting time and credits on if you
--    skipped straight to "just try a bigger warehouse and see"?
-- ============================================================
