-- queries to be used on db
SELECT * FROM staging_superstore;

-- check for non null values
SELECT
    COUNT(*) AS total_rows,
    COUNT(category) AS non_null_category,
    COUNT(city) AS non_null_city,
    COUNT(country) AS non_null_country,
    COUNT(customer_id) AS non_null_customer_id,
    COUNT(customer_name) AS non_null_customer_name,
    COUNT(discount) AS non_null_discount,
    COUNT(market) AS non_null_market,
    COUNT(ji_lu_shu) AS non_null_ji_lu_shu,
    COUNT(order_date) AS non_null_order_date,
    COUNT(order_id) AS non_null_order_id,
    COUNT(order_priority) AS non_null_order_priority,
    COUNT(product_id) AS non_null_product_id,
    COUNT(product_name) AS non_null_product_name,
    COUNT(profit) AS non_null_profit,
    COUNT(quantity) AS non_null_quantity,
    COUNT(region) AS non_null_region,
    COUNT(sales) AS non_null_sales,
    COUNT(segment) AS non_null_segment,
    COUNT(ship_date) AS non_null_ship_date,
    COUNT(ship_mode) AS non_null_ship_mode,
    COUNT(shipping_cost) AS non_null_shipping_cost,
    COUNT(state) AS non_null_state,
    COUNT(sub_category) AS non_null_sub_category,
    COUNT(year) AS non_null_year,
    COUNT(market2) AS non_null_market2,
    COUNT(weeknum) AS non_null_weeknum
FROM staging_superstore;


-- check for distinct values
SELECT
    COUNT(DISTINCT category) AS distinct_category,
    COUNT(DISTINCT city) AS distinct_city,
    COUNT(DISTINCT country) AS distinct_country,
    COUNT(DISTINCT customer_id) AS distinct_customer_id,
    COUNT(DISTINCT customer_name) AS distinct_customer_name,
    COUNT(DISTINCT discount) AS distinct_discount,
    COUNT(DISTINCT market) AS distinct_market,
    COUNT(DISTINCT ji_lu_shu) AS distinct_ji_lu_shu,
    COUNT(DISTINCT order_date) AS distinct_order_date,
    COUNT(DISTINCT order_id) AS distinct_order_id,
    COUNT(DISTINCT order_priority) AS distinct_order_priority,
    COUNT(DISTINCT product_id) AS distinct_product_id,
    COUNT(DISTINCT product_name) AS distinct_product_name,
    COUNT(DISTINCT profit) AS distinct_profit,
    COUNT(DISTINCT quantity) AS distinct_quantity,
    COUNT(DISTINCT region) AS distinct_region,
    COUNT(DISTINCT sales) AS distinct_sales,
    COUNT(DISTINCT segment) AS distinct_segment,
    COUNT(DISTINCT ship_date) AS distinct_ship_date,
    COUNT(DISTINCT ship_mode) AS distinct_ship_mode,
    COUNT(DISTINCT shipping_cost) AS distinct_shipping_cost,
    COUNT(DISTINCT state) AS distinct_state,
    COUNT(DISTINCT sub_category) AS distinct_sub_category,
    COUNT(DISTINCT year) AS distinct_year,
    COUNT(DISTINCT market2) AS distinct_market2,
    COUNT(DISTINCT weeknum) AS distinct_weeknum
FROM staging_superstore;


-- as 'ji_lu_shu' comes back as 1 for each record, we can assume it redundant for our database
-- we will also drop 'market' col, as 'market2' suffices and is more uniformed than market and rename market2 to an appropriate indentifier
-- as each customer_id has many id's per customer, we shall delete the customer_id column and create our own upon table creation of customer table

ALTER TABLE staging_superstore DROP COLUMN ji_lu_shu;
ALTER TABLE staging_superstore DROP COLUMN market;
ALTER TABLE staging_superstore RENAME COLUMN market2 to geo_market;
ALTER TABLE staging_superstore DROP COLUMN customer_id;


