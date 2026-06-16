# AgriSync AI - Power BI Dashboard Measures and Layout

## Objective

This document defines the measures, calculated columns, visuals and dashboard pages planned for the AgriSync AI Power BI reporting layer.

The dashboards are based on the Data Warehouse star schema and the generated analytical dataset.

---

## Dashboard Pages

The Power BI report will contain the following pages:

1. Sales Performance Dashboard
2. Stock Monitoring Dashboard
3. Invoice Monitoring Dashboard
4. Climate Risk Dashboard
5. Recommendation and Decision-Support Dashboard

---

# 1. Sales Performance Dashboard

## Objective

Analyze revenue, orders, clients, products, zones and commercial user performance.

## KPI Cards

| KPI | Description |
|---|---|
| Total Revenue | Total sales amount |
| Total Orders | Number of distinct orders |
| Total Quantity Sold | Total sold quantity |
| Average Order Value | Average revenue per order |
| Top Zone | Zone with highest revenue |
| Top Product | Product with highest revenue |

## Measures

```text
Total Revenue = SUM(fact_sales[line_total])

Total Orders = DISTINCTCOUNT(fact_sales[order_id])

Total Quantity Sold = SUM(fact_sales[quantity])

Average Order Value = DIVIDE([Total Revenue], [Total Orders])
```

## Visuals

| Visual | Data Used | Purpose |
|---|---|---|
| Card | Total Revenue | Show global sales performance |
| Card | Total Orders | Show total order volume |
| Line chart | Month, Total Revenue | Analyze revenue trend |
| Bar chart | Zone, Total Revenue | Compare regional performance |
| Bar chart | Product Category, Total Revenue | Identify best product categories |
| Table | Client, Total Revenue | Identify top clients |
| Table | Product, Total Quantity Sold | Identify top products |

## Filters

- Year
- Month
- Zone
- Product category
- Commercial user

---

# 2. Stock Monitoring Dashboard

## Objective

Monitor product availability and identify products that may create commercial or supply problems.

## KPI Cards

| KPI | Description |
|---|---|
| Total Products | Number of products |
| Low Stock Products | Products below the alert threshold |
| Total Quantity Sold | Quantity sold from fact sales |
| Best Selling Product | Product with highest quantity sold |

## Measures

```text
Total Products = DISTINCTCOUNT(dim_product[product_key])

Total Quantity Sold = SUM(fact_sales[quantity])

Low Stock Products = COUNTROWS(FILTER(dim_product, dim_product[current_price] > 0))
```

## Visuals

| Visual | Data Used | Purpose |
|---|---|---|
| Bar chart | Product, Quantity Sold | Detect high-demand products |
| Bar chart | Category, Quantity Sold | Compare product families |
| Matrix | Zone, Product Category, Quantity Sold | Analyze demand by region |
| Table | Product, Price, Quantity Sold | Support restocking decisions |

## Note

The current Data Warehouse prototype focuses on sales facts. A future version can add a dedicated `fact_stock` table to monitor stock movements and remaining quantities more precisely.

---

# 3. Invoice Monitoring Dashboard

## Objective

Analyze invoice status, payment risk and delayed invoices.

## KPI Cards

| KPI | Description |
|---|---|
| Total Invoices | Number of invoices |
| Unpaid Invoices | Invoices with unpaid status |
| Delayed Invoices | Invoices with delay days greater than zero |
| Total Amount Due | Total invoice amount |

## Planned Measures

```text
Total Invoices = COUNTROWS(invoices)

Unpaid Invoices = COUNTROWS(FILTER(invoices, invoices[status] = "unpaid"))

Delayed Invoices = COUNTROWS(FILTER(invoices, invoices[delay_days] > 0))

Total Amount Due = SUM(invoices[amount_due])
```

## Visuals

| Visual | Data Used | Purpose |
|---|---|---|
| Donut chart | Invoice status | Show payment distribution |
| Bar chart | Client, Amount Due | Detect clients with high unpaid amounts |
| Bar chart | Zone, Delayed Invoices | Detect risky regions |
| Table | Client, Invoice Status, Delay Days | Operational follow-up |

## Note

Invoice analytics can be implemented after adding invoice data to the Data Warehouse or importing the `invoices.csv` file directly into Power BI.

---

# 4. Climate Risk Dashboard

## Objective

Use 2025 weather observations to analyze drought risk, rainfall, humidity and temperature by agricultural zone.

## KPI Cards

| KPI | Description |
|---|---|
| Average Temperature | Mean temperature for selected period |
| Average Humidity | Mean humidity for selected period |
| Total Rainfall | Sum of rainfall |
| High Drought Risk Days | Number of days with high drought risk |

## Planned Measures

```text
Average Temperature = AVERAGE(weather_by_zone[temperature_mean])

Average Humidity = AVERAGE(weather_by_zone[humidity_mean])

Total Rainfall = SUM(weather_by_zone[rainfall])

High Drought Risk Days =
COUNTROWS(FILTER(weather_by_zone, weather_by_zone[drought_risk] = "high"))
```

## Visuals

| Visual | Data Used | Purpose |
|---|---|---|
| Line chart | Date, Temperature Mean | Show temperature evolution |
| Line chart | Date, Rainfall | Show rainfall trend |
| Bar chart | Zone, High Drought Risk Days | Compare drought exposure |
| Matrix | Zone, Month, Drought Risk | Analyze climate risk by period |

## Filters

- Year
- Month
- Zone
- Drought risk level

---

# 5. Recommendation and Decision-Support Dashboard

## Objective

Prepare a reporting page that explains how climate, stock and sales indicators can support product recommendations.

## KPI Cards

| KPI | Description |
|---|---|
| Recommended Products | Number of recommended products |
| High Risk Zones | Zones with high drought risk |
| Best Product Category | Category with strongest sales |
| Low Availability Products | Products with stock or supply risk |

## Planned Recommendation Logic

```text
Recommendation Score =
Climate Score
+ Sales History Score
+ Zone Suitability Score
+ Stock Availability Score
```

## Example Rules

| Condition | Decision |
|---|---|
| High drought risk | Recommend drought-adapted products |
| High humidity | Recommend anti-fungal products |
| Low stock | Reduce recommendation priority |
| Strong previous sales in zone | Increase recommendation priority |

## Visuals

| Visual | Data Used | Purpose |
|---|---|---|
| Table | Zone, Risk Level, Suggested Product | Support commercial visits |
| Bar chart | Product Category, Recommendation Score | Rank product families |
| Matrix | Zone, Product Category, Climate Condition | Connect climate to products |
| Card | High Risk Zones | Highlight urgent regions |

---

# Global Dashboard Design Rules

## Layout

- Use one page per decision area.
- Keep KPI cards at the top of each page.
- Place trend charts in the center.
- Place detailed tables at the bottom.
- Keep filters on the left or top side.

## Colors

| Meaning | Suggested Color |
|---|---|
| Positive / valid | Green |
| Warning / medium risk | Orange |
| Critical / high risk | Red |
| Neutral / structural data | Blue or gray |

## User Roles

| Role | Dashboard Usage |
|---|---|
| Administrator | User and data supervision |
| Commercial | Client, product and visit decision support |
| Manager | KPI monitoring, BI dashboards and strategic decisions |

---

# PFE Report Note

The Power BI reporting layer was specified through dashboard pages, KPI cards, measures, filters and visuals. The planned dashboards cover sales performance, stock monitoring, invoice monitoring, climate risk analysis and climate-smart recommendation support. This allows AgriSync AI to transform operational CRM data and environmental data into decision-support indicators for agricultural managers and commercial teams.
