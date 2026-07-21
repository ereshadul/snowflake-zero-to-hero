-- ============================================================
-- Task 11 — PIVOT and UNPIVOT
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;
USE SCHEMA ADVANCED;

CREATE OR REPLACE TABLE QUARTERLY_SALES (
    region  STRING,
    quarter STRING,
    amount  NUMBER
);

INSERT INTO QUARTERLY_SALES (region, quarter, amount) VALUES
    ('East', 'Q1', 100), ('East', 'Q2', 150), ('East', 'Q3', 120), ('East', 'Q4', 200),
    ('West', 'Q1',  80), ('West', 'Q2',  90), ('West', 'Q3', 110), ('West', 'Q4',  95);

-- 1. PIVOT: rows -> columns. One row per region, one column per
--    quarter, values aggregated with SUM (required -- PIVOT always
--    needs an aggregate, even if you know there's only one row per
--    region+quarter already).
SELECT *
FROM QUARTERLY_SALES
    PIVOT (SUM(amount) FOR quarter IN ('Q1', 'Q2', 'Q3', 'Q4'))
        AS p (region, q1, q2, q3, q4)
ORDER BY region;

-- 2. UNPIVOT: columns -> rows, the reverse direction. Needs a table
--    that's already wide to begin with.
CREATE OR REPLACE TABLE QUARTERLY_SALES_WIDE (
    region STRING,
    q1 NUMBER,
    q2 NUMBER,
    q3 NUMBER,
    q4 NUMBER
);

INSERT INTO QUARTERLY_SALES_WIDE (region, q1, q2, q3, q4) VALUES
    ('East', 100, 150, 120, 200),
    ('West',  80,  90, 110,  95);

SELECT *
FROM QUARTERLY_SALES_WIDE
    UNPIVOT (amount FOR quarter IN (q1, q2, q3, q4))
ORDER BY region, quarter;

-- 3. What happens when a wide column is NULL -- add a row with a
--    missing quarter and unpivot again.
INSERT INTO QUARTERLY_SALES_WIDE (region, q1, q2, q3, q4) VALUES
    ('North', 50, NULL, 60, 70);

SELECT *
FROM QUARTERLY_SALES_WIDE
    UNPIVOT (amount FOR quarter IN (q1, q2, q3, q4))
WHERE region = 'North'
ORDER BY quarter;

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 12:
--
-- 1. PIVOT requires an aggregate function (SUM here) even though
--    there's only ever one row per region+quarter combination in
--    this data. What would PIVOT actually do if two rows existed for
--    the same region+quarter (e.g. two 'East'/'Q1' rows)? Test it by
--    inserting a duplicate and re-running.
--
-- 2. North's Q2 value is NULL. How many rows come back for North
--    from the UNPIVOT in step 3 -- 4 (one per quarter, including a
--    NULL amount row) or 3 (Q2 silently dropped)? What does that
--    tell you about UNPIVOT's default NULL handling, and what keyword
--    would change that behavior if you needed the opposite?
--
-- 3. Task 31 (later in the roadmap) builds the same pivot result by
--    hand with CASE + SUM inside a GROUP BY, instead of the PIVOT
--    keyword. What's the actual functional difference, if any --
--    is there anything PIVOT can express that manual CASE can't, or
--    is it purely a readability/convenience difference?
-- ============================================================
