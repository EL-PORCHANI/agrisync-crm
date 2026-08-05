import warnings
from pathlib import Path

import numpy as np
import pandas as pd
from statsmodels.tsa.arima.model import ARIMA


BASE_DIR = Path(__file__).resolve().parent
INPUT_PATH = BASE_DIR / "monthly_demand_dataset.csv"
RESULTS_DIR = BASE_DIR / "forecasting_results"


def fit_arima(train, order):
    try:
        with warnings.catch_warnings(record=True) as caught:
            warnings.simplefilter("always")

            fitted = ARIMA(train, order=order).fit()
            prediction = float(
                np.asarray(fitted.forecast(steps=1))[0]
            )

        converged = fitted.mle_retvals.get("converged", True)

        return max(prediction, 0), converged, len(caught)

    except Exception:
        return None, False, 1


def historical_mean(train):
    return max(float(train.mean()), 0)


def recent_mean(train):
    return max(float(train.tail(3).mean()), 0)


def current_arima_strategy(train):
    prediction, converged, warning_count = fit_arima(
        train,
        (1, 1, 1),
    )

    if prediction is None or not converged:
        return recent_mean(train), "Recent3Mean fallback", warning_count

    return prediction, "ARIMA(1,1,1)", warning_count


def hybrid_strategy(train):
    active_months = int((train > 0).sum())
    coverage = active_months / len(train)

    eligible = (
        len(train) >= 8
        and active_months >= 6
        and coverage >= 0.75
    )

    if eligible:
        prediction, converged, warning_count = fit_arima(
            train,
            (1, 0, 0),
        )

        if prediction is not None and converged:
            return prediction, "ARIMA(1,0,0)", warning_count

    return historical_mean(train), "HistoricalMean", 0


def calculate_metrics(data, prediction_column):
    actual = data["actual_quantity"]
    predicted = data[prediction_column]

    error = actual - predicted

    mae = np.mean(np.abs(error))
    rmse = np.sqrt(np.mean(error ** 2))

    total_actual = np.sum(np.abs(actual))
    wape = (
        np.sum(np.abs(error)) / total_actual * 100
        if total_actual > 0
        else np.nan
    )

    return {
        "strategy": prediction_column,
        "evaluation_points": len(data),
        "mae": round(mae, 4),
        "rmse": round(rmse, 4),
        "wape": round(wape, 4),
    }


def main():
    data = pd.read_csv(INPUT_PATH)

    data["date"] = pd.to_datetime(
        data["year"].astype(str)
        + "-"
        + data["month"].astype(str)
        + "-01"
    )

    calendar = pd.date_range(
        data["date"].min(),
        data["date"].max(),
        freq="MS",
    )

    group_columns = [
        "product_id",
        "product_name",
        "category",
        "zone_id",
        "zone_name",
    ]

    predictions = []

    for group_key, group_data in data.groupby(group_columns):
        series = (
            group_data.groupby("date")["monthly_quantity_sold"]
            .sum()
            .reindex(calendar, fill_value=0)
            .astype(float)
        )

        for split_index in range(6, len(series)):
            train = series.iloc[:split_index]
            actual = float(series.iloc[split_index])

            current_prediction, current_method, current_warnings = (
                current_arima_strategy(train)
            )

            hybrid_prediction, hybrid_method, hybrid_warnings = (
                hybrid_strategy(train)
            )

            predictions.append(
                {
                    "product_id": group_key[0],
                    "product_name": group_key[1],
                    "zone_id": group_key[3],
                    "zone_name": group_key[4],
                    "forecast_month": series.index[
                        split_index
                    ].strftime("%Y-%m"),
                    "actual_quantity": actual,
                    "historical_mean": historical_mean(train),
                    "recent_3_month_mean": recent_mean(train),
                    "last_value": max(float(train.iloc[-1]), 0),
                    "current_arima_111": current_prediction,
                    "current_method_used": current_method,
                    "current_warning_count": current_warnings,
                    "proposed_hybrid": hybrid_prediction,
                    "hybrid_method_used": hybrid_method,
                    "hybrid_warning_count": hybrid_warnings,
                }
            )

    predictions_df = pd.DataFrame(predictions)

    strategy_columns = [
        "historical_mean",
        "recent_3_month_mean",
        "last_value",
        "current_arima_111",
        "proposed_hybrid",
    ]

    metrics = pd.DataFrame(
        [
            calculate_metrics(predictions_df, column)
            for column in strategy_columns
        ]
    ).sort_values("rmse")

    RESULTS_DIR.mkdir(parents=True, exist_ok=True)

    predictions_path = (
        RESULTS_DIR / "product_zone_strategy_predictions.csv"
    )
    metrics_path = (
        RESULTS_DIR / "product_zone_strategy_metrics.csv"
    )

    predictions_df.to_csv(predictions_path, index=False)
    metrics.to_csv(metrics_path, index=False)

    print("Product-zone forecasting strategy comparison:")
    print(metrics.to_string(index=False))

    print("\nHybrid method usage:")
    print(predictions_df["hybrid_method_used"].value_counts())

    print("\nCurrent ARIMA method usage:")
    print(predictions_df["current_method_used"].value_counts())

    print(
        "\nZero-demand evaluation points:",
        int((predictions_df["actual_quantity"] == 0).sum()),
    )

    print(f"\nMetrics saved: {metrics_path}")
    print(f"Predictions saved: {predictions_path}")


if __name__ == "__main__":
    main()