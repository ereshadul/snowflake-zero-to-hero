-- ============================================================
-- Task 17 — QUALIFY clause
-- Reuses GAME_SCORES (Task 7).
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;
USE SCHEMA ADVANCED;

-- 1. Without QUALIFY: WHERE can't reference a window function result
--    (window functions compute AFTER WHERE runs), so filtering on one
--    means wrapping the whole thing in a subquery.
SELECT * FROM (
    SELECT
        team, player_id, score,
        RANK() OVER (PARTITION BY team ORDER BY score DESC) AS rnk
    FROM GAME_SCORES
)
WHERE rnk = 1;

-- 2. The exact same result with QUALIFY -- no subquery needed. This
--    is Snowflake-specific syntax; most other SQL dialects don't have
--    it and require the subquery pattern above.
SELECT
    team, player_id, score,
    RANK() OVER (PARTITION BY team ORDER BY score DESC) AS rnk
FROM GAME_SCORES
QUALIFY rnk = 1;

-- 3. WHERE and QUALIFY together -- WHERE narrows the row set FIRST,
--    then the window function computes over whatever WHERE left
--    behind, then QUALIFY filters on that result.
SELECT
    team, player_id, score,
    ROW_NUMBER() OVER (PARTITION BY team ORDER BY score DESC) AS rn
FROM GAME_SCORES
WHERE score >= 80
QUALIFY rn = 1;

-- 4. QUALIFY can reference the window function directly, without an
--    alias in SELECT at all.
SELECT team, player_id, score
FROM GAME_SCORES
QUALIFY RANK() OVER (PARTITION BY team ORDER BY score DESC) = 1;

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 18:
--
-- 1. Compare step 3's result to step 2's. Blue's P8 scored 70 (below
--    the WHERE >= 80 cutoff). Does removing P8 from consideration
--    change which player ends up as Blue's rn = 1 compared to the
--    RANK()-based rnk = 1 from step 2? Would it ever change the
--    ranking of the SURVIVING rows, or only which rows survive to be
--    ranked at all?
--
-- 2. SQL clause evaluation order is roughly: FROM -> WHERE -> GROUP BY
--    -> HAVING -> window functions -> QUALIFY -> SELECT list ->
--    ORDER BY. Given that order, explain why WHERE literally cannot
--    reference a window function's alias, while QUALIFY can.
--
-- 3. Step 4 uses QUALIFY with no alias at all. Is there ever a
--    downside to inlining the window function directly in QUALIFY
--    instead of computing it once in SELECT with an alias and
--    referencing the alias in QUALIFY? (Hint: what if you needed that
--    same window function's value visible in the output columns too.)
-- ============================================================
