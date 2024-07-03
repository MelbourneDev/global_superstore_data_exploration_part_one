-- Database Schema for Global Superstore

-- create database Global_Superstore_db

CREATE DATABASE global_superstore_db;

-- create staging table which will hold all initial data.
CREATE TABLE staging_superstore (
    category TEXT,
    city TEXT,
    country TEXT,
    customer_id TEXT,
    customer_name TEXT,
    discount NUMERIC,
    market TEXT,
    ji_lu_shu TEXT,
    order_date DATE,
    order_id TEXT,
    order_priority TEXT,
    product_id TEXT,
    product_name TEXT,
    profit NUMERIC,
    quantity INTEGER,
    region TEXT,
    row_id INTEGER,
    sales NUMERIC,
    segment TEXT,
    ship_date DATE,
    ship_mode TEXT,
    shipping_cost NUMERIC,
    state TEXT,
    sub_category TEXT,
    year INTEGER,
    market2 TEXT,
    weeknum INTEGER
);

-- copy data from csv to staging_superstore table
COPY staging_superstore (
    category,
    city,
    country,
    customer_id,
    customer_name,
    discount,
    market,
    ji_lu_shu,
    order_date,
    order_id,
    order_priority,
    product_id,
    product_name,
    profit,
    quantity,
    region,
    row_id,
    sales,
    segment,
    ship_date,
    ship_mode,
    shipping_cost,
    state,
    sub_category,
    year,
    market2,
    weeknum
)
FROM 'C:/Users/matth/Desktop/PostgreSQL Project - Global Superstore Dataset/superstore.csv'
DELIMITER ','
CSV HEADER;
-- *** please refer to queries script before continuing with the schema script ***
------------------------------------------------------------------------------------------------------------------
-- *** continue with query page ***


-- *** continuing with exporting data from staging table to tables as per ER diagram (see diagram in files...) ***
-- create customer table with no foreign key attributes
CREATE TABLE customers (
	customer_id TEXT PRIMARY KEY,
	customer_name TEXT,
	segment TEXT
);

-- create a sequence that allows us to use same convention as dummy dataset (customer initials followed by numerical code)
-- the sequence handles the numerical factor of the id and the function generates the ID based on the customer's initials
CREATE SEQUENCE customer_id_seq
    START WITH 100000
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
-- create function that assigns customer_name first n second initial as customer_id variation 
CREATE FUNCTION generate_customer_id(customer_name TEXT)
RETURNS TEXT AS $$
DECLARE
    initials TEXT;
    seq_num TEXT;
BEGIN
    -- Extract initials (first letter of first name and first letter of last name)
    initials := LEFT(customer_name, 1) || LEFT(SPLIT_PART(customer_name, ' ', 2), 1);
    
    -- Get the next value from the sequence
    seq_num := LPAD(nextval('customer_id_seq')::TEXT, 6, '0');
    
    -- Return the combined customer ID
    RETURN initials || '-' || seq_num;
END;
$$ LANGUAGE plpgsql;


-- insert customer data from staging table
INSERT INTO customers (customer_id, customer_name, segment)
SELECT generate_customer_id(customer_name), customer_name, segment
FROM (
    SELECT DISTINCT customer_name, segment
    FROM staging_superstore
) AS unique_customers;

-- NOTE, 'generate_customer_id' will use a user's middle name as second initial as shown in the query below
SELECT customer_id, customer_name
FROM customers
WHERE array_length(string_to_array(customer_name, ' '), 1) > 2;


SELECT * FROM customers;

-- create order table with fk attr to customer_id
CREATE TABLE orders(
	order_id TEXT PRIMARY KEY,
	customer_id TEXT REFERENCES customers(customer_id)	
);

-- select the order_id from staging and to ensure there are no duplicates customer_id's 
-- we use the MIN function to negate multiple entries of customer_id 
-- as an order_id may have multiple of the same customer_id
INSERT INTO orders (order_id, customer_id)
SELECT order_id, MIN(c.customer_id)
FROM staging_superstore s
JOIN customers c ON s.customer_name = c.customer_name AND s.segment = c.segment
GROUP BY order_id;

SELECT * FROM ORDERS;

-- create products table with no foreign keys
CREATE TABLE products (
	product_id text PRIMARY KEY,
	product_name text,
	category text,
	sub_category text	
);

INSERT INTO products (product_id, product_name, category, sub_category)
SELECT DISTINCT ON (product_id) product_id, product_name, category, sub_category
FROM staging_superstore;

SELECT * FROM products;

-- create order_details table which stores order related attr
-- FK's to the orders table and products table
CREATE TABLE order_details (
    order_detail_id SERIAL PRIMARY KEY,
    order_id TEXT REFERENCES orders(order_id),
    product_id TEXT REFERENCES products(product_id),
    order_date DATE,
    ship_date DATE,
    ship_mode TEXT,
    shipping_cost NUMERIC,
    discount NUMERIC,
    order_priority TEXT,
    quantity INTEGER,
    profit NUMERIC,
    sales NUMERIC
);


INSERT INTO order_details (order_id, product_id, order_date, ship_date, ship_mode, shipping_cost, discount, order_priority, quantity, profit, sales)
SELECT order_id, product_id, order_date, ship_date, ship_mode, shipping_cost, discount, order_priority, quantity, profit, sales
FROM staging_superstore;

SELECT * FROM order_details;

-- create shipping_address table with FK's to customers and orders table
CREATE TABLE shipping_addresses (
    shipping_id SERIAL PRIMARY KEY,
	customer_id TEXT REFERENCES customers(customer_id),
    order_id TEXT REFERENCES orders(order_id),	
    geo_market TEXT,
    country TEXT,
    state TEXT,
    region TEXT,
    city TEXT
);

-- select the following attributes from the staging table with distint combinations 
-- of thhe SELECT DISTINCT clause to ensure no duplicate entries
INSERT INTO shipping_addresses (customer_id, order_id, geo_market, country, state, region, city)
SELECT DISTINCT c.customer_id, s.order_id, s.geo_market, s.country, s.state, s.region, s.city
FROM staging_superstore s
JOIN customers c ON s.customer_name = c.customer_name AND s.segment = c.segment;

SELECT * FROM shipping_addresses;

-- Now that all of our tables have been made and the global_superstore_db has become
-- a relational database we can drop the staging table from our db.ABORT

DROP TABLE staging_superstore;

-- RETURN TO QUERIES FOR DISCOVERY QUESTIONS





