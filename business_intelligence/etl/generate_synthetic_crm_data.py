import csv
import random
from datetime import datetime, timedelta
from pathlib import Path

random.seed(42)

ROOT_DIR = Path(__file__).resolve().parents[2]
OUTPUT_DIR = ROOT_DIR / "business_intelligence" / "synthetic_data"
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

START_DATE = datetime(2025, 6, 1)
END_DATE = datetime(2026, 5, 31)

ZONES = [
    {"zone_id": 1, "zone_name": "Nabeul", "context": "Citrus and vegetables"},
    {"zone_id": 2, "zone_name": "Sfax", "context": "Olive trees"},
    {"zone_id": 3, "zone_name": "Beja", "context": "Cereals"},
    {"zone_id": 4, "zone_name": "Kairouan", "context": "Dry inland crops"},
    {"zone_id": 5, "zone_name": "Gabes", "context": "Oasis agriculture"},
]

PRODUCT_CATEGORIES = [
    "Fertilizers",
    "Seeds",
    "Pesticides",
    "Fungicides",
    "Irrigation products",
    "Soil treatment",
    "Climate-adapted products",
]

PRODUCT_NAMES = [
    "NPK Fertilizer 20-20-20",
    "Organic Compost Mix",
    "Tomato Seeds Premium",
    "Wheat Seeds Resistant",
    "Olive Tree Nutrient Pack",
    "Anti-Fungal Treatment",
    "Copper Fungicide",
    "Drip Irrigation Kit",
    "Water Retention Granules",
    "Soil PH Corrector",
    "Drought Shield Bio",
    "Humidity Control Spray",
    "Potassium Booster",
    "Nitrogen Booster",
    "Citrus Growth Formula",
    "Vegetable Root Stimulator",
    "Cereal Yield Enhancer",
    "Palm Tree Fertilizer",
    "Salinity Control Product",
    "Greenhouse Pest Control",
    "Aphid Control Solution",
    "Mildew Protection Spray",
    "Seed Germination Booster",
    "Foliar Nutrition Mix",
    "Micro Elements Pack",
    "Crop Stress Reducer",
    "Irrigation Filter Pack",
    "Soil Moisture Sensor",
    "Climate Smart Pack",
    "Bio Stimulant Plus",
]

CLIENT_PREFIXES = [
    "Agri",
    "Green",
    "Société",
    "Ferme",
    "Domaine",
    "Espace",
    "Coopérative",
    "Olive",
    "Citrus",
    "Terra",
]

CLIENT_SUFFIXES = [
    "Nord",
    "Sud",
    "Plus",
    "Pro",
    "Fertile",
    "Nature",
    "Export",
    "Services",
    "Culture",
    "Verte",
]

USERS = [
    {"user_id": 1, "username": "admin", "role": "Administrator", "zone_id": 1},
    {"user_id": 2, "username": "commercial_nabeul", "role": "Commercial", "zone_id": 1},
    {"user_id": 3, "username": "commercial_sfax", "role": "Commercial", "zone_id": 2},
    {"user_id": 4, "username": "commercial_beja", "role": "Commercial", "zone_id": 3},
    {"user_id": 5, "username": "commercial_kairouan", "role": "Commercial", "zone_id": 4},
    {"user_id": 6, "username": "commercial_gabes", "role": "Commercial", "zone_id": 5},
    {"user_id": 7, "username": "manager", "role": "Manager", "zone_id": 1},
]


def write_csv(filename, rows, fieldnames):
    path = OUTPUT_DIR / filename
    with path.open("w", newline="", encoding="utf-8") as csv_file:
        writer = csv.DictWriter(csv_file, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)

    print(f"Generated {filename}: {len(rows)} rows")


def random_date():
    days = (END_DATE - START_DATE).days
    return START_DATE + timedelta(days=random.randint(0, days))


def weighted_choice(options):
    values, weights = zip(*options)
    return random.choices(values, weights=weights, k=1)[0]


def generate_clients():
    clients = []

    for client_id in range(1, 81):
        zone = random.choice(ZONES)
        pricing_category = weighted_choice([
            ("A", 20),
            ("B", 50),
            ("C", 30),
        ])

        name = f"{random.choice(CLIENT_PREFIXES)} {random.choice(CLIENT_SUFFIXES)} {client_id}"

        clients.append({
            "client_id": client_id,
            "client_name": name,
            "phone": f"2{random.randint(1000000, 9999999)}",
            "address": f"{zone['zone_name']} agricultural area",
            "pricing_category": pricing_category,
            "zone_id": zone["zone_id"],
            "zone_name": zone["zone_name"],
            "latitude": round(random.uniform(33.0, 37.5), 6),
            "longitude": round(random.uniform(8.0, 11.5), 6),
        })

    return clients


def generate_products():
    products = []

    for product_id, product_name in enumerate(PRODUCT_NAMES, start=1):
        category = random.choice(PRODUCT_CATEGORIES)
        price = round(random.uniform(25, 450), 2)

        stock_quantity = weighted_choice([
            (random.randint(5, 20), 20),
            (random.randint(21, 80), 50),
            (random.randint(81, 250), 30),
        ])

        products.append({
            "product_id": product_id,
            "product_name": product_name,
            "category": category,
            "reference": f"AGR-{product_id:04d}",
            "current_price": price,
            "stock_quantity": stock_quantity,
        })

    return products


