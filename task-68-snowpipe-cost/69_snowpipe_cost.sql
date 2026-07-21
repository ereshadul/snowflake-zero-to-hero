-- ============================================================
-- Task 68 — Snowpipe cost model
-- Category: Snowpipe
-- Completes the Snowpipe category. Snowpipe runs on Snowflake-managed
-- SERVERLESS compute -- billed separately from any warehouse you own,
-- and with a cost driver that's easy to miss: a per-FILE overhead, not
-- just a per-byte cost.
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;

-- 1. Actual credits consumed by RAW.SENSOR_PIPE specifically -- this
--    is SEPARATE from anything IOT_LAB_WH has cost you.
SELECT *
FROM TABLE(INFORMATION_SCHEMA.PIPE_USAGE_HISTORY(
    DATE_RANGE_START => DATEADD('day', -7, CURRENT_TIMESTAMP()),
    PIPE_NAME         => 'RAW.SENSOR_PIPE'
));
-- Look at CREDITS_USED, FILES_INSERTED, and BYTES_INSERTED together.

-- 2. If you've only run a couple of small test files through this
--    pipe so far, credits_used may show as 0 or a tiny fraction --
--    Snowpipe billing has its own rounding behavior, similar in
--    spirit to a warehouse's per-second billing floor.

-- ============================================================
-- UNDERSTANDING CHECK — this closes out the Snowpipe category:
--
-- 1. Look at your own PIPE_USAGE_HISTORY output. Given how few files
--    you've actually run through RAW.SENSOR_PIPE, does CREDITS_USED
--    show as exactly 0, or some small nonzero amount? What does that
--    suggest about how granular (or not) Snowpipe's billing actually
--    is at very low usage volumes?
--
-- 2. Snowflake's documented Snowpipe cost model includes a per-FILE
--    overhead, on top of the actual compute needed to parse and load
--    that file's bytes. Given that, would loading 1,000,000 rows as
--    ONE file cost more or less total credits than loading that exact
--    same 1,000,000 rows split across 1,000 separate tiny files?
--    Explain the mechanism — not just "more" or "less," but WHY the
--    file count itself drives cost independent of total data volume.
--
-- 3. Given question 2's answer, what upstream practice would you
--    recommend to a team whose Snowpipe bill is surprisingly high —
--    something they could change about HOW files get produced before
--    they ever reach the stage, not anything about the pipe or
--    COPY INTO statement itself?
-- ============================================================
