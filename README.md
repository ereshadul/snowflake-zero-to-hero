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
[issues](../../issues) for tracking, kept in sync with the task
numbers below.

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

| # | Category | Folder | What it covers |
|---|----------|--------|-----------------|
| 1 | Foundations | `task-01-upload-csv/` | Internal stages, file formats, `COPY INTO`, `ON_ERROR`/`VALIDATION_MODE`, loading messy real-world data |
| 2 | Foundations | `task-02-generate-huge-data/` | `GENERATOR()`/`SEQ4()` — synthesizing large datasets with pure SQL, no file needed |
| 3 | Foundations | `task-03-scheduler-continuous-data/` | Snowflake Tasks — scheduling SQL to run repeatedly, warehouse/cost implications |
| 4 | Foundations | `task-04-on-error-abort-statement/` | `ON_ERROR = ABORT_STATEMENT` — the default, and why strict typing makes it bite |
| 5 | Stages & File Mgmt | `task-05-stage-types/` | The three kinds of internal stage, user (@~), table (@%table), and named, and when project work actually calls for each. |
| 6 | Stages & File Mgmt | `task-06-put-get-remove-commands/` | Uploading, downloading, and removing files on a stage with PUT/GET/REMOVE from the command line, instead of Snowsight's upload UI. |
| 7 | Table & Data Fundamentals | `task-07-transient-temporary-permanent-tables/` | Time Travel/Fail-safe differences between the three table types, why daily-truncated staging tables usually don't need PERMANENT, and whether a permanent table can live inside a transient schema. |
| 8 | Table & Data Fundamentals | `task-08-constraints-enforcement/` | What Snowflake actually validates for PRIMARY KEY, FOREIGN KEY, UNIQUE, and NOT NULL constraints, and what's purely documentation the optimizer trusts but never checks. |
| 9 | Table & Data Fundamentals | `task-09-primary-key-generation/` | Generating primary key values in Snowflake with sequences and AUTOINCREMENT/IDENTITY columns, given PRIMARY KEY itself isn't enforced. |
| 10 | Loading & COPY | `task-10-on-error-skip-file/` | Skipping an entire file the moment it hits an error, vs. skipping just the bad rows. |
| 11 | Loading & COPY | `task-11-on-error-skip-file-num/` | Tolerating up to N bad rows per file before Snowflake gives up on that file. |
| 12 | Loading & COPY | `task-12-on-error-skip-file-percent/` | Tolerating a percentage of bad rows per file instead of a fixed count. |
| 13 | Loading & COPY | `task-13-return-failed-only/` | Getting COPY INTO to report only the files/rows that failed, not a full success dump. |
| 14 | Loading & COPY | `task-14-size-limit/` | Capping how much data a single COPY INTO will ingest in one call. |
| 15 | Loading & COPY | `task-15-truncatecolumns/` | Silently truncating oversized string values instead of erroring the load. |
| 16 | Loading & COPY | `task-16-force-reload/` | Reloading files Snowflake thinks it already loaded, and why that's normally a bad idea. |
| 17 | Loading & COPY | `task-17-pattern-matching/` | Loading only a subset of staged files by regex instead of everything in the stage. |
| 18 | Loading & COPY | `task-18-purge-after-load/` | Auto-deleting staged files after a successful load, and the recovery risk that comes with it. |
| 19 | Loading & COPY | `task-19-load-history/` | Auditing what got loaded, when, and whether it succeeded, after the fact. |
| 20 | Loading & COPY | `task-20-transform-during-copy/` | Using a SELECT inside COPY INTO to reshape columns during the load instead of after. |
| 21 | Semi-structured data | `task-21-object-type/` | Storing and querying key-value data natively with OBJECT. |
| 22 | Semi-structured data | `task-22-array-type/` | Storing and querying ordered lists natively with ARRAY. |
| 23 | Semi-structured data | `task-23-variant-type/` | The type that holds arbitrary JSON and how dot/bracket notation traverses it. |
| 24 | Semi-structured data | `task-24-flatten-single-record/` | Exploding a single nested JSON document into relational rows. |
| 25 | Semi-structured data | `task-25-flatten-union-all/` | Flattening many JSON documents at once and stitching the results together. |
| 26 | Semi-structured data | `task-26-querying-parquet/` | Querying a staged Parquet file without loading it into a table first. |
| 27 | Unloading data | `task-27-unload-csv/` | COPY INTO <location> to push a table/query result out to CSV. |
| 28 | Unloading data | `task-28-unload-options/` | Controlling file splitting, headers, and overwrite behavior on unload. |
| 29 | Unloading data | `task-29-unload-json/` | Unloading query results as newline-delimited JSON. |
| 30 | Unloading data | `task-30-unload-parquet/` | Unloading query results as Parquet. |
| 31 | Unloading data | `task-31-unload-partitioned/` | Using PARTITION BY to fan a single unload out into a folder structure. |
| 32 | Programmability | `task-32-udf-basics/` | What a UDF is and which languages Snowflake supports (SQL, JavaScript, Python, Java, Scala), and what a UDF fundamentally can and can't do (no DDL/DML side effects). |
| 33 | Programmability | `task-33-stored-procedures-and-udf-tradeoffs/` | Why TRUNCATE (or any DDL/DML) requires a stored procedure, not a UDF, and when to reach for each. |
| 34 | Programmability | `task-34-notification-integrations-email/` | Sending email from Snowflake via a Notification Integration and SYSTEM$SEND_EMAIL, wiring an Alert or Task to actually page someone. |
| 35 | Data Quality | `task-35-table-diffing/` | Comparing two tables (e.g. QA vs. prod) for drift with MINUS/EXCEPT and hash-based row comparison. |
| 36 | Data Quality | `task-36-data-quality-validation-framework/` | Designing a repeatable validation/QC process around a load, combining VALIDATION_MODE, post-load checks, and alerting into one pattern instead of ad hoc queries. |
| 37 | Snowpipe | `task-37-snowpipe-internal-stage/` | Standing up a Snowpipe that ingests from an internal stage. |
| 38 | Snowpipe | `task-38-snowpipe-auto-vs-manual/` | The difference between event-driven auto-ingest and manually refreshing a pipe. |
| 39 | Snowpipe | `task-39-snowpipe-monitoring/` | Checking whether a pipe is healthy and what's queued or failed. |
| 40 | Snowpipe | `task-40-snowpipe-cost/` | How Snowpipe billing (serverless compute per file) differs from warehouse billing. |
| 41 | Streams | `task-41-stream-standard/` | Tracking inserts/updates/deletes on a table with a STANDARD stream. |
| 42 | Streams | `task-42-stream-append-only/` | Tracking only inserts, cheaper than a STANDARD stream when deletes/updates don't matter. |
| 43 | Streams | `task-43-stream-task-cdc/` | Wiring a stream and a task together into a self-driving CDC pipeline. |
| 44 | Streams | `task-44-stream-multiple-tables/` | Coordinating streams across more than one source table. |
| 45 | Streams | `task-45-stream-on-view/` | Change tracking on a view instead of a base table. |
| 46 | Streams | `task-46-stream-consuming-emptying/` | What actually advances a stream's offset, and how to avoid accidentally consuming it. |
| 47 | Streams | `task-47-change-tracking-columns/` | Reading METADATA$ACTION/ISUPDATE/ROW_ID to interpret stream output correctly. |
| 48 | Streams | `task-48-change-tracking-on-table/` | CHANGE_TRACKING = TRUE and the CHANGES() clause, tracking a table's history without creating a Stream object, and when that's the better fit. |
| 49 | Tasks, deeper | `task-49-task-no-schedule-triggered/` | Tasks that fire on a stream having data instead of a fixed schedule. |
| 50 | Tasks, deeper | `task-50-task-trees-dag/` | Chaining tasks into a dependency graph with AFTER. |
| 51 | Tasks, deeper | `task-51-task-when-clause/` | Conditionally skipping a task run based on a predicate, e.g. SYSTEM$STREAM_HAS_DATA. |
| 52 | Tasks, deeper | `task-52-task-monitoring-errors/` | Inspecting task run history and handling failures in a DAG. |
| 53 | Tasks, deeper | `task-53-task-serverless-vs-warehouse/` | Choosing between Snowflake-managed compute and your own warehouse for a task. |
| 54 | Tasks, deeper | `task-54-incremental-load-strategy/` | Deciding between full-reload and incremental load, and the watermarking approaches (timestamp-based, CDC-based via Streams) that make incremental loading actually correct. |
| 55 | Time Travel & cloning | `task-55-time-travel-at-before/` | Querying a table as it existed at a past timestamp, offset, or query ID. |
| 56 | Time Travel & cloning | `task-56-undrop/` | Recovering a dropped table/schema/database within its retention window. |
| 57 | Time Travel & cloning | `task-57-zero-copy-clone-table/` | Cloning a table instantly without copying storage. |
| 58 | Time Travel & cloning | `task-58-zero-copy-clone-schema-db/` | Cloning at the schema/database level, e.g. for a full env snapshot. |
| 59 | Time Travel & cloning | `task-59-time-travel-retention-cost/` | How DATA_RETENTION_TIME_IN_DAYS drives storage cost for Time Travel and Fail-safe. |
| 60 | Security | `task-60-role-hierarchy/` | How Snowflake's built-in and custom roles nest, and how privilege inheritance flows. |
| 61 | Security | `task-61-custom-roles-grants/` | Creating a custom role and granting it object and role privileges. |
| 62 | Security | `task-62-row-access-policies/` | Restricting which rows a role can see with a row access policy. |
| 63 | Security | `task-63-dynamic-data-masking/` | Masking column values for some roles but not others without duplicating data. |
| 64 | Security | `task-64-network-policies/` | IP allow/block lists at the account or user level (conceptual, since this lab has no VPC). |
| 65 | Performance & cost | `task-65-clustering-keys/` | Choosing a clustering key and reading clustering depth to judge if it's helping. |
| 66 | Performance & cost | `task-66-query-profile/` | Reading the query profile graph to find the actual bottleneck in a slow query. |
| 67 | Performance & cost | `task-67-result-caching/` | When Snowflake reuses a cached result vs. recomputing, and how to tell. |
| 68 | Performance & cost | `task-68-warehouse-scaling/` | Bigger warehouse (scale up) vs. multi-cluster (scale out) for different bottlenecks. |
| 69 | Performance & cost | `task-69-resource-monitors/` | Capping credit spend with a resource monitor and suspend actions. |
| 70 | Performance & cost | `task-70-materialized-views/` | Trading storage/maintenance cost for query speed on an expensive aggregation. |
| 71 | Newer table types | `task-71-dynamic-tables/` | Declarative, incrementally-refreshed tables defined by a query instead of a pipeline. |
| 72 | Newer table types | `task-72-hybrid-tables/` | Row-oriented, OLTP-style tables with enforced primary keys and fast point lookups. |
| 73 | Newer table types | `task-73-event-tables/` | The special table type that captures logs/traces from procedures and functions. |
| 74 | Newer table types | `task-74-iceberg-tables/` | Snowflake reading/writing the open Iceberg table format on external storage. |
| 75 | Ecosystem & Modeling | `task-75-dbt-basics/` | Wiring up a dbt project against Snowflake and running a first model + test. |
| 76 | Ecosystem & Modeling | `task-76-medallion-architecture/` | Designing a Bronze/Silver/Gold layered pipeline, what belongs in each layer, and why the boundaries exist. |
| 77 | Ecosystem & Modeling | `task-77-star-schema-dimensional-modeling/` | Fact tables, dimension tables, and a date dimension, Kimball-style star schema modeling, as a second modeling approach alongside Task 78's Data Vault. |
| 78 | Ecosystem & Modeling | `task-78-data-vault-modeling/` | Hubs, links, and satellites applied to a small Snowflake schema. |
| 79 | Ecosystem & Modeling | `task-79-cicd-schema-changes/` | Driving SQL deployments through GitHub Actions instead of hand-running worksheets. |
| 80 | Ecosystem & Modeling | `task-80-git-integration-workspaces/` | Connecting a Snowflake Workspace to a Git repository for native version-controlled SQL development. |
| 81 | Ecosystem & Modeling | `task-81-cortex/` | Calling Cortex's built-in LLM functions directly from SQL. |
| 82 | Ecosystem & Modeling | `task-82-semantic-layer-talk-to-data/` | Building a semantic model so Cortex Analyst can answer natural-language questions over your data directly. |
| 83 | FinOps | `task-83-account-usage-cost-views/` | Querying WAREHOUSE_METERING_HISTORY, METERING_DAILY_HISTORY, and QUERY_HISTORY in SNOWFLAKE.ACCOUNT_USAGE to see exactly where credits actually went, not just what a warehouse is configured to cost. |
| 84 | FinOps | `task-84-query-tagging-cost-attribution/` | Using QUERY_TAG and object tags to attribute warehouse spend back to a team, project, or workload, the chargeback/showback pattern. |
| 85 | FinOps | `task-85-warehouse-right-sizing-methodology/` | Formalizing the SMALL-vs-MEDIUM test from Task 2 into a repeatable process: when a bigger warehouse actually pays for itself, and how to tell from the query profile instead of guessing. |
| 86 | FinOps | `task-86-auto-suspend-resume-tuning/` | The tradeoff between a short AUTO_SUSPEND (saves idle credits, but pays repeated resume latency) and a long one (stays warm, but burns credits doing nothing), tuned against a real workload's query spacing. |
| 87 | FinOps | `task-87-budgets-and-alerts/` | Setting a spend threshold with Snowflake Budgets and wiring up a notification so you find out about a cost spike from an alert, not from the bill. |
| 88 | FinOps | `task-88-storage-cost-monitoring/` | Querying STORAGE_USAGE and TABLE_STORAGE_METRICS to see how much you're paying for active data vs. Time Travel vs. Fail-safe vs. clones, and which of those is actually the expensive one. |
| 89 | Cert & interview prep | `task-89-snowpro-core-review/` | Working through SnowPro Core exam-style questions against concepts from earlier tasks. |
| 90 | Cert & interview prep | `task-90-rapid-fire-drills/` | Quick-recall drills on syntax and gotchas across everything covered so far. |
| 91 | Cert & interview prep | `task-91-mock-interview/` | A simulated Sr. DBE interview covering design/tradeoff questions, not just syntax. |

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
