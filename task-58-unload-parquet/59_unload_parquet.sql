-- ============================================================
-- Task 58 — Unload to Parquet
-- Category: Unloading data
-- Parquet is binary and columnar (unlike CSV/JSON, both plain text)
-- -- it preserves actual data TYPES, not just text representations.
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;
USE SCHEMA ADVANCED;

-- 1. Try a direct, plain multi-column unload to Parquet.
COPY INTO @RAW.IOT_STAGE/unload_parquet_direct/
FROM (SELECT region, quarter, amount FROM QUARTERLY_SALES)
FILE_FORMAT = (TYPE = PARQUET)
OVERWRITE = TRUE;

-- 2. The alternative form some Snowflake versions/setups require:
--    wrap the whole row into a single OBJECT column first.
COPY INTO @RAW.IOT_STAGE/unload_parquet_object/
FROM (SELECT OBJECT_CONSTRUCT(*) AS row_data FROM QUARTERLY_SALES)
FILE_FORMAT = (TYPE = PARQUET)
OVERWRITE = TRUE;

-- 3. Round-trip check: query the unloaded Parquet file directly,
--    the same technique as Task 26, to confirm the TYPES survived
--    the round trip (not just the values as text).
SELECT $1 AS region, $2 AS quarter, $3 AS amount, TYPEOF($3) AS amount_type
FROM @RAW.IOT_STAGE/unload_parquet_direct/
    (FILE_FORMAT => 'RAW.IOT_CSV_FORMAT')  -- placeholder; see understanding check 1
LIMIT 5;

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 59:
--
-- 1. Step 3's query above deliberately reuses RAW.IOT_CSV_FORMAT,
--    which is a CSV format, not a Parquet one — this is wrong on
--    purpose. Create a proper Parquet file format
--    (CREATE FILE FORMAT ... TYPE = PARQUET) and rewrite step 3 to
--    use it correctly, following the same pattern Task 26 used for
--    querying staged Parquet directly.
--
-- 2. Did step 1 (the plain multi-column unload) succeed, or did it
--    error and force you to use step 2's OBJECT_CONSTRUCT wrapping
--    instead? Report exactly what happened on your account — this is
--    a case where the current behavior is worth testing directly
--    rather than assuming.
--
-- 3. Once you've fixed the query in question 1, check the amount
--    column's TYPEOF() result. Compare this to what TYPEOF() would
--    show if you'd unloaded to CSV instead and queried that back —
--    does CSV preserve the fact that amount is a NUMBER, or does
--    everything come back as a string that happens to look numeric?
-- ============================================================
