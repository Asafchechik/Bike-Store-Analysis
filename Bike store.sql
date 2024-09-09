SELECT 
	order_id,
	SUM(quantity * list_price) AS revenue
FROM sales.order_items
GROUP BY order_id

SELECT 
	ord.order_id,
	CONCAT(cus.first_name, ' ', cus.last_name) AS full_name,
	cus.city,
	cus.state,
	ord.order_date,
	pro.product_name,
	cat.category_name,
	sto.store_name,
	CONCAT(sta.first_name, ' ', sta.last_name) AS sales_representative,
	SUM(itm.quantity) AS total_quantity,
	SUM(itm.quantity * itm.list_price) AS revenue
FROM sales.orders ord
INNER JOIN sales.customers cus
ON ord.customer_id = cus.customer_id
INNER JOIN sales.order_items itm
ON itm.order_id = ord.order_id
INNER JOIN production.products pro
ON pro.product_id = itm.product_id
INNER JOIN production.categories cat
ON cat.category_id = pro.category_id
INNER JOIN sales.stores sto
ON sto.store_id = ord.store_id
INNER JOIN sales.staffs sta
ON sta.staff_id = ord.staff_id
GROUP BY
	ord.order_id,
	CONCAT(cus.first_name, ' ', cus.last_name),
	cus.city,
	cus.state,
	ord.order_date,
	pro.product_name,
	cat.category_name,
	sto.store_name,
	CONCAT(sta.first_name, ' ', sta.last_name)