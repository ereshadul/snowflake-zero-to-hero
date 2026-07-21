-- ============================================================
-- Task 122 — Query tagging & cost attribution
-- Category: FinOps
-- Task 121 showed you the account-wide spend. This task is about
-- attributing THAT spend back to a specific team/project -- the
-- "chargeback" question every platform team eventually gets asked.
-- ============================================================

USE ROLE ACCOUNTADMIN;
USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;

-- 1. QUERY_TAG -- a free-text label attached to every query run in a
--    session, entirely under the CALLER's control (an application,
--    a BI tool, a specific team's script).
ALTER SESSION SET QUERY_TAG = 'team=iot-analytics;project=fleet-health-dashboard';

SELECT COUNT(*) FROM CURATED.SENSOR_READINGS_HISTORY;
SELECT AVG(reading_value) FROM CURATED.SENSOR_READINGS_HISTORY;

ALTER SESSION UNSET QUERY_TAG;

-- 2. See the tag show up in query history -- this is what makes
--    attribution possible after the fact.
SELECT
    query_id,
    query_tag,
    warehouse_name,
    total_elapsed_time,
    start_time
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE query_tag = 'team=iot-analytics;project=fleet-health-dashboard'
ORDER BY start_time DESC;

-- 3. OBJECT TAGS -- a separate, governed mechanism (unlike QUERY_TAG,
--    an ADMIN assigns these, not the query's caller) for tagging
--    WAREHOUSES/DATABASES/etc. themselves with a cost center.
CREATE OR REPLACE TAG COST_CENTER;

ALTER WAREHOUSE IOT_LAB_WH SET TAG COST_CENTER = 'IOT-PLATFORM-ENG';

SHOW TAGS LIKE 'COST_CENTER';
SELECT SYSTEM$GET_TAG('COST_CENTER', 'IOT_LAB_WH', 'WAREHOUSE');

-- 4. Combine tagged warehouse spend with ACCOUNT_USAGE to get an
--    actual chargeback number -- credits used, joined out to which
--    cost center owns the warehouse that burned them.
SELECT
    t.tag_value AS cost_center,
    SUM(m.credits_used) AS total_credits_used
FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY m
JOIN SNOWFLAKE.ACCOUNT_USAGE.TAG_REFERENCES t
    ON t.object_name = m.warehouse_name
    AND t.domain = 'WAREHOUSE'
    AND t.tag_name = 'COST_CENTER'
WHERE m.start_time >= DATEADD('day', -7, CURRENT_TIMESTAMP())
GROUP BY t.tag_value;

-- 5. Clean up.
ALTER WAREHOUSE IOT_LAB_WH UNSET TAG COST_CENTER;
DROP TAG COST_CENTER;

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 123:
--
-- 1. Step 1's QUERY_TAG is set by the SESSION running the query --
--    nothing stops a careless script from forgetting to set it, or
--    setting an inconsistent value. Step 3's object TAG is instead
--    assigned once, by an admin, directly onto the warehouse object.
--    Which of the two would you trust MORE for an accurate chargeback
--    report across dozens of teams' scripts, and why?
--
-- 2. Step 4's join attributes spend to a cost center based on WHICH
--    WAREHOUSE ran the query. If two different teams, working on
--    completely different projects, both happen to share the SAME
--    warehouse (IOT_LAB_WH, in this lab), could this specific join
--    tell them apart? What would you need to change (hint: think about
--    step 1's QUERY_TAG) to attribute cost at the INDIVIDUAL QUERY
--    level instead of the whole-warehouse level?
--
-- 3. A resource monitor (Task 97) can SUSPEND a warehouse once it
--    crosses a credit threshold. Query tagging and object tags, on
--    their own, do NOT stop anything from running -- they only make
--    spend visible and attributable after the fact. What's the actual
--    difference in PURPOSE between a resource monitor and a tagging
--    strategy -- one is about preventing overspend, the other is about
--    understanding whose overspend it was. Could you use both together
--    on the same warehouse?
-- ============================================================
