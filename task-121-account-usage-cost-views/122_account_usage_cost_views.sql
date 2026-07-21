-- ============================================================
-- Task 121 — ACCOUNT_USAGE cost views
-- Category: FinOps
-- About this category: Tasks 121-126 are about ACCOUNTABILITY for
-- spend, not just cutting it -- measuring where credits actually went,
-- attributing it to a workload, and getting alerted before a surprise
-- bill instead of after.
-- ============================================================

USE ROLE ACCOUNTADMIN;
USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;

-- 1. Credit consumption PER WAREHOUSE, per hour -- the most granular
--    view of "what did each warehouse actually cost, and when."
SELECT
    warehouse_name,
    start_time,
    end_time,
    credits_used,
    credits_used_compute,
    credits_used_cloud_services
FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY
WHERE start_time >= DATEADD('day', -7, CURRENT_TIMESTAMP())
ORDER BY start_time DESC
LIMIT 50;

-- 2. The DAILY total, across everything metered on the account
--    (warehouses, but also serverless features like Snowpipe and
--    automatic clustering) -- the number that actually reconciles
--    against a bill.
SELECT
    usage_date,
    service_type,
    SUM(credits_used) AS total_credits_used
FROM SNOWFLAKE.ACCOUNT_USAGE.METERING_DAILY_HISTORY
WHERE usage_date >= DATEADD('day', -30, CURRENT_DATE())
GROUP BY usage_date, service_type
ORDER BY usage_date DESC, total_credits_used DESC;

-- 3. Which INDIVIDUAL QUERIES were the expensive ones -- this is what
--    you'd drill into once step 1/2 tell you WHICH warehouse/day was
--    expensive, but not WHY.
SELECT
    query_id,
    query_text,
    warehouse_name,
    total_elapsed_time / 1000 AS elapsed_seconds,
    bytes_scanned,
    credits_used_cloud_services
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE warehouse_name = 'IOT_LAB_WH'
    AND start_time >= DATEADD('day', -7, CURRENT_TIMESTAMP())
ORDER BY total_elapsed_time DESC
LIMIT 20;

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 122:
--
-- 1. Step 1 (WAREHOUSE_METERING_HISTORY) and step 2
--    (METERING_DAILY_HISTORY) both report credit usage, but at
--    different grain and scope. METERING_DAILY_HISTORY includes
--    service_type values beyond just warehouse compute -- what OTHER
--    kinds of credit consumption show up there that you've directly
--    caused earlier in this lab (hint: think about Snowpipe from Tasks
--    65-68, and clustering from Task 93)?
--
-- 2. ACCOUNT_USAGE views like these have a documented LATENCY -- data
--    doesn't appear the instant it happens, unlike querying a live
--    table. If you ran a big query right now and immediately checked
--    step 3's QUERY_HISTORY view for it, would you expect to see it
--    already, or does ACCOUNT_USAGE typically lag by some period? Why
--    would a FinOps dashboard built on these views need to account for
--    that lag?
--
-- 3. Step 3 sorts by total_elapsed_time to find "expensive" queries.
--    Is elapsed time actually the same thing as CREDIT cost -- could a
--    query that ran for a long time on an XSMALL warehouse cost FEWER
--    credits than a short query on a 4XL warehouse? What would you
--    need to know about the warehouse SIZE alongside elapsed time to
--    actually estimate a query's credit cost?
-- ============================================================
