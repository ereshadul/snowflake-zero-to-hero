-- ============================================================
-- IoT Sensor Telemetry Lab — Setup DDL
-- Sr Snowflake DB Engineer Training
--
-- Run this first. Creates the database, warehouse, file format,
-- stage, and the three tables used across the rest of the lab:
--   RAW.SENSOR_READINGS_RAW        raw landing table (append-only)
--   CURATED.SENSOR_READINGS_HISTORY   cleansed, typed history (append-only)
--   CURATED.SENSOR_CURRENT_STATE      THE transactional table — one row
--                                      per sensor, continuously upserted
-- ============================================================

CREATE DATABASE IF NOT EXISTS IOT_LAB;
CREATE SCHEMA IF NOT EXISTS IOT_LAB.RAW;
CREATE SCHEMA IF NOT EXISTS IOT_LAB.CURATED;

USE DATABASE IOT_LAB;

CREATE WAREHOUSE IF NOT EXISTS IOT_LAB_WH
  WAREHOUSE_SIZE = 'MEDIUM'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE
  INITIALLY_SUSPENDED = TRUE;

USE WAREHOUSE IOT_LAB_WH;

-- ------------------------------------------------------------
-- File format matching the messy CSV export
-- (NULL_IF handles blank fields AND the literal strings 'N/A'/'NULL'
--  that show up in the reading_value column — see the load script
--  for why we still keep reading_value as a raw STRING at landing.)
-- ------------------------------------------------------------
CREATE OR REPLACE FILE FORMAT RAW.IOT_CSV_FORMAT
  TYPE = CSV
  FIELD_DELIMITER = ','
  SKIP_HEADER = 1
  FIELD_OPTIONALLY_ENCLOSED_BY = '"'
  NULL_IF = ('', 'NULL', 'N/A')
  EMPTY_FIELD_AS_NULL = TRUE
  ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE
  TRIM_SPACE = TRUE;

CREATE OR REPLACE STAGE RAW.IOT_STAGE
  FILE_FORMAT = RAW.IOT_CSV_FORMAT;

-- ------------------------------------------------------------
-- Landing table — deliberately loose typing.
-- Loading straight into FLOAT/TIMESTAMP columns will make COPY INTO
-- reject or silently mangle the ~0.6% of rows that are malformed
-- (non-numeric reading_value, garbage timestamp string). Landing as
-- STRING/VARIANT and casting downstream with TRY_TO_* is the safer
-- pattern for messy source data.
-- ------------------------------------------------------------
CREATE OR REPLACE TABLE RAW.SENSOR_READINGS_RAW (
    event_id            STRING,
    sensor_id           STRING,
    device_type         STRING,
    event_timestamp     STRING,
    ingested_at         STRING,
    reading_value       STRING,
    unit                STRING,
    battery_pct         STRING,
    signal_strength_dbm STRING,
    latitude            STRING,
    longitude           STRING,
    firmware_version    STRING,
    status_code         STRING,
    raw_payload         VARIANT,
    is_duplicate_of     STRING,
    ingest_batch_id     STRING,
    _file_name          STRING DEFAULT NULL,
    _loaded_at          TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ------------------------------------------------------------
-- Cleansed, typed, append-only history — every reading ever seen,
-- properly typed and deduplicated. Clustered for time-series queries.
-- ------------------------------------------------------------
CREATE OR REPLACE TABLE CURATED.SENSOR_READINGS_HISTORY (
    event_id            STRING,
    sensor_id           STRING,
    device_type         STRING,
    event_timestamp     TIMESTAMP_NTZ,
    ingested_at         TIMESTAMP_NTZ,
    reading_value       FLOAT,
    unit                STRING,
    battery_pct         NUMBER(5,2),
    signal_strength_dbm NUMBER(5,1),
    latitude            FLOAT,
    longitude           FLOAT,
    firmware_version    STRING,
    status_code         STRING,
    raw_payload         VARIANT,
    processed_at        TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
)
CLUSTER BY (sensor_id, event_timestamp);

-- ------------------------------------------------------------
-- THE transactional table: one row per sensor, continuously
-- upserted by later tasks. This is the table that makes later
-- exercises "difficult" — concurrent/repeated writes against it.
--
-- Note: PRIMARY KEY is declared for documentation/optimizer hints
-- only. Snowflake does NOT enforce PK/UNIQUE/FK constraints by
-- default — duplicate sensor_ids are a real possibility your
-- application logic has to defend against, not something the
-- table will stop for you.
-- ------------------------------------------------------------
CREATE OR REPLACE TABLE CURATED.SENSOR_CURRENT_STATE (
    sensor_id             STRING PRIMARY KEY,
    device_type           STRING,
    last_event_timestamp  TIMESTAMP_NTZ,
    last_ingested_at      TIMESTAMP_NTZ,
    last_reading_value    FLOAT,
    unit                  STRING,
    battery_pct           NUMBER(5,2),
    signal_strength_dbm   NUMBER(5,1),
    latitude              FLOAT,
    longitude             FLOAT,
    firmware_version      STRING,
    status_code           STRING,
    update_count          NUMBER DEFAULT 1,
    last_updated_at       TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);
