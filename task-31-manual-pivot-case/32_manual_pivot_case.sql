-- ============================================================
-- Task 31 — Manual pivot with CASE (crosstab without PIVOT)
-- Task 14 already did a basic manual pivot (quarters -> columns).
-- This one is deliberately harder: a crosstab keyed on RANK POSITION,
-- something native PIVOT (Task 11) genuinely cannot do directly,
-- since PIVOT pivots on a column's existing values, not on a
-- computed position that has to be figured out first.
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;
USE SCHEMA ADVANCED;

-- 1. Rank each player within their team first (rank position isn't a
--    real column yet -- it has to be computed).
WITH ranked AS (
    SELECT
        team, player_id, score,
        ROW_NUMBER() OVER (PARTITION BY team ORDER BY score DESC) AS place
    FROM GAME_SCORES
)
-- 2. Now pivot on THAT computed rank position with CASE + MAX --
--    one row per team, one column per finishing place.
SELECT
    team,
    MAX(CASE WHEN place = 1 THEN score END) AS place_1_score,
    MAX(CASE WHEN place = 2 THEN score END) AS place_2_score,
    MAX(CASE WHEN place = 3 THEN score END) AS place_3_score,
    MAX(CASE WHEN place = 4 THEN score END) AS place_4_score
FROM ranked
GROUP BY team
ORDER BY team;

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 32:
--
-- 1. Native PIVOT (Task 11) pivots on a column's EXISTING distinct
--    values (like 'Q1', 'Q2', 'Q3', 'Q4' already sitting in the
--    quarter column). Explain specifically why you can't just write
--    `PIVOT(MAX(score) FOR place IN (1,2,3,4))` directly against
--    GAME_SCORES without the `ranked` CTE step first — what's missing
--    from the raw table that the CTE has to create?
--
-- 2. Red's P1 and P2 are tied at 100. ROW_NUMBER breaks that tie
--    arbitrarily. Run this query twice — does place_1_score and
--    place_2_score for Red ever show DIFFERENT specific values across
--    runs, or does the actual VALUE (100 either way) stay identical
--    regardless of which of P1/P2 gets called "1st"? Why does that
--    matter less here than it would if you were also displaying
--    player_id in the pivoted output?
--
-- 3. If a team only had 2 players instead of 4, what would
--    place_3_score and place_4_score show for that team — NULL, 0,
--    or something else? Trace through why, based on what
--    `MAX(CASE WHEN place = 3 THEN score END)` actually evaluates to
--    when no row in that group has place = 3 at all.
-- ============================================================
