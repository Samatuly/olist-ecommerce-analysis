"""Load the clean Olist tables into PostgreSQL.

Steps:
1. read connection settings from .env
2. (re)create the schema from sql/schema.sql
3. bulk-load every file from data/processed/ with COPY
4. verify row counts against the source files

Usage (from the project root):
    python src/build_db.py
"""

import io
import os
import sys
import time
from pathlib import Path

import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine, text
from sqlalchemy.engine import URL

ROOT = Path(__file__).resolve().parents[1]
PROCESSED = ROOT / "data" / "processed"
SCHEMA = ROOT / "sql" / "schema.sql"

# Parents are loaded before children so foreign keys are satisfied.
LOAD_ORDER = ["customers", "products", "orders", "order_items", "order_payments", "order_reviews"]

# Whole-number columns that pandas stores as float because of missing values.
INTEGER_COLUMNS = {
    "products": [
        "product_photos_qty",
        "product_weight_g",
        "product_length_cm",
        "product_height_cm",
        "product_width_cm",
    ],
}


def get_engine():
    load_dotenv(ROOT / ".env")
    url = URL.create(
        "postgresql+psycopg2",
        username=os.getenv("POSTGRES_USER", "olist"),
        password=os.getenv("POSTGRES_PASSWORD", "olist"),
        host=os.getenv("POSTGRES_HOST", "localhost"),
        port=int(os.getenv("POSTGRES_PORT", "5432")),
        database=os.getenv("POSTGRES_DB", "olist"),
    )
    # Explicit UTF-8 avoids encoding errors on Windows with a non-English locale.
    return create_engine(url, connect_args={"client_encoding": "utf8"})


def create_schema(engine):
    with engine.begin() as conn:
        conn.exec_driver_sql(SCHEMA.read_text(encoding="utf-8"))
    print("Schema created from sql/schema.sql")


def load_table(engine, name):
    df = pd.read_csv(PROCESSED / f"{name}.csv")
    for col in INTEGER_COLUMNS.get(name, []):
        df[col] = df[col].astype("Int64")

    buffer = io.StringIO()
    df.to_csv(buffer, index=False, header=False)
    buffer.seek(0)

    columns = ", ".join(df.columns)
    raw = engine.raw_connection()
    try:
        with raw.cursor() as cur:
            cur.copy_expert(f"COPY {name} ({columns}) FROM STDIN WITH (FORMAT csv)", buffer)
        raw.commit()
    finally:
        raw.close()
    return len(df)


def main():
    missing = [n for n in LOAD_ORDER if not (PROCESSED / f"{n}.csv").exists()]
    if missing:
        sys.exit(f"Missing files in data/processed/: {missing}. Run notebooks/02_cleaning.ipynb first.")

    engine = get_engine()
    start = time.time()
    create_schema(engine)

    expected = {}
    for name in LOAD_ORDER:
        expected[name] = load_table(engine, name)
        print(f"Loaded {name:<15} {expected[name]:>9,} rows")

    with engine.connect() as conn:
        conn.execute(text("ANALYZE"))
        for name, rows in expected.items():
            actual = conn.execute(text(f"SELECT COUNT(*) FROM {name}")).scalar()
            if actual != rows:
                sys.exit(f"Row count mismatch in {name}: expected {rows}, found {actual}")

    print(f"All row counts verified. Done in {time.time() - start:.1f} s")


if __name__ == "__main__":
    main()
