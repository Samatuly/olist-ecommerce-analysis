-- Q4. Revenue, customers and AOV by customer state
WITH order_revenue AS (
    SELECT
        o.order_id,
        c.customer_state,
        c.customer_unique_id,
        SUM(oi.price + oi.freight_value) AS revenue,
        SUM(oi.freight_value)            AS freight
    FROM orders o
    JOIN customers   c  ON c.customer_id = o.customer_id
    JOIN order_items oi ON oi.order_id   = o.order_id
    GROUP BY o.order_id, c.customer_state, c.customer_unique_id
)
SELECT
    customer_state                                         AS state,
    COUNT(DISTINCT customer_unique_id)                     AS customers,
    COUNT(*)                                               AS orders,
    ROUND(SUM(revenue), 2)                                 AS revenue,
    ROUND(100.0 * SUM(revenue) / SUM(SUM(revenue)) OVER (), 1) AS revenue_share_pct,
    ROUND(AVG(revenue), 2)                                 AS aov,
    ROUND(100.0 * SUM(freight) / SUM(revenue), 1)          AS freight_share_pct
FROM order_revenue
GROUP BY customer_state
ORDER BY revenue DESC;
