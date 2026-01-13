# Main CTE Table used for all orders and Time trend:
WITH orders_time_status AS (
SELECT order_id,
       order_purchase_timestamp,
       EXTRACT(YEAR FROM order_purchase_timestamp) AS order_year,
       EXTRACT(MONTH FROM order_purchase_timestamp) AS order_month_num,
       EXTRACT(DAY FROM order_purchase_timestamp) AS order_day,
       Date(order_purchase_timestamp) AS order_date,
       EXTRACT(HOUR FROM order_purchase_timestamp) AS order_hour,
       FORMAT_DATETIME('%A', order_purchase_timestamp) AS order_weekday,
       CASE WHEN EXTRACT(HOUR FROM order_purchase_timestamp) BETWEEN 0 AND 6 THEN 'Dawn'
            WHEN EXTRACT(HOUR FROM order_purchase_timestamp) BETWEEN 7 AND 12 THEN 'Morning'
            WHEN EXTRACT(HOUR FROM order_purchase_timestamp) BETWEEN 13 AND 18 THEN 'Afternoon'
            WHEN EXTRACT(HOUR FROM order_purchase_timestamp) BETWEEN 19 AND 23 THEN 'Night'
       END AS time_of_day
FROM `Target_Corporation.orders`)

#1. Is there a growing trend in the no. of orders placed over the past years? 
SELECT order_year, first_date_of_order, last_date_of_order, total_orders_count,
       ROUND(total_orders_count * 100.0 / SUM(total_orders_count) OVER (), 2) AS total_orders_pct
FROM (
SELECT order_year,
       MIN(order_purchase_timestamp) AS first_date_of_order,
       MAX(order_purchase_timestamp) AS last_date_of_order,
       COUNT(order_id) AS total_orders_count
FROM orders_time_status
WHERE order_year IS NOT NULL
GROUP BY order_year) a
ORDER BY total_orders_pct DESC;

#2. Can we see some kind of monthly seasonality in terms of the no. of orders being placed? 
SELECT order_year,
       order_month_num,
       COUNT(order_id) AS monthly_seasonality
FROM orders_time_status
GROUP BY order_month_num, order_year
ORDER BY order_month_num;

#3. During what time of the day, do the Brazilian customers mostly place their orders? (Dawn, Morning, Afternoon or Night)
SELECT time_of_day, no_of_orders,
       ROUND(SAFE_DIVIDE(no_of_orders * 100, SUM(no_of_orders) OVER ()), 2) AS order_count_percentage
FROM
(SELECT time_of_day,
       COUNT(order_id) AS no_of_orders
FROM orders_time_status
GROUP BY time_of_day) a
ORDER BY order_count_percentage DESC;

#4. Weekday vs Weekend demand:
SELECT CASE WHEN order_weekday IN ('Saturday', 'Sunday') THEN 'Weekend'
            ELSE 'Weekday'
       END AS day_of_week,
       COUNT(order_id) AS order_count
FROM orders_time_status
GROUP BY day_of_week;

#5. Calculate % contribution of: Top 1 month Top 3 months Top 5 months
SELECT order_year,
       order_month_num,
       ROUND(SAFE_DIVIDE(monthly_seasonality * 100, SUM(monthly_seasonality) OVER ()), 2) AS order_count_percentage
FROM
(SELECT order_year,
        order_month_num,
        COUNT(order_id) AS monthly_seasonality
FROM orders_time_status
GROUP BY order_year, order_month_num
ORDER BY order_month_num) a
ORDER BY order_count_percentage DESC;

#6. Any special dates that contributes generously to number of orders.
SELECT order_year,
       order_month,
       order_day,
       COUNT(order_id) total_order_count
FROM orders_time_status
GROUP BY order_year, order_month, order_day
ORDER BY total_order_count DESC
LIMIT 5;
