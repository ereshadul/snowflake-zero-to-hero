-- ============================================================
-- Task 48 — Transforming data mid-COPY
-- Category: Loading & COPY options
--
-- Task 1 already used a SELECT inside COPY INTO, but only to
-- reorder/pass columns straight through plus one JSON parse. This
-- task goes further: real transformation logic (rounding, date
-- extraction, normalization, concatenation) happening AS the data
-- loads. Uses Task 1's iot_sensor_readings_SAMPLE.csv (fixture_clean
-- was purged in Task 46).
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;
USE SCHEMA ADVANCED;

CREATE OR REPLACE TABLE TRANSFORM_DEMO (
    event_id              STRING,
    event_date            DATE,
    reading_value_rounded NUMBER(10, 1),
    status_normalized     STRING,
    sensor_summary        STRING
);

COPY INTO TRANSFORM_DEMO (
    event_id, event_date, reading_value_rounded, status_normalized, sensor_summary
)
FROM (
    SELECT
        $1,                                    -- event_id, passed through
        TRY_TO_DATE($4),                       -- event_timestamp -> just the DATE part
        ROUND(TRY_TO_DOUBLE($6), 1),           -- reading_value -> cast + rounded in one step
        UPPER($13),                            -- status_code -> normalized to uppercase
        $2 || ' (' || $3 || ')'                -- sensor_id + device_type -> one combined label
    FROM @RAW.IOT_STAGE/iot_sensor_readings_SAMPLE.csv
)
FILE_FORMAT = (FORMAT_NAME = RAW.IOT_CSV_FORMAT)
ON_ERROR = 'CONTINUE';

SELECT * FROM TRANSFORM_DEMO LIMIT 10;

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 49:
--
-- 1. Compare this COPY INTO to Task 1's -- that one selected
--    $1 through $16 essentially straight through (plus one
--    TRY_PARSE_JSON). This one rounds, extracts a date, uppercases,
--    and concatenates. Could you have achieved the exact same final
--    result with a plain, untransformed COPY INTO followed by a
--    separate `INSERT INTO ... SELECT` doing the transformation
--    afterward? What's the actual tradeoff between doing it inline
--    during the COPY vs. as a second step?
--
-- 2. TRY_TO_DOUBLE is used instead of a plain CAST/`::FLOAT` for
--    reading_value_rounded, even though this specific file
--    (iot_sensor_readings_SAMPLE.csv) is clean. Why use the TRY_
--    version defensively here anyway? What would a plain `::FLOAT`
--    cast have done differently if this file had contained one of the
--    "ERR" values from Task 38's fixture_mixed.csv instead?
--
-- 3. Name something you genuinely CANNOT do inside a COPY INTO's
--    transformation SELECT that you COULD do in a separate
--    post-load transformation step — think about anything that needs
--    to look at MORE than just the current row being parsed (e.g.
--    comparing to other rows, joining to an existing table, a window
--    function).
-- ============================================================
