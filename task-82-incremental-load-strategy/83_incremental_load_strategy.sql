-- ============================================================
-- Task 82 — Incremental load strategy
-- Category: Tasks, deeper
-- Completes this category. Compares three approaches side by side,
-- specifically constructing the late-arriving-row scenario that
-- breaks timestamp watermarking but not CDC.
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;
USE SCHEMA ADVANCED;

CREATE OR REPLACE TABLE INCREMENTAL_SOURCE (id INT, value STRING, updated_at TIMESTAMP_NTZ);
INSERT INTO INCREMENTAL_SOURCE (id, value, updated_at) VALUES
    (1, 'A', '2026-06-01 10:00:00'),
    (2, 'B', '2026-06-01 11:00:00');

-- Stream created NOW, so it tracks everything from this point forward
-- -- unlike the watermark approach, it doesn't care about timestamp
-- VALUES at all, only actual committed changes.
CREATE OR REPLACE STREAM INCREMENTAL_SOURCE_STREAM ON TABLE INCREMENTAL_SOURCE;

-- 1. Full reload -- simplest, correct, but rescans/rewrites everything
--    every single time regardless of what actually changed.
CREATE OR REPLACE TABLE INCREMENTAL_TARGET_FULL (id INT, value STRING);
TRUNCATE TABLE INCREMENTAL_TARGET_FULL;
INSERT INTO INCREMENTAL_TARGET_FULL SELECT id, value FROM INCREMENTAL_SOURCE;

-- 2. Timestamp-watermark incremental -- track the last time you
--    synced, only pull rows newer than that.
CREATE OR REPLACE TABLE INCREMENTAL_TARGET_WATERMARK (id INT, value STRING, synced_at TIMESTAMP_NTZ);
CREATE OR REPLACE TABLE WATERMARK_TRACKER (table_name STRING, last_watermark TIMESTAMP_NTZ);
INSERT INTO WATERMARK_TRACKER (table_name, last_watermark) VALUES ('INCREMENTAL_SOURCE', '2026-06-01 00:00:00');

INSERT INTO INCREMENTAL_TARGET_WATERMARK (id, value, synced_at)
SELECT id, value, CURRENT_TIMESTAMP()
FROM INCREMENTAL_SOURCE
WHERE updated_at > (SELECT last_watermark FROM WATERMARK_TRACKER WHERE table_name = 'INCREMENTAL_SOURCE');

UPDATE WATERMARK_TRACKER
SET last_watermark = (SELECT MAX(updated_at) FROM INCREMENTAL_SOURCE)
WHERE table_name = 'INCREMENTAL_SOURCE';

-- 3. Now: a LATE-ARRIVING row shows up, with an updated_at timestamp
--    OLDER than the watermark you just set (a genuinely common
--    real-world case -- e.g. a backfill, or a source system with
--    clock skew).
INSERT INTO INCREMENTAL_SOURCE (id, value, updated_at) VALUES
    (3, 'C-late-arrival', '2026-06-01 09:30:00');

-- Re-run the EXACT same watermark-based incremental query.
INSERT INTO INCREMENTAL_TARGET_WATERMARK (id, value, synced_at)
SELECT id, value, CURRENT_TIMESTAMP()
FROM INCREMENTAL_SOURCE
WHERE updated_at > (SELECT last_watermark FROM WATERMARK_TRACKER WHERE table_name = 'INCREMENTAL_SOURCE');

SELECT * FROM INCREMENTAL_TARGET_WATERMARK ORDER BY id;

-- 4. Check the STREAM instead -- did IT catch the late-arriving row?
SELECT *, METADATA$ACTION FROM INCREMENTAL_SOURCE_STREAM ORDER BY id;

-- ============================================================
-- UNDERSTANDING CHECK — this closes out the Tasks, deeper category:
--
-- 1. Is id=3 (the late arrival) present in INCREMENTAL_TARGET_WATERMARK
--    after step 3's re-run? Explain exactly why the watermark
--    approach missed it — walk through the WHERE clause with id=3's
--    actual updated_at value and the watermark's value.
--
-- 2. Is id=3 present in step 4's stream output? Why does the stream
--    catch this row when the watermark approach couldn't — what is
--    the stream actually keying off of instead of a timestamp column?
--
-- 3. Given the watermark approach can silently miss late-arriving
--    rows while the stream-based approach can't, why would anyone
--    still choose timestamp watermarking over CDC/streams for
--    incremental loading? Think about source systems the stream
--    approach genuinely can't be used against (hint: what does
--    CREATE STREAM actually require of its source).
-- ============================================================
