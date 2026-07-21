-- ============================================================
-- Task 21 — LATERAL joins with table functions
-- FLATTEN (Task 52) is a special case of THIS general mechanism --
-- a table function called once per row of an outer table, able to
-- reference that row's own columns as its arguments.
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;
USE SCHEMA ADVANCED;

CREATE OR REPLACE TABLE PRODUCT_TAGS (
    product_id INT,
    tags       STRING   -- comma-separated: 'electronics,sale,new'
);
INSERT INTO PRODUCT_TAGS (product_id, tags) VALUES
    (1, 'electronics,sale,new'),
    (2, 'clothing,sale'),
    (3, 'electronics');

-- 1. LATERAL + SPLIT_TO_TABLE: call a table function once PER ROW of
--    PRODUCT_TAGS, with each call's argument (p.tags) coming from
--    that specific row -- an ordinary (non-lateral) join to a table
--    function can't do this, because the function needs a *different*
--    argument value for every outer row, not one fixed value.
SELECT p.product_id, t.value AS tag
FROM PRODUCT_TAGS p,
     LATERAL SPLIT_TO_TABLE(p.tags, ',') AS t
ORDER BY p.product_id, t.value;

-- 2. Same mechanism, applied to VARIANT data — this IS what FLATTEN
--    is, under the hood: a table function, called laterally.
CREATE OR REPLACE TABLE PRODUCT_METADATA (
    product_id INT,
    attributes VARIANT
);
INSERT INTO PRODUCT_METADATA (product_id, attributes) SELECT 1, PARSE_JSON('{"color": "red",  "sizes": ["S", "M", "L"]}');
INSERT INTO PRODUCT_METADATA (product_id, attributes) SELECT 2, PARSE_JSON('{"color": "blue", "sizes": ["M"]}');

SELECT p.product_id, f.value::STRING AS size
FROM PRODUCT_METADATA p,
     LATERAL FLATTEN(input => p.attributes:sizes) f
ORDER BY p.product_id, size;

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 22:
--
-- 1. Try rewriting step 1 WITHOUT the LATERAL keyword, as
--    `FROM PRODUCT_TAGS p, TABLE(SPLIT_TO_TABLE(p.tags, ','))` — does
--    it still work, or does it error? Report exactly what you find;
--    this is genuinely worth testing rather than assuming.
--
-- 2. Product 1 has 3 tags and product 2 has 2 tags. How many total
--    rows does step 1's result have, and does that match
--    3 + 2 + (product 3's tag count)? What does that tell you about
--    what a lateral join does to row count compared to a normal join
--    against a fixed-size table?
--
-- 3. Try rewriting step 2 as `FROM PRODUCT_METADATA p,
--    TABLE(FLATTEN(input => p.attributes:sizes)) f` -- dropping the
--    LATERAL keyword and wrapping in TABLE(...) instead. Does it
--    still work? Given what you found in question 1 for
--    SPLIT_TO_TABLE, does FLATTEN behave the same way?
--    (You'll meet FLATTEN again, on its own, in the Semi-structured
--    data category later in this roadmap -- keep this comparison in
--    mind when you get there.)
-- ============================================================
