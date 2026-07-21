-- ============================================================
-- Task 34 — PUT/GET/REMOVE file commands
-- Category: Stages & File Management
-- Requires Task 1 already done: RAW.IOT_STAGE must exist.
--
-- IMPORTANT: PUT and GET touch your LOCAL filesystem, so they do NOT
-- work from a Snowsight worksheet (there's no local disk to talk to
-- in a browser). Run this file through a CLI client instead:
--   - SnowSQL (snowsql -a <account> -u <user>), or
--   - the newer Snowflake CLI (snow sql -f 35_put_get_remove_commands.sql)
-- Everything else here (LIST/REMOVE/SELECT) works fine in Snowsight
-- too, but PUT/GET specifically need the CLI.
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;

-- 1. PUT a small file up to your USER stage (@~) first -- no table,
--    no schema object, just your own private space. Use the sample
--    CSV from Task 1 so you don't need to regenerate anything.
--    (Adjust the path to wherever you cloned this repo locally.)
PUT file:///path/to/task-01-upload-csv/iot_sensor_readings_SAMPLE.csv @~
    AUTO_COMPRESS = TRUE
    OVERWRITE = TRUE;

-- PUT's own result set tells you what happened: source_size vs
-- target_size (compression ratio), and a status of UPLOADED vs
-- SKIPPED. Note the file lands as iot_sensor_readings_SAMPLE.csv.gz
-- -- AUTO_COMPRESS gzips it during upload, you didn't gzip it first.
LIST @~;

-- 2. Run the exact same PUT again. Notice the status this time.
PUT file:///path/to/task-01-upload-csv/iot_sensor_readings_SAMPLE.csv @~
    AUTO_COMPRESS = TRUE;
-- Without OVERWRITE = TRUE, Snowflake checksums the local file
-- against what's already on the stage and skips re-uploading an
-- identical file. This is why re-running a load script is cheap.

-- 3. Now PUT the same sample file to the NAMED stage from Task 1,
--    under its own subfolder so it doesn't collide with the real
--    2,000,000-row file already sitting there.
PUT file:///path/to/task-01-upload-csv/iot_sensor_readings_SAMPLE.csv @RAW.IOT_STAGE/practice/
    AUTO_COMPRESS = TRUE
    OVERWRITE = TRUE
    PARALLEL = 4;

LIST @RAW.IOT_STAGE/practice/;

-- Compare against the whole stage -- the real file from Task 1 should
-- still be sitting at the top level, untouched.
LIST @RAW.IOT_STAGE;

-- 4. GET it back down to a *different* local folder than the one you
--    PUT it from, so you can tell the round-trip actually happened
--    instead of just looking at the file you already had.
GET @RAW.IOT_STAGE/practice/iot_sensor_readings_SAMPLE.csv.gz file:///path/to/some/download/dir/;
-- Compare row counts / diff the decompressed file against the
-- original to confirm nothing got mangled in the round trip.

-- 5. REMOVE with a pattern -- clean up just the practice file(s),
--    leave the real load file alone.
REMOVE @RAW.IOT_STAGE/practice/ PATTERN = '.*sensor_readings_SAMPLE.*';

LIST @RAW.IOT_STAGE/practice/;
LIST @RAW.IOT_STAGE;

-- 6. Clean up the user stage too.
REMOVE @~ PATTERN = '.*sensor_readings_SAMPLE.*';
LIST @~;

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 35:
--
-- 1. PUT defaults to AUTO_COMPRESS = TRUE and gzips your file during
--    upload. If you PUT an already-gzipped file (like the .gz from
--    Task 1) with AUTO_COMPRESS still TRUE, what happens -- does
--    Snowflake double-compress it, and how would you tell either way
--    from the PUT result set?
--
-- 2. Step 2 re-ran an identical PUT without OVERWRITE and it skipped
--    the upload. What is Snowflake actually comparing to decide
--    "skip" vs "upload" -- filename, file size, a hash, a
--    modified-timestamp, or some combination? What would make it
--    upload again even though the filename is unchanged?
--
-- 3. REMOVE in step 5 used a regex PATTERN scoped to the /practice/
--    prefix. What would `REMOVE @RAW.IOT_STAGE PATTERN='.*sensor_readings_SAMPLE.*'`
--    (no /practice/ prefix) have matched instead, given step 3 also
--    put a copy there? Why does scoping the path matter even when
--    the pattern itself looks specific enough on its own?
-- ============================================================
