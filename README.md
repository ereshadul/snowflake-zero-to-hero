# Snowflake Sr. DB Engineer — Hands-On Lab

Environment setup + hands-on tasks for going from "knows SQL" to
comfortable running real things in Snowflake — zero to super advanced.
Each task folder is self-contained: run its SQL against your own
Snowflake trial, then answer the understanding questions in its
README before moving on — they're not optional, they're where the
actual learning happens.

## Prerequisites
- A Snowflake trial account (free, sign up at snowflake.com).
- Basic SQL (joins, aggregates, subqueries). No prior Snowflake
  experience assumed.
- A browser. Almost every task here uses Snowflake's internal stage
  and native compute only — **no AWS/Azure/GCP account needed for
  117 of the 119 tasks.** The one deliberate exception is Tasks 5-6
  (AWS Integration), which need a free-tier AWS account to create an
  S3 bucket. Skip those two if you don't want AWS involved at all —
  nothing later in the roadmap depends on them.
- Python 3 locally only if you want to regenerate the CSV in Task 1
  yourself instead of using the sample.

## Tasks
119 tasks total, one atomic concept each, grouped into 22 categories,
ordered so foundational concepts (stages, table types, constraints,
advanced SQL, interview drills) come before the things that build on
them. Tasks 1-4 are fully written; the rest are scaffolded (README +
SQL stub with a goal and TODOs) and get filled in as we work through
them — see the open [issues](../../issues) for tracking, kept in sync
with the task numbers below.

Tasks 33-37 and 60-64 (Stages/Table Fundamentals/Programmability/Data
Quality) were added after cross-checking the roadmap against a set of
real Snowflake interview questions. Tasks 82, 104, 105, 108, and 110
were added after reviewing a course on data modeling/architecture
patterns. Tasks 5-32 (AWS Integration, Advanced SQL, Advanced
Snowflake SQL, SQL Interview Practice) were added to round this out
into a complete zero-to-advanced resource, positioned right after the
Foundations block. Deliberately excluded throughout: third-party
orchestrators like Airflow, and any AWS usage beyond Tasks 5-6 — both
stay out of scope per this repo's Snowflake-native design.

