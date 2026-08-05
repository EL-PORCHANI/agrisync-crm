from pathlib import Path

import matplotlib

matplotlib.use("Agg")

import matplotlib.pyplot as plt
import pandas as pd
from statsmodels.graphics.tsaplots import plot_acf, plot_pacf
from statsmodels.tsa.stattools import acf, pacf


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

OUTPUT_PATH = OUTPUT_DIR / "demand_acf_pacf.png"


def main():
    data = pd.read_csv(INPUT_PATH, parse_dates=["date"])
    data = data.sort_values("date")

    series = data["total_quantity"]

    # Twelve observations only support a small number of lags.
    maximum_lag = 4

    acf_values = acf(
        series,
        nlags=maximum_lag,
        fft=False,
    )

    pacf_values = pacf(
        series,
        nlags=maximum_lag,
        method="ywm",
    )

    print("ACF values:")
    for lag, value in enumerate(acf_values):
        print(f"Lag {lag}: {value:.4f}")

    print()
    print("PACF values:")
    for lag, value in enumerate(pacf_values):
        print(f"Lag {lag}: {value:.4f}")

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    figure, axes = plt.subplots(1, 2, figsize=(11, 4.5))

    plot_acf(
        series,
        lags=maximum_lag,
        ax=axes[0],
        zero=False,
    )
    axes[0].set_title("ACF of Monthly Demand")

    plot_pacf(
        series,
        lags=maximum_lag,
        method="ywm",
        ax=axes[1],
        zero=False,
    )
    axes[1].set_title("PACF of Monthly Demand")

    figure.tight_layout()
    figure.savefig(
        OUTPUT_PATH,
        dpi=220,
        bbox_inches="tight",
    )

    plt.close(figure)

    print()
    print(f"ACF/PACF figure created: {OUTPUT_PATH}")
    print(
        "Warning: interpret these plots cautiously because "
        "the series contains only 12 observations."
    )


if __name__ == "__main__":
    main()