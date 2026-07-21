-- ============================================================
-- Task 92 — Network policies (conceptual)
-- Category: Security
-- Completes this category.
--
-- SAFETY NOTE, read before running anything: this task deliberately
-- NEVER applies a network policy to your account or your own user.
-- Doing that with a misconfigured IP list can lock you out of your
-- OWN Snowflake trial entirely -- there's no "undo" from outside the
-- account once you can no longer log in. Everything below only
-- creates and inspects a policy object; it never activates one.
-- ============================================================

USE ROLE ACCOUNTADMIN;

-- 1. A deliberately wide-open policy -- 0.0.0.0/0 allows EVERY IP,
--    so even if this were somehow applied, it would restrict nothing.
--    This exists purely to demonstrate the syntax safely.
CREATE OR REPLACE NETWORK POLICY DEMO_NETWORK_POLICY
    ALLOWED_IP_LIST = ('0.0.0.0/0');

SHOW NETWORK POLICIES;
DESCRIBE NETWORK POLICY DEMO_NETWORK_POLICY;

-- 2. See your OWN actual client IP from recent login history -- this
--    is the real, practical prerequisite before anyone builds a
--    genuinely restrictive allow-list: you must know your own IP(s)
--    first, or you WILL lock yourself out.
SELECT CLIENT_IP, EVENT_TIMESTAMP
FROM SNOWFLAKE.ACCOUNT_USAGE.LOGIN_HISTORY
ORDER BY EVENT_TIMESTAMP DESC
LIMIT 5;

-- 3. Clean up -- this policy was never attached to anything.
DROP NETWORK POLICY DEMO_NETWORK_POLICY;

-- Deliberately NOT included, and not to be run against your own
-- trial account:
--   ALTER ACCOUNT SET NETWORK_POLICY = DEMO_NETWORK_POLICY;
--   ALTER USER <you> SET NETWORK_POLICY = DEMO_NETWORK_POLICY;

-- ============================================================
-- UNDERSTANDING CHECK — this closes out the Security category:
--
-- 1. Why does this task deliberately avoid ever running
--    ALTER ACCOUNT/ALTER USER ... SET NETWORK_POLICY, even against a
--    wide-open (0.0.0.0/0) policy? What's the actual worst-case risk
--    if someone practiced this exact workflow with a genuinely
--    restrictive IP list instead?
--
-- 2. Look at your own CLIENT_IP from step 2. If you WERE going to
--    build a real restrictive ALLOWED_IP_LIST for your own user, what
--    would you need to include to avoid locking yourself out? Why is
--    a home or office internet connection's typically-dynamic IP
--    address a genuine practical problem for this feature?
--
-- 3. Network policies can be applied at the ACCOUNT level (affects
--    every user) or at the USER level (affects just one person). Why
--    would a company almost always test a brand-new network policy on
--    a single test user first, rather than applying it account-wide
--    immediately?
-- ============================================================
