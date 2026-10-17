-- Q6. Monthly cohort retention
-- Cohort = month of a customer's first purchase.
-- month_number = months between the cohort month and the purchase month.
WITH purchases AS (
    SELECT
        c.customer_unique_id,
        DATE_TRUNC('month', o.order_purchase_timestamp)::date AS order_month
    FROM orders o
    JOIN customers c ON c.customer_id = o.customer_id
),
with_cohort AS (
    SELECT
        customer_unique_id,
        order_month,
        MIN(order_month) OVER (PARTITION BY customer_unique_id) AS cohort_month
    FROM purchases
),
activity AS (
    SELECT DISTINCT
        customer_unique_id,
        cohort_month,
        (EXTRACT(YEAR  FROM AGE(order_month, cohort_month)) * 12
       + EXTRACT(MONTH FROM AGE(order_month, cohort_month)))::int AS month_number
    FROM with_cohort
),
cohort_size AS (
    SELECT cohort_month, COUNT(DISTINCT customer_unique_id) AS customers
    FROM activity
    WHERE month_number = 0
    GROUP BY cohort_month
)
SELECT
    a.cohort_month,
    s.customers                                                AS cohort_size,
    a.month_number,
    COUNT(DISTINCT a.customer_unique_id)                       AS active_customers,
    ROUND(100.0 * COUNT(DISTINCT a.customer_unique_id) / s.customers, 2) AS retention_pct
FROM activity a
JOIN cohort_size s ON s.cohort_month = a.cohort_month
WHERE a.cohort_month BETWEEN '2017-01-01' AND '2018-08-01'
GROUP BY a.cohort_month, s.customers, a.month_number
ORDER BY a.cohort_month, a.month_number;