| # | Category | Folder | What it covers |
|---|----------|--------|-----------------|
| 1 | Foundations | `task-01-upload-csv/` | Internal stages, file formats, `COPY INTO`, `ON_ERROR`/`VALIDATION_MODE`, loading messy real-world data |
| 2 | Foundations | `task-02-generate-huge-data/` | `GENERATOR()`/`SEQ4()` — synthesizing large datasets with pure SQL, no file needed |
| 3 | Foundations | `task-03-scheduler-continuous-data/` | Snowflake Tasks — scheduling SQL to run repeatedly, warehouse/cost implications |
| 4 | Foundations | `task-04-on-error-abort-statement/` | `ON_ERROR = ABORT_STATEMENT` — the default, and why strict typing makes it bite |
| 5 | AWS Integration | `task-05-s3-iam-setup/` | Creating an S3 bucket and the IAM policy/role Snowflake needs to read from it — the prerequisite plumbing before any STORAGE INTEGRATION can exist. |
| 6 | AWS Integration | `task-06-external-stage-s3/` | Creating a STORAGE INTEGRATION and an external stage pointed at S3, then loading data with the same COPY INTO you already know from Task 1 — the one deliberate exception to this repo's no-external-cloud rule, kept to exactly these two tasks. |
| 7 | Advanced SQL | `task-07-window-ranking-functions/` | Assigning per-row rank within a partition, and the real differences between the three ranking functions when ties happen. |
| 8 | Advanced SQL | `task-08-window-lag-lead/` | Comparing a row to the row before/after it within a partition — period-over-period deltas without a self-join. |
| 9 | Advanced SQL | `task-09-window-frames/` | Cumulative sums and moving averages by controlling exactly which rows a window function sees. |
| 10 | Advanced SQL | `task-10-ctes-recursive/` | WITH clauses for readable multi-step queries, then a recursive CTE for hierarchical/graph-shaped data. |
| 11 | Advanced SQL | `task-11-pivot-unpivot/` | Turning row values into columns and back, natively, without hand-rolled CASE statements. |
| 12 | Advanced SQL | `task-12-advanced-joins/` | Joining a table to itself, and joins whose condition isn't equality — range joins, greatest-n-per-group patterns. |
| 13 | Advanced SQL | `task-13-correlated-subqueries/` | Four ways to ask "does a related row exist," and why they don't always perform or behave the same. |
| 14 | Advanced SQL | `task-14-case-conditional-aggregation/` | Turning row-level conditions into pivoted aggregate columns with CASE inside SUM/COUNT. |
| 15 | Advanced SQL | `task-15-advanced-string-regex/` | REGEXP_SUBSTR, SPLIT, and pattern-based extraction instead of chained SUBSTRING/POSITION calls. |
| 16 | Advanced SQL | `task-16-advanced-date-time/` | Date truncation, date diffing, and business-day-aware date math. |
| 17 | Advanced Snowflake SQL | `task-17-qualify-clause/` | Filtering on a window function's result without wrapping the query in a subquery — a Snowflake-native shortcut most other dialects don't have. |
| 18 | Advanced Snowflake SQL | `task-18-merge-statement/` | Upsert logic in one statement — WHEN MATCHED/NOT MATCHED, and the gotchas around matching more than one row. |
| 19 | Advanced Snowflake SQL | `task-19-multi-table-insert/` | Routing rows from one SELECT into multiple target tables in a single statement. |
| 20 | Advanced Snowflake SQL | `task-20-sampling/` | Querying a random subset of a huge table cheaply, and the difference between ROW and BERNOULLI/SYSTEM sampling. |
| 21 | Advanced Snowflake SQL | `task-21-lateral-table-functions/` | Calling a table function once per row of an outer query — the general mechanism behind FLATTEN. |
| 22 | Advanced Snowflake SQL | `task-22-explain-query-plans/` | Reading a query plan before it runs to predict where it'll actually spend time, as a complement to the post-run Query Profile task. |
| 23 | SQL Interview Practice | `task-23-nth-highest-value/` | The classic interview question, solved three ways (DISTINCT+OFFSET, DENSE_RANK, correlated subquery) with the tradeoffs of each. |
| 24 | SQL Interview Practice | `task-24-running-totals/` | The most commonly asked window-function interview problem, plus the reset-per-group variant. |
| 25 | SQL Interview Practice | `task-25-gaps-and-islands/` | Finding consecutive-value groups and the gaps between them — a named classic in SQL interviews. |
| 26 | SQL Interview Practice | `task-26-deduplication-strategies/` | Several ways to find and remove duplicate rows, and why ROW_NUMBER is usually the right one. |
| 27 | SQL Interview Practice | `task-27-top-n-per-group/` | The "top 3 per category" problem — QUALIFY vs. window function vs. correlated subquery. |
| 28 | SQL Interview Practice | `task-28-percentage-of-total/` | Expressing each row as a share of its group's total using window functions instead of a self-join. |
| 29 | SQL Interview Practice | `task-29-median-percentile/` | MEDIAN, PERCENTILE_CONT, and PERCENTILE_DISC — and why they can disagree. |
| 30 | SQL Interview Practice | `task-30-hierarchical-self-join/` | Walking an org chart with a self-join, then with a recursive CTE, and when each is the right tool. |
| 31 | SQL Interview Practice | `task-31-manual-pivot-case/` | Building a pivot table by hand for interviews that don't allow the PIVOT keyword. |
| 32 | SQL Interview Practice | `task-32-consecutive-streak-detection/` | Finding the longest run of consecutive days/values per group — a direct application of the gaps-and-islands technique. |
| 33 | Stages & File Mgmt | `task-33-stage-types/` | The three kinds of internal stage, user (@~), table (@%table), and named, and when project work actually calls for each. |
| 34 | Stages & File Mgmt | `task-34-put-get-remove-commands/` | Uploading, downloading, and removing files on a stage with PUT/GET/REMOVE from the command line, instead of Snowsight's upload UI. |
| 35 | Table & Data Fundamentals | `task-35-transient-temporary-permanent-tables/` | Time Travel/Fail-safe differences between the three table types, why daily-truncated staging tables usually don't need PERMANENT, and whether a permanent table can live inside a transient schema. |
| 36 | Table & Data Fundamentals | `task-36-constraints-enforcement/` | What Snowflake actually validates for PRIMARY KEY, FOREIGN KEY, UNIQUE, and NOT NULL constraints, and what's purely documentation the optimizer trusts but never checks. |
| 37 | Table & Data Fundamentals | `task-37-primary-key-generation/` | Generating primary key values in Snowflake with sequences and AUTOINCREMENT/IDENTITY columns, given PRIMARY KEY itself isn't enforced. |
| 38 | Loading & COPY | `task-38-on-error-skip-file/` | Skipping an entire file the moment it hits an error, vs. skipping just the bad rows. |
| 39 | Loading & COPY | `task-39-on-error-skip-file-num/` | Tolerating up to N bad rows per file before Snowflake gives up on that file. |
| 40 | Loading & COPY | `task-40-on-error-skip-file-percent/` | Tolerating a percentage of bad rows per file instead of a fixed count. |
| 41 | Loading & COPY | `task-41-return-failed-only/` | Getting COPY INTO to report only the files/rows that failed, not a full success dump. |
| 42 | Loading & COPY | `task-42-size-limit/` | Capping how much data a single COPY INTO will ingest in one call. |
| 43 | Loading & COPY | `task-43-truncatecolumns/` | Silently truncating oversized string values instead of erroring the load. |
| 44 | Loading & COPY | `task-44-force-reload/` | Reloading files Snowflake thinks it already loaded, and why that's normally a bad idea. |
| 45 | Loading & COPY | `task-45-pattern-matching/` | Loading only a subset of staged files by regex instead of everything in the stage. |
| 46 | Loading & COPY | `task-46-purge-after-load/` | Auto-deleting staged files after a successful load, and the recovery risk that comes with it. |
| 47 | Loading & COPY | `task-47-load-history/` | Auditing what got loaded, when, and whether it succeeded, after the fact. |
| 48 | Loading & COPY | `task-48-transform-during-copy/` | Using a SELECT inside COPY INTO to reshape columns during the load instead of after. |
| 49 | Semi-structured data | `task-49-object-type/` | Storing and querying key-value data natively with OBJECT. |
| 50 | Semi-structured data | `task-50-array-type/` | Storing and querying ordered lists natively with ARRAY. |
| 51 | Semi-structured data | `task-51-variant-type/` | The type that holds arbitrary JSON and how dot/bracket notation traverses it. |
| 52 | Semi-structured data | `task-52-flatten-single-record/` | Exploding a single nested JSON document into relational rows. |
| 53 | Semi-structured data | `task-53-flatten-union-all/` | Flattening many JSON documents at once and stitching the results together. |
| 54 | Semi-structured data | `task-54-querying-parquet/` | Querying a staged Parquet file without loading it into a table first. |
| 55 | Unloading data | `task-55-unload-csv/` | COPY INTO <location> to push a table/query result out to CSV. |
| 56 | Unloading data | `task-56-unload-options/` | Controlling file splitting, headers, and overwrite behavior on unload. |
| 57 | Unloading data | `task-57-unload-json/` | Unloading query results as newline-delimited JSON. |
| 58 | Unloading data | `task-58-unload-parquet/` | Unloading query results as Parquet. |
| 59 | Unloading data | `task-59-unload-partitioned/` | Using PARTITION BY to fan a single unload out into a folder structure. |
| 60 | Programmability | `task-60-udf-basics/` | What a UDF is and which languages Snowflake supports (SQL, JavaScript, Python, Java, Scala), and what a UDF fundamentally can and can't do (no DDL/DML side effects). |
| 61 | Programmability | `task-61-stored-procedures-and-udf-tradeoffs/` | Why TRUNCATE (or any DDL/DML) requires a stored procedure, not a UDF, and when to reach for each. |
| 62 | Programmability | `task-62-notification-integrations-email/` | Sending email from Snowflake via a Notification Integration and SYSTEM$SEND_EMAIL, wiring an Alert or Task to actually page someone. |
| 63 | Data Quality | `task-63-table-diffing/` | Comparing two tables (e.g. QA vs. prod) for drift with MINUS/EXCEPT and hash-based row comparison. |
| 64 | Data Quality | `task-64-data-quality-validation-framework/` | Designing a repeatable validation/QC process around a load, combining VALIDATION_MODE, post-load checks, and alerting into one pattern instead of ad hoc queries. |
| 65 | Snowpipe | `task-65-snowpipe-internal-stage/` | Standing up a Snowpipe that ingests from an internal stage. |
| 66 | Snowpipe | `task-66-snowpipe-auto-vs-manual/` | The difference between event-driven auto-ingest and manually refreshing a pipe. |
| 67 | Snowpipe | `task-67-snowpipe-monitoring/` | Checking whether a pipe is healthy and what's queued or failed. |
| 68 | Snowpipe | `task-68-snowpipe-cost/` | How Snowpipe billing (serverless compute per file) differs from warehouse billing. |
| 69 | Streams | `task-69-stream-standard/` | Tracking inserts/updates/deletes on a table with a STANDARD stream. |
| 70 | Streams | `task-70-stream-append-only/` | Tracking only inserts, cheaper than a STANDARD stream when deletes/updates don't matter. |
| 71 | Streams | `task-71-stream-task-cdc/` | Wiring a stream and a task together into a self-driving CDC pipeline. |
| 72 | Streams | `task-72-stream-multiple-tables/` | Coordinating streams across more than one source table. |
| 73 | Streams | `task-73-stream-on-view/` | Change tracking on a view instead of a base table. |
| 74 | Streams | `task-74-stream-consuming-emptying/` | What actually advances a stream's offset, and how to avoid accidentally consuming it. |
| 75 | Streams | `task-75-change-tracking-columns/` | Reading METADATA$ACTION/ISUPDATE/ROW_ID to interpret stream output correctly. |
| 76 | Streams | `task-76-change-tracking-on-table/` | CHANGE_TRACKING = TRUE and the CHANGES() clause, tracking a table's history without creating a Stream object, and when that's the better fit. |
| 77 | Tasks - deeper | `task-77-task-no-schedule-triggered/` | Tasks that fire on a stream having data instead of a fixed schedule. |
| 78 | Tasks - deeper | `task-78-task-trees-dag/` | Chaining tasks into a dependency graph with AFTER. |
| 79 | Tasks - deeper | `task-79-task-when-clause/` | Conditionally skipping a task run based on a predicate, e.g. SYSTEM$STREAM_HAS_DATA. |
| 80 | Tasks - deeper | `task-80-task-monitoring-errors/` | Inspecting task run history and handling failures in a DAG. |
| 81 | Tasks - deeper | `task-81-task-serverless-vs-warehouse/` | Choosing between Snowflake-managed compute and your own warehouse for a task. |
| 82 | Tasks - deeper | `task-82-incremental-load-strategy/` | Deciding between full-reload and incremental load, and the watermarking approaches (timestamp-based, CDC-based via Streams) that make incremental loading actually correct. |
| 83 | Time Travel & cloning | `task-83-time-travel-at-before/` | Querying a table as it existed at a past timestamp, offset, or query ID. |
| 84 | Time Travel & cloning | `task-84-undrop/` | Recovering a dropped table/schema/database within its retention window. |
| 85 | Time Travel & cloning | `task-85-zero-copy-clone-table/` | Cloning a table instantly without copying storage. |
| 86 | Time Travel & cloning | `task-86-zero-copy-clone-schema-db/` | Cloning at the schema/database level, e.g. for a full env snapshot. |
| 87 | Time Travel & cloning | `task-87-time-travel-retention-cost/` | How DATA_RETENTION_TIME_IN_DAYS drives storage cost for Time Travel and Fail-safe. |
| 88 | Security | `task-88-role-hierarchy/` | How Snowflake's built-in and custom roles nest, and how privilege inheritance flows. |
| 89 | Security | `task-89-custom-roles-grants/` | Creating a custom role and granting it object and role privileges. |
| 90 | Security | `task-90-row-access-policies/` | Restricting which rows a role can see with a row access policy. |
| 91 | Security | `task-91-dynamic-data-masking/` | Masking column values for some roles but not others without duplicating data. |
| 92 | Security | `task-92-network-policies/` | IP allow/block lists at the account or user level (conceptual, since this lab has no VPC). |
| 93 | Performance & cost | `task-93-clustering-keys/` | Choosing a clustering key and reading clustering depth to judge if it's helping. |
| 94 | Performance & cost | `task-94-query-profile/` | Reading the query profile graph to find the actual bottleneck in a slow query. |
| 95 | Performance & cost | `task-95-result-caching/` | When Snowflake reuses a cached result vs. recomputing, and how to tell. |
| 96 | Performance & cost | `task-96-warehouse-scaling/` | Bigger warehouse (scale up) vs. multi-cluster (scale out) for different bottlenecks. |
| 97 | Performance & cost | `task-97-resource-monitors/` | Capping credit spend with a resource monitor and suspend actions. |
| 98 | Performance & cost | `task-98-materialized-views/` | Trading storage/maintenance cost for query speed on an expensive aggregation. |
| 99 | Newer table types | `task-99-dynamic-tables/` | Declarative, incrementally-refreshed tables defined by a query instead of a pipeline. |
| 100 | Newer table types | `task-100-hybrid-tables/` | Row-oriented, OLTP-style tables with enforced primary keys and fast point lookups. |
| 101 | Newer table types | `task-101-event-tables/` | The special table type that captures logs/traces from procedures and functions. |
| 102 | Newer table types | `task-102-iceberg-tables/` | Snowflake reading/writing the open Iceberg table format on external storage. |
| 103 | Ecosystem & Modeling | `task-103-dbt-basics/` | Wiring up a dbt project against Snowflake and running a first model + test. |
| 104 | Ecosystem & Modeling | `task-104-medallion-architecture/` | Designing a Bronze/Silver/Gold layered pipeline, what belongs in each layer, and why the boundaries exist. |
| 105 | Ecosystem & Modeling | `task-105-star-schema-dimensional-modeling/` | Fact tables, dimension tables, and a date dimension, Kimball-style star schema modeling, as a second modeling approach alongside Task 106's Data Vault. |
| 106 | Ecosystem & Modeling | `task-106-data-vault-modeling/` | Hubs, links, and satellites applied to a small Snowflake schema. |
| 107 | Ecosystem & Modeling | `task-107-cicd-schema-changes/` | Driving SQL deployments through GitHub Actions instead of hand-running worksheets. |
| 108 | Ecosystem & Modeling | `task-108-git-integration-workspaces/` | Connecting a Snowflake Workspace to a Git repository for native version-controlled SQL development. |
| 109 | Ecosystem & Modeling | `task-109-cortex/` | Calling Cortex's built-in LLM functions directly from SQL. |
| 110 | Ecosystem & Modeling | `task-110-semantic-layer-talk-to-data/` | Building a semantic model so Cortex Analyst can answer natural-language questions over your data directly. |
| 111 | FinOps | `task-111-account-usage-cost-views/` | Querying WAREHOUSE_METERING_HISTORY, METERING_DAILY_HISTORY, and QUERY_HISTORY in SNOWFLAKE.ACCOUNT_USAGE to see exactly where credits actually went, not just what a warehouse is configured to cost. |
| 112 | FinOps | `task-112-query-tagging-cost-attribution/` | Using QUERY_TAG and object tags to attribute warehouse spend back to a team, project, or workload, the chargeback/showback pattern. |
| 113 | FinOps | `task-113-warehouse-right-sizing-methodology/` | Formalizing the SMALL-vs-MEDIUM test from Task 2 into a repeatable process: when a bigger warehouse actually pays for itself, and how to tell from the query profile instead of guessing. |
| 114 | FinOps | `task-114-auto-suspend-resume-tuning/` | The tradeoff between a short AUTO_SUSPEND (saves idle credits, but pays repeated resume latency) and a long one (stays warm, but burns credits doing nothing), tuned against a real workload's query spacing. |
| 115 | FinOps | `task-115-budgets-and-alerts/` | Setting a spend threshold with Snowflake Budgets and wiring up a notification so you find out about a cost spike from an alert, not from the bill. |
| 116 | FinOps | `task-116-storage-cost-monitoring/` | Querying STORAGE_USAGE and TABLE_STORAGE_METRICS to see how much you're paying for active data vs. Time Travel vs. Fail-safe vs. clones, and which of those is actually the expensive one. |
| 117 | Cert & interview prep | `task-117-snowpro-core-review/` | Working through SnowPro Core exam-style questions against concepts from earlier tasks. |
| 118 | Cert & interview prep | `task-118-rapid-fire-drills/` | Quick-recall drills on syntax and gotchas across everything covered so far. |
| 119 | Cert & interview prep | `task-119-mock-interview/` | A simulated Sr. DBE interview covering design/tradeoff questions, not just syntax. |

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