-- ensuring integrity by checking all ship_date records come after order_date
SELECT *
FROM staging_superstore
WHERE ship_date < order_date;

-- after performing the below query we can see that the loction attributes associated with the customer 
-- shows the customer has multiple address, for these reasons we shall assume these locations are shipping locations for the customer
SELECT customer_name, country, state, region, city, geo_market, category
FROM staging_superstore 
WHERE LOWER(customer_name) LIKE LOWER('ALEX AVILA');


-- *** return to schema query ***


-- CONTINUIN WITH DATA DISCOVERY
-- NOTE the questions will become harder as you progress. Answers will be available through the QnA page though try your best.
-- NOTE it may be handy to have the ER Diagram available to remember attributes and table relationships.

-- Q1: How many customers are there in the global_superstore_database?
SELECT COUNT(DISTINCT customer_id) AS total_customers
FROM customers;

-- Q2: How many products are there in the global_superstore_database?
SELECT COUNT(DISTINCT product_id) AS total_products
FROM products;

-- Q3: What are the market regions that the global superstore operates in (geo_market)?
SELECT DISTINCT geo_market
FROM shipping_addresses;

-- Q4: What are the customer segments that identify the global superstore consumer demographics?
SELECT DISTINCT segment
FROM customers;

-- Q5: Which segment has the most customers in? Order By segment descending?
SELECT segment, 
		count(*) AS consumer_type_count
FROM customers
GROUP BY segment
ORDER BY consumer_type_count DESC; 

-- Q6: How many countries does the global superstore distribute too?
SELECT COUNT(DISTINCT country)
FROM shipping_addresses;
	

-- Q7: What are the category types and how many sub-categories are in each category?
SELECT DISTINCT category, 
		COUNT(sub_category) AS sub_category_count
FROM products
GROUP BY category;

-- Q8: What is the most popular shipping distribution option? Order by the count desc
SELECT DISTINCT ship_mode, 
		COUNT(*) AS distribution_methods
FROM order_details
GROUP BY ship_mode
ORDER BY distribution_methods DESC;

-- Q9: What was the earliest and latest order_date? 
SELECT MIN(order_date) AS earliest_order,
	MAX(order_date) AS latest_order
FROM order_details;

-- Q10: What is the % profit of overall sales for the company? Round it to 2 decimal places.
SELECT SUM(sales) AS total_sales, 
		SUM(profit) AS total_profit,
		ROUND((SUM(profit) / SUM(sales + profit)),2) * 100 AS pct_profit	
FROM order_details

-- Q11: Which year has the most sales
SELECT DISTINCT EXTRACT(YEAR FROM order_date) AS order_year, 
	SUM(sales)
	FROM order_details
	GROUP BY order_year
	ORDER BY order_year DESC;

-- Q12: What is the median price of a sale per month in the year of 2012?
-- list the months, total quantity of sales and the median cost of the montly sales.
-- HINT - use percentile_cont function
SELECT EXTRACT(MONTH FROM order_date) AS order_month,
    COUNT(sales) AS total_qty_sales,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY sales) AS "median_cost"
FROM order_details
WHERE EXTRACT(YEAR FROM order_date) = 2012
GROUP BY EXTRACT(MONTH FROM order_date)
ORDER BY order_month;

-- Q13: Find the mode product_name, this will require the first join of these questions (HINT: look at ER diagram for table relations)
SELECT p.product_name,
    COUNT(od.product_id) AS count
FROM order_details od
JOIN products p ON od.product_id = p.product_id
GROUP BY p.product_name
ORDER BY count DESC
LIMIT 1;

-- Q14: Which customer segment is most popular in the United States and what product sells the most?
-- return the products.product_name, customer.segment and (optional) shipping_addresses_country, LIMIT to 5.
SELECT p.product_name, c.segment, sa.state, COUNT(*) AS total_sales
	FROM products AS p 
		JOIN order_details AS od ON p.product_id = od.product_id
		JOIN orders AS o ON od.order_id = o.order_id
		JOIN customers AS c ON o.customer_id = c.customer_id
		JOIN shipping_addresses AS sa ON c.customer_id = sa.customer_id
