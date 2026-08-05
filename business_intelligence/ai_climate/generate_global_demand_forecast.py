from pathlib import Path

import matplotlib

matplotlib.use("Agg")

import matplotlib.pyplot as plt
import pandas as pd
from statsmodels.tsa.arima.model import ARIMA


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

FORECAST_PATH = OUTPUT_DIR / "global_demand_forecast.csv"
FIGURE_PATH = OUTPUT_DIR / "arima_100_final_forecast.png"


def main():
    data = pd.read_csv(INPUT_PATH, parse_dates=["date"])
    data = data.sort_values("date")

    series = (
        data.set_index("date")["total_quantity"]
        .asfreq("MS")
    )

    if series.isna().any():
        raise ValueError("The series contains missing months.")

    fitted_model = ARIMA(
        series,
        order=(1, 0, 0),
    ).fit()

    forecast_result = fitted_model.get_forecast(steps=1)

    forecast_summary = forecast_result.summary_frame(
        alpha=0.05
    )

    forecast_date = (
        series.index.max()
        + pd.offsets.MonthBegin(1)
    )

    predicted_quantity = max(
        float(forecast_summary["mean"].iloc[0]),
        0,
    )

    lower_bound = max(
        float(forecast_summary["mean_ci_lower"].iloc[0]),
        0,
    )

    upper_bound = max(
        float(forecast_summary["mean_ci_upper"].iloc[0]),
        0,
    )

    output = pd.DataFrame([{
        "forecast_month": forecast_date.strftime("%Y-%m"),
        "model": "ARIMA(1,0,0)",
        "predicted_quantity": round(
            predicted_quantity,
            2,
        ),
        "lower_95": round(lower_bound, 2),
        "upper_95": round(upper_bound, 2),
        "aic": round(fitted_model.aic, 4),
        "bic": round(fitted_model.bic, 4),
    }])

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    output.to_csv(
        FORECAST_PATH,
        index=False,
        encoding="utf-8",
    )

    print("Final aggregate demand forecast:")
    print(output.to_string(index=False))

    figure, axis = plt.subplots(figsize=(11, 6))

    axis.plot(
        series.index,
        series.values,
        marker="o",
        linewidth=2,
        color="#333333",
        label="Historical demand",
    )

    axis.scatter(
        [forecast_date],
        [predicted_quantity],
        color="#c65d3b",
        marker="s",
        s=90,
        label="ARIMA forecast",
        zorder=3,
    )

    axis.plot(
        [series.index.max(), forecast_date],
        [series.iloc[-1], predicted_quantity],
        color="#c65d3b",
        linestyle="--",
    )

    axis.fill_between(
        [series.index.max(), forecast_date],
        [series.iloc[-1], lower_bound],
        [series.iloc[-1], upper_bound],
        color="#c65d3b",
        alpha=0.2,
        label="95% confidence interval",
    )

    axis.set_title(
        "Aggregate Monthly Demand Forecast for June 2026"
    )
    axis.set_xlabel("Month")
    axis.set_ylabel("Quantity")
    axis.grid(alpha=0.3)
    axis.legend()

    figure.autofmt_xdate()
    figure.tight_layout()

    figure.savefig(
        FIGURE_PATH,
        dpi=220,
        bbox_inches="tight",
    )

    plt.close(figure)

    print()
    print(f"Forecast saved: {FORECAST_PATH}")
    print(f"Figure created: {FIGURE_PATH}")
    print(
        "The confidence interval is expected to be wide "
        "because only 12 observations are available."
    )


if __name__ == "__main__":
    main()