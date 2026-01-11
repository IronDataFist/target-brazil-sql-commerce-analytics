## 1. DATASET STRUCTURE:
* The dataset consists of 8 relational tables representing customers, orders, payments, items, products, sellers, reviews, and geolocation.
* The core fact table is orders (99,441 records), with supporting fact tables (order_items, payments, order_reviews) and dimension tables.

## 2. CUSTOMERS & GEOGRAPHY:
* Total customers: 99,441
* Unique customers (customer_unique_id): 96,096
* Customers span: 27 states & 4,119 cities
* No NULL values are present in the customers table.
* Key observation: Each customer places exactly one order, meaning the dataset does not support repeat-customer or retention analysis.

## 3. ORDER COVERAGE & TIME RANGE:
* Total orders: 99,441
 *Order purchase time range: - First order: 2016-09-04
                             - Last order: 2018-10-17
* Order purchase timestamps are nearly unique, indicating consistent transactional activity over time.

## 4. ORDER STATUS DISTRIBUTION:
* he dataset contains 8 distinct order statuses.
* Majority of orders are delivered, while the remaining orders fall into non-delivered states such as: - canceled
                                                                                                       - unavailable
                                                                                                       - shipped
                                                                                                       - invoiced
                                                                                                       - processing
                                                                                                       - approved
                                                                                                       - created
* Analytical decision: Only orders with order_status = 'delivered' are eligible for delivery-time analysis.

## 5. DELIVERY TIMESTAMP DETAILS:
* Delivery-related timestamps contain NULLs in: - order_approved_at
                                                - order_delivered_carrier_date
                                                - order_delivered_customer_date
* These NULLs are primarily associated with non-delivered orders, reinforcing the need for status-based filtering.

## 6. PAYMENTS & ORDER ITEMS (Grain Awareness):
* Payments table contains more rows than orders, indicating:
* Multiple payment records per order
* Installment-based payments
* Order items table also has multiple rows per order, reflecting:
* Multiple products per order
* Analytical implication: All payment and revenue-related queries must use DISTINCT order_id or pre-aggregation to avoid double counting.

## 7. GEOLOCATION TABLE:
* Geolocation table contains 1M+ records with many-to-many mappings.
* It should be treated as an enrichment table, not joined directly to fact tables without aggregation.

8. IMPORTANT: KEY TABLE LIMITATION
* No repeat customers → customer-level lifetime analysis not possible.
* Delivery metrics apply only to delivered orders.
* Fan-out joins present in payments and order items require careful aggregation.
