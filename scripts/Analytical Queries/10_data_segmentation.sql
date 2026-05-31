/*
===============================================================================
Data Segmentation Analysis
===============================================================================
Purpose:
    - To group data into meaningful categories for targeted insights.
    - For customer segmentation, product categorization, or regional analysis.

SQL Functions Used:
    - CASE: Defines custom segmentation logic.
    - GROUP BY: Groups data into segments.
===============================================================================
*/

-- Segment products into cost ranges and  count how many products fall into each range

SELECT
	COST_RANGE,
	COUNT(DISTINCT PRODUCT_NAME) AS TOTAL_PRODUCT
FROM
	(
		SELECT
			*,
			CASE
				WHEN COST < 100 THEN 'Below 100'
				WHEN COST BETWEEN 100 AND 500  THEN '100-500'
				WHEN COST BETWEEN 500 AND 1000  THEN '500-1000'
				ELSE 'Above 1000'
			END AS COST_RANGE
		FROM
			GOLD.DIM_PRODUCTS
	) T
GROUP BY
	COST_RANGE
ORDER BY
	TOTAL_PRODUCT DESC;


'Group customers into three segments based on their spending behavior:
	- VIP: Customers with at least 12 months of history and spending more than €5,000.
	- Regular: Customers with at least 12 months of history but spending €5,000 or less.
	- New: Customers with a lifespan less than 12 months.
And find the total number of PRODUCT by each group'

WITH customer_spending AS (
    SELECT
        c.customer_key,
        SUM(f.sales_amount) AS total_spending,
        (
            EXTRACT(YEAR FROM AGE(MAX(f.order_date), MIN(f.order_date))) * 12
            +
            EXTRACT(MONTH FROM AGE(MAX(f.order_date), MIN(f.order_date)))
        ) AS lifespan
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_customers c
        ON f.customer_key = c.customer_key
    GROUP BY c.customer_key
)

SELECT
    CASE
        WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
        WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular'
        ELSE 'New'
    END AS customer_segment,
    COUNT(*) AS total_customers
FROM customer_spending
GROUP BY customer_segment
ORDER BY total_customers DESC;
