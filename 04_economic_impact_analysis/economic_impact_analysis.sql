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
