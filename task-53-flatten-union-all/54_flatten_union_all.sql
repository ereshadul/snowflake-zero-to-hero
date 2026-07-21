-- ============================================================
-- Task 53 — FLATTEN + UNION ALL multiple records
-- Category: Semi-structured data
-- Two different multi-record problems in one task: (a) flattening
-- across EVERY row of a table at once instead of one at a time
-- (Task 52 filtered to a single event_id), and (b) combining
-- flatten results from TWO DIFFERENT array fields via UNION ALL.
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;
USE SCHEMA ADVANCED;

CREATE OR REPLACE TABLE MULTI_ALERT_EVENTS (event_id STRING, payload VARIANT);

INSERT INTO MULTI_ALERT_EVENTS
SELECT 'E1', PARSE_JSON('{"alerts": ["LOW_BATTERY"], "warnings": ["FIRMWARE_OUTDATED", "CALIBRATION_DUE"]}');
INSERT INTO MULTI_ALERT_EVENTS
SELECT 'E2', PARSE_JSON('{"alerts": ["SIGNAL_LOSS", "LOW_BATTERY"], "warnings": []}');

-- 1. FLATTEN across EVERY row at once -- no WHERE filtering to one
--    event_id this time. LATERAL naturally joins each flattened
--    element back to the SPECIFIC row it came from.
SELECT event_id, f.value::STRING AS alert
FROM MULTI_ALERT_EVENTS,
     LATERAL FLATTEN(input => payload:alerts) f
ORDER BY event_id;

-- 2. Combining flatten results from TWO DIFFERENT array fields
--    (alerts AND warnings) into one unified list, tagging which type
--    each row came from, via UNION ALL.
SELECT event_id, 'alert' AS flag_type, f.value::STRING AS flag_value
FROM MULTI_ALERT_EVENTS,
     LATERAL FLATTEN(input => payload:alerts) f

UNION ALL

SELECT event_id, 'warning' AS flag_type, f.value::STRING AS flag_value
FROM MULTI_ALERT_EVENTS,
     LATERAL FLATTEN(input => payload:warnings) f

ORDER BY event_id, flag_type;

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 54:
--
-- 1. Step 1 flattens BOTH E1 and E2's alerts in a single query, with
--    no WHERE clause restricting to one event. How many total rows
--    come back, and does each row correctly show WHICH event_id it
--    belongs to? What part of the query is responsible for keeping
--    each flattened element attached to its correct originating row?
--
-- 2. E2's warnings array is empty. In step 2's combined result, does
--    E2 still appear at all under flag_type = 'warning', or does it
--    disappear from that half of the UNION ALL entirely? Connect this
--    back to what you found in Task 52 about flattening an empty
--    array.
--
-- 3. Why UNION ALL specifically, instead of plain UNION, to combine
--    the two FLATTEN queries in step 2? Is there a realistic scenario
--    where a genuine duplicate row (same event_id, same flag_type,
--    same flag_value) could legitimately occur here, and would plain
--    UNION silently and incorrectly remove it?
-- ============================================================
