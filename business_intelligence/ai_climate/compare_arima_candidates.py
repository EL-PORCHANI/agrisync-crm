import warnings
from pathlib import Path

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

OUTPUT_PATH = OUTPUT_DIR / "arima_candidate_comparison.csv"


CANDIDATE_ORDERS = [
    (0, 0, 0),
    (1, 0, 0),
    (0, 0, 1),
    (1, 0, 1),
    (2, 0, 0),
    (0, 0, 2),
]


def calculate_aicc(aic, observations, parameters):
    denominator = observations - parameters - 1

    if denominator <= 0:
        return float("inf")

    correction = (
        2 * parameters * (parameters + 1)
        / denominator
    )

    return aic + correction


def main():
    data = pd.read_csv(INPUT_PATH, parse_dates=["date"])
    data = data.sort_values("date")

    series = (
        data.set_index("date")["total_quantity"]
        .asfreq("MS")
    )

    if series.isna().any():
        raise ValueError(
            "The monthly series contains missing months."
        )
    observations = len(series)

    results = []

    for order in CANDIDATE_ORDERS:
        try:
            with warnings.catch_warnings(record=True) as captured:
                warnings.simplefilter("always")

                model = ARIMA(
                    series,
                    order=order,
                )

                fitted_model = model.fit()

            parameter_count = len(fitted_model.params)

            aicc = calculate_aicc(
                fitted_model.aic,
                observations,
                parameter_count,
            )

            converged = fitted_model.mle_retvals.get(
                "converged",
                True,
            )

            results.append({
                "model": f"ARIMA{order}",
                "p": order[0],
                "d": order[1],
                "q": order[2],
                "parameters": parameter_count,
                "aic": round(fitted_model.aic, 4),
                "aicc": round(aicc, 4),
                "bic": round(fitted_model.bic, 4),
                "log_likelihood": round(
                    fitted_model.llf,
                    4,
                ),
                "converged": converged,
                "warning_count": len(captured),
            })

        except Exception as error:
            results.append({
                "model": f"ARIMA{order}",
                "p": order[0],
                "d": order[1],
                "q": order[2],
                "parameters": None,
                "aic": None,
                "aicc": None,
                "bic": None,
                "log_likelihood": None,
                "converged": False,
                "warning_count": None,
                "error": str(error),
            })

    comparison = pd.DataFrame(results)

    successful = comparison[
        comparison["aicc"].notna()
    ].sort_values(
        by=["aicc", "bic"],
        ascending=True,
    )

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    comparison.to_csv(
        OUTPUT_PATH,
        index=False,
        encoding="utf-8",
    )

    print("Candidate model comparison:")
    print(successful.to_string(index=False))

    if not successful.empty:
        best_model = successful.iloc[0]

        print()
        print("Best model according to AICc:")
        print(best_model["model"])
        print(f"AIC: {best_model['aic']}")
        print(f"AICc: {best_model['aicc']}")
        print(f"BIC: {best_model['bic']}")

    print()
    print(f"Results saved: {OUTPUT_PATH}")
    print(
        "Warning: model selection remains preliminary "
        "because only 12 observations are available."
    )


if __name__ == "__main__":
    main()