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
│   ├── build_db.py     # loads clean data into PostgreSQL
│   └── db.py           # connection helper used by the notebooks
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
4. Run `notebooks/01_load.ipynb` and `notebooks/02_cleaning.ipynb` — the second one writes clean files to `data/processed/`.
5. Load the clean data into PostgreSQL (recreates all tables, ~15 s):
   ```bash
   python src/build_db.py
   ```
6. Continue with `notebooks/03_sql_analysis.ipynb`.

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

## Database (stage 3)

`sql/schema.sql` defines 6 tables with primary keys, foreign keys, `CHECK` constraints and indexes;
`src/build_db.py` bulk-loads the clean files with `COPY` and verifies row counts.

```
customers ──< orders ──< order_items >── products
                 ├──< order_payments
                 └──── order_reviews (1 : 0..1)
```

## SQL analysis (stage 3)

10 queries in `sql/`, executed and interpreted in `notebooks/03_sql_analysis.ipynb`
(CTEs, window functions `LAG` / `RANK` / `NTILE` / `SUM() OVER`, `FILTER`, `PERCENTILE_CONT`, cohort logic with `AGE`).

| Question | Finding |
| --- | --- |
| Revenue trend | Fast growth in 2017, **plateau at ~1.0–1.1 M BRL/month** from Mar 2018 |
| Growth driver | More orders; AOV stable at ~150–170 BRL |
| Top categories | 5 of 74 categories = 39% of revenue |
| Geography | SP + RJ + MG = 63% of revenue; remote states pay up to 22% freight |
| Retention | **Only 3.0% of customers buy twice**; month-1 cohort retention < 1% |
| Satisfaction | Average score **4.3 on time vs. 2.3 late** (1.7 when 5+ days late) |
| Payments | 77% credit card, 3.5 installments on average |

## Data source

[Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce), CC BY-NC-SA 4.0.
