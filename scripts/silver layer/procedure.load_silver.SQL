/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process to 
    populate the 'silver' schema tables from the 'bronze' schema.
	Actions Performed:
		- Truncates Silver tables.
		- Inserts transformed and cleansed data from Bronze into Silver tables.
		
Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    CALL SILVER.LOAD_SILVER();
===============================================================================
*/

CREATE OR REPLACE PROCEDURE SILVER.LOAD_SILVER ()
LANGUAGE PLPGSQL
AS $$
DECLARE total_rows INT;
		start_time TIMESTAMP;
    	end_time TIMESTAMP;
    	duration INTERVAL;
BEGIN
	start_time := clock_timestamp();  -- clock_timestamp() This is a PostgreSQL function that returns: date, hrs, min, sec, milisec
	RAISE NOTICE 'ETL Started At: %', start_time; -- % is necessary if you want to show some nos in output, % is a placeholder.
	
	Raise Notice '=====================================================';
	Raise Notice 'Loading Silver Layer';
	Raise Notice '=====================================================';
	Raise Notice '-----------------------------------------------------';
	Raise Notice 'Loading CRM Tables';
	Raise Notice '-----------------------------------------------------';

	Raise Notice '-----------------------------------------------------';
	
	Raise Notice '>> Truncating Table: bronze.crm_cust_info';

TRUNCATE SILVER.CRM_CUST_INFO;
Raise Notice '>> Insert data into Table: bronze.crm_cust_info';
INSERT INTO
	SILVER.CRM_CUST_INFO (
		CST_ID,
		CST_KEY,
		CST_FIRSTNAME,
		CST_LASTNAME,
		CST_MARITAL_STATUS,
		CST_GNDR,
		CST_CREATE_DATE
	)
SELECT
	CST_ID,
	CST_KEY,
	TRIM(CST_FIRSTNAME) AS CST_FIRSTNAME,
	TRIM(CST_LASTNAME) AS CST_LASTNAME,
	CASE UPPER(TRIM(CST_MARITAL_STATUS))
		WHEN 'S' THEN 'SINGLE'
		WHEN 'M' THEN 'MARRIED'
		ELSE 'n/a' -- Normalize marital status values to readable format
	END CST_MARITAL_STATUS,
	CASE UPPER(TRIM(CST_GNDR))
		WHEN 'F' THEN 'FEMALE'
		WHEN 'M' THEN 'MALE'
		ELSE 'n/a' -- Normalize gender values to readable format
	END CST_GNDR,
	CST_CREATE_DATE
FROM
	(
		SELECT
			*,
			ROW_NUMBER() OVER (
				PARTITION BY
					CST_ID
				ORDER BY
					CST_CREATE_DATE DESC
			) AS RECORD
		FROM
			BRONZE.CRM_CUST_INFO
	) T
WHERE
	RECORD = 1 -- Select the most recent record per customer
	AND CST_ID IS NOT NULL;
	SELECT COUNT(*) INTO total_rows FROM SILVER.CRM_CUST_INFO;

	RAISE NOTICE 'Rows Loaded: %', total_rows;
-----------------------------------------------------------------
RAISE NOTICE '>> Truncating Table: silver.CRM_PRD_INFO';

TRUNCATE SILVER.CRM_PRD_INFO;
Raise Notice '>> Insert data into Table: SILVER.CRM_PRD_INFO';
INSERT INTO
	SILVER.CRM_PRD_INFO (
		PRD_ID,
		CAT_ID,
		PRD_KEY,
		PRD_NM,
		PRD_COST,
		PRD_LINE,
		PRD_START_DT,
		PRD_END_DT
	)
