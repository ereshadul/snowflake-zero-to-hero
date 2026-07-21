-- ============================================================
-- Task 10 — CTEs and recursive CTEs
-- Uses GAME_SCORES from Task 7, plus a new EMPLOYEES table for the
-- recursive half.
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;
USE SCHEMA ADVANCED;

-- 1. A plain (non-recursive) multi-step CTE -- chaining two named
--    subqueries instead of nesting them or repeating logic.
WITH high_scorers AS (
    SELECT sensor_id, team, score
    FROM GAME_SCORES
    WHERE score >= 90
),
team_counts AS (
    SELECT team, COUNT(*) AS high_scorer_count
    FROM high_scorers
    GROUP BY team
)
SELECT * FROM team_counts ORDER BY team;

-- 2. Recursive CTE — an org chart. Snowflake requires the RECURSIVE
--    keyword explicitly (some dialects make it optional; Snowflake
--    does not).
CREATE OR REPLACE TABLE EMPLOYEES (
    employee_id   INT,
    employee_name STRING,
    manager_id    INT
);

INSERT INTO EMPLOYEES (employee_id, employee_name, manager_id) VALUES
    (1, 'Alice', NULL),  -- top of the org, no manager
    (2, 'Bob',   1),
    (3, 'Carol', 1),
    (4, 'Dave',  2),
    (5, 'Eve',   2),
    (6, 'Frank', 3);

WITH RECURSIVE org_chart AS (
    -- Anchor: the row(s) with no manager -- level 0.
    SELECT employee_id, employee_name, manager_id, 0 AS level,
           employee_name AS path
    FROM EMPLOYEES
    WHERE manager_id IS NULL

    UNION ALL

    -- Recursive member: join EMPLOYEES back to the CTE itself,
    -- one level deeper each pass, until no more matches are found.
    SELECT e.employee_id, e.employee_name, e.manager_id, oc.level + 1,
           oc.path || ' -> ' || e.employee_name
    FROM EMPLOYEES e
    JOIN org_chart oc ON e.manager_id = oc.employee_id
)
SELECT * FROM org_chart
ORDER BY level, employee_id;

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 11:
--
-- 1. In the org_chart result, what level does Frank land on, and
--    what does his `path` column read? Trace by hand which anchor
--    row and which recursive passes produced that result.
--
-- 2. Try inserting a row that creates a cycle: manager_id pointing
--    back up the chain in a loop (e.g. make Alice's manager_id = 6,
--    so Frank is indirectly Alice's boss). Re-run the recursive CTE.
--    What happens -- does it error, hang, or stop at some point? What
--    does that tell you about how you should guard recursive CTEs
--    against bad source data in a real pipeline?
--
-- 3. The first (non-recursive) CTE chains high_scorers into
--    team_counts. Could you write the same result as one query with
--    a subquery instead of two CTEs? What's actually gained by naming
--    each step instead of nesting -- is it just readability, or does
--    Snowflake ever materialize/reuse a CTE result differently than a
--    subquery referenced only once?
-- ============================================================
