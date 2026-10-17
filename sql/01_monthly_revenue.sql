-- Q1. Monthly revenue, orders and average order value (AOV)
-- Revenue = price + freight_value. Trend period: Jan 2017 – Aug 2018.
WITH order_revenue AS (
    SELECT
        o.order_id,
        DATE_TRUNC('month', o.order_purchase_timestamp)::date AS month,
        SUM(oi.price + oi.freight_value)                       AS revenue
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.order_purchase_timestamp >= '2017-01-01'
      AND o.order_purchase_timestamp <  '2018-09-01'
    GROUP BY o.order_id, month
)
SELECT
    month,
    COUNT(*)                      AS orders,
    ROUND(SUM(revenue), 2)        AS revenue,
    ROUND(AVG(revenue), 2)        AS aov
FROM order_revenue
GROUP BY month
ORDER BY month;
