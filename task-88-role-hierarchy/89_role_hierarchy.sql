-- ============================================================
-- Task 88 — Role hierarchy
-- Category: Security
--
-- About this category: Tasks 88-92 cover who can see and do what --
-- roles, grants, row-level and column-level restrictions. Every task
-- so far has run as ACCOUNTADMIN; this category is about NOT doing
-- that in a real project.
-- ============================================================

USE ROLE ACCOUNTADMIN;
USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;

-- 1. Two custom roles, one nested inside the other.
CREATE ROLE IF NOT EXISTS DATA_ANALYST_ROLE;
CREATE ROLE IF NOT EXISTS DATA_ANALYST_LEAD_ROLE;

GRANT ROLE DATA_ANALYST_ROLE TO ROLE DATA_ANALYST_LEAD_ROLE;

-- 2. Give the BASE role a real privilege -- notice the LEAD role never
--    gets this grant directly.
GRANT USAGE ON DATABASE IOT_LAB TO ROLE DATA_ANALYST_ROLE;
GRANT USAGE ON SCHEMA IOT_LAB.ADVANCED TO ROLE DATA_ANALYST_ROLE;
GRANT SELECT ON TABLE IOT_LAB.ADVANCED.GAME_SCORES TO ROLE DATA_ANALYST_ROLE;

-- 3. Anchor this custom hierarchy under SYSADMIN -- the standard
--    practice so ACCOUNTADMIN retains visibility into every custom
--    role that exists, instead of orphaned roles nobody in the
--    built-in hierarchy can see.
GRANT ROLE DATA_ANALYST_LEAD_ROLE TO ROLE SYSADMIN;

-- 4. Grant the LEAD role to your own user so you can actually test it
--    (replace with your real username).
GRANT ROLE DATA_ANALYST_LEAD_ROLE TO USER <your_username>;

-- 5. Inspect the hierarchy from both directions.
SHOW GRANTS OF ROLE DATA_ANALYST_ROLE;       -- who/what HAS this role
SHOW GRANTS TO ROLE DATA_ANALYST_LEAD_ROLE;  -- what THIS role has

-- 6. Test inheritance directly: switch to the LEAD role and try to
--    query a table the grant was only ever given to the BASE role.
USE ROLE DATA_ANALYST_LEAD_ROLE;
SELECT * FROM IOT_LAB.ADVANCED.GAME_SCORES LIMIT 3;

USE ROLE ACCOUNTADMIN;

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 89:
--
-- 1. Confirm step 6's SELECT actually succeeded under
--    DATA_ANALYST_LEAD_ROLE, even though SELECT was granted only to
--    DATA_ANALYST_ROLE. Which single statement (step 1) made that
--    inheritance possible?
--
-- 2. Why is it common practice to anchor a custom role hierarchy under
--    SYSADMIN (step 3) rather than leaving it disconnected from the
--    built-in role tree entirely? What would ACCOUNTADMIN lose
--    visibility into if that GRANT never happened?
--
-- 3. Compare SHOW GRANTS OF ROLE (step 5, first query) to
--    SHOW GRANTS TO ROLE (step 5, second query). What's the actual
--    difference in what each reports?
-- ============================================================
