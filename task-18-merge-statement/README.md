# Task 18 — MERGE statement deep dive

**Category:** Advanced Snowflake SQL

## Goal
Upsert logic in one statement -- WHEN MATCHED/NOT MATCHED, and the gotchas around matching more than one row.

**Real-world scenario:** Every day you get a batch of customer
records — some brand new, some existing customers with an updated
email. Instead of writing separate INSERT and UPDATE statements (and
figuring out which rows go where yourself), MERGE does both in one
statement. But the moment your source batch has an accidental
duplicate key, MERGE won't quietly guess — it fails loudly, which is
usually the behavior you want in production.

## Steps
1. Run `19_merge_statement.sql`.
2. Work through it section by section against your own Snowflake trial
   — don't just read it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `19_merge_statement.sql` — three questions on what
MERGE can't do (delete rows missing from the source), why duplicate
source keys cause a hard failure, and how to prevent that upstream.
