-- ============================================================
-- Task 24 — Running totals and cumulative sums
-- Deliberately includes a tie on sale_date, to reconnect with Task
-- 9's RANGE vs. ROWS distinction -- this is where that subtlety
-- actually bites in a real "running total" query.
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;
USE SCHEMA ADVANCED;

CREATE OR REPLACE TABLE DAILY_SALES (
    region    STRING,
    sale_date DATE,
    amount    NUMBER
);
INSERT INTO DAILY_SALES (region, sale_date, amount) VALUES
    ('East', '2026-06-01', 100),
    ('East', '2026-06-02', 150),
    ('East', '2026-06-02',  50),   -- tie: same region, same date as above
    ('East', '2026-06-03',  80),
    ('West', '2026-06-01', 200),
    ('West', '2026-06-02',  90);

-- 1. Running total per region, using the DEFAULT frame (no explicit
--    ROWS/RANGE) — just PARTITION BY + ORDER BY. This defaults to
--    RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW.
SELECT
    region, sale_date, amount,
    SUM(amount) OVER (PARTITION BY region ORDER BY sale_date) AS running_total_default
FROM DAILY_SALES
ORDER BY region, sale_date;

-- 2. The same thing with an EXPLICIT ROWS frame instead.
SELECT
    region, sale_date, amount,
    SUM(amount) OVER (
        PARTITION BY region ORDER BY sale_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total_rows
FROM DAILY_SALES
ORDER BY region, sale_date;

-- 3. A GLOBAL running total, ignoring region entirely -- no
--    PARTITION BY at all, one running sum across the whole table.
SELECT
    region, sale_date, amount,
    SUM(amount) OVER (ORDER BY sale_date, region) AS global_running_total
FROM DAILY_SALES
ORDER BY sale_date, region;

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 25:
--
-- 1. East has two sales tied on 2026-06-02 (150 and 50). Compare
--    running_total_default (step 1) to running_total_rows (step 2)
--    for those two specific rows. Do they show the SAME cumulative
--    value for both tied rows, or two DIFFERENT progressively
--    increasing values? Which behavior comes from RANGE and which
--    from ROWS — tie this back to what you found in Task 9.
--
-- 2. If a report needs "how much has this region sold so far, as of
--    each individual transaction" (not "as of each date"), which
--    frame — the default RANGE or explicit ROWS — actually gives the
--    right answer when two sales land on the same day? Why?
--
-- 3. Step 3 drops PARTITION BY entirely for a company-wide running
--    total. If someone meant to write a PER-REGION running total but
--    forgot the PARTITION BY clause, would Snowflake error, or would
--    it just silently produce this global total instead? What's the
--    practical danger of that being a silent failure instead of an
--    error?
-- ============================================================
