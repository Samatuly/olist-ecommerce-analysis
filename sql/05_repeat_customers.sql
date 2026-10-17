-- Q5. How many customers come back? (customer = customer_unique_id)
WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS orders
    FROM orders o
    JOIN customers c ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
)
SELECT
    COUNT(*)                                              AS customers,
    COUNT(*) FILTER (WHERE orders >= 2)                   AS repeat_customers,
    ROUND(100.0 * COUNT(*) FILTER (WHERE orders >= 2) / COUNT(*), 2) AS repeat_rate_pct,
    ROUND(AVG(orders), 3)                                 AS avg_orders_per_customer,
    MAX(orders)                                           AS max_orders
FROM customer_orders;
