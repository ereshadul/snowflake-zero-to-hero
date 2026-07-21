-- ============================================================
-- Task 33 — Internal stage types
-- Requires Task 1 already done: RAW.IOT_STAGE must exist.
--
-- Purely observational -- no file uploads needed here. Every
-- Snowflake account already has all three stage types available
-- with zero setup. Task 34 covers actually moving files with
-- PUT/GET/REMOVE; this one is just "what am I even looking at."
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;

-- 1. USER STAGE — @~
--    One per user, private to you, not tied to any table or schema.
--    Nobody had to create this -- it's always there.
LIST @~;

-- 2. TABLE STAGE — @%table_name
--    Every table gets one automatically the instant the table exists.
--    You never CREATE a table stage and you can't rename or drop it
--    independently -- it lives and dies with the table.
LIST @%RAW.SENSOR_READINGS_RAW;

-- Prove the point: this table stage exists purely because the table
-- does, with zero setup from you.
SELECT 'table stage exists for SENSOR_READINGS_RAW, never explicitly created' AS note;

-- 3. NAMED STAGE — @stage_name
--    The one you already used in Task 1: RAW.IOT_STAGE. Unlike the
--    other two, this is a real schema-level object -- it shows up in
--    SHOW STAGES, can be granted to other roles, and carries its own
--    default FILE_FORMAT.
LIST @RAW.IOT_STAGE;

DESCRIBE STAGE RAW.IOT_STAGE;

SHOW STAGES IN SCHEMA RAW;

-- Try the same SHOW/DESCRIBE against the other two -- notice what's
-- missing.
-- SHOW STAGES will NOT list @~ or @%SENSOR_READINGS_RAW: they aren't
-- schema objects, so there's nothing to grant, rename, or show.

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 34:
--
-- 1. GRANT USAGE ON STAGE RAW.IOT_STAGE TO ROLE some_role; works.
--    Try the equivalent against @~ or @%SENSOR_READINGS_RAW conceptually
--    -- why can't you grant access to either of those the same way?
--    What does that tell you about who's allowed to use each stage type?
--
-- 2. If you DROP TABLE RAW.SENSOR_READINGS_RAW, what happens to its
--    table stage and any files sitting on it? Contrast that with what
--    happens to RAW.IOT_STAGE's files if some other table got dropped.
--
-- 3. A named stage has its own FILE_FORMAT default (set back in
--    01_setup_ddl.sql). Do @~ and @%table have an equivalent default
--    file format of their own, or do they only get one supplied at
--    COPY/PUT time? What does that imply about which stage type fits
--    a "many different file shapes land here" scenario vs a "always
--    the exact same format" one?
-- ============================================================
