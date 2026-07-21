-- ============================================================
-- Task 125 — Snowflake Budgets & spend notifications
-- Category: FinOps
-- Task 97's Resource Monitor stops a WAREHOUSE from spending past a
-- threshold. A Budget is broader and softer: it watches spend across
-- an arbitrary set of objects (not just one warehouse) and only
-- NOTIFIES -- it never suspends anything itself.
-- ============================================================

USE ROLE ACCOUNTADMIN;
USE DATABASE IOT_LAB;

-- 1. A notification integration -- reused from Task 62's email
--    alerting, needed here so a Budget has somewhere to send its
--    warning.
CREATE OR REPLACE NOTIFICATION INTEGRATION BUDGET_EMAIL_INT
    TYPE = EMAIL
    ENABLED = TRUE;

-- 2. A Budget -- a spend threshold that can watch MULTIPLE objects at
--    once (unlike a Resource Monitor, which attaches to warehouses
--    specifically). Snowflake ships a built-in SNOWFLAKE.CORE.BUDGET
--    object type for this.
CREATE OR REPLACE SNOWFLAKE.CORE.BUDGET IOT_LAB_MONTHLY_BUDGET()
    -- Budgets are configured mainly through Snowsight's UI/the
    -- BUDGET.ADD_RESOURCE / SET_SPENDING_LIMIT procedures, since the
    -- object type wraps a fair amount of managed state. The essential
    -- calls:
;

CALL IOT_LAB_MONTHLY_BUDGET!SET_SPENDING_LIMIT(500);

CALL IOT_LAB_MONTHLY_BUDGET!ADD_RESOURCE(
    SYSTEM$REFERENCE('WAREHOUSE', 'IOT_LAB_WH', 'SESSION', 'ALL')
);

CALL IOT_LAB_MONTHLY_BUDGET!SET_NOTIFICATION_INTEGRATION('BUDGET_EMAIL_INT');

-- 3. Check what the Budget is actually tracking, and how much of the
--    limit has been consumed so far this period.
CALL IOT_LAB_MONTHLY_BUDGET!GET_SPENDING_LIMIT();
SELECT * FROM TABLE(IOT_LAB_MONTHLY_BUDGET!GET_ACTIVITY());

-- 4. Clean up.
DROP SNOWFLAKE.CORE.BUDGET IF EXISTS IOT_LAB_MONTHLY_BUDGET;
DROP NOTIFICATION INTEGRATION IF EXISTS BUDGET_EMAIL_INT;

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 126:
--
-- 1. Task 97's Resource Monitor can be configured to DO
--    SUSPEND/SUSPEND_IMMEDIATE once a threshold is crossed. Does a
--    Budget do anything equivalent -- can it stop a warehouse from
--    running, or does crossing SET_SPENDING_LIMIT's threshold only
--    ever result in a NOTIFICATION? What does that difference tell you
--    about when you'd reach for a Resource Monitor versus a Budget?
--
-- 2. Step 2's ADD_RESOURCE attached ONE warehouse to this Budget, but
--    the same Budget object can have MULTIPLE resources added to it --
--    warehouses, but also (depending on account features) other
--    billable object types. Task 97's Resource Monitor, by contrast,
--    attaches directly to warehouses only. If a team wanted a single
--    "are we on track this month" view spanning several DIFFERENT cost
--    sources, which of the two objects fits that need better?
--
-- 3. This Budget was set to a flat $500-equivalent SET_SPENDING_LIMIT
--    for the whole account period. Task 122 covered attributing spend
--    to a specific cost center via tags. Could a Budget alone tell you
--    WHICH team's workload actually caused a spend spike, or would you
--    still need Task 122's tagging approach layered on top to answer
--    that follow-up question once the Budget alert fires?
-- ============================================================
