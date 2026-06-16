import csv
import sqlite3
from datetime import datetime
from pathlib import Path

ROOT_DIR = Path(__file__).resolve().parents[2]
DATA_DIR = ROOT_DIR / "business_intelligence" / "synthetic_data"
DW_DIR = ROOT_DIR / "business_intelligence" / "data_warehouse"

SQL_PATH = DW_DIR / "data_warehouse_tables.sql"
DB_PATH = DW_DIR / "agrisync_dw_test.db"


def read_csv(filename):
    path = DATA_DIR / filename

    with path.open(encoding="utf-8") as csv_file:
        return list(csv.DictReader(csv_file))


def date_key(date_value):
    return int(date_value.replace("-", ""))


def quarter_from_month(month):
    return ((month - 1) // 3) + 1


def reset_database(connection):
    sql = SQL_PATH.read_text(encoding="utf-8")
    connection.executescript("""
    DROP TABLE IF EXISTS fact_sales;
    DROP TABLE IF EXISTS dim_date;
    DROP TABLE IF EXISTS dim_client;
    DROP TABLE IF EXISTS dim_product;
    DROP TABLE IF EXISTS dim_user;
    DROP TABLE IF EXISTS dim_zone;
    """)
    connection.executescript(sql)


def load_dim_date(connection, orders):
    dates = sorted(set(order["order_date"] for order in orders))

    for value in dates:
        parsed = datetime.strptime(value, "%Y-%m-%d")
        month = parsed.month

        connection.execute(
            """
            INSERT INTO dim_date (
                date_key,
                full_date,
                day,
                month,
                quarter,
                year
            )
            VALUES (?, ?, ?, ?, ?, ?)
            """,
            (
                date_key(value),
                value,
                parsed.day,
                parsed.month,
                quarter_from_month(month),
                parsed.year,
            )
        )


def load_dim_client(connection, clients):
    for client in clients:
        connection.execute(
            """
            INSERT INTO dim_client (
                client_id,
                client_name,
                pricing_category,
                zone_id
            )
            VALUES (?, ?, ?, ?)
            """,
            (
                int(client["client_id"]),
                client["client_name"],
                client["pricing_category"],
                int(client["zone_id"]),
            )
        )


def load_dim_product(connection, products):
    for product in products:
        connection.execute(
            """
            INSERT INTO dim_product (
                product_id,
                product_name,
                category,
                reference,
                current_price,
                stock_quantity
            )
            VALUES (?, ?, ?, ?, ?, ?)
            """,
            (
                int(product["product_id"]),
                product["product_name"],
                product["category"],
                product["reference"],
                float(product["current_price"]),
                int(product["stock_quantity"]),
            )
        )


def load_dim_user(connection, users):
    for user in users:
        connection.execute(
            """
            INSERT INTO dim_user (
                user_id,
                user_name,
                role,
                zone_id
            )
            VALUES (?, ?, ?, ?)
            """,
            (
                int(user["user_id"]),
                user["username"],
                user["role"],
                int(user["zone_id"]),
            )
        )


def load_dim_zone(connection, clients):
    zones = {}

    for client in clients:
        zones[int(client["zone_id"])] = client["zone_name"]

    for zone_id_value, zone_name in sorted(zones.items()):
        connection.execute(
            """
            INSERT INTO dim_zone (
                zone_id,
                zone_name,
                description
            )
            VALUES (?, ?, ?)
            """,
            (
                zone_id_value,
                zone_name,
                f"Agricultural zone: {zone_name}",
            )
        )


def build_lookup(connection, table_name, key_column, id_column):
    rows = connection.execute(
        f"SELECT {key_column}, {id_column} FROM {table_name}"
    ).fetchall()

    return {row[1]: row[0] for row in rows}


def load_fact_sales(connection, orders, order_lines):
    orders_by_id = {
        int(order["order_id"]): order
        for order in orders
    }

    client_lookup = build_lookup(
        connection,
        "dim_client",
        "client_key",
        "client_id",
    )

    product_lookup = build_lookup(
        connection,
        "dim_product",
        "product_key",
        "product_id",
    )

    user_lookup = build_lookup(
        connection,
        "dim_user",
        "user_key",
        "user_id",
    )

    zone_lookup = build_lookup(
        connection,
        "dim_zone",
        "zone_key",
        "zone_id",
    )

    for line in order_lines:
        order = orders_by_id[int(line["order_id"])]

        connection.execute(
            """
            INSERT INTO fact_sales (
                date_key,
                client_key,
                product_key,
                user_key,
                zone_key,
                order_id,
                quantity,
                unit_price,
                line_total,
                order_status
            )
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """,
            (
                date_key(order["order_date"]),
                client_lookup[int(order["client_id"])],
                product_lookup[int(line["product_id"])],
                user_lookup[int(order["user_id"])],
                zone_lookup[int(order["zone_id"])],
                int(order["order_id"]),
                int(line["quantity"]),
                float(line["unit_price"]),
                float(line["line_total"]),
                order["order_status"],
            )
        )


def print_table_counts(connection):
    tables = [
        "dim_date",
        "dim_client",
        "dim_product",
        "dim_user",
        "dim_zone",
        "fact_sales",
    ]

    print("\nData Warehouse row counts:")

    for table in tables:
        count = connection.execute(
            f"SELECT COUNT(*) FROM {table}"
        ).fetchone()[0]

        print(f"- {table}: {count}")


def main():
    clients = read_csv("clients.csv")
    products = read_csv("products.csv")
    users = read_csv("users.csv")
    orders = read_csv("orders.csv")
    order_lines = read_csv("order_lines.csv")

    connection = sqlite3.connect(DB_PATH)

    reset_database(connection)

    load_dim_date(connection, orders)
    load_dim_client(connection, clients)
    load_dim_product(connection, products)
    load_dim_user(connection, users)
    load_dim_zone(connection, clients)
    load_fact_sales(connection, orders, order_lines)

    connection.commit()
    print_table_counts(connection)
    connection.close()

    print("\nData Warehouse loading completed.")
    print(f"Database: {DB_PATH}")


if __name__ == "__main__":
    main()