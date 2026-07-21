-- ============================================================
-- Task 63 — Comparing two tables for drift
-- Category: Data Integrity & Quality
-- Simulates a real drift scenario: one changed value, one row missing
-- from QA, one row extra in QA, two rows identical.
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;
USE SCHEMA ADVANCED;

CREATE OR REPLACE TABLE CUSTOMER_PROD (customer_id INT, name STRING, email STRING);
CREATE OR REPLACE TABLE CUSTOMER_QA   (customer_id INT, name STRING, email STRING);

INSERT INTO CUSTOMER_PROD (customer_id, name, email) VALUES
    (1, 'Alice', 'alice@example.com'),
    (2, 'Bob',   'bob@example.com'),
    (3, 'Carol', 'carol@example.com'),
    (4, 'Dave',  'dave@example.com');

INSERT INTO CUSTOMER_QA (customer_id, name, email) VALUES
    (1, 'Alice', 'alice@example.com'),
    (2, 'Bob',   'bob@NEW-DOMAIN.com'),  -- drifted: email changed
    (3, 'Carol', 'carol@example.com'),
    (5, 'Eve',   'eve@example.com');     -- extra: not in PROD at all
-- customer_id 4 (Dave) is conspicuously MISSING from CUSTOMER_QA.

-- 1. MINUS (a.k.a. EXCEPT) -- full-row comparison, either direction.
SELECT * FROM CUSTOMER_PROD
MINUS
SELECT * FROM CUSTOMER_QA;

SELECT * FROM CUSTOMER_QA
MINUS
SELECT * FROM CUSTOMER_PROD;

-- 2. A hash-based comparison keyed on customer_id -- categorizes
--    EXACTLY what kind of drift each row has, not just "differs."
WITH prod_hashed AS (
    SELECT customer_id, HASH(name, email) AS row_hash FROM CUSTOMER_PROD
),
qa_hashed AS (
    SELECT customer_id, HASH(name, email) AS row_hash FROM CUSTOMER_QA
)
SELECT
    COALESCE(p.customer_id, q.customer_id) AS customer_id,
    CASE
        WHEN p.customer_id IS NULL THEN 'EXTRA_IN_QA'
        WHEN q.customer_id IS NULL THEN 'MISSING_IN_QA'
        WHEN p.row_hash != q.row_hash THEN 'VALUE_MISMATCH'
        ELSE 'MATCH'
    END AS diff_status
FROM prod_hashed p
FULL OUTER JOIN qa_hashed q ON p.customer_id = q.customer_id
ORDER BY customer_id;

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 64:
--
-- 1. Compare step 1's two MINUS queries to step 2's categorized
--    report. Does MINUS alone tell you WHY customer 2 shows up
--    (value changed) versus WHY customer 4 shows up (missing
--    entirely) — or does it just tell you "these rows differ," with
--    no distinction between the two kinds of drift?
--
-- 2. HASH(name, email) folds two columns into a single comparable
--    value. What's the practical benefit of this over writing
--    p.name != q.name OR p.email != q.email by hand, once a real
--    table has 20+ columns instead of 2?
--
-- 3. This comparison assumes customer_id is unique within each table.
--    What would happen to the FULL OUTER JOIN in step 2 if
--    CUSTOMER_QA accidentally had TWO rows with customer_id = 2 —
--    would diff_status still report cleanly, or would something else
--    go wrong first? What would you check before trusting a diff
--    report like this on real data?
-- ============================================================
