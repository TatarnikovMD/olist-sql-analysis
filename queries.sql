SELECT 
    order_status, 
    COUNT(order_id) AS total_orders
FROM 
    orders
GROUP BY 
    order_status
ORDER BY 
    total_orders DESC;


SELECT 
    p.product_category_name, 
    oi.price
FROM 
    order_items oi
JOIN 
    products p ON oi.product_id = p.product_id
ORDER BY 
    oi.price DESC
LIMIT 10;


SELECT 
    c.customer_state, 
    SUM(oi.price) AS total_revenue,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM 
    order_items oi
JOIN 
    orders o ON oi.order_id = o.order_id
JOIN 
    customers c ON o.customer_id = c.customer_id
GROUP BY 
    c.customer_state
ORDER BY 
    total_revenue DESC
LIMIT 10;


WITH StateCategorySales AS (
    SELECT 
        c.customer_state, 
        p.product_category_name, 
        COUNT(*) AS sales_count
    FROM 
        order_items oi
    JOIN 
        products p ON oi.product_id = p.product_id
    JOIN 
        orders o ON oi.order_id = o.order_id
    JOIN 
        customers c ON o.customer_id = c.customer_id
    GROUP BY 
        c.customer_state, p.product_category_name
),
RankedSales AS (
    SELECT 
        customer_state, 
        product_category_name, 
        sales_count,
        ROW_NUMBER() OVER(PARTITION BY customer_state ORDER BY sales_count DESC) AS rank
    FROM 
        StateCategorySales
)
SELECT * 
FROM RankedSales
WHERE rank <= 3;


SELECT 
    DATE_TRUNC('month', order_purchase_timestamp) AS purchase_month,
    ROUND(AVG(EXTRACT(EPOCH FROM (order_delivered_customer_date - order_purchase_timestamp))/86400)::numeric, 1) AS avg_delivery_days
FROM 
    orders
WHERE 
    order_status = 'delivered'
GROUP BY 
    DATE_TRUNC('month', order_purchase_timestamp)
ORDER BY 
    purchase_month;