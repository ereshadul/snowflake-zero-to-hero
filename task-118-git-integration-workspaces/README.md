# Task 118 — Git integration with Snowflake Workspaces

**Category:** Ecosystem & Modeling

## Goal
Connecting a Snowflake Workspace to a Git repository for native
version-controlled SQL development — a different, newer mechanism
than the GitHub Actions/external-CI approach in Task 117.

**Real-world scenario:** An engineer wants to run a SQL file straight
out of a git branch, at a specific commit, without spinning up a CI
job or copy-pasting into a worksheet. Snowflake's native git
integration does exactly that with `EXECUTE IMMEDIATE FROM`.

**Note:** Replace `<your-github-username>` with your own GitHub
username before running this against a real repo (this lab's own repo
works fine as the target).

## Steps
1. Run `119_git_integration_workspaces.sql`.
2. Work through it section by section against your own Snowflake trial
   — don't just read it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `119_git_integration_workspaces.sql` — three
questions on what infrastructure this avoids versus Task 117's CI
approach, why FETCH is explicit, and which approach fits which team.
