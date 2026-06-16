import csv
from pathlib import Path

ROOT_DIR = Path(__file__).resolve().parents[2]

WEATHER_PATH = ROOT_DIR / "business_intelligence" / "synthetic_data" / "weather_by_zone.csv"
OUTPUT_PATH = ROOT_DIR / "business_intelligence" / "ai_climate" / "climate_alerts.csv"


def read_csv(path):
    with path.open(encoding="utf-8") as file:
        return list(csv.DictReader(file))


def add_alert(alerts, alert_id, row, alert_type, severity, message, recommended_action):
    alerts.append({
        "alert_id": alert_id,
        "zone_id": row["zone_id"],
        "zone_name": row["zone_name"],
        "date": row["date"],
        "month": row["month"],
        "temperature_mean": row["temperature_mean"],
        "humidity_mean": row["humidity_mean"],
        "rainfall": row["rainfall"],
        "drought_risk": row["drought_risk"],
        "alert_type": alert_type,
        "severity": severity,
        "message": message,
        "recommended_action": recommended_action,
    })


def main():
    if not WEATHER_PATH.exists():
        raise FileNotFoundError(f"Weather dataset not found: {WEATHER_PATH}")

    weather_rows = read_csv(WEATHER_PATH)

    alerts = []
    alert_id = 1

    for row in weather_rows:
        temperature = float(row["temperature_mean"])
        humidity = float(row["humidity_mean"])
        rainfall = float(row["rainfall"])
        drought_risk = row["drought_risk"]

        if drought_risk == "high":
            add_alert(
                alerts,
                alert_id,
                row,
                "High drought risk",
                "High",
                "The zone is exposed to high drought risk.",
                "Prioritize drought-adapted products and irrigation solutions.",
            )
            alert_id += 1

        if humidity >= 85:
            add_alert(
                alerts,
                alert_id,
                row,
                "High humidity",
                "Medium",
                "Humidity level is high and may increase fungal disease risk.",
                "Recommend fungicides and crop protection products.",
            )
            alert_id += 1

        if rainfall <= 0.5 and drought_risk in {"medium", "high"}:
            add_alert(
                alerts,
                alert_id,
                row,
                "Low rainfall",
                "Medium",
                "Rainfall is very low for a climate-sensitive zone.",
                "Recommend irrigation products and soil moisture support.",
            )
            alert_id += 1

        if temperature >= 32:
            add_alert(
                alerts,
                alert_id,
                row,
                "Heat stress",
                "Medium",
                "Temperature is high and may create crop stress.",
                "Recommend climate-adapted products and field monitoring.",
            )
            alert_id += 1

    fieldnames = [
        "alert_id",
        "zone_id",
        "zone_name",
        "date",
        "month",
        "temperature_mean",
        "humidity_mean",
        "rainfall",
        "drought_risk",
        "alert_type",
        "severity",
        "message",
        "recommended_action",
    ]

    with OUTPUT_PATH.open("w", newline="", encoding="utf-8") as file:
        writer = csv.DictWriter(file, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(alerts)

    print(f"Climate alerts created: {OUTPUT_PATH}")
    print(f"Rows: {len(alerts)}")

    alert_type_counts = {}
    severity_counts = {}

    for alert in alerts:
        alert_type_counts[alert["alert_type"]] = alert_type_counts.get(alert["alert_type"], 0) + 1
        severity_counts[alert["severity"]] = severity_counts.get(alert["severity"], 0) + 1

    print()
    print("Alert type summary:")
    for alert_type, count in sorted(alert_type_counts.items()):
        print(f"- {alert_type}: {count}")

    print()
    print("Severity summary:")
    for severity, count in sorted(severity_counts.items()):
        print(f"- {severity}: {count}")


if __name__ == "__main__":
    main()