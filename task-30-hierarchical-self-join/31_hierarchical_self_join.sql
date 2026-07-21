-- ============================================================
-- Task 30 — Self-join for hierarchical data (manager-employee)
-- Reuses EMPLOYEES (Task 10). This task is specifically about WHERE
-- the fixed self-join from Task 12 stops working and you're forced
-- back to recursion.
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;
USE SCHEMA ADVANCED;

-- 1. Self-join, TWO levels: each employee's manager, AND their
--    manager's manager (a "skip-level" lookup). Hardcoded to exactly
--    2 hops — one more LEFT JOIN per additional level needed.
SELECT
    e.employee_name,
    m.employee_name  AS manager_name,
    gm.employee_name AS skip_level_manager
FROM EMPLOYEES e
LEFT JOIN EMPLOYEES m  ON e.manager_id = m.employee_id
LEFT JOIN EMPLOYEES gm ON m.manager_id = gm.employee_id
ORDER BY e.employee_id;

-- 2. Recursive CTE: how many levels up to the very top, for EVERY
--    employee, without knowing the org's depth in advance. Notice
--    there's no hardcoded number of joins here at all.
WITH RECURSIVE ancestors AS (
    SELECT
        employee_id AS original_employee_id,
        employee_id AS current_id,
        manager_id  AS current_manager_id,
        0           AS levels_up
    FROM EMPLOYEES

    UNION ALL

    SELECT
        a.original_employee_id,
        e.employee_id,
        e.manager_id,
        a.levels_up + 1
    FROM ancestors a
    JOIN EMPLOYEES e ON a.current_manager_id = e.employee_id
)
SELECT original_employee_id, MAX(levels_up) AS levels_to_top
FROM ancestors
GROUP BY original_employee_id
ORDER BY original_employee_id;

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 31:
--
-- 1. Trace Dave (employee_id 4, manager_id 2 -> Bob, whose manager_id
--    is 1 -> Alice, who has no manager) through the recursive CTE by
--    hand. Confirm levels_to_top comes out to 2, and explain in your
--    own words why the recursion stops there — what specifically
--    causes the JOIN condition to fail once it reaches Alice?
--
-- 2. What would you have to CHANGE in step 1's query to get a 3rd
--    level (skip-skip-level manager) instead of 2? What happens to
--    that query's complexity as the org grows to 6, then 10 levels
--    deep — does the self-join approach scale at all?
--
-- 3. Suppose you add a new employee who reports to Frank, making the
--    deepest chain 3 levels instead of 2. Would step 1's query
--    correctly show that new employee's full chain to the top? Would
--    step 2's recursive CTE? What's the actual, structural reason one
--    handles arbitrary depth and the other fundamentally can't?
-- ============================================================
