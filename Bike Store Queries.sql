--Bike Store Analysis
--1. Sales and Orders Analysis
--Total Revenue and Quantity Sold:

SELECT Round(Sum(list_price * ( 1 - discount ) * quantity), 2) AS Total_revenue,
       Sum(quantity)AS Quantity_sold
FROM    [sales].[order_items]


--2.Total Revenue and Quantity Sold Per Year:

SELECT Datename(year, order_date) AS Year,
    Round(Sum(list_price * ( 1 - discount ) * quantity), 2) AS Total_revenue,
       Sum(quantity) AS Quantity
FROM  [sales].[order_items] oi
       JOIN [sales].[orders] o
         ON oi.order_id = o.order_id
GROUP  BY Datename(year, order_date)
ORDER  BY Datename(year, order_date) ASC 

--3.Total Monthly Revenue Aggregated Over a Three-Year Period:

SELECT datename(month,o.order_date) AS Month,
       Round(Sum(list_price * ( 1 - discount ) * quantity), 2) AS Total_revenue
FROM   [sales].[order_items] ot
       JOIN [sales].[orders] o
         ON ot.order_id = o.order_id
GROUP  BY datename(month,o.order_date)
order by Total_revenue desc


--2. Customer Analysis
--Top 10 Customers by Total Order Value:

SELECT TOP 10 c.customer_id,
       CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.state AS State,
    SUM(Quantity) as Order_count,
       SUM(oi.list_price * oi.quantity * (1 - oi.discount)) AS total_order_value
FROM [sales].[customers] c
JOIN [sales].[orders] o ON c.customer_id = o.customer_id
JOIN [sales].[order_items] oi ON o.order_id = oi.order_id
GROUP BY c.customer_id, CONCAT(c.first_name, ' ', c.last_name), State
ORDER BY total_order_value DESC


--Customer Distribution and Total Sales by State:

SELECT COUNT(distinct c.customer_id) AS Customer_count,
    s.state,
       ROUND(SUM(oi.list_price * oi.quantity * (1 - oi.discount)),2) AS total_sales
FROM [sales].[orders] o
JOIN  [sales].[customers]c ON o.customer_id = c.customer_id
JOIN [sales].[order_items] oi ON o.order_id = oi.order_id
JOIN [sales].[stores] s ON o.store_id = s.store_id
GROUP BY s.state
ORDER BY total_sales DESC;


--3. Product Analysis
--Top 10 Products by Total Sales:

SELECT TOP 10
    p.product_id,
    p.product_name,
    SUM(oi.quantity) AS total_quantity_sold,
    SUM(oi.list_price * oi.quantity * (1 - oi.discount)) AS total_sales
FROM 
   [sales].[order_items]  oi
JOIN 
   [production].[products]  p ON oi.product_id = p.product_id
GROUP BY 
    p.product_id, p.product_name
ORDER BY 
    total_sales DESC;

--10 Least Profitable Products:

SELECT TOP 10
    p.product_id,
    p.product_name,
    SUM(oi.quantity) AS total_quantity_sold,
    SUM(oi.list_price * oi.quantity * (1 - oi.discount)) AS total_sales
FROM 
   [sales].[order_items]  oi
JOIN 
   [production].[products]  p ON oi.product_id = p.product_id
GROUP BY 
    p.product_id, p.product_name
ORDER BY 
    total_sales ASC;


--4. Brands
--Total Sales and Average Sales Price by Brand:

SELECT 
    b.brand_name,
    ROUND(SUM(oi.list_price * oi.quantity * (1 - oi.discount)), 2) AS total_sales,
 ROUND(AVG(oi.list_price * (1 - oi.discount)), 2) AS avg_sales_price
FROM 
   [production].[brands]  b
JOIN 
  [production].[products]  p ON b.brand_id = p.brand_id
JOIN 
  [sales].[order_items]  oi ON p.product_id = oi.product_id
GROUP BY 
    b.brand_name
ORDER BY 
    total_sales DESC

--5. Categories
--Total Sales and Average Sales Price by Product Category:

SELECT 
    c.category_name,
   Round(SUM(oi.list_price * oi.quantity * (1 - oi.discount)),2) AS total_sales,
   ROUND(AVG(oi.list_price * (1 - oi.discount)),2) AS avg_sales_price
FROM 
   [production].[categories]  c
JOIN 
  [production].[products]  p ON c.category_id = p.category_id
JOIN 
   [sales].[order_items]  oi ON p.product_id = oi.product_id
GROUP BY 
    c.category_name
ORDER BY 
    total_sales DESC


--6. Store Analysis
--Total Sales by Store:

SELECT S.store_id,
       S.store_name,
       s.city,
       s.state,
       Round(Sum(oi.list_price * oi.quantity * ( 1 - oi.discount )), 2) AS
       total_sales
FROM  [sales].[order_items]  oi
       JOIN [sales].[orders] o
         ON oi.order_id = o.order_id
       JOIN[sales].[stores]  s
         ON o.store_id = s.store_id
GROUP  BY S.store_id,
          S.store_name,
          s.city,
          s.state
ORDER  BY total_sales DESC


--Most Selling Product For Each Store:

WITH RankedProducts AS (
    SELECT 
        s.store_id, 
        s.store_name, 
        p.product_name, 
        SUM(oi.quantity) AS units_sold, 
        RANK() OVER (PARTITION BY s.store_id ORDER BY SUM(oi.quantity) DESC) AS rank
    FROM 
      [sales].[orders]  o
    JOIN 
       [sales].[order_items]  oi ON o.order_id = oi.order_id
    JOIN 
        [sales].[stores] s ON o.store_id = s.store_id
    JOIN 
       [production].[products]  p ON oi.product_id = p.product_id 
    GROUP BY 
        s.store_id, 
        s.store_name, 
        p.product_name
)
SELECT 
    store_id,
    store_name,
    product_name,
    units_sold
FROM 
    RankedProducts
WHERE 
    rank = 1;


--7. Staffs
--Total Number of Staff per Store:

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

--Top Performing Staff Members by Total Sales and Units Sold:

 SELECT TOP 10
    CONCAT(first_name, ' ', last_name) AS staff_name,
    ROUND(SUM(oi.list_price * oi.quantity * (1 - oi.discount)),2) AS total_sales,
    SUM(quantity) AS units_sold
FROM 
   [sales].[staffs]  s
JOIN 
   [sales].[orders]  o ON s.staff_id = o.staff_id
JOIN 
    [sales].[order_items] oi ON o.order_id = oi.order_id
GROUP BY 
    s.staff_id, s.first_name, s.last_name
ORDER BY 
    total_sales DESC
