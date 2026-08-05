import warnings
from pathlib import Path

import matplotlib

matplotlib.use("Agg")

import matplotlib.pyplot as plt
import numpy as np
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

METRICS_PATH = OUTPUT_DIR / "forecast_accuracy_comparison.csv"
FORECAST_PATH = OUTPUT_DIR / "forecast_test_predictions.csv"
FIGURE_PATH = OUTPUT_DIR / "forecast_comparison.png"


ARIMA_MODELS = {
    "ARIMA(0,0,0)": (0, 0, 0),
    "ARIMA(1,0,0)": (1, 0, 0),
    "ARIMA(0,0,1)": (0, 0, 1),
    "ARIMA(1,1,1)": (1, 1, 1),
}


def calculate_metrics(actual, predicted):
    actual = np.asarray(actual, dtype=float)
    predicted = np.asarray(predicted, dtype=float)

    errors = actual - predicted

    mae = np.mean(np.abs(errors))
    rmse = np.sqrt(np.mean(errors ** 2))
    mape = np.mean(
        np.abs(errors / actual)
    ) * 100

    return {
        "mae": round(mae, 4),
        "rmse": round(rmse, 4),
        "mape": round(mape, 4),
    }


def main():
    data = pd.read_csv(INPUT_PATH, parse_dates=["date"])
    data = data.sort_values("date")

    series = (
        data.set_index("date")["total_quantity"]
        .asfreq("MS")
    )

    if series.isna().any():
        raise ValueError("The series contains missing months.")

    train = series.iloc[:-3]
    test = series.iloc[-3:]

    predictions = pd.DataFrame({
        "date": test.index,
        "actual": test.values,
    })

    metrics_rows = []

    # Baseline 1: historical training mean
    mean_forecast = np.repeat(
        train.mean(),
        len(test),
    )

    predictions["Historical Mean"] = mean_forecast

    metrics_rows.append({
        "model": "Historical Mean",
        **calculate_metrics(test.values, mean_forecast),
        "converged": True,
        "warning_count": 0,
    })

    # Baseline 2: latest observed training value
    last_value_forecast = np.repeat(
        train.iloc[-1],
        len(test),
    )

    predictions["Last Value"] = last_value_forecast

    metrics_rows.append({
        "model": "Last Value",
        **calculate_metrics(
            test.values,
            last_value_forecast,
        ),
        "converged": True,
        "warning_count": 0,
    })

    # ARIMA candidates
    for model_name, order in ARIMA_MODELS.items():
        try:
            with warnings.catch_warnings(record=True) as captured:
                warnings.simplefilter("always")

                fitted_model = ARIMA(
                    train,
                    order=order,
                ).fit()

                forecast = fitted_model.forecast(
                    steps=len(test)
                )

            forecast_values = np.maximum(
                np.asarray(forecast, dtype=float),
                0,
            )

            converged = fitted_model.mle_retvals.get(
                "converged",
                True,
            )

            predictions[model_name] = forecast_values

            metrics_rows.append({
                "model": model_name,
                **calculate_metrics(
                    test.values,
                    forecast_values,
                ),
                "converged": converged,
                "warning_count": len(captured),
            })

        except Exception as error:
            metrics_rows.append({
                "model": model_name,
                "mae": None,
                "rmse": None,
                "mape": None,
                "converged": False,
                "warning_count": None,
                "error": str(error),
            })

    metrics = pd.DataFrame(metrics_rows)
    metrics = metrics.sort_values(
        by=["rmse", "mae"],
        na_position="last",
    )

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    metrics.to_csv(
        METRICS_PATH,
        index=False,
        encoding="utf-8",
    )

    predictions.to_csv(
        FORECAST_PATH,
        index=False,
        encoding="utf-8",
    )

    print("Training period:")
    print(f"{train.index.min().date()} to {train.index.max().date()}")

    print()
    print("Testing period:")
    print(f"{test.index.min().date()} to {test.index.max().date()}")

    print()
    print("Forecast accuracy comparison:")
    print(metrics.to_string(index=False))

    figure, axis = plt.subplots(figsize=(11, 6))

    axis.plot(
        series.index,
        series.values,
        marker="o",
        color="#333333",
        linewidth=2,
        label="Observed demand",
    )

    colors = {
        "Historical Mean": "#74a57f",
        "Last Value": "#d6aa3d",
        "ARIMA(0,0,0)": "#3f6f78",
        "ARIMA(1,0,0)": "#8a6d9e",
        "ARIMA(0,0,1)": "#c65d3b",
        "ARIMA(1,1,1)": "#cc3333",
    }

    for model_name in colors:
        if model_name not in predictions.columns:
            continue

        axis.plot(
            predictions["date"],
            predictions[model_name],
            marker="s",
            linestyle="--",
            color=colors[model_name],
            label=model_name,
        )

    axis.axvline(
        test.index.min(),
        color="black",
        linestyle=":",
        label="Test period begins",
    )

    axis.set_title("Out-of-Sample Demand Forecast Comparison")
    axis.set_xlabel("Month")
    axis.set_ylabel("Quantity")
    axis.grid(alpha=0.3)
    axis.legend(fontsize=8)

    figure.autofmt_xdate()
    figure.tight_layout()
    figure.savefig(
        FIGURE_PATH,
        dpi=220,
        bbox_inches="tight",
    )

    plt.close(figure)

    print()
    print(f"Metrics saved: {METRICS_PATH}")
    print(f"Predictions saved: {FORECAST_PATH}")
    print(f"Figure created: {FIGURE_PATH}")


if __name__ == "__main__":
    main()