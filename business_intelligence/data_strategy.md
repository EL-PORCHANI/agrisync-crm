# AgriSync AI - Data Strategy

## Objective

This document defines the data strategy used for the Business Intelligence, Data Warehouse, Power BI dashboards, and AI recommendation prototype of the AgriSync AI project.

The objective is to explain which data will be used, where it comes from, how it is prepared, and why it is sufficient for PFE validation.

---

## Project Context

AgriSync AI is an intelligent climate-smart agricultural CRM platform.

The system combines:

- Flutter mobile CRM
- Django REST backend
- SQLite offline-first local database
- Synchronization engine
- JWT authentication
- Talend ETL
- Data Warehouse
- Power BI dashboards
- Weather and climate data
- AI-based recommendation logic

The objective is to transform operational CRM data into decision-support indicators for agricultural companies.

---

## Data Sources

The project uses three types of data:

1. Operational CRM data
2. Simulated analytical data
3. Public weather and climate data

---

## 1. Operational CRM Data

Operational CRM data comes from the AgriSync AI application and backend database.

Main entities:

- Clients
- Products
- Orders
- Order lines
- Invoices
- Visits
- Stocks
- Users
- Zones

This data represents the commercial activity of the company.

Examples:

- client information
- product catalog
- product prices
- stock quantities
- customer orders
- invoice status
- commercial visits
- GPS visit validation

---

## 2. Simulated Analytical Data

If the company does not provide enough real data, a realistic simulated dataset will be created.

The simulated data will respect the structure of the real CRM system.

The goal is not to invent unrealistic results, but to create enough records to validate:

- Data Warehouse loading
- Power BI dashboards
- sales analysis
- stock monitoring
- invoice follow-up
- climate-aware indicators
- recommendation logic

Recommended dataset size for the PFE prototype:

| Entity | Target Volume |
|---|---:|
| Clients | 50 to 100 |
| Products | 20 to 40 |
| Orders | 300 to 1000 |
| Order lines | 500 to 2000 |
| Invoices | 300 to 1000 |
| Visits | 100 to 300 |
| Zones | 3 to 8 |
| Weather records | 12 months by zone |

---

## 3. Public Weather and Climate Data

Weather and climate data will come from public APIs or open datasets.

Possible sources:

- Open-Meteo Historical Weather API
- NASA POWER Agroclimatology API
- FAOSTAT
- World Bank Climate Change Knowledge Portal

The climate data may include:

- temperature
- rainfall
- humidity
- drought indicators
- regional climate risk
- seasonal patterns

This data will be linked with commercial data using:

- zone
- date
- region
- climate risk level

---

## Data Privacy

If real company data is used, it must be anonymized.

Private information should not be exposed in the report or screenshots.

Examples of anonymization:

- replace client names with generated names
- hide phone numbers
- avoid personal addresses
- use zone names instead of exact private locations
- remove sensitive commercial information

---

## Why Simulated Data Is Acceptable

For the PFE MVP, simulated data is acceptable because the goal is to validate the system architecture and analytical logic.

The project validates:

- data extraction
- ETL transformation
- Data Warehouse structure
- Power BI indicators
- climate-aware recommendation rules
- decision-support workflow

The objective is not to prove a final industrial AI model, but to demonstrate a functional and extensible decision-support platform.

---

## Data Preparation Workflow

The data preparation workflow is:

1. Collect available CRM data.
2. Anonymize real company data if available.
3. Generate realistic missing CRM records if needed.
4. Extract CRM data into CSV files.
5. Load data into the Data Warehouse.
6. Enrich the analytical data with weather and climate indicators.
7. Use Power BI to create dashboards.
8. Use climate and stock data for product recommendation logic.

---

## Data Quality Rules

The dataset must respect these rules:

- Each order must belong to a client.
- Each order line must belong to an order.
- Each order line must contain a product name, quantity, price, and line total.
- Each invoice must belong to an order and a client.
- Each visit must belong to a client and commercial user.
- Each client should belong to a zone.
- Each product should have a category and stock quantity.
- Weather data should be linked to date and zone.
- Missing values should be cleaned or documented.

---

## Use in Power BI

The prepared data will support Power BI dashboards such as:

- Sales Performance Dashboard
- Stock Monitoring Dashboard
- Invoice Monitoring Dashboard
- Climate Risk Dashboard

Example charts:

- total revenue by month
- revenue by product
- orders by zone
- top clients
- low stock products
- unpaid invoices
- visit validation status
- climate risk by region
- recommended products by zone

---

## Use in AI Recommendation Logic

The AI recommendation prototype will use a rule-based scoring approach.

Inputs:

- client zone
- weather condition
- climate risk
- product category
- stock availability
- sales history

Example rules:

- If drought risk is high, prioritize drought-adapted products.
- If humidity is high, recommend anti-fungal products.
- If stock is low, reduce recommendation priority.
- If a product performs well in a zone, increase its recommendation score.

---

## PFE Report Note

The AgriSync AI project uses a mixed data strategy combining operational CRM data, realistic simulated data, and public climate data. This approach allows the validation of the Data Warehouse, ETL workflow, Power BI dashboards, and AI recommendation prototype while respecting data privacy and MVP constraints.