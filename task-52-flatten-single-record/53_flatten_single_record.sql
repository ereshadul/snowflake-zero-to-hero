-- ============================================================
-- Task 52 — FLATTEN a single JSON record
-- Category: Semi-structured data
-- FLATTEN is a specific, purpose-built table function -- the general
-- LATERAL mechanism behind it was Task 21. This task is the promised
-- follow-up: FLATTEN specifically, on its own.
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;
USE SCHEMA ADVANCED;

CREATE OR REPLACE TABLE SINGLE_DEVICE_EVENT (event_id STRING, payload VARIANT);

INSERT INTO SINGLE_DEVICE_EVENT
SELECT 'E1', PARSE_JSON('{"sensor_id": "SENSOR_001", "alerts": ["LOW_BATTERY", "SIGNAL_LOSS"], "calibration_offset": -1.2}');

INSERT INTO SINGLE_DEVICE_EVENT
SELECT 'E2', PARSE_JSON('{"sensor_id": "SENSOR_002", "alerts": [], "calibration_offset": 0.3}');

-- 1. FLATTEN the alerts array of E1 -- one output row per element.
SELECT event_id, f.value::STRING AS alert
FROM SINGLE_DEVICE_EVENT,
     LATERAL FLATTEN(input => payload:alerts) f
WHERE event_id = 'E1';

-- 2. The FULL set of columns FLATTEN produces, not just value.
SELECT event_id, f.seq, f.index, f.key, f.path, f.value
FROM SINGLE_DEVICE_EVENT,
     LATERAL FLATTEN(input => payload:alerts) f
WHERE event_id = 'E1';

-- 3. Now flatten E2, whose alerts array is EMPTY.
SELECT event_id, f.value::STRING AS alert
FROM SINGLE_DEVICE_EVENT,
     LATERAL FLATTEN(input => payload:alerts) f
WHERE event_id = 'E2';
-- Count the rows this actually returns.

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 53:
--
-- 1. E1's alerts array has 2 elements. How many rows does step 1
--    produce? Now look at step 3's result for E2 (an EMPTY alerts
--    array, []) — does FLATTEN produce zero rows, or one row with a
--    NULL value? What does that mean for a query that FLATTENs
--    across many devices at once, some with empty arrays — does E2
--    disappear entirely from the result, or does it still show up
--    once with a NULL alert?
--
-- 2. Task 21 taught LATERAL as the GENERAL mechanism for calling a
--    table function once per outer row. Is FLATTEN a genuinely
--    different concept from what you learned there, or literally the
--    same mechanism applied through a specific, pre-built table
--    function Snowflake ships for you? Justify your answer using
--    what the syntax actually looks like in step 1.
--
-- 3. For E1 alone, do f.seq and f.index end up with the same values,
--    or different ones? seq identifies which OUTER row a flattened
--    result came from (useful when flattening MULTIPLE outer rows at
--    once — the subject of Task 53 next), while index identifies
--    position WITHIN one array. With only one outer row here, would
--    you expect them to look identical or genuinely different?
-- ============================================================
