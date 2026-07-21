-- ============================================================
-- Task 104 — dbt sources and staging models
-- Category: dbt
-- ============================================================

-- 1. RAW.SENSOR_READINGS_RAW (from Task 1's setup DDL) is a table
--    dbt didn't create -- it's raw data landed by COPY INTO, outside
--    dbt's control. Declaring it as a SOURCE (instead of just typing
--    the table name into a FROM clause) lets dbt track it as a graph
--    node, document it, and test it. Save as
--    iot_lab_dbt/models/staging/_sources.yml:
--
-- version: 2
--
-- sources:
--   - name: iot_raw
--     database: IOT_LAB
--     schema: RAW
--     tables:
--       - name: sensor_readings_raw
--         description: >
--           Raw landed sensor telemetry, loose STRING typing on
--           purpose -- see Task 1. Loaded by COPY INTO, not by dbt.
--         loaded_at_field: _loaded_at
--         freshness:
--           warn_after: {count: 24, period: hour}
--           error_after: {count: 48, period: hour}

-- 2. A STAGING model: one model per source table, doing ONLY light
--    renaming/casting -- no business logic, no joins, no aggregation.
--    This is the convention, not a technical requirement, and it pays
--    off the moment more than one downstream model needs this same
--    source. Save as
--    iot_lab_dbt/models/staging/stg_sensor_readings.sql:
--
-- SELECT
--     event_id,
--     sensor_id,
--     device_type,
--     TRY_TO_TIMESTAMP_NTZ(event_timestamp) AS event_timestamp,
--     TRY_TO_TIMESTAMP_NTZ(ingested_at)     AS ingested_at,
--     TRY_TO_DOUBLE(reading_value)          AS reading_value,
--     unit,
--     TRY_TO_DECIMAL(battery_pct, 5, 2)     AS battery_pct,
--     status_code
-- FROM {{ source('iot_raw', 'sensor_readings_raw') }}
-- WHERE TRY_TO_DOUBLE(reading_value) IS NOT NULL

-- 3. Run just this one model and its source freshness check.
--
--    dbt run --select stg_sensor_readings
--    dbt source freshness

-- 4. Verify in Snowflake -- real SQL, run in a worksheet:
USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;
SELECT COUNT(*) AS staged_row_count FROM DBT_DEV.STG_SENSOR_READINGS;
SELECT * FROM DBT_DEV.STG_SENSOR_READINGS LIMIT 20;

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 105:
--
-- 1. Step 2's staging model casts reading_value from STRING to DOUBLE
--    using TRY_TO_DOUBLE and filters out rows where that cast fails.
--    Task 1's landing table deliberately kept everything as STRING
--    because ~0.6% of rows are malformed. What would happen to a
--    downstream model if it queried RAW.SENSOR_READINGS_RAW directly
--    and tried to do math on reading_value, INSTEAD of building on top
--    of stg_sensor_readings?
--
-- 2. {{ source('iot_raw', 'sensor_readings_raw') }} compiles down to
--    the literal table reference IOT_LAB.RAW.SENSOR_READINGS_RAW. If
--    that raw table later gets renamed or moved to a different schema,
--    what's the ONE place you'd need to update -- the _sources.yml
--    file, or every model that references this source?
--
-- 3. The staging-layer convention says stg_sensor_readings should do
--    ONLY renaming/casting/filtering-out-garbage -- no joins, no
--    business logic, no aggregation. If you're tempted to add a JOIN
--    to another table inside this staging model, what layer of the
--    DAG (hint: see Task 105) should that logic actually live in
--    instead, and why does keeping staging models "dumb" make the rest
--    of the project easier to reason about?
-- ============================================================
