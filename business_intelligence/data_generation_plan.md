# AgriSync AI - Simulated CRM Data Generation Plan

## Objective

This document defines the structure and logic of the simulated CRM dataset that will be used for Business Intelligence, Data Warehouse validation, Power BI dashboards, and AI recommendation testing.

The simulated dataset will be realistic and aligned with the AgriSync AI domain: agricultural sales, products, clients, stock, invoices, visits, zones, and climate-aware decision support.

---

## Why Simulated Data Is Needed

The operational CRM database currently contains limited test data.

For a meaningful BI and AI prototype, the project needs enough records to show:

- monthly sales trends,
- product performance,
- client segmentation,
- stock monitoring,
- unpaid invoices,
- commercial visits,
- zone-based activity,
- climate-aware recommendations.

If real company data is unavailable or incomplete, simulated data will be used to validate the prototype.

---

## Target Dataset Volume

| Entity | Target Volume |
|---|---:|
| Clients | 80 |
| Products | 30 |
| Orders | 600 |
| Order lines | 1200 to 1800 |
| Invoices | 600 |
| Visits | 250 |
| Zones | 5 |
| Users | 3 to 5 |
| Weather records | 12 months by zone |

---

## Zones

The simulated CRM will use agricultural zones.

Example zones:

| Zone ID | Zone Name | Agricultural Context |
|---:|---|---|
| 1 | Nabeul | Citrus, vegetables, humid coastal climate |
| 2 | Sfax | Olive trees, dry climate |
| 3 | Beja | Cereals, rainfall-dependent agriculture |
| 4 | Kairouan | Dry inland crops |
| 5 | Gabes | Oasis agriculture, heat and salinity risk |

---

## Client Data Rules

Each client should have:

- name,
- phone,
- address,
- pricing category,
- zone,
- latitude,
- longitude.

Pricing categories:

| Category | Meaning |
|---|---|
| A | Large client / high volume |
| B | Medium client |
| C | Small client |

Client distribution:

- 20% category A,
- 50% category B,
- 30% category C.

---

## Product Data Rules

Products should represent agricultural commercial products.

Example categories:

- Fertilizers
- Seeds
- Pesticides
- Fungicides
- Irrigation products
- Soil treatment
- Climate-adapted products

Each product should have:

- product name,
- category,
- price,
- stock quantity.

Stock rules:

- some products have high stock,
- some products have medium stock,
- some products have low stock to support stock alerts.

---

## Order Data Rules

Orders should be generated across 12 months.

Each order should have:

- client,
- order date,
- status,
- total amount.

Order statuses:

- draft,
- validated,
- delivered,
- cancelled.

Most orders should be validated or delivered.

Suggested distribution:

| Status | Percentage |
|---|---:|
| delivered | 60% |
| validated | 25% |
| draft | 10% |
| cancelled | 5% |

---

## Order Line Rules

Each order should contain between 1 and 4 products.

Each order line should include:

- order ID,
- product name,
- quantity,
- unit price,
- line total.

Calculation:

```text
line_total = quantity * unit_price

```

---

## Invoice Rules

Each order should generate one invoice.

Each invoice should include:

- invoice ID,
- client ID,
- order ID,
- amount due,
- due date,
- status,
- delay days.

Invoice statuses:

- up_to_date,
- unpaid,
- delayed,
- partially_paid.

Suggested invoice status distribution:

| Status | Percentage |
|---|---:|
| up_to_date | 65% |
| unpaid | 15% |
| delayed | 15% |
| partially_paid | 5% |

Delayed invoices should have `delay_days` greater than 0.

Invoices with `up_to_date` status should have `delay_days` equal to 0.

---

## Visit Rules

Commercial users should visit clients in the field.

Each visit should include:

- visit ID,
- client ID,
- commercial user ID,
- visit date,
- visit time,
- GPS location,
- latitude,
- longitude,
- validation status.

Visit validation statuses:

- valid,
- invalid,
- pending.

Suggested visit validation distribution:

| Status | Percentage |
|---|---:|
| valid | 75% |
| pending | 15% |
| invalid | 10% |

---

## Weather and Climate Data Rules

Weather data will be linked with CRM and sales data using:

- zone,
- month,
- date.

Climate indicators:

- temperature,
- humidity,
- rainfall,
- drought risk.

Example drought risk levels:

- low,
- medium,
- high.

---

## Power BI Use Cases

The generated data should support:

- revenue by month,
- revenue by zone,
- revenue by product category,
- top clients,
- top products,
- orders by status,
- unpaid invoices,
- delayed invoices,
- visit validation status,
- low-stock products,
- climate risk by zone,
- recommended products by climate condition.

---

## AI Recommendation Use Cases

The simulated dataset will help test recommendation rules such as:

- recommend drought-adapted products in high drought-risk zones,
- recommend fungicides when humidity is high,
- reduce recommendation score if stock is low,
- increase recommendation score for products with strong sales history in a zone.

Example scoring logic:

```text
recommendation_score = climate_score + stock_score + sales_score + zone_score
```

---

## Data Quality Rules

The generated data must respect these constraints:

- every order belongs to an existing client,
- every order line belongs to an existing order,
- every invoice belongs to an existing order and client,
- every visit belongs to an existing client,
- every visit belongs to a commercial user,
- every client belongs to a zone,
- every product belongs to a product category,
- product prices must be positive,
- stock quantities must be zero or positive,
- order quantities must be positive,
- line totals must be calculated correctly,
- invoice amounts must match order totals,
- dates must cover several months,
- weather data must be linked to zones and dates,
- no private real client data should be exposed.

---

## PFE Report Note

A realistic simulated CRM dataset was planned to validate the analytical layers of AgriSync AI.

This dataset will support:

- Data Warehouse loading,
- Talend ETL testing,
- Power BI dashboards,
- climate-risk analysis,
- stock monitoring,
- invoice monitoring,
- AI recommendation logic.

The simulated dataset respects the business structure of the CRM while protecting privacy and supporting MVP validation.