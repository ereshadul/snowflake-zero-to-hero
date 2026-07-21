-- ============================================================
-- Task 55 — Unload to CSV
-- Category: Unloading data
-- The mirror image of Task 1: COPY INTO a STAGE LOCATION instead of a
-- table. Uses QUARTERLY_SALES (Task 11).
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;
USE SCHEMA ADVANCED;

-- 1. Unload an entire table straight to CSV.
COPY INTO @RAW.IOT_STAGE/unload_demo/
FROM QUARTERLY_SALES
FILE_FORMAT = (TYPE = CSV)
OVERWRITE = TRUE;

LIST @RAW.IOT_STAGE/unload_demo/;
-- Notice how many files this produced for just 8 rows.

-- 2. Unload a QUERY result (an aggregation), not a raw table --
--    the source becomes a subquery instead of a bare table name.
COPY INTO @RAW.IOT_STAGE/unload_query_demo/
FROM (
    SELECT region, SUM(amount) AS total_sales
    FROM QUARTERLY_SALES
    GROUP BY region
)
FILE_FORMAT = (TYPE = CSV)
OVERWRITE = TRUE;

LIST @RAW.IOT_STAGE/unload_query_demo/;

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 56:
--
-- 1. QUARTERLY_SALES only has 8 rows, yet step 1's LIST likely shows
--    MORE than one output file. Why does Snowflake split unload
--    output into multiple files even for a small table — what does
--    the file count actually correspond to (hint: it's not the row
--    count)?
--
-- 2. Compare the FROM clause in step 1 (a bare table name) to step 2
--    (a parenthesized SELECT). What's the actual syntactic difference
--    that lets COPY INTO unload either a whole table or an arbitrary
--    query result?
--
-- 3. Download one of the unloaded files (via Snowsight or GET, Task
--    34) and open it. Does it have a header row with column names, or
--    just raw data? What option would you add to the COPY INTO to
--    include column headers if you needed them?
-- ============================================================
