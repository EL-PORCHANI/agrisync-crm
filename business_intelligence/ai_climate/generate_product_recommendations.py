import csv
from pathlib import Path

ROOT_DIR = Path(__file__).resolve().parents[2]

FORECAST_PATH = ROOT_DIR / "business_intelligence" / "ai_climate" / "stock_demand_forecast.csv"
WEATHER_PATH = ROOT_DIR / "business_intelligence" / "synthetic_data" / "weather_by_zone.csv"
OUTPUT_PATH = ROOT_DIR / "business_intelligence" / "ai_climate" / "product_recommendations.csv"


CLIMATE_ADAPTED_CATEGORIES = {
    "Climate-adapted products",
    "Irrigation products",
    "Soil treatment",
}

HUMIDITY_SENSITIVE_CATEGORIES = {
    "Fungicides",
}

HIGH_DEMAND_NOTES = {
    "Predicted demand exceeds available stock",
    "Stock pressure expected",
}


def read_csv(path):
    with path.open(encoding="utf-8") as file:
        return list(csv.DictReader(file))


def get_latest_weather_by_zone(weather_rows):
    latest_by_zone = {}

    for row in weather_rows:
        zone_id = row["zone_id"]
        current_date = row["date"]

        if zone_id not in latest_by_zone:
            latest_by_zone[zone_id] = row
            continue

        if current_date > latest_by_zone[zone_id]["date"]:
            latest_by_zone[zone_id] = row

    return latest_by_zone


def calculate_climate_score(category, weather):
    score = 0
    reasons = []

    drought_risk = weather["drought_risk"]
    humidity = float(weather["humidity_mean"])
    rainfall = float(weather["rainfall"])

    if drought_risk == "high" and category in CLIMATE_ADAPTED_CATEGORIES:
        score += 35
        reasons.append("high drought risk supports climate-adapted or irrigation products")

    if humidity >= 75 and category in HUMIDITY_SENSITIVE_CATEGORIES:
        score += 25
        reasons.append("high humidity supports fungicide recommendation")

    if rainfall <= 1 and category in {"Irrigation products", "Soil treatment"}:
        score += 20
        reasons.append("low rainfall supports irrigation or soil treatment products")

    if drought_risk == "medium" and category in CLIMATE_ADAPTED_CATEGORIES:
        score += 15
        reasons.append("medium drought risk increases climate-related product relevance")

    return score, reasons


def calculate_stock_score(stock_quantity):
    if stock_quantity <= 0:
        return -40, ["product is out of stock"]

    if stock_quantity <= 30:
        return -15, ["stock is low, recommendation priority reduced"]

    if stock_quantity <= 80:
        return 10, ["stock is available but should be monitored"]

    return 20, ["stock availability is sufficient"]


def calculate_demand_score(recommendation_note, predicted_quantity):
    reasons = []

    if recommendation_note in HIGH_DEMAND_NOTES:
        reasons.append("ARIMA forecast indicates future stock pressure")
        return 30, reasons

    if predicted_quantity >= 10:
        reasons.append("predicted demand is commercially relevant")
        return 15, reasons

    return 5, ["predicted demand is limited but present"]


def priority_from_score(score):
    if score >= 65:
        return "High"

    if score >= 35:
        return "Medium"

    return "Low"


def main():
    if not FORECAST_PATH.exists():
        raise FileNotFoundError(f"Forecast file not found: {FORECAST_PATH}")

    if not WEATHER_PATH.exists():
        raise FileNotFoundError(f"Weather file not found: {WEATHER_PATH}")

    forecast_rows = read_csv(FORECAST_PATH)
    weather_rows = read_csv(WEATHER_PATH)
    latest_weather = get_latest_weather_by_zone(weather_rows)

    recommendations = []

    for index, forecast in enumerate(forecast_rows, start=1):
        zone_id = forecast["zone_id"]
        weather = latest_weather.get(zone_id)

        if not weather:
            continue

        category = forecast["category"]
        stock_quantity = int(forecast["stock_quantity"])
        predicted_quantity = float(forecast["predicted_quantity"])
        recommendation_note = forecast["recommendation_note"]

        climate_score, climate_reasons = calculate_climate_score(category, weather)
        stock_score, stock_reasons = calculate_stock_score(stock_quantity)
        demand_score, demand_reasons = calculate_demand_score(
            recommendation_note,
            predicted_quantity,
        )

        final_score = climate_score + stock_score + demand_score
        priority = priority_from_score(final_score)

        reasons = climate_reasons + stock_reasons + demand_reasons

        recommendations.append({
            "recommendation_id": index,
            "product_id": forecast["product_id"],
            "product_name": forecast["product_name"],
            "category": category,
            "zone_id": zone_id,
            "zone_name": forecast["zone_name"],
            "forecast_month": forecast["forecast_month"],
            "drought_risk": weather["drought_risk"],
            "humidity_mean": weather["humidity_mean"],
            "rainfall": weather["rainfall"],
            "predicted_quantity": round(predicted_quantity, 2),
            "stock_quantity": stock_quantity,
            "climate_score": climate_score,
            "stock_score": stock_score,
            "demand_score": demand_score,
            "final_score": final_score,
            "priority": priority,
            "recommendation_reason": "; ".join(reasons),
        })

    fieldnames = [
        "recommendation_id",
        "product_id",
        "product_name",
        "category",
        "zone_id",
        "zone_name",
        "forecast_month",
        "drought_risk",
        "humidity_mean",
        "rainfall",
        "predicted_quantity",
        "stock_quantity",
        "climate_score",
        "stock_score",
        "demand_score",
        "final_score",
        "priority",
        "recommendation_reason",
    ]

    with OUTPUT_PATH.open("w", newline="", encoding="utf-8") as file:
        writer = csv.DictWriter(file, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(recommendations)

    print(f"Product recommendations created: {OUTPUT_PATH}")
    print(f"Rows: {len(recommendations)}")

    priority_counts = {}
    for row in recommendations:
        priority_counts[row["priority"]] = priority_counts.get(row["priority"], 0) + 1

    print()
    print("Recommendation priority summary:")
    for priority, count in sorted(priority_counts.items()):
        print(f"- {priority}: {count}")


if __name__ == "__main__":
    main()