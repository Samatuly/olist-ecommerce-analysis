"""Shared helpers for connecting to the project database and running SQL files."""

import os
from pathlib import Path

import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine, text
from sqlalchemy.engine import URL

ROOT = Path(__file__).resolve().parents[1]
SQL_DIR = ROOT / "sql"


def get_engine():
    """Create a SQLAlchemy engine from the settings in .env."""
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


def run_sql_file(engine, filename):
    """Run a query stored in sql/<filename> and return the result as a DataFrame."""
    query = (SQL_DIR / filename).read_text(encoding="utf-8")
    with engine.connect() as conn:
        return pd.read_sql(text(query), conn)
