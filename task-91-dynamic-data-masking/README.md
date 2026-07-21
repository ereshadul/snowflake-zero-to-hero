# Task 91 — Dynamic data masking

**Category:** Security

## Goal
Masking column values for some roles but not others without duplicating data.

**Real-world scenario:** Support staff need to look up customers by
name but should never see full email addresses — while the data team
that handles GDPR requests needs the real value. One column, one
underlying table, two very different views depending on who's asking.

## Steps
1. Run `92_dynamic_data_masking.sql`, replacing `<your_username>` with
   your real username.
2. Work through it section by section against your own Snowflake trial
   — don't just read it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `92_dynamic_data_masking.sql` — three questions on
where the masking transformation happens, the advantage over a
duplicated masked table, and whether masking affects filtering.
