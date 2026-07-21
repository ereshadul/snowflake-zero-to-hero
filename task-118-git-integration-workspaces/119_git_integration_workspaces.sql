-- ============================================================
-- Task 118 — Git integration with Snowflake Workspaces
-- Category: Ecosystem & Modeling
-- Task 117 deployed SQL FROM GitHub INTO Snowflake via CI. This task
-- is the newer, more direct mechanism: Snowflake itself connects to a
-- git repo, so you develop and version SQL objects natively inside
-- Snowsight, without a separate CI pipeline in between.
-- ============================================================

USE ROLE ACCOUNTADMIN;
USE DATABASE IOT_LAB;

-- 1. An API integration -- Snowflake's equivalent of authorizing
--    outbound access to a specific git provider (GitHub here).
CREATE OR REPLACE API INTEGRATION GITHUB_API_INTEGRATION
    API_PROVIDER = GIT_HTTPS_API
    API_ALLOWED_PREFIXES = ('https://github.com/<your-github-username>/')
    ENABLED = TRUE;

-- 2. A GIT REPOSITORY object -- this is what actually links a
--    Snowflake database object to your real GitHub repo (the SAME
--    ereshadul/snowflake-zero-to-hero repo this whole lab lives in,
--    for instance).
CREATE OR REPLACE GIT REPOSITORY IOT_LAB_GIT_REPO
    API_INTEGRATION = GITHUB_API_INTEGRATION
    ORIGIN = 'https://github.com/<your-github-username>/snowflake-zero-to-hero.git';

-- 3. Fetch the latest commits -- this is Snowflake doing the
--    equivalent of `git fetch`, not a one-time import.
ALTER GIT REPOSITORY IOT_LAB_GIT_REPO FETCH;

-- 4. Browse the repo's files AS STAGE-like objects, directly from SQL
--    -- no separate git client needed inside Snowflake at all.
SHOW GIT BRANCHES IN IOT_LAB_GIT_REPO;
LS @IOT_LAB_GIT_REPO/branches/main;

-- 5. Execute a SQL file straight out of the repo at a specific commit/
--    branch -- this is the core payoff: SQL that lives in git, run
--    directly, no copy-paste into a worksheet, no separate CI step.
EXECUTE IMMEDIATE FROM @IOT_LAB_GIT_REPO/branches/main/task-114-medallion-architecture/115_medallion_architecture.sql;

-- 6. Clean up.
DROP GIT REPOSITORY IOT_LAB_GIT_REPO;
DROP API INTEGRATION GITHUB_API_INTEGRATION;

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 119:
--
-- 1. Step 5's EXECUTE IMMEDIATE FROM pulled a SQL file straight out of
--    a specific branch of the git repo and ran it, with no separate
--    step to download it, paste it, or push it through an external CI
--    runner. Compare that to Task 117's approach (a GitHub Actions
--    workflow that installs SnowSQL and loops over migration files).
--    What infrastructure does Task 117's approach need OUTSIDE
--    Snowflake that this task's approach doesn't?
--
-- 2. Step 3's ALTER GIT REPOSITORY ... FETCH is explicit -- Snowflake
--    does NOT automatically stay in sync with every new commit pushed
--    to GitHub on its own. What would you see in step 4's LS listing
--    if you pushed a brand-new commit to the repo but never ran FETCH
--    again?
--
-- 3. Both Task 117 (GitHub Actions CI) and this task (native git
--    integration) ultimately get SQL from a git repo into Snowflake.
--    For a TEAM used to full CI/CD (PR reviews, automated tests before
--    merge, staged environments), which approach fits more naturally
--    into that existing process, and which is better suited for fast,
--    ad hoc SQL development directly inside Snowsight by an individual
--    engineer?
-- ============================================================
