-- Q9. Cumulative revenue and year-over-year comparison by month
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
    ROUND(revenue, 2)                                                AS revenue,
    ROUND(SUM(revenue) OVER (ORDER BY month), 2)                     AS cumulative_revenue,
    ROUND(SUM(revenue) OVER (PARTITION BY EXTRACT(YEAR FROM month)
                             ORDER BY month), 2)                     AS ytd_revenue,
    ROUND(100.0 * (revenue - LAG(revenue, 12) OVER (ORDER BY month))
          / LAG(revenue, 12) OVER (ORDER BY month), 1)               AS yoy_growth_pct
FROM monthly
ORDER BY month;
