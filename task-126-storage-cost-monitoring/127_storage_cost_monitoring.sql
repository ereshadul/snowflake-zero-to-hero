-- ============================================================
-- Task 126 — Storage cost monitoring
-- Category: FinOps
-- This closes out the FinOps group (121-126). Everything so far in
-- this category has been about COMPUTE (credits). Storage is billed
-- completely separately, and it's easy to forget that Time Travel,
-- Fail-safe, and clones all keep consuming storage even after you
-- think you've "deleted" something.
-- ============================================================

USE ROLE ACCOUNTADMIN;
USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;

-- 1. Account-wide storage, broken into the categories that actually
--    get billed separately.
SELECT
    usage_date,
    storage_bytes / POWER(1024, 3)            AS active_storage_gb,
    stage_bytes / POWER(1024, 3)               AS stage_storage_gb,
    failsafe_bytes / POWER(1024, 3)            AS failsafe_storage_gb
FROM SNOWFLAKE.ACCOUNT_USAGE.STORAGE_USAGE
ORDER BY usage_date DESC
LIMIT 7;

-- 2. Per-TABLE storage -- this is where Time Travel and clone storage
--    actually get attributed to a specific object, not just an account
--    total.
SELECT
    table_catalog,
    table_schema,
    table_name,
    active_bytes           / POWER(1024, 3) AS active_gb,
    time_travel_bytes      / POWER(1024, 3) AS time_travel_gb,
    failsafe_bytes         / POWER(1024, 3) AS failsafe_gb,
    retained_for_clone_bytes / POWER(1024, 3) AS clone_gb
FROM SNOWFLAKE.ACCOUNT_USAGE.TABLE_STORAGE_METRICS
WHERE table_catalog = 'IOT_LAB'
ORDER BY active_bytes DESC
LIMIT 20;

-- 3. Prove clones aren't "free" the moment the underlying data
--    diverges -- clone a table (Task 85's zero-copy clone), then
--    change the ORIGINAL, and watch retained_for_clone_bytes actually
--    grow on the clone once the two versions genuinely differ.
CREATE OR REPLACE TABLE STORAGE_DEMO_SOURCE AS
SELECT * FROM CURATED.SENSOR_READINGS_HISTORY LIMIT 100000;

CREATE OR REPLACE TABLE STORAGE_DEMO_CLONE CLONE STORAGE_DEMO_SOURCE;

-- Right after cloning, the clone shares storage with the source --
-- close to zero INCREMENTAL bytes of its own.
SELECT table_name, active_bytes / POWER(1024, 3) AS active_gb
FROM SNOWFLAKE.ACCOUNT_USAGE.TABLE_STORAGE_METRICS
WHERE table_name IN ('STORAGE_DEMO_SOURCE', 'STORAGE_DEMO_CLONE');

DELETE FROM STORAGE_DEMO_SOURCE WHERE event_id IN (
    SELECT event_id FROM STORAGE_DEMO_SOURCE LIMIT 50000
);
-- The deleted rows are gone from STORAGE_DEMO_SOURCE's active storage,
-- but STORAGE_DEMO_CLONE still references them -- that divergence is
-- what starts costing incremental storage. (ACCOUNT_USAGE lags, so
-- re-check this a bit later.)

-- 4. Clean up.
DROP TABLE STORAGE_DEMO_CLONE;
DROP TABLE STORAGE_DEMO_SOURCE;

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 127:
--
-- 1. Step 1 breaks storage into active/stage/failsafe categories. Task
--    83-87 covered Time Travel's DATA_RETENTION_TIME_IN_DAYS as a
--    cost-tunable setting. Is Fail-safe (the 7-day post-Time-Travel
--    recovery period) something YOU can shorten the same way, or is it
--    a fixed cost you have no control over for permanent tables?
--
-- 2. Step 3 deleted rows from STORAGE_DEMO_SOURCE after cloning. The
--    clone still needs to be able to show those rows (that's the whole
--    point of a clone being an independent snapshot). Whose storage
--    "bill" do those now-divergent rows count against -- the ORIGINAL
--    table's, the CLONE's, or does it get billed once and shared
--    between them the way it was immediately after cloning?
--
-- 3. Given everything in Tasks 121-126 (metering history, tagging,
--    right-sizing, auto-suspend tuning, budgets, and now storage),
--    which category of spend in THIS LAB'S OWN account is more likely
--    to dominate the bill: compute credits from a MEDIUM warehouse
--    running for a few minutes at a time, or storage for a
--    50-million-row table sitting there 24/7 with Time Travel and
--    Fail-safe retention on top? What would you actually check first
--    if asked to cut this account's costs by 20%?
-- ============================================================
