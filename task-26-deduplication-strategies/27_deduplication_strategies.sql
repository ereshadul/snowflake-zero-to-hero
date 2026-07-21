-- ============================================================
-- Task 26 — Deduplication strategies
-- Two DIFFERENT kinds of "duplicate" on purpose: customer 1 has a
-- true exact-duplicate row, customer 2 has two DIFFERENT rows that
-- share the same business key (an updated email arrived later).
-- These need different techniques to fix.
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;
USE SCHEMA ADVANCED;

CREATE OR REPLACE TABLE CUSTOMER_RAW (
    customer_id INT,
    email       STRING,
    loaded_at   TIMESTAMP_NTZ
);
INSERT INTO CUSTOMER_RAW (customer_id, email, loaded_at) VALUES
    (1, 'alice@example.com', '2026-06-01 08:00'),
    (1, 'alice@example.com', '2026-06-01 08:00'),  -- exact duplicate row
    (2, 'bob@example.com',   '2026-06-01 09:00'),
    (2, 'bob@new.com',       '2026-06-02 10:00'),  -- same customer, updated email, arrived later
    (3, 'carol@example.com', '2026-06-01 07:00');

-- 1. Detect duplicates first (diagnostic, doesn't remove anything).
SELECT customer_id, email, loaded_at, COUNT(*) AS cnt
FROM CUSTOMER_RAW
GROUP BY customer_id, email, loaded_at
HAVING COUNT(*) > 1;

-- 2. DISTINCT removes only EXACT, full-row duplicates.
SELECT DISTINCT * FROM CUSTOMER_RAW ORDER BY customer_id, loaded_at;

-- 3. ROW_NUMBER-based dedup: keep only the LATEST row per customer_id
--    — this is a "same business key" dedup, not a "same exact row"
--    dedup, and it's the one DISTINCT structurally cannot do.
SELECT * FROM (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY loaded_at DESC) AS rn
    FROM CUSTOMER_RAW
)
WHERE rn = 1
ORDER BY customer_id;

-- 4. The same thing, using QUALIFY (Task 17) instead of a subquery.
SELECT customer_id, email, loaded_at
FROM CUSTOMER_RAW
QUALIFY ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY loaded_at DESC) = 1
ORDER BY customer_id;

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 27:
--
-- 1. After DISTINCT (step 2), customer 1 shows ONE row but customer 2
--    still shows TWO rows. Explain precisely why DISTINCT can't touch
--    customer 2's rows at all — what would need to be true about
--    those two rows for DISTINCT to collapse them?
--
-- 2. Step 3's ROW_NUMBER approach gives exactly one row per
--    customer_id (1, 2, and 3), including correctly picking bob@new.com
--    over bob@example.com. What definition of "duplicate" is this
--    using instead of DISTINCT's "identical row" definition?
--
-- 3. Steps 3 and 4 produce the same result, one via subquery + WHERE,
--    one via QUALIFY. Which would you actually write day to day, and
--    does this connect to the specific reason QUALIFY exists (recall
--    Task 17) — what does QUALIFY let you skip here that the
--    subquery version needs?
-- ============================================================
