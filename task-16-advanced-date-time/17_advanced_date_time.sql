-- ============================================================
-- Task 16 — Advanced date/time manipulation
-- Callback to Task 2: the business-day count below reuses
-- GENERATOR + SEQ4 to build a date spine, the same mechanism you
-- used to synthesize millions of IOT rows.
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;
USE SCHEMA ADVANCED;

CREATE OR REPLACE TABLE SUPPORT_TICKETS (
    ticket_id  INT,
    opened_at  TIMESTAMP_NTZ,
    closed_at  TIMESTAMP_NTZ
);

INSERT INTO SUPPORT_TICKETS (ticket_id, opened_at, closed_at) VALUES
    (1, '2026-06-01 09:00', '2026-06-01 17:00'),  -- same day
    (2, '2026-06-05 09:00', '2026-06-08 10:00'),  -- spans a weekend
    (3, '2026-06-10 08:00', '2026-06-12 14:00');  -- mid-week, no weekend

-- 1. See what day of week each date actually is -- don't take it on
--    faith, look it up. DAYOFWEEKISO is 1=Monday ... 7=Sunday, fixed
--    regardless of session/locale settings (plain DAYOFWEEK's
--    numbering is not).
SELECT
    ticket_id, opened_at, closed_at,
    DAYNAME(opened_at) AS opened_day, DAYNAME(closed_at) AS closed_day
FROM SUPPORT_TICKETS;

-- 2. DATE_TRUNC -- snapping a timestamp down to the start of its
--    week/month, useful for grouping by period.
SELECT
    ticket_id,
    opened_at,
    DATE_TRUNC('WEEK', opened_at)  AS week_start,
    DATE_TRUNC('MONTH', opened_at) AS month_start
FROM SUPPORT_TICKETS;

-- 3. Plain calendar-day/hour diffs -- these count weekends too.
SELECT
    ticket_id,
    DATEDIFF('hour', opened_at, closed_at) AS hours_open,
    DATEDIFF('day',  opened_at, closed_at) AS calendar_days_open
FROM SUPPORT_TICKETS;

-- 4. Business-day count -- Snowflake has no built-in NETWORKDAYS
--    equivalent, so build one: generate one row per calendar day in
--    range (same GENERATOR+SEQ4 pattern as Task 2), then keep only
--    the ones that aren't Saturday/Sunday.
WITH date_spine AS (
    SELECT
        t.ticket_id,
        DATEADD(day, s.seq, DATE_TRUNC('day', t.opened_at)) AS d
    FROM SUPPORT_TICKETS t,
         (SELECT SEQ4() AS seq FROM TABLE(GENERATOR(ROWCOUNT => 30))) s
    WHERE DATEADD(day, s.seq, DATE_TRUNC('day', t.opened_at)) <= DATE_TRUNC('day', t.closed_at)
)
SELECT
    ticket_id,
    COUNT(*) AS business_days_open
FROM date_spine
WHERE DAYOFWEEKISO(d) NOT IN (6, 7)   -- exclude Saturday(6)/Sunday(7)
GROUP BY ticket_id
ORDER BY ticket_id;

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 17:
--
-- 1. Ticket 2 spans a weekend. Compare its calendar_days_open (step
--    3) to its business_days_open (step 4) — by how many days do
--    they differ, and does that number match how many Sat/Sun dates
--    actually fall in its range? Why would reporting calendar days
--    instead of business days on an SLA dashboard be misleading?
--
-- 2. Why DAYOFWEEKISO instead of plain DAYOFWEEK for the weekend
--    filter? Look up what plain DAYOFWEEK's numbering actually
--    depends on, and explain the risk of hardcoding "0 and 6 are
--    the weekend" against it.
--
-- 3. The date spine caps out at ROWCOUNT => 30 days. What would
--    happen to a ticket that's been open 45 days — would the query
--    error, silently undercount, or something else? How would you
--    make GENERATOR's row count robust to tickets of unknown, and
--    potentially large, duration instead of hardcoding a guess?
-- ============================================================
