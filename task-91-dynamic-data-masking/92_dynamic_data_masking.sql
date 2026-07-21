-- ============================================================
-- Task 91 — Dynamic data masking
-- Category: Security
-- Reuses CUSTOMER_PROD (Task 63). One physical copy of the data,
-- two roles see it completely differently.
-- ============================================================

USE ROLE ACCOUNTADMIN;
USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;
USE SCHEMA ADVANCED;

-- 1. The masking policy -- privileged roles see the real value,
--    everyone else gets the domain only.
CREATE OR REPLACE MASKING POLICY EMAIL_MASK AS (val STRING) RETURNS STRING ->
    CASE
        WHEN CURRENT_ROLE() IN ('ACCOUNTADMIN', 'SYSADMIN', 'PII_VIEWER_ROLE') THEN val
        ELSE REGEXP_REPLACE(val, '^.+(@.+)$', '***\\1')
    END;

ALTER TABLE CUSTOMER_PROD MODIFY COLUMN email SET MASKING POLICY EMAIL_MASK;

-- 2. Two roles with otherwise identical access to this table.
CREATE ROLE IF NOT EXISTS PII_VIEWER_ROLE;
CREATE ROLE IF NOT EXISTS GENERAL_ANALYST_ROLE;
GRANT USAGE ON DATABASE IOT_LAB TO ROLE PII_VIEWER_ROLE;
GRANT USAGE ON DATABASE IOT_LAB TO ROLE GENERAL_ANALYST_ROLE;
GRANT USAGE ON SCHEMA IOT_LAB.ADVANCED TO ROLE PII_VIEWER_ROLE;
GRANT USAGE ON SCHEMA IOT_LAB.ADVANCED TO ROLE GENERAL_ANALYST_ROLE;
GRANT SELECT ON TABLE IOT_LAB.ADVANCED.CUSTOMER_PROD TO ROLE PII_VIEWER_ROLE;
GRANT SELECT ON TABLE IOT_LAB.ADVANCED.CUSTOMER_PROD TO ROLE GENERAL_ANALYST_ROLE;
GRANT ROLE PII_VIEWER_ROLE TO ROLE SYSADMIN;
GRANT ROLE GENERAL_ANALYST_ROLE TO ROLE SYSADMIN;
GRANT ROLE PII_VIEWER_ROLE TO USER <your_username>;
GRANT ROLE GENERAL_ANALYST_ROLE TO USER <your_username>;

-- 3. Same query, two different roles.
USE ROLE GENERAL_ANALYST_ROLE;
SELECT customer_id, name, email FROM IOT_LAB.ADVANCED.CUSTOMER_PROD;

USE ROLE PII_VIEWER_ROLE;
SELECT customer_id, name, email FROM IOT_LAB.ADVANCED.CUSTOMER_PROD;

-- 4. Does masking affect FILTERING on the real value, or only what's
--    displayed? Test it directly under the unprivileged role.
USE ROLE GENERAL_ANALYST_ROLE;
SELECT * FROM IOT_LAB.ADVANCED.CUSTOMER_PROD WHERE email = 'alice@example.com';

USE ROLE ACCOUNTADMIN;

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 92:
--
-- 1. Compare the email column's output between the two roles in
--    step 3, same table, same rows. Where does this transformation
--    actually happen — is the real value ever sent out of Snowflake
--    to an unprivileged client at all, or is it substituted before
--    the result set is even built?
--
-- 2. Only ONE physical copy of CUSTOMER_PROD exists — no separate
--    "masked" table was created. What's the practical advantage of
--    this over maintaining a second, manually-masked copy that has to
--    stay in sync with the real one every time the data changes?
--
-- 3. Run step 4 for real. Did the WHERE clause find Alice's row?
--    What does that tell you about what "masked" actually means for
--    an unprivileged role — is the underlying VALUE genuinely
--    replaced for that session, or is masking purely a display-layer
--    effect that leaves the real value available for filtering?
-- ============================================================
