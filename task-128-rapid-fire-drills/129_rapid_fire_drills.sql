-- ============================================================
-- Task 128 — Rapid-fire drills
-- Category: Cert & interview prep
-- Task 127 was untimed, multiple-choice-style review. This is
-- different: SYNTAX RECALL, fast. For each prompt, write the actual
-- SQL from memory FIRST, then compare against the answer beneath it.
-- The goal is muscle memory, not multiple choice.
-- ============================================================

-- DRILL 1: Write the COPY INTO option that aborts the ENTIRE load the
-- moment ANY row fails (the strictest ON_ERROR setting).
-- --------------------------------------------------------------
-- ON_ERROR = 'ABORT_STATEMENT'


-- DRILL 2: Write the CREATE STAGE syntax pointing at an external S3
-- bucket using a storage integration named S3_INT.
-- --------------------------------------------------------------
-- CREATE STAGE my_stage
--     URL = 's3://my-bucket/path/'
--     STORAGE_INTEGRATION = S3_INT;


-- DRILL 3: Write a query that reads a table AS IT WAS exactly one hour
-- ago, using Time Travel.
-- --------------------------------------------------------------
-- SELECT * FROM my_table AT(OFFSET => -3600);


-- DRILL 4: Write the statement that recovers a table you dropped 10
-- minutes ago (assume default retention, no name collision).
-- --------------------------------------------------------------
-- UNDROP TABLE my_table;


-- DRILL 5: Write a zero-copy clone of an entire SCHEMA (not just one
-- table).
-- --------------------------------------------------------------
-- CREATE SCHEMA my_schema_clone CLONE my_schema;


-- DRILL 6: Write a STANDARD stream on a table named ORDERS.
-- --------------------------------------------------------------
-- CREATE STREAM orders_stream ON TABLE orders;


-- DRILL 7: Write a TASK that runs every 5 minutes, only when
-- orders_stream has data (don't fire on empty runs).
-- --------------------------------------------------------------
-- CREATE TASK process_orders_task
--     WAREHOUSE = my_wh
--     SCHEDULE = '5 MINUTE'
-- WHEN SYSTEM$STREAM_HAS_DATA('orders_stream')
-- AS
--     MERGE INTO ... ;


-- DRILL 8: Write a query that FLATTENs a VARIANT array column named
-- tags in a table named EVENTS.
-- --------------------------------------------------------------
-- SELECT e.event_id, f.value AS tag
-- FROM events e, LATERAL FLATTEN(input => e.tags) f;


-- DRILL 9: Write a masking policy that shows an email column's real
-- value only to the ANALYST role, masking it to '***MASKED***' for
-- everyone else.
-- --------------------------------------------------------------
-- CREATE MASKING POLICY email_mask AS (val STRING) RETURNS STRING ->
--     CASE WHEN CURRENT_ROLE() = 'ANALYST' THEN val
--          ELSE '***MASKED***'
--     END;


-- DRILL 10: Write the ALTER statement attaching a resource monitor
-- named LAB_MONITOR to a warehouse named MY_WH.
-- --------------------------------------------------------------
-- ALTER WAREHOUSE my_wh SET RESOURCE_MONITOR = lab_monitor;


-- DRILL 11: Write a query using QUALIFY to get only the MOST RECENT
-- row per sensor_id from a table with an event_timestamp column.
-- --------------------------------------------------------------
-- SELECT *
-- FROM sensor_readings
-- QUALIFY ROW_NUMBER() OVER (
--     PARTITION BY sensor_id ORDER BY event_timestamp DESC
-- ) = 1;


-- DRILL 12: Write a dynamic table with a 5-minute target lag over a
-- SELECT from a table named RAW_EVENTS.
-- --------------------------------------------------------------
-- CREATE DYNAMIC TABLE summary_dt
--     TARGET_LAG = '5 minutes'
--     WAREHOUSE  = my_wh
-- AS
-- SELECT ... FROM raw_events;


-- DRILL 13: Write the syntax to grant SELECT on ALL FUTURE TABLES in a
-- schema named CURATED to a role named ANALYST.
-- --------------------------------------------------------------
-- GRANT SELECT ON FUTURE TABLES IN SCHEMA curated TO ROLE analyst;


-- DRILL 14: Write a query using TRY_TO_DOUBLE to safely cast a STRING
-- column without erroring on bad values.
-- --------------------------------------------------------------
-- SELECT TRY_TO_DOUBLE(reading_value) FROM sensor_readings_raw;


-- DRILL 15: Write the UNLOAD (COPY INTO <location>) statement writing
-- a table to an internal stage as compressed Parquet, one file only.
-- --------------------------------------------------------------
-- COPY INTO @my_stage/export/
-- FROM my_table
-- FILE_FORMAT = (TYPE = PARQUET)
-- SINGLE = TRUE
-- OVERWRITE = TRUE;

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 129:
--
-- 1. Which of these 15 drills did you get WRONG or blank on without
--    looking? Go back to that drill's referenced task category
--    (loading/unloading, Time Travel, streams/tasks, security,
--    performance) and re-run the real SQL there, not just re-read the
--    answer line.
--
-- 2. Drill 7's WHEN clause and Drill 12's TARGET_LAG both control WHEN
--    work actually happens, but via completely different mechanisms
--    (an explicit stream-has-data check vs. a declarative freshness
--    target). Which one requires YOU to reason about "has anything
--    changed" yourself, and which one delegates that reasoning to
--    Snowflake?
--
-- 3. Under real interview or exam time pressure, which of these 15
--    drills would you expect to take you longest to recall correctly
--    from a blank page, and why -- is it the ones with more clauses to
--    remember (masking policies, tasks), or the ones whose syntax just
--    doesn't come up often in your day-to-day work?
-- ============================================================
