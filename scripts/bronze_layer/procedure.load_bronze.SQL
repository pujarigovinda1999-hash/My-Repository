/*
===============================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
===============================================================================
Script Purpose:
    This stored procedure loads data into the 'bronze' schema from external CSV files. 
    It performs the following actions:
    - Truncates the bronze tables before loading data.
    - Uses the `BULK INSERT` command to load data from csv Files to bronze tables.

Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    CALL bronze.load_bronze();
===============================================================================
*/

-- Bulk Inserting data in tables
CREATE OR REPLACE PROCEDURE BRONZE.LOAD_BRONZE ()
LANGUAGE PLPGSQL
AS $$
DECLARE total_rows INT;
		start_time TIMESTAMP;
    	end_time TIMESTAMP;
    	duration INTERVAL;
BEGIN
	start_time := clock_timestamp();
	RAISE NOTICE 'ETL Started At: %', start_time;
	
	Raise Notice '=====================================================';
	Raise Notice 'Loading Bronze Layer';
	Raise Notice '=====================================================';
	Raise Notice '-----------------------------------------------------';
	Raise Notice 'Loading CRM Tables';
	Raise Notice '-----------------------------------------------------';
	
	Raise Notice '>> Truncating Table: bronze.crm_cust_info';
	
TRUNCATE TABLE bronze.crm_cust_info;

	Raise Notice '>> Uploading data in: bronze.crm_cust_info';

COPY bronze.crm_cust_info FROM 'C:\Program Files\PostgreSQL\18\data\sql-data-warehouse-project-main\datasets\source_crm\cust_info.csv'
DELIMITER ',' CSV HEADER;
SELECT COUNT(*) INTO total_rows FROM bronze.crm_cust_info;

	RAISE NOTICE 'Rows Loaded in: %', total_rows; -- % is necessary if you want to show some nos in output, % is a placeholder.

	Raise Notice '>> Truncating Table: bronze.crm_prd_info';

TRUNCATE TABLE bronze.crm_prd_info;

	Raise Notice '>> Uploading data in: bronze.crm_prd_info';
	
COPY bronze.crm_prd_info FROM 'C:\Program Files\PostgreSQL\18\data\sql-data-warehouse-project-main\datasets\source_crm\prd_info.csv'
DELIMITER ',' CSV HEADER;
SELECT COUNT(*) INTO total_rows FROM bronze.crm_prd_info;

	RAISE NOTICE 'Rows Loaded: %', total_rows;

	Raise Notice '>> Truncating Table: bronze.crm_sales_details';

TRUNCATE TABLE bronze.crm_sales_details;

	Raise Notice '>> Uploading data in: bronze.crm_sales_details';
	
COPY bronze.crm_sales_details FROM 'C:\Program Files\PostgreSQL\18\data\sql-data-warehouse-project-main\datasets\source_crm\sales_details.csv'
DELIMITER ',' CSV HEADER;
SELECT COUNT(*) INTO total_rows FROM bronze.crm_sales_details;

	RAISE NOTICE 'Rows Loaded: %', total_rows;

	Raise Notice '-----------------------------------------------------';

	Raise Notice '=====================================================';
	Raise Notice 'Loading ERP Tables';
	Raise Notice '=====================================================';

	Raise Notice '>> Truncating Table: bronze.erp_cust_az12';
	
TRUNCATE TABLE bronze.erp_cust_az12;

	Raise Notice '>> Uploading data in: bronze.erp_cust_az12';
	
COPY bronze.erp_cust_az12 FROM 'C:\Program Files\PostgreSQL\18\data\sql-data-warehouse-project-main\datasets\source_erp\CUST_AZ12.csv'
DELIMITER ',' CSV HEADER;
SELECT COUNT(*) INTO total_rows FROM bronze.erp_cust_az12;

	RAISE NOTICE 'Rows Loaded: %', total_rows;

	Raise Notice '>> Truncating Table: bronze.erp_loc_a101';
	
TRUNCATE TABLE bronze.erp_loc_a101;


	Raise Notice '>> Uploading data in: bronze.erp_loc_a101';
	
COPY bronze.erp_loc_a101 FROM 'C:\Program Files\PostgreSQL\18\data\sql-data-warehouse-project-main\datasets\source_erp\LOC_A101.csv'
DELIMITER ',' CSV HEADER;
SELECT COUNT(*) INTO total_rows FROM bronze.erp_loc_a101;


	RAISE NOTICE 'Rows Loaded: %', total_rows;

	Raise Notice '>> Truncating Table: bronze.erp_px_cat_g1v2';
	
TRUNCATE TABLE bronze.erp_px_cat_g1v2;

	Raise Notice '>> Uploading data in: bronze.erp_px_cat_g1v2';
	
COPY bronze.erp_px_cat_g1v2 FROM 'C:\Program Files\PostgreSQL\18\data\sql-data-warehouse-project-main\datasets\source_erp\PX_CAT_G1V2.csv'
DELIMITER ',' CSV HEADER;
SELECT COUNT(*) INTO total_rows FROM bronze.erp_px_cat_g1v2;

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

---------------------------------------------------------------------

CALL bronze.load_bronze();

---------------------------------------------------------------------

