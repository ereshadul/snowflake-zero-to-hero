-- ============================================================
-- Task 86 — Zero-copy clone (schema/database)
-- Category: Time Travel & cloning
-- Clones the ENTIRE ADVANCED schema (every table/stream built across
-- this whole roadmap) and then the whole IOT_LAB database, in one
-- statement each.
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;

-- 1. Clone an entire schema -- every table, view, and stream inside
--    it, in one shot.
CREATE OR REPLACE SCHEMA IOT_LAB.ADVANCED_CLONE CLONE IOT_LAB.ADVANCED;

SHOW TABLES IN SCHEMA IOT_LAB.ADVANCED_CLONE;

SELECT COUNT(*) AS original_count FROM IOT_LAB.ADVANCED.GAME_SCORES;
SELECT COUNT(*) AS clone_count    FROM IOT_LAB.ADVANCED_CLONE.GAME_SCORES;

-- 2. Did the STREAM come along, and with its consumption state intact?
SHOW STREAMS IN SCHEMA IOT_LAB.ADVANCED_CLONE;

SELECT SYSTEM$STREAM_HAS_DATA('IOT_LAB.ADVANCED.STREAM_DEMO_STREAM')       AS original_stream_state;
SELECT SYSTEM$STREAM_HAS_DATA('IOT_LAB.ADVANCED_CLONE.STREAM_DEMO_STREAM') AS clone_stream_state;

-- 3. Clone the WHOLE DATABASE -- a full environment snapshot,
--    RAW/CURATED/ADVANCED schemas and everything in them, together.
CREATE OR REPLACE DATABASE IOT_LAB_SNAPSHOT CLONE IOT_LAB;

SHOW SCHEMAS IN DATABASE IOT_LAB_SNAPSHOT;

-- 4. Clean up -- both of these clones are real objects now.
DROP SCHEMA IOT_LAB.ADVANCED_CLONE;
DROP DATABASE IOT_LAB_SNAPSHOT;

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 87:
--
-- 1. Confirm step 2's two SYSTEM$STREAM_HAS_DATA results. Did the
--    cloned stream carry over the EXACT SAME consumption state
--    (offset) as the original, or did it reset to something else?
--
-- 2. What's a real use case for cloning an entire DATABASE (step 3)
--    rather than just one schema (step 1) — think about what "a full
--    environment snapshot" is actually used for in a real company
--    (hint: think about what you'd want before a risky migration).
--
-- 3. If IOT_LAB had contained a RUNNING task inside one of its
--    schemas at clone time, would that task exist in the clone too?
--    If so, would it come back RUNNING or SUSPENDED by default? Why
--    would Snowflake choose that specific default, given the risk of
--    accidentally ending up with two copies of the same task both
--    actively running (and billing) at once?
-- ============================================================
