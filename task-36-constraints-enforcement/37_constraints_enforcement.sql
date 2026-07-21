-- ============================================================
-- Task 36 — What constraints Snowflake actually enforces
-- Category: Table & Data Fundamentals
--
-- The surprising part: PRIMARY KEY, UNIQUE, and FOREIGN KEY are all
-- accepted by Snowflake's DDL, but NONE of them are actually checked
-- at insert time by default. Only NOT NULL is genuinely enforced.
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;
USE SCHEMA ADVANCED;

-- 1. PRIMARY KEY — declared, but watch what actually happens.
CREATE OR REPLACE TABLE PK_TEST (id INT PRIMARY KEY, name STRING);
INSERT INTO PK_TEST (id, name) VALUES (1, 'Alice'), (1, 'Bob');  -- duplicate id!

SELECT * FROM PK_TEST;
SELECT COUNT(*) AS rows_with_id_1 FROM PK_TEST WHERE id = 1;

-- 2. UNIQUE — same story.
CREATE OR REPLACE TABLE UNIQUE_TEST (email STRING UNIQUE);
INSERT INTO UNIQUE_TEST (email) VALUES ('a@example.com'), ('a@example.com');
SELECT COUNT(*) AS duplicate_emails FROM UNIQUE_TEST WHERE email = 'a@example.com';

-- 3. NOT NULL — the one exception. This one IS genuinely enforced.
CREATE OR REPLACE TABLE NOTNULL_TEST (name STRING NOT NULL);
INSERT INTO NOTNULL_TEST (name) VALUES (NULL);
-- Expect this to fail outright, unlike steps 1 and 2.

-- 4. FOREIGN KEY — an orphaned child row (no matching parent), which
--    a real foreign key constraint would reject in most databases.
CREATE OR REPLACE TABLE FK_PARENT (id INT PRIMARY KEY);
CREATE OR REPLACE TABLE FK_CHILD (parent_id INT REFERENCES FK_PARENT(id));
INSERT INTO FK_PARENT (id) VALUES (1);
INSERT INTO FK_CHILD (parent_id) VALUES (999);  -- no parent with id=999 exists
SELECT * FROM FK_CHILD;

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 37:
--
-- 1. PK_TEST ends up with two rows both having id = 1, despite
--    PRIMARY KEY being declared on that column. What does that tell
--    you about what a PRIMARY KEY constraint actually IS in
--    Snowflake — is it a runtime rule, or closer to documentation/a
--    hint for the query optimizer? (Look up the RELY option on
--    constraints while you're at it — what does RELY actually change
--    about this?)
--
-- 2. NOT NULL is the one exception that genuinely gets enforced
--    end-to-end. Contrast it with PRIMARY KEY/UNIQUE/FOREIGN KEY —
--    what's structurally different about "this value can't be
--    missing" versus "this value can't be duplicated across rows" or
--    "this value must exist somewhere in another table" that might
--    explain why only the first one is cheap enough to check on
--    every single insert?
--
-- 3. Since Snowflake won't stop a duplicate PK or an orphaned FK from
--    landing, whose job is it to actually catch that in a real
--    pipeline? Name a specific task/technique from earlier in this
--    repo that's the real tool for this — hint: think about what
--    you'd run right after a load to verify the data is actually
--    clean.
-- ============================================================
