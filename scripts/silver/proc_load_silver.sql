/*
==============================================================================
Stored Procedure: Load Silver Layer ( Bronze -> Silver )
==============================================================================
Script purpose:
  This stored procedure loads data into the 'silver' schema from bronze layers.
  It performs the following actions:
  - Truncates the silver tables before loading data.
  

Parameters:
  None.
This Stored Procedure does not accept any parameters or return any values.

Usage Example:
  EXEC silver.load_silver;
  ==============================================================================
*/




CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
		DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME

	
		BEGIN TRY
			SET @batch_start_time = GETDATE()
			PRINT '======================================================================================';
			PRINT ' LOADING THE SILVER LAYER';
			PRINT '======================================================================================';
		 

			PRINT '--------------------------------------------------------------------------------------';
			PRINT 'Loading the crm tables';
			PRINT '--------------------------------------------------------------------------------------';
		
			SET @start_time = GETDATE()
	PRINT '>> Truncating Table: silver.crm_cust_info';
	TRUNCATE TABLE silver.crm_cust_info;
	PRINT '>> Inserting Data Into: silver.crm_cust_info';
	INSERT INTO silver.crm_cust_info(
		cst_id,
		cst_key,
		cst_firstname,
		cst_lastname,
		cst_marital_status,
		cst_gndr,
		cst_create_date
	)
	SELECT
		cst_id,
		cst_key,
		TRIM(cst_firstname) AS cst_firstname,
		TRIM(cst_lastname) AS cst_lastname,
		CASE
			WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
			WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
			ELSE 'n/a'
		END AS cst_marital_status,
		CASE
			WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
			WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
			ELSE 'n/a'
		END AS cst_gndr,
		cst_create_date
	FROM (
		SELECT
			*,
			ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
		FROM bronze.crm_cust_info
		WHERE cst_id IS NOT NULL
	) t
	WHERE flag_last = 1;
	SET @end_time = GETDATE()
	PRINT '>>Load duration: ' + CAST(DATEDIFF(second, @start_time,@end_time) AS NVARCHAR ) + ' seconds';
	PRINT '-----------------'



	SET @start_time = GETDATE()
	PRINT '>> Truncating Table: silver.crm_prd_info';
	TRUNCATE TABLE silver.crm_prd_info;
	PRINT '>> Inserting Data Into: silver.crm_prd_info';
	INSERT INTO silver.crm_prd_info(
		prd_id,
		cat_id,
		prd_key,
		prd_nm,
		prd_cost,
		prd_line,
		prd_start_dt,
		prd_end_dt
	)

	SELECT 
		prd_id,
		REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id, --Extract category ID
		SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,        -- Extract product key
		prd_nm,
		ISNULL( prd_cost,0) AS prd_cost,
		CASE UPPER(TRIM(prd_line))
			 WHEN 'M' THEN 'Mountain'
			 WHEN 'R' THEN 'Road'
			 WHEN 'S' THEN 'Other Sales'
			 WHEN 'T' THEN ' Touring'
			 ELSE 'n/a'
		END AS prd_line,   -- Map product line codes to descriptive values  
		CAST (prd_start_dt AS DATE) AS prd_start_dt,
		CAST(
			LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) - 1 
			AS DATE
		) AS prd_end_dt
		FROM bronze.crm_prd_info
		SET @end_time = GETDATE()
		PRINT '>>Load duration: ' + CAST(DATEDIFF(second, @start_time,@end_time) AS NVARCHAR ) + ' seconds';
		PRINT '-----------------'


	SET @start_time = GETDATE()
	PRINT '>> Truncating Table: silver.crm_sls_details';
	TRUNCATE TABLE silver.crm_sls_details;
	PRINT '>> Inserting Data Into: silver.crm_sls_details';
	INSERT INTO silver.crm_sls_details(
		sls_ord_num,
		sls_prd_key,
		sls_cust_id,
		sls_order_dt,
		sls_ship_dt,
		sls_due_dt,
		sls_sales,
		sls_quantity,
		sls_price
	)
	SELECT
		sls_ord_num,
		sls_prd_key,
		sls_cust_id,
		CASE WHEN sls_order_dt = 0 or LEN(sls_order_dt) != 8 THEN NULL
			 ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
		END AS sls_order_dt,    -- Changes the data type from INT to DATE   
		CASE WHEN sls_ship_dt = 0 or LEN(sls_ship_dt) != 8 THEN NULL
			 ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
		END AS sls_ship_dt,
		CASE WHEN sls_due_dt = 0 or LEN(sls_due_dt) != 8 THEN NULL
			 ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
		END AS sls_due_dt,
		CASE WHEN sls_sales IS NULL OR sls_sales <=0 OR sls_sales != sls_quantity * ABS(sls_price)
			THEN sls_quantity * ABS(sls_price)
		ELSE sls_sales
	END AS sls_sales, -- Recalculate sales if original value is missing or inncorrect
		sls_quantity,
		CASE WHEN sls_price IS NULL OR sls_price <=0
			THEN sls_sales / NULLIF(sls_quantity,0)
		ELSE sls_price  -- Derive price if original value is invalid
	END AS sls_price
	FROM bronze.crm_sls_details
	SET @end_time = GETDATE()
	PRINT '>>Load duration: ' + CAST(DATEDIFF(second, @start_time,@end_time) AS NVARCHAR ) + ' seconds';
	PRINT '-----------------'




	PRINT '--------------------------------------------------------------------------------------';
	PRINT 'Loading the erp tables';
	PRINT '--------------------------------------------------------------------------------------';

	SET @start_time = GETDATE()
	PRINT '>> Truncating Table: silver.erp_CUST_AZ12';
	TRUNCATE TABLE silver.erp_CUST_AZ12;
	PRINT '>> Inserting Data Into: silver.erp_CUST_AZ12';
	INSERT INTO silver.erp_CUST_AZ12 (CID, BDATE, GEN)
	 SELECT 
	  CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
			ELSE cid
	  END cid,
	   CASE WHEN bdate > GETDATE() THEN NULL
			ELSE bdate
	   END bdate,
	 CASE WHEN UPPER(TRIM(GEN)) IN ('F', 'Female') THEN 'Female'
		 WHEN UPPER(TRIM(GEN)) IN ('M', 'Male') THEN 'Male'
		 ELSE 'n/a'
	END gen
	FROM bronze.erp_cust_az12;
	SET @end_time = GETDATE()
	PRINT '>>Load duration: ' + CAST(DATEDIFF(second, @start_time,@end_time) AS NVARCHAR ) + ' seconds';
	PRINT '-----------------'

	SET @start_time = GETDATE()
	PRINT '>> Truncating Table: silver.erp_LOC_A101';
	TRUNCATE TABLE silver.erp_LOC_A101;
	PRINT '>> Inserting Data Into: silver.erp_LOC_A101';
	INSERT INTO silver.erp_LOC_A101 (CID, CNTRY)
	 SELECT
	 REPLACE(CID, '-', '') CID,
	 CASE WHEN TRIM(CNTRY) = 'DE' THEN 'Germany'
		  WHEN TRIM(CNTRY) IN ('US', 'USA') THEN 'United States'
		  WHEN TRIM(CNTRY) = '' OR CNTRY IS null THEN 'n/a'
		  ELSE TRIM(CNTRY) 
	 END CNTRY  -- Normalize and handle missing or blank country codes
	 FROM bronze.erp_LOC_A101;
	 SET @end_time = GETDATE()
	PRINT '>>Load duration: ' + CAST(DATEDIFF(second, @start_time,@end_time) AS NVARCHAR ) + ' seconds';
	PRINT '-----------------'



	SET @start_time = GETDATE()
	 PRINT '>> Truncating Table: silver.erp_PX_CAT_G1V2';
	TRUNCATE TABLE silver.erp_PX_CAT_G1V2;
	PRINT '>> Inserting Data Into: silver.erp_PX_CAT_G1V2';
	INSERT INTO silver.erp_PX_CAT_G1V2 (ID, CAT, SUBCAT, MAINTENANCE)
	SELECT 
	ID,
	CAT,
	SUBCAT,
	MAINTENANCE
	FROM bronze.erp_PX_CAT_G1V2;
	SET @end_time = GETDATE()
	PRINT '>>Load duration: ' + CAST(DATEDIFF(SECOND, @start_time,@end_time) AS NVARCHAR ) + ' seconds';
	PRINT '-----------------'
	SET @batch_end_time = GETDATE()

	PRINT '===========================================================';
	PRINT ' LOADING THE SILVER LAYER IS COMPLETE'
	PRINT ' - Total Load duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time,@batch_end_time) AS NVARCHAR ) + ' seconds';
	PRINT '===========================================================';
	END TRY
		BEGIN CATCH
			PRINT '=============================================================';
			PRINT 'ERROR HAS OCCURED DURING LOADING SILVER LAYER';
			PRINT 'ERROR MEESAGE' + ERROR_MESSAGE();
			PRINT 'Error message' + CAST (ERROR_NUMBER() AS NVARCHAR );
			PRINT 'Error message' + CAST(ERROR_STATE() AS NVARCHAR );
			PRINT '=============================================================';
		END CATCH
	
END  



EXEC silver.load_silver
