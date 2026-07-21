-- ============================================================
-- Task 49 — OBJECT data type
-- Category: Semi-structured data
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;
USE SCHEMA ADVANCED;

CREATE OR REPLACE TABLE DEVICE_CONFIG (
    device_id STRING,
    config    OBJECT
);

INSERT INTO DEVICE_CONFIG
SELECT 'D1', OBJECT_CONSTRUCT('sample_rate', 60, 'unit', 'celsius',    'calibrated', TRUE);
INSERT INTO DEVICE_CONFIG
SELECT 'D2', OBJECT_CONSTRUCT('sample_rate', 30, 'unit', 'fahrenheit', 'calibrated', FALSE);

-- 1. Reading fields with : (colon) notation.
SELECT
    device_id,
    config,
    config:sample_rate       AS sample_rate_raw,
    config:unit::STRING      AS unit_text,
    config:calibrated::BOOLEAN AS is_calibrated
FROM DEVICE_CONFIG;

-- 2. Does arithmetic work on a field BEFORE casting it?
SELECT device_id, config:sample_rate + 1 AS plus_one_uncast
FROM DEVICE_CONFIG;

-- 3. Adding a new key with OBJECT_INSERT — doesn't mutate the table,
--    just returns a new object value.
SELECT device_id, OBJECT_INSERT(config, 'firmware', 'v2.0') AS with_firmware
FROM DEVICE_CONFIG
WHERE device_id = 'D1';

-- 4. Re-inserting a key that ALREADY exists.
SELECT OBJECT_INSERT(config, 'unit', 'kelvin') AS attempted_overwrite
FROM DEVICE_CONFIG
WHERE device_id = 'D1';
-- Expect this one to behave differently from step 3 -- read closely.

-- 5. The safe way to overwrite an existing key.
SELECT OBJECT_INSERT(config, 'unit', 'kelvin', TRUE) AS forced_overwrite
FROM DEVICE_CONFIG
WHERE device_id = 'D1';

-- 6. Removing a key, and listing all keys present.
SELECT OBJECT_DELETE(config, 'calibrated') AS without_calibrated
FROM DEVICE_CONFIG
WHERE device_id = 'D1';

SELECT device_id, OBJECT_KEYS(config) AS keys FROM DEVICE_CONFIG;

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 50:
--
-- 1. Step 2 tried arithmetic on config:sample_rate without an
--    explicit cast. Did it work, error, or silently return something
--    unexpected? What does that tell you about the actual data TYPE
--    of a raw `:field` access before you cast it — is it already a
--    NUMBER, or something else entirely until you say ::INT/::NUMBER?
--
-- 2. Compare step 3 (inserting a brand-new key, 'firmware') to step 4
--    (attempting to insert 'unit', which already exists). What
--    actually happened in step 4 — an error, a silent no-op, or
--    something else? What does the extra TRUE argument in step 5
--    change?
--
-- 3. Give one real advantage of storing this config as a single
--    OBJECT column instead of separate sample_rate/unit/calibrated
--    columns, and one real disadvantage. Think about what happens
--    when different devices need genuinely DIFFERENT sets of config
--    keys, versus what you lose in terms of being able to declare a
--    NOT NULL or a specific data type on any individual field.
-- ============================================================
