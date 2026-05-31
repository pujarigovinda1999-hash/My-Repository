/*
===============================================================================
Date Range Exploration 
===============================================================================
Purpose:
    - To determine the temporal boundaries of key data points.
    - To understand the range of historical data.

SQL Functions Used:
    - MIN(), MAX(), EXTRACT(), AGE(), CURRENT_DATE
===============================================================================
*/

-- Determine the first and last order date and the total duration in months

SELECT
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date,
    EXTRACT(YEAR FROM AGE(MAX(order_date), MIN(order_date))) AS years,
    EXTRACT(MONTH FROM AGE(MAX(order_date), MIN(order_date))) AS months
FROM gold.fact_sales;


-- Find the youngest and oldest customer based on birthdate

SELECT
    'Oldest Customer' AS category,
    MIN(birthdate) AS birthdate,
    EXTRACT(YEAR FROM AGE(CURRENT_DATE, MIN(birthdate))) AS age
FROM gold.dim_customers

UNION ALL

SELECT
    'Youngest Customer' AS category,
    MAX(birthdate) AS birthdate,
    EXTRACT(YEAR FROM AGE(CURRENT_DATE, MAX(birthdate))) AS age
FROM gold.dim_customers;
