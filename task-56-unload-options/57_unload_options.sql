-- ============================================================
-- Task 56 — Unload options (SINGLE/MAX_FILE_SIZE/HEADER/OVERWRITE)
-- Category: Unloading data
-- Directly answers what Task 55 left open: why multiple files, and
-- no header, by default.
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;
USE SCHEMA ADVANCED;

-- 1. SINGLE = TRUE forces exactly one output file, no matter how many
--    micro-partitions the source data spans.
COPY INTO @RAW.IOT_STAGE/unload_single/
FROM QUARTERLY_SALES
FILE_FORMAT = (TYPE = CSV)
SINGLE = TRUE
OVERWRITE = TRUE;

LIST @RAW.IOT_STAGE/unload_single/;

-- 2. HEADER = TRUE adds a header row with column names -- Task 55's
--    unload didn't have one.
COPY INTO @RAW.IOT_STAGE/unload_header/
FROM QUARTERLY_SALES
FILE_FORMAT = (TYPE = CSV)
HEADER = TRUE
SINGLE = TRUE
OVERWRITE = TRUE;

-- Download this one (GET, Task 34, or via Snowsight) and confirm the
-- first line is actual column names, not data.

-- 3. MAX_FILE_SIZE caps how large each output file can get (in
--    bytes), influencing how many files a multi-file unload produces.
COPY INTO @RAW.IOT_STAGE/unload_maxsize/
FROM QUARTERLY_SALES
FILE_FORMAT = (TYPE = CSV)
MAX_FILE_SIZE = 1000
OVERWRITE = TRUE;

LIST @RAW.IOT_STAGE/unload_maxsize/;

-- 4. OVERWRITE = FALSE (the default) — re-run step 1's exact unload a
--    second time without OVERWRITE at all.
COPY INTO @RAW.IOT_STAGE/unload_single/
FROM QUARTERLY_SALES
FILE_FORMAT = (TYPE = CSV)
SINGLE = TRUE;

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 57:
--
-- 1. Step 1 uses SINGLE = TRUE and produces one file, unlike Task
--    55's multi-file default. What's the real-world tradeoff of
--    forcing SINGLE = TRUE on a genuinely huge table — what does
--    Snowflake lose the ability to do (think back to how COPY INTO
--    loading itself benefits from multiple files) by writing
--    everything to one output file?
--
-- 2. Run step 4 and read what actually happens. Does it silently do
--    nothing, error, or overwrite anyway despite OVERWRITE not being
--    set to TRUE? What's the default value of OVERWRITE for unloading,
--    and does it match what you'd guess from PUT's OVERWRITE default
--    back in Task 34?
--
-- 3. Step 3 sets MAX_FILE_SIZE = 1000 (bytes) — deliberately tiny for
--    this small table. Compare the file count in step 3's LIST to
--    step 1's single file. Is the relationship between MAX_FILE_SIZE
--    and actual file count exact (files are always precisely that
--    size) or approximate (a soft target Snowflake works toward)?
-- ============================================================
