#Analysis based on the payments:
  
#1.	Find the month on month no. of orders placed using different payment types.
SELECT year,
       month,
       payment_type,
       total_order_count,
       ROUND(((total_order_count - LAG(total_order_count) OVER (PARTITION BY month, payment_type ORDER BY year)) /
           LAG(total_order_count) OVER (PARTITION BY month, payment_type ORDER BY year)) * 100, 2) AS total_order_count_pct
FROM
(SELECT EXTRACT(YEAR FROM o.order_purchase_timestamp) AS year,
       EXTRACT(MONTH FROM o.order_purchase_timestamp) AS month,
       p.payment_type,
       COUNT(DISTINCT(o.order_id)) AS total_order_count
FROM `Target_Corporation.orders` o
INNER JOIN `Target_Corporation.payments` p
ON o.order_id = p.order_id
WHERE o.order_purchase_timestamp IS NOT NULL AND
      order_status = 'delivered' AND
      EXTRACT(YEAR FROM o.order_purchase_timestamp) IN (2017, 2018) AND
      EXTRACT(MONTH FROM o.order_purchase_timestamp) BETWEEN 1 AND 8 
GROUP BY p.payment_type, year, month) a
ORDER BY payment_type ASC, month ASC, year ASC;


# 2.	Find the no. of orders placed on the basis of the payment installments that have been paid.
    # Installments vs Order Value: Do higher-value orders use more installments?
SELECT payment_installments,
       COUNT(DISTINCT(order_id)) AS total_order_count,
       ROUND(SUM(payment_value), 2) AS total_payment_value,
       ROUND(SUM(payment_value) / COUNT(DISTINCT(order_id)), 2) AS avg_order_value
FROM `Target_Corporation.payments`
GROUP BY payment_installments
ORDER BY payment_installments;


# 3. Payment Type Share (% Contribution): 
     # % of orders by payment type
     # % of revenue by payment type.
     # AOV by payment type
WITH contribution_table AS (
SELECT payment_type, 
       COUNT(order_id) as order_count,
       SUM(payment_value) as revenue
FROM Target_Corporation.payments
WHERE payment_type != 'not_defined'
GROUP BY payment_type)

SELECT payment_type,
       order_count,
       ROUND(order_count * 100 / SUM(order_count) OVER(), 2) AS order_count_pct,
       ROUND(revenue, 2) AS revenue,
       ROUND(revenue * 100 / SUM(revenue) OVER(), 2) AS revenue_pct,
       ROUND((revenue / order_count), 2) AS avg_order_value
FROM contribution_table;
