-- ============================================================
-- Task 18 — MERGE statement deep dive
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;
USE SCHEMA ADVANCED;

CREATE OR REPLACE TABLE CUSTOMER_DIM (
    customer_id   INT,
    customer_name STRING,
    email         STRING,
    updated_at    TIMESTAMP_NTZ
);
INSERT INTO CUSTOMER_DIM (customer_id, customer_name, email, updated_at) VALUES
    (1, 'Alice', 'alice@old.com',    '2026-01-01'),
    (2, 'Bob',   'bob@example.com',  '2026-01-01'),
    (3, 'Carol', 'carol@example.com','2026-01-01');

CREATE OR REPLACE TABLE CUSTOMER_UPDATES (
    customer_id   INT,
    customer_name STRING,
    email         STRING
);
INSERT INTO CUSTOMER_UPDATES (customer_id, customer_name, email) VALUES
    (1, 'Alice', 'alice@new.com'),   -- existing customer, email changed
    (4, 'Dave',  'dave@example.com'),-- brand new customer
    (5, 'Eve',   'eve@example.com'); -- brand new customer

-- 1. The upsert -- one statement, both branches.
MERGE INTO CUSTOMER_DIM t
USING CUSTOMER_UPDATES s
    ON t.customer_id = s.customer_id
WHEN MATCHED THEN UPDATE SET
    t.email = s.email,
    t.updated_at = CURRENT_TIMESTAMP()
WHEN NOT MATCHED THEN INSERT (customer_id, customer_name, email, updated_at)
    VALUES (s.customer_id, s.customer_name, s.email, CURRENT_TIMESTAMP());

SELECT * FROM CUSTOMER_DIM ORDER BY customer_id;
-- Expect: Alice's email changed, Carol untouched (not in the source
-- at all), Dave and Eve newly inserted.

-- 2. The gotcha: a source with a duplicate key for the SAME target
--    row. Deliberately broken on purpose.
CREATE OR REPLACE TABLE CUSTOMER_UPDATES_BAD (
    customer_id   INT,
    customer_name STRING,
    email         STRING
);
INSERT INTO CUSTOMER_UPDATES_BAD (customer_id, customer_name, email) VALUES
    (2, 'Bob', 'bob@dup1.com'),
    (2, 'Bob', 'bob@dup2.com');   -- same customer_id twice

MERGE INTO CUSTOMER_DIM t
USING CUSTOMER_UPDATES_BAD s
    ON t.customer_id = s.customer_id
WHEN MATCHED THEN UPDATE SET t.email = s.email;
-- Expect this to fail outright -- read the actual error message.

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 19:
--
-- 1. In step 1, Carol (customer_id 3) never appears in
--    CUSTOMER_UPDATES at all. Confirm she's untouched in the result.
--    Snowflake's MERGE only has WHEN MATCHED and WHEN NOT MATCHED
--    (source-has-no-target-match) -- there's no third clause for
--    "target row with no matching source row." What would you have
--    to do differently if you actually wanted to DELETE target rows
--    that no longer exist in the source at all?
--
-- 2. Read the exact error message from step 2. Why does Snowflake
--    refuse to just pick one of the two duplicate rows and apply it,
--    instead of silently succeeding with a somewhat-arbitrary result?
--    What real bug would that silent behavior hide from you?
--
-- 3. Describe a real upstream data pipeline situation that would
--    produce a source table with duplicate keys like
--    CUSTOMER_UPDATES_BAD, and what you'd add BEFORE the MERGE step
--    (not inside it) to guarantee this error can't happen in
--    production.
-- ============================================================
