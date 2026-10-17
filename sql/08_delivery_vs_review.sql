-- Q8. Does delivery speed affect the review score?
SELECT
    CASE
        WHEN o.delay_days <= -10 THEN '1. 10+ days early'
        WHEN o.delay_days <=   0 THEN '2. 0-9 days early'
        WHEN o.delay_days <=   5 THEN '3. 1-5 days late'
        WHEN o.delay_days <=  15 THEN '4. 6-15 days late'
        ELSE                          '5. 15+ days late'
    END                                                         AS delivery_vs_promise,
    COUNT(*)                                                    AS orders,
    ROUND(AVG(r.review_score), 2)                               AS avg_score,
    ROUND(100.0 * COUNT(*) FILTER (WHERE r.review_score <= 2) / COUNT(*), 1) AS low_score_pct,
    ROUND(100.0 * COUNT(*) FILTER (WHERE r.review_score = 5)  / COUNT(*), 1) AS five_star_pct
FROM orders o
JOIN order_reviews r ON r.order_id = o.order_id
GROUP BY delivery_vs_promise
ORDER BY delivery_vs_promise;
