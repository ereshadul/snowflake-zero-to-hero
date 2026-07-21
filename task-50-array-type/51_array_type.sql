-- ============================================================
-- Task 50 — ARRAY data type
-- Category: Semi-structured data
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;
USE SCHEMA ADVANCED;

CREATE OR REPLACE TABLE DEVICE_TAGS (
    device_id STRING,
    tags      ARRAY
);

INSERT INTO DEVICE_TAGS SELECT 'D1', ARRAY_CONSTRUCT('outdoor', 'battery-powered', 'critical');
INSERT INTO DEVICE_TAGS SELECT 'D2', ARRAY_CONSTRUCT('indoor');

-- 1. Indexing (0-based) and size.
SELECT
    device_id, tags,
    tags[0]::STRING   AS first_tag,
    ARRAY_SIZE(tags)  AS tag_count
FROM DEVICE_TAGS;

-- 2. Indexing PAST the end of a shorter array.
SELECT device_id, tags[5] AS out_of_bounds
FROM DEVICE_TAGS
WHERE device_id = 'D2';   -- only has 1 element, index 0

-- 3. Searching for a value inside the array.
SELECT device_id
FROM DEVICE_TAGS
WHERE ARRAY_CONTAINS('critical'::VARIANT, tags);

-- 4. The same search WITHOUT the ::VARIANT cast on the search value.
SELECT device_id
FROM DEVICE_TAGS
WHERE ARRAY_CONTAINS('critical', tags);

-- 5. ARRAY_APPEND — returns a NEW array value, doesn't touch the
--    table.
SELECT device_id, tags, ARRAY_APPEND(tags, 'new-tag') AS with_new_tag
FROM DEVICE_TAGS
WHERE device_id = 'D2';

SELECT * FROM DEVICE_TAGS WHERE device_id = 'D2';
-- Confirm the table itself is unchanged.

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 51:
--
-- 1. What did tags[5] actually return for D2 in step 2 — an error, or
--    a value, and if a value, what was it? Compare this to how a
--    normal SQL array/list access would behave in a language where
--    out-of-bounds indexing throws an error.
--
-- 2. Compare step 3's result (with ::VARIANT) to step 4's (without
--    it). Do they return the same rows, different rows, or does one
--    of them error? What does that tell you about whether
--    ARRAY_CONTAINS needs its search argument explicitly typed as
--    VARIANT to match correctly?
--
-- 3. Step 5 confirmed ARRAY_APPEND doesn't mutate the underlying
--    table. What statement would you actually need to run to
--    PERSIST that appended tag back into DEVICE_TAGS for D2 — write
--    it out.
-- ============================================================
