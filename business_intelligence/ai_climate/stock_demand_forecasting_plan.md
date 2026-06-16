# AgriSync AI - Stock Demand Forecasting and Intelligence Plan

## 1. Objective

        The objective of the intelligence layer is to transform CRM, stock, sales and climate data into decision-support indicators for agricultural managers and commercial users.

The intelligence layer has two complementary components:

1. Rule-based product recommendation logic.
2. Time-series stock demand prediction prototype.

The recommendation logic supports climate-smart product suggestions, while the forecasting prototype estimates future product demand based on historical sales data.

---

## 2. Intelligence Layer Position in the Architecture

The intelligence layer is positioned after the Data Warehouse and Business Intelligence layers.

Data flow:

```text
Flutter CRM / Django Backend / SQLite
        |
        v
Operational CRM Data
        |
        v
Talend ETL
        |
        v
Data Warehouse
        |
        v
Power BI Dashboards
        |
        v
AI / Recommendation / Forecasting Layer
```

The AI layer uses structured analytical data prepared by the ETL and Data Warehouse processes.

---

## 3. Rule-Based Recommendation Logic

The recommendation logic is based on explainable business rules.

It uses:

- client zone,
- product category,
- stock quantity,
- sales history,
- weather and climate indicators,
- drought risk,
- humidity,
- rainfall.

Example rules:

```text
If drought risk is high:
    recommend climate-adapted products and irrigation products.

If humidity is high:
    recommend fungicides.

If rainfall is low:
    recommend soil treatment and irrigation products.

If stock quantity is low:
    reduce recommendation priority.

If previous sales are strong in a zone:
    increase recommendation priority.
```

This approach is suitable for the MVP because it is explainable, easy to validate, and aligned with agricultural business logic.

---

## 4. Stock Demand Prediction Prototype

The stock demand prediction prototype uses time-series analysis to estimate future demand.

A time series is a sequence of values measured over time.

In this project, the time series is:

```text
monthly quantity sold by product or product category
```

Example:

```text
January sales quantity
February sales quantity
March sales quantity
...
```

The goal is to predict future demand for products or product categories.

---

## 5. ARIMA Model

ARIMA stands for:

```text
AutoRegressive Integrated Moving Average
```

It is a classical statistical model used for time-series forecasting.

ARIMA is suitable for the MVP because:

- it is interpretable,
- it works with limited historical data,
- it is faster and simpler than deep learning,
- it is appropriate for academic demonstration,
- it can forecast future sales or demand from monthly data.

In AgriSync AI, ARIMA can be used to forecast:

- future product demand,
- future category demand,
- stock pressure,
- possible restocking needs.

---

## 6. LSTM Model

LSTM stands for:

```text
Long Short-Term Memory
```

It is a recurrent neural network designed to learn sequential patterns.

LSTM can model complex and non-linear time-series relationships, but it requires:

- larger datasets,
- more training time,
- more computing resources,
- careful parameter tuning.

For this MVP, LSTM is considered as a future extension.

---

## 7. ARIMA vs LSTM Comparison

| Criteria | ARIMA | LSTM |
|---|---|---|
| Type | Statistical model | Deep learning model |
| Data need | Small to medium dataset | Large dataset |
| Interpretability | High | Lower |
| Complexity | Medium | High |
| Training time | Fast | Slower |
| Suitability for MVP | Strong | Future extension |
| Use in AgriSync AI | Prototype demand forecast | Future advanced forecast |

ARIMA is selected for the MVP because the project currently uses a limited analytical dataset and needs an explainable forecasting prototype.

---

## 8. Forecasting Input Data

The forecasting prototype will use data from:

- fact_sales,
- dim_date,
- dim_product,
- dim_zone.

Main fields:

```text
month
year
product_id
product_name
category
zone_name
quantity sold
line total
```

Optional climate fields:

```text
temperature_mean
humidity_mean
rainfall
drought_risk
```

---

## 9. Forecasting Output Data

The output of the prediction prototype will be a CSV file:

```text
stock_demand_forecast.csv
```

Planned columns:

```text
forecast_id
product_name
category
zone_name
forecast_month
historical_quantity
predicted_quantity
forecast_method
recommendation_note
```

This file can be imported into Power BI to visualize predicted demand.

---

## 10. KPI Formulas

The intelligence and BI layers use the following KPIs:

### Revenue Growth Rate

```text
Revenue Growth Rate = (Revenue N - Revenue N-1) / Revenue N-1 * 100
```

### Average Order Value

```text
Average Order Value = Total Revenue / Number of Orders
```

### Stock Turnover

```text
Stock Turnover = Units Sold / Average Stock
```

### Unpaid Invoice Rate

```text
Unpaid Invoice Rate = Unpaid Invoices / Total Invoices * 100
```

### Visit Compliance Rate

```text
Visit Compliance Rate = Valid GPS Visits / Planned Visits * 100
```

---

## 11. Use in Power BI

The forecasting results will be used in Power BI to show:

- predicted demand by product,
- predicted demand by category,
- predicted demand by zone,
- products with possible stock pressure,
- products recommended for restocking,
- climate-aware product demand indicators.

---

## 12. Future Live Recommendation Extension

The current MVP uses generated CRM data and historical weather observations.

A future version can use live data through:

```text
Live Weather API
        |
        v
Django Recommendation Endpoint
        |
        v
Flutter Commercial Screen
        |
        v
Real-time Product Suggestions
```

This future extension would allow commercial users to receive live recommendations during field visits.

---

## 13. PFE Report Note

The intelligence layer of AgriSync AI combines explainable rule-based recommendation logic with a time-series demand prediction prototype. ARIMA was selected for the MVP because it is suitable for limited historical sales data, interpretable, and appropriate for academic validation. LSTM is discussed as a future extension for larger datasets and more advanced non-linear forecasting.
