-- ============================================================
-- Task 111 — dbt seeds
-- Category: dbt
-- Seeds are for small, mostly-static REFERENCE data that belongs in
-- version control right alongside your models -- not for loading
-- real event volume (that's COPY INTO / Snowpipe's job, Tasks 38-68).
-- ============================================================

-- 1. A small lookup table: a human-readable label and expected
--    battery life per device model. Save as
--    iot_lab_dbt/seeds/device_model_lookup.csv:
--
-- device_type,display_name,expected_battery_days
-- TH-100,Basic Temp/Humidity Sensor,180
-- TH-200,Temp/Humidity + GPS Sensor,90
-- PRESSURE-50,Pressure Sensor,365

-- 2. Load it into Snowflake as a real table.
--
--    dbt seed
--    -- This runs a straightforward INSERT/COPY of the CSV's rows into
--    -- a table named after the file: DEVICE_MODEL_LOOKUP.

-- 3. Verify in Snowflake -- real SQL, run in a worksheet:
USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;
SELECT * FROM DBT_DEV.DEVICE_MODEL_LOOKUP;

-- 4. Use the seed like any other model -- reference it with ref(),
--    exactly the same syntax as referencing stg_sensor_readings.
--    Save as iot_lab_dbt/models/marts/dim_device_model.sql:
--
-- SELECT
--     s.device_type,
--     l.display_name,
--     l.expected_battery_days,
--     COUNT(DISTINCT s.sensor_id) AS sensor_count
-- FROM {{ ref('stg_sensor_readings') }} s
-- LEFT JOIN {{ ref('device_model_lookup') }} l
--     ON s.device_type = l.device_type
-- GROUP BY s.device_type, l.display_name, l.expected_battery_days

-- 5. Run it and verify -- real SQL, run in a worksheet:
--
--    dbt run --select dim_device_model
SELECT * FROM DBT_DEV.DIM_DEVICE_MODEL;

-- 6. Update the lookup data itself (edit the CSV, e.g. change
--    TH-100's expected_battery_days to 200) and re-seed:
--
--    dbt seed --select device_model_lookup
--    -- By default this is a full CREATE OR REPLACE of the seed table,
--    -- not an incremental append -- the whole point is that seeds are
--    -- small enough this is cheap.

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 112:
--
-- 1. Step 4's dim_device_model.sql references device_model_lookup
--    using {{ ref('device_model_lookup') }} -- the EXACT SAME function
--    used for referencing regular models like stg_sensor_readings. Is
--    a seed a genuinely different kind of dbt object under the hood,
--    or does dbt treat "a model built from a CSV" and "a model built
--    from a SELECT" as the same kind of DAG node once they're loaded?
--
-- 2. Step 6 re-runs dbt seed as a full replace, not an incremental
--    load. Given seeds are meant for SMALL reference data (a handful
--    to a few thousand rows, like this 3-row device lookup), why is a
--    full CREATE OR REPLACE an entirely reasonable default here, when
--    the exact same approach would be a bad idea for the 50-million-row
--    CURATED.SENSOR_READINGS_SYNTHETIC table?
--
-- 3. Seeds live in the dbt project's seeds/ folder and get committed
--    to git alongside your models. What kind of data would you be
--    tempted to load as a seed that you actually SHOULDN'T (hint:
--    think about data that changes often, or data with real event
--    volume) -- and which loading mechanism from earlier in this lab
--    (Tasks 38-68) should that kind of data use instead?
-- ============================================================
