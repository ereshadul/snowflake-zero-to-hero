# Task 5 — AWS S3 + IAM setup for Snowflake

**Category:** AWS Integration

## Goal
Creating an S3 bucket and the IAM policy/role Snowflake needs to read
from it — the prerequisite plumbing before any `STORAGE INTEGRATION`
can exist. This task is entirely AWS Console work; Task 6 is where you
come back to Snowflake and actually wire it up.

## Why this is two steps, not one
Snowflake and AWS have to trust each other, but neither side has the
other's identity yet at the start. The dance is:
1. **(This task)** You create an S3 bucket and an IAM role, with a
   *placeholder* trust policy — you don't know Snowflake's identity
   yet, so you can't finish it.
2. **(Task 6)** You create a `STORAGE INTEGRATION` in Snowflake, which
   generates a Snowflake-owned AWS IAM user ARN and an external ID.
3. **(Task 6)** You go back to AWS and update the IAM role's trust
   policy with those two values — *now* the role actually trusts
   Snowflake specifically, not a placeholder.

Skipping straight to a "finished" trust policy isn't possible — Task 6
literally can't happen until this task's role exists, and this task's
role isn't usable until Task 6 supplies the values it's missing.

## Steps

### 1. Create the S3 bucket
1. AWS Console → **S3** → **Create bucket**.
2. Name it something unique, e.g. `<your-name>-snowflake-lab`.
3. Region: pick one and **write it down** — Task 6's `STORAGE
   INTEGRATION` must specify a stage URL in this same bucket/region.
4. Leave "Block all public access" **checked** — Snowflake never needs
   the bucket to be public, only the IAM role needs access.
5. Create a folder inside it called `iot_lab/` — this is where you'll
   land files for Task 6.

### 2. Create the IAM policy
AWS Console → **IAM** → **Policies** → **Create policy** → JSON tab,
paste this (replace `<bucket-name>`):

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "SnowflakeObjectAccess",
      "Effect": "Allow",
      "Action": ["s3:GetObject", "s3:GetObjectVersion"],
      "Resource": "arn:aws:s3:::<bucket-name>/iot_lab/*"
    },
    {
      "Sid": "SnowflakeListBucket",
      "Effect": "Allow",
      "Action": ["s3:ListBucket", "s3:GetBucketLocation"],
      "Resource": "arn:aws:s3:::<bucket-name>",
      "Condition": {
        "StringLike": { "s3:prefix": ["iot_lab/*"] }
      }
    }
  ]
}
```

Name it e.g. `snowflake-lab-s3-access`. Notice this is scoped to
exactly the `iot_lab/` prefix, not the whole bucket — least privilege,
the same principle Task 88 (Role hierarchy) covers on the Snowflake
side.

### 3. Create the IAM role
1. IAM → **Roles** → **Create role** → trusted entity type: **AWS
   account** → choose **Another AWS account** → for now, enter **your
   own** account ID as a temporary placeholder (you'll overwrite this
   in Task 6 — Snowflake's real IAM user doesn't exist until you run
   `CREATE STORAGE INTEGRATION`).
2. Attach the `snowflake-lab-s3-access` policy from step 2.
3. Name the role e.g. `snowflake-lab-role`.
4. Copy the role's **ARN** (`arn:aws:iam::<account-id>:role/snowflake-lab-role`)
   — you'll need it in Task 6.

## Understanding check
1. Why can't you write the IAM role's *final* trust policy in this
   task? What specific piece of information is Snowflake-generated
   and doesn't exist until `CREATE STORAGE INTEGRATION` runs?
2. The IAM policy above scopes `s3:GetObject` to `iot_lab/*` but
   `s3:ListBucket` needs the bucket ARN *without* a path, using a
   `Condition` block instead. Why can't `s3:ListBucket` be scoped the
   same simple way as `s3:GetObject`?
3. If you'd left "Block all public access" unchecked and made the
   bucket public instead of using an IAM role at all, what would
   Snowflake's `STORAGE INTEGRATION` step look different, and why is
   the IAM role approach still what real companies use even though a
   public bucket would technically also work?
