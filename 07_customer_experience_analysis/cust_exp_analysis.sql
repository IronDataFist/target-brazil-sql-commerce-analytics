-- Customer Review Analysis:

# 1. How does delivery delay impact review score?
WITH order_delivery_duration_table AS (
SELECT order_id,
       TIMESTAMP_DIFF(order_delivered_customer_date, order_estimated_delivery_date, Day) AS delivery_delay_duration
FROM `Target_Corporation.orders`
WHERE order_delivered_customer_date IS NOT NULL AND order_status = 'delivered')

SELECT CASE WHEN od.delivery_delay_duration < 0 THEN 'Early'
            WHEN od.delivery_delay_duration = 0 THEN 'On Time'
            WHEN od.delivery_delay_duration BETWEEN 1 AND 3 THEN '1-3 days late'
            WHEN od.delivery_delay_duration BETWEEN 4 AND 7 THEN '4-7 days late'
            WHEN od.delivery_delay_duration > 7 THEN '7+ days late'
       END AS delay_buckets,
       ROUND(AVG(o.review_score), 2) AS avg_review_score,
       COUNT(o.order_id) AS orders_count
FROM `Target_Corporation.order_reviews` o
INNER JOIN order_delivery_duration_table od
ON o.order_id = od.order_id
GROUP BY delay_buckets
ORDER BY CASE WHEN delay_buckets = 'Early' THEN 1
              WHEN delay_buckets = 'On Time' THEN 2
              WHEN delay_buckets = '1-3 days late' THEN 3
              WHEN delay_buckets = '4-7 days late' THEN 4
              WHEN delay_buckets = '7+ days late' THEN 5
         END;


# 2. Do payment types influence customer satisfaction?
WITH order_payment_table AS (
SELECT order_id,
       ANY_VALUE(payment_type) as payment_type
FROM `Target_Corporation.payments`
GROUP BY order_id)

SELECT op.payment_type,
       COUNT(op.order_id) AS order_count,
       ROUND(AVG(ore.review_score), 2) AS avg_review_score
FROM order_payment_table op
INNER JOIN `Target_Corporation.order_reviews` ore
ON ore.order_id = op.order_id
GROUP BY op.payment_type
ORDER BY avg_review_score DESC;
