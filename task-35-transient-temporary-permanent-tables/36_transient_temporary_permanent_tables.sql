-- ============================================================
-- Task 35 — PERMANENT vs. TRANSIENT vs. TEMPORARY tables
-- Category: Table & Data Fundamentals
--
-- Every table you've created so far in this repo has been PERMANENT
-- by default -- this task is about the two alternatives you never
-- had a reason to reach for yet.
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;
USE SCHEMA ADVANCED;

-- 1. PERMANENT (the default -- no keyword needed). Full Time Travel
--    (up to 90 days on Enterprise+, 1 day on Standard) AND Fail-safe
--    (an extra 7 days Snowflake alone can recover from, you can't
--    query it yourself).
CREATE OR REPLACE TABLE PERMANENT_DEMO (id INT);

-- 2. TRANSIENT — same querying behavior as PERMANENT, but NO
--    Fail-safe at all, and Time Travel capped at 1 day regardless of
--    edition. In exchange: less storage cost, since Snowflake isn't
--    holding onto that extra Fail-safe copy.
CREATE OR REPLACE TRANSIENT TABLE TRANSIENT_DEMO (id INT);

-- 3. TEMPORARY — exists only for the lifetime of the SESSION that
--    created it. No Fail-safe, Time Travel capped at 1 day, and
--    invisible to every other session/user, even on the same
--    warehouse.
CREATE OR REPLACE TEMPORARY TABLE TEMP_DEMO (id INT);

-- 4. Confirm all three exist right now, in the same schema.
SHOW TABLES LIKE '%_DEMO' IN SCHEMA ADVANCED;
-- Look at the "kind" column in the result -- it labels each one.

-- 5. Check whether a permanent schema can hold a transient table (it
--    can) -- but what about the reverse? Try creating a schema as
--    TRANSIENT, then a PERMANENT table inside it.
CREATE TRANSIENT SCHEMA IF NOT EXISTS IOT_LAB.TRANSIENT_SCHEMA_DEMO;
CREATE OR REPLACE TABLE IOT_LAB.TRANSIENT_SCHEMA_DEMO.SHOULD_THIS_WORK (id INT);
SHOW TABLES IN SCHEMA IOT_LAB.TRANSIENT_SCHEMA_DEMO;
-- Read the "kind" column here especially closely.

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 36:
--
-- 1. For a staging table that gets fully TRUNCATEd and reloaded every
--    single day (the kind of table this repo's own Task 1 raw landing
--    table resembles), what's actually being wasted by leaving it
--    PERMANENT instead of TRANSIENT? Be specific about which cost
--    component (Time Travel storage, Fail-safe storage, or both)
--    you'd stop paying for.
--
-- 2. In step 5, you tried creating a PERMANENT table inside a
--    TRANSIENT schema. What does SHOW TABLES actually report for that
--    table's "kind" — does the containing schema's transient-ness
--    override the table's own (explicit or default) type, or does the
--    table keep the type you asked for?
--
-- 3. A TEMPORARY table disappears the moment your session ends —
--    even a dropped connection, not just an explicit DROP TABLE. Name
--    one real use case where that's exactly the behavior you want,
--    and one situation where a colleague who didn't know this would
--    be genuinely confused when their "table" vanished.
-- ============================================================
