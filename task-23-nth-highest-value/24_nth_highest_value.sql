-- ============================================================
-- Task 23 — Nth highest value (the second-highest-salary problem)
-- Probably the single most commonly asked SQL interview question.
-- Three solutions, each with a real tradeoff.
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;
USE SCHEMA ADVANCED;

CREATE OR REPLACE TABLE EMPLOYEE_SALARIES (
    employee_name STRING,
    salary         NUMBER
);
INSERT INTO EMPLOYEE_SALARIES (employee_name, salary) VALUES
    ('Alice', 90000),
    ('Bob',   85000),
    ('Carol', 85000),   -- tied with Bob
    ('Dave',  75000),
    ('Eve',   70000);

-- Approach 1: DISTINCT + OFFSET. Simple, gives you the VALUE, not who
-- has it. Generalizes to Nth by changing OFFSET to (N-1).
SELECT DISTINCT salary
FROM EMPLOYEE_SALARIES
ORDER BY salary DESC
LIMIT 1 OFFSET 1;   -- 2nd highest

-- Approach 2: DENSE_RANK. Gives you the employee(s) too, and handles
-- ties in a way OFFSET can't (see understanding check 1).
SELECT employee_name, salary
FROM (
    SELECT employee_name, salary,
           DENSE_RANK() OVER (ORDER BY salary DESC) AS rnk
    FROM EMPLOYEE_SALARIES
)
WHERE rnk = 2;

-- Approach 3: correlated subquery -- "the max salary that's still
-- less than the overall max."
SELECT MAX(salary) AS second_highest_salary
FROM EMPLOYEE_SALARIES
WHERE salary < (SELECT MAX(salary) FROM EMPLOYEE_SALARIES);

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 24:
--
-- 1. Bob and Carol are tied at the 2nd-highest salary (85000).
--    Approach 2 (DENSE_RANK) returns TWO rows for rnk = 2 -- both of
--    them. Approach 1 (DISTINCT + OFFSET) returns just the number
--    85000, once. Which of these is the "more correct" answer to
--    "who has the 2nd highest salary" -- does DISTINCT + OFFSET
--    actually answer that question, or does it quietly answer a
--    different, narrower question ("what IS the 2nd highest value")?
--
-- 2. Generalize all three approaches to find the 3rd highest salary
--    instead of the 2nd. Which one required changing the LEAST code
--    to generalize, and which one would get genuinely awkward if you
--    needed the 10th highest instead of the 3rd?
--
-- 3. Approach 3's WHERE salary < (SELECT MAX(salary) ...) works
--    cleanly for "2nd highest" because there's exactly one nested
--    MAX to peel off. Try writing the equivalent correlated-subquery
--    version for the 3rd highest. Does the query get meaningfully
--    more complex, and what does that tell you about when this
--    approach stops being a reasonable choice as N grows?
-- ============================================================
