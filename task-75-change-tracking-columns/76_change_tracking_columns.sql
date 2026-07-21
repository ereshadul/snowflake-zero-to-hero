-- ============================================================
-- Task 75 — Change-tracking columns (METADATA$...)
-- Category: Streams
-- The canonical "reconstruct before/after from a stream" pattern,
-- using METADATA$ROW_ID to pair an update's DELETE half with its
-- INSERT half back into one row.
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;
USE SCHEMA ADVANCED;

CREATE OR REPLACE TABLE METADATA_DEMO (id INT, value INT);
-- Baseline rows, inserted BEFORE the stream exists, so they're
-- already "settled" and won't show up as stream noise below.
INSERT INTO METADATA_DEMO (id, value) VALUES (1, 100), (3, 300);

CREATE OR REPLACE STREAM METADATA_DEMO_STREAM ON TABLE METADATA_DEMO;

-- Three independent, clean scenarios on three different rows.
UPDATE METADATA_DEMO SET value = 200 WHERE id = 1;   -- update
INSERT INTO METADATA_DEMO (id, value) VALUES (2, 500); -- pure insert
DELETE FROM METADATA_DEMO WHERE id = 3;               -- pure delete

-- 1. Raw stream output with all three metadata columns.
SELECT *, METADATA$ACTION, METADATA$ISUPDATE, METADATA$ROW_ID
FROM METADATA_DEMO_STREAM
ORDER BY id, METADATA$ACTION;

-- 2. Reconstruct the update's before/after value in ONE row, using
--    METADATA$ROW_ID to pair the DELETE half with the INSERT half of
--    the same logical row.
SELECT
    ins.id,
    del.value AS old_value,
    ins.value AS new_value
FROM METADATA_DEMO_STREAM ins
JOIN METADATA_DEMO_STREAM del
    ON ins.METADATA$ROW_ID = del.METADATA$ROW_ID
WHERE ins.METADATA$ACTION = 'INSERT' AND ins.METADATA$ISUPDATE
  AND del.METADATA$ACTION = 'DELETE' AND del.METADATA$ISUPDATE;

-- ============================================================
-- UNDERSTANDING CHECK — this closes out the Streams category:
--
-- 1. Compare METADATA$ISUPDATE across the three rows in step 1's
--    output: id=1's two rows, id=2's row, id=3's row. Confirm it's
--    TRUE only for the update pair (id=1) and FALSE for the genuine
--    standalone insert (id=2) and delete (id=3).
--
-- 2. Confirm id=1's DELETE row and INSERT row share the exact SAME
--    METADATA$ROW_ID, while id=2 and id=3 each have their own
--    distinct ROW_ID. What does ROW_ID let you do in step 2's query
--    that METADATA$ACTION and METADATA$ISUPDATE alone couldn't?
--
-- 3. Could you reliably pair up an update's DELETE and INSERT rows
--    using just the `id` column instead of METADATA$ROW_ID? Describe
--    a realistic scenario (think about what makes a real primary key
--    UPDATE-able) where matching by id alone would give you the wrong
--    pairing, but ROW_ID would still work correctly.
-- ============================================================
