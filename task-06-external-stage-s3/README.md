# Task 6 — External stage on S3 and COPY INTO from S3

**Category:** AWS Integration

## Goal
Creating a STORAGE INTEGRATION and an external stage pointed at S3, then loading data with the same COPY INTO you already know from Task 1 -- the one deliberate exception to this repo's no-external-cloud rule, kept to exactly these two tasks.

## Steps
1. Requires Task 5 already done — the S3 bucket, IAM policy, and IAM
   role (with its placeholder trust policy) must already exist.
2. Run `07_external_stage_s3.sql` section by section — it's not a
   single run-and-done script. Partway through, it tells you to switch
   over to the AWS Console and paste Snowflake-generated values into
   your IAM role's trust policy before continuing.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `07_external_stage_s3.sql` — three questions on the
confused-deputy problem `STORAGE_AWS_EXTERNAL_ID` prevents, the
internal-vs-external stage DDL difference, and what happens if you
rotate the underlying IAM role.
