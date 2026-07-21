-- ============================================================
-- Task 101 — Event Tables
-- Category: Newer table types
-- Needs ACCOUNTADMIN to wire an event table up to the account.
-- ============================================================

USE ROLE ACCOUNTADMIN;
USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;
USE SCHEMA ADVANCED;

-- 1. An Event Table is a special table type with a FIXED schema
--    (TIMESTAMP, RESOURCE_ATTRIBUTES, RECORD, VALUE, etc.) built to
--    capture structured logs, traces, and metrics emitted by handler
--    code running inside procedures and functions.
CREATE EVENT TABLE IF NOT EXISTS APP_EVENTS;

-- 2. Tell the account: "this is where log/trace output should land."
--    Only one event table can be active per account at a time.
ALTER ACCOUNT SET EVENT_TABLE = IOT_LAB.ADVANCED.APP_EVENTS;

-- 3. A stored procedure that deliberately emits log messages at
--    different severities using SYSTEM$LOG -- this is what actually
--    populates the event table, the SQL equivalent of a Python
--    handler calling logger.info(...) / logger.error(...).
CREATE OR REPLACE PROCEDURE PROCESS_SENSOR_BATCH(batch_size INT)
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
    CALL SYSTEM$LOG_INFO('PROCESS_SENSOR_BATCH started, batch_size=' || :batch_size);
    IF (:batch_size > 10000) THEN
        CALL SYSTEM$LOG_WARN('batch_size unusually large: ' || :batch_size);
    END IF;
    CALL SYSTEM$LOG_INFO('PROCESS_SENSOR_BATCH completed successfully');
    RETURN 'processed ' || :batch_size || ' rows';
END;
$$;

CALL PROCESS_SENSOR_BATCH(500);
CALL PROCESS_SENSOR_BATCH(50000);

-- 4. Give it a minute or two -- event delivery is asynchronous, not
--    instant -- then query the event table like any other table.
SELECT
    timestamp,
    record:severity_text::STRING AS severity,
    value::STRING                AS message
FROM APP_EVENTS
ORDER BY timestamp DESC
LIMIT 20;

-- 5. Clean up -- detach and drop, so this doesn't keep capturing
--    events from everything else you run for the rest of the lab.
ALTER ACCOUNT UNSET EVENT_TABLE;
DROP EVENT TABLE APP_EVENTS;

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 102:
--
-- 1. Step 4's query may return zero rows the FIRST time you run it,
--    even though step 3's CALLs already completed. What does that tell
--    you about how event delivery works -- is it synchronous (the log
--    line lands the instant SYSTEM$LOG_INFO runs) or does it flow
--    through an asynchronous pipeline with some delay?
--
-- 2. Only ONE event table can be active per account at a time (step
--    2's ALTER ACCOUNT SET EVENT_TABLE). If a different team in the
--    same account later runs their own ALTER ACCOUNT SET EVENT_TABLE
--    pointing at a DIFFERENT table, what happens to logging from code
--    that's already deployed and running?
--
-- 3. PROCESS_SENSOR_BATCH logged both an INFO message and, for the
--    50000-row call, a WARN message. In a real incident, what would
--    querying APP_EVENTS by severity and time range let an engineer
--    do that grepping through scattered application logs across
--    multiple systems wouldn't -- specifically, what's the benefit of
--    having procedure/function logs sitting in the SAME queryable SQL
--    surface as your actual data?
-- ============================================================
