-- ============================================================
-- Task 100 — Hybrid Tables
-- Category: Newer table types
--
-- NOTE: Hybrid Tables need to be enabled for your account (they're a
-- newer feature, sometimes still gated). If CREATE HYBRID TABLE errors
-- below, that's expected on some trial accounts -- read through the
-- SQL and the understanding check anyway; the concepts still apply.
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;
USE SCHEMA ADVANCED;

-- 1. Every table you've built in this whole lab so far is a standard
--    Snowflake table -- columnar, optimized for scanning millions of
--    rows for analytics. A Hybrid Table is row-oriented instead,
--    built for the opposite job: single-row lookups and updates by
--    key, fast, the way an application's operational database behaves.
CREATE OR REPLACE HYBRID TABLE DEVICE_LOOKUP (
    sensor_id     STRING PRIMARY KEY,
    device_model  STRING,
    install_date  DATE,
    last_seen_at  TIMESTAMP_NTZ
);

INSERT INTO DEVICE_LOOKUP (sensor_id, device_model, install_date, last_seen_at)
VALUES
    ('SENSOR_00001', 'TH-100', '2025-01-15', CURRENT_TIMESTAMP()),
    ('SENSOR_00002', 'TH-100', '2025-01-15', CURRENT_TIMESTAMP()),
    ('SENSOR_00003', 'TH-200', '2025-03-02', CURRENT_TIMESTAMP());

-- 2. This PRIMARY KEY is actually ENFORCED (unlike a standard Snowflake
--    table, where PRIMARY KEY is just documentation). Try to insert a
--    duplicate key and watch it fail.
INSERT INTO DEVICE_LOOKUP (sensor_id, device_model, install_date, last_seen_at)
VALUES ('SENSOR_00001', 'TH-100-DUPLICATE', '2026-01-01', CURRENT_TIMESTAMP());
-- Expected: a uniqueness-violation error, not silently accepted.

-- 3. The point of a Hybrid Table: a fast single-row point lookup by
--    primary key -- the kind of query an application backend fires
--    constantly, as opposed to the big analytical scans the rest of
--    this lab has been doing.
SELECT * FROM DEVICE_LOOKUP WHERE sensor_id = 'SENSOR_00002';

-- 4. Clean up.
DROP TABLE DEVICE_LOOKUP;

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 101:
--
-- 1. Step 2 tried to insert a second row with sensor_id =
--    'SENSOR_00001'. On a STANDARD Snowflake table with the exact same
--    PRIMARY KEY declared, would that insert have been silently
--    accepted or rejected? What does that tell you about the
--    difference between a "documented" constraint and an "enforced"
--    one?
--
-- 2. This whole lab's 50-million-row CURATED.SENSOR_READINGS_SYNTHETIC
--    table is a standard table, great for the big GROUP BY
--    aggregations you've been running against it. Would a Hybrid Table
--    be a good replacement for that table? Why do row-oriented storage
--    and single-key lookups make Hybrid Tables a poor fit for
--    large-scale analytical scans, and a good fit for something like
--    DEVICE_LOOKUP?
--
-- 3. In a real architecture, you might use a Hybrid Table for exactly
--    this kind of reference/lookup data (device metadata, customer
--    records) sitting right next to standard tables holding the bulk
--    event data. What does that let an application do (via a single
--    SQL interface) that it couldn't do cleanly if the lookup data
--    lived in a separate operational database entirely?
-- ============================================================
