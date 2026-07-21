-- ============================================================
-- Task 62 — Notification Integrations & emailing from Snowflake
-- Category: Programmability
-- Completes the Programmability category. Combines with Task 61's
-- procedural control flow to build a real "check a condition, page
-- someone if it's bad" pattern.
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;
USE SCHEMA ADVANCED;

-- 1. A Notification Integration -- the object that actually knows how
--    to send email, scoped to an explicit allow-list of recipients.
--    Replace with your own real email address.
CREATE NOTIFICATION INTEGRATION IF NOT EXISTS EMAIL_ALERT_INT
    TYPE = EMAIL
    ENABLED = TRUE
    ALLOWED_RECIPIENTS = ('your_email@example.com');

-- 2. A direct, one-off test.
CALL SYSTEM$SEND_EMAIL(
    'EMAIL_ALERT_INT',
    'your_email@example.com',
    'Test email from Snowflake',
    'This is a test notification sent via SYSTEM$SEND_EMAIL.'
);

-- 3. Wrap it in a stored procedure with real conditional logic (Task
--    61's pattern) -- only actually send email if a condition is met.
CREATE OR REPLACE PROCEDURE ALERT_IF_OVER_THRESHOLD(threshold INT)
RETURNS STRING
LANGUAGE SQL
AS
$$
DECLARE
    row_count INT;
BEGIN
    SELECT COUNT(*) INTO :row_count FROM GAME_SCORES;
    IF (:row_count > :threshold) THEN
        CALL SYSTEM$SEND_EMAIL(
            'EMAIL_ALERT_INT',
            'your_email@example.com',
            'Row count alert',
            'GAME_SCORES has ' || :row_count || ' rows, exceeding threshold ' || :threshold || '.'
        );
        RETURN 'Alert sent';
    ELSE
        RETURN 'No alert needed';
    END IF;
END;
$$;

CALL ALERT_IF_OVER_THRESHOLD(5);
CALL ALERT_IF_OVER_THRESHOLD(1000);

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 63:
--
-- 1. Try calling SYSTEM$SEND_EMAIL with a recipient address that is
--    NOT in EMAIL_ALERT_INT's ALLOWED_RECIPIENTS list. What happens?
--    What real-world risk does that allow-list protect against?
--
-- 2. Compare step 2 (a bare, unconditional SYSTEM$SEND_EMAIL call) to
--    step 3 (the same call, wrapped inside a procedure with an IF
--    check). What does wrapping it in a procedure let you do that
--    calling SYSTEM$SEND_EMAIL directly, every time, can't — connect
--    this back to Task 61's point about procedural control flow.
--
-- 3. To actually run ALERT_IF_OVER_THRESHOLD automatically (not by
--    hand), you'd wire it into either a Task on a schedule, or a
--    native Snowflake ALERT object with its own IF/THEN clause. Does
--    checking "how many rows are in GAME_SCORES" ever come for free,
--    the way a Task's WHEN SYSTEM$STREAM_HAS_DATA check does — or
--    does this kind of condition always cost warehouse compute to
--    evaluate, no matter which wrapper you choose?
-- ============================================================
