from pathlib import Path

import pandas as pd


ROOT_DIR = Path(__file__).resolve().parents[2]
INPUT_PATH = ROOT_DIR / "business_intelligence" / "ai_climate" / "monthly_demand_dataset.csv"
OUTPUT_PATH = ROOT_DIR / "business_intelligence" / "ai_climate" / "stock_demand_forecast.csv"


def build_time_index(data):
    data = data.copy()
    data["date"] = pd.to_datetime(
        data["year"].astype(str) + "-" + data["month"].astype(str) + "-01"
    )
    return data.sort_values("date")


def forecast_with_historical_mean(series):
    if series.empty:
        return 0.0

    return max(float(series.mean()), 0.0)


def build_recommendation_note(predicted_quantity, stock_quantity):
    if stock_quantity <= 0:
        return "Out of stock - urgent restocking required"

    if predicted_quantity > stock_quantity:
        return "Predicted demand exceeds available stock"

    if predicted_quantity >= stock_quantity * 0.75:
        return "Stock pressure expected"

    return "Stock level appears sufficient"


def main():
    if not INPUT_PATH.exists():
        raise FileNotFoundError(f"Input dataset not found: {INPUT_PATH}")

    data = pd.read_csv(INPUT_PATH)
    data = build_time_index(data)

    global_month_index = pd.date_range(
        start=data["date"].min(),
        end=data["date"].max(),
        freq="MS",
    )

    forecast_target_month = global_month_index.max() + pd.DateOffset(months=1)

    forecasts = []
    forecast_id = 1

    grouped = data.groupby(
        ["product_id", "product_name", "category", "zone_id", "zone_name"],
        as_index=False
    )

    for group_key, group_data in grouped:
        product_id, product_name, category, zone_id, zone_name = group_key

        monthly_series = (
            group_data
            .groupby("date")["monthly_quantity_sold"]
            .sum()
            .reindex(global_month_index, fill_value=0)
        )

        if monthly_series.empty:
            continue

        predicted_quantity = forecast_with_historical_mean(
            monthly_series
        )
        latest_quantity = float(monthly_series.iloc[-1])
        stock_quantity = int(group_data["stock_quantity"].iloc[-1])

        forecast_month = forecast_target_month


        forecasts.append({
            "forecast_id": forecast_id,
            "product_id": product_id,
            "product_name": product_name,
            "category": category,
            "zone_id": zone_id,
            "zone_name": zone_name,
            "forecast_month": forecast_month.strftime("%Y-%m"),
            "historical_quantity": round(latest_quantity, 2),
            "predicted_quantity": round(predicted_quantity, 2),
            "stock_quantity": stock_quantity,
            "forecast_method": "Historical monthly mean",
            "recommendation_note": build_recommendation_note(
                predicted_quantity,
                stock_quantity,
            ),
        })

        forecast_id += 1

    result = pd.DataFrame(forecasts)
    result.to_csv(OUTPUT_PATH, index=False, encoding="utf-8")

    print(f"Stock demand forecast created: {OUTPUT_PATH}")
    print(f"Rows: {len(result)}")

    if not result.empty:
        print()
        print("Forecast summary by recommendation note:")
        print(result["recommendation_note"].value_counts())


if __name__ == "__main__":
    main()