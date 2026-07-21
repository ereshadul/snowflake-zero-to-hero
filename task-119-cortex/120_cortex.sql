-- ============================================================
-- Task 119 — Snowflake Cortex
-- Category: Ecosystem & Modeling
-- Cortex functions are ordinary SQL functions -- they run inline in a
-- SELECT like any UDF from Task 60, except the "function body" is a
-- hosted LLM instead of your own code.
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;
USE SCHEMA ADVANCED;

-- 1. A small table of free-text maintenance notes -- the kind of
--    unstructured field that shows up next to structured sensor data
--    in almost every real IoT system.
CREATE OR REPLACE TABLE MAINTENANCE_NOTES (
    note_id  INT,
    sensor_id STRING,
    note_text STRING
);

INSERT INTO MAINTENANCE_NOTES (note_id, sensor_id, note_text) VALUES
    (1, 'SENSOR_00001', 'Technician replaced battery, unit reading normally again, no further issues expected.'),
    (2, 'SENSOR_00002', 'URGENT: sensor housing cracked after storm damage, readings unreliable, needs replacement ASAP.'),
    (3, 'SENSOR_00003', 'Routine firmware update applied, no anomalies observed during testing.');

-- 2. COMPLETE -- a general-purpose LLM call, inline in SQL.
SELECT
    note_id,
    note_text,
    SNOWFLAKE.CORTEX.COMPLETE(
        'llama3.1-8b',
        'Summarize this maintenance note in under 10 words: ' || note_text
    ) AS summary
FROM MAINTENANCE_NOTES;

-- 3. SENTIMENT -- a purpose-built function returning a numeric score,
--    not free text, so it's directly usable in a WHERE/ORDER BY.
SELECT
    note_id,
    note_text,
    SNOWFLAKE.CORTEX.SENTIMENT(note_text) AS sentiment_score
FROM MAINTENANCE_NOTES
ORDER BY sentiment_score ASC;
-- Expect the "URGENT... cracked... unreliable" note to score most
-- negative.

-- 4. CLASSIFY_TEXT -- forcing the model to pick from YOUR categories,
--    not generate free-form text, so the result is safe to GROUP BY.
SELECT
    note_id,
    note_text,
    SNOWFLAKE.CORTEX.CLASSIFY_TEXT(
        note_text,
        ['routine', 'needs_attention', 'urgent']
    ):label::STRING AS urgency_class
FROM MAINTENANCE_NOTES;

-- 5. Clean up.
DROP TABLE MAINTENANCE_NOTES;

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 120:
--
-- 1. Step 2's COMPLETE call and Task 60's UDFs are both invoked inline
--    inside a SELECT, once per row. What's fundamentally DIFFERENT
--    about what runs when Snowflake evaluates COMPLETE versus when it
--    evaluates a UDF you wrote yourself -- is COMPLETE's "body" SQL/
--    Python code at all, or something else entirely?
--
-- 2. Step 3's SENTIMENT returns a plain NUMBER, while step 2's COMPLETE
--    returns free-form STRING text. Why does returning a constrained,
--    numeric/categorical result (SENTIMENT, CLASSIFY_TEXT) make a
--    function's output more directly usable in a WHERE clause,
--    ORDER BY, or GROUP BY than COMPLETE's open-ended text output?
--
-- 3. Every note in MAINTENANCE_NOTES never left Snowflake's own
--    governed environment to be summarized/classified -- no separate
--    API call to an external LLM provider, no data leaving the
--    account's security boundary. Why does that matter specifically
--    for a company with sensitive customer or operational data that
--    legal/compliance would otherwise be nervous about sending to a
--    third-party AI API?
-- ============================================================
