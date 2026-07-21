-- ============================================================
-- Task 73 — Stream on a view
-- Category: Streams
-- A stream on a view tracks changes to the VIEW'S RESULT SET -- which
-- can differ from what actually happened to the base table.
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;
USE SCHEMA ADVANCED;

CREATE OR REPLACE TABLE VIEW_STREAM_BASE (id INT, name STRING, status STRING);
ALTER TABLE VIEW_STREAM_BASE SET CHANGE_TRACKING = TRUE;

CREATE OR REPLACE VIEW ACTIVE_ROWS_VIEW AS
SELECT id, name, status FROM VIEW_STREAM_BASE WHERE status = 'ACTIVE';
ALTER VIEW ACTIVE_ROWS_VIEW SET CHANGE_TRACKING = TRUE;

CREATE OR REPLACE STREAM ACTIVE_ROWS_STREAM ON VIEW ACTIVE_ROWS_VIEW;

-- 1. Insert one active row and one inactive row.
INSERT INTO VIEW_STREAM_BASE (id, name, status) VALUES (1, 'Alice', 'ACTIVE'), (2, 'Bob', 'INACTIVE');

SELECT *, METADATA$ACTION FROM ACTIVE_ROWS_STREAM;
-- Only Alice should appear -- Bob is filtered out by the view's WHERE
-- clause, so the stream (which tracks the VIEW's output) never sees him.

-- 2. Bob becomes active -- a base-table UPDATE, but from the view's
--    perspective, his row is newly APPEARING in the filtered result.
UPDATE VIEW_STREAM_BASE SET status = 'ACTIVE' WHERE id = 2;

SELECT *, METADATA$ACTION FROM ACTIVE_ROWS_STREAM;

-- 3. Alice becomes inactive -- her base-table row still exists, but
--    she now disappears from the filtered view entirely.
UPDATE VIEW_STREAM_BASE SET status = 'INACTIVE' WHERE id = 1;

SELECT *, METADATA$ACTION FROM ACTIVE_ROWS_STREAM;

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 74:
--
-- 1. In step 2, the actual database operation was an UPDATE on
--    VIEW_STREAM_BASE. What METADATA$ACTION does the stream show for
--    Bob's row — INSERT, UPDATE, or something else? Explain why,
--    from the view's point of view rather than the base table's.
--
-- 2. In step 3, Alice's base-table row was never deleted, only
--    changed. What METADATA$ACTION does the stream show for her row?
--    Why does a row LEAVING a filtered view's result set count as a
--    delete from the stream's perspective, even though nothing was
--    actually deleted from the underlying table?
--
-- 3. This task required TWO explicit ALTER statements
--    (SET CHANGE_TRACKING = TRUE on both the base table and the view)
--    before CREATE STREAM would even work. Task 69's stream on a
--    plain table needed no such setup at all. Why does a view
--    specifically require this extra step that a base table doesn't?
-- ============================================================
