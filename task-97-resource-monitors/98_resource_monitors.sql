-- ============================================================
-- Task 97 — Resource monitors
-- Category: Performance & cost
-- ============================================================

USE ROLE ACCOUNTADMIN;
USE DATABASE IOT_LAB;

-- 1. A resource monitor with staged actions -- notify quietly first,
--    then actually stop new work, then stop everything.
CREATE OR REPLACE RESOURCE MONITOR LAB_MONITOR
    WITH CREDIT_QUOTA = 50
    FREQUENCY = MONTHLY
    START_TIMESTAMP = IMMEDIATELY
    TRIGGERS
        ON 50 PERCENT  DO NOTIFY
        ON 75 PERCENT  DO NOTIFY
        ON 100 PERCENT DO SUSPEND
        ON 110 PERCENT DO SUSPEND_IMMEDIATE;

-- 2. Attach it to the warehouse this whole lab has been running on.
ALTER WAREHOUSE IOT_LAB_WH SET RESOURCE_MONITOR = LAB_MONITOR;

SHOW RESOURCE MONITORS;
SHOW WAREHOUSES LIKE 'IOT_LAB_WH';
-- Look at the "resource_monitor" column.

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 98:
--
-- 1. Look up the documented difference between the SUSPEND action
--    (triggered at 100% here) and SUSPEND_IMMEDIATE (triggered at
--    110%). What happens to a query that's ALREADY RUNNING when each
--    one fires — does SUSPEND let it finish, and does
--    SUSPEND_IMMEDIATE actually cancel it mid-execution?
--
-- 2. This resource monitor is attached to ONE warehouse
--    (IOT_LAB_WH). Could the same monitor be attached to MULTIPLE
--    warehouses at once? If so, does the CREDIT_QUOTA apply
--    separately to each warehouse, or as one shared pool across all
--    warehouses using that monitor?
--
-- 3. Check your trial's remaining credit balance in Snowsight. Why
--    would setting up a resource monitor with a modest CREDIT_QUOTA
--    (like 50) be a genuinely smart practice on a TRIAL account
--    specifically, even though you're not paying real money out of
--    pocket beyond what the trial already grants?
-- ============================================================
