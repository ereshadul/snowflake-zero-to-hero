-- ============================================================
-- Task 25 — Gaps and islands problem
-- The named classic. Task 32 (later in this category) is a direct
-- application of this exact technique, so make sure the mechanism
-- below actually clicks, not just the final answer.
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;
USE SCHEMA ADVANCED;

CREATE OR REPLACE TABLE USER_LOGINS (
    user_name  STRING,
    login_date DATE
);
INSERT INTO USER_LOGINS (user_name, login_date) VALUES
    ('Alice', '2026-06-01'),
    ('Alice', '2026-06-02'),
    ('Alice', '2026-06-03'),
    -- gap here
    ('Alice', '2026-06-06'),
    ('Alice', '2026-06-07'),
    ('Bob',   '2026-06-01'),
    -- gap immediately
    ('Bob',   '2026-06-03'),
    ('Bob',   '2026-06-04');

-- The technique: ROW_NUMBER() increases by exactly 1 per row, and a
-- consecutive-day streak's login_date ALSO increases by exactly 1 per
-- row. Subtract one from the other and, for as long as the streak
-- stays unbroken, the result stays a CONSTANT -- the moment there's a
-- gap, that constant jumps to a new value. That constant becomes a
-- free grouping key for "which island does this row belong to."
WITH numbered AS (
    SELECT
        user_name, login_date,
        ROW_NUMBER() OVER (PARTITION BY user_name ORDER BY login_date) AS rn
    FROM USER_LOGINS
),
grouped AS (
    SELECT
        user_name, login_date, rn,
        DATEADD(day, -rn, login_date) AS island_group
    FROM numbered
)
SELECT
    user_name,
    island_group,
    MIN(login_date) AS streak_start,
    MAX(login_date) AS streak_end,
    COUNT(*)        AS streak_length
FROM grouped
GROUP BY user_name, island_group
ORDER BY user_name, streak_start;

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 26:
--
-- 1. Run just the `grouped` CTE by itself (SELECT * FROM grouped) and
--    look at Alice's rows. What island_group value do her first 3
--    rows (06-01, 06-02, 06-03) share, and what different value does
--    06-06 get? Compute both by hand (login_date minus rn, as a
--    literal date-minus-integer) to confirm you understand WHY they
--    differ, not just that they do.
--
-- 2. Bob's streak breaks after just ONE day (06-01), then resumes for
--    two consecutive days (06-03, 06-04). How many separate islands
--    does the final result show for Bob, and what's each one's
--    streak_length?
--
-- 3. This same "subtract the row number to get a constant" trick
--    works on consecutive INTEGERS just as well as consecutive DATES
--    (subtract rn from a numeric column instead of DATEADD). Sketch,
--    without necessarily running it, what that would look like for a
--    column of consecutive order IDs instead of dates.
-- ============================================================
