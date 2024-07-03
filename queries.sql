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


-- Q2: How many products are there in the global_superstore_database?


-- Q3: What are the market regions that the global superstore operates in (geo_market)?


-- Q4: What are the customer segments that identify the global superstore consumer demographics?


-- Q5: Which segment has the most customers in? Order By segment descending?


-- Q6: How many countries does the global superstore distribute too?
	

-- Q7: What are the category types and how many sub-categories are in each category?


-- Q8: What is the most popular shipping distribution option? Order by the count desc


-- Q9: What was the earliest and latest order_date? 


-- Q10: What is the % profit of overall sales for the company? Round it to 2 decimal places.


-- Q11: Which year has the most sales


-- Q12: What is the median price of a sale per month in the year of 2012?
-- list the months, total quantity of sales and the median cost of the montly sales.
-- HINT - use percentile_cont function


-- Q13: Find the mode product_name, this will require the first join of these questions (HINT: look at ER diagram for table relations)
;

-- Q14: Which customer segment is most popular in the United States and what product sells the most?
-- return the products.product_name, customer.segment and (optional) shipping_addresses_country, LIMIT to 5.


-- Q15: What is the total profit per customer segment in each state in the United States? Limit 10
		

-- Q16: List the countries in geo_market Europe ('EU') by total sales descending


-- Q17: Which customer has the highest sale ammount. Include sales, customer, and product name


-- Q18: Which year had the most sales for the global superstore, List in DESC order.


-- Q19: What was the most popular product from the APAC region?


-- Q20: Which product has sold the most in each geo_market?


-- Q21: What is the % increase in total sales year on year?


-- Q22: What is the average sales per order by region?


-- Q23: What is the total quantity sold per product category?


-- Q24: What is the highest performing quarter of each year?


-- Q25: What is the highest performing quarter of each year? This time assign the year number a name such as Q1 (Winter). HINT - use case expression.


-- Q26: What is the average discount per customer segment for each product category?


-- Q27: What is the highest performing products year on year by sales?

