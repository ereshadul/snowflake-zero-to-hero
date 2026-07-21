-- ============================================================
-- Task 12 — Advanced joins: self-join and non-equi join
-- Reuses EMPLOYEES (Task 10), GAME_SCORES (Task 7), DAILY_TEMPS
-- (Task 8).
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;
USE SCHEMA ADVANCED;

-- 1. Self-join: look up each employee's manager's NAME, not just
--    their manager_id -- join the table to itself under two aliases.
SELECT
    e.employee_name,
    m.employee_name AS manager_name
FROM EMPLOYEES e
LEFT JOIN EMPLOYEES m ON e.manager_id = m.employee_id
ORDER BY e.employee_id;

-- 2. Self-join for "greatest-n-per-group" -- the classic pre-window-
--    function technique: find each team's top scorer by joining
--    GAME_SCORES to itself and keeping only rows with no higher
--    score anywhere else on the same team.
SELECT g1.team, g1.player_id, g1.score
FROM GAME_SCORES g1
LEFT JOIN GAME_SCORES g2
    ON g1.team = g2.team AND g2.score > g1.score
WHERE g2.player_id IS NULL   -- no row beat g1's score -> g1 IS the max
ORDER BY g1.team;

-- 3. Non-equi join: classify each day's temperature into a named
--    range using BETWEEN-style boundaries instead of an equality
--    match -- there's no shared key, just a range condition.
CREATE OR REPLACE TABLE TEMP_RANGES (
    category STRING,
    min_temp FLOAT,
    max_temp FLOAT
);

INSERT INTO TEMP_RANGES (category, min_temp, max_temp) VALUES
    ('Freezing', -100,   0),
    ('Cold',        0,  15),
    ('Mild',       15,  25),
    ('Hot',        25, 100);

SELECT
    dt.sensor_id, dt.reading_date, dt.avg_temp, tr.category
FROM DAILY_TEMPS dt
JOIN TEMP_RANGES tr
    ON dt.avg_temp >= tr.min_temp AND dt.avg_temp < tr.max_temp
ORDER BY dt.sensor_id, dt.reading_date;

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 13:
--
-- 1. In the greatest-n-per-group query (step 2), explain in your own
--    words why `WHERE g2.player_id IS NULL` is the part that actually
--    identifies the max -- what does a NULL in g2's columns mean here,
--    given it came from a LEFT JOIN?
--
-- 2. Modify step 2 to find each team's SECOND-highest scorer instead
--    of the highest, using the same self-join anti-join pattern (no
--    window functions). What does the join condition need to become?
--
-- 3. The non-equi join in step 3 has ranges that touch at the
--    boundary (Cold ends at 15, Mild starts at 15) using `>=` on one
--    side and `<` on the other specifically to avoid double-counting
--    a reading of exactly 15.0. What would go wrong -- and how many
--    rows would a 15.0 reading match -- if both boundaries used `<=`
--    instead?
-- ============================================================
