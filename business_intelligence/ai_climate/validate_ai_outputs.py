from pathlib import Path

import pandas as pd


BASE_DIR = Path(__file__).resolve().parent

FORECAST_PATH = BASE_DIR / "stock_demand_forecast.csv"
RECOMMENDATION_PATH = BASE_DIR / "product_recommendations.csv"


def expected_priority(score):
    if score >= 65:
        return "High"

    if score >= 35:
        return "Medium"

    return "Low"


def main():
    forecasts = pd.read_csv(FORECAST_PATH)
    recommendations = pd.read_csv(RECOMMENDATION_PATH)

    checks = {}

    checks["150 forecast rows"] = len(forecasts) == 150
    checks["150 recommendation rows"] = (
        len(recommendations) == 150
    )

    checks["Unique forecast product-zone pairs"] = (
        not forecasts.duplicated(
            subset=["product_id", "zone_id"]
        ).any()
    )

    checks["Unique recommendation product-zone pairs"] = (
        not recommendations.duplicated(
            subset=["product_id", "zone_id"]
        ).any()
    )

    checks["Forecast month is June 2026"] = (
        forecasts["forecast_month"].eq("2026-06").all()
    )

    checks["Validated forecast method recorded"] = (
        forecasts["forecast_method"]
        .eq("Historical monthly mean")
        .all()
    )

    calculated_scores = (
        recommendations["climate_score"]
        + recommendations["stock_score"]
        + recommendations["demand_score"]
    )

    checks["Final scores calculated correctly"] = (
        recommendations["final_score"]
        .eq(calculated_scores)
        .all()
    )

    calculated_priorities = recommendations[
        "final_score"
    ].apply(expected_priority)

    checks["Priority labels calculated correctly"] = (
        recommendations["priority"]
        .eq(calculated_priorities)
        .all()
    )

    checks["Weather reference period recorded"] = (
        recommendations["weather_reference_period"]
        .notna()
        .all()
    )

    merged = recommendations.merge(
        forecasts[
            [
                "product_id",
                "zone_id",
                "predicted_quantity",
                "stock_quantity",
                "forecast_method",
            ]
        ],
        on=["product_id", "zone_id"],
        suffixes=("_recommendation", "_forecast"),
    )

    checks["All recommendations match forecasts"] = (
        len(merged) == 150
        and merged["predicted_quantity_recommendation"]
        .eq(merged["predicted_quantity_forecast"])
        .all()
        and merged["stock_quantity_recommendation"]
        .eq(merged["stock_quantity_forecast"])
        .all()
        and merged["forecast_method_recommendation"]
        .eq(merged["forecast_method_forecast"])
        .all()
    )

    print("AI output validation:")
    for check_name, passed in checks.items():
        status = "PASS" if passed else "FAIL"
        print(f"- {status}: {check_name}")

    print("\nRecommendation priorities:")
    print(recommendations["priority"].value_counts())

    if not all(checks.values()):
        raise ValueError("One or more validation checks failed.")

    print("\nAll AI output validation checks passed.")


if __name__ == "__main__":
    main()