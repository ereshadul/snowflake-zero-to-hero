-- ============================================================
-- Task 83 — AT / BEFORE queries
-- Category: Time Travel & cloning
--
-- About this category: Tasks 83-87 cover querying and recovering past
-- states without a backup system of your own -- Snowflake keeps this
-- history natively.
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;
USE SCHEMA ADVANCED;

CREATE OR REPLACE TABLE TIME_TRAVEL_DEMO (id INT, value INT);
INSERT INTO TIME_TRAVEL_DEMO (id, value) VALUES (1, 100);

-- Capture a reference point BEFORE the changes below.
SET before_changes_ts = (SELECT CURRENT_TIMESTAMP());

UPDATE TIME_TRAVEL_DEMO SET value = 200 WHERE id = 1;
INSERT INTO TIME_TRAVEL_DEMO (id, value) VALUES (2, 300);

-- 1. Current state.
SELECT * FROM TIME_TRAVEL_DEMO ORDER BY id;

-- 2. AT(TIMESTAMP) -- state as of the captured reference point.
SELECT * FROM TIME_TRAVEL_DEMO AT(TIMESTAMP => $before_changes_ts) ORDER BY id;

-- 3. AT(OFFSET) -- state as of N seconds before NOW (evaluated at
--    query time, not against a fixed saved value).
SELECT * FROM TIME_TRAVEL_DEMO AT(OFFSET => -60) ORDER BY id;

-- 4. BEFORE(STATEMENT) -- state right before a SPECIFIC query ran,
--    identified by its query ID rather than a timestamp at all.
SELECT QUERY_ID, QUERY_TEXT, START_TIME
FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY())
WHERE QUERY_TEXT ILIKE '%UPDATE TIME_TRAVEL_DEMO%'
ORDER BY START_TIME DESC
LIMIT 1;
-- Copy the QUERY_ID from that result into the query below.

-- SELECT * FROM TIME_TRAVEL_DEMO BEFORE(STATEMENT => '<paste QUERY_ID here>') ORDER BY id;

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 84:
--
-- 1. Compare step 1 (current state) to step 2 (AT the captured
--    timestamp). Confirm step 2 shows ONLY id=1 with value=100, and
--    id=2 doesn't exist yet in that historical view — even though
--    both rows exist right now.
--
-- 2. Step 3 uses AT(OFFSET => -60) — "60 seconds before whenever this
--    query actually runs." If you run this exact query 5 minutes
--    after making your changes, would it show the OLD state (before
--    the UPDATE/INSERT) or the CURRENT state? What determines where
--    the cutoff actually falls?
--
-- 3. Run step 4's BEFORE(STATEMENT => ...) query with the real query
--    ID you found. Confirm it reproduces the same result as step 2.
--    Now describe a realistic scenario where you'd know WHICH query
--    caused a problem but NOT the exact timestamp it ran at — why
--    would BEFORE(STATEMENT) be the more natural tool there than
--    AT(TIMESTAMP)?
-- ============================================================
