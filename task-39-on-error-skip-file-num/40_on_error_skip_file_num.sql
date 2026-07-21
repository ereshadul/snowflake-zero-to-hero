-- ============================================================
-- Task 39 — ON_ERROR = SKIP_FILE_<num>
-- Category: Loading & COPY options
--
-- Reuses fixtures/fixture_mixed.csv from Task 38 -- it has exactly
-- 2 bad rows, which is what makes it possible to sit right on either
-- side of a threshold.
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;

TRUNCATE TABLE RAW.SENSOR_READINGS_STRICT;

-- 1. SKIP_FILE_1 — tolerate at most 1 error. fixture_mixed.csv has 2,
--    which EXCEEDS the tolerance, so the whole file gets skipped,
--    same as plain SKIP_FILE would.
COPY INTO RAW.SENSOR_READINGS_STRICT (
    event_id, sensor_id, device_type, event_timestamp, ingested_at,
    reading_value, unit, battery_pct, signal_strength_dbm,
    latitude, longitude, firmware_version, status_code,
    raw_payload, is_duplicate_of, ingest_batch_id
)
FROM (
    SELECT
        $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13,
        TRY_PARSE_JSON($14), $15, $16
    FROM @RAW.IOT_STAGE/fixture_mixed.csv
)
FILE_FORMAT = (FORMAT_NAME = RAW.IOT_CSV_FORMAT)
ON_ERROR = 'SKIP_FILE_1';

SELECT COUNT(*) AS rows_after_skip_file_1 FROM RAW.SENSOR_READINGS_STRICT;
-- Expect 0.

TRUNCATE TABLE RAW.SENSOR_READINGS_STRICT;

-- 2. SKIP_FILE_3 — tolerate up to 3 errors. fixture_mixed.csv's 2
--    errors are now WITHIN tolerance, so the file loads -- but the 2
--    bad rows themselves are still dropped, same as CONTINUE would
--    drop them.
COPY INTO RAW.SENSOR_READINGS_STRICT (
    event_id, sensor_id, device_type, event_timestamp, ingested_at,
    reading_value, unit, battery_pct, signal_strength_dbm,
    latitude, longitude, firmware_version, status_code,
    raw_payload, is_duplicate_of, ingest_batch_id
)
FROM (
    SELECT
        $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13,
        TRY_PARSE_JSON($14), $15, $16
    FROM @RAW.IOT_STAGE/fixture_mixed.csv
)
FILE_FORMAT = (FORMAT_NAME = RAW.IOT_CSV_FORMAT)
ON_ERROR = 'SKIP_FILE_3';

SELECT COUNT(*) AS rows_after_skip_file_3 FROM RAW.SENSOR_READINGS_STRICT;
-- Expect 8 (the good rows), not 10 and not 0.

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 40:
--
-- 1. Confirm the exact counts: 0 rows with SKIP_FILE_1, 8 rows with
--    SKIP_FILE_3. Explain in one sentence what determines whether a
--    file gets fully skipped versus partially loaded under this
--    ON_ERROR mode -- what's actually being compared to what?
--
-- 2. With SKIP_FILE_3, the 2 genuinely bad rows are gone but the 8
--    good ones made it in -- functionally identical to what CONTINUE
--    would have done for THIS specific file. Given that, what's the
--    actual difference in behavior between SKIP_FILE_3 and CONTINUE,
--    and under what condition would they diverge (hint: think about
--    a file with MORE than 3 errors)?
--
-- 3. If you didn't know in advance how many bad rows a typical
--    incoming file has, how would you pick a sensible threshold
--    number for SKIP_FILE_<num> in a real pipeline — too low and
--    you'd skip files that were mostly fine, too high and you'd
--    silently accept files that are mostly garbage. What would you
--    actually look at (from an earlier task) to make that number a
--    reasoned choice instead of a guess?
-- ============================================================
