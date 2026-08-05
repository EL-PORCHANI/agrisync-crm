from pathlib import Path

import pandas as pd
from statsmodels.tsa.stattools import adfuller


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

OUTPUT_PATH = OUTPUT_DIR / "stationarity_results.csv"


def run_adf_test(series, series_name):
    result = adfuller(
        series.dropna(),
        maxlag=2,
        autolag="AIC",
    )

    statistic = result[0]
    p_value = result[1]
    used_lag = result[2]
    observations = result[3]
    critical_values = result[4]

    conclusion = (
        "stationary"
        if p_value < 0.05
        else "non-stationary"
    )

    print()
    print(f"ADF Test: {series_name}")
    print(f"ADF statistic: {statistic:.4f}")
    print(f"p-value: {p_value:.4f}")
    print(f"Used lag: {used_lag}")
    print(f"Observations: {observations}")
    print(f"Conclusion: {conclusion}")

    for level, value in critical_values.items():
        print(f"Critical value ({level}): {value:.4f}")

    return {
        "series": series_name,
        "adf_statistic": round(statistic, 4),
        "p_value": round(p_value, 4),
        "used_lag": used_lag,
        "observations": observations,
        "conclusion": conclusion,
    }


def main():
    data = pd.read_csv(INPUT_PATH, parse_dates=["date"])
    data = data.sort_values("date")

    original_series = data["total_quantity"]
    differenced_series = original_series.diff().dropna()

    results = [
        run_adf_test(
            original_series,
            "Original monthly demand",
        ),
        run_adf_test(
            differenced_series,
            "First-differenced monthly demand",
        ),
    ]

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    pd.DataFrame(results).to_csv(
        OUTPUT_PATH,
        index=False,
        encoding="utf-8",
    )

    print()
    print(f"Stationarity results saved: {OUTPUT_PATH}")
    print()
    print(
        "Warning: the series contains only 12 months, "
        "so the ADF conclusions are preliminary."
    )


if __name__ == "__main__":
    main()