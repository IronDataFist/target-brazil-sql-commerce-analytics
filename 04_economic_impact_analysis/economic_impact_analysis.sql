## Impact on Economy: Analyze the money movement by e-commerce by looking at order prices, freight and others.
       
# 1. Calculate the Total & Average value of order price for each state.
# 2. Calculate the Total & Average value of order freight for each state.
WITH order_level_metrix AS (
SELECT c.customer_state,
       o.order_id,
       SUM(oi.price) AS order_price,
       SUM(oi.freight_value) AS order_freight,
       SUM(oi.price + oi.freight_value) AS price_freight_value
FROM `Target_Corporation.customers` c
JOIN `Target_Corporation.orders` o
ON c.customer_id = o.customer_id
JOIN `Target_Corporation.order_items` oi
ON oi.order_id = o.order_id
GROUP BY c.customer_state, o.order_id)

SELECT customer_state,
       COUNT(order_id) AS total_orders,
       ROUND(COUNT(order_id) / SUM(COUNT(order_id)) OVER() * 100, 2) as total_orders_pct,
       ROUND(SUM(order_price), 2) AS total_price,
       ROUND(SUM(order_price) / SUM(SUM(order_price)) OVER() * 100, 2) as total_price_pct,
       ROUND(AVG(order_price), 2) AS avg_order_price,
       ROUND(SUM(order_freight), 2) AS total_freight,
       ROUND(AVG(order_freight), 2) AS avg_order_freight,
       ROUND(SUM(price_freight_value), 2) AS total_order_value,
       ROUND(SUM(price_freight_value) / SUM(SUM(price_freight_value)) OVER() * 100, 2) AS total_order_value_pct,
       ROUND(AVG(order_freight / price_freight_value) * 100, 2) AS avg_freight_pct_of_order
FROM order_level_metrix
GROUP BY customer_state
ORDER BY total_order_value DESC;


# 3. Get the % increase in the cost of orders from year 2017 to 2018 (include months between Jan to Aug only).
    # You can use the "payment_value" column in the payments table to get the cost of orders.
WITH cost_of_orders_table AS (
SELECT p.order_id,
       o.order_purchase_timestamp,
       SUM(p.payment_value) AS order_value
FROM `Target_Corporation.payments` p
JOIN `Target_Corporation.orders` o
ON p.order_id = o.order_id
WHERE (EXTRACT(YEAR FROM o.order_purchase_timestamp) = 2017) OR
      (EXTRACT(YEAR FROM o.order_purchase_timestamp) = 2018) AND
      (EXTRACT(MONTH FROM o.order_purchase_timestamp) BETWEEN 1 AND 8)
GROUP BY p.order_id, o.order_purchase_timestamp),
  
yearly_cost AS (
SELECT EXTRACT(YEAR FROM order_purchase_timestamp) AS year,
       ROUND(SUM(order_value), 2) AS total_order_value
FROM cost_of_orders_table
GROUP BY year)

SELECT year,
       total_order_value,
       ROUND(SAFE_DIVIDE((total_order_value - LAG(total_order_value) OVER (ORDER BY year ASC)), LAG(total_order_value) OVER (ORDER BY year ASC)) * 100, 2) AS pct_increase
FROM yearly_cost;


# 4.  Monthly Revenue Trend (2017-2018)(Jan–Aug)
WITH month_over_table AS (
SELECT EXTRACT(YEAR FROM o.order_purchase_timestamp) AS year,
       EXTRACT(MONTH FROM o.order_purchase_timestamp) AS month,
       COUNT(DISTINCT(o.order_id)) orders_count,
       ROUND(SUM(p.payment_value), 2) AS total_order_value
FROM `Target_Corporation.payments` p
JOIN `Target_Corporation.orders` o
ON p.order_id = o.order_id
WHERE EXTRACT(YEAR FROM o.order_purchase_timestamp) IN (2017, 2018) AND
      EXTRACT(MONTH FROM o.order_purchase_timestamp) BETWEEN 1 AND 8
GROUP BY year, month),

aov_table AS (
SELECT *,
       SAFE_DIVIDE(total_order_value, orders_count) AS avg_order_value
FROM month_over_table)

SELECT year,
       month,
       orders_count,
       total_order_value,
       ROUND(SAFE_DIVIDE((total_order_value - LAG(total_order_value) OVER (PARTITION BY month ORDER BY year ASC)), LAG(total_order_value) OVER (PARTITION BY month ORDER BY year ASC)) * 100, 2) AS yoy_revenue_growth_pct,
       ROUND(avg_order_value, 2) AS avg_order_value,
       ROUND(SAFE_DIVIDE((avg_order_value) - LAG(avg_order_value) OVER (PARTITION BY month ORDER BY year), LAG(avg_order_value) OVER (PARTITION BY month ORDER BY year)) * 100, 2) AS yoy_aov_growth_pct
FROM aov_table;
