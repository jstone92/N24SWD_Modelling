"""Generate synthetic_sleep.csv, synthetic_light.csv, synthetic_acrophase.csv for toolbox testing."""
from __future__ import annotations

import math
import random
from datetime import datetime, timedelta
from pathlib import Path

import csv

random.seed(42)
OUT = Path(__file__).resolve().parent

N_NIGHTS = 38
ONSET0 = datetime(2021, 6, 1, 23, 0, 0)
TAU_SLEEP_H = 25.05
ONSET_NOISE_H = 0.25
WAKE_DUR_H = 7.5

sleep_rows = []
for i in range(N_NIGHTS):
    ons = ONSET0 + timedelta(hours=i * TAU_SLEEP_H + random.gauss(0, ONSET_NOISE_H))
    wak = ons + timedelta(hours=WAKE_DUR_H + random.gauss(0, 0.1))
    bed = ons.replace(hour=0, minute=0, second=0, microsecond=0)
    sleep_rows.append((bed, ons, wak))

sleep_path = OUT / "synthetic_sleep.csv"
with sleep_path.open("w", newline="", encoding="utf-8") as f:
    w = csv.writer(f)
    w.writerow(["BedTimeDate", "SleepOnset_DT", "WakeUp_DT"])
    for bed, ons, wak in sleep_rows:
        w.writerow(
            [
                bed.strftime("%Y-%m-%d"),
                ons.strftime("%Y-%m-%d %H:%M:%S"),
                wak.strftime("%Y-%m-%d %H:%M:%S"),
            ]
        )

ACRO0 = datetime(2021, 6, 1, 7, 30, 0)
acro_path = OUT / "synthetic_acrophase.csv"
with acro_path.open("w", newline="", encoding="utf-8") as f:
    w = csv.writer(f)
    w.writerow(["AcrophaseDateTime"])
    for d in (0, 12, 24):
        acro = ACRO0 + timedelta(days=d, hours=d * 1.02 + random.gauss(0, 0.15))
        w.writerow([acro.strftime("%Y-%m-%d %H:%M:%S")])

t_start = datetime(2021, 6, 1, 0, 0, 0)
t_end = sleep_rows[-1][2] + timedelta(hours=12)
step = timedelta(minutes=15)

light_path = OUT / "synthetic_light.csv"
with light_path.open("w", newline="", encoding="utf-8") as f:
    w = csv.writer(f)
    w.writerow(["DateTime", "WhiteLight", "Sleep_Wake"])
    t = t_start
    while t <= t_end:
        asleep = any(ons <= t < wak for _, ons, wak in sleep_rows)
        sw = 0 if asleep else 1
        if sw:
            hr = t.hour + t.minute / 60.0
            if 8 <= hr <= 18:
                lux = 180 + 220 * random.random() + 40 * math.sin(2 * math.pi * hr / 24)
            else:
                lux = 20 + 80 * random.random()
        else:
            lux = 0.1 + 2 * random.random()
        w.writerow([t.strftime("%Y-%m-%d %H:%M:%S"), f"{lux:.2f}", sw])
        t += step

print(f"Wrote {sleep_path.name} ({N_NIGHTS} nights)")
print(f"Wrote {acro_path.name} (3 acrophase times, every 12 days)")
print(f"Wrote {light_path.name} (15-min epochs)")
print(f"Folder: {OUT}")
