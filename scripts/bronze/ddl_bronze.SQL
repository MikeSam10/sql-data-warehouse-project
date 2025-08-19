/*SCRIPT PURPOSE;
    The purpose of this script is to create tables for the Bronze layer of the Database 




*/

CREATE TABLE bronze.crm_cust_info (
cst_id INT,
cst_key NVARCHAR (50),
cst_firstname NVARCHAR (50),
cst_lastname NVARCHAR (50),
cst_marital_status NVARCHAR (50),
cst_gndr NVARCHAR (50),
cst_create_date DATE
)

CREATE TABLE bronze.crm_prd_info (
prd_id INT,
prd_key NVARCHAR (50),
prd_nm NVARCHAR (50),
prd_cost INT,
prd_line NVARCHAR (50),
prd_start_dt DATETIME,
prd_end_dt DATETIME
)


CREATE TABLE bronze.crm_sls_details(
sls_ord_num NVARCHAR(50),
sls_prd_key NVARCHAR(50),
sls_cust_id INT,
sls_order_dt INT,
sls_ship_dt INT,
sls_due_dt INT,
sls_sales INT,
sls_quantity INT,
sls_price INT
)

CREATE TABLE bronze.erp_CUST_az12(
cid NVARCHAR(50),
bdate DATE,
gen NVARCHAR(50)
)

CREATE TABLE bronze.erp_LOC_A101(
CID NVARCHAR (50),
CNTRY NVARCHAR(50)
)

CREATE TABLE bronze.erp_PX_CAT_G1V2(
ID NVARCHAR(50),
CAT NVARCHAR(50),
SUBCAT NVARCHAR (50),
MAINTENANCE NVARCHAR (50)
)
