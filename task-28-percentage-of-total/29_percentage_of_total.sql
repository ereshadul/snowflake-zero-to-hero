-- ============================================================
-- Task 28 — Percentage of total / ratio-to-report
-- Reuses QUARTERLY_SALES (Task 11).
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;
USE SCHEMA ADVANCED;

-- 1. The old way: self-join against a pre-aggregated per-group total.
--    Works, but scans/aggregates the table twice.
SELECT
    q.region, q.quarter, q.amount,
    q.amount / t.total_amount AS pct_of_region_total
FROM QUARTERLY_SALES q
JOIN (
    SELECT region, SUM(amount) AS total_amount
    FROM QUARTERLY_SALES
    GROUP BY region
) t ON q.region = t.region
ORDER BY q.region, q.quarter;

-- 2. Window function: one pass, no join at all.
SELECT
    region, quarter, amount,
    amount / SUM(amount) OVER (PARTITION BY region) AS pct_of_region_total
FROM QUARTERLY_SALES
ORDER BY region, quarter;

-- 3. Snowflake has a dedicated function for exactly this pattern:
--    RATIO_TO_REPORT.
SELECT
    region, quarter, amount,
    RATIO_TO_REPORT(amount) OVER (PARTITION BY region) AS pct_of_region_total
FROM QUARTERLY_SALES
ORDER BY region, quarter;

-- 4. Drop PARTITION BY entirely for "percent of GRAND total" instead
--    of "percent of region total."
SELECT
    region, quarter, amount,
    RATIO_TO_REPORT(amount) OVER () AS pct_of_grand_total
FROM QUARTERLY_SALES
ORDER BY region, quarter;

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 29:
--
-- 1. Confirm steps 1, 2, and 3 produce identical pct_of_region_total
--    values. As QUARTERLY_SALES grows to millions of rows, what's the
--    practical cost difference between the self-join (step 1) and the
--    window function (steps 2-3) — how many times does each approach
--    actually scan/aggregate the table?
--
-- 2. RATIO_TO_REPORT(amount) OVER (PARTITION BY region) and
--    amount / SUM(amount) OVER (PARTITION BY region) give the same
--    numbers. What's actually gained by using the dedicated function
--    instead of writing the division yourself — is it purely
--    readability, or does RATIO_TO_REPORT handle an edge case (like a
--    zero or NULL denominator) more gracefully than manual division
--    would?
--
-- 3. Step 4 removes PARTITION BY for a grand-total percentage. Do all
--    four regions' quarters now sum to 1.0 (100%) when added together
--    across the WHOLE result, or does each region still sum to 1.0 on
--    its own? Explain the difference in what the denominator actually
--    is between step 3 and step 4.
-- ============================================================
