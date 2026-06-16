-- AgriSync AI - Data Warehouse Tables
-- First version: Sales analysis star schema

CREATE TABLE dim_date (
    date_key INTEGER PRIMARY KEY,
    full_date DATE NOT NULL,
    day INTEGER NOT NULL,
    month INTEGER NOT NULL,
    quarter INTEGER NOT NULL,
    year INTEGER NOT NULL
);

CREATE TABLE dim_client (
    client_key INTEGER PRIMARY KEY AUTOINCREMENT,
    client_id INTEGER NOT NULL,
    client_name VARCHAR(150) NOT NULL,
    pricing_category VARCHAR(20),
    zone_id INTEGER
);

CREATE TABLE dim_product (
    product_key INTEGER PRIMARY KEY AUTOINCREMENT,
    product_id INTEGER NOT NULL,
    product_name VARCHAR(150) NOT NULL,
    category VARCHAR(100),
    reference VARCHAR(100),
    current_price DECIMAL(10, 2),
    stock_quantity INTEGER
);

CREATE TABLE dim_user (
    user_key INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    user_name VARCHAR(150) NOT NULL,
    role VARCHAR(50),
    zone_id INTEGER
);

CREATE TABLE dim_zone (
    zone_key INTEGER PRIMARY KEY AUTOINCREMENT,
    zone_id INTEGER NOT NULL,
    zone_name VARCHAR(150) NOT NULL,
    description TEXT
);

CREATE TABLE fact_sales (
    sales_key INTEGER PRIMARY KEY AUTOINCREMENT,
    date_key INTEGER NOT NULL,
    client_key INTEGER NOT NULL,
    product_key INTEGER NOT NULL,
    user_key INTEGER NOT NULL,
    zone_key INTEGER NOT NULL,
    order_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    line_total DECIMAL(10, 2) NOT NULL,
    order_status VARCHAR(50),

    FOREIGN KEY (date_key) REFERENCES dim_date(date_key),
    FOREIGN KEY (client_key) REFERENCES dim_client(client_key),
    FOREIGN KEY (product_key) REFERENCES dim_product(product_key),
    FOREIGN KEY (user_key) REFERENCES dim_user(user_key),
    FOREIGN KEY (zone_key) REFERENCES dim_zone(zone_key)
);