WHERE country = 'United States'
GROUP BY p.product_name, c.segment, sa.state
ORDER BY
	total_sales DESC
LIMIT 5;

-- Q15: What is the total profit per customer segment in each state in the United States? Limit 10
SELECT c.segment,
    sa.state,
    ROUND(SUM(od.profit), 2) AS total_profit
	FROM customers AS c
		JOIN orders AS o ON c.customer_id = o.customer_id
		JOIN order_details AS od ON o.order_id = od.order_id
		JOIN shipping_addresses AS sa ON c.customer_id = sa.customer_id
WHERE country = 'United States'
GROUP BY c.segment, sa.state
ORDER BY total_profit DESC
LIMIT 10;
		

-- Q16: List the countries in geo_market Europe ('EU') by total sales descending
SELECT DISTINCT sa.country, 
		SUM(od.sales) AS Total_Sales
FROM shipping_addresses AS sa
	JOIN orders AS o ON sa.order_id = o.order_id
	JOIN order_details AS od ON od.order_id = o.order_id
WHERE geo_market = 'EU'
	GROUP BY sa.country
	ORDER BY total_sales DESC;

-- Q17: Which customer has the highest sale ammount. Include sales, customer, and product name
SELECT od.sales AS sale_amount,
    p.product_name,
    c.customer_name
FROM order_details AS od
	JOIN orders AS o ON od.order_id = o.order_id
	JOIN customers AS c ON o.customer_id = c.customer_id
	JOIN products AS p ON od.product_id = p.product_id
ORDER BY 
    sale_amount DESC
LIMIT 1;


-- Q18: Which year had the most sales for the global superstore, List in DESC order.
SELECT EXTRACT(YEAR FROM order_date) AS year,
    SUM(sales) AS total_sales
FROM order_details
GROUP BY year
ORDER BY total_sales DESC;

-- Q19: What was the most popular product from the APAC region?
SELECT od.product_id, 
    p.product_name, 
    SUM(od.quantity) AS total_quantity
FROM order_details AS od
JOIN orders AS o ON od.order_id = o.order_id
JOIN shipping_addresses AS sa ON o.order_id = sa.order_id
JOIN products AS p ON od.product_id = p.product_id
WHERE sa.geo_market = 'APAC'
GROUP BY od.product_id, p.product_name
ORDER BY total_quantity DESC
LIMIT 1;

-- Q20: Which product has sold the most in each geo_market?
WITH ranked_products AS (
	    SELECT
	        sa.geo_market,
	        od.product_id,
	        p.product_name,
	        SUM(od.quantity) AS total_quantity,
	        ROW_NUMBER() OVER (PARTITION BY sa.geo_market ORDER BY SUM(od.quantity) DESC) AS row_num
	    FROM order_details AS od
	    JOIN orders AS o ON od.order_id = o.order_id
	    JOIN shipping_addresses AS sa ON o.order_id = sa.order_id
	    JOIN products AS p ON od.product_id = p.product_id
	    GROUP BY sa.geo_market, od.product_id, p.product_name
	)
SELECT geo_market,
    product_id,
    product_name,
    total_quantity
FROM ranked_products
WHERE row_num = 1
ORDER BY total_quantity DESC;


-- Q21: What is the % increase in total sales year on year?
WITH yearly_revenue AS (
    SELECT 
        EXTRACT(YEAR FROM order_date) AS year,
        SUM(sales) AS revenue
    FROM order_details
    GROUP BY EXTRACT(YEAR FROM order_date)
    ORDER BY year
)
SELECT year,
    revenue,
    LAG(revenue) OVER (ORDER BY year) AS Revenue_Previous_Year,
    revenue - LAG(revenue) OVER (ORDER BY year) AS YOY_Difference,
    ROUND(((revenue - LAG(revenue) OVER (ORDER BY year)) / LAG(revenue) OVER (ORDER BY year)),2) * 100 AS YOY_Percentage_Change