SELECT
	PRD_ID,
	REPLACE(SUBSTRING(PRD_KEY, 1, 5), '-', '_') AS CAT_ID,
	SUBSTRING(PRD_KEY, 7, LENGTH(PRD_KEY)) AS PRD_KEY,
	PRD_NM,
	COALESCE(PRD_COST::INT, 0) AS PRD_COST,
	CASE UPPER(TRIM(PRD_LINE))
		WHEN 'M' THEN 'MOUNTAIN'
		WHEN 'R' THEN 'ROAD'
		WHEN 'S' THEN 'Other Sales'
		WHEN 'T' THEN 'Touring'
		ELSE 'n/a'
	END PRD_LINE,
	CAST(PRD_START_DT AS DATE) AS PRD_START_DT,
	CAST(
		LEAD(PRD_START_DT) OVER (
			PARTITION BY
				PRD_KEY
			ORDER BY
				PRD_START_DT
		) - INTERVAL '1 DAY' AS DATE
	) AS PRD_END_DT
FROM
	BRONZE.CRM_PRD_INFO;
	SELECT COUNT(*) INTO total_rows FROM SILVER.CRM_PRD_INFO;

-- Note since you have changed datetime format in this query we will have to change date in craeted table as well. 

	RAISE NOTICE 'Rows Loaded: %', total_rows;
----------------------------------------------------------------

RAISE NOTICE '>> Truncating Table: silver.crm_sales_details';

TRUNCATE SILVER.CRM_SALES_DETAILS;
Raise Notice '>> Insert data into Table: SILVER.CRM_SALES_DETAILS';
INSERT INTO
	SILVER.CRM_SALES_DETAILS (
		SLS_ORD_NUM,
		SLS_PRD_KEY,
		SLS_CUST_ID,
		SLS_ORDER_DT,
		SLS_SHIP_DT,
		SLS_DUE_DT,
		SLS_SALES,
		SLS_QUANTITY,
		SLS_PRICE
	)
SELECT
	SLS_ORD_NUM,
	SLS_PRD_KEY,
	SLS_CUST_ID,
	CASE
		WHEN SLS_ORDER_DT::TEXT ~ '^[0-9]{8}$' THEN TO_DATE(SLS_ORDER_DT::TEXT, 'YYYYMMDD')
		ELSE NULL
	END AS SLS_ORDER_DT,
	CASE
		WHEN SLS_SHIP_DT::TEXT ~ '^[0-9]{8}$' THEN TO_DATE(SLS_SHIP_DT::TEXT, 'YYYYMMDD')
		ELSE NULL
	END AS SLS_SHIP_DT,
	CASE
		WHEN SLS_DUE_DT::TEXT ~ '^[0-9]{8}$' THEN TO_DATE(SLS_DUE_DT::TEXT, 'YYYYMMDD')
		ELSE NULL
	END AS SLS_DUE_DT,
	-- DERIVE SALES
	CASE
		WHEN SLS_SALES IS NULL
		OR SLS_SALES <= 0
		OR SLS_SALES != SLS_QUANTITY * SLS_PRICE THEN SLS_QUANTITY * ABS(SLS_PRICE)
		ELSE SLS_SALES
	END AS SLS_SALES,
	-- DERIVE QUANTITY
	CASE
		WHEN SLS_QUANTITY IS NULL
		OR SLS_QUANTITY <= 0 THEN SLS_SALES / NULLIF(ABS(SLS_PRICE), 0)
		ELSE SLS_QUANTITY
	END AS SLS_QUANTITY,
	-- DERIVE PRICE
	CASE
		WHEN SLS_PRICE IS NULL
		OR SLS_PRICE <= 0 THEN SLS_SALES / NULLIF(ABS(SLS_QUANTITY), 0)
		ELSE SLS_PRICE
	END AS SLS_PRICE
FROM
	BRONZE.CRM_SALES_DETAILS;
	SELECT COUNT(*) INTO total_rows FROM SILVER.CRM_SALES_DETAILS;

	RAISE NOTICE 'Rows Loaded: %', total_rows;
-----------------------------------------------------------------------------

	Raise Notice '-----------------------------------------------------';

	Raise Notice '=====================================================';
	Raise Notice 'Loading ERP Tables';
	Raise Notice '=====================================================';

