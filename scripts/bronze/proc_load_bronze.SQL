/*
==============================================================================
Stored Procedure: Load Bronze Layer ( Source -> Bronze )
==============================================================================
Script purpose:
  This stored procedure loads data into the 'bronze' schema from external CSV files.
  It performs the following actions:
  - Truncates the bronze tables before loading data.
  - Uses 'BULK INSERT' command to load data frm csv files to bronze tables.

Parameters:
  None.
This Stored Procedure does not accept any parameters or return any values.

Usage Example:
  EXEC bronze.load_bronze;
  ==============================================================================
*/
CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME

	
		BEGIN TRY
			SET @batch_start_time = GETDATE()
			PRINT '======================================================================================';
			PRINT ' LOADING THE BRONZE LAYER';
			PRINT '======================================================================================';
		 

			PRINT '--------------------------------------------------------------------------------------';
			PRINT 'Loading the crm tables';
			PRINT '--------------------------------------------------------------------------------------';
		
			SET @start_time = GETDATE()
			PRINT '>>Truncating the table crm_cust_info';
			TRUNCATE TABLE bronze.crm_cust_info
			PRINT '>> Loading the table cust_info'
			BULK INSERT bronze.crm_cust_info
			FROM 'D:\Users\Documents\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
			WITH (
					FIRSTROW = 2,
					FIELDTERMINATOR =',',
					TABLOCK
			);
			SET @end_time = GETDATE()
			PRINT '>>Load duration: ' + CAST(DATEDIFF(second, @start_time,@end_time) AS NVARCHAR ) + ' seconds';
			PRINT '-----------------'


			SET @start_time = GETDATE()
			PRINT '>>Truncating the table crm_prd_info';
			TRUNCATE TABLE bronze.crm_prd_info
			PRINT '>> Loading the table prd_info'
			BULK INSERT bronze.crm_prd_info
			FROM 'D:\Users\Documents\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
			WITH (
					FIRSTROW = 2,
					FIELDTERMINATOR =',',
					TABLOCK
			);
			SET @end_time = GETDATE()
			PRINT '>>Load duration: ' + CAST(DATEDIFF(second, @start_time,@end_time) AS NVARCHAR ) + ' seconds';
			PRINT '-----------------'

			SET @start_time = GETDATE()
			PRINT '>>Truncating the table sls_details';
			TRUNCATE TABLE bronze.crm_sls_details	
			PRINT '>> Loading the table sls_details'
			BULK INSERT bronze.crm_sls_details
			FROM 'D:\Users\Documents\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
			WITH (
					FIRSTROW = 2,
					FIELDTERMINATOR =',',
					TABLOCK
			);
			SET @end_time = GETDATE()
			PRINT '>>Load duration: ' + CAST(DATEDIFF(second, @start_time,@end_time) AS NVARCHAR ) + ' seconds';
			PRINT '-----------------'

			PRINT '--------------------------------------------------------------------------------------';
			PRINT 'Loading the erp tables';
			PRINT '--------------------------------------------------------------------------------------';

			SET @start_time = GETDATE()
			PRINT '>>Truncating the table CUST_AZ12';
			TRUNCATE TABLE bronze.erp_CUST_AZ12
			PRINT '>>Loading the table CUST_AZ12'
			BULK INSERT bronze.erp_CUST_AZ12
			FROM 'D:\Users\Documents\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
			WITH (
					FIRSTROW = 2,
					FIELDTERMINATOR =',',
					TABLOCK
			);
			SET @end_time = GETDATE()
			PRINT '>>Load duration: ' + CAST(DATEDIFF(second, @start_time,@end_time) AS NVARCHAR ) + ' seconds';
			PRINT '-----------------'


			SET @start_time = GETDATE()
			PRINT '>>Truncating the table LOC_A101'
			TRUNCATE TABLE bronze.erp_LOC_A101
			PRINT '>>Loading the table LOC_A101'
			BULK INSERT bronze.erp_LOC_A101
			FROM 'D:\Users\Documents\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
			WITH (
					FIRSTROW = 2,
					FIELDTERMINATOR =',',
					TABLOCK
			);
			SET @end_time = GETDATE()
			PRINT '>>Load duration: ' + CAST(DATEDIFF(second, @start_time,@end_time) AS NVARCHAR ) + ' seconds';
			PRINT '-----------------'


			SET @start_time = GETDATE()
			PRINT '>>Truncating the Table PX_CAT-G1V2'
			TRUNCATE TABLE bronze.erp_PX_CAT_G1V2
			PRINT '>>Loading the table PX_CAT_G1V2'
			BULK INSERT bronze.erp_PX_CAT_G1V2
			FROM 'D:\Users\Documents\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
			WITH (
					FIRSTROW = 2,
					FIELDTERMINATOR =',',
					TABLOCK
			);
			SET @end_time = GETDATE()
			PRINT '>>Load duration: ' + CAST(DATEDIFF(SECOND, @start_time,@end_time) AS NVARCHAR ) + ' seconds';
			PRINT '-----------------'
			SET @batch_end_time = GETDATE()

			PRINT '===============f============================================';
			PRINT ' LOADING THE BRONZE LAYER IS COMPLETE'
			PRINT ' - Total Load duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time,@batch_end_time) AS NVARCHAR ) + ' seconds';
			PRINT '===========================================================';

		END TRY
		BEGIN CATCH
			PRINT '=============================================================';
			PRINT 'ERROR HAS OCCURED DURING LOADING BRONZE LAYER';
			PRINT 'ERROR MEESAGE' + ERROR_MESSAGE();
			PRINT 'Error message' + CAST (ERROR_NUMBER() AS NVARCHAR );
			PRINT 'Error message' + CAST(ERROR_STATE() AS NVARCHAR );
			PRINT '=============================================================';
		END CATCH
	
END


-----------------------------------------------------------------------------------------
--EXECUTION OF THE STORED PROCEDURE
-----------------------------------------------------------------------------------------

EXEC bronze.load_bronze
