# AgriSync AI - Power BI SQL Queries

## Objective

This document contains reusable SQL queries for Power BI dashboards based on the AgriSync AI Data Warehouse.

The queries use the first sales star schema:

- dim_date
- dim_client
- dim_product
- dim_user
- dim_zone
- fact_sales

---

## 1. Sales Summary

```sql
SELECT
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(quantity) AS total_quantity_sold,
    ROUND(SUM(line_total), 2) AS total_revenue,
    ROUND(AVG(line_total), 2) AS average_line_amount
FROM fact_sales;
```

---

## 2. Revenue By Month

```sql
SELECT
    d.year,
    d.month,
    ROUND(SUM(f.line_total), 2) AS revenue
FROM fact_sales f
JOIN dim_date d ON f.date_key = d.date_key
GROUP BY d.year, d.month
ORDER BY d.year, d.month;
```

---

## 3. Revenue By Zone

```sql
SELECT
    z.zone_name,
    ROUND(SUM(f.line_total), 2) AS revenue
FROM fact_sales f
JOIN dim_zone z ON f.zone_key = z.zone_key
GROUP BY z.zone_name
ORDER BY revenue DESC;
```

---

## 4. Revenue By Product Category

```sql
SELECT
    p.category,
    ROUND(SUM(f.line_total), 2) AS revenue,
    SUM(f.quantity) AS quantity_sold
FROM fact_sales f
JOIN dim_product p ON f.product_key = p.product_key
GROUP BY p.category
ORDER BY revenue DESC;
```

---

## 5. Top 10 Products By Revenue

```sql
SELECT
    p.product_name,
    p.category,
    ROUND(SUM(f.line_total), 2) AS revenue,
    SUM(f.quantity) AS quantity_sold
FROM fact_sales f
JOIN dim_product p ON f.product_key = p.product_key
GROUP BY p.product_name, p.category
ORDER BY revenue DESC
LIMIT 10;
```

---

## 6. Top 10 Clients By Revenue

```sql
SELECT
    c.client_name,
    c.pricing_category,
    ROUND(SUM(f.line_total), 2) AS revenue,
    COUNT(DISTINCT f.order_id) AS orders_count
FROM fact_sales f
JOIN dim_client c ON f.client_key = c.client_key
GROUP BY c.client_name, c.pricing_category
ORDER BY revenue DESC
LIMIT 10;
```

---

## 7. Orders By Status

```sql
SELECT
    order_status,
    COUNT(DISTINCT order_id) AS orders_count,
    ROUND(SUM(line_total), 2) AS revenue
FROM fact_sales
GROUP BY order_status
ORDER BY orders_count DESC;
```

---

## 8. Sales By Commercial User

```sql
SELECT
    u.user_name,
    u.role,
    ROUND(SUM(f.line_total), 2) AS revenue,
    COUNT(DISTINCT f.order_id) AS orders_count
FROM fact_sales f
JOIN dim_user u ON f.user_key = u.user_key
GROUP BY u.user_name, u.role
ORDER BY revenue DESC;
```

---

## 9. Revenue By Zone And Month

```sql
SELECT
    d.year,
    d.month,
    z.zone_name,
    ROUND(SUM(f.line_total), 2) AS revenue
FROM fact_sales f
JOIN dim_date d ON f.date_key = d.date_key
JOIN dim_zone z ON f.zone_key = z.zone_key
GROUP BY d.year, d.month, z.zone_name
ORDER BY d.year, d.month, z.zone_name;
```

---

## 10. Product Performance By Zone

```sql
SELECT
    z.zone_name,
    p.product_name,
    p.category,
    ROUND(SUM(f.line_total), 2) AS revenue,
    SUM(f.quantity) AS quantity_sold
FROM fact_sales f
JOIN dim_zone z ON f.zone_key = z.zone_key
JOIN dim_product p ON f.product_key = p.product_key
GROUP BY z.zone_name, p.product_name, p.category
ORDER BY z.zone_name, revenue DESC;
```

---

## Power BI Dashboard Usage

These SQL queries can support the following visuals:

| Query | Power BI Visual |
|---|---|
| Sales Summary | KPI cards |
| Revenue By Month | Line chart |
| Revenue By Zone | Bar chart or map |
| Revenue By Product Category | Bar chart |
| Top Products | Table or bar chart |
| Top Clients | Table |
| Orders By Status | Donut chart |
| Sales By Commercial User | Bar chart |
| Revenue By Zone And Month | Matrix or line chart |
| Product Performance By Zone | Matrix or drill-down table |

---

## PFE Report Note

Reusable analytical SQL queries were prepared from the AgriSync AI Data Warehouse. These queries transform the star schema into business indicators such as total revenue, monthly revenue, revenue by zone, top products, top clients, order status analysis and commercial user performance.
