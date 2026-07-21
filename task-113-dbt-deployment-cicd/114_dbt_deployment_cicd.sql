-- ============================================================
-- Task 113 — dbt deployment and CI/CD for dbt
-- Category: dbt
-- This closes out the dbt category (103-113). Everything so far ran
-- from your own laptop with `dbt run`/`dbt test`. Production dbt
-- projects run on a SCHEDULE, unattended, and get tested automatically
-- before anyone's changes reach production data.
-- ============================================================

-- 1. OPTION A — dbt Cloud: a managed scheduler built for dbt
--    specifically. No YAML pipeline file needed -- configured entirely
--    through dbt Cloud's UI:
--      - Connect the same Snowflake account/warehouse/role from your
--        profiles.yml (dbt Cloud manages the equivalent of that file
--        for you, per environment).
--      - Create a "Job" with commands: dbt build (a superset of
--        dbt run + dbt test + dbt snapshot + dbt seed in dependency
--        order).
--      - Set a schedule (e.g. daily at 5am) or trigger it on every
--        merge to main.
--      - dbt Cloud runs it on ITS OWN infrastructure -- nothing to
--        provision or keep patched yourself.

-- 2. OPTION B — self-hosted, via GitHub Actions: the same `dbt build`
--    command, but you own the runner and the trigger. Save as
--    .github/workflows/dbt_ci.yml in the dbt project's repo:
--
-- name: dbt CI
--
-- on:
--   pull_request:
--     branches: [main]
--   schedule:
--     - cron: '0 5 * * *'   # 5am daily, same idea as dbt Cloud's schedule
--
-- jobs:
--   dbt_build:
--     runs-on: ubuntu-latest
--     steps:
--       - uses: actions/checkout@v4
--       - uses: actions/setup-python@v5
--         with:
--           python-version: '3.11'
--       - run: pip install dbt-snowflake
--       - name: dbt build
--         env:
--           DBT_SNOWFLAKE_ACCOUNT:  ${{ secrets.SNOWFLAKE_ACCOUNT }}
--           DBT_SNOWFLAKE_USER:     ${{ secrets.SNOWFLAKE_USER }}
--           DBT_SNOWFLAKE_PASSWORD: ${{ secrets.SNOWFLAKE_PASSWORD }}
--         run: dbt build --target ci

-- 3. Notice what step 2's workflow does NOT do: it never puts a
--    Snowflake password in the YAML file itself -- only a reference to
--    a GitHub Actions secret, resolved at run time. Configure these as
--    real repo secrets (in GitHub: Settings -> Secrets and variables ->
--    Actions), never committed to git.

-- 4. On a PULL REQUEST (not just main), running `dbt build` against a
--    separate CI target/schema means a broken model or failing test
--    gets caught BEFORE merge, not after it's already changed
--    production data. This is exactly what Task 106's tests and
--    Task 107's custom tests are FOR in a deployed pipeline -- they're
--    not just a local nicety, they're the actual safety gate.

-- 5. Verify in Snowflake after a CI run (or a dbt Cloud job run) --
--    real SQL, run in a worksheet, confirming the automated run
--    actually built something:
USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;
SELECT table_schema, table_name, last_altered
FROM INFORMATION_SCHEMA.TABLES
WHERE table_schema ILIKE 'DBT%'
ORDER BY last_altered DESC;

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 114:
--
-- 1. Step 2's workflow references ${{ secrets.SNOWFLAKE_PASSWORD }}
--    instead of a literal password string. If this workflow file
--    (which IS committed to git and visible to anyone with repo
--    access) contained the actual password instead, what would that
--    expose, and to whom?
--
-- 2. Step 4 argues CI should run against a SEPARATE target/schema, not
--    directly against the same production schema your local `dbt run`
--    writes to. What could go wrong if a pull request's CI run used
--    the SAME target as production, especially for a MODEL that uses
--    materialized='table' (a full CREATE OR REPLACE, not additive)?
--
-- 3. dbt Cloud (option A) and self-hosted GitHub Actions (option B)
--    both ultimately run the same `dbt build` command. What's the
--    actual tradeoff between them -- what do you get "for free" with a
--    managed scheduler that you have to build and maintain yourself
--    with a CI YAML file, and what do you gain in control/cost by
--    self-hosting instead?
-- ============================================================
