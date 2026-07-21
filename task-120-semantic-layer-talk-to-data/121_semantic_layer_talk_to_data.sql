-- ============================================================
-- Task 120 — Semantic layer & "Talk to Data"
-- Category: Ecosystem & Modeling
-- This closes out the Ecosystem & Modeling group (114-120). Cortex
-- Analyst answers natural-language questions over YOUR tables -- but
-- only once you've told it, explicitly, what your tables/columns MEAN
-- in business terms. That explicit mapping is the semantic model.
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;
USE SCHEMA ADVANCED;

-- 1. Rebuild a small, stable version of Task 115's star schema --
--    Cortex Analyst needs real tables/views to point at, not a
--    one-off ad hoc query.
CREATE OR REPLACE TABLE DIM_SENSOR AS
SELECT DISTINCT sensor_id, device_type, firmware_version
FROM CURATED.SENSOR_READINGS_HISTORY;

CREATE OR REPLACE TABLE FCT_SENSOR_READINGS AS
SELECT
    event_id,
    sensor_id,
    DATE(event_timestamp) AS reading_date,
    reading_value,
    battery_pct
FROM CURATED.SENSOR_READINGS_HISTORY;

-- 2. A SEMANTIC MODEL is a YAML file describing tables, columns, and
--    business-friendly synonyms/descriptions -- this is what actually
--    lets Cortex Analyst translate "average battery by device type"
--    into a real JOIN + GROUP BY over YOUR schema. Save as
--    semantic_models/sensor_fleet.yaml (uploaded to a Snowflake stage
--    that Cortex Analyst reads from):
--
-- name: sensor_fleet
-- tables:
--   - name: fct_sensor_readings
--     base_table:
--       database: IOT_LAB
--       schema: ADVANCED
--       table: FCT_SENSOR_READINGS
--     dimensions:
--       - name: sensor_id
--         expr: sensor_id
--       - name: reading_date
--         expr: reading_date
--     measures:
--       - name: avg_reading_value
--         expr: reading_value
--         default_aggregation: avg
--       - name: avg_battery_pct
--         expr: battery_pct
--         default_aggregation: avg
--   - name: dim_sensor
--     base_table:
--       database: IOT_LAB
--       schema: ADVANCED
--       table: DIM_SENSOR
--     dimensions:
--       - name: sensor_id
--         expr: sensor_id
--       - name: device_type
--         expr: device_type
--         synonyms: ["device model", "sensor model"]
-- relationships:
--   - name: readings_to_sensor
--     left_table: fct_sensor_readings
--     right_table: dim_sensor
--     relationship_columns:
--       - left_column: sensor_id
--         right_column: sensor_id

-- 3. Upload semantic_models/sensor_fleet.yaml to a stage, then point
--    Cortex Analyst at it (via Snowsight's "Cortex Analyst" UI, or the
--    REST API) and ask a genuinely natural-language question:
--
--    "What's the average battery percentage by device type?"
--
--    Cortex Analyst should generate SQL roughly equivalent to:
SELECT
    ds.device_type,
    AVG(f.battery_pct) AS avg_battery_pct
FROM FCT_SENSOR_READINGS f
JOIN DIM_SENSOR ds ON f.sensor_id = ds.sensor_id
GROUP BY ds.device_type;

-- 4. Ask a question using the synonym you defined in step 2 instead of
--    the real column name -- confirm it still resolves correctly:
--
--    "Break down average reading value by sensor model."
--    -- "sensor model" should resolve to device_type via the synonym.

-- 5. Clean up.
DROP TABLE FCT_SENSOR_READINGS;
DROP TABLE DIM_SENSOR;

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 121:
--
-- 1. Step 3's natural-language question got translated into the exact
--    JOIN + GROUP BY you'd have written by hand in Task 115. What
--    information did Cortex Analyst actually need from step 2's YAML
--    to know HOW fct_sensor_readings and dim_sensor relate to each
--    other -- would it have been able to guess that join correctly
--    with NO semantic model at all, given only raw table/column names?
--
-- 2. Step 4's synonym ("sensor model" -> device_type) is declared
--    explicitly in the YAML. If a business user asked about "device
--    category" instead, a term you never listed as a synonym, would
--    you expect Cortex Analyst to resolve it correctly? What does that
--    tell you about how much of this feature's quality depends on the
--    semantic model being genuinely well-written, versus the LLM's own
--    general capability?
--
-- 3. Task 115's star schema was designed for a data engineer writing
--    SQL. This semantic model sits ON TOP of the exact same fact/
--    dimension tables, but for a completely different audience. Who is
--    the semantic model actually FOR, and why did modeling the data as
--    a clean star schema in Task 115 make building this semantic layer
--    dramatically easier than it would have been directly on top of
--    Task 116's Data Vault Hubs/Links/Satellites?
-- ============================================================
