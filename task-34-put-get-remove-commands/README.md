# Task 34 — PUT/GET/REMOVE file commands

**Category:** Stages & File Management

## Goal
Uploading, downloading, and removing files on a stage with PUT/GET/REMOVE from the command line, instead of Snowsight's upload UI.

## Steps
1. Requires Task 1 already done — `RAW.IOT_STAGE` needs to exist.
2. PUT/GET touch your local filesystem, so this task needs a CLI
   client (SnowSQL or the Snowflake CLI) — a Snowsight worksheet
   can't run PUT/GET.
3. Run `35_put_get_remove_commands.sql`, editing the local file paths
   to match where you cloned this repo.
4. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `35_put_get_remove_commands.sql` — three questions
on AUTO_COMPRESS against an already-compressed file, what PUT checks
to decide whether to skip a re-upload, and why REMOVE's PATTERN
should be scoped to a path prefix.
