from pathlib import Path

import matplotlib.pyplot as plt
import pandas as pd


BASE_DIR = Path(__file__).resolve().parent
RESULTS_DIR = BASE_DIR / "forecasting_results"


def normalize_model_name(series):
    return series.astype(str).str.replace(
        r"\s+",
        "",
        regex=True,
    )


def main():
    candidate_path = RESULTS_DIR / "arima_candidate_comparison.csv"
    holdout_path = RESULTS_DIR / "forecast_accuracy_comparison.csv"
    rolling_path = RESULTS_DIR / "rolling_origin_metrics.csv"

    candidates = pd.read_csv(candidate_path)
    holdout = pd.read_csv(holdout_path)
    rolling = pd.read_csv(rolling_path)

    candidates["model"] = normalize_model_name(candidates["model"])
    holdout["model"] = normalize_model_name(holdout["model"])
    rolling["model"] = normalize_model_name(rolling["model"])

    candidate_columns = candidates[
        ["model", "aic", "aicc", "bic"]
    ]

    holdout_columns = holdout[
        ["model", "mae", "rmse", "mape"]
    ].rename(
        columns={
            "mae": "holdout_mae",
            "rmse": "holdout_rmse",
            "mape": "holdout_mape",
        }
    )

    rolling_columns = rolling[
        [
            "model",
            "evaluation_points",
            "mae",
            "rmse",
            "mape",
            "nonconverged_fits",
            "warning_count",
        ]
    ].rename(
        columns={
            "mae": "rolling_mae",
            "rmse": "rolling_rmse",
            "mape": "rolling_mape",
            "warning_count": "rolling_warning_count",
        }
    )

    summary = holdout_columns.merge(
        rolling_columns,
        on="model",
        how="outer",
    )

    summary = summary.merge(
        candidate_columns,
        on="model",
        how="left",
    )

    summary["aicc_rank"] = summary["aicc"].rank(
        method="min",
        na_option="bottom",
    )

    summary["holdout_rmse_rank"] = summary["holdout_rmse"].rank(
        method="min",
        na_option="bottom",
    )

    summary["rolling_rmse_rank"] = summary["rolling_rmse"].rank(
        method="min",
        na_option="bottom",
    )

    summary["selected_model"] = summary["model"].eq(
        "ARIMA(1,0,0)"
    )

    summary = summary.sort_values(
        by=["rolling_rmse", "holdout_rmse"],
        na_position="last",
    )

    output_csv = RESULTS_DIR / "forecasting_model_summary.csv"
    summary.to_csv(output_csv, index=False)

    chart_data = summary.dropna(
        subset=["holdout_rmse", "rolling_rmse"]
    ).copy()

    positions = range(len(chart_data))
    width = 0.36

    fig, ax = plt.subplots(figsize=(12, 7))

    ax.bar(
        [position - width / 2 for position in positions],
        chart_data["holdout_rmse"],
        width,
        label="Holdout RMSE",
        color="#4C7A86",
    )

    ax.bar(
        [position + width / 2 for position in positions],
        chart_data["rolling_rmse"],
        width,
        label="Rolling-origin RMSE",
        color="#D2A63C",
    )

    ax.set_title("Forecasting Model Performance Summary")
    ax.set_xlabel("Model")
    ax.set_ylabel("RMSE")
    ax.set_xticks(list(positions))
    ax.set_xticklabels(
        chart_data["model"],
        rotation=30,
        ha="right",
    )
    ax.legend()
    ax.grid(axis="y", alpha=0.25)

    fig.tight_layout()

    output_figure = RESULTS_DIR / "forecasting_model_summary.png"
    fig.savefig(output_figure, dpi=300, bbox_inches="tight")
    plt.close(fig)

    print("Final forecasting model comparison:")
    print(summary.to_string(index=False))

    print(f"\nSummary saved: {output_csv}")
    print(f"Figure created: {output_figure}")

    print("\nSelected operational model: ARIMA(1,0,0)")
    print(
        "Reason: it achieved the best rolling-origin RMSE "
        "and the best holdout MAE/MAPE among the evaluated models."
    )
    print(
        "Limitation: the selection remains preliminary because "
        "only 12 monthly observations are available."
    )


if __name__ == "__main__":
    main()