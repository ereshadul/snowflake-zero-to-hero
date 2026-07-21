-- ============================================================
-- Task 89 — Custom roles & grants
-- Category: Security
-- The key technique: GRANT ... ON FUTURE TABLES, so a role
-- automatically gets access to tables that don't exist yet.
-- ============================================================

USE ROLE ACCOUNTADMIN;
USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;

CREATE ROLE IF NOT EXISTS REPORTING_ROLE;
GRANT USAGE ON DATABASE IOT_LAB TO ROLE REPORTING_ROLE;
GRANT USAGE ON SCHEMA IOT_LAB.ADVANCED TO ROLE REPORTING_ROLE;

-- 1. SELECT on every table that exists RIGHT NOW.
GRANT SELECT ON ALL TABLES IN SCHEMA IOT_LAB.ADVANCED TO ROLE REPORTING_ROLE;

-- 2. SELECT on every table created LATER, automatically -- no future
--    GRANT statement needed per new table.
GRANT SELECT ON FUTURE TABLES IN SCHEMA IOT_LAB.ADVANCED TO ROLE REPORTING_ROLE;

GRANT ROLE REPORTING_ROLE TO ROLE SYSADMIN;
GRANT ROLE REPORTING_ROLE TO USER <your_username>;

-- 3. Create a BRAND NEW table, AFTER the future grant was issued.
CREATE OR REPLACE TABLE IOT_LAB.ADVANCED.FUTURE_GRANT_TEST (id INT);
INSERT INTO IOT_LAB.ADVANCED.FUTURE_GRANT_TEST (id) VALUES (1);

-- 4. Confirm REPORTING_ROLE can query it with zero additional grants.
USE ROLE REPORTING_ROLE;
SELECT * FROM IOT_LAB.ADVANCED.FUTURE_GRANT_TEST;
USE ROLE ACCOUNTADMIN;

-- 5. Revoke the CURRENT-tables grant and see what still works.
REVOKE SELECT ON ALL TABLES IN SCHEMA IOT_LAB.ADVANCED FROM ROLE REPORTING_ROLE;

USE ROLE REPORTING_ROLE;
SELECT * FROM IOT_LAB.ADVANCED.GAME_SCORES;        -- was this revoked?
SELECT * FROM IOT_LAB.ADVANCED.FUTURE_GRANT_TEST;  -- was THIS revoked?
USE ROLE ACCOUNTADMIN;

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 90:
--
-- 1. Confirm step 4's SELECT succeeded on a table that didn't even
--    exist when the FUTURE grant (step 2) was issued. Does "FUTURE"
--    mean "current tables plus ones created later," or ONLY tables
--    created after the grant?
--
-- 2. After step 5's REVOKE, do BOTH queries in step 5 fail, or only
--    one of them? What does that tell you about whether
--    "REVOKE ... ON ALL TABLES" also un-does a separate
--    "GRANT ... ON FUTURE TABLES" grant, or whether those are two
--    genuinely independent grants that each need their own revoke?
--
-- 3. In a real pipeline where new tables get created constantly
--    (think of everything this repo alone has created), what tedious,
--    error-prone manual process does "GRANT ... ON FUTURE TABLES"
--    eliminate? What would go wrong in practice if a team relied only
--    on "GRANT ... ON ALL TABLES," re-run occasionally, instead?
-- ============================================================
