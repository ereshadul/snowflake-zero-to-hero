-- ============================================================
-- Task 34 — PUT/GET/REMOVE file commands
-- IMPORTANT: PUT and GET reference a LOCAL file system on the
-- machine running the client. Snowsight runs in a browser with no
-- local file access, so these commands genuinely CANNOT be run from
-- a Snowsight worksheet at all -- unlike every other task so far,
-- this one requires the SnowSQL CLI (or another client with local
-- file access, like the Python connector).
--
-- Install SnowSQL first if you haven't: search "Snowflake SnowSQL
-- install" for your OS, then connect with:
--   snowsql -a <account_identifier> -u <your_username>
-- Everything below is run inside that SnowSQL session, not Snowsight.
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;

-- 1. PUT — upload a local file onto a stage. Point this at the
--    SAMPLE csv from Task 1 (task-01-upload-csv/iot_sensor_readings_SAMPLE.csv)
--    on your own machine.
PUT file:///absolute/path/to/iot_sensor_readings_SAMPLE.csv @RAW.IOT_STAGE
    AUTO_COMPRESS = TRUE;
-- AUTO_COMPRESS gzips the file during upload -- confirm afterward
-- that what landed on the stage ends in .csv.gz, not plain .csv.

-- 2. Confirm it actually landed.
LIST @RAW.IOT_STAGE;

-- 3. PUT again with OVERWRITE = FALSE (the default) -- re-run the
--    exact same PUT command from step 1 a second time and see what
--    happens.
PUT file:///absolute/path/to/iot_sensor_readings_SAMPLE.csv @RAW.IOT_STAGE
    AUTO_COMPRESS = TRUE;

-- 4. Now with OVERWRITE = TRUE explicitly.
PUT file:///absolute/path/to/iot_sensor_readings_SAMPLE.csv @RAW.IOT_STAGE
    AUTO_COMPRESS = TRUE
    OVERWRITE = TRUE;

-- 5. GET — download a staged file back to your local machine. Point
--    the destination at any local folder you want the file to land in.
GET @RAW.IOT_STAGE/iot_sensor_readings_SAMPLE.csv.gz file:///absolute/path/to/local/download/folder/;

-- 6. REMOVE — delete a file (or a whole prefix) off a stage.
REMOVE @RAW.IOT_STAGE/iot_sensor_readings_SAMPLE.csv.gz;
LIST @RAW.IOT_STAGE;  -- confirm it's actually gone

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 35:
--
-- 1. In step 3, you re-ran the exact same PUT command a second time
--    without OVERWRITE = TRUE. What did SnowSQL actually report —
--    did it silently skip the upload, error, or upload a duplicate?
--    What's the DEFAULT value of OVERWRITE, and why might that
--    default make sense for a client tool meant to be re-run
--    accidentally?
--
-- 2. Why can't PUT and GET be run from a Snowsight worksheet at all,
--    when practically every other SQL statement in this whole repo
--    can be? What's fundamentally different about what these two
--    commands need access to, compared to a normal SELECT or
--    COPY INTO?
--
-- 3. AUTO_COMPRESS = TRUE gzipped your file during the PUT in step 1.
--    If you'd instead uploaded an already-gzipped file (like
--    iot_sensor_readings.csv.gz from Task 1) with AUTO_COMPRESS still
--    set to TRUE, what would happen — would Snowflake double-compress
--    it, detect it's already compressed and skip that step, or error?
--    Worth testing directly if you're not sure.
-- ============================================================
