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
69 tasks total, one atomic concept each, grouped into 12 categories.
Tasks 1-3 are fully written; 4-69 are scaffolded (README + SQL stub
with a goal and TODOs) and get filled in as we work through them —
see the open [issues](../../issues) for tracking.

| # | Folder | What it covers |
|---|--------|----------------|
| 1 | `task-01-upload-csv/` | Internal stages, file formats, `COPY INTO`, `ON_ERROR`/`VALIDATION_MODE`, loading messy real-world data |
| 2 | `task-02-generate-huge-data/` | `GENERATOR()`/`SEQ4()` — synthesizing large datasets with pure SQL, no file needed |
| 3 | `task-03-scheduler-continuous-data/` | Snowflake Tasks — scheduling SQL to run repeatedly, warehouse/cost implications |
| 4-15 | `task-04-*` … `task-15-*` | Loading & `COPY INTO` options — `ON_ERROR` variants, `RETURN_FAILED_ONLY`, `SIZE_LIMIT`, `TRUNCATECOLUMNS`, `FORCE`, `PATTERN`, `PURGE`, load history, transforming data mid-COPY |
| 16-21 | `task-16-*` … `task-21-*` | Semi-structured data — `OBJECT`, `ARRAY`, `VARIANT`, `FLATTEN`, querying Parquet directly |
| 22-26 | `task-22-*` … `task-26-*` | Unloading data — CSV/JSON/Parquet unload, unload options, partitioned unload |
| 27-30 | `task-27-*` … `task-30-*` | Snowpipe — internal-stage pipe, auto-ingest vs. manual refresh, monitoring, cost |
| 31-37 | `task-31-*` … `task-37-*` | Streams — STANDARD/APPEND-ONLY, stream+task CDC, streams on views/multiple tables, change-tracking columns |
| 38-42 | `task-38-*` … `task-42-*` | Tasks, deeper — triggered tasks, DAGs, `WHEN`, monitoring, serverless vs. warehouse-backed |
| 43-47 | `task-43-*` … `task-47-*` | Time Travel & cloning — `AT`/`BEFORE`, `UNDROP`, zero-copy clone, retention & storage cost |
| 48-52 | `task-48-*` … `task-52-*` | Security — role hierarchy, custom roles/grants, row access policies, dynamic data masking, network policies |
| 53-58 | `task-53-*` … `task-58-*` | Performance & cost — clustering keys, query profile, result caching, warehouse scaling, resource monitors, materialized views |
| 59-62 | `task-59-*` … `task-62-*` | Newer table types — Dynamic, Hybrid, Event, Iceberg tables |
| 63-66 | `task-63-*` … `task-66-*` | Ecosystem — dbt, Data Vault modeling, CI/CD, Cortex |
| 67-69 | `task-67-*` … `task-69-*` | Cert & interview prep — SnowPro Core review, rapid-fire drills, mock interview |

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
