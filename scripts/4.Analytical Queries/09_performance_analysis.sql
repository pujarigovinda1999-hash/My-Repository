/*
===============================================================================
Performance Analysis (Year-over-Year, Month-over-Month)
===============================================================================
Purpose:
    - To measure the performance of products, customers, or regions over time.
    - For benchmarking and identifying high-performing entities.
    - To track yearly trends and growth.

SQL Functions Used:
    - LAG(): Accesses data from previous rows.
    - AVG() OVER(): Computes average values within partitions.
    - CASE: Defines conditional logic for trend analysis.
===============================================================================
*/

-- Analyze the yearly performance of products by comparing their sales to both the average sales performance of the product and the previous year's sales

SELECT
    *,
    (TOTAL_SALES - PREV_YEAR_SALES) AS YOY_GROWTH,
    (TOTAL_SALES - AVG_PRODUCT_SALES) AS VS_PRODUCT_AVG,
    ROUND(
        (TOTAL_SALES - PREV_YEAR_SALES) * 100.0
        / NULLIF(PREV_YEAR_SALES, 0),
        2
    ) AS YOY_GROWTH_PCT
FROM
(
    SELECT
        YEAR,
        PRODUCT_NAME,
        TOTAL_SALES,

        LAG(TOTAL_SALES) OVER (
            PARTITION BY PRODUCT_NAME
            ORDER BY YEAR
        ) AS PREV_YEAR_SALES,

        ROUND(
            AVG(TOTAL_SALES) OVER (
                PARTITION BY PRODUCT_NAME
            ),
            2
        ) AS AVG_PRODUCT_SALES,

        ROUND(
            AVG(TOTAL_SALES) OVER (
                PARTITION BY YEAR
            ),
            2
        ) AS AVG_YEAR_SALES,

        DENSE_RANK() OVER (
            PARTITION BY YEAR
            ORDER BY TOTAL_SALES DESC
        ) AS RNK
    FROM
    (
        SELECT
            EXTRACT(YEAR FROM F.ORDER_DATE) AS YEAR,
            P.PRODUCT_NAME,
            SUM(F.SALES_AMOUNT) AS TOTAL_SALES
        FROM GOLD.FACT_SALES F
        JOIN GOLD.DIM_PRODUCTS P
            ON P.PRODUCT_KEY = F.PRODUCT_KEY
        WHERE F.ORDER_DATE IS NOT NULL
        GROUP BY
            EXTRACT(YEAR FROM F.ORDER_DATE),
            P.PRODUCT_NAME
    ) T
) T2
ORDER BY YEAR, RNK;
