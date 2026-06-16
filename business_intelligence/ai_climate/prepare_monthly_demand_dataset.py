import csv
from collections import defaultdict
from pathlib import Path

ROOT_DIR = Path(__file__).resolve().parents[2]
DATASET_DIR = ROOT_DIR / "business_intelligence" / "power_bi" / "dataset"
OUTPUT_PATH = ROOT_DIR / "business_intelligence" / "ai_climate" / "monthly_demand_dataset.csv"


def read_csv(path):
    with path.open(encoding="utf-8") as file:
        return list(csv.DictReader(file))


def index_by(rows, key):
    return {row[key]: row for row in rows}


def main():
    fact_sales = read_csv(DATASET_DIR / "fact_sales.csv")
    dim_date = index_by(read_csv(DATASET_DIR / "dim_date.csv"), "date_key")
    dim_product = index_by(read_csv(DATASET_DIR / "dim_product.csv"), "product_key")
    dim_zone = index_by(read_csv(DATASET_DIR / "dim_zone.csv"), "zone_key")

    monthly_data = defaultdict(lambda: {
        "monthly_quantity_sold": 0,
        "monthly_revenue": 0.0,
        "stock_quantity": 0,
    })

    for sale in fact_sales:
        date = dim_date[sale["date_key"]]
        product = dim_product[sale["product_key"]]
        zone = dim_zone[sale["zone_key"]]

        key = (
            date["year"],
            date["month"],
            product["product_id"],
            product["product_name"],
            product["category"],
            zone["zone_id"],
            zone["zone_name"],
        )

        monthly_data[key]["monthly_quantity_sold"] += int(sale["quantity"])
        monthly_data[key]["monthly_revenue"] += float(sale["line_total"])
        monthly_data[key]["stock_quantity"] = int(product["stock_quantity"])

    OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)

    fieldnames = [
        "year",
        "month",
        "product_id",
        "product_name",
        "category",
        "zone_id",
        "zone_name",
        "monthly_quantity_sold",
        "monthly_revenue",
        "stock_quantity",
    ]

    with OUTPUT_PATH.open("w", newline="", encoding="utf-8") as file:
        writer = csv.DictWriter(file, fieldnames=fieldnames)
        writer.writeheader()

        for key, values in sorted(monthly_data.items()):
            (
                year,
                month,
                product_id,
                product_name,
                category,
                zone_id,
                zone_name,
            ) = key

            writer.writerow({
                "year": year,
                "month": month,
                "product_id": product_id,
                "product_name": product_name,
                "category": category,
                "zone_id": zone_id,
                "zone_name": zone_name,
                "monthly_quantity_sold": values["monthly_quantity_sold"],
                "monthly_revenue": round(values["monthly_revenue"], 2),
                "stock_quantity": values["stock_quantity"],
            })

    print(f"Monthly demand dataset created: {OUTPUT_PATH}")
    print(f"Rows: {len(monthly_data)}")


if __name__ == "__main__":
    main()