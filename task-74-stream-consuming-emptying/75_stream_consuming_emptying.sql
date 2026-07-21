-- ============================================================
-- Task 74 — Consuming/emptying a stream
-- Category: Streams
-- The gotcha this task is built around: a "harmless" query someone
-- writes just to peek at a stream's contents can accidentally empty
-- it before the real downstream consumer ever sees the data.
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;
USE SCHEMA ADVANCED;

CREATE OR REPLACE TABLE STREAM_TEST_SCRATCH (id INT, name STRING, value INT, action STRING);

INSERT INTO STREAM_DEMO_SOURCE (id, name, value) VALUES (10, 'Frank', 1000);

-- 1. A bare SELECT, run twice. Confirm it never consumes, no matter
--    how many times you run it (same result you saw briefly in Task
--    69 -- now isolated and confirmed deliberately).
SELECT * FROM STREAM_DEMO_STREAM;
SELECT * FROM STREAM_DEMO_STREAM;

-- 2. The accidental-consumption gotcha: "let me just save this off to
--    look at it properly" -- this INSERT reads FROM the stream, and
--    that's enough to consume it, even though the intent was just to
--    inspect the data, not to "really" process it.
INSERT INTO STREAM_TEST_SCRATCH (id, name, value, action)
SELECT id, name, value, METADATA$ACTION FROM STREAM_DEMO_STREAM;

SELECT SYSTEM$STREAM_HAS_DATA('STREAM_DEMO_STREAM');

-- 3. Confirm it's not just INSERT that does this -- CREATE TABLE AS
--    SELECT reading from a stream consumes it too.
INSERT INTO STREAM_DEMO_SOURCE (id, name, value) VALUES (11, 'Grace', 1100);

CREATE OR REPLACE TABLE STREAM_SNAPSHOT AS
SELECT * FROM STREAM_DEMO_STREAM;

SELECT SYSTEM$STREAM_HAS_DATA('STREAM_DEMO_STREAM');

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 75:
--
-- 1. Confirm step 1's two SELECTs return the identical rows both
--    times. State plainly: does a bare SELECT ever consume a stream,
--    regardless of how many times it's run?
--
-- 2. Step 2's INSERT was written with the innocent intent of "just
--    saving a copy to look at." Confirm SYSTEM$STREAM_HAS_DATA became
--    FALSE afterward. What specifically about that statement (not the
--    SELECT clause itself, but the statement as a whole) is what
--    actually triggers consumption?
--
-- 3. Step 3 shows CREATE TABLE AS SELECT also consumes the stream.
--    Given both INSERT...SELECT and CREATE TABLE AS SELECT consume it
--    while a bare SELECT never does, state the general rule: what
--    kind of statement actually advances a stream's offset — one that
--    merely reads from it, or one that COMMITS a DML/DDL operation
--    whose source is the stream?
-- ============================================================
