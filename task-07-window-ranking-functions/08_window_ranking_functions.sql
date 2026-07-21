-- ============================================================
-- Task 7 — Window functions: ROW_NUMBER, RANK, DENSE_RANK, NTILE
-- New schema for this category: small hand-built datasets designed
-- to actually contain ties, since the IOT data's float readings from
-- earlier tasks almost never tie and would hide the whole point.
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;
CREATE SCHEMA IF NOT EXISTS ADVANCED;
USE SCHEMA ADVANCED;

CREATE OR REPLACE TABLE GAME_SCORES (
    player_id STRING,
    team      STRING,
    score     INT
);

INSERT INTO GAME_SCORES (player_id, team, score) VALUES
    ('P1', 'Red',  100),
    ('P2', 'Red',  100),   -- tied with P1
    ('P3', 'Red',   90),
    ('P4', 'Red',   80),
    ('P5', 'Blue', 100),
    ('P6', 'Blue',  95),
    ('P7', 'Blue',  95),   -- tied with P6
    ('P8', 'Blue',  70);

-- 1. All four side by side. Read every column for the SAME row before
--    concluding anything -- the differences only show up where ties are.
SELECT
    team,
    player_id,
    score,
    ROW_NUMBER() OVER (PARTITION BY team ORDER BY score DESC)  AS rn,
    RANK()       OVER (PARTITION BY team ORDER BY score DESC)  AS rnk,
    DENSE_RANK() OVER (PARTITION BY team ORDER BY score DESC)  AS drnk,
    NTILE(2)     OVER (PARTITION BY team ORDER BY score DESC)  AS ntile2
FROM GAME_SCORES
ORDER BY team, score DESC;

-- 2. Isolate just the tied rows on Red's team (P1/P2 both scored 100)
--    to see the tie-breaking behavior in isolation.
SELECT player_id, score,
    ROW_NUMBER() OVER (ORDER BY score DESC) AS rn,
    RANK()       OVER (ORDER BY score DESC) AS rnk,
    DENSE_RANK() OVER (ORDER BY score DESC) AS drnk
FROM GAME_SCORES
WHERE team = 'Red'
ORDER BY score DESC;

-- 3. NTILE splits a partition into N roughly-equal buckets by row
--    count, NOT by score value -- it doesn't know or care that two
--    rows tied. Compare Red's ntile2 output to its actual scores.

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 8:
--
-- 1. On Red's team, P1 and P2 both scored 100. What rn, rnk, and
--    drnk value does each get, and specifically: does P3 (the next
--    player down, scoring 90) get rnk = 2 or rnk = 3? Why?
--
-- 2. ROW_NUMBER() assigns P1 and P2 different numbers (1 and 2) even
--    though they're tied. Is that outcome deterministic -- will P1
--    always get 1 and P2 always get 2 -- or could it flip between
--    runs? What would you add to the ORDER BY to make it fully
--    deterministic either way?
--
-- 3. NTILE(2) splits each team's 4 players into two buckets of 2. On
--    Blue's team, P6 and P7 are tied at 95 -- does NTILE guarantee
--    they land in the same bucket, or could a tie get split across
--    buckets? Run it and check.
-- ============================================================
