-- ============================================================
-- Task 57 — Unload to JSON
-- Category: Unloading data
-- Reuses PRODUCT_METADATA (Task 21) specifically because it has a
-- VARIANT column -- that's where JSON unload's advantage over CSV
-- actually shows up.
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;
USE SCHEMA ADVANCED;

-- 1. A flat table with no VARIANT columns -- build one JSON object
--    per row on the fly with OBJECT_CONSTRUCT.
COPY INTO @RAW.IOT_STAGE/unload_json_sales/
FROM (
    SELECT OBJECT_CONSTRUCT('region', region, 'quarter', quarter, 'amount', amount)
    FROM QUARTERLY_SALES
)
FILE_FORMAT = (TYPE = JSON)
OVERWRITE = TRUE;

-- 2. A table that ALREADY has a VARIANT column -- unload it directly
--    as JSON, no OBJECT_CONSTRUCT needed.
COPY INTO @RAW.IOT_STAGE/unload_json_metadata/
FROM PRODUCT_METADATA
FILE_FORMAT = (TYPE = JSON)
OVERWRITE = TRUE;

-- 3. The SAME table, unloaded as CSV instead, for direct comparison.
COPY INTO @RAW.IOT_STAGE/unload_csv_metadata/
FROM PRODUCT_METADATA
FILE_FORMAT = (TYPE = CSV)
OVERWRITE = TRUE;

-- Download both (GET, Task 34, or Snowsight) and open them side by
-- side. Look specifically at how the `attributes` column is
-- represented in each.

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 58:
--
-- 1. Open the JSON file from step 2. Is it ONE big JSON array
--    containing every row, or one separate JSON object per line
--    (newline-delimited JSON)? Check the actual file, don't guess.
--
-- 2. Compare how the `attributes` column looks in step 2's JSON
--    output vs. step 3's CSV output. In the CSV version, is
--    `attributes` still genuinely structured/nested data, or has it
--    become an escaped string blob? Which format actually preserved
--    the nesting?
--
-- 3. QUARTERLY_SALES has no VARIANT columns at all — every value is
--    already flat. Given that JSON unload worked fine for it too
--    (step 1), when would you still deliberately choose CSV over JSON
--    for a table like this? Think about file size and how a
--    non-technical person opening the file in a spreadsheet tool
--    would react to each format.
-- ============================================================
