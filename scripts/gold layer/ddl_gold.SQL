/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================
Script Purpose:
    This script creates views for the Gold layer in the data warehouse. 
    The Gold layer represents the final dimension and fact tables (Star Schema)

    Each view performs transformations and combines data from the Silver layer 
    to produce a clean, enriched, and business-ready dataset.

Usage:
    - These views can be queried directly for analytics and reporting.
===============================================================================
*/

-- =============================================================================
-- Create Dimension: gold.dim_customers
-- =============================================================================

  DROP VIEW IF EXISTS GOLD.DIM_CUSTOMERS;
CREATE VIEW GOLD.DIM_CUSTOMERS AS
SELECT
	ROW_NUMBER() OVER (
		ORDER BY
			CI.CST_ID
	) AS CUSTOMER_KEY,
	CI.CST_ID AS CUSTOMER_ID,
	CI.CST_KEY AS CUSTOMER_NUMER,
	CI.CST_FIRSTNAME AS FIRST_NAME,
	CI.CST_LASTNAME AS LAST_NAME,
	CA.BDATE AS BIRTHDATE,
	CASE
		WHEN CI.CST_GNDR != 'n/a' THEN CI.CST_GNDR
		ELSE COALESCE(CA.GEN, 'n/a')
	END AS NEW_GEN,
	CI.CST_MARITAL_STATUS AS MARITAL_STATUS,
	LA.CNTRY AS COUNTRY,
	CI.CST_CREATE_DATE AS CREATED_DATE
FROM
	SILVER.CRM_CUST_INFO CI
	LEFT JOIN SILVER.ERP_CUST_AZ12 CA ON CI.CST_KEY = CA.CST_KEY
	LEFT JOIN SILVER.ERP_LOC_A101 LA ON CI.CST_KEY = LA.CID;
---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------

DROP VIEW IF EXISTS gold.dim_products;
CREATE VIEW gold.dim_products AS
SELECT
	ROW_NUMBER() OVER (
		ORDER BY
			pn.PRD_START_DT,
			pn.PRD_ID
	) AS PRODUCT_KEY,
	PN.PRD_ID AS PRODUCT_ID,
	PN.PRD_KEY AS PRODUCT_NUMBER,
	PN.PRD_NM AS PRODUCT_NAME,
	PN.CAT_ID AS CATEGORY_ID,
	PC.CAT AS CATEGORY,
	PC.SUBCAT AS SUBCATEGORY,
	PC.MAINTENANCE,
	PN.PRD_COST AS COST,
	PN.PRD_LINE AS PRODUCT_LINE,
	PN.PRD_START_DT AS START_DATE
FROM
	SILVER.CRM_PRD_INFO PN
	LEFT JOIN SILVER.ERP_PX_CAT_G1V2 PC ON PN.CAT_ID = PC.ID
WHERE
	PN.PRD_END_DT IS NULL;     -- filter out historical or closed a/c data

--------------------------------------------------------------------------
--------------------------------------------------------------------------

DROP VIEW IF EXISTS gold.fact_sales;
create view gold.fact_sales as
SELECT
sd.sls_ord_num as order_number,
pr.product_key,   -- Dimension Keys (we need this instead of keys in sales details)
cu.customer_key,   -- Dimension Keys (we need this instead of keys in sales details)
sd.sls_order_dt as order_date,
sd.sls_ship_dt as shipping_date,
sd.sls_due_dt as due_date,
sd.sls_sales as sales_amount,
sd.sls_quantity as quantity,
sd.sls_price as price
FROM silver.crm_sales_details sd
left join gold.dim_products pr on sd.sls_prd_key = pr.product_number
left join gold.dim_customers cu on sd.sls_cust_id = cu.customer_id;
