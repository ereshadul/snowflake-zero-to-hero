-- ============================================================
-- Task 37 — Generating primary keys
-- Category: Table & Data Fundamentals
--
-- Since PRIMARY KEY doesn't enforce anything (Task 36), generating a
-- genuinely unique key value in the first place is what actually
-- prevents duplicates -- not the constraint declaration.
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;
USE SCHEMA ADVANCED;

-- 1. A standalone SEQUENCE object -- can be referenced by name from
--    anywhere, including multiple different tables if you wanted a
--    shared ID space.
CREATE OR REPLACE SEQUENCE ORDER_ID_SEQ START = 1 INCREMENT = 1;

SELECT ORDER_ID_SEQ.NEXTVAL;   -- 1
SELECT ORDER_ID_SEQ.NEXTVAL;   -- 2

CREATE OR REPLACE TABLE ORDERS_WITH_SEQ (
    order_id      INT DEFAULT ORDER_ID_SEQ.NEXTVAL,
    customer_name STRING
);
INSERT INTO ORDERS_WITH_SEQ (customer_name) VALUES ('Alice'), ('Bob'), ('Carol');
SELECT * FROM ORDERS_WITH_SEQ ORDER BY order_id;

-- 2. IDENTITY (AUTOINCREMENT is a synonym) -- built into the column
--    itself, no separate sequence object to manage.
CREATE OR REPLACE TABLE ORDERS_WITH_IDENTITY (
    order_id      INT IDENTITY(1, 1),
    customer_name STRING
);
INSERT INTO ORDERS_WITH_IDENTITY (customer_name) VALUES ('Dave'), ('Eve');
SELECT * FROM ORDERS_WITH_IDENTITY ORDER BY order_id;

-- 3. What happens to the ID when a row is deleted, then a new row is
--    inserted afterward?
INSERT INTO ORDERS_WITH_IDENTITY (customer_name) VALUES ('Frank');
DELETE FROM ORDERS_WITH_IDENTITY WHERE customer_name = 'Frank';
INSERT INTO ORDERS_WITH_IDENTITY (customer_name) VALUES ('Grace');

SELECT * FROM ORDERS_WITH_IDENTITY ORDER BY order_id;
-- Look at Grace's order_id specifically -- did she get Frank's old
-- number back, or a brand new one?

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 38:
--
-- 1. Did Grace's order_id reuse Frank's deleted number, or skip past
--    it? What does that confirm about the actual guarantee IDENTITY
--    (and SEQUENCE) provide — is it "sequential with zero gaps," or
--    just "always increasing and never repeated"?
--
-- 2. ORDER_ID_SEQ is a standalone object, referenceable from any
--    table via ORDER_ID_SEQ.NEXTVAL. IDENTITY is built into one
--    specific column of one specific table. When would you actually
--    want a single shared sequence feeding IDs to MULTIPLE different
--    tables, instead of giving each table its own IDENTITY column?
--
-- 3. Task 36 showed that declaring PRIMARY KEY doesn't stop a
--    duplicate value from being inserted. Does using IDENTITY/SEQUENCE
--    to GENERATE the key make duplicates structurally impossible, or
--    could a duplicate still happen some other way — for instance, if
--    someone manually INSERTs an explicit order_id value instead of
--    letting the DEFAULT/IDENTITY fill it in? Try it and see.
-- ============================================================
