# Import the dataset and do usual exploratory analysis steps like checking the structure & characteristics of the dataset:

# a. Data type of all columns in the "customers" table.
SELECT column_name, data_type
FROM `Target_Corporation`.INFORMATION_SCHEMA.COLUMNS
WHERE table_name = 'customers'
ORDER BY ordinal_position;


# b. Get the time range between which the orders were placed.
# c. Count the cities & states of customers who ordered during the given period.
SELECT COUNT(DISTINCT(c.customer_city)) AS distinct_city_count,
       COUNT(DISTINCT(c.customer_state)) AS distinct_state_count,
       MIN(o.order_purchase_timestamp) as first_order_date,
       MAX(o.order_purchase_timestamp) as last_order_date
FROM `Target_Corporation.orders` o
JOIN `Target_Corporation.customers` c
ON c.customer_id = o.customer_id;


# Order status distribution, Purpose: Justifies filtering decisions later.
# Question to answer: What is the distribution of order_status?
SELECT order_status, COUNT(order_status) as order_status_count
FROM `Target_Corporation.orders`
GROUP BY order_status
ORDER BY order_status_count DESC;


# Delivered vs non-delivered orders, Purpose: Establishes delivery-analysis eligibility.
# Question to answer: How many orders are delivered vs not delivered?
SELECT CASE WHEN order_status = 'delivered' THEN 'delivered'
            ELSE 'not delivered' END AS delivery_status,
       COUNT(order_status) as order_status_count
FROM `Target_Corporation.orders`
GROUP BY delivery_status
ORDER BY order_status_count DESC;


# One-order-per-customer validation, Purpose: Supports the “no repeat customers” limitation.
# Question to answer: Do any customers place more than one order?
SELECT customer_id, COUNT(order_id) as order_count
FROM `Target_Corporation.orders`
GROUP BY customer_id
HAVING order_count > 1;


# Payments fan-out check, Purpose: Justifies DISTINCT order_id usage later.
# Question to answer: How many orders have multiple payment records?
SELECT order_id, COUNT(order_id) AS multiple_orders_record
FROM `Target_Corporation.payments`
GROUP BY order_id
ORDER BY  multiple_orders_record DESC;
