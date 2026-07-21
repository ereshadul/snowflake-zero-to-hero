-- ============================================================
-- Task 13 — Correlated subqueries vs. EXISTS vs. IN vs. JOIN
-- The classic customers/orders setup, with a deliberate NULL planted
-- in ORDERS.customer_id -- that NULL is the whole point of this task.
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;
USE SCHEMA ADVANCED;

CREATE OR REPLACE TABLE CUSTOMERS (
    customer_id   INT,
    customer_name STRING
);
INSERT INTO CUSTOMERS VALUES
    (1, 'Alice'), (2, 'Bob'), (3, 'Carol'), (4, 'Dave'), (5, 'Eve');

CREATE OR REPLACE TABLE ORDERS (
    order_id    INT,
    customer_id INT,
    amount      NUMBER
);
INSERT INTO ORDERS VALUES
    (101, 1,   50),
    (102, 1,   30),
    (103, 2,   75),
    (104, 3,   20),
    (105, NULL, 15);   -- a guest/anonymous order -- no customer attached

-- Dave (4) and Eve (5) have never ordered anything.

-- 1. Customers WHO HAVE ordered -- four equivalent ways.
SELECT customer_name FROM CUSTOMERS c
WHERE EXISTS (SELECT 1 FROM ORDERS o WHERE o.customer_id = c.customer_id)
ORDER BY customer_name;

SELECT customer_name FROM CUSTOMERS
WHERE customer_id IN (SELECT customer_id FROM ORDERS)
ORDER BY customer_name;

SELECT DISTINCT c.customer_name FROM CUSTOMERS c
JOIN ORDERS o ON c.customer_id = o.customer_id
ORDER BY c.customer_name;

-- 2. Customers who have NEVER ordered -- three ways, only two of
--    which actually work correctly given the NULL in ORDERS.
SELECT customer_name FROM CUSTOMERS c
WHERE NOT EXISTS (SELECT 1 FROM ORDERS o WHERE o.customer_id = c.customer_id)
ORDER BY customer_name;

SELECT c.customer_name FROM CUSTOMERS c
LEFT JOIN ORDERS o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL
ORDER BY c.customer_name;

-- This one is the trap -- run it and see what actually comes back.
SELECT customer_name FROM CUSTOMERS
WHERE customer_id NOT IN (SELECT customer_id FROM ORDERS)
ORDER BY customer_name;

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 14:
--
-- 1. The NOT IN query in step 2 should return Dave and Eve, same as
--    the other two. What does it actually return? Explain why, in
--    terms of three-valued logic: `customer_id NOT IN (1, 2, 3, NULL)`
--    -- what does SQL do when it has to compare against a NULL inside
--    an IN/NOT IN list?
--
-- 2. NOT EXISTS and the LEFT JOIN + IS NULL version both give the
--    correct answer despite the same NULL sitting in ORDERS. What's
--    structurally different about how EXISTS/NOT EXISTS check for a
--    match, compared to IN/NOT IN, that makes EXISTS immune to this?
--
-- 3. In step 1, the JOIN version needs DISTINCT but the EXISTS and IN
--    versions don't. Why? What would happen to the JOIN version's row
--    count, without DISTINCT, if Alice had 5 orders instead of 2?
-- ============================================================
