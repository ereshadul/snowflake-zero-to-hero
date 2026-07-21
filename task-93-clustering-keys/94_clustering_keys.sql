-- ============================================================
-- Task 93 — Clustering keys
-- Category: Performance & cost
--
-- About this category: Tasks 93-98 are about making queries faster
-- and warehouses cheaper with evidence, not guesswork -- the same
-- instinct behind the SMALL-vs-MEDIUM tests you ran back in Task 2.
--
-- COST NOTE: automatic reclustering costs real, ongoing credits on a
-- table that keeps changing. This task deliberately demonstrates the
-- SYNTAX on a small throwaway table rather than altering the real
-- 50-million-row CURATED.SENSOR_READINGS_SYNTHETIC, to avoid
-- triggering background reclustering costs on a trial account.
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;
USE SCHEMA ADVANCED;

-- 1. Read-only: check clustering info on the REAL big table, which
--    has never had an explicit clustering key set. This costs
--    nothing -- it's just reading metadata.
SELECT SYSTEM$CLUSTERING_INFORMATION('IOT_LAB.CURATED.SENSOR_READINGS_SYNTHETIC', '(sensor_id)');

-- 2. A small, throwaway table to safely demonstrate the actual
--    ALTER TABLE ... CLUSTER BY syntax.
CREATE OR REPLACE TABLE CLUSTERING_SYNTAX_DEMO (
    sensor_id       STRING,
    event_timestamp TIMESTAMP_NTZ,
    value           FLOAT
);

INSERT INTO CLUSTERING_SYNTAX_DEMO (sensor_id, event_timestamp, value)
SELECT
    'SENSOR_' || LPAD(MOD(SEQ4(), 5)::STRING, 5, '0'),
    DATEADD(second, SEQ4(), '2026-06-01'::TIMESTAMP_NTZ),
    UNIFORM(-40, 60, RANDOM())
FROM TABLE(GENERATOR(ROWCOUNT => 10000));

ALTER TABLE CLUSTERING_SYNTAX_DEMO CLUSTER BY (sensor_id);

SHOW TABLES LIKE 'CLUSTERING_SYNTAX_DEMO';
-- Look at the "automatic_clustering" column.

SELECT SYSTEM$CLUSTERING_INFORMATION('CLUSTERING_SYNTAX_DEMO', '(sensor_id)');

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 94:
--
-- 1. Look at step 1's clustering information for the real 50-million
--    row table, which has never been explicitly clustered. What does
--    the average_depth value actually mean, and is a LOWER or HIGHER
--    depth generally "better" for query pruning?
--
-- 2. Right after step 2's ALTER TABLE ... CLUSTER BY, does
--    SYSTEM$CLUSTERING_INFORMATION show an immediate, already-perfect
--    clustering depth, or does real reclustering happen asynchronously
--    in the background over time (and cost credits as it runs)?
--
-- 3. Given automatic reclustering costs real, ongoing credits on any
--    table that keeps changing, why wouldn't you just add a clustering
--    key to every large table "just in case it helps"? What would you
--    actually check (hint: think about the query patterns that hit a
--    table) before deciding a table is worth clustering at all?
-- ============================================================
