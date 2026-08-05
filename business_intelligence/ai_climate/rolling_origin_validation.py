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

METRICS_PATH = OUTPUT_DIR / "rolling_origin_metrics.csv"
PREDICTIONS_PATH = OUTPUT_DIR / "rolling_origin_predictions.csv"
FIGURE_PATH = OUTPUT_DIR / "rolling_origin_comparison.png"


MODELS = {
    "ARIMA(0,0,0)": (0, 0, 0),
    "ARIMA(1,0,0)": (1, 0, 0),
    "ARIMA(0,0,1)": (0, 0, 1),
    "ARIMA(1,1,1)": (1, 1, 1),
}


def calculate_metrics(actual, predicted):
    actual = np.asarray(actual, dtype=float)
    predicted = np.asarray(predicted, dtype=float)

    errors = actual - predicted

    return {
        "mae": np.mean(np.abs(errors)),
        "rmse": np.sqrt(np.mean(errors ** 2)),
        "mape": np.mean(np.abs(errors / actual)) * 100,
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

    initial_train_size = 6
    prediction_rows = []

    for test_position in range(initial_train_size, len(series)):
        train = series.iloc[:test_position]
        test_date = series.index[test_position]
        actual = float(series.iloc[test_position])

        baseline_predictions = {
            "Historical Mean": float(train.mean()),
            "Last Value": float(train.iloc[-1]),
        }

        for model_name, prediction in baseline_predictions.items():
            prediction_rows.append({
                "date": test_date,
                "model": model_name,
                "actual": actual,
                "predicted": prediction,
                "converged": True,
                "warning_count": 0,
            })

        for model_name, order in MODELS.items():
            try:
                with warnings.catch_warnings(record=True) as captured:
                    warnings.simplefilter("always")

                    fitted_model = ARIMA(
                        train,
                        order=order,
                    ).fit()

                    forecast = fitted_model.forecast(steps=1)

                prediction = max(float(forecast.iloc[0]), 0)

                prediction_rows.append({
                    "date": test_date,
                    "model": model_name,
                    "actual": actual,
                    "predicted": prediction,
                    "converged": fitted_model.mle_retvals.get(
                        "converged",
                        True,
                    ),
                    "warning_count": len(captured),
                })

            except Exception as error:
                prediction_rows.append({
                    "date": test_date,
                    "model": model_name,
                    "actual": actual,
                    "predicted": np.nan,
                    "converged": False,
                    "warning_count": np.nan,
                    "error": str(error),
                })

    predictions = pd.DataFrame(prediction_rows)

    metric_rows = []

    for model_name, model_data in predictions.groupby("model"):
        valid = model_data.dropna(subset=["predicted"])

        metrics = calculate_metrics(
            valid["actual"],
            valid["predicted"],
        )

        metric_rows.append({
            "model": model_name,
            "evaluation_points": len(valid),
            "mae": round(metrics["mae"], 4),
            "rmse": round(metrics["rmse"], 4),
            "mape": round(metrics["mape"], 4),
            "nonconverged_fits": int(
                (~valid["converged"]).sum()
            ),
            "warning_count": int(
                valid["warning_count"].fillna(0).sum()
            ),
        })

    metrics = pd.DataFrame(metric_rows).sort_values(
        by=["rmse", "mae"],
    )

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    predictions.to_csv(
        PREDICTIONS_PATH,
        index=False,
        encoding="utf-8",
    )

    metrics.to_csv(
        METRICS_PATH,
        index=False,
        encoding="utf-8",
    )

    print("Rolling-origin model comparison:")
    print(metrics.to_string(index=False))

    figure, axis = plt.subplots(figsize=(11, 6))

    evaluation_dates = sorted(predictions["date"].unique())

    actual_values = (
        predictions[
            predictions["model"] == "Historical Mean"
        ]
        .sort_values("date")
    )

    axis.plot(
        actual_values["date"],
        actual_values["actual"],
        marker="o",
        linewidth=2.5,
        color="#222222",
        label="Actual",
    )

    colors = {
        "Historical Mean": "#74a57f",
        "Last Value": "#d6aa3d",
        "ARIMA(0,0,0)": "#3f6f78",
        "ARIMA(1,0,0)": "#8a6d9e",
        "ARIMA(0,0,1)": "#c65d3b",
        "ARIMA(1,1,1)": "#cc3333",
    }

    for model_name, color in colors.items():
        model_data = predictions[
            predictions["model"] == model_name
        ].sort_values("date")

        axis.plot(
            model_data["date"],
            model_data["predicted"],
            marker="s",
            linestyle="--",
            color=color,
            label=model_name,
        )

    axis.set_title("Rolling-Origin One-Step Forecast Comparison")
    axis.set_xlabel("Forecast Month")
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
    print(f"Predictions saved: {PREDICTIONS_PATH}")
    print(f"Figure created: {FIGURE_PATH}")


if __name__ == "__main__":
    main()