-- ============================================================
-- Task 72 — Stream on multiple tables
-- Category: Streams
-- The key behavior: streams referenced within the SAME transaction
-- advance atomically together -- all commit, or none do.
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;
USE SCHEMA ADVANCED;

CREATE OR REPLACE TABLE TEAM_ROSTER  (player_id STRING, team STRING);
CREATE OR REPLACE TABLE PLAYER_STATS (player_id STRING, score INT);
CREATE OR REPLACE STREAM TEAM_ROSTER_STREAM  ON TABLE TEAM_ROSTER;
CREATE OR REPLACE STREAM PLAYER_STATS_STREAM ON TABLE PLAYER_STATS;

INSERT INTO TEAM_ROSTER  (player_id, team)  VALUES ('P1', 'Red');
INSERT INTO PLAYER_STATS (player_id, score) VALUES ('P1', 100);

CREATE OR REPLACE TABLE COMBINED_LOG (
    source_table STRING, player_id STRING, detail STRING, logged_at TIMESTAMP_NTZ
);

-- 1. Read BOTH streams inside one transaction, then ROLL IT BACK.
BEGIN;
INSERT INTO COMBINED_LOG
    SELECT 'TEAM_ROSTER', player_id, team, CURRENT_TIMESTAMP() FROM TEAM_ROSTER_STREAM;
INSERT INTO COMBINED_LOG
    SELECT 'PLAYER_STATS', player_id, TO_VARCHAR(score), CURRENT_TIMESTAMP() FROM PLAYER_STATS_STREAM;
ROLLBACK;

-- Check both streams -- did rolling back leave them fully unconsumed?
SELECT SYSTEM$STREAM_HAS_DATA('TEAM_ROSTER_STREAM')  AS roster_still_has_data;
SELECT SYSTEM$STREAM_HAS_DATA('PLAYER_STATS_STREAM') AS stats_still_has_data;

-- 2. Same thing again, but COMMIT this time.
BEGIN;
INSERT INTO COMBINED_LOG
    SELECT 'TEAM_ROSTER', player_id, team, CURRENT_TIMESTAMP() FROM TEAM_ROSTER_STREAM;
INSERT INTO COMBINED_LOG
    SELECT 'PLAYER_STATS', player_id, TO_VARCHAR(score), CURRENT_TIMESTAMP() FROM PLAYER_STATS_STREAM;
COMMIT;

SELECT SYSTEM$STREAM_HAS_DATA('TEAM_ROSTER_STREAM')  AS roster_has_data_after_commit;
SELECT SYSTEM$STREAM_HAS_DATA('PLAYER_STATS_STREAM') AS stats_has_data_after_commit;

SELECT * FROM COMBINED_LOG ORDER BY logged_at;

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 73:
--
-- 1. After step 1's ROLLBACK, confirm BOTH streams still show TRUE
--    for SYSTEM$STREAM_HAS_DATA. What does that confirm about whether
--    stream advancement is tied to the individual INSERT statement,
--    or to the transaction as a whole committing?
--
-- 2. After step 2's COMMIT, both streams should show FALSE. Now
--    imagine one of the two INSERT statements had been accidentally
--    left out of that transaction (say, only TEAM_ROSTER_STREAM got
--    read). Would PLAYER_STATS_STREAM still show as consumed just
--    because the transaction committed, or does a stream only
--    advance if something inside that transaction actually READ
--    from it?
--
-- 3. Why does it matter, for a real pipeline, that TEAM_ROSTER_STREAM
--    and PLAYER_STATS_STREAM advance together atomically rather than
--    independently? Describe what could go wrong for a downstream
--    system if roster changes and stats changes could get consumed
--    out of sync with each other (one advancing without the other).
-- ============================================================
