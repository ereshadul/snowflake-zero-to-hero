-- ============================================================
-- Task 2 — Generate huge data directly inside Snowflake
-- No file upload, no external cloud. Uses GENERATOR() + SEQ4()
-- to synthesize rows entirely with SQL, at whatever volume you want.
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;

CREATE OR REPLACE TABLE CURATED.SENSOR_READINGS_SYNTHETIC AS
SELECT
    UUID_STRING()                                                     AS event_id,
    'SENSOR_' || LPAD(MOD(SEQ4(), 5000)::STRING, 5, '0')              AS sensor_id,
    ARRAY_CONSTRUCT('temperature','humidity','pressure','motion','gps','vibration')
        [MOD(SEQ4(), 6)]::STRING                                       AS device_type,
    DATEADD(SECOND, UNIFORM(0, 3888000, RANDOM()), '2026-06-01'::TIMESTAMP_NTZ) AS event_timestamp,
    ROUND(UNIFORM(-40, 150, RANDOM())::FLOAT, 3)                       AS reading_value,
    UNIFORM(0, 100, RANDOM())                                          AS battery_pct,
    ROUND(UNIFORM(-110, -30, RANDOM())::FLOAT, 1)                      AS signal_strength_dbm,
    OBJECT_CONSTRUCT(
        'calibration_offset', ROUND(UNIFORM(-2, 2, RANDOM())::FLOAT, 3),
        'alerts', ARRAY_CONSTRUCT_COMPACT(
            IFF(UNIFORM(0, 100, RANDOM()) < 5, 'LOW_BATTERY', NULL),
            IFF(UNIFORM(0, 100, RANDOM()) < 2, 'SIGNAL_LOSS', NULL)
        )
    )                                                                  AS raw_payload
FROM TABLE(GENERATOR(ROWCOUNT => 5000000));  -- 5M rows in one shot

-- Sanity checks
SELECT COUNT(*) AS row_count FROM CURATED.SENSOR_READINGS_SYNTHETIC;
SELECT device_type, COUNT(*) FROM CURATED.SENSOR_READINGS_SYNTHETIC GROUP BY 1;

-- Going bigger: cross-joining two GENERATOR calls multiplies row count,
-- but naively doing this repeats the SAME sequence of SEQ4() values on
-- both sides, which correlates columns that use SEQ4() in a way you
-- don't want. Compare the row diversity here to the single-generator
-- version above before you use this pattern for anything real:
--
-- SELECT ...
-- FROM TABLE(GENERATOR(ROWCOUNT => 1000000)) a,
--      TABLE(GENERATOR(ROWCOUNT => 20)) b;   -- "20M rows"

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 3:
--
-- 1. What does SEQ4() actually return, row by row? Run
--    `SELECT SEQ4() FROM TABLE(GENERATOR(ROWCOUNT => 10));` and look.
--    Why does MOD(SEQ4(), 5000) give you a repeatable spread across
--    5000 sensor IDs instead of random ones?
--
-- 2. The cross-join trick above ("going bigger") is a common copy-paste
--    pattern online for generating more rows. Run it with a small
--    ROWCOUNT on each side and inspect sensor_id/device_type together
--    across the result. What goes wrong, and why does it happen?
--
-- 3. This CREATE TABLE AS SELECT ran on IOT_LAB_WH sized MEDIUM.
--    What would you check in the query profile to decide whether
--    MEDIUM was the right size, versus SMALL or LARGE?
-- ============================================================
