-- ============================================================
-- Task 32 — Consecutive/streak detection
-- Directly extends Task 25's gaps-and-islands technique: find every
-- island first, then keep only the LONGEST one per user.
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;
USE SCHEMA ADVANCED;

WITH numbered AS (
    SELECT
        user_name, login_date,
        ROW_NUMBER() OVER (PARTITION BY user_name ORDER BY login_date) AS rn
    FROM USER_LOGINS
),
grouped AS (
    SELECT
        user_name, login_date,
        DATEADD(day, -rn, login_date) AS island_group
    FROM numbered
),
streaks AS (
    SELECT
        user_name, island_group,
        MIN(login_date) AS streak_start,
        MAX(login_date) AS streak_end,
        COUNT(*)        AS streak_length
    FROM grouped
    GROUP BY user_name, island_group
)

-- 1. Just the LENGTH of each user's longest streak.
SELECT user_name, MAX(streak_length) AS longest_streak
FROM streaks
GROUP BY user_name
ORDER BY user_name;

-- 2. The FULL DETAILS (which specific dates) of each user's longest
--    streak — a plain MAX()+GROUP BY can't keep the start/end dates
--    attached, so this needs QUALIFY (Task 17) instead.
WITH numbered AS (
    SELECT
        user_name, login_date,
        ROW_NUMBER() OVER (PARTITION BY user_name ORDER BY login_date) AS rn
    FROM USER_LOGINS
),
grouped AS (
    SELECT
        user_name, login_date,
        DATEADD(day, -rn, login_date) AS island_group
    FROM numbered
),
streaks AS (
    SELECT
        user_name, island_group,
        MIN(login_date) AS streak_start,
        MAX(login_date) AS streak_end,
        COUNT(*)        AS streak_length
    FROM grouped
    GROUP BY user_name, island_group
)
SELECT user_name, streak_start, streak_end, streak_length
FROM streaks
QUALIFY ROW_NUMBER() OVER (PARTITION BY user_name ORDER BY streak_length DESC) = 1
ORDER BY user_name;

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 33:
--
-- 1. Confirm Alice's longest_streak from step 1 is 3 (her 06-01
--    through 06-03 run). Trace through the `streaks` CTE by hand:
--    what are her TWO separate islands, and what length does each
--    have?
--
-- 2. Step 1 gives you the NUMBER 3, but not which dates made up that
--    streak. Explain concretely why `MAX(streak_length) GROUP BY
--    user_name` structurally can't also show you streak_start and
--    streak_end for that specific longest island, while step 2's
--    QUALIFY approach can.
--
-- 3. If a user had two DIFFERENT islands tied for the longest length
--    (say, two separate 3-day streaks), what would step 2's
--    ROW_NUMBER-based QUALIFY show — one of them, or both? What
--    single-word change to the query would show both tied streaks
--    instead of picking one arbitrarily?
-- ============================================================
