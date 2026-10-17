-- Q3. Top 15 product categories by revenue, ranked with RANK()
WITH category_revenue AS (
    SELECT
        p.category,
        COUNT(DISTINCT oi.order_id)        AS orders,
        SUM(oi.price + oi.freight_value)   AS revenue,
        AVG(oi.price)                      AS avg_item_price
    FROM order_items oi
    JOIN products p ON p.product_id = oi.product_id
    JOIN orders   o ON o.order_id   = oi.order_id
    GROUP BY p.category
)
SELECT
    RANK() OVER (ORDER BY revenue DESC)                           AS rank,
    category,
    orders,
    ROUND(revenue, 2)                                             AS revenue,
    ROUND(100.0 * revenue / SUM(revenue) OVER (), 1)              AS revenue_share_pct,
    ROUND(100.0 * SUM(revenue) OVER (ORDER BY revenue DESC)
          / SUM(revenue) OVER (), 1)                              AS cumulative_share_pct,
    ROUND(avg_item_price, 2)                                      AS avg_item_price
FROM category_revenue
ORDER BY revenue DESC
LIMIT 15;
