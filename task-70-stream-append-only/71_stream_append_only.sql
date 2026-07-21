-- ============================================================
-- Task 70 — APPEND-ONLY stream
-- Category: Streams
-- A second stream on the SAME table as Task 69, so you can directly
-- compare STANDARD vs. APPEND_ONLY behavior against identical DML.
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;
USE SCHEMA ADVANCED;

CREATE OR REPLACE STREAM STREAM_DEMO_APPEND_ONLY
    ON TABLE STREAM_DEMO_SOURCE
    APPEND_ONLY = TRUE;

-- 1. Insert two fresh rows.
INSERT INTO STREAM_DEMO_SOURCE (id, name, value) VALUES (3, 'Carol', 300), (4, 'Dave', 400);

SELECT *, METADATA$ACTION FROM STREAM_DEMO_APPEND_ONLY;
-- Compare this to what Task 69's STANDARD stream shows for the exact
-- same rows -- run the equivalent SELECT against STREAM_DEMO_STREAM
-- too if it's still around.

-- 2. Update one of the rows you just inserted.
UPDATE STREAM_DEMO_SOURCE SET value = 350 WHERE id = 3;

SELECT *, METADATA$ACTION FROM STREAM_DEMO_APPEND_ONLY;
-- Does this look the same as it did after step 1, or different?

-- 3. Delete a row that's never been touched by an UPDATE.
DELETE FROM STREAM_DEMO_SOURCE WHERE id = 4;

SELECT *, METADATA$ACTION FROM STREAM_DEMO_APPEND_ONLY;
-- Does Dave's row still appear at all?

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 71:
--
-- 1. Compare step 1's output between this APPEND_ONLY stream and
--    Task 69's STANDARD stream for the same fresh inserts. Are they
--    identical for pure inserts with no later changes?
--
-- 2. Step 2 updates row id=3 (which, under the hood, is a delete of
--    the old version plus an insert of the new version). Does the
--    APPEND_ONLY stream's output change at all after this UPDATE, or
--    does it look exactly like it did after step 1? What does that
--    tell you about whether an append-only stream can ever show you
--    that a row was modified?
--
-- 3. Step 3 deletes row id=4, which was NEVER updated, only originally
--    inserted and never consumed from this stream. Does Dave's row
--    still show up in the APPEND_ONLY stream's output after being
--    deleted, or has it vanished entirely? Compare this to what would
--    happen in Task 69's STANDARD stream for the identical sequence —
--    which one actually tells you "this row was deleted," and which
--    one just quietly forgets it existed?
-- ============================================================
