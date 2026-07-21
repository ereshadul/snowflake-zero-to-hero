-- ============================================================
-- Task 76 — CHANGE_TRACKING & the CHANGES() clause
-- Category: Streams
-- Completes the Streams category. CHANGES() gives you the same kind
-- of change data a Stream does, but queried ad hoc at read time --
-- no persistent, consumable object to create or manage.
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;
USE SCHEMA ADVANCED;

CREATE OR REPLACE TABLE CHANGES_DEMO (id INT, value INT);
ALTER TABLE CHANGES_DEMO SET CHANGE_TRACKING = TRUE;

INSERT INTO CHANGES_DEMO (id, value) VALUES (1, 100);

-- Capture "now" as a reference point, before the changes we actually
-- want to observe.
SET before_ts = (SELECT CURRENT_TIMESTAMP());

UPDATE CHANGES_DEMO SET value = 200 WHERE id = 1;
INSERT INTO CHANGES_DEMO (id, value) VALUES (2, 500);

-- 1. Query the changes since before_ts directly -- no STREAM object
--    was ever created for this table.
SELECT *, METADATA$ACTION, METADATA$ISUPDATE, METADATA$ROW_ID
FROM CHANGES_DEMO
    CHANGES(INFORMATION => DEFAULT)
    AT(TIMESTAMP => $before_ts)
ORDER BY id, METADATA$ACTION;

-- 2. Run the EXACT same query again, unchanged.
SELECT *, METADATA$ACTION, METADATA$ISUPDATE, METADATA$ROW_ID
FROM CHANGES_DEMO
    CHANGES(INFORMATION => DEFAULT)
    AT(TIMESTAMP => $before_ts)
ORDER BY id, METADATA$ACTION;

-- ============================================================
-- UNDERSTANDING CHECK — this closes out the Streams category:
--
-- 1. Compare step 1 and step 2's results. Are they identical? A
--    Stream's offset gets consumed by a committed DML read (Task 74).
--    Does querying CHANGES() the same way twice behave the same way,
--    or does CHANGES() have no persistent state to consume at all?
--
-- 2. A Stream is a named object you CREATE once, that persists and
--    tracks "everything since I was last consumed," automatically.
--    CHANGES() needs no such object — just CHANGE_TRACKING = TRUE and
--    an AT/BEFORE clause supplied at query time. Given both expose
--    the same METADATA$ columns, when would you actually still want a
--    real Stream instead of just querying CHANGES() whenever you need
--    to?
--
-- 3. Using CHANGES() means YOU have to remember and supply the
--    correct AT(TIMESTAMP => ...) reference point every time you
--    query it. What operational responsibility does that put on you
--    (or your pipeline code) that a Stream's automatic offset-tracking
--    handles for you without any extra bookkeeping?
-- ============================================================
