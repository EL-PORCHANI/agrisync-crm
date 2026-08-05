from pathlib import Path

import matplotlib

matplotlib.use("Agg")

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from scipy import stats
from statsmodels.graphics.tsaplots import plot_acf
from statsmodels.stats.diagnostic import acorr_ljungbox
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

FIGURE_PATH = OUTPUT_DIR / "arima_100_residual_diagnostics.png"
TESTS_PATH = OUTPUT_DIR / "arima_100_residual_tests.csv"
PARAMETERS_PATH = OUTPUT_DIR / "arima_100_parameters.csv"


def main():
    data = pd.read_csv(INPUT_PATH, parse_dates=["date"])
    data = data.sort_values("date")

    series = (
        data.set_index("date")["total_quantity"]
        .asfreq("MS")
    )

    model = ARIMA(
        series,
        order=(1, 0, 0),
    )

    fitted_model = model.fit()
    residuals = fitted_model.resid

    print("ARIMA(1,0,0) model information:")
    print(f"AIC: {fitted_model.aic:.4f}")
    print(f"BIC: {fitted_model.bic:.4f}")
    print(f"Residual mean: {residuals.mean():.4f}")
    print(f"Residual standard deviation: {residuals.std():.4f}")

    parameters = pd.DataFrame({
        "parameter": fitted_model.params.index,
        "estimate": fitted_model.params.values,
        "p_value": fitted_model.pvalues.values,
    })

    print()
    print("Model parameters:")
    print(parameters.round(4).to_string(index=False))

    # Ljung-Box residual-autocorrelation test.
    ljung_box = acorr_ljungbox(
        residuals,
        lags=[2, 3, 4],
        model_df=1,
        return_df=True,
    )

    # Shapiro-Wilk residual-normality test.
    shapiro_statistic, shapiro_p_value = stats.shapiro(
        residuals
    )

    print()
    print("Ljung-Box test:")
    print(ljung_box.round(4).to_string())

    print()
    print("Shapiro-Wilk test:")
    print(f"Statistic: {shapiro_statistic:.4f}")
    print(f"p-value: {shapiro_p_value:.4f}")

    test_rows = []

    for lag, row in ljung_box.iterrows():
        test_rows.append({
            "test": "Ljung-Box",
            "lag": lag,
            "statistic": round(row["lb_stat"], 4),
            "p_value": round(row["lb_pvalue"], 4),
            "interpretation": (
                "No significant residual autocorrelation"
                if row["lb_pvalue"] > 0.05
                else "Significant residual autocorrelation remains"
            ),
        })

    test_rows.append({
        "test": "Shapiro-Wilk",
        "lag": None,
        "statistic": round(shapiro_statistic, 4),
        "p_value": round(shapiro_p_value, 4),
        "interpretation": (
            "Residual normality is not rejected"
            if shapiro_p_value > 0.05
            else "Residual normality is rejected"
        ),
    })

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    pd.DataFrame(test_rows).to_csv(
        TESTS_PATH,
        index=False,
        encoding="utf-8",
    )

    parameters.round(6).to_csv(
        PARAMETERS_PATH,
        index=False,
        encoding="utf-8",
    )

    figure, axes = plt.subplots(2, 2, figsize=(12, 8))

    axes[0, 0].plot(
        residuals.index,
        residuals.values,
        marker="o",
        color="#3f6f78",
    )
    axes[0, 0].axhline(0, color="black", linewidth=1)
    axes[0, 0].set_title("Residuals over Time")
    axes[0, 0].grid(alpha=0.3)

    axes[0, 1].hist(
        residuals,
        bins=6,
        density=True,
        color="#74a57f",
        alpha=0.75,
        edgecolor="black",
    )

    x_values = np.linspace(
        residuals.min(),
        residuals.max(),
        100,
    )

    axes[0, 1].plot(
        x_values,
        stats.norm.pdf(
            x_values,
            residuals.mean(),
            residuals.std(),
        ),
        color="#c65d3b",
        linewidth=2,
    )
    axes[0, 1].set_title("Residual Distribution")

    stats.probplot(
        residuals,
        dist="norm",
        plot=axes[1, 0],
    )
    axes[1, 0].set_title("Normal Q-Q Plot")

    plot_acf(
        residuals,
        lags=4,
        zero=False,
        ax=axes[1, 1],
    )
    axes[1, 1].set_title("Residual ACF")

    figure.tight_layout()
    figure.savefig(
        FIGURE_PATH,
        dpi=220,
        bbox_inches="tight",
    )

    plt.close(figure)

    print()
    print(f"Diagnostic figure created: {FIGURE_PATH}")
    print(f"Residual tests saved: {TESTS_PATH}")
    print(f"Parameters saved: {PARAMETERS_PATH}")
    print(
        "Warning: residual tests remain preliminary "
        "because only 12 observations are available."
    )


if __name__ == "__main__":
    main()