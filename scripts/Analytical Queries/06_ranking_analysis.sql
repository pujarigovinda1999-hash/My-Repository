/*
===============================================================================
Ranking Analysis
===============================================================================
Purpose:
    - To rank items (e.g., products, customers) based on performance or other metrics.
    - To identify top performers or laggards.

SQL Functions Used:
    - Window Ranking Functions: RANK(), DENSE_RANK(), ROW_NUMBER(), TOP
    - Clauses: GROUP BY, ORDER BY
===============================================================================
*/

-- Which 5 products Generating the Highest Revenue?

SELECT * FROM
(SELECT P.PRODUCT_KEY, P.PRODUCT_NUMBER, P.PRODUCT_NAME,
SUM(F.SALES_AMOUNT) AS REVENUE,
ROW_NUMBER() OVER (ORDER BY SUM(F.SALES_AMOUNT) DESC) AS RNK
FROM gold.dim_products P
JOIN gold.fact_sales F
ON P.PRODUCT_KEY = F.PRODUCT_KEY
GROUP BY P.PRODUCT_KEY, P.PRODUCT_NUMBER, P.PRODUCT_NAME) T WHERE RNK <= 5;

-- What are the 5 worst-performing products in terms of sales?

SELECT * FROM
(SELECT P.PRODUCT_KEY, P.PRODUCT_NUMBER, P.PRODUCT_NAME,
SUM(F.SALES_AMOUNT) AS REVENUE,
ROW_NUMBER() OVER (ORDER BY SUM(F.SALES_AMOUNT) ASC) AS RNK
FROM gold.dim_products P
JOIN gold.fact_sales F
ON P.PRODUCT_KEY = F.PRODUCT_KEY
GROUP BY P.PRODUCT_KEY, P.PRODUCT_NUMBER, P.PRODUCT_NAME) T WHERE RNK <= 5;

-- Find the top 10 customers who have generated the highest revenue

SELECT * FROM
(SELECT C.CUSTOMER_KEY, C.FIRST_NAME, C.LAST_NAME,
SUM(F.SALES_AMOUNT) AS REVENUE,
ROW_NUMBER() OVER (ORDER BY SUM(F.SALES_AMOUNT) DESC) AS RNK
FROM GOLD.DIM_CUSTOMERS C
JOIN gold.fact_sales F
ON C.CUSTOMER_KEY = F.CUSTOMER_KEY
GROUP BY C.CUSTOMER_KEY, C.FIRST_NAME, C.LAST_NAME) T WHERE RNK <= 10;

-- The 3 customers with the fewest orders placed

SELECT C.CUSTOMER_KEY, C.FIRST_NAME, C.LAST_NAME, COUNT(DISTINCT F.order_number) ORDER_COUNT FROM gold.fact_sales F
LEFT JOIN GOLD.DIM_CUSTOMERS C
ON C.CUSTOMER_KEY = F.CUSTOMER_KEY
GROUP BY C.CUSTOMER_KEY, C.FIRST_NAME, C.LAST_NAME ORDER BY ORDER_COUNT ASC;
