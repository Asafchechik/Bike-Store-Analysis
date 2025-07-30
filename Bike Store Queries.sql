--Bike Store Analysis 
--1. Sales and Orders Analysis 
--Total Revenue and Quantity Sold: 
SELECT CAST(ROUND(SUM(list_price * (1 - discount) * quantity), 0) AS DECIMAL(10,2)) AS Total_revenue 
, 
Sum(quantity)AS Quantity_sold 
FROM    
[sales].[order_items]

 

--Average Revenue per Order and Total Quantity Sold by Year: 
SELECT Datename(year, order_date) AS Year, 
 CAST(ROUND(AVG(list_price * (1 - discount) * quantity), 2) AS DECIMAL(10,2)) AS Average_revenue_per_order, 
Sum(quantity) AS Quantity 
FROM  [sales].[order_items] oi 
JOIN [sales].[orders] o 
ON oi.order_id = o.order_id 
GROUP  BY Datename(year, order_date) 
ORDER  BY Datename(year, order_date) ASC

  


-- Total Monthly Revenue Aggregated by Month and Year
SELECT 
    DATENAME(month, o.order_date) AS Month,
    YEAR(o.order_date) AS Year,
    CAST(ROUND(SUM(list_price * (1 - discount) * quantity), 0) AS DECIMAL(10,2)) AS Total_revenue
FROM [sales].[order_items] ot
JOIN [sales].[orders] o 
    ON ot.order_id = o.order_id
GROUP BY DATENAME(month, o.order_date), YEAR(o.order_date), DATEPART(month, o.order_date)
ORDER BY Year, DATEPART(month, o.order_date);





--2. Customer Analysis
-- Top 10 Customers by Total Order Value: 

SELECT TOP 10 
    c.customer_id, 
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name, 
    c.state AS State, 
    SUM(oi.quantity) AS Order_count, 
    CAST(ROUND(SUM(oi.list_price * oi.quantity * (1 - oi.discount)), 0) AS DECIMAL(10,2)) AS total_order_value
FROM [sales].[customers] c 
JOIN [sales].[orders] o ON c.customer_id = o.customer_id 
JOIN [sales].[order_items] oi ON o.order_id = oi.order_id 
GROUP BY 
    c.customer_id, 
    CONCAT(c.first_name, ' ', c.last_name), 
    c.state
ORDER BY total_order_value DESC;

 


-- Customer Distribution and Total Sales by State: 
SELECT COUNT(distinct c.customer_id) AS Customer_count, 
s.state, 
CAST(ROUND(SUM(oi.list_price * oi.quantity * (1 - oi.discount)), 0) AS DECIMAL(10,2)) AS total_sales
FROM [sales].[orders] o 
JOIN  [sales].[customers]c ON o.customer_id = c.customer_id 
JOIN [sales].[order_items] oi ON o.order_id = oi.order_id 
JOIN [sales].[stores] s ON o.store_id = s.store_id 
GROUP BY s.state 
ORDER BY total_sales DESC 

 

--3. Product Analysis
--Top 10 Products by Total Sales

SELECT TOP 10
    p.product_id,
    p.product_name,
    SUM(oi.quantity) AS total_quantity_sold,
    CAST(ROUND(SUM(oi.list_price * oi.quantity * (1 - oi.discount)), 0) AS DECIMAL(10,2)) AS total_sales
FROM [sales].[order_items] oi
JOIN [production].[products] p ON oi.product_id = p.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_sales DESC;

 

-- Least Profitable Products: 
SELECT TOP 10
    p.product_id,
    p.product_name,
    CAST(ROUND(SUM(oi.list_price * oi.quantity * (1 - oi.discount)), 0) AS DECIMAL(10,2)) AS total_sales
FROM [sales].[order_items] oi
JOIN [production].[products] p ON oi.product_id = p.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_sales ;

 



--4. Brands 
--Total Sales and Average Sales Price by Brand:

