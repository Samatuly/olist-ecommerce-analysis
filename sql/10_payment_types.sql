-- Q10. Payment methods: share, typical amount and installments
SELECT
    payment_type,
    COUNT(DISTINCT order_id)                                        AS orders,
    ROUND(100.0 * COUNT(DISTINCT order_id)
          / (SELECT COUNT(DISTINCT order_id) FROM order_payments), 1) AS order_share_pct,
    ROUND(100.0 * SUM(payment_value) / SUM(SUM(payment_value)) OVER (), 1) AS value_share_pct,
    ROUND(AVG(payment_value), 2)                                    AS avg_payment,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY payment_value)::numeric, 2) AS median_payment,
    ROUND(AVG(payment_installments), 1)                             AS avg_installments
FROM order_payments
GROUP BY payment_type
ORDER BY orders DESC;
