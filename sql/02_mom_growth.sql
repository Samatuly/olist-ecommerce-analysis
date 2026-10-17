-- Q2. Month-over-month revenue growth with LAG()
WITH monthly AS (
    SELECT
        DATE_TRUNC('month', o.order_purchase_timestamp)::date AS month,
        SUM(oi.price + oi.freight_value)                       AS revenue
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.order_purchase_timestamp >= '2017-01-01'
      AND o.order_purchase_timestamp <  '2018-09-01'
    GROUP BY month
)
SELECT
    month,
    ROUND(revenue, 2)                                        AS revenue,
    ROUND(LAG(revenue) OVER (ORDER BY month), 2)             AS prev_month_revenue,
    ROUND(100.0 * (revenue - LAG(revenue) OVER (ORDER BY month))
          / LAG(revenue) OVER (ORDER BY month), 1)           AS mom_growth_pct
FROM monthly
ORDER BY month;
