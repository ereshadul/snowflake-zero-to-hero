-- ============================================================
-- Task 116 — Data Vault modeling
-- Category: Ecosystem & Modeling
-- Task 115 built a star schema over this same sensor domain. This
-- task models it a completely different way: Hubs, Links, and
-- Satellites, designed for a source system that keeps changing shape.
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;
USE SCHEMA ADVANCED;

-- 1. A HUB -- just the business key, nothing else. One row per
--    distinct sensor, ever seen, forever. Hubs almost never change
--    once a key exists.
CREATE OR REPLACE TABLE HUB_SENSOR AS
SELECT
    sensor_id                                    AS sensor_hub_key,
    sensor_id,
    MIN(event_timestamp)                         AS load_date,
    'SENSOR_READINGS_HISTORY'                     AS record_source
FROM CURATED.SENSOR_READINGS_HISTORY
GROUP BY sensor_id;

-- 2. A second HUB -- device types are their own business concept too.
CREATE OR REPLACE TABLE HUB_DEVICE_TYPE AS
SELECT
    device_type                                  AS device_type_hub_key,
    device_type,
    MIN(event_timestamp)                         AS load_date,
    'SENSOR_READINGS_HISTORY'                     AS record_source
FROM CURATED.SENSOR_READINGS_HISTORY
GROUP BY device_type;

-- 3. A LINK -- records that a sensor and a device type are related,
--    nothing descriptive about EITHER of them, just the relationship
--    itself. This is what makes Data Vault flexible: relationships are
--    their OWN objects, not baked into a hub or satellite.
CREATE OR REPLACE TABLE LINK_SENSOR_DEVICE_TYPE AS
SELECT DISTINCT
    sensor_id || '|' || device_type              AS link_key,
    sensor_id                                    AS sensor_hub_key,
    device_type                                  AS device_type_hub_key,
    MIN(event_timestamp) OVER (PARTITION BY sensor_id, device_type) AS load_date,
    'SENSOR_READINGS_HISTORY'                     AS record_source
FROM CURATED.SENSOR_READINGS_HISTORY;

-- 4. A SATELLITE -- the descriptive, CHANGING attributes about a hub,
--    stored WITH a timestamp so history is naturally preserved (this
--    is Data Vault's own built-in answer to the same "track changes
--    over time" problem Task 110's dbt snapshots solved differently).
CREATE OR REPLACE TABLE SAT_SENSOR_READING AS
SELECT
    sensor_id                                    AS sensor_hub_key,
    event_timestamp                              AS load_date,
    reading_value,
    battery_pct,
    signal_strength_dbm,
    status_code,
    'SENSOR_READINGS_HISTORY'                     AS record_source
FROM CURATED.SENSOR_READINGS_HISTORY;

-- 5. Reconstruct a business question by joining back through the
--    model -- Hub to Link to Hub to Satellite. More joins than the
--    star schema needed for the same underlying question.
SELECT
    hs.sensor_id,
    hd.device_type,
    AVG(sr.reading_value) AS avg_reading_value
FROM HUB_SENSOR hs
JOIN LINK_SENSOR_DEVICE_TYPE l ON hs.sensor_hub_key = l.sensor_hub_key
JOIN HUB_DEVICE_TYPE hd        ON l.device_type_hub_key = hd.device_type_hub_key
JOIN SAT_SENSOR_READING sr     ON hs.sensor_hub_key = sr.sensor_hub_key
GROUP BY hs.sensor_id, hd.device_type
ORDER BY hs.sensor_id
LIMIT 20;

-- 6. Clean up.
DROP TABLE SAT_SENSOR_READING;
DROP TABLE LINK_SENSOR_DEVICE_TYPE;
DROP TABLE HUB_DEVICE_TYPE;
DROP TABLE HUB_SENSOR;

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 117:
--
-- 1. Step 3's LINK_SENSOR_DEVICE_TYPE stores ONLY the relationship
--    between a sensor and a device type -- no descriptive attributes
--    at all. If tomorrow a brand-new relationship type appeared (say,
--    sensor-to-maintenance-technician), would you need to ALTER any
--    existing Hub or Satellite table to add it, or would you add a
--    completely new, independent Link table? Compare that to Task
--    115's star schema -- would adding a new relationship type there
--    have been that clean?
--
-- 2. SAT_SENSOR_READING stores load_date alongside every descriptive
--    attribute, so history is preserved by DESIGN, just by inserting
--    new satellite rows over time rather than updating in place. How
--    does this compare to Task 110's dbt snapshot approach (dbt_valid_
--    from/dbt_valid_to columns bolted onto an existing table) for
--    achieving the same "don't lose history" goal?
--
-- 3. Step 5's query needed FOUR joins (Hub, Link, Hub, Satellite) to
--    answer the same "average reading by sensor and device type"
--    question that Task 115's star schema answered with two joins
--    against a skinny fact table. Given Data Vault is clearly MORE
--    joins for the same analytical question, why would a data
--    engineering team choose it anyway for a fast-changing source
--    system -- what are they optimizing for instead of query
--    simplicity?
-- ============================================================
