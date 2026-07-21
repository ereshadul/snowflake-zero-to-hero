# Task 62 — Notification Integrations & emailing from Snowflake

**Category:** Programmability

## Goal
Sending email from Snowflake via a Notification Integration and SYSTEM$SEND_EMAIL -- wiring an Alert or Task to actually page someone.

**Real-world scenario:** "Page me if this table's row count ever looks
wrong" — turning a stored procedure's conditional check (Task 61)
into an actual email, instead of a result someone has to remember to
go look at.

## Steps
1. Run `63_notification_integrations_email.sql`, replacing the
   placeholder email address with your own real one.
2. Work through it section by section against your own Snowflake trial
   — don't just read it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `63_notification_integrations_email.sql` — three
questions on the allow-list's purpose, why wrapping the email call in
a procedure matters, and whether this kind of check is ever free.
