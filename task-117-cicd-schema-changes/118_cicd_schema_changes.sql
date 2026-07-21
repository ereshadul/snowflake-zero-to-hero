-- ============================================================
-- Task 117 — CI/CD for schema changes
-- Category: Ecosystem & Modeling
-- Task 113 covered CI/CD for dbt MODELS specifically. This task is
-- broader: deploying plain SQL schema changes (DDL migrations) that
-- have nothing to do with dbt, through GitHub Actions instead of
-- someone hand-running a worksheet.
-- ============================================================

-- 1. A numbered migration file, exactly the kind of change you'd
--    otherwise paste into a worksheet by hand. Save as
--    migrations/003_add_maintenance_flag.sql in a plain (non-dbt) repo:
--
-- ALTER TABLE IOT_LAB.CURATED.SENSOR_CURRENT_STATE
--     ADD COLUMN IF NOT EXISTS under_maintenance BOOLEAN DEFAULT FALSE;

-- 2. A GitHub Actions workflow that runs migration files against
--    Snowflake using the SnowSQL CLI, triggered on merge to main. Save
--    as .github/workflows/schema_migrations.yml:
--
-- name: Deploy schema migrations
--
-- on:
--   push:
--     branches: [main]
--     paths:
--       - 'migrations/**.sql'
--
-- jobs:
--   deploy:
--     runs-on: ubuntu-latest
--     steps:
--       - uses: actions/checkout@v4
--       - name: Install SnowSQL
--         run: |
--           curl -O https://sfc-repo.snowflakecomputing.com/snowsql/bootstrap/1.2/linux_x86_64/snowsql-1.2.28-linux_x86_64.bash
--           SNOWSQL_DEST=~/snowsql SNOWSQL_LOGIN_SHELL=~/.profile bash snowsql-1.2.28-linux_x86_64.bash
--       - name: Run pending migrations
--         env:
--           SNOWSQL_ACCOUNT:  ${{ secrets.SNOWFLAKE_ACCOUNT }}
--           SNOWSQL_USER:     ${{ secrets.SNOWFLAKE_USER }}
--           SNOWSQL_PWD:      ${{ secrets.SNOWFLAKE_PASSWORD }}
--         run: |
--           for f in migrations/*.sql; do
--             ~/snowsql/snowsql -q "!source $f" -o exit_on_error=true
--           done

-- 2b. This same idea works with GitHub Actions' native Snowflake CLI
--    action too (snowflake-labs/snowflake-cli), which is newer and
--    less brittle than raw SnowSQL bootstrap scripting -- worth
--    knowing both exist.

-- 3. The migration NEEDS to be safely re-runnable -- notice step 1
--    used ADD COLUMN IF NOT EXISTS, not a bare ADD COLUMN. Prove to
--    yourself why that matters by running the same statement twice in
--    a worksheet:
USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;
ALTER TABLE CURATED.SENSOR_CURRENT_STATE
    ADD COLUMN IF NOT EXISTS under_maintenance BOOLEAN DEFAULT FALSE;
-- Run this exact statement again -- confirm it does NOT error the
-- second time, unlike a bare ADD COLUMN would.
ALTER TABLE CURATED.SENSOR_CURRENT_STATE
    ADD COLUMN IF NOT EXISTS under_maintenance BOOLEAN DEFAULT FALSE;

-- 4. Verify and clean up.
DESCRIBE TABLE CURATED.SENSOR_CURRENT_STATE;
ALTER TABLE CURATED.SENSOR_CURRENT_STATE DROP COLUMN under_maintenance;

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 118:
--
-- 1. Step 3 ran the exact same ALTER TABLE ... ADD COLUMN IF NOT
--    EXISTS statement twice. What actually happened the second time --
--    an error, or a silent no-op? Why does a migration script meant to
--    run automatically in CI need to tolerate being accidentally
--    re-run, in a way a one-off worksheet paste doesn't have to worry
--    about?
--
-- 2. Step 2's workflow triggers on push to main, filtered to changes
--    under migrations/**.sql specifically. What would happen if that
--    path filter were removed entirely -- would every unrelated commit
--    to the repo (a README typo fix, say) also try to re-run every
--    migration file?
--
-- 3. Compare this task's approach (plain numbered .sql migration files,
--    run in order via a CI script) to Task 113's dbt-managed CI/CD
--    (dbt build, using dbt's own dependency graph and state tracking).
--    What does dbt give you for free here that a bare "loop over .sql
--    files" approach does NOT -- specifically around knowing what's
--    already been applied and skipping it versus re-running everything
--    every time?
-- ============================================================
