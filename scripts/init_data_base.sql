/*
==============================================================================
Create Database named data_warehoure and Schemas
==============================================================================

Script Purpose;
	This Script creates a new database after checking if the database data_warehouse is
	present.If present the database is dropped and recreated to a new database. Also new Schemas 
	were created within the database: bronze, silver and gold.

WARNING:
	Runnung this Script will drop the entire 'data_warehouse' database if it exists.
	All data in the database will be permanently deketed. Proceed with caution and ensure 
	you have proper bacjups before running this script.

*/




USE master;
GO
--Dropping and recreating the data base
IF EXISTS ( SELECT 1 FROM sys.databases WHERE name = 'data_warehouse')
	BEGIN 
		ALTER DATABASE data_warehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
		DROP DATABASE data_warehouse
	END;
GO



--Create Database 'data warehouse'
CREATE DATABASE data_warehouse;
GO


USE data_warehouse;
GO



--Create SCHEMAS
CREATE SCHEMA bronze;
GO




CREATE SCHEMA silver;
GO





CREATE SCHEMA gold;
GO
