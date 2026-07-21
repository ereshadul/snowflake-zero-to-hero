-- ============================================================
-- Task 14 — CASE expressions and conditional aggregation
-- Reuses ORDERS (Task 13) and QUARTERLY_SALES (Task 11).
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;
USE SCHEMA ADVANCED;

-- 1. Conditional counting and summing per customer -- turning a
--    single amount column into several "bucketed" aggregate columns
--    without a separate query per bucket.
SELECT
    customer_id,
    COUNT(CASE WHEN amount >= 50 THEN 1 END)              AS large_order_count,
    COUNT(CASE WHEN amount < 50  THEN 1 END)               AS small_order_count,
    SUM(CASE WHEN amount >= 50 THEN amount ELSE 0 END)     AS large_order_total,
    SUM(CASE WHEN amount < 50  THEN amount ELSE 0 END)     AS small_order_total
FROM ORDERS
WHERE customer_id IS NOT NULL
GROUP BY customer_id
ORDER BY customer_id;

-- 2. The same "manual pivot" pattern applied to QUARTERLY_SALES --
--    this produces the exact same shape Task 11's native PIVOT
--    keyword gave you, just spelled out by hand.
SELECT
    region,
    SUM(CASE WHEN quarter = 'Q1' THEN amount ELSE 0 END) AS q1,
    SUM(CASE WHEN quarter = 'Q2' THEN amount ELSE 0 END) AS q2,
    SUM(CASE WHEN quarter = 'Q3' THEN amount ELSE 0 END) AS q3,
    SUM(CASE WHEN quarter = 'Q4' THEN amount ELSE 0 END) AS q4
FROM QUARTERLY_SALES
GROUP BY region
ORDER BY region;

-- 3. A subtle variant worth testing directly: what changes if you add
--    an explicit ELSE 0 to the COUNT() CASE expressions from step 1?
SELECT
    customer_id,
    COUNT(CASE WHEN amount >= 50 THEN 1 END)          AS count_without_else,
    COUNT(CASE WHEN amount >= 50 THEN 1 ELSE 0 END)   AS count_with_else_0
FROM ORDERS
WHERE customer_id IS NOT NULL
GROUP BY customer_id
ORDER BY customer_id;

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 15:
--
-- 1. Compare count_without_else and count_with_else_0 in step 3 for
--    any customer with at least one small order. Are they the same
--    number or different? Explain exactly why, in terms of what
--    COUNT() actually counts (hint: it's not "how many TRUE values,"
--    it's "how many non-NULL values").
--
-- 2. In step 1, SUM(CASE WHEN amount >= 50 THEN amount ELSE 0 END)
--    explicitly has ELSE 0. What would large_order_total look like
--    for a customer whose only order is small, if you removed the
--    ELSE 0 entirely (leaving an implicit ELSE NULL)? Would it show
--    0, or something else?
--
-- 3. Step 2 reproduces Task 11's PIVOT output using only CASE +
--    GROUP BY. Which version would you actually reach for in a real
--    project — does PIVOT do anything CASE fundamentally can't, or
--    is the choice purely about which one your team finds more
--    readable?
-- ============================================================