def generate_orders_and_lines(clients, products):
    orders = []
    order_lines = []
    order_id = 1
    line_id = 1

    for _ in range(600):
        client = random.choice(clients)
        order_date = random_date()
        status = weighted_choice([
            ("delivered", 60),
            ("validated", 25),
            ("draft", 10),
            ("cancelled", 5),
        ])

        selected_products = random.sample(products, random.randint(1, 4))
        total_amount = 0

        for product in selected_products:
            quantity = random.randint(1, 12)
            unit_price = float(product["current_price"])
            line_total = round(quantity * unit_price, 2)
            total_amount += line_total

            order_lines.append({
                "line_id": line_id,
                "order_id": order_id,
                "product_id": product["product_id"],
                "product_name": product["product_name"],
                "category": product["category"],
                "quantity": quantity,
                "unit_price": unit_price,
                "line_total": line_total,
            })

            line_id += 1

        orders.append({
            "order_id": order_id,
            "client_id": client["client_id"],
            "client_name": client["client_name"],
            "zone_id": client["zone_id"],
            "zone_name": client["zone_name"],
            "user_id": next(
                user["user_id"]
                for user in USERS
                if user["role"] == "Commercial" and user["zone_id"] == client["zone_id"]
            ),
            "order_date": order_date.strftime("%Y-%m-%d"),
            "order_status": status,
            "total_amount": round(total_amount, 2),
        })

        order_id += 1

    return orders, order_lines


def generate_invoices(orders):
    invoices = []

    for invoice_id, order in enumerate(orders, start=1):
        status = weighted_choice([
            ("up_to_date", 65),
            ("unpaid", 15),
            ("delayed", 15),
            ("partially_paid", 5),
        ])

        if status == "delayed":
            delay_days = random.randint(5, 90)
        elif status == "unpaid":
            delay_days = random.randint(1, 45)
        else:
            delay_days = 0

        due_date = datetime.strptime(order["order_date"], "%Y-%m-%d") + timedelta(days=30)

        invoices.append({
            "invoice_id": invoice_id,
            "order_id": order["order_id"],
            "client_id": order["client_id"],
            "amount_due": order["total_amount"],
            "due_date": due_date.strftime("%Y-%m-%d"),
            "invoice_status": status,
            "delay_days": delay_days,
        })

    return invoices


def generate_visits(clients):
    visits = []

    for visit_id in range(1, 251):
        client = random.choice(clients)
        visit_date = random_date()
        validation_status = weighted_choice([
            ("valid", 75),
            ("pending", 15),
            ("invalid", 10),
        ])

        visits.append({
            "visit_id": visit_id,
            "client_id": client["client_id"],
            "client_name": client["client_name"],
            "user_id": next(
                user["user_id"]
                for user in USERS
                if user["role"] == "Commercial" and user["zone_id"] == client["zone_id"]
            ),
            "visit_date": visit_date.strftime("%Y-%m-%d"),
            "visit_time": f"{random.randint(8, 17):02d}:{random.choice([0, 15, 30, 45]):02d}",
            "gps_location": f"{client['latitude']},{client['longitude']}",
            "latitude": client["latitude"],
            "longitude": client["longitude"],
            "validation_status": validation_status,
        })

    return visits


def generate_weather_by_zone():
    rows = []

    for zone in ZONES:
        for month in range(1, 13):
            if zone["zone_name"] in ["Sfax", "Kairouan", "Gabes"]:
                drought_risk = weighted_choice([
                    ("low", 10),
                    ("medium", 35),
                    ("high", 55),
                ])
                rainfall = round(random.uniform(2, 35), 2)
                temperature = round(random.uniform(25, 39), 2)
            else:
                drought_risk = weighted_choice([
                    ("low", 45),
                    ("medium", 40),
                    ("high", 15),
                ])
                rainfall = round(random.uniform(20, 90), 2)
                temperature = round(random.uniform(16, 32), 2)

            humidity = round(random.uniform(35, 85), 2)

            rows.append({
                "zone_id": zone["zone_id"],
                "zone_name": zone["zone_name"],
                "year": 2025,
                "month": month,
                "temperature": temperature,
                "humidity": humidity,
                "rainfall": rainfall,
                "drought_risk": drought_risk,
            })

    return rows


def main():
    clients = generate_clients()
    products = generate_products()
    orders, order_lines = generate_orders_and_lines(clients, products)
    invoices = generate_invoices(orders)
    visits = generate_visits(clients)

    write_csv("clients.csv", clients, clients[0].keys())
    write_csv("products.csv", products, products[0].keys())
    write_csv("users.csv", USERS, USERS[0].keys())
    write_csv("orders.csv", orders, orders[0].keys())
    write_csv("order_lines.csv", order_lines, order_lines[0].keys())
    write_csv("invoices.csv", invoices, invoices[0].keys())
    write_csv("visits.csv", visits, visits[0].keys())

    print("Synthetic CRM dataset generation completed.")
    print(f"Output folder: {OUTPUT_DIR}")


if __name__ == "__main__":
    main()