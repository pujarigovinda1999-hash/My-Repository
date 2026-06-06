/*
===============================================================================
Cumulative Analysis
===============================================================================
Purpose:
    - To calculate running totals or moving averages for key metrics.
    - To track performance over time cumulatively.
    - Useful for growth analysis or identifying long-term trends.

SQL Functions Used:
    - Window Functions: SUM() OVER(), AVG() OVER()
===============================================================================
*/

-- Calculate the total sales per month and the running total of sales over time
SELECT
	*,
	SUM(TOTAL_SALES) OVER (
		ORDER BY
			ORDER_DATE
	)
FROM
	(
		SELECT
			TO_CHAR(ORDER_DATE, 'yyyy-Mon') AS ORDER_DATE,
			SUM(SALES_AMOUNT) AS TOTAL_SALES
		FROM
			GOLD.FACT_SALES
		WHERE
			ORDER_DATE IS NOT NULL
		GROUP BY
			TO_CHAR(ORDER_DATE, 'yyyy-Mon')
		ORDER BY
			TO_CHAR(ORDER_DATE, 'yyyy-Mon')
	) T;
