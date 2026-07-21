# Task 104 — dbt sources and staging models

**Category:** dbt

## Goal
Declaring raw tables as dbt sources() instead of hardcoding table names, and the staging-layer convention of one staging model per source table doing only light renaming/casting.

**Real-world scenario:** The raw landing table gets renamed during a
platform migration, and a project with dozens of models hardcoding
`IOT_LAB.RAW.SENSOR_READINGS_RAW` everywhere means dozens of files to
fix. A project built on `{{ source(...) }}` means updating one YAML
file.

## Steps
1. Work through `105_dbt_sources_staging.sql` — declare the source,
   build the staging model, run it.
2. Do it for real against your own Snowflake trial — don't just read
   it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `105_dbt_sources_staging.sql` — three questions on
why staging models cast/filter before anything else touches the data,
the one-place-to-update benefit of sources, and why staging models
stay deliberately "dumb."
