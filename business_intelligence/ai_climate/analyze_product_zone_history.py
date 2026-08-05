from pathlib import Path

import pandas as pd


BASE_DIR = Path(__file__).resolve().parent
INPUT_PATH = BASE_DIR / "monthly_demand_dataset.csv"
OUTPUT_PATH = (
    BASE_DIR
    / "forecasting_results"
    / "product_zone_history_coverage.csv"
)


def classify_series(active_months):
    if active_months >= 9:
        return "Limited ARIMA candidate"

    if active_months >= 6:
        return "Baseline model preferred"

    return "Sparse series - baseline only"


def main():
    data = pd.read_csv(INPUT_PATH)

    data["date"] = pd.to_datetime(
        data["year"].astype(str)
        + "-"
        + data["month"].astype(str)
        + "-01"
    )

    calendar = pd.date_range(
        start=data["date"].min(),
        end=data["date"].max(),
        freq="MS",
    )

    group_columns = [
        "product_id",
        "product_name",
        "category",
        "zone_id",
        "zone_name",
    ]

    coverage_rows = []

    for group_key, group_data in data.groupby(group_columns):
        (
            product_id,
            product_name,
            category,
            zone_id,
            zone_name,
        ) = group_key

        active_months = group_data["date"].nunique()
        calendar_months = len(calendar)
        zero_months = calendar_months - active_months

        complete_series = (
            group_data.groupby("date")["monthly_quantity_sold"]
            .sum()
            .reindex(calendar, fill_value=0)
        )

        coverage_rows.append(
            {
                "product_id": product_id,
                "product_name": product_name,
                "category": category,
                "zone_id": zone_id,
                "zone_name": zone_name,
                "calendar_months": calendar_months,
                "active_months": active_months,
                "zero_months": zero_months,
                "coverage_percentage": round(
                    active_months / calendar_months * 100,
                    2,
                ),
                "total_quantity": int(complete_series.sum()),
                "average_monthly_quantity": round(
                    complete_series.mean(),
                    2,
                ),
                "series_variance": round(
                    complete_series.var(),
                    2,
                ),
                "recommended_approach": classify_series(
                    active_months
                ),
            }
        )

    result = pd.DataFrame(coverage_rows)
    result = result.sort_values(
        by=["active_months", "total_quantity"],
        ascending=[True, False],
    )

    OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    result.to_csv(OUTPUT_PATH, index=False)

    print("Product-zone history coverage analysis")
    print(f"Period: {calendar.min():%Y-%m} to {calendar.max():%Y-%m}")
    print(f"Calendar months: {len(calendar)}")
    print(f"Product-zone series: {len(result)}")

    print("\nActive-month statistics:")
    print(result["active_months"].describe().round(2))

    print("\nRecommended approach distribution:")
    print(result["recommended_approach"].value_counts())

    print("\nCoverage distribution:")
    print(
        result["coverage_percentage"]
        .describe()
        .round(2)
    )

    print(f"\nResults saved: {OUTPUT_PATH}")


if __name__ == "__main__":
    main()