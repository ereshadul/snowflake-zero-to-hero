-- ============================================================
-- Task 102 — Iceberg Tables
-- Category: Newer table types
--
-- SCOPE NOTE: A real Iceberg Table needs an EXTERNAL VOLUME pointing
-- at cloud storage (S3/Azure/GCS) plus a catalog. This lab deliberately
-- keeps AWS usage confined to Tasks 5-6, so this task demonstrates the
-- SYNTAX and the underlying concepts as reference material -- read and
-- understand it rather than running the EXTERNAL VOLUME step for real.
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;
USE SCHEMA ADVANCED;

-- 1. REFERENCE ONLY -- every other table in this entire lab has stored
--    its data in Snowflake's own internal, proprietary storage format.
--    An Iceberg Table instead stores data as open Apache Iceberg
--    format files (Parquet + metadata) in storage YOU control, so
--    other engines (Spark, Trino, etc.) can read the exact same data
--    without going through Snowflake at all.
--
-- CREATE EXTERNAL VOLUME my_iceberg_volume
--     STORAGE_LOCATIONS = (
--         (
--             NAME = 'my-s3-location'
--             STORAGE_PROVIDER = 'S3'
--             STORAGE_BASE_URL = 's3://my-bucket/iceberg/'
--             STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::123456789012:role/my-role'
--         )
--     );
--
-- CREATE ICEBERG TABLE SENSOR_READINGS_ICEBERG (
--     sensor_id       STRING,
--     event_timestamp TIMESTAMP_NTZ,
--     value           FLOAT
-- )
--     CATALOG        = 'SNOWFLAKE'
--     EXTERNAL_VOLUME = 'my_iceberg_volume'
--     BASE_LOCATION   = 'sensor_readings/';

-- 2. Snowflake can also act as a Snowflake-managed Iceberg table,
--    where Snowflake itself is both the catalog AND the storage,
--    without you needing to bring your own S3 bucket at all. Whether
--    this is available depends on your account/region, so this step
--    is safe to actually try:
CREATE OR REPLACE ICEBERG TABLE SENSOR_READINGS_ICEBERG_DEMO (
    sensor_id       STRING,
    event_timestamp TIMESTAMP_NTZ,
    value           FLOAT
)
    CATALOG = 'SNOWFLAKE';
-- If this errors on your account/region, that's expected -- read on
-- rather than troubleshooting it; the concepts below still apply.

SHOW ICEBERG TABLES LIKE 'SENSOR_READINGS_ICEBERG_DEMO';

DROP ICEBERG TABLE IF EXISTS SENSOR_READINGS_ICEBERG_DEMO;

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 103:
--
-- 1. Every standard table you've created in this lab (like
--    CURATED.SENSOR_READINGS_SYNTHETIC) stores its data in Snowflake's
--    own proprietary internal format. What's the core difference an
--    Iceberg Table offers instead, in terms of WHO can read the
--    underlying data files and WHERE they physically live?
--
-- 2. Step 1's commented-out example uses your own S3 bucket as an
--    EXTERNAL_VOLUME, while step 2 uses CATALOG = 'SNOWFLAKE' with no
--    external volume at all. What's the practical tradeoff between
--    "bring your own storage, other engines can read it directly" and
--    "let Snowflake manage the storage for you"?
--
-- 3. Think about a company already running Spark or Trino jobs against
--    a data lake, that ALSO wants to use Snowflake for some workloads.
--    Why would Iceberg Tables specifically (versus loading a full copy
--    of the data into standard Snowflake tables) avoid duplicating that
--    data and avoid the two systems silently drifting out of sync with
--    each other?
-- ============================================================
