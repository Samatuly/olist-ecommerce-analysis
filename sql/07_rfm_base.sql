-- Q7. RFM scores per customer with NTILE(5)
-- Recency   = days since the last purchase (reference = day after the last order in data)
-- Frequency = number of orders
-- Monetary  = total revenue
WITH order_revenue AS (
    SELECT
        o.order_id,
        c.customer_unique_id,
        o.order_purchase_timestamp,
        SUM(oi.price + oi.freight_value) AS revenue
    FROM orders o
    JOIN customers   c  ON c.customer_id = o.customer_id
    JOIN order_items oi ON oi.order_id   = o.order_id
    GROUP BY o.order_id, c.customer_unique_id, o.order_purchase_timestamp
),
reference AS (
    SELECT MAX(order_purchase_timestamp)::date + 1 AS ref_date FROM orders
),
rfm AS (
    SELECT
        r.customer_unique_id,
        (SELECT ref_date FROM reference) - MAX(r.order_purchase_timestamp)::date AS recency_days,
        COUNT(*)                     AS frequency,
        ROUND(SUM(r.revenue), 2)     AS monetary
    FROM order_revenue r
    GROUP BY r.customer_unique_id
)
SELECT
    customer_unique_id,
    recency_days,
    frequency,
    monetary,
    NTILE(5) OVER (ORDER BY recency_days DESC) AS r_score,   -- 5 = most recent
    NTILE(5) OVER (ORDER BY monetary ASC)      AS m_score,   -- 5 = highest spend
    CASE WHEN frequency >= 3 THEN 3                          -- frequency is too skewed
         WHEN frequency = 2  THEN 2                          -- for quintiles (97% buy once)
         ELSE 1 END                            AS f_score
FROM rfm;
