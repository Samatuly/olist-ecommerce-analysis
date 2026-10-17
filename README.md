# Olist E-commerce Analysis

End-to-end analysis of ~100k orders from **Olist**, the largest department store on Brazilian marketplaces (2016–2018):
data cleaning in Python, a relational model in **PostgreSQL**, analytical SQL, customer segmentation (RFM) and cohort retention.

> 🚧 Work in progress — results and charts will be added as each stage is completed.

## Business questions

1. How did revenue, order count and average order value (AOV) change month by month?
2. Which product categories and states generate most of the revenue?
3. What share of customers come back for a second purchase (cohort retention)?
4. Which RFM segments do customers fall into, and which are the most valuable?
5. How does delivery time affect the review score?

## Tech stack

Python 3.11 · pandas · matplotlib · seaborn · PostgreSQL 16 · SQLAlchemy · Docker Compose · Jupyter

## Project structure

```
olist-ecommerce-analysis/
├── data/
│   ├── raw/            # original CSV files (not tracked by Git)
│   └── processed/      # cleaned tables
├── notebooks/
│   ├── 01_load.ipynb           # first look & data quality
│   ├── 02_cleaning.ipynb       # cleaning & preparation
│   ├── 03_sql_analysis.ipynb   # SQL queries against PostgreSQL
│   └── 04_metrics.ipynb        # RFM, cohorts, charts
├── sql/                # schema + one file per analytical query
├── src/
│   └── build_db.py     # loads clean data into PostgreSQL
├── reports/figures/    # charts used in this README
├── docker-compose.yml
├── .env.example
└── requirements.txt
```

## How to run

1. Download the dataset from [Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) and unzip the 9 CSV files into `data/raw/`.
2. Start PostgreSQL — choose **one** option:
   - **Docker** (no local install needed):
     ```bash
     cp .env.example .env
     docker compose up -d
     ```
   - **Local PostgreSQL** (14+): create the user and database, then copy `.env.example` to `.env`
     and adjust the values if yours differ:
     ```sql
     CREATE USER olist WITH PASSWORD 'olist';
     CREATE DATABASE olist OWNER olist;
     ```
3. Install dependencies:
   ```bash
   python -m venv .venv
   source .venv/bin/activate        # Windows: .\.venv\Scripts\Activate.ps1
   pip install -r requirements.txt
   ```
4. Run the notebooks in order, starting with `notebooks/01_load.ipynb`.

## Data quality findings (stage 1)

| Check | Result |
| --- | --- |
| Orders | 99,441 (97% delivered) |
| Unique customers | 96,096 (`customer_unique_id`; `customer_id` is per order) |
| Period | Sep 2016 – Oct 2018 (first and last months incomplete) |
| Orphan rows across foreign keys | none |
| Orders with several reviews | 547 |
| Products without category | 610 |

## Cleaning (stage 2)

`notebooks/02_cleaning.ipynb` produces 6 clean tables in `data/processed/`:

| Table | Rows | Primary key |
| --- | --- | --- |
| orders | 96,470 | order_id |
| order_items | 110,189 | order_id, order_item_id |
| order_payments | 100,748 | order_id, payment_sequential |
| order_reviews | 95,824 | order_id |
| customers | 96,470 | customer_id |
| products | 32,214 | product_id |

**Key definitions used throughout the project**

- **Revenue** = `price + freight_value` from order items (payments differ in only 0.26% of orders).
- **Customer** = `customer_unique_id` (93,350 unique buyers).
- **Trend period** = Jan 2017 – Aug 2018 (2016 has too few orders).
- **Late delivery** = delivered after the estimated date (6.8% of orders).

First insight: only **3.0% of customers** placed more than one order.

## Data source

[Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce), CC BY-NC-SA 4.0.
