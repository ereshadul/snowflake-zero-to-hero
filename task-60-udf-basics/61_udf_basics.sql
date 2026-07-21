-- ============================================================
-- Task 60 — UDF basics & supported languages
-- Category: Programmability
--
-- About this category: Tasks 60-62 are about extending Snowflake with
-- your own logic -- UDFs, stored procedures, and notifications --
-- instead of only ever using built-in functions.
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;
USE SCHEMA ADVANCED;

-- 1. SQL UDF — the simplest kind. Body is a single expression.
CREATE OR REPLACE FUNCTION FAHRENHEIT_TO_CELSIUS(temp_f FLOAT)
RETURNS FLOAT
AS
$$
    (temp_f - 32) * 5 / 9
$$;

SELECT FAHRENHEIT_TO_CELSIUS(98.6) AS body_temp_c;

-- 2. JavaScript UDF.
CREATE OR REPLACE FUNCTION CELSIUS_TO_FAHRENHEIT_JS(temp_c FLOAT)
RETURNS FLOAT
LANGUAGE JAVASCRIPT
AS
$$
    return (TEMP_C * 9 / 5) + 32;
$$;

SELECT CELSIUS_TO_FAHRENHEIT_JS(37.0) AS body_temp_f;

-- 3. Python UDF — needs RUNTIME_VERSION and a HANDLER naming which
--    function in the body actually gets called.
CREATE OR REPLACE FUNCTION SQUARE_PY(n FLOAT)
RETURNS FLOAT
LANGUAGE PYTHON
RUNTIME_VERSION = '3.10'
HANDLER = 'square_it'
AS
$$
def square_it(n):
    return n * n
$$;

SELECT SQUARE_PY(7) AS squared;

-- 4. Try to make a UDF perform a DML side effect (an INSERT) instead
--    of just returning a computed value. Expect this to fail to even
--    CREATE — read the actual error.
CREATE OR REPLACE FUNCTION TRY_INSERT_UDF()
RETURNS STRING
AS
$$
    INSERT INTO GAME_SCORES (player_id, team, score) VALUES ('X', 'Z', 1)
$$;

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 61:
--
-- 1. Compare the three CREATE FUNCTION statements in steps 1-3.
--    What's present in the Python version (RUNTIME_VERSION, HANDLER)
--    that's entirely absent from the SQL and JavaScript versions?
--    Why would Python specifically need a way to name "which function
--    in this code is the entry point," when the SQL and JS versions
--    don't need anything equivalent?
--
-- 2. Step 4 should fail to even CREATE the function. Read the actual
--    error message. What does it tell you a UDF's body fundamentally
--    has to be — a single VALUE-producing expression, or something
--    that can also include statements like INSERT?
--
-- 3. Given UDFs structurally can't perform INSERT/UPDATE/DELETE, what
--    Snowflake object type WOULD let you write custom logic that
--    modifies data? (You'll build one directly in Task 61 — for now,
--    just name what you think it is and why a UDF's "just an
--    expression" nature rules it out for that job.)
-- ============================================================
