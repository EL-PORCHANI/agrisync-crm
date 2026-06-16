# AgriSync AI - Data Warehouse Star Schema

## 1. Objective

The objective of the Data Warehouse is to transform operational CRM data into analytical data that can support Business Intelligence dashboards, climate-aware decision-making, and AI-based recommendations.

The operational CRM stores daily business transactions such as clients, products, orders, invoices, visits, and stock levels. The Data Warehouse reorganizes this data into fact and dimension tables optimized for analysis in Power BI.

## 2. Analytical Questions

The Data Warehouse must help answer the following questions:

1. Which products generate the most revenue?
2. Which clients are the most valuable?
3. Which zones have the highest sales?
4. Which products are frequently low in stock?
5. Which invoices are unpaid, late, or critical?
6. Which commercial users perform the most visits?
7. How do weather and climate conditions affect sales and demand?
8. Which products should be recommended depending on zone, stock availability, and climate risk?

## 3. Star Schema Overview

The proposed Data Warehouse follows a star schema composed of fact tables and dimension tables.

Fact tables store measurable business events such as sales, invoices, stock levels, visits, and weather observations.

Dimension tables store descriptive information used to filter, group, and analyze facts, such as dates, clients, products, users, zones, and weather conditions.

## 4. Fact Tables

### 4.1 FactSales

Grain:
One row per product sold in an order.

Source tables:
- orders
- order_lines
- products
- clients
- users
- zones

Measures:
- quantity
- unit_price
- line_total
- order_total

Foreign keys:
- date_key
- client_key
- product_key
- user_key
- zone_key

### 4.2 FactInvoices

Grain:
One row per invoice.

Source table:
- invoices

Measures:
- amount_due
- delay_days

Foreign keys:
- date_key
- client_key

### 4.3 FactStock

Grain:
One row per product per zone per extraction date.

Source tables:
- stocks
- products
- zones

Measures:
- available_quantity
- alert_threshold
- stock_gap

Foreign keys:
- date_key
- product_key
- zone_key

### 4.4 FactVisits

Grain:
One row per commercial visit.

Source table:
- visits

Measures:
- visit_count
- validation_status

Foreign keys:
- date_key
- client_key
- user_key
- zone_key

### 4.5 FactWeather

Grain:
One row per zone per date.

Source:
- weather API or climate dataset

Measures:
- temperature
- humidity
- rainfall
- wind_speed
- drought_index

Foreign keys:
- date_key
- zone_key
- weather_condition_key

## 5. Dimension Tables

### 5.1 DimDate

Used for time-based analysis.

Example columns:
- date_key
- full_date
- day
- month
- month_name
- quarter
- year
- week_number

### 5.2 DimClient

Used to analyze sales, visits, invoices, and climate exposure by client.

Example columns:
- client_key
- client_id
- client_name
- phone
- address
- pricing_category
- zone_id
- latitude
- longitude

### 5.3 DimProduct

Used to analyze product sales, stock, and recommendations.

Example columns:
- product_key
- product_id
- product_name
- category
- reference
- current_price

### 5.4 DimUser

Used to analyze commercial user performance.

Example columns:
- user_key
- user_id
- user_name
- email
- role
- zone_id

### 5.5 DimZone

Used to analyze data by geographical or commercial zone.

Example columns:
- zone_key
- zone_id
- zone_name
- description

### 5.6 DimWeatherCondition

Used to classify weather and climate conditions.

Example columns:
- weather_condition_key
- condition_name
- risk_level
- recommendation_note

Example values:
- drought
- high_humidity
- heavy_rain
- heatwave
- normal

## 6. Relationships

FactSales connects to:
- DimDate
- DimClient
- DimProduct
- DimUser
- DimZone

FactInvoices connects to:
- DimDate
- DimClient

FactStock connects to:
- DimDate
- DimProduct
- DimZone

FactVisits connects to:
- DimDate
- DimClient
- DimUser
- DimZone

FactWeather connects to:
- DimDate
- DimZone
- DimWeatherCondition

## 7. Power BI Dashboard Usage

The star schema will support the following dashboards:

### Sales Dashboard

KPIs:
- Total revenue
- Number of orders
- Top clients
- Top products
- Revenue by month
- Revenue by zone

### Stock Dashboard

KPIs:
- Available stock
- Low stock products
- Critical stock alerts
- Product availability by zone

### Invoice Dashboard

KPIs:
- Total unpaid invoices
- Late invoices
- Critical invoices
- Delay days by client
- Amount due by zone

### Commercial Activity Dashboard

KPIs:
- Number of visits
- Visits by commercial user
- Valid vs invalid visits
- Visits by client
- Visits by zone

### Climate Risk Dashboard

KPIs:
- Weather risk by zone
- Drought alerts
- Humidity alerts
- Rainfall trends
- Climate risk impact on product demand

## 8. AI and Climate Usage

The Data Warehouse will support AI logic by combining:

- sales history
- product demand
- stock availability
- client zone
- weather risk
- climate condition

This can be used to generate product recommendations such as:

If a client is located in a high drought-risk zone and stock is available, recommend drought-adapted products.

## 9. PFE Report Note

The Data Warehouse was designed using a star schema to transform operational CRM data into analytical structures suitable for Business Intelligence and AI-based decision support. Fact tables represent measurable business events such as sales, stock, invoices, visits, and weather observations, while dimension tables provide descriptive context such as clients, products, dates, users, zones, and weather conditions.