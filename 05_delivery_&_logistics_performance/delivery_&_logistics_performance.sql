# 1.	Find the no. of days taken to deliver each order from the order’s purchase date as delivery time.
   #Also, calculate the difference (in days) between the estimated & actual delivery date of an order.
SELECT order_id,
       order_purchase_timestamp,
       order_estimated_delivery_date,
       order_delivered_customer_date,
       TIMESTAMP_DIFF(order_delivered_customer_date, order_purchase_timestamp, DAY) AS time_to_deliver,
       TIMESTAMP_DIFF(order_delivered_customer_date, order_estimated_delivery_date, DAY) AS delivery_delay_days
FROM `Target_Corporation.orders`
WHERE order_status = 'delivered' AND order_delivered_customer_date IS NOT NULL;


# 2.	Find out the top 5 states with the highest & lowest average delivery time.
# 3.	Find out the top 5 states where the order delivery is really fast as compared to the estimated date of delivery.
SELECT c.customer_state,
       COUNT(o.order_id) AS order_count,
       ROUND(AVG(TIMESTAMP_DIFF(o.order_delivered_customer_date, o.order_purchase_timestamp, DAY)), 2) AS avg_delivery_time,
       ROUND(AVG(TIMESTAMP_DIFF(o.order_delivered_customer_date, o.order_estimated_delivery_date, DAY)), 2) AS avg_delivery_delay
FROM `Target_Corporation.customers` c
INNER JOIN `Target_Corporation.orders` o
ON c.customer_id = o.customer_id
WHERE o.order_status = 'delivered' AND o.order_delivered_customer_date IS NOT NULL
GROUP BY c.customer_state;


# 4. On-Time Delivery Rate: What % of orders are delivered on or before estimated date?
SELECT total_order_count,
       on_time_orders,
       ROUND(SAFE_DIVIDE(on_time_orders, total_order_count) * 100, 2) AS on_time_pct
FROM
(SELECT COUNT(order_id) AS total_order_count,
       SUM(CASE WHEN order_delivered_customer_date <= order_estimated_delivery_date THEN 1 ELSE 0 END) AS on_time_orders
FROM `Target_Corporation.orders`
WHERE order_status = 'delivered' AND order_delivered_customer_date IS NOT NULL) a;

# 5. Distribution Analysis: Delivery Time Buckets -vs- Delay Buckets
WITH time_distribution_table AS(
SELECT order_id,
       TIMESTAMP_DIFF(order_delivered_customer_date, order_purchase_timestamp, Day) AS delivery_time_days,
       TIMESTAMP_DIFF(order_delivered_customer_date, order_estimated_delivery_date, Day) AS delivery_delay_days
FROM `Target_Corporation.orders`
WHERE order_status = 'delivered' AND order_delivered_customer_date IS NOT NULL)

SELECT COUNT(*) AS order_count,

       CASE WHEN delivery_time_days <= 3 THEN '0-3 days'
            WHEN delivery_time_days BETWEEN 4 AND 8 THEN '4-8 days'
            WHEN delivery_time_days BETWEEN 9 AND 15 THEN '9-15 days'
            WHEN delivery_time_days > 15 THEN '15+ days'
        END AS delivery_time_bucket,

        CASE WHEN delivery_delay_days < 0 THEN 'Early'
             WHEN delivery_delay_days = 0 THEN 'On Time'
             WHEN delivery_delay_days BETWEEN 1 AND 3 THEN '1-3 days late'
             WHEN delivery_delay_days BETWEEN 4 AND 8 THEN '4-8 days late'
             WHEN delivery_delay_days BETWEEN 9 AND 15 THEN '9-15 days late'
             WHEN delivery_delay_days > 15 THEN '15+ days late'
        END AS delivery_delay_bucket
FROM time_distribution_table
GROUP BY delivery_time_bucket, delivery_delay_bucket
ORDER BY order_count DESC;
