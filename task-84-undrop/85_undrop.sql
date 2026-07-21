-- ============================================================
-- Task 84 — UNDROP
-- Category: Time Travel & cloning
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;
USE SCHEMA ADVANCED;

CREATE OR REPLACE TABLE UNDROP_DEMO (id INT, value STRING);
INSERT INTO UNDROP_DEMO (id, value) VALUES (1, 'Important Data');

-- 1. Drop it, confirm it's actually gone, then bring it back.
DROP TABLE UNDROP_DEMO;

-- SELECT * FROM UNDROP_DEMO; -- would error: table no longer exists

UNDROP TABLE UNDROP_DEMO;

SELECT * FROM UNDROP_DEMO;  -- data restored

-- 2. The name-collision gotcha: drop it again, but this time create a
--    DIFFERENT table with the same name before undropping the
--    original.
DROP TABLE UNDROP_DEMO;

CREATE TABLE UNDROP_DEMO (id INT, value STRING);
INSERT INTO UNDROP_DEMO (id, value) VALUES (99, 'Brand new, different data');

-- Try to undrop the ORIGINAL now -- expect this to fail, the name is
-- already taken by the new table.
UNDROP TABLE UNDROP_DEMO;

-- Fix: rename the CURRENT table out of the way first, then undrop.
ALTER TABLE UNDROP_DEMO RENAME TO UNDROP_DEMO_NEW;
UNDROP TABLE UNDROP_DEMO;

SELECT * FROM UNDROP_DEMO;      -- the ORIGINAL data (id=1) is back
SELECT * FROM UNDROP_DEMO_NEW;  -- the newer data (id=99) is separate

-- 3. UNDROP also works at the schema/database level, same syntax
--    pattern.
CREATE SCHEMA IF NOT EXISTS IOT_LAB.UNDROP_SCHEMA_DEMO;
DROP SCHEMA IOT_LAB.UNDROP_SCHEMA_DEMO;
UNDROP SCHEMA IOT_LAB.UNDROP_SCHEMA_DEMO;
SHOW SCHEMAS LIKE 'UNDROP_SCHEMA_DEMO' IN DATABASE IOT_LAB;

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 85:
--
-- 1. Confirm step 1 fully restored the original row (id=1). What
--    actually determines the WINDOW during which UNDROP is possible
--    for a dropped object — is it unlimited, or tied to something
--    specific about the table's configuration? (Task 87 covers this
--    in depth — for now, just note what you'd guess controls it.)
--
-- 2. What exact error did the first UNDROP attempt in step 2 give
--    you? Why does Snowflake require the name to be completely free
--    before undropping, rather than automatically renaming the
--    restored object to something else?
--
-- 3. UNDROP relies on the same underlying mechanism as Time Travel.
--    Given a TRANSIENT table (Task 35) has a much shorter maximum Time
--    Travel window than a PERMANENT one, would you expect UNDROP to
--    still work the same way for a transient table? What about a
--    table with DATA_RETENTION_TIME_IN_DAYS explicitly set to 0 —
--    would UNDROP have anything to restore at all?
-- ============================================================
