-- ============================================================
-- Task 6 — External stage on S3 and COPY INTO from S3
-- Requires Task 5 already done: an S3 bucket, IAM policy, and IAM
-- role (with a placeholder trust policy) must already exist.
-- ============================================================

USE DATABASE IOT_LAB;
USE WAREHOUSE IOT_LAB_WH;

-- 1. Create the STORAGE INTEGRATION. This is what actually generates
--    Snowflake's own AWS identity -- STORAGE_AWS_IAM_USER_ARN and
--    STORAGE_AWS_EXTERNAL_ID come from Snowflake's side, not yours.
CREATE STORAGE INTEGRATION S3_LAB_INTEGRATION
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = 'S3'
  ENABLED = TRUE
  STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::<your-account-id>:role/snowflake-lab-role'
  STORAGE_ALLOWED_LOCATIONS = ('s3://<bucket-name>/iot_lab/');

-- 2. Pull out the two values you need to paste into AWS.
DESCRIBE INTEGRATION S3_LAB_INTEGRATION;
-- Look at the property_value column for these two rows:
--   STORAGE_AWS_IAM_USER_ARN  -> the Principal in your IAM role's trust policy
--   STORAGE_AWS_EXTERNAL_ID   -> the sts:ExternalId condition

-- ------------------------------------------------------------
-- 3. NOW GO BACK TO AWS (this step happens outside Snowflake):
--    IAM -> Roles -> snowflake-lab-role -> Trust relationships -> Edit
--    Replace the placeholder trust policy with:
--
-- {
--   "Version": "2012-10-17",
--   "Statement": [
--     {
--       "Effect": "Allow",
--       "Principal": { "AWS": "<STORAGE_AWS_IAM_USER_ARN from above>" },
--       "Action": "sts:AssumeRole",
--       "Condition": {
--         "StringEquals": { "sts:ExternalId": "<STORAGE_AWS_EXTERNAL_ID from above>" }
--       }
--     }
--   ]
-- }
--
--    This is the moment the trust becomes real: before this edit,
--    the role trusted a placeholder (your own account); after it,
--    the role trusts specifically Snowflake's own generated IAM user,
--    scoped further by the external ID so no OTHER Snowflake account
--    could assume it even if they somehow knew the ARN.
-- ------------------------------------------------------------

-- 4. Create the external stage, pointing at the same S3 path,
--    referencing the integration by name.
CREATE OR REPLACE STAGE RAW.S3_IOT_STAGE
  URL = 's3://<bucket-name>/iot_lab/'
  STORAGE_INTEGRATION = S3_LAB_INTEGRATION
  FILE_FORMAT = RAW.IOT_CSV_FORMAT;  -- reuse the file format from Task 1

-- 5. Confirm Snowflake can actually see into the bucket. If the trust
--    policy edit in step 3 isn't done yet, this fails with an access
--    error -- that's expected, go finish step 3 first.
LIST @RAW.S3_IOT_STAGE;

-- 6. Upload iot_sensor_readings_SAMPLE.csv (from Task 1) into the
--    iot_lab/ folder in your S3 bucket via the AWS Console, then
--    re-run LIST above to confirm it shows up from the Snowflake side.

-- 7. Load it -- the exact same COPY INTO shape as Task 1, just a
--    different stage.
COPY INTO RAW.SENSOR_READINGS_RAW (
    event_id, sensor_id, device_type, event_timestamp, ingested_at,
    reading_value, unit, battery_pct, signal_strength_dbm,
    latitude, longitude, firmware_version, status_code,
    raw_payload, is_duplicate_of, ingest_batch_id, _file_name
)
FROM (
    SELECT
        $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13,
        TRY_PARSE_JSON($14), $15, $16, METADATA$FILENAME
    FROM @RAW.S3_IOT_STAGE/iot_sensor_readings_SAMPLE.csv
)
FILE_FORMAT = (FORMAT_NAME = RAW.IOT_CSV_FORMAT)
ON_ERROR = 'CONTINUE';

SELECT COUNT(*) AS rows_from_s3 FROM RAW.SENSOR_READINGS_RAW;

-- ============================================================
-- UNDERSTANDING CHECK — answer before moving to Task 7:
--
-- 1. STORAGE_AWS_EXTERNAL_ID exists specifically to prevent a
--    security problem called the "confused deputy" problem. Look up
--    what that term means, and explain in your own words what attack
--    it prevents here -- what could a different, malicious Snowflake
--    account try to do if the external ID condition didn't exist?
--
-- 2. Compare this stage's DDL to RAW.IOT_STAGE from Task 1. What's
--    the exact syntactic difference between an internal and an
--    external stage's CREATE STAGE statement? (Hint: it's not just
--    the URL.)
--
-- 3. If you rotate/regenerate your IAM role in AWS (delete and
--    recreate it with the same name), does the existing
--    STORAGE INTEGRATION in Snowflake keep working, or does something
--    break? What does that tell you about what Snowflake actually
--    stored when you ran CREATE STORAGE INTEGRATION -- the role ARN
--    as a string, or something deeper tied to the role's identity?
-- ============================================================
