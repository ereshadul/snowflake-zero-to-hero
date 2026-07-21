-- ============================================================
-- Task 19 — Multi-table INSERT
-- Reuses ORDERS from Task 13 -- including its one row with a NULL
-- customer_id, which is the whole point of this task.
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;
USE SCHEMA ADVANCED;

CREATE OR REPLACE TABLE ORDERS_LARGE      (order_id INT, customer_id INT, amount NUMBER);
CREATE OR REPLACE TABLE ORDERS_SMALL      (order_id INT, customer_id INT, amount NUMBER);
CREATE OR REPLACE TABLE ORDERS_UNASSIGNED (order_id INT, customer_id INT, amount NUMBER);

-- 1. INSERT ALL -- evaluates EVERY WHEN clause for EVERY row. A row
--    that satisfies multiple conditions gets inserted into multiple
--    tables, once per matching clause.
INSERT ALL
    WHEN amount >= 50        THEN INTO ORDERS_LARGE
    WHEN amount < 50         THEN INTO ORDERS_SMALL
    WHEN customer_id IS NULL THEN INTO ORDERS_UNASSIGNED
SELECT order_id, customer_id, amount FROM ORDERS;

SELECT 'ORDERS_LARGE'      AS tbl, * FROM ORDERS_LARGE
UNION ALL
SELECT 'ORDERS_SMALL'      AS tbl, * FROM ORDERS_SMALL
UNION ALL
SELECT 'ORDERS_UNASSIGNED' AS tbl, * FROM ORDERS_UNASSIGNED
ORDER BY tbl, order_id;
-- Look specifically for order_id 105 (the NULL-customer, $15 order)
-- in this output -- count how many rows it appears in total.

-- 2. Reset and try INSERT FIRST instead -- evaluates WHEN clauses IN
--    ORDER and stops at the first match, so each row lands in exactly
--    one table.
TRUNCATE TABLE ORDERS_LARGE;
TRUNCATE TABLE ORDERS_SMALL;
TRUNCATE TABLE ORDERS_UNASSIGNED;

INSERT FIRST
    WHEN customer_id IS NULL THEN INTO ORDERS_UNASSIGNED
    WHEN amount >= 50        THEN INTO ORDERS_LARGE
    WHEN amount < 50         THEN INTO ORDERS_SMALL
SELECT order_id, customer_id, amount FROM ORDERS;

SELECT 'ORDERS_LARGE'      AS tbl, * FROM ORDERS_LARGE
UNION ALL
SELECT 'ORDERS_SMALL'      AS tbl, * FROM ORDERS_SMALL
UNION ALL
SELECT 'ORDERS_UNASSIGNED' AS tbl, * FROM ORDERS_UNASSIGNED
ORDER BY tbl, order_id;
-- Same question: how many rows does order_id 105 appear in this time?

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 20:
--
-- 1. Order 105 (customer_id NULL, amount 15) satisfies BOTH
--    "amount < 50" and "customer_id IS NULL". In step 1 (INSERT ALL),
--    how many of the three tables does it land in? List them.
--
-- 2. In step 2 (INSERT FIRST), order 105 only lands in one table.
--    Which one, and why — walk through the WHEN clauses in the exact
--    order they're written and explain where evaluation stops.
--
-- 3. If you swapped the order of the first two WHEN clauses in step
--    2 (checking "amount >= 50" before "customer_id IS NULL"), would
--    order 105 end up somewhere different? Test it. What does that
--    tell you about how much INSERT FIRST's behavior depends on
--    clause ORDER, compared to INSERT ALL where order doesn't matter
--    at all?
-- ============================================================
