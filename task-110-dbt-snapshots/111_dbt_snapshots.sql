-- ============================================================
-- Task 110 — dbt snapshots (SCD Type 2)
-- Category: dbt
-- CURATED.SENSOR_CURRENT_STATE (Task 1) is THE mutable table in this
-- whole lab -- one row per sensor, continuously overwritten in place.
-- Once a row is updated, its PREVIOUS value is just gone. A snapshot
-- is dbt's built-in way to capture that history BEFORE it's lost.
-- ============================================================

-- 1. Declare a snapshot. Save as
--    iot_lab_dbt/snapshots/snap_sensor_current_state.sql:
--
-- {% snapshot snap_sensor_current_state %}
--
-- {{
--     config(
--         target_schema='DBT_SNAPSHOTS',
--         unique_key='sensor_id',
--         strategy='timestamp',
--         updated_at='last_updated_at',
--     )
-- }}
--
-- SELECT * FROM {{ source('iot_curated', 'sensor_current_state') }}
--
-- {% endsnapshot %}
--
--    This needs a source declaration too -- add to
--    iot_lab_dbt/models/staging/_sources.yml:
--
--   - name: iot_curated
--     database: IOT_LAB
--     schema: CURATED
--     tables:
--       - name: sensor_current_state

-- 2. First snapshot run: every current row gets inserted with
--    dbt_valid_from = now, dbt_valid_to = NULL (still "current").
--
--    dbt snapshot

-- 3. Verify in Snowflake -- real SQL, run in a worksheet:
USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;
SELECT sensor_id, last_reading_value, dbt_valid_from, dbt_valid_to
FROM DBT_SNAPSHOTS.SNAP_SENSOR_CURRENT_STATE
ORDER BY sensor_id;

-- 4. Change the source data -- update a row the way any normal
--    application write to SENSOR_CURRENT_STATE would (this table gets
--    upserted constantly across this lab, e.g. by Task 82's tasks):
UPDATE CURATED.SENSOR_CURRENT_STATE
SET last_reading_value = last_reading_value + 100,
    last_updated_at    = CURRENT_TIMESTAMP()
WHERE sensor_id = (SELECT MIN(sensor_id) FROM CURATED.SENSOR_CURRENT_STATE);

-- 5. Snapshot again. This is the key moment: dbt does NOT overwrite
--    the old row -- it closes out the old version (sets dbt_valid_to)
--    and inserts a NEW row for the current value.
--
--    dbt snapshot

-- 6. Verify the Type 2 history -- real SQL, run in a worksheet. You
--    should now see TWO rows for the sensor you updated: one CLOSED
--    (dbt_valid_to populated) and one CURRENT (dbt_valid_to NULL).
SELECT sensor_id, last_reading_value, dbt_valid_from, dbt_valid_to
FROM DBT_SNAPSHOTS.SNAP_SENSOR_CURRENT_STATE
WHERE sensor_id = (SELECT MIN(sensor_id) FROM CURATED.SENSOR_CURRENT_STATE)
ORDER BY dbt_valid_from;

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 111:
--
-- 1. Step 4 updated CURATED.SENSOR_CURRENT_STATE in place -- the OLD
--    value is now genuinely gone from that table (it only ever holds
--    ONE row per sensor). Where does the old value still exist after
--    step 5's snapshot run? Without the snapshot, would you have any
--    way at all to answer "what was this sensor's reading BEFORE the
--    update"?
--
-- 2. Step 1 used strategy='timestamp' with updated_at='last_updated_at'.
--    dbt also supports strategy='check', which compares actual column
--    VALUES instead of trusting a timestamp column. What could go
--    wrong with the timestamp strategy specifically if an upstream
--    process updated a row's data but forgot to bump last_updated_at?
--
-- 3. Time Travel (Tasks 83-87) can also answer "what did this row look
--    like before?", using Snowflake's own retained history, for a
--    LIMITED retention window. How is a dbt snapshot's history
--    fundamentally different from Time Travel's -- specifically, does
--    a snapshot's retained history expire after a configured number of
--    days the way Time Travel's DATA_RETENTION_TIME_IN_DAYS does, and
--    who is responsible for the underlying storage cost of that
--    history in each case?
-- ============================================================
