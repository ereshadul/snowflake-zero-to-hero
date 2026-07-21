-- ============================================================
-- Task 69 — STANDARD stream
-- Category: Streams
--
-- About this category: Tasks 69-76 cover Change Data Capture (CDC) --
-- tracking what changed on a table since you last looked, instead of
-- diffing snapshots yourself (the way Task 63 did by hand).
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;
USE SCHEMA ADVANCED;

CREATE OR REPLACE TABLE STREAM_DEMO_SOURCE (id INT, name STRING, value INT);
CREATE OR REPLACE STREAM STREAM_DEMO_STREAM ON TABLE STREAM_DEMO_SOURCE;

-- 1. Insert two rows, then look at the stream.
INSERT INTO STREAM_DEMO_SOURCE (id, name, value) VALUES (1, 'Alice', 100), (2, 'Bob', 200);

SELECT *, METADATA$ACTION, METADATA$ISUPDATE
FROM STREAM_DEMO_STREAM;
-- Expect 2 rows, both METADATA$ACTION = 'INSERT'.

-- 2. Update one of them, then look at the stream AGAIN (without ever
--    consuming it in between).
UPDATE STREAM_DEMO_SOURCE SET value = 150 WHERE id = 1;

SELECT *, METADATA$ACTION, METADATA$ISUPDATE
FROM STREAM_DEMO_STREAM
ORDER BY id, METADATA$ACTION;
-- The stream still shows the original 2 inserts, PLUS a new pair for
-- the updated row.

-- 3. Delete the other row.
DELETE FROM STREAM_DEMO_SOURCE WHERE id = 2;

SELECT *, METADATA$ACTION, METADATA$ISUPDATE
FROM STREAM_DEMO_STREAM
ORDER BY id, METADATA$ACTION;

-- 4. Has this stream ever been consumed? Check.
SELECT SYSTEM$STREAM_HAS_DATA('STREAM_DEMO_STREAM');

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 70:
--
-- 1. After step 2's UPDATE, how many TOTAL rows does the stream show
--    for id = 1, and what METADATA$ACTION/METADATA$ISUPDATE values do
--    they have? Confirm a STANDARD stream represents an UPDATE as a
--    DELETE+INSERT pair, not a single row with an "UPDATE" action.
--
-- 2. Run the SELECT from step 1 again, right now, a second time.
--    Do the exact same rows still show up, or have they disappeared?
--    What does that tell you about whether merely SELECTing from a
--    stream consumes/advances it? (Task 74 covers what actually DOES
--    consume it — for now, just observe that SELECT alone doesn't.)
--
-- 3. SYSTEM$STREAM_HAS_DATA in step 4 should report TRUE, since
--    nothing has ever been consumed. If you'd created the stream but
--    never inserted/updated/deleted a single row, what would
--    SYSTEM$STREAM_HAS_DATA report instead, and why does that
--    function exist as a separate check rather than everyone just
--    running SELECT COUNT(*) FROM the_stream to see if it's empty?
-- ============================================================
