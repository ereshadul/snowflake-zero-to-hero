-- ============================================================
-- Task 87 — Retention & storage cost
-- Category: Time Travel & cloning
-- Completes this category. Reuses PERMANENT_DEMO and TRANSIENT_DEMO
-- from Task 35 specifically to contrast their Fail-safe storage.
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;
USE SCHEMA ADVANCED;

-- 1. Check and set DATA_RETENTION_TIME_IN_DAYS explicitly.
SHOW PARAMETERS LIKE 'DATA_RETENTION_TIME_IN_DAYS' IN TABLE GAME_SCORES;

ALTER TABLE GAME_SCORES SET DATA_RETENTION_TIME_IN_DAYS = 5;

-- 2. Actual storage breakdown per table -- active data vs. Time
--    Travel vs. Fail-safe, broken out separately. (ACCOUNT_USAGE views
--    can lag by a few hours -- if these come back empty, that's why.)
SELECT TABLE_NAME, ACTIVE_BYTES, TIME_TRAVEL_BYTES, FAILSAFE_BYTES
FROM SNOWFLAKE.ACCOUNT_USAGE.TABLE_STORAGE_METRICS
WHERE TABLE_SCHEMA = 'ADVANCED'
  AND TABLE_NAME IN ('PERMANENT_DEMO', 'TRANSIENT_DEMO')
ORDER BY TABLE_NAME;

-- 3. Set retention to the minimum for a table you don't need history
--    on at all.
ALTER TABLE GAME_SCORES SET DATA_RETENTION_TIME_IN_DAYS = 0;

-- ============================================================
-- UNDERSTANDING CHECK — this closes out the Time Travel & cloning
-- category:
--
-- 1. Compare FAILSAFE_BYTES between PERMANENT_DEMO and TRANSIENT_DEMO
--    in step 2's results. Does the transient table show 0 regardless
--    of anything you've done to it, confirming TRANSIENT tables never
--    get Fail-safe at all — not just a shorter window, but genuinely
--    none?
--
-- 2. Step 3 sets GAME_SCORES's retention to 0, disabling Time Travel
--    queries (AT/BEFORE) against it going forward. Does this
--    immediately erase whatever TIME_TRAVEL_BYTES it had already
--    accrued under the PREVIOUS 5-day setting from step 1, or does
--    that existing history simply age out on its own schedule?
--
-- 3. Given everything in this category depends on Time Travel
--    existing (UNDROP, AT/BEFORE, clone-from-the-past), what's the
--    real tradeoff of setting DATA_RETENTION_TIME_IN_DAYS = 0 on a
--    table? Looking back at Task 35's staging-table discussion, which
--    of this repo's OWN tables would 0 actually be a reasonable
--    choice for, and which would you never do that to?
-- ============================================================
