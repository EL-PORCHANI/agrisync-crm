import pandas as pd
from pathlib import Path


ROOT_DIR = Path(__file__).resolve().parents[2]

INPUT_PATH = (
    ROOT_DIR
    / "business_intelligence"
    / "ai_climate"
    / "monthly_demand_dataset.csv"
)

OUTPUT_PATH = (
    ROOT_DIR
    / "business_intelligence"
    / "ai_climate"
    / "global_monthly_demand.csv"
)


def main():
    data = pd.read_csv(INPUT_PATH)

    data["date"] = pd.to_datetime(
        data["year"].astype(str)
        + "-"
        + data["month"].astype(str)
        + "-01"
    )

    monthly_series = (
        data.groupby("date", as_index=False)
        .agg(
            total_quantity=("monthly_quantity_sold", "sum"),
            total_revenue=("monthly_revenue", "sum"),
        )
        .sort_values("date")
    )

    monthly_series["total_revenue"] = (
    monthly_series["total_revenue"].round(2)
)

    monthly_series.to_csv(
        OUTPUT_PATH,
        index=False,
        encoding="utf-8",
    )

    print(f"Global monthly demand created: {OUTPUT_PATH}")
    print(f"Rows: {len(monthly_series)}")
    print()
    print(monthly_series.to_string(index=False))


if __name__ == "__main__":
    main()