-- ============================================================
-- Task 15 — Advanced string and regex functions
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;
USE SCHEMA ADVANCED;

CREATE OR REPLACE TABLE RAW_LOG_LINES (log_line STRING);

INSERT INTO RAW_LOG_LINES (log_line) VALUES
    ('2026-06-01 10:15:32 [INFO] user=alice@example.com action=login status=200'),
    ('2026-06-01 10:16:05 [ERROR] user=bob@example.org action=purchase status=500'),
    ('2026-06-01 10:17:41 [INFO] user=carol@example.com action=logout status=200'),
    ('this line does not match the expected format at all');

-- 1. Extracting several fields out of one unstructured string with
--    REGEXP_SUBSTR. The 'e' parameter + trailing group number tell it
--    to return just the CAPTURED GROUP in parentheses, not the whole
--    match.
SELECT
    log_line,
    REGEXP_SUBSTR(log_line, '^\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}')            AS log_timestamp,
    REGEXP_SUBSTR(log_line, '\\[(\\w+)\\]',        1, 1, 'e', 1) AS log_level,
    REGEXP_SUBSTR(log_line, 'user=([^\\s]+)',      1, 1, 'e', 1) AS user_email,
    REGEXP_SUBSTR(log_line, 'status=(\\d+)',       1, 1, 'e', 1) AS status_code
FROM RAW_LOG_LINES;

-- 2. Pulling the domain out of the extracted email -- SPLIT_PART is
--    the right tool here, not another regex, since the delimiter (@)
--    is fixed and simple.
WITH extracted AS (
    SELECT
        log_line,
        REGEXP_SUBSTR(log_line, 'user=([^\\s]+)', 1, 1, 'e', 1) AS user_email
    FROM RAW_LOG_LINES
)
SELECT
    user_email,
    SPLIT_PART(user_email, '@', 1) AS username,
    SPLIT_PART(user_email, '@', 2) AS domain
FROM extracted
WHERE user_email IS NOT NULL;

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 16:
--
-- 1. Run REGEXP_SUBSTR(log_line, '\\[(\\w+)\\]') on one row WITHOUT
--    the '1, 1, ''e'', 1' arguments. Compare that output to the
--    log_level column above. What's the difference between "the
--    whole match" and "just group 1," concretely, for this pattern?
--
-- 2. The last row in RAW_LOG_LINES doesn't match the expected log
--    format at all. What does every REGEXP_SUBSTR column return for
--    that row — an error, an empty string, or NULL? What does that
--    mean for how you'd detect "how many log lines failed to parse"
--    across a real dataset?
--
-- 3. SPLIT_PART handled the email -> domain split cleanly because '@'
--    is a single, unambiguous, fixed delimiter. Give a concrete
--    example of a string-splitting problem where SPLIT_PART would NOT
--    be enough and you'd genuinely need a regex instead -- what
--    property does the delimiter need to have for SPLIT_PART to stop
--    working?
-- ============================================================
