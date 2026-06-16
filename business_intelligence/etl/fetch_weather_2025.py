import csv
import json
import time
import urllib.parse
import urllib.request
from pathlib import Path

ROOT_DIR = Path(__file__).resolve().parents[2]
OUTPUT_DIR = ROOT_DIR / "business_intelligence" / "synthetic_data"
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

OUTPUT_FILE = OUTPUT_DIR / "weather_by_zone.csv"

ZONES = [
    {"zone_id": 1, "zone_name": "Nabeul", "latitude": 36.4561, "longitude": 10.7376},
    {"zone_id": 2, "zone_name": "Sfax", "latitude": 34.7406, "longitude": 10.7603},
    {"zone_id": 3, "zone_name": "Beja", "latitude": 36.7333, "longitude": 9.1833},
    {"zone_id": 4, "zone_name": "Kairouan", "latitude": 35.6781, "longitude": 10.0963},
    {"zone_id": 5, "zone_name": "Gabes", "latitude": 33.8815, "longitude": 10.0982},
]

START_DATE = "2025-01-01"
END_DATE = "2025-12-31"

DAILY_VARIABLES = [
    "temperature_2m_max",
    "temperature_2m_min",
    "temperature_2m_mean",
    "relative_humidity_2m_mean",
    "precipitation_sum",
]


def calculate_drought_risk(precipitation, temperature):
    if precipitation < 1 and temperature >= 30:
        return "high"

    if precipitation < 2:
        return "medium"

    if temperature >= 35 and precipitation < 5:
        return "medium"

    return "low"


def fetch_zone_weather(zone):
    params = {
        "latitude": zone["latitude"],
        "longitude": zone["longitude"],
        "start_date": START_DATE,
        "end_date": END_DATE,
        "daily": ",".join(DAILY_VARIABLES),
        "timezone": "Africa/Tunis",
    }

    url = "https://archive-api.open-meteo.com/v1/archive?" + urllib.parse.urlencode(params)

    print(f"Fetching weather data for {zone['zone_name']}...")
    with urllib.request.urlopen(url, timeout=30) as response:
        data = json.loads(response.read().decode("utf-8"))

    daily = data["daily"]
    rows = []

    for index, date_value in enumerate(daily["time"]):
        precipitation = daily["precipitation_sum"][index]
        temperature_mean = daily["temperature_2m_mean"][index]

        rows.append({
            "zone_id": zone["zone_id"],
            "zone_name": zone["zone_name"],
            "date": date_value,
            "year": int(date_value[:4]),
            "month": int(date_value[5:7]),
            "temperature_max": daily["temperature_2m_max"][index],
            "temperature_min": daily["temperature_2m_min"][index],
            "temperature_mean": temperature_mean,
            "humidity_mean": daily["relative_humidity_2m_mean"][index],
            "rainfall": precipitation,
            "drought_risk": calculate_drought_risk(precipitation, temperature_mean),
        })

    return rows


def main():
    all_rows = []

    for zone in ZONES:
        zone_rows = fetch_zone_weather(zone)
        all_rows.extend(zone_rows)

        # Small pause to be polite with the public API.
        time.sleep(1)

    fieldnames = [
        "zone_id",
        "zone_name",
        "date",
        "year",
        "month",
        "temperature_max",
        "temperature_min",
        "temperature_mean",
        "humidity_mean",
        "rainfall",
        "drought_risk",
    ]

    with OUTPUT_FILE.open("w", newline="", encoding="utf-8") as csv_file:
        writer = csv.DictWriter(csv_file, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(all_rows)

    print(f"Generated {OUTPUT_FILE}")
    print(f"Rows: {len(all_rows)}")


if __name__ == "__main__":
    main()