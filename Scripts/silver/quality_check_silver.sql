/*
	Here I am using only 1 or 2 tables as example of for the checks neede.
	However, It can and it should be applied to all.
*/

-------------------------
-- check for duplicates -
-------------------------
select cst_id, count(*) as numOfDublicates
from bronze.crm_cust_info
group by cst_id
having count(*) > 1 or cst_id is null
------------------------------------------
with recentDuplicate
as
(
	select *, ROW_NUMBER() over(partition by cst_id order by cst_create_date desc) as mostRecent
	from bronze.crm_cust_info
)
select * from recentDuplicate where mostRecent != 1


------------------------------
-- check for unwanted spaces -
------------------------------
select cst_firstname, len(cst_firstname) as numOfChars
from bronze.crm_cust_info
where cst_firstname != trim(cst_firstname)


--------------------------
-- check for consistency -
--------------------------
select distinct cst_gndr
from bronze.crm_cust_info
--------------------------------------
select distinct cst_marital_status
from bronze.crm_cust_info


------------------
-- Cleaning Data -
------------------
with latestDuplicate
as
(
	select *, ROW_NUMBER() over(partition by cst_id order by cst_create_date desc) as mostRecent
	from bronze.crm_cust_info
	where cst_id is not null
)
select
	cst_id,
	cst_key,
	trim(cst_firstname) as cst_firstname,
	trim(cst_lastname) as cst_lastname,
	case 
		when upper(trim(cst_marital_status)) = 'S' then 'Single'
		when upper(trim(cst_marital_status)) = 'M' then 'Married'
		else 'n/a'
	end as cst_marital_status,
	case 
		when upper(trim(cst_gndr)) = 'F' then 'Female'
		when upper(trim(cst_gndr)) = 'M' then 'Male'
		else 'n/a'
	end as cst_gndr,
	cst_create_date
from latestDuplicate
where mostRecent = 1
