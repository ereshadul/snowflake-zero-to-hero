-- ============================================================
-- Task 90 — Row access policies
-- Category: Security
-- Reuses QUARTERLY_SALES (Task 11). Same table, same query, two
-- different roles see two different subsets of rows.
-- ============================================================

USE ROLE ACCOUNTADMIN;
USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;
USE SCHEMA ADVANCED;

-- 1. A mapping table -- which role is allowed to see which region.
--    More maintainable than hardcoding role names inside the policy
--    logic itself.
CREATE OR REPLACE TABLE ROLE_REGION_MAPPING (role_name STRING, allowed_region STRING);
INSERT INTO ROLE_REGION_MAPPING (role_name, allowed_region) VALUES
    ('EAST_ANALYST_ROLE', 'East'),
    ('WEST_ANALYST_ROLE', 'West');

-- 2. The policy itself -- admins bypass it entirely, everyone else is
--    checked against the mapping table.
CREATE OR REPLACE ROW ACCESS POLICY REGION_RESTRICTION_POLICY
AS (region STRING) RETURNS BOOLEAN ->
    CURRENT_ROLE() IN ('ACCOUNTADMIN', 'SYSADMIN')
    OR EXISTS (
        SELECT 1 FROM ROLE_REGION_MAPPING
        WHERE role_name = CURRENT_ROLE() AND allowed_region = region
    );

ALTER TABLE QUARTERLY_SALES ADD ROW ACCESS POLICY REGION_RESTRICTION_POLICY ON (region);

-- 3. A role that should only ever see East rows.
CREATE ROLE IF NOT EXISTS EAST_ANALYST_ROLE;
GRANT USAGE ON DATABASE IOT_LAB TO ROLE EAST_ANALYST_ROLE;
GRANT USAGE ON SCHEMA IOT_LAB.ADVANCED TO ROLE EAST_ANALYST_ROLE;
GRANT SELECT ON TABLE IOT_LAB.ADVANCED.QUARTERLY_SALES TO ROLE EAST_ANALYST_ROLE;
GRANT ROLE EAST_ANALYST_ROLE TO ROLE SYSADMIN;
GRANT ROLE EAST_ANALYST_ROLE TO USER <your_username>;

-- 4. Same query, two different roles.
USE ROLE EAST_ANALYST_ROLE;
SELECT * FROM IOT_LAB.ADVANCED.QUARTERLY_SALES;

USE ROLE ACCOUNTADMIN;
SELECT * FROM IOT_LAB.ADVANCED.QUARTERLY_SALES;

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 91:
--
-- 1. Confirm EAST_ANALYST_ROLE saw ONLY 'East' rows while
--    ACCOUNTADMIN saw every region, from the exact same SELECT
--    statement against the exact same table. Is this filtering
--    something the ROLE has to add itself (a WHERE clause), or does
--    it happen transparently underneath any query that role runs?
--
-- 2. What would WEST_ANALYST_ROLE see if you granted it access to
--    QUERY QUARTERLY_SALES but ROLE_REGION_MAPPING had no row for it
--    yet (say, someone forgot to add it)? Would that role see ALL
--    rows, ZERO rows, or get an error? Reason through the policy's
--    EXISTS(...) logic to answer, then confirm by testing it.
--
-- 3. This policy checks a MAPPING TABLE rather than hardcoding role
--    names directly in CASE/IF logic inside the policy itself. What's
--    the practical advantage of that, specifically for a security
--    team that needs to add or remove role/region assignments over
--    time without ever touching the policy definition?
-- ============================================================
