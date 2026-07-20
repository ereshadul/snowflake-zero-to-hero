# Snowflake Sr. DB Engineer — Hands-On Lab

Environment setup + hands-on tasks for going from "knows SQL" to
comfortable running real things in Snowflake. Each task folder is
self-contained: run its SQL against your own Snowflake trial, then
answer the understanding questions in its README before moving on —
they're not optional, they're where the actual learning happens.

## Prerequisites
- A Snowflake trial account (free, sign up at snowflake.com).
- Basic SQL (joins, aggregates, subqueries). No prior Snowflake
  experience assumed.
- A browser. That's it — **no AWS/Azure/GCP account needed**. Every
  task here uses Snowflake's internal stage and native compute only,
  on purpose.
- Python 3 locally only if you want to regenerate the CSV in Task 1
  yourself instead of using the sample.

## Tasks
91 tasks total, one atomic concept each, grouped into 18 categories,
ordered so foundational concepts (stages, table types, constraints)
come before the things that depend on them. Tasks 1-4 are fully
written; the rest are scaffolded (README + SQL stub with a goal and
TODOs) and get filled in as we work through them — see the open
[issues](../../issues) for tracking (issue numbers/titles predate this
reordering and reference the old task numbers — the folder paths in
each issue body are still accurate).

Tasks 5-9 and 32-36 were added after cross-checking the roadmap
against a set of real Snowflake interview questions, then moved up to
sit right after the initial hands-on tasks since they're prerequisite
knowledge (stages, table types, constraints), not advanced topics.
Tasks 54, 76, 77, 80, and 82 were added after reviewing a course on
data modeling/architecture patterns. Deliberately excluded throughout:
anything requiring an AWS/Azure/GCP account (storage integrations,
external stages) and third-party orchestrators like Airflow — both
are out of scope per this repo's no-external-cloud, Snowflake-native
design.

| # | Folder | What it covers |
|---|--------|----------------|
| 1 | `task-01-upload-csv/` | Internal stages, file formats, `COPY INTO`, `ON_ERROR`/`VALIDATION_MODE`, loading messy real-world data |
| 2 | `task-02-generate-huge-data/` | `GENERATOR()`/`SEQ4()` — synthesizing large datasets with pure SQL, no file needed |
| 3 | `task-03-scheduler-continuous-data/` | Snowflake Tasks — scheduling SQL to run repeatedly, warehouse/cost implications |
| 4 | `task-04-on-error-abort-statement/` | `ON_ERROR = ABORT_STATEMENT` — the default, and why strict typing makes it bite |
| 5-6 | `task-05-*` … `task-06-*` | Stages & File Management — internal stage types (user/table/named), `PUT`/`GET`/`REMOVE` commands |
| 7-9 | `task-07-*` … `task-09-*` | Table & Data Fundamentals — PERMANENT vs. TRANSIENT vs. TEMPORARY tables, constraint enforcement, primary key generation |
| 10-20 | `task-10-*` … `task-20-*` | Loading & `COPY INTO` options — `ON_ERROR` variants, `RETURN_FAILED_ONLY`, `SIZE_LIMIT`, `TRUNCATECOLUMNS`, `FORCE`, `PATTERN`, `PURGE`, load history, transforming data mid-COPY |
| 21-26 | `task-21-*` … `task-26-*` | Semi-structured data — `OBJECT`, `ARRAY`, `VARIANT`, `FLATTEN`, querying Parquet directly |
| 27-31 | `task-27-*` … `task-31-*` | Unloading data — CSV/JSON/Parquet unload, unload options, partitioned unload |
| 32-34 | `task-32-*` … `task-34-*` | Programmability — UDF basics & supported languages, stored procedures vs. UDFs, Notification Integrations & emailing from Snowflake |
| 35-36 | `task-35-*` … `task-36-*` | Data Quality — comparing two tables for drift, a repeatable validation framework |
| 37-40 | `task-37-*` … `task-40-*` | Snowpipe — internal-stage pipe, auto-ingest vs. manual refresh, monitoring, cost |
| 41-48 | `task-41-*` … `task-48-*` | Streams — STANDARD/APPEND-ONLY, stream+task CDC, streams on views/multiple tables, change-tracking columns, `CHANGE_TRACKING`/`CHANGES()` as a Streams alternative |
| 49-54 | `task-49-*` … `task-54-*` | Tasks, deeper — triggered tasks, DAGs, `WHEN`, monitoring, serverless vs. warehouse-backed, incremental load strategy |
| 55-59 | `task-55-*` … `task-59-*` | Time Travel & cloning — `AT`/`BEFORE`, `UNDROP`, zero-copy clone, retention & storage cost |
| 60-64 | `task-60-*` … `task-64-*` | Security — role hierarchy, custom roles/grants, row access policies, dynamic data masking, network policies |
| 65-70 | `task-65-*` … `task-70-*` | Performance & cost — clustering keys, query profile, result caching, warehouse scaling, resource monitors, materialized views |
| 71-74 | `task-71-*` … `task-74-*` | Newer table types — Dynamic, Hybrid, Event, Iceberg tables |
| 75-82 | `task-75-*` … `task-82-*` | Ecosystem & Modeling — dbt, Medallion Architecture, star schema/dimensional modeling, Data Vault modeling, CI/CD, Git integration with Workspaces, Cortex, semantic layer/"Talk to Data" |
| 83-88 | `task-83-*` … `task-88-*` | FinOps — ACCOUNT_USAGE cost views, query tagging/cost attribution, warehouse right-sizing methodology, AUTO_SUSPEND tuning, Budgets & alerts, storage cost monitoring |
| 89-91 | `task-89-*` … `task-91-*` | Cert & interview prep — SnowPro Core review, rapid-fire drills, mock interview |

## Why no data files are committed here
Generated CSVs are large and reproducible from `gen_iot_data.py` — see
`.gitignore`. Don't commit multi-hundred-MB data files to git; GitHub
hard-rejects anything over 100MB per file anyway. Regenerate locally,
or ask why that matters as part of Task 1's understanding check.

## How to use this repo
1. Work through the task folders in order.
2. Actually run the SQL in your own Snowflake trial worksheet — don't
   just read it.
3. Answer each task's understanding questions before moving to the
   next one.
4. Commit your own notes/answers if you want a record of your
   progress (e.g. add an `ANSWERS.md` per task folder).
