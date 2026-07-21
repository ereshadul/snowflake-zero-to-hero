-- ============================================================
-- Task 51 — VARIANT data type
-- Category: Semi-structured data
-- OBJECT and ARRAY (Tasks 49-50) are specific shapes. VARIANT is the
-- general container -- it can hold either of those, a bare scalar,
-- or even a value that looks like "nothing" but isn't quite NULL.
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;
USE SCHEMA ADVANCED;

CREATE OR REPLACE TABLE MIXED_VARIANT_DEMO (id INT, data VARIANT);

INSERT INTO MIXED_VARIANT_DEMO SELECT 1, PARSE_JSON('{"a": 1, "b": [10, 20, 30]}');
INSERT INTO MIXED_VARIANT_DEMO SELECT 2, PARSE_JSON('42');
INSERT INTO MIXED_VARIANT_DEMO SELECT 3, PARSE_JSON('"just a string"');
INSERT INTO MIXED_VARIANT_DEMO SELECT 4, NULL;                 -- a true SQL NULL
INSERT INTO MIXED_VARIANT_DEMO SELECT 5, PARSE_JSON('null');   -- the JSON LITERAL null -- not the same thing

-- 1. What TYPE is actually stored in each row?
SELECT id, data, TYPEOF(data) AS actual_type FROM MIXED_VARIANT_DEMO ORDER BY id;

-- 2. The classic gotcha: SQL NULL vs. JSON null are NOT the same
--    value, even though both LOOK empty when displayed.
SELECT
    id,
    data IS NULL          AS is_sql_null,
    IS_NULL_VALUE(data)   AS is_json_null_literal
FROM MIXED_VARIANT_DEMO
ORDER BY id;

-- 3. Traversal into a nested structure: object key, then array index,
--    then a cast to a concrete type.
SELECT id, data:b[1]::INT AS second_array_element
FROM MIXED_VARIANT_DEMO
WHERE id = 1;

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 52:
--
-- 1. Row 4 (true SQL NULL) and row 5 (PARSE_JSON('null')) look
--    identical when you just SELECT data and look at the display.
--    Fill in this table from what step 2 actually returned:
--    row 4 -> is_sql_null = ?, is_json_null_literal = ?
--    row 5 -> is_sql_null = ?, is_json_null_literal = ?
--    Confirm the two rows are NOT actually the same thing underneath.
--
-- 2. Row 2 holds just the bare number 42, row 3 holds just a bare
--    string — neither is wrapped in {} or []. What does TYPEOF return
--    for each in step 1, confirming VARIANT can hold a plain scalar
--    value, not just OBJECT/ARRAY-shaped JSON?
--
-- 3. Break down data:b[1]::INT from step 3 into its three separate
--    operations, in order, and explain what each one does: the `:b`
--    part, the `[1]` part, and the `::INT` part. What would happen if
--    you left off the final ::INT cast entirely — would the value
--    displayed look any different, even though the underlying type
--    wouldn't be INT?
-- ============================================================
