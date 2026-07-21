-- ============================================================
-- Task 61 — Stored procedures vs. UDFs
-- Category: Programmability
-- Directly answers Task 60's final question: THIS is the object type
-- that can actually run DML/DDL.
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;
USE SCHEMA ADVANCED;

-- 1. A stored procedure that DOES what Task 60's UDF attempt
--    couldn't: actually run a DDL statement.
CREATE OR REPLACE PROCEDURE TRUNCATE_TABLE_PROC(table_name STRING)
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
    EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || :table_name;
    RETURN 'Truncated ' || :table_name;
END;
$$;

INSERT INTO PERMANENT_DEMO (id) VALUES (1), (2), (3);
SELECT COUNT(*) AS before_truncate FROM PERMANENT_DEMO;

CALL TRUNCATE_TABLE_PROC('ADVANCED.PERMANENT_DEMO');

SELECT COUNT(*) AS after_truncate FROM PERMANENT_DEMO;

-- 2. Procedures also support real procedural control flow
--    (Snowflake Scripting: DECLARE, IF/THEN, loops) -- something a
--    UDF's single-expression body can't do at all.
CREATE OR REPLACE PROCEDURE CONDITIONAL_CHECK(threshold INT)
RETURNS STRING
LANGUAGE SQL
AS
$$
DECLARE
    row_count INT;
BEGIN
    SELECT COUNT(*) INTO :row_count FROM GAME_SCORES;
    IF (:row_count > :threshold) THEN
        RETURN 'Table has ' || :row_count || ' rows, exceeds threshold ' || :threshold;
    ELSE
        RETURN 'Table has ' || :row_count || ' rows, within threshold ' || :threshold;
    END IF;
END;
$$;

CALL CONDITIONAL_CHECK(5);
CALL CONDITIONAL_CHECK(100);

-- 3. UDFs are invoked inline inside a SELECT, once per row. Try
--    calling a stored procedure the same way, inline in a SELECT.
SELECT TRUNCATE_TABLE_PROC('ADVANCED.PERMANENT_DEMO');
-- Expect this to fail -- procedures aren't callable like that.

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 62:
--
-- 1. Confirm PERMANENT_DEMO's row count actually dropped to 0 after
--    step 1's CALL. Task 60's UDF attempted the same TRUNCATE and
--    failed to even CREATE. What does a stored procedure's body
--    language (Snowflake Scripting, with EXECUTE IMMEDIATE) have
--    access to that a UDF's body fundamentally doesn't?
--
-- 2. Step 3 tries to call a procedure from inside a SELECT, the way
--    you'd call a UDF. Read the actual error. What does that confirm
--    about HOW procedures are invoked (CALL, as their own top-level
--    statement) versus how UDFs are invoked (inline, inside an
--    expression)?
--
-- 3. CONDITIONAL_CHECK uses DECLARE/IF/THEN — genuine procedural
--    control flow. Could you express this same "count rows, branch on
--    a threshold, return different messages" logic inside a UDF's
--    single-expression body at all, even using CASE WHEN? What's
--    fundamentally different between "a value-producing expression
--    with conditional logic baked in" and "a sequence of procedural
--    steps with branching"?
-- ============================================================
