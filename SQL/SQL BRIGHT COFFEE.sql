-- Databricks notebook source
-- DBTITLE 1,BRIGHT COFFEE SQL
---DATA INSPECTION
select * 
from `brightlearn`.`default`.`bright_coffee_shop_analysis` limit 100;

---CHECK SCHEMA
DESCRIBE `brightlearn`.`default`.`bright_coffee_shop_analysis`;

---CHECK FOR NULL VALUES

SELECT *
FROM `brightlearn`.`default`.`bright_coffee_shop_analysis`
WHERE transaction_date IS NULL
   OR transaction_time IS NULL
   OR transaction_qty IS NULL
   OR unit_price IS NULL
   OR product_category IS NULL
   OR product_detail IS NULL;

---CHECK FOR DUPLIICATE TRANSACTIONS

SELECT transaction_id,
       COUNT(*) AS duplicate_count
FROM `brightlearn`.`default`.`bright_coffee_shop_analysis`
GROUP BY transaction_id
HAVING COUNT(*) > 1;

---TRIM() REMOVE SPACE BEFORE AND AFTER TEXT 

SELECT
transaction_id,
TRIM(product_category) AS product_category,
TRIM(product_type) AS product_type,
TRIM(product_detail) AS product_detail
FROM `brightlearn`.`default`.`bright_coffee_shop_analysis`;

---STANDARDIZE CAPITALIZATION

SELECT
INITCAP(TRIM(product_category)) AS product_category,
INITCAP(TRIM(product_type)) AS product_type,
INITCAP(TRIM(product_detail)) AS product_detail
FROM `brightlearn`.`default`.`bright_coffee_shop_analysis`;

---TIME LINE OF DATA

SELECT
    MIN(transaction_date) AS start_date,
    MAX(transaction_date) AS end_date,
    COUNT(DISTINCT DATE_FORMAT(transaction_date, 'yyyy-MM')) AS number_of_months
FROM brightlearn.default.bright_coffee_shop_analysis;

---EARLIEST AND LATEST TRANSATION TIME

SELECT
MIN(transaction_time) AS earliest_transaction,
MAX(transaction_time) AS Latest_transaction
FROM `brightlearn`.`default`.`bright_coffee_shop_analysis`;


---ETRACTION OF DATE PARTS 

SELECT *,
YEAR(transaction_date) AS sales_year,
MONTH(transaction_date) AS sales_month,
DAY(transaction_date) AS sales_day,
DAYNAME(transaction_date) AS day_name,
QUARTER(transaction_date) AS sales_quarter
FROM `brightlearn`.`default`.`bright_coffee_shop_analysis`;

---DISTINCT STORE LOCATION

SELECT DISTINCT store_location
FROM brightlearn.default.bright_coffee_shop_analysis
ORDER BY store_location;

---REVENUE BY STORE LOCATION FOR EACH MONTH
SELECT
    DATE_FORMAT(transaction_date, 'yyyy-MM') AS sales_month,
    store_location,
    SUM(transaction_qty * unit_price) AS total_revenue
FROM brightlearn.default.bright_coffee_shop_analysis
GROUP BY
    DATE_FORMAT(transaction_date, 'yyyy-MM'),
    store_location
ORDER BY
    sales_month,
    total_revenue DESC;

   ---COUNT DISTINCT PRODUCT_CATEGORY AND PRODUCT_DETAIL

   SELECT
    COUNT(DISTINCT product_category) AS total_categories,
    COUNT(DISTINCT product_detail) AS total_products
FROM brightlearn.default.bright_coffee_shop_analysis;

---REVENUE BY PRODUCT CATEGORY-LIMIT 10

SELECT
    product_category,
    SUM(transaction_qty * unit_price) AS total_revenue
FROM brightlearn.default.bright_coffee_shop_analysis
GROUP BY product_category
ORDER BY total_revenue DESC
LIMIT 10;


---TOP 10 SELLING PRODUCTS ACROSS ALL STORES (product_detail)
SELECT
    product_detail,
    SUM(transaction_qty) AS units_sold,
    SUM(transaction_qty * unit_price) AS total_revenue
FROM brightlearn.default.bright_coffee_shop_analysis
GROUP BY product_detail
ORDER BY total_revenue DESC
LIMIT 10;


---TOP 10 SELLING PRODUCTS ACROSS ALL STORES (product_type)
SELECT
   product_type,
    SUM(transaction_qty) AS units_sold,
    SUM(transaction_qty * unit_price) AS total_revenue
FROM brightlearn.default.bright_coffee_shop_analysis
GROUP BY product_type
ORDER BY total_revenue DESC
LIMIT 10;

