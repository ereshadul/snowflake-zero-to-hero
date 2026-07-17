import csv
import random
import sys
import uuid
import json
from collections import deque
from datetime import datetime, timedelta

# CLI args: NUM_ROWS OUTFILE SEED WRITE_HEADER(1/0)
NUM_ROWS = int(sys.argv[1]) if len(sys.argv) > 1 else 2_000_000
OUTFILE = sys.argv[2] if len(sys.argv) > 2 else "iot_sensor_readings.csv"
SEED = int(sys.argv[3]) if len(sys.argv) > 3 else 42
WRITE_HEADER = bool(int(sys.argv[4])) if len(sys.argv) > 4 else True

random.seed(SEED)

NUM_SENSORS = 5000
BASE_TIME = datetime(2026, 6, 1, 0, 0, 0)
SPAN_SECONDS = 45 * 24 * 3600  # 45 days
DAY_STRINGS_COUNT = 50  # 45 day span + buffer for late-arriving ingest offsets

DEVICE_TYPES = ["temperature", "humidity", "pressure", "motion", "gps", "vibration"]
STATUS_CODES = ["OK", "OK", "OK", "OK", "WARN", "ERROR", "OFFLINE"]
FIRMWARE_VERSIONS = ["v1.0", "v1.1", "v1.2", "v2.0-beta"]

VALUE_RANGES = {
    "temperature": (-40, 60),
    "humidity": (0, 100),
    "pressure": (870, 1085),
    "motion": (0, 1),
    "gps": (-180, 180),
    "vibration": (0, 15),
}
UNITS = {
    "temperature": "C", "humidity": "%", "pressure": "hPa",
    "motion": "bool", "gps": "deg", "vibration": "mm/s",
}

HEADER = [
    "event_id", "sensor_id", "device_type", "event_timestamp", "ingested_at",
    "reading_value", "unit", "battery_pct", "signal_strength_dbm",
    "latitude", "longitude", "firmware_version", "status_code",
    "raw_payload", "is_duplicate_of", "ingest_batch_id",
]

DAY_STRINGS = [(BASE_TIME + timedelta(days=d)).strftime("%Y-%m-%d") for d in range(DAY_STRINGS_COUNT)]

def ts_str(total_offset_seconds):
    day_idx, sec_in_day = divmod(total_offset_seconds, 86400)
    hh, rem = divmod(sec_in_day, 3600)
    mm, ss = divmod(rem, 60)
    return f"{DAY_STRINGS[day_idx]} {hh:02d}:{mm:02d}:{ss:02d}"

PAYLOAD_POOL = []
for _ in range(40):
    p = {"calibration_offset": round(random.uniform(-2, 2), 3), "alerts": []}
    if random.random() < 0.25:
        p["alerts"].append(random.choice(["LOW_BATTERY", "SIGNAL_LOSS", "SENSOR_FAULT"]))
    if random.random() < 0.05:
        del p["calibration_offset"]
    PAYLOAD_POOL.append(json.dumps(p))

recent_rows_buffer = deque(maxlen=200)

randint = random.randint
uniform = random.uniform
choice = random.choice
rnd = random.random

rows_buffer = []
FLUSH_EVERY = 50_000

with open(OUTFILE, "w", newline="", encoding="utf-8") as f:
    writer = csv.writer(f, quoting=csv.QUOTE_MINIMAL)
    if WRITE_HEADER:
        writer.writerow(HEADER)

    batch_id = f"INITIAL_LOAD_{BASE_TIME.strftime('%Y%m%d')}"

    for i in range(NUM_ROWS):
        roll = rnd()
        sensor_id = f"SENSOR_{randint(0, NUM_SENSORS - 1):05d}"
        device_type = choice(DEVICE_TYPES)
        status = choice(STATUS_CODES)
        firmware = choice(FIRMWARE_VERSIONS)

        event_offset = randint(0, SPAN_SECONDS)
        if rnd() < 0.02:
            ingest_delay = randint(3600 * 6, 3600 * 48)
        else:
            ingest_delay = randint(0, 300)

        event_ts_str = ts_str(event_offset)
        ingested_at_str = ts_str(event_offset + ingest_delay)

        lo, hi = VALUE_RANGES[device_type]
        value = round(uniform(lo, hi), 3)
        unit = UNITS[device_type]

        battery = round(uniform(1, 100), 1)
        signal = round(uniform(-110, -30), 1)

        if device_type == "gps":
            lat = round(uniform(-90, 90), 6)
            lon = round(uniform(-180, 180), 6)
        else:
            lat = "" if rnd() < 0.7 else round(uniform(-90, 90), 6)
            lon = "" if rnd() < 0.7 else round(uniform(-180, 180), 6)

        event_id = str(uuid.uuid4())
        payload = choice(PAYLOAD_POOL)
        is_dup_of = ""

        if roll < 0.003:
            value = ""
        elif roll < 0.005:
            value = choice(["N/A", "ERR"])
        elif roll < 0.006:
            event_ts_str = "2026-13-45 99:99:99"
        elif roll < 0.016 and recent_rows_buffer:
            dup_event_id, dup_sensor_id, dup_device_type, dup_ts_str = choice(recent_rows_buffer)
            sensor_id = dup_sensor_id
            device_type = dup_device_type
            event_ts_str = dup_ts_str
            is_dup_of = dup_event_id
            value = round(value * uniform(0.8, 1.2), 3) if isinstance(value, float) else value

        rows_buffer.append([
            event_id, sensor_id, device_type, event_ts_str, ingested_at_str,
            value, unit, battery, signal, lat, lon, firmware, status,
            payload, is_dup_of, batch_id,
        ])

        recent_rows_buffer.append((event_id, sensor_id, device_type, event_ts_str))

        if len(rows_buffer) >= FLUSH_EVERY:
            writer.writerows(rows_buffer)
            rows_buffer = []

    if rows_buffer:
        writer.writerows(rows_buffer)

print("done")
