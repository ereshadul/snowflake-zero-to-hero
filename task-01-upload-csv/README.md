# Task 1 — Upload a messy CSV and bulk-load it

## Goal
Set up the lab database in your Snowflake trial and load a 2,000,000-row
synthetic IoT sensor dataset that's deliberately messy (duplicates, bad
timestamps, non-numeric values, nulls) — the kind of file you actually
get handed in real jobs.

## Files
- `01_setup_ddl.sql` — database, warehouse, file format, stage, tables.
- `gen_iot_data.py` — regenerates the CSV locally if you don't have it
  (`python3 gen_iot_data.py 2000000 iot_sensor_readings.csv 42 1`).
- `iot_sensor_readings_SAMPLE.csv` — first 200 rows, so you can look at
  the shape of the data without opening the full file.
- `02_bulk_load_copy_into.sql` — the actual load + validation queries.

## Steps
1. Log into your Snowflake trial, open a new Snowsight worksheet.
2. Paste and run all of `01_setup_ddl.sql`.
3. Generate the CSV locally (see command above), then gzip it —
   `gzip iot_sensor_readings.csv` — you want the `.gz`, not the raw CSV
   (438MB uncompressed exceeds Snowsight's 250MB browser-upload limit;
   compressed it's ~121MB and uploads fine, no SnowSQL CLI needed).
4. In Snowsight: **Data → Add Data → Load files into a Stage** → choose
   `IOT_LAB.RAW.IOT_STAGE` → upload the `.gz` file.
5. Run `02_bulk_load_copy_into.sql` top to bottom.

## Understanding check — answer these before Task 2
1. The raw table lands everything as STRING (and one VARIANT). Why not
   load `reading_value` straight into a FLOAT column and
   `event_timestamp` straight into a TIMESTAMP column? What would
   `COPY INTO` do with the malformed rows if we typed them at landing,
   under `ON_ERROR = 'CONTINUE'` vs the default `ABORT_STATEMENT`?
2. `VALIDATION_MODE = 'RETURN_ERRORS'` loads zero rows. What's the
   actual difference between running that first vs. just running the
   real `COPY INTO` with `ON_ERROR = 'CONTINUE'` and checking
   `VALIDATE()` afterward — is the dry run ever necessary, or just habit?
3. If you ran the exact same `COPY INTO` statement a second time right
   now, what happens? Try it before answering.
