# Task 88 — Role hierarchy

**Category:** Security

## About this category — Security
Tasks 88-92 cover who can see and do what — roles, grants, and row-
and column-level restrictions. Every task so far has run as
ACCOUNTADMIN; this category is about not doing that in a real project.

## Goal
How Snowflake's built-in and custom roles nest, and how privilege inheritance flows.

**Real-world scenario:** A "lead analyst" role should have everything
a regular analyst has, plus more — without re-granting every single
privilege twice. Nesting one role inside another gets you that
automatically.

## Steps
1. Run `89_role_hierarchy.sql`, replacing `<your_username>` with your
   real Snowflake username.
2. Work through it section by section against your own Snowflake trial
   — don't just read it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `89_role_hierarchy.sql` — three questions on what
made inheritance work, why anchoring under SYSADMIN matters, and
SHOW GRANTS OF vs. TO.