---DISTINCT PRICING (CHEAPEST TO MOST EXENSIVE PRICING)

SELECT DISTINCT unit_price
FROM `brightlearn`.`default`.`bright_coffee_shop_analysis`
ORDER BY unit_price;

---TOTAL AMOUNT FOR EACH DISTINCT TRANSACTION (Quantity acounted for)

SELECT *,
(transaction_qty * unit_price) AS total_amount
FROM `brightlearn`.`default`.`bright_coffee_shop_analysis`;

---TOTAL REVENUE ACROSS ALL LOCATIONS

SELECT
    SUM(transaction_qty * unit_price) AS total_revenue
FROM brightlearn.default.bright_coffee_shop_analysis;


---TIME BUCKET (3HOUR INTERVALS)
SELECT *,
CASE 
   WHEN HOUR(transaction_time) BETWEEN 6 AND 8 THEN 'EARLY MORNING'
   WHEN HOUR(transaction_time) BETWEEN 9 AND 11 THEN 'MORNING'
   WHEN HOUR(transaction_time) BETWEEN 12 AND 14 THEN 'MIDDAY'
   WHEN HOUR(transaction_time) BETWEEN 15 AND 17 THEN 'AFTERNOON'
   WHEN HOUR(transaction_time) BETWEEN 18 AND 20 THEN 'EVENING'
   ELSE 'Other'
END AS time_bucket
FROM `brightlearn`.`default`.`bright_coffee_shop_analysis`;

---CALCULATING REVENUE BY TIME_BUCKETS


SELECT
CASE
   WHEN HOUR(transaction_time) BETWEEN 6 AND 8 THEN 'EARLY MORNING'
   WHEN HOUR(transaction_time) BETWEEN 9 AND 11 THEN 'MORNING'
   WHEN HOUR(transaction_time) BETWEEN 12 AND 14 THEN 'MIDDAY'
   WHEN HOUR(transaction_time) BETWEEN 15 AND 17 THEN 'AFTERNOON'
   WHEN HOUR(transaction_time) BETWEEN 18 AND 20 THEN 'EVENING'
   ELSE 'OTHER'
END AS time_bucket, 
SUM(transaction_qty*unit_price) AS `TOTAL REVENUE`
FROM `brightlearn`.`default`.`bright_coffee_shop_analysis`
GROUP BY
CASE
    WHEN HOUR(transaction_time) BETWEEN 6 AND 8 THEN 'EARLY MORNING'
    WHEN HOUR(transaction_time) BETWEEN 9 AND 11 THEN 'MORNING'
    WHEN HOUR(transaction_time) BETWEEN 12 AND 14 THEN 'MIDDAY'
    WHEN HOUR(transaction_time) BETWEEN 15 AND 17 THEN 'AFTERNOON'
    WHEN HOUR(transaction_time) BETWEEN 18 AND 20 THEN 'EVENING'
    ELSE 'OTHER'
END

ORDER BY `TOTAL REVENUE` DESC;


---FINAL TABLE 

CREATE OR REPLACE TABLE brightlearn.default.coffee_shop_aggregated AS

SELECT
    transaction_id,
    transaction_date,
    transaction_time,

    YEAR(transaction_date) AS sales_year,
    MONTH(transaction_date) AS sales_month,
    MONTHNAME(transaction_date) AS month_name,
    DAY(transaction_date) AS sales_day,
    DAYNAME(transaction_date) AS day_name,

    store_id,
    store_location,

    product_id,
    INITCAP(TRIM(product_category)) AS product_category,
    INITCAP(TRIM(product_type)) AS product_type,
    INITCAP(TRIM(product_detail)) AS product_detail,


    transaction_qty,
    CAST(unit_price AS DECIMAL(10,2)) AS unit_price,

    (transaction_qty * unit_price) AS total_revenue,

    CASE
        WHEN HOUR(transaction_time) BETWEEN 6 AND 8 THEN 'EARLY MORNING'
        WHEN HOUR(transaction_time) BETWEEN 9 AND 11 THEN 'MORNING'
        WHEN HOUR(transaction_time) BETWEEN 12 AND 14 THEN 'MIDDAY'
        WHEN HOUR(transaction_time) BETWEEN 15 AND 17 THEN 'AFTERNOON'
        WHEN HOUR(transaction_time) BETWEEN 18 AND 20 THEN 'EVENING'
        ELSE 'OTHER'
    END AS time_bucket

FROM brightlearn.default.bright_coffee_shop_analysis;


---EXPORT TO EXCEL: Query the final table
SELECT * FROM brightlearn.default.coffee_shop_aggregated;




