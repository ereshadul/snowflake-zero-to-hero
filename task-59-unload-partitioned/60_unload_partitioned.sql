-- ============================================================
-- Task 59 — Partitioned unload
-- Category: Unloading data
-- Completes the Unloading data category.
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;
USE SCHEMA ADVANCED;

-- 1. PARTITION BY a raw column -- fans one unload out into a
--    subfolder per distinct value.
COPY INTO @RAW.IOT_STAGE/unload_partitioned/
FROM QUARTERLY_SALES
PARTITION BY (region)
FILE_FORMAT = (TYPE = CSV)
OVERWRITE = TRUE;

LIST @RAW.IOT_STAGE/unload_partitioned/;

-- 2. PARTITION BY an EXPRESSION instead of a bare column -- gives you
--    control over the exact folder naming, e.g. Hive-style
--    "key=value" partitioning, which downstream tools like Spark
--    recognize automatically.
COPY INTO @RAW.IOT_STAGE/unload_partitioned_hive/
FROM QUARTERLY_SALES
PARTITION BY ('region=' || region)
FILE_FORMAT = (TYPE = CSV)
OVERWRITE = TRUE;

LIST @RAW.IOT_STAGE/unload_partitioned_hive/;

-- ============================================================
-- UNDERSTANDING CHECK — answer before wrapping up this category:
--
-- 1. Compare the folder/prefix names in step 1's LIST output to step
--    2's. Step 1 partitions on the raw `region` value directly --
--    what does that prefix actually look like versus step 2's
--    "region=East" style naming? Which one would a tool expecting
--    Hive-style partitioning actually be able to parse?
--
-- 2. Why go through PARTITION BY at all instead of just running
--    separate COPY INTO ... WHERE region = 'East' statements, one per
--    region, one at a time? What does PARTITION BY save you from
--    doing manually as the number of distinct regions grows?
--
-- 3. What would happen if you PARTITION BY an expression that
--    produces a huge number of distinct values (e.g. partitioning
--    QUARTERLY_SALES by a unique transaction ID instead of region)?
--    Think about what "fan out into a folder per distinct value"
--    means when there are thousands of distinct values instead of 2.
-- ============================================================
