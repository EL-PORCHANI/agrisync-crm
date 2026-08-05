from pathlib import Path

import matplotlib

matplotlib.use("Agg")

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from scipy.stats import pearsonr, spearmanr
from statsmodels.stats.multitest import multipletests


ROOT_DIR = Path(__file__).resolve().parents[2]

DATA_DIR = ROOT_DIR / "business_intelligence" / "synthetic_data"

OUTPUT_DIR = (
    ROOT_DIR
    / "business_intelligence"
    / "ai_climate"
    / "forecasting_results"
)

MERGED_PATH = OUTPUT_DIR / "sales_climate_monthly.csv"
MATRIX_PATH = OUTPUT_DIR / "sales_climate_correlation_matrix.csv"
TESTS_PATH = OUTPUT_DIR / "sales_climate_correlation_tests.csv"
HEATMAP_PATH = OUTPUT_DIR / "sales_climate_correlation_heatmap.png"
SCATTER_PATH = OUTPUT_DIR / "sales_climate_scatter_plots.png"


SALES_VARIABLES = [
    "quantity",
    "revenue",
    "order_count",
]

CLIMATE_VARIABLES = [
    "temperature_mean",
    "humidity_mean",
    "rainfall",
    "high_drought_days",
]


def prepare_sales_data():
    orders = pd.read_csv(
        DATA_DIR / "orders.csv",
        parse_dates=["order_date"],
    )

    order_lines = pd.read_csv(
        DATA_DIR / "order_lines.csv"
    )

    orders["month"] = (
        orders["order_date"]
        .dt.to_period("M")
        .astype(str)
    )

    sales_lines = order_lines.merge(
        orders[
            [
                "order_id",
                "zone_id",
                "zone_name",
                "month",
            ]
        ],
        on="order_id",
        how="inner",
    )

    sales_monthly = (
        sales_lines.groupby(
            ["zone_id", "zone_name", "month"],
            as_index=False,
        )
        .agg(
            quantity=("quantity", "sum"),
            revenue=("line_total", "sum"),
        )
    )

    order_counts = (
        orders.groupby(
            ["zone_id", "zone_name", "month"],
            as_index=False,
        )
        .agg(order_count=("order_id", "nunique"))
    )

    return sales_monthly.merge(
        order_counts,
        on=["zone_id", "zone_name", "month"],
        how="inner",
    )


def prepare_weather_data():
    weather = pd.read_csv(
        DATA_DIR / "weather_by_zone.csv",
        parse_dates=["date"],
    )

    weather["month"] = (
        weather["date"]
        .dt.to_period("M")
        .astype(str)
    )

    weather["is_high_drought"] = (
        weather["drought_risk"] == "high"
    ).astype(int)

    return (
        weather.groupby(
            ["zone_id", "zone_name", "month"],
            as_index=False,
        )
        .agg(
            temperature_mean=(
                "temperature_mean",
                "mean",
            ),
            humidity_mean=(
                "humidity_mean",
                "mean",
            ),
            rainfall=("rainfall", "sum"),
            high_drought_days=(
                "is_high_drought",
                "sum",
            ),
        )
    )


def create_heatmap(correlation_matrix):
    figure, axis = plt.subplots(figsize=(10, 8))

    image = axis.imshow(
        correlation_matrix,
        cmap="coolwarm",
        vmin=-1,
        vmax=1,
    )

    axis.set_xticks(
        range(len(correlation_matrix.columns))
    )
    axis.set_xticklabels(
        correlation_matrix.columns,
        rotation=45,
        ha="right",
    )

    axis.set_yticks(
        range(len(correlation_matrix.index))
    )
    axis.set_yticklabels(correlation_matrix.index)

    for row in range(len(correlation_matrix.index)):
        for column in range(
            len(correlation_matrix.columns)
        ):
            value = correlation_matrix.iloc[row, column]

            axis.text(
                column,
                row,
                f"{value:.2f}",
                ha="center",
                va="center",
                color=(
                    "white"
                    if abs(value) > 0.55
                    else "black"
                ),
            )

    axis.set_title(
        "Pearson Correlation Matrix: Sales and Climate"
    )

    figure.colorbar(image, ax=axis)
    figure.tight_layout()

    figure.savefig(
        HEATMAP_PATH,
        dpi=220,
        bbox_inches="tight",
    )

    plt.close(figure)


