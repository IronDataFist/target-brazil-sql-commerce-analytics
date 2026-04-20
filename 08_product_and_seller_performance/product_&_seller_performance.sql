# 1. Seller Performance Distribution: Do few sellers dominate revenue?
SELECT oi.seller_id,
       COUNT(DISTINCT oi.order_id) AS total_orders,
       ROUND(SUM(oi.price), 2) AS total_revenue,
       ROUND(SUM(oi.price) / COUNT(DISTINCT oi.order_id), 2) AS avg_order_value
FROM `Target_Corporation.order_items` oi
JOIN `Target_Corporation.orders` o
ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY oi.seller_id
ORDER BY total_revenue DESC
LIMIT 10;


# 2. Category–Seller Concentration: Are some product categories dominated by a few sellers? 
WITH category_seller AS (
SELECT COALESCE(p.`product category`, 'Unknown') AS category,
       oi.seller_id,
       SUM(oi.price) AS seller_revenue
FROM `Target_Corporation.order_items` oi
JOIN `Target_Corporation.orders` o
ON oi.order_id = o.order_id
JOIN `Target_Corporation.products` p
ON oi.product_id = p.product_id
WHERE o.order_status = 'delivered'
GROUP BY category, oi.seller_id),

category_summary AS (
SELECT category,
       COUNT(DISTINCT seller_id) AS seller_count,
       ROUND(SUM(seller_revenue), 2) AS total_revenue
FROM category_seller
GROUP BY category)

SELECT category,
       seller_count,
       total_revenue,
       ROUND(total_revenue / seller_count, 2) AS revenue_per_seller
FROM category_summary
ORDER BY total_revenue DESC;


# 3. Seller–Category Dependency: In each category, how much revenue is controlled by the top seller?
WITH category_seller_revenue AS (
SELECT COALESCE(p.`product category`, 'Unknown') AS category,
       oi.seller_id,
       SUM(oi.price) AS seller_revenue
FROM `Target_Corporation.order_items` oi
JOIN `Target_Corporation.orders` o
ON oi.order_id = o.order_id
JOIN `Target_Corporation.products` p
ON oi.product_id = p.product_id
WHERE o.order_status = 'delivered'
GROUP BY category, oi.seller_id),

ranked_sellers AS (
SELECT category,
       seller_id,
       seller_revenue,
       ROW_NUMBER() OVER (PARTITION BY category ORDER BY seller_revenue DESC) AS rn,
       SUM(seller_revenue) OVER (PARTITION BY category) AS category_total_revenue
FROM category_seller_revenue)

SELECT category,
       seller_id AS top_seller_id,
       ROUND(seller_revenue, 2) AS top_seller_revenue,
       ROUND(category_total_revenue, 2) AS total_category_revenue,
       ROUND(seller_revenue / category_total_revenue * 100, 2) AS top_seller_share_pct
FROM ranked_sellers
WHERE rn = 1
ORDER BY top_seller_share_pct DESC;