FROM yearly_revenue;

-- Q22: What is the average sales per order by region?
SELECT sa.geo_market AS region,
    	ROUND(AVG(od.sales),2) AS avg_sales_per_order
FROM order_details od
JOIN orders o ON od.order_id = o.order_id
JOIN shipping_addresses sa ON o.order_id = sa.order_id
GROUP BY sa.geo_market
ORDER BY avg_sales_per_order DESC;

-- Q23: What is the total quantity sold per product category?
SELECT p.category,
    SUM(od.quantity) AS total_quantity_sold
FROM order_details od
JOIN products p ON od.product_id = p.product_id
GROUP BY p.category
ORDER BY total_quantity_sold DESC;


-- Q24: What is the highest performing quarter of each year?
WITH quarterly_profits AS (
    SELECT 
        EXTRACT(YEAR FROM order_date) AS year,
        EXTRACT(QUARTER FROM order_date) AS quarter,
        ROUND(SUM(od.profit), 2) AS total_profit
    FROM order_details od
    JOIN orders AS o ON od.order_id = o.order_id
    GROUP BY year, quarter
),
ranked_quarterly_profits AS (
    SELECT 
        year,
        quarter,
        total_profit,
        RANK() OVER (PARTITION BY year ORDER BY total_profit DESC) AS profit_rank
    FROM 
        quarterly_profits
)
SELECT year,
    quarter,
    total_profit
FROM ranked_quarterly_profits
WHERE profit_rank = 1
ORDER BY year;


-- Q25: What is the highest performing quarter of each year? This time assign the year number a name such as Q1 (Winter). HINT - use case expression.
WITH quarterly_profits AS (
    SELECT 
        EXTRACT(YEAR FROM order_date) AS year,
        EXTRACT(QUARTER FROM order_date) AS quarter,
        ROUND(SUM(od.profit), 2) AS total_profit
    FROM order_details AS od
    JOIN orders AS o ON od.order_id = o.order_id
    GROUP BY year, quarter
),
ranked_quarterly_profits AS (
    SELECT year,
        quarter,
        total_profit,
        RANK() OVER (PARTITION BY year ORDER BY total_profit DESC) AS profit_rank
    FROM quarterly_profits
)
SELECT year,
    CASE 
        WHEN quarter = 1 THEN 'Q1 (Winter)'
        WHEN quarter = 2 THEN 'Q2 (Spring)'
        WHEN quarter = 3 THEN 'Q3 (Summer)'
        WHEN quarter = 4 THEN 'Q4 (Autumn)'
    END AS quarter_name,
    		total_profit
FROM ranked_quarterly_profits
WHERE profit_rank = 1
ORDER BY year;

-- Q26: What is the average discount per customer segment for each product category?
SELECT c.segment,
    p.category,
    ROUND(AVG(od.discount), 2) AS avg_discount
FROM customers AS c JOIN orders AS o ON c.customer_id = o.customer_id
JOIN order_details AS od ON o.order_id = od.order_id
JOIN products AS p ON od.product_id = p.product_id
GROUP BY c.segment, p.category
ORDER BY c.segment, p.category;

-- Q27: What is the highest performing products year on year by sales?
WITH yearly_product_sales AS (
    SELECT EXTRACT(YEAR FROM order_date) AS year,
		p.product_name,	
        SUM(od.sales) AS total_sales
    FROM order_details od
    JOIN products p ON od.product_id = p.product_id
    JOIN orders o ON od.order_id = o.order_id
    GROUP BY year, p.product_name
),
ranked_product_sales AS (
    SELECT year,
		product_name,
        total_sales,
        RANK() OVER (PARTITION BY year ORDER BY total_sales DESC) AS sales_rank
    FROM yearly_product_sales
)
SELECT year,
    product_name,
	total_sales
FROM ranked_product_sales
WHERE sales_rank = 1
ORDER BY year;