SELECT 
    b.brand_name,
    CAST(ROUND(SUM(oi.list_price * oi.quantity * (1 - oi.discount)), 0) AS DECIMAL(10,2)) AS total_sales,
    CAST(ROUND(AVG(oi.list_price * (1 - oi.discount)), 2) AS DECIMAL(10,2)) AS avg_sales_price
FROM [production].[brands] b
JOIN [production].[products] p ON b.brand_id = p.brand_id
JOIN [sales].[order_items] oi ON p.product_id = oi.product_id
GROUP BY b.brand_name
ORDER BY total_sales DESC;

 

--5. Categories 
--Total Sales and Average Sales Price by Product Category: 

SELECT 
    c.category_name,
    CAST(ROUND(SUM(oi.list_price * oi.quantity * (1 - oi.discount)), 0) AS DECIMAL(10,2)) AS total_sales,
    CAST(ROUND(AVG(oi.list_price * (1 - oi.discount)), 2) AS DECIMAL(10,2)) AS avg_sales_price
FROM [production].[categories] c
JOIN [production].[products] p ON c.category_id = p.category_id
JOIN [sales].[order_items] oi ON p.product_id = oi.product_id
GROUP BY c.category_name
ORDER BY total_sales DESC;

 


--6. Store Analysis 
--Total Sales by Store:

SELECT 
    s.store_id,
    s.store_name,
    s.city,
    s.state,
    CAST(ROUND(SUM(oi.list_price * oi.quantity * (1 - oi.discount)), 0) AS DECIMAL(10,2)) AS total_sales
FROM [sales].[order_items] oi
JOIN [sales].[orders] o ON oi.order_id = o.order_id
JOIN [sales].[stores] s ON o.store_id = s.store_id
GROUP BY s.store_id, s.store_name, s.city, s.state
ORDER BY total_sales DESC;
 


--Most Selling Product for Each Store: 

WITH RankedProducts AS (
    SELECT 
        s.store_id,
        s.store_name,
        p.product_id,
        p.product_name,
        SUM(oi.quantity) AS total_quantity_sold,
        ROW_NUMBER() OVER (PARTITION BY s.store_id ORDER BY SUM(oi.quantity) DESC) AS rank
    FROM [sales].[order_items] oi
    JOIN [sales].[orders] o ON oi.order_id = o.order_id
    JOIN [sales].[stores] s ON o.store_id = s.store_id
    JOIN [production].[products] p ON oi.product_id = p.product_id
    GROUP BY s.store_id, s.store_name, p.product_id, p.product_name
)
SELECT 
    store_id,
    store_name,
    product_id,
    product_name,
    total_quantity_sold
FROM RankedProducts
WHERE rank = 1;

 


--7. Staffs 
-- Total Number of Staff per Store:

SELECT  
s.store_id, 
s.store_name, 
COUNT(*) AS staff_count 
FROM  
[sales].[staffs]  st 
JOIN  
[sales].[stores] s ON st.store_id = s.store_id 
GROUP BY  
s.store_id, s.store_name; 


 



--Top Performing Staff Members by Total Sales and Units Sold
WITH RankedStaff AS (
    SELECT 
        CONCAT(s.first_name, ' ', s.last_name) AS staff_name,
        CAST(ROUND(SUM(oi.list_price * oi.quantity * (1 - oi.discount)), 0) AS DECIMAL(10,2)) AS total_sales,
        SUM(oi.quantity) AS units_sold,
        RANK() OVER (ORDER BY SUM(oi.list_price * oi.quantity * (1 - oi.discount)) DESC) AS sales_rank
    FROM [sales].[staffs] s
    JOIN [sales].[orders] o ON s.staff_id = o.staff_id
    JOIN [sales].[order_items] oi ON o.order_id = oi.order_id
    GROUP BY s.staff_id, s.first_name, s.last_name
)
SELECT staff_name, total_sales, units_sold
FROM RankedStaff
WHERE sales_rank <= 3

 









