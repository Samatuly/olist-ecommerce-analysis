-- =============================================================
-- Olist e-commerce analysis: database schema (PostgreSQL 14+)
-- Tables are created from the clean files in data/processed/.
-- Run via:  python src/build_db.py
-- =============================================================

DROP TABLE IF EXISTS order_reviews, order_payments, order_items, orders, products, customers CASCADE;

-- -------------------------------------------------------------
-- Customers: one row per order-level customer_id.
-- customer_unique_id identifies the real person (use it for
-- retention, cohorts and RFM).
-- -------------------------------------------------------------
CREATE TABLE customers (
    customer_id              VARCHAR(32) PRIMARY KEY,
    customer_unique_id       VARCHAR(32) NOT NULL,
    customer_zip_code_prefix INTEGER,
    customer_city            TEXT,
    customer_state           CHAR(2)     NOT NULL
);

-- -------------------------------------------------------------
-- Products with English category names ('unknown' if missing).
-- -------------------------------------------------------------
CREATE TABLE products (
    product_id            VARCHAR(32) PRIMARY KEY,
    category              TEXT        NOT NULL,
    product_category_name TEXT        NOT NULL,
    product_photos_qty    SMALLINT,
    product_weight_g      INTEGER,
    product_length_cm     SMALLINT,
    product_height_cm     SMALLINT,
    product_width_cm      SMALLINT
);

-- -------------------------------------------------------------
-- Orders: delivered orders only, with delivery features.
-- -------------------------------------------------------------
CREATE TABLE orders (
    order_id                      VARCHAR(32) PRIMARY KEY,
    customer_id                   VARCHAR(32) NOT NULL REFERENCES customers (customer_id),
    order_status                  VARCHAR(20) NOT NULL,
    order_purchase_timestamp      TIMESTAMP   NOT NULL,
    order_approved_at             TIMESTAMP,
    order_delivered_carrier_date  TIMESTAMP,
    order_delivered_customer_date TIMESTAMP   NOT NULL,
    order_estimated_delivery_date TIMESTAMP   NOT NULL,
    delivery_days                 INTEGER     NOT NULL CHECK (delivery_days >= 0),
    delay_days                    INTEGER     NOT NULL,
    is_late                       BOOLEAN     NOT NULL
);

-- -------------------------------------------------------------
-- Order items: one row per unit sold.
-- Revenue = price + freight_value.
-- -------------------------------------------------------------
CREATE TABLE order_items (
    order_id            VARCHAR(32)   NOT NULL REFERENCES orders (order_id),
    order_item_id       SMALLINT      NOT NULL,
    product_id          VARCHAR(32)   NOT NULL REFERENCES products (product_id),
    seller_id           VARCHAR(32)   NOT NULL,
    shipping_limit_date TIMESTAMP     NOT NULL,
    price               NUMERIC(10,2) NOT NULL CHECK (price > 0),
    freight_value       NUMERIC(10,2) NOT NULL CHECK (freight_value >= 0),
    PRIMARY KEY (order_id, order_item_id)
);

-- -------------------------------------------------------------
-- Payments: an order can be paid in several parts.
-- -------------------------------------------------------------
CREATE TABLE order_payments (
    order_id             VARCHAR(32)   NOT NULL REFERENCES orders (order_id),
    payment_sequential   SMALLINT      NOT NULL,
    payment_type         VARCHAR(20)   NOT NULL,
    payment_installments SMALLINT      NOT NULL,
    payment_value        NUMERIC(10,2) NOT NULL CHECK (payment_value >= 0),
    PRIMARY KEY (order_id, payment_sequential)
);

-- -------------------------------------------------------------
-- Reviews: the latest review per order.
-- -------------------------------------------------------------
CREATE TABLE order_reviews (
    order_id                VARCHAR(32) PRIMARY KEY REFERENCES orders (order_id),
    review_id               VARCHAR(32) NOT NULL,
    review_score            SMALLINT    NOT NULL CHECK (review_score BETWEEN 1 AND 5),
    review_creation_date    TIMESTAMP   NOT NULL,
    review_answer_timestamp TIMESTAMP   NOT NULL
);

-- -------------------------------------------------------------
-- Indexes on the columns used for joins and filters.
-- (Primary keys are indexed automatically.)
-- -------------------------------------------------------------
CREATE INDEX idx_customers_unique_id   ON customers (customer_unique_id);
CREATE INDEX idx_customers_state       ON customers (customer_state);
CREATE INDEX idx_orders_customer_id    ON orders (customer_id);
CREATE INDEX idx_orders_purchase_ts    ON orders (order_purchase_timestamp);
CREATE INDEX idx_order_items_product   ON order_items (product_id);
CREATE INDEX idx_products_category     ON products (category);
