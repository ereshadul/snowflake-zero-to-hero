-- ============================================================
-- Task 27 — Top-N per group
-- Reuses GAME_SCORES (Task 7) -- its existing ties (Red: P1/P2 tied
-- at 100; Blue: P6/P7 tied at 95) are exactly what makes "top 2"
-- genuinely ambiguous, which is the whole point of this task.
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;
USE SCHEMA ADVANCED;

-- 1. QUALIFY + ROW_NUMBER -- always exactly N rows per group, ties
--    broken arbitrarily (by whatever order Snowflake happens to
--    process same-score rows in).
SELECT team, player_id, score
FROM GAME_SCORES
QUALIFY ROW_NUMBER() OVER (PARTITION BY team ORDER BY score DESC) <= 2
ORDER BY team, score DESC;

-- 2. QUALIFY + RANK -- can return MORE than N rows per group if
--    there's a tie sitting right at the cutoff.
SELECT team, player_id, score
FROM GAME_SCORES
QUALIFY RANK() OVER (PARTITION BY team ORDER BY score DESC) <= 2
ORDER BY team, score DESC;

-- 3. Correlated subquery -- "keep me if fewer than 2 teammates
--    scored strictly higher than I did."
SELECT g1.team, g1.player_id, g1.score
FROM GAME_SCORES g1
WHERE (
    SELECT COUNT(*) FROM GAME_SCORES g2
    WHERE g2.team = g1.team AND g2.score > g1.score
) < 2
ORDER BY g1.team, g1.score DESC;

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 28:
--
-- 1. Count Blue team's rows in step 1 (ROW_NUMBER) vs. step 2 (RANK).
--    Are they the same count? P6 and P7 are tied at 95 for Blue's
--    2nd-highest score — does RANK<=2 include both of them or just
--    one? Explain why in terms of what RANK actually assigns to tied
--    rows.
--
-- 2. Compare step 3's row count for Blue to step 1 and step 2. Which
--    of the two window-function approaches does the correlated
--    subquery behave like? Explain why "count of teammates who scored
--    strictly higher" naturally produces that behavior for tied rows.
--
-- 3. An interviewer says: "I want exactly 2 players per team, no
--    matter what — pick any 2 if there's a tie." Which of these three
--    approaches do you reach for? Now they say: "Actually, I want
--    everyone tied for the cutoff position included, even if that's
--    more than 2 people." Which approach naturally gives you that
--    instead, with zero code changes needed?
-- ============================================================
