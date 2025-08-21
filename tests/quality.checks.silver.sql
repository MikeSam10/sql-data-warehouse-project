/*
=============================================================================================
THIS QUERY SHOWS THE QUALITY CHECKS DONE ON THE BRONZE TABLES 
 THAT WERE THEN LOADED ONTO THE SILVER TABLES
=============================================================================================

*/
---------------------------------------------------------------------------------------------
-- QUALITY CHECK DONE ON THE crm._prd_info
---------------------------------------------------------------------------------------------
-- Quality Checks
-- Check for Nulls or Duplicates in Primary key
-- Expectation: No Result
SELECT
prd_id,
COUNT(*)
FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL

-- Ceck for unwanted spaces
-- Expectation: No Results
SELECT prd_nm
FROM bronze.crm_prd_info
WHERE prd_nm != TRIM (prd_nm)

--Check For Nulls or Negative Numbers
--Expectation: No Results
SELECT prd_cost
FROM bronze.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL

--Data Standardization & consistency
SELECT DISTINCT prd_line
FROM silver.crm_prd_info

--Check for Invalid Orders
SELECT *
FROM bronze.crm_prd_info
WHERE prd_end_dt < prd_start_dt

---------------------------------------------------------------------------------------------
-- QUALITY CHECK DONE ON THE crm_sls_details
---------------------------------------------------------------------------------------------
-- Check for Invalid dates
SELECT NULLIF(sls_order_dt,0) sls_order_dt
FROM bronze.crm_sls_details
WHERE sls_order_dt <= 0 OR LEN(sls_order_dt) != 8

--Check for Invalid date Orders
SELECT
*
FROM bronze.crm_sls_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt

--Check Data Consistency: Between Sales, Quanity and Price
-- >> Sales = Quantity * price
-- >> Values must not be NULL, zero or negative.

SELECT DISTINCT
sls_sales AS old_sls_sales,
sls_quantity,
sls_price AS old_sls_price,
CASE WHEN sls_sales IS NULL OR sls_sales <=0 OR sls_sales != sls_quantity * ABS(sls_price)
		THEN sls_quantity * ABS(sls_price)
	ELSE sls_sales
END AS sls_sales,

CASE WHEN sls_price IS NULL OR sls_price <=0
		THEN sls_sales / NULLIF(sls_quantity,0)
	ELSE sls_price
END AS sls_price
FROM bronze.crm_sls_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0 
ORDER BY sls_sales, sls_quantity, sls_price


---------------------------------------------------------------------------------------------
-- QUALITY CHECK DONE ON THE erp_cust_az12
---------------------------------------------------------------------------------------------
-- Identify Out of Range Dates

SELECT DISTINCT
bdate
FROM silver.erp_CUST_AZ12 
WHERE bdate < '1924-01-01' OR bdate > GETDATE()

-- Data Standardization & Consistency
SELECT DISTINCT 
gen,
CASE WHEN UPPER(TRIM(GEN)) IN ('F', 'Female') THEN 'Female'
	 WHEN UPPER(TRIM(GEN)) IN ('M', 'Male') THEN 'Male'
	 ELSE 'n/a'
END gen
FROM bronze.erp_cust_az12
