-- ============================================================
-- Task 108 — dbt macros and Jinja templating
-- Category: dbt
-- Task 107 already wrote one macro (below_max) to define a custom
-- TEST. Macros aren't only for tests -- this task uses one to
-- generate ordinary SQL logic, reused across models.
-- ============================================================

-- 1. Both stg_sensor_readings (Task 104) and any future staging model
--    will keep needing the same "safely cast a string to a number,
--    dropping garbage" pattern. Instead of copy-pasting
--    TRY_TO_DOUBLE(...) everywhere, wrap it in a macro. Save as
--    iot_lab_dbt/macros/safe_cast_numeric.sql:
--
-- {% macro safe_cast_numeric(column_name, precision=38, scale=6) %}
--     TRY_TO_DECIMAL({{ column_name }}, {{ precision }}, {{ scale }})
-- {% endmacro %}

-- 2. Use it inside a model with Jinja's {{ }} call syntax, the same
--    way you've already been calling {{ source(...) }} and
--    {{ ref(...) }}. Update
--    iot_lab_dbt/models/staging/stg_sensor_readings.sql's
--    battery_pct line to:
--
--     {{ safe_cast_numeric('battery_pct', 5, 2) }} AS battery_pct,

-- 3. See the RAW SQL Jinja actually generates, before it's sent to
--    Snowflake -- this is the debugging step people skip and
--    shouldn't:
--
--    dbt compile --select stg_sensor_readings
--    -- Open target/compiled/iot_lab_dbt/models/staging/stg_sensor_readings.sql
--    -- and confirm the macro call was replaced with plain
--    -- TRY_TO_DECIMAL(battery_pct, 5, 2) -- Snowflake never sees Jinja,
--    -- only the compiled-down SQL.

-- 4. Run the model with the macro in place.
--
--    dbt run --select stg_sensor_readings

-- 5. Prove the reuse actually pays off: use the SAME macro on a
--    DIFFERENT column, signal_strength_dbm, right in the same model,
--    with different precision/scale arguments -- one macro definition,
--    two call sites:
--
--     {{ safe_cast_numeric('signal_strength_dbm', 5, 1) }} AS signal_strength_dbm,

-- 6. Verify in Snowflake -- real SQL, run in a worksheet:
USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;
SELECT battery_pct, signal_strength_dbm
FROM DBT_DEV.STG_SENSOR_READINGS
LIMIT 20;

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 109:
--
-- 1. Step 3 had you open the COMPILED SQL file and confirm the macro
--    call was gone, replaced by plain TRY_TO_DECIMAL(...). What does
--    that tell you about what Snowflake itself actually receives when
--    dbt runs a model -- does Snowflake ever see Jinja syntax
--    ({{ }}, {% %}) at all?
--
-- 2. Step 5 called safe_cast_numeric TWICE in the same model with
--    DIFFERENT precision/scale arguments (5,2 for battery_pct vs. 5,1
--    for signal_strength_dbm). If this exact casting pattern were
--    needed in FIVE different staging models across the project, and
--    a bug were later found in the casting logic, how many places
--    would need fixing with the macro versus without it?
--
-- 3. Task 107's below_max macro used {% test %}...{% endtest %} and
--    got used in YAML as a TEST. This task's safe_cast_numeric used
--    {% macro %}...{% endmacro %} and got called inside a SELECT with
--    {{ }}. What's the actual difference in how/where each kind gets
--    invoked -- and is a dbt "test" fundamentally a special kind of
--    macro, or something completely separate under the hood?
-- ============================================================
