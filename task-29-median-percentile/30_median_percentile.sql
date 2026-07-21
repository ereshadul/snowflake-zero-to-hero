-- ============================================================
-- Task 29 — Median and percentile calculation
-- Adds one row to EMPLOYEE_SALARIES (Task 23) so there are an EVEN
-- number of values -- that's specifically where CONT and DISC stop
-- agreeing with each other.
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;
USE SCHEMA ADVANCED;

INSERT INTO EMPLOYEE_SALARIES (employee_name, salary) VALUES ('Frank', 80000);
-- EMPLOYEE_SALARIES sorted: 70000, 75000, 80000, 85000, 85000, 90000 (6 values now)

-- 1. MEDIAN() -- shorthand for the 50th percentile, continuous style.
SELECT MEDIAN(salary) AS median_salary FROM EMPLOYEE_SALARIES;

-- 2. PERCENTILE_CONT -- INTERPOLATES between the two middle values
--    when the count is even. Same thing MEDIAN() computes at p=0.5.
SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY salary) AS p50_cont
FROM EMPLOYEE_SALARIES;

-- 3. PERCENTILE_DISC -- picks an ACTUAL value that exists in the
--    data, never interpolates.
SELECT PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY salary) AS p50_disc
FROM EMPLOYEE_SALARIES;

-- 4. Both side by side, plus a couple more percentiles (quartiles).
SELECT
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY salary) AS p25_cont,
    PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY salary) AS p50_cont,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY salary) AS p75_cont,
    PERCENTILE_DISC(0.25) WITHIN GROUP (ORDER BY salary) AS p25_disc,
    PERCENTILE_DISC(0.50) WITHIN GROUP (ORDER BY salary) AS p50_disc,
    PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY salary) AS p75_disc
FROM EMPLOYEE_SALARIES;

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 30:
--
-- 1. List the 6 sorted salary values by hand. p50_cont and p50_disc
--    from step 4 -- are they the same number or different? If
--    different, explain exactly what PERCENTILE_CONT computed (an
--    interpolation between which two values?) versus what
--    PERCENTILE_DISC picked (which single actual value, and why that
--    one specifically?).
--
-- 2. MEDIAN(salary) from step 1 -- does it match p50_cont or p50_disc
--    from step 4? What does that tell you about which percentile
--    "flavor" MEDIAN() actually is under the hood?
--
-- 3. Give a concrete reason you'd want PERCENTILE_DISC specifically
--    (an actual value that exists in your data) instead of
--    PERCENTILE_CONT (a mathematically interpolated number that might
--    not correspond to any real row) — think about a scenario where
--    the "median" needs to be a value you could actually look up or
--    point to, not just a number.
-- ============================================================
