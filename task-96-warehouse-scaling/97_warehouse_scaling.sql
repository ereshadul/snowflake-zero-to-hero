-- ============================================================
-- Task 96 — Warehouse scaling up vs. out
-- Category: Performance & cost
-- Task 2 already empirically tested SCALE UP (SMALL vs. MEDIUM for
-- ONE query). This task is about SCALE OUT -- multiple clusters of
-- the SAME size, for CONCURRENCY, not single-query speed.
-- ============================================================

USE DATABASE IOT_LAB;
USE ROLE ACCOUNTADMIN;

-- 1. A multi-cluster warehouse -- MIN/MAX_CLUSTER_COUNT lets
--    Snowflake spin up ADDITIONAL clusters of this SAME size when
--    queries start queueing, instead of making any one query faster.
CREATE OR REPLACE WAREHOUSE MULTI_CLUSTER_DEMO_WH
    WAREHOUSE_SIZE   = 'XSMALL'
    MIN_CLUSTER_COUNT = 1
    MAX_CLUSTER_COUNT = 3
    SCALING_POLICY    = 'STANDARD'
    AUTO_SUSPEND      = 60
    AUTO_RESUME       = TRUE;

-- 2. Whether scale-out ever actually helps depends on whether queries
--    are QUEUING (waiting for a free slot) rather than just running
--    slowly. Check IOT_LAB_WH's real load history for signs of this.
SELECT *
FROM TABLE(INFORMATION_SCHEMA.WAREHOUSE_LOAD_HISTORY(
    WAREHOUSE_NAME    => 'IOT_LAB_WH',
    DATE_RANGE_START  => DATEADD('hour', -24, CURRENT_TIMESTAMP())
));
-- Look specifically at AVG_RUNNING vs. AVG_QUEUED_LOAD per time slice.

-- 3. Clean up -- this warehouse was only for the syntax demo.
DROP WAREHOUSE MULTI_CLUSTER_DEMO_WH;

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 97:
--
-- 1. In step 2's results, do you see any AVG_QUEUED_LOAD greater than
--    0 for IOT_LAB_WH? Given this whole lab has mostly been one
--    person running queries sequentially (not many people hitting the
--    same warehouse at once), would you actually expect to see
--    queueing here at all?
--
-- 2. MULTI_CLUSTER_DEMO_WH was created with MIN_CLUSTER_COUNT = 1,
--    MAX_CLUSTER_COUNT = 3. Under what specific circumstance does
--    Snowflake actually spin up a 2nd or 3rd cluster? Does simply
--    making a warehouse multi-cluster-CAPABLE cost anything extra if
--    it never actually needs more than 1 cluster running?
--
-- 3. Task 2 found MEDIUM ran a 50-million-row generation query ~2x
--    faster than SMALL — a genuine scale-UP win. Would adding MORE
--    CLUSTERS (scale-OUT) to a SMALL warehouse have sped up that SAME
--    single query at all? What's the fundamental difference between
--    "more clusters" and "one bigger cluster" for a query that's one
--    sequential unit of work, not many separate concurrent ones?
-- ============================================================