RAISE NOTICE '>> Truncating Table: silver.erp_cust_az12';

TRUNCATE SILVER.ERP_CUST_AZ12;
Raise Notice '>> Insert data into Table: SILVER.ERP_CUST_AZ12';
INSERT INTO
	SILVER.ERP_CUST_AZ12 (CID, CST_KEY, BDATE, GEN)
SELECT
	CID,
	CASE
		WHEN LEFT(CID, 3) = 'NAS' THEN REPLACE(CID, 'NAS', '')
		ELSE CID
	END AS CST_KEY,
	CASE
		WHEN BDATE > CURRENT_DATE THEN NULL
		ELSE BDATE
	END AS BDATE,
	CASE
		WHEN UPPER(TRIM(GEN)) IN ('F', 'FEMALE') THEN 'FEMALE'
		WHEN UPPER(TRIM(GEN)) IN ('M', 'MALE') THEN 'MALE'
		ELSE 'N/A'
	END AS GEN
FROM
	BRONZE.ERP_CUST_AZ12;
	SELECT COUNT(*) INTO total_rows FROM SILVER.ERP_CUST_AZ12;

	RAISE NOTICE 'Rows Loaded: %', total_rows;
-------------------------------------------------------------------------------------------

RAISE NOTICE '>> Truncating Table: silver.erp_loc_a101';

TRUNCATE SILVER.ERP_LOC_A101;
Raise Notice '>> Insert data into Table: SILVER.ERP_LOC_A101';
INSERT INTO
	SILVER.ERP_LOC_A101 (CID, CNTRY)
SELECT
	REPLACE(CID, '-', '') AS CID,
	CASE
		WHEN TRIM(CNTRY) IN ('US', 'USA') THEN 'United States'
		WHEN TRIM(CNTRY) = 'DE' THEN 'Germany'
		WHEN TRIM(CNTRY) IS NULL
		OR TRIM(CNTRY) = '' THEN 'N/A'
		ELSE TRIM(CNTRY)
	END AS CNTRY
FROM
	BRONZE.ERP_LOC_A101;
	SELECT COUNT(*) INTO total_rows FROM SILVER.ERP_LOC_A101;

	RAISE NOTICE 'Rows Loaded: %', total_rows;
----------------------------------------------------------------------------------

RAISE NOTICE '>> Truncating Table: silver.erp_px_cat_g1v2';

TRUNCATE SILVER.ERP_PX_CAT_G1V2;
Raise Notice '>> Insert data into Table: SILVER.ERP_PX_CAT_G1V2';
INSERT INTO
	SILVER.ERP_PX_CAT_G1V2 (ID, CAT, SUBCAT, MAINTENANCE)
SELECT
	TRIM(ID) AS ID,
	TRIM(CAT) AS CAT,
	TRIM(SUBCAT) AS SUBCAT,
	TRIM(MAINTENANCE) AS MAINTENANCE
FROM
	BRONZE.ERP_PX_CAT_G1V2;
	SELECT COUNT(*) INTO total_rows FROM SILVER.ERP_PX_CAT_G1V2;

	RAISE NOTICE 'Rows Loaded: %', total_rows;

	-- Capture End Time
    end_time := clock_timestamp();

    -- Calculate Duration
    duration := end_time - start_time;

    RAISE NOTICE 'ETL Ended At: %', end_time;

    RAISE NOTICE 'Total ETL Duration: %', duration;

EXCEPTION
    WHEN OTHERS THEN
       
        end_time := clock_timestamp();

        duration := end_time - start_time;

        RAISE NOTICE 'ETL Failed';

        RAISE NOTICE 'Error: %', SQLERRM;

        RAISE NOTICE 'Failed At: %', end_time;

        RAISE NOTICE 'Execution Duration Before Failure: %', duration;
		
		END;
		$$;

CALL SILVER.LOAD_SILVER();
-------------------------------------------------------------------------------------
