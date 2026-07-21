# Task 34 — PUT/GET/REMOVE file commands

**Category:** Stages & File Management

## Goal
Uploading, downloading, and removing files on a stage with PUT/GET/REMOVE from the command line, instead of Snowsight's upload UI.

**Real-world scenario:** A teammate on a headless server or a CI
pipeline needs to push files to a stage — there's no browser, no
Snowsight upload button available at all. PUT/GET are the CLI-native
equivalent, and they're also just faster for anyone comfortable in a
terminal.

**Requires SnowSQL**, not Snowsight — PUT/GET reference your local
file system, which a browser-based worksheet has no access to.

## Steps
1. Install SnowSQL if you don't have it, then connect:
   `snowsql -a <account_identifier> -u <your_username>`.
2. Run `35_put_get_remove_commands.sql` inside that SnowSQL session —
   not in Snowsight.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `35_put_get_remove_commands.sql` — three questions
on OVERWRITE's default behavior, why PUT/GET can't run in Snowsight at
all, and AUTO_COMPRESS against an already-compressed file.
