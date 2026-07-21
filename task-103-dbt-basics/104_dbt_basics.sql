-- ============================================================
-- Task 103 — dbt basics on Snowflake
-- Category: dbt
-- About this category: Tasks 103-113 step outside the Snowflake
-- worksheet. dbt (data build tool) is a separate CLI that compiles
-- Jinja-templated SQL into real statements and runs them against
-- Snowflake -- so most of the "code" in this category is dbt project
-- files (YAML, Jinja SQL), not statements you paste into a worksheet.
-- Each task tells you exactly which file to save where, and which
-- CLI command to run. Verification queries at the end ARE real
-- Snowflake SQL, run in a worksheet as usual.
-- ============================================================

-- 1. Install dbt with the Snowflake adapter (run in your terminal,
--    not in Snowflake):
--
--    pip install dbt-snowflake
--    dbt --version

-- 2. Scaffold a new dbt project (run in your terminal):
--
--    dbt init iot_lab_dbt
--    cd iot_lab_dbt

-- 3. dbt needs to know HOW to connect to Snowflake. This lives in
--    ~/.dbt/profiles.yml (OUTSIDE the project folder, never committed
--    to git -- it's where your credentials live). Save this as
--    ~/.dbt/profiles.yml:
--
-- iot_lab_dbt:
--   target: dev
--   outputs:
--     dev:
--       type: snowflake
--       account: <your_account_locator>
--       user: <your_username>
--       password: <your_password>
--       role: ACCOUNTADMIN
--       database: IOT_LAB
--       warehouse: IOT_LAB_WH
--       schema: DBT_DEV
--       threads: 4

-- 4. dbt_project.yml declares project-wide settings -- save as
--    iot_lab_dbt/dbt_project.yml (dbt init already creates a starter
--    version; replace the "models:" block with this):
--
-- name: 'iot_lab_dbt'
-- version: '1.0.0'
-- profile: 'iot_lab_dbt'
-- model-paths: ["models"]
-- seed-paths: ["seeds"]
-- snapshot-paths: ["snapshots"]
-- macro-paths: ["macros"]
--
-- models:
--   iot_lab_dbt:
--     +materialized: view

-- 5. Confirm dbt can actually reach Snowflake:
--
--    dbt debug
--    -- Expect "All checks passed!" at the end.

-- 6. A first, trivial model -- just to prove the wiring works before
--    building anything real. Save as
--    iot_lab_dbt/models/example/hello_dbt.sql:
--
-- SELECT
--     1 AS id,
--     'hello from dbt' AS message,
--     CURRENT_TIMESTAMP() AS run_at

-- 7. Run it.
--
--    dbt run --select hello_dbt
--    -- dbt compiles the Jinja (there's none here yet), wraps it in a
--    -- CREATE VIEW, and executes it against Snowflake as the role/
--    -- warehouse/schema from your profiles.yml.

-- 8. Verify the result THE NORMAL WAY -- this part IS real Snowflake
--    SQL, run in a worksheet:
USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;
SELECT * FROM DBT_DEV.HELLO_DBT;

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 104:
--
-- 1. Step 3's profiles.yml (with your actual password in it) lives at
--    ~/.dbt/profiles.yml, outside the project folder that gets
--    committed to git in step 2. Why does dbt deliberately split
--    "project code" (dbt_project.yml, models/) from "connection
--    credentials" (profiles.yml) into two different locations instead
--    of one config file?
--
-- 2. Step 7's dbt run compiled hello_dbt.sql and created a VIEW named
--    HELLO_DBT in the DBT_DEV schema (from profiles.yml's `schema:`
--    setting), even though hello_dbt.sql itself never says CREATE VIEW
--    or names a schema anywhere. Where did dbt get the object type
--    (view) and the target schema from?
--
-- 3. dbt_project.yml's `+materialized: view` setting means EVERY model
--    in this project defaults to a view unless overridden. What's the
--    tradeoff between materializing a model as a VIEW (recomputed on
--    every query) versus a TABLE (stored, but needs an explicit rebuild
--    step)? You'll revisit this exact tradeoff with incremental models
--    in Task 109.
-- ============================================================