def create_scatter_plots(data):
    variables = [
        ("temperature_mean", "Average Temperature"),
        ("humidity_mean", "Average Humidity"),
        ("rainfall", "Monthly Rainfall"),
    ]

    figure, axes = plt.subplots(
        1,
        3,
        figsize=(15, 4.8),
    )

    for axis, (variable, label) in zip(
        axes,
        variables,
    ):
        x_values = data[variable].to_numpy()
        y_values = data["quantity"].to_numpy()

        axis.scatter(
            x_values,
            y_values,
            color="#3f6f78",
            alpha=0.75,
        )

        slope, intercept = np.polyfit(
            x_values,
            y_values,
            1,
        )

        line_x = np.linspace(
            x_values.min(),
            x_values.max(),
            100,
        )

        axis.plot(
            line_x,
            slope * line_x + intercept,
            color="#c65d3b",
            linewidth=2,
        )

        axis.set_title(f"Quantity vs {label}")
        axis.set_xlabel(label)
        axis.set_ylabel("Quantity Sold")
        axis.grid(alpha=0.25)

    figure.tight_layout()

    figure.savefig(
        SCATTER_PATH,
        dpi=220,
        bbox_inches="tight",
    )

    plt.close(figure)


def main():
    sales = prepare_sales_data()
    weather = prepare_weather_data()

    merged = sales.merge(
        weather,
        on=["zone_id", "zone_name", "month"],
        how="inner",
    )

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    merged.to_csv(
        MERGED_PATH,
        index=False,
        encoding="utf-8",
    )

    analysis_variables = (
        SALES_VARIABLES + CLIMATE_VARIABLES
    )

    correlation_matrix = merged[
        analysis_variables
    ].corr(method="pearson")

    correlation_matrix.round(4).to_csv(
        MATRIX_PATH,
        encoding="utf-8",
    )

    test_rows = []

    for sales_variable in SALES_VARIABLES:
        for climate_variable in CLIMATE_VARIABLES:
            pearson_value, pearson_p = pearsonr(
                merged[sales_variable],
                merged[climate_variable],
            )

            spearman_value, spearman_p = spearmanr(
                merged[sales_variable],
                merged[climate_variable],
            )

            test_rows.append({
                "sales_variable": sales_variable,
                "climate_variable": climate_variable,
                "pearson_correlation": round(
                    pearson_value,
                    4,
                ),
                "pearson_p_value": round(
                    pearson_p,
                    4,
                ),
                "spearman_correlation": round(
                    spearman_value,
                    4,
                ),
                "spearman_p_value": round(
                    spearman_p,
                    4,
                ),
                "pearson_significant_5_percent": (
                    pearson_p < 0.05
                ),
                "spearman_significant_5_percent": (
                    spearman_p < 0.05
                ),
            })

    tests = pd.DataFrame(test_rows)

    pearson_rejected, pearson_adjusted, _, _ = multipletests(
        tests["pearson_p_value"],
        alpha=0.05,
        method="fdr_bh",
    )

    spearman_rejected, spearman_adjusted, _, _ = multipletests(
        tests["spearman_p_value"],
        alpha=0.05,
        method="fdr_bh",
    )

    tests["pearson_fdr_p_value"] = np.round(
        pearson_adjusted,
        4,
    )

    tests["pearson_significant_after_fdr"] = (
        pearson_rejected
    )

    tests["spearman_fdr_p_value"] = np.round(
        spearman_adjusted,
        4,
    )

    tests["spearman_significant_after_fdr"] = (
        spearman_rejected
    )



    tests.to_csv(
        TESTS_PATH,
        index=False,
        encoding="utf-8",
    )

    create_heatmap(correlation_matrix)
    create_scatter_plots(merged)

    print(f"Merged zone-month observations: {len(merged)}")

    print()
    print("Pearson correlation matrix:")
    print(correlation_matrix.round(3).to_string())

    print()
    print("Sales-climate significance tests:")
    print(tests.to_string(index=False))

    print()
    print(f"Merged dataset saved: {MERGED_PATH}")
    print(f"Correlation matrix saved: {MATRIX_PATH}")
    print(f"Statistical tests saved: {TESTS_PATH}")
    print(f"Heatmap created: {HEATMAP_PATH}")
    print(f"Scatter plots created: {SCATTER_PATH}")

    print()
    print(
        "Important: sales are synthetic and were generated "
        "independently from weather. Correlations must not "
        "be interpreted as causal business relationships."
    )


if __name__ == "__main__":
    main()