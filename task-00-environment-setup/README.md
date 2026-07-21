# Task 0 — Environment setup: Snowflake trial + AWS account

**Category:** Foundations

## Goal
Get both accounts this whole repo assumes you already have: a
Snowflake trial (needed for every task) and an AWS free-tier account
(needed only for Tasks 5-6, AWS Integration — nothing else in the
roadmap touches AWS). Do this once, now, so nothing later stalls out
on a signup flow.

## Steps

### 1. Snowflake trial account
1. Go to signup.snowflake.com and register with your email.
2. Pick a **cloud provider and region** when prompted (AWS, Azure, or
   GCP — doesn't matter which for 99% of this repo; pick AWS if you
   want your Snowflake account and your Task 5-6 S3 bucket in the same
   cloud, which makes the region-matching in Task 6 simpler).
3. Choose the **Standard** edition — no need for Enterprise/Business
   Critical features anywhere in this roadmap.
4. Verify your email, set a password, and log in. You should land in
   **Snowsight** (the web UI) — if you instead see the old classic
   console, look for a prompt to switch to Snowsight; every task here
   assumes Snowsight.
5. Confirm your role in the top-right shows **ACCOUNTADMIN** — that's
   the role used throughout this repo (a real project would use
   least-privilege custom roles instead; see Task 88's Role hierarchy
   task for why).
6. Sanity check: open a new Worksheet and run `SELECT CURRENT_VERSION();`
   — if that returns a version string, you're set.

### 2. AWS free-tier account (only needed for Tasks 5-6)
1. Go to aws.amazon.com and create a free-tier account (requires a
   card for identity verification, but S3 usage at the scale these
   two tasks need stays within the free tier).
2. Once logged into the AWS Console, note your **AWS account ID**
   (top-right menu) — you'll need it in Task 5 to write the S3 bucket
   policy that trusts Snowflake's IAM user.
3. Note which **AWS region** you created resources in by default
   (e.g. `us-east-1`) — Task 6's `STORAGE INTEGRATION` needs to match
   this.
4. If you don't want AWS involved at all, that's fine — skip Tasks 5-6
   entirely and jump to Task 7. Nothing later in the roadmap depends
   on them.

## Understanding check
1. Why does this repo default to `ACCOUNTADMIN` for every task instead
   of a scoped custom role, and what would you change before doing
   this against a real production account instead of a trial?
2. Task 6 needs your S3 bucket's region to match something on the
   Snowflake side. Which Snowflake account property is that, and where
   do you find it in Snowsight?
3. Free-tier AWS accounts still bill you if you exceed the free
   allowance. What single setting would you configure right now, before
   Task 5, to make sure a mistake in these two tasks can't quietly
   rack up a real AWS bill?

*(Status: written — no SQL file for this task, it's pure account
setup.)*
