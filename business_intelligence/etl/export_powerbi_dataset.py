import csv
import shutil
import sqlite3
from pathlib import Path

ROOT_DIR = Path(__file__).resolve().parents[2]

DW_DB_PATH = ROOT_DIR / "business_intelligence" / "data_warehouse" / "agrisync_dw_test.db"
SYNTHETIC_DATA_DIR = ROOT_DIR / "business_intelligence" / "synthetic_data"
AI_DATA_DIR = (ROOT_DIR / "business_intelligence" / "ai_climate")
POWERBI_DATASET_DIR = ROOT_DIR / "business_intelligence" / "power_bi" / "dataset"

DW_TABLES = [
    "dim_date",
    "dim_client",
    "dim_product",
    "dim_user",
    "dim_zone",
    "fact_sales",
]

SUPPORTING_FILES = [
    "invoices.csv",
    "visits.csv",
    "weather_by_zone.csv",
]

AI_OUTPUT_FILES = [
    "stock_demand_forecast.csv",
    "product_recommendations.csv",
    "climate_alerts.csv",
]


def export_table_to_csv(connection, table_name, output_path):
    cursor = connection.cursor()
    cursor.execute(f"SELECT * FROM {table_name}")

    columns = [description[0] for description in cursor.description]
    rows = cursor.fetchall()

    with output_path.open("w", newline="", encoding="utf-8") as file:
        writer = csv.writer(file)
        writer.writerow(columns)
        writer.writerows(rows)

    print(f"Exported {table_name}.csv: {len(rows)} rows")


def copy_supporting_file(file_name):
    source = SYNTHETIC_DATA_DIR / file_name
    destination = POWERBI_DATASET_DIR / file_name

    if not source.exists():
        print(f"Missing supporting file: {source}")
        return

    shutil.copy2(source, destination)

    with destination.open(encoding="utf-8") as file:
        row_count = sum(1 for _ in file) - 1

    print(f"Copied {file_name}: {row_count} rows")

def copy_ai_output_file(file_name):
    source = AI_DATA_DIR / file_name
    destination = POWERBI_DATASET_DIR / file_name

    if not source.exists():
        print(f"Missing AI output file: {source}")
        return

    shutil.copy2(source, destination)

    with destination.open(encoding="utf-8") as file:
        row_count = sum(1 for _ in file) - 1

    print(f"Copied AI output {file_name}: {row_count} rows")


def main():
    if not DW_DB_PATH.exists():
        raise FileNotFoundError(f"Data Warehouse database not found: {DW_DB_PATH}")

    POWERBI_DATASET_DIR.mkdir(parents=True, exist_ok=True)

    with sqlite3.connect(DW_DB_PATH) as connection:
        for table_name in DW_TABLES:
            output_path = POWERBI_DATASET_DIR / f"{table_name}.csv"
            export_table_to_csv(connection, table_name, output_path)

    for file_name in SUPPORTING_FILES:
        copy_supporting_file(file_name)

    for file_name in AI_OUTPUT_FILES:
        copy_ai_output_file(file_name)
        

    print()
    print("Power BI dataset export completed.")
    print(f"Output folder: {POWERBI_DATASET_DIR}")


if __name__ == "__main__":
    main()