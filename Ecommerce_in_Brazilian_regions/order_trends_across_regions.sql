# E-commerce Orders Evolution.

  Analyzes **order volume trends**, **customer concentration**, and **revenue distribution** across 27 Brazilian states.

## Table of Contents
- [1. Month-on-Month Orders](#31-month-on-month-orders)
- [2. Customer Distribution](#32-customer-distribution)
- [3. Orders & Revenue Distribution](#33-orders--revenue-distribution)
- [Executive Summary](#executive-summary)

## 1 Month-on-Month Orders
  
### Business Question
**How do order volumes evolve month-over-month across states? Which states show growth vs stagnation?**

### SQL Query
```sql
WITH monthly_orders_by_state AS (
SELECT c.customer_state,
       DATE_TRUNC(DATE(o.order_purchase_timestamp), MONTH) AS date,
       COUNT(order_id) total_orders_by_month
FROM `Target_Corporation.customers` c
JOIN `Target_Corporation.orders` o
ON c.customer_id = o.customer_id
GROUP BY c.customer_state, date)

SELECT customer_state,
       date,
       total_orders_by_month,
       LAG(total_orders_by_month) OVER (PARTITION BY customer_state ORDER BY date) AS prev_month_orders,
       CONCAT(ROUND(SAFE_DIVIDE(total_orders_by_month - LAG(total_orders_by_month) OVER (PARTITION BY customer_state ORDER BY date), LAG(total_orders_by_month) OVER (PARTITION BY customer_state ORDER BY date)) * 100, 2),'%') AS mom_growth_pct
FROM monthly_orders_by_state;

## 2 Customer Distribution & Concentration Risk
  
### Business Question
**Do a few states dominate the customer base?**

### SQL Query
```sql
WITH customer_count_by_state AS (
SELECT customer_state,
       COUNT(DISTINCT(customer_id)) customer_count
FROM `Target_Corporation.customers`
GROUP BY customer_state),

customer_count_by_state_pct AS (
SELECT customer_state,
        customer_count,
        ROUND((customer_count * 100) / SUM(customer_count) OVER(), 3) AS customer_count_pct
FROM customer_count_by_state)

SELECT customer_state,
       customer_count,
       customer_count_pct,
       ROUND(SUM(customer_count_pct) OVER(ORDER BY customer_count DESC)) AS cumulative_pct
FROM customer_count_by_state_pct;

## 3 Orders & Revenue Distribution
  
### Business Question
**Which states drive revenue? Are high-volume states also high-value?**

### SQL Query
```sql
WITH state_metrics AS (
SELECT c.customer_state,
       COUNT(c.customer_id) AS customer_count,
       COUNT(o.order_id) AS order_count,
       ROUND(SUM(oi.price + oi.freight_value), 3) AS total_revenue
FROM `Target_Corporation.customers` c
JOIN `Target_Corporation.orders` o
ON c.customer_id = o.customer_id
JOIN `Target_Corporation.order_items` oi
ON o.order_id = oi.order_id
GROUP BY c.customer_state)

SELECT customer_state,
       customer_count,
       order_count,
       total_revenue,
       ROUND((total_revenue / order_count), 2) AS avg_order_value,
       ROUND((order_count * 100) / SUM(order_count) OVER(), 2) AS order_pct,
       ROUND((total_revenue * 100) / SUM(total_revenue) OVER(), 2) AS revenue_pct
FROM state_metrics
ORDER BY order_pct DESC, revenue_pct DESC;
