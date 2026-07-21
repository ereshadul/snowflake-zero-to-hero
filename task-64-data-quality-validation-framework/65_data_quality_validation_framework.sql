-- ============================================================
-- Task 64 — A repeatable data quality/validation framework
-- Category: Data Integrity & Quality
-- Ties together Task 1's post-load sanity checks, Task 61's
-- procedural control flow, and Task 62's alerting into ONE reusable
-- pattern, instead of ad hoc one-off queries every time.
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;
USE SCHEMA ADVANCED;

-- 1. A log table -- every check run gets recorded here, not just
--    printed once and forgotten.
CREATE OR REPLACE TABLE DQ_RESULTS (
    check_name       STRING,
    table_name       STRING,
    passed           BOOLEAN,
    failed_row_count INT,
    checked_at       TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- 2. A procedure that runs several checks in sequence, logs each
--    result, and reports an overall pass/fail.
CREATE OR REPLACE PROCEDURE RUN_DATA_QUALITY_CHECKS()
RETURNS STRING
LANGUAGE SQL
AS
$$
DECLARE
    bad_reading_count   INT;
    bad_timestamp_count INT;
    any_failures        BOOLEAN DEFAULT FALSE;
BEGIN
    -- Check 1: numeric reading_value (same logic as Task 1's sanity check)
    SELECT COUNT(*) INTO :bad_reading_count
    FROM RAW.SENSOR_READINGS_RAW
    WHERE TRY_TO_DOUBLE(reading_value) IS NULL AND reading_value IS NOT NULL;

    INSERT INTO DQ_RESULTS (check_name, table_name, passed, failed_row_count)
    VALUES ('numeric_reading_value_check', 'RAW.SENSOR_READINGS_RAW',
            :bad_reading_count = 0, :bad_reading_count);

    IF (:bad_reading_count > 0) THEN
        any_failures := TRUE;
    END IF;

    -- Check 2: valid timestamp (same logic as Task 1's sanity check)
    SELECT COUNT(*) INTO :bad_timestamp_count
    FROM RAW.SENSOR_READINGS_RAW
    WHERE TRY_TO_TIMESTAMP_NTZ(event_timestamp) IS NULL;

    INSERT INTO DQ_RESULTS (check_name, table_name, passed, failed_row_count)
    VALUES ('valid_timestamp_check', 'RAW.SENSOR_READINGS_RAW',
            :bad_timestamp_count = 0, :bad_timestamp_count);

    IF (:bad_timestamp_count > 0) THEN
        any_failures := TRUE;
    END IF;

    IF (:any_failures) THEN
        RETURN 'FAILED: one or more checks found bad rows -- see DQ_RESULTS';
    ELSE
        RETURN 'PASSED: all checks clean';
    END IF;
END;
$$;

CALL RUN_DATA_QUALITY_CHECKS();
SELECT * FROM DQ_RESULTS ORDER BY checked_at DESC;

-- ============================================================
-- UNDERSTANDING CHECK — before moving to Task 65 (this closes out
-- the Data Integrity & Quality category):
--
-- 1. Given Task 1's data is known to have deliberately malformed
--    rows, does CALL RUN_DATA_QUALITY_CHECKS() report PASSED or
--    FAILED? Query DQ_RESULTS and confirm the failed_row_count for
--    each individual check matches what you'd expect from Task 1's
--    original sanity-check numbers.
--
-- 2. DQ_RESULTS logs every run, not just the latest one. Run
--    CALL RUN_DATA_QUALITY_CHECKS() a second time and query
--    DQ_RESULTS again. What's the practical value of keeping this
--    history over time, instead of only ever seeing the most recent
--    outcome?
--
-- 3. Combine this with Task 62: what single change to
--    RUN_DATA_QUALITY_CHECKS would make it actually EMAIL someone
--    the moment any_failures becomes TRUE, instead of just returning
--    a string nobody's watching? And combining with the Tasks
--    category (Task 3, 77-82): how would you make this run
--    automatically every night instead of by hand?
-- ============================================================
