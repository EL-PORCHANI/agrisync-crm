from pathlib import Path

import matplotlib

matplotlib.use("Agg")

import matplotlib.pyplot as plt
import pandas as pd


ROOT_DIR = Path(__file__).resolve().parents[2]

INPUT_PATH = (
    ROOT_DIR
    / "business_intelligence"
    / "ai_climate"
    / "global_monthly_demand.csv"
)

OUTPUT_DIR = (
    ROOT_DIR
    / "business_intelligence"
    / "ai_climate"
    / "forecasting_results"
)

OUTPUT_PATH = OUTPUT_DIR / "global_demand_time_plot.png"


def main():
    data = pd.read_csv(INPUT_PATH, parse_dates=["date"])
    data = data.sort_values("date")

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    print("Global demand descriptive statistics:")
    print(data[["total_quantity", "total_revenue"]].describe().round(2))

    figure, axes = plt.subplots(
        2,
        1,
        figsize=(11, 8),
        sharex=True,
    )

    axes[0].plot(
        data["date"],
        data["total_quantity"],
        marker="o",
        color="#3f6f78",
        linewidth=2,
    )
    axes[0].set_title("Global Monthly Quantity Sold")
    axes[0].set_ylabel("Quantity")
    axes[0].grid(alpha=0.3)

    axes[1].plot(
        data["date"],
        data["total_revenue"],
        marker="o",
        color="#74a57f",
        linewidth=2,
    )
    axes[1].set_title("Global Monthly Revenue")
    axes[1].set_xlabel("Month")
    axes[1].set_ylabel("Revenue (TND)")
    axes[1].grid(alpha=0.3)

    figure.autofmt_xdate()
    figure.tight_layout()

    figure.savefig(
        OUTPUT_PATH,
        dpi=220,
        bbox_inches="tight",
    )

    plt.close(figure)

    print()
    print(f"Time-series plot created: {OUTPUT_PATH}")


if __name__ == "__main__":
    main()
    