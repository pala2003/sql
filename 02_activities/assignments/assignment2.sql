/* ASSIGNMENT 2 */
/* SECTION 2 */

-- COALESCE
/* 1. Our favourite manager wants a detailed long list of products, but is afraid of tables! 
We tell them, no problem! We can produce a list with all of the appropriate details. 

Using the following syntax you create our super cool and not at all needy manager a list: 

SELECT 
product_name || ', ' || product_size|| ' (' || product_qty_type || ')' as product_details
FROM product

 But wait! The product table has some bad data (a few NULL values). 
Find the NULLs and then using COALESCE, replace the NULL with a 
blank for the first problem, and 'unit' for the second problem. 

HINT: keep the syntax the same, but edited the correct components with the string. 
The `||` values concatenate the columns into strings. 
Edit the appropriate columns -- you're making two edits -- and the NULL rows will be fixed. 
All the other rows will remain the same.) */

SELECT 
	product_name || ', ' || COALESCE(product_size,'')|| ' (' || COALESCE(product_qty_type,'unit') || ')' as product_details
FROM product;


--Windowed Functions
/* 1. Write a query that selects from the customer_purchases table and numbers each customer’s  
visits to the farmer’s market (labeling each market date with a different number). 
Each customer’s first visit is labeled 1, second visit is labeled 2, etc. 

You can either display all rows in the customer_purchases table, with the counter changing on
each new market date for each customer, or select only the unique market dates per customer 
(without purchase details) and number those visits. 
HINT: One of these approaches uses ROW_NUMBER() and one uses DENSE_RANK(). */

select DISTINCT
	customer_id, market_date
	, row_number() over(PARTITION by customer_id order by market_date ASC) as [number of visit]
	, dense_rank() OVER(order by customer_id, market_date ASC) as [Number of visit by marketDate]
FROM
	customer_purchases;
	
select DISTINCT
	customer_id, market_date
	, dense_rank() OVER(PARTITION by market_date) as [Number of visit by marketDate]
FROM
	customer_purchases;


/* 2. Reverse the numbering of the query from a part so each customer’s most recent visit is labeled 1, 
then write another query that uses this one as a subquery (or temp table) and filters the results to 
only the customer’s most recent visit. */


Select *
from 
(
select DISTINCT
	customer_id, market_date
	, row_number() over(PARTITION by customer_id order by market_date DESC) as [latest_visit]
FROM
	customer_purchases
) X
where X.latest_visit = 1;


/* 3. Using a COUNT() window function, include a value along with each row of the 
customer_purchases table that indicates how many different times that customer has purchased that product_id. */

select DISTINCT
	customer_id, product_id
	, count( product_id) over(PARTITION by customer_id,product_id) as [numberOfPurcahsed]
	, market_date, quantity, cost_to_customer_per_qty, vendor_id, transaction_time

FROM
	customer_purchases;

-- EXTRA to understand: we can verify the customer and product purchased number by below query as well.
select DISTINCT
	customer_id, product_id
	, count( product_id) over(PARTITION by customer_id,product_id) as [numberOfPurcahsed]

FROM
	customer_purchases;
	

-- String manipulations
/* 1. Some product names in the product table have descriptions like "Jar" or "Organic". 
These are separated from the product name with a hyphen. 
Create a column using SUBSTR (and a couple of other commands) that captures these, but is otherwise NULL. 
Remove any trailing or leading whitespaces. Don't just use a case statement for each product! 

| product_name               | description |
|----------------------------|-------------|
| Habanero Peppers - Organic | Organic     |

Hint: you might need to use INSTR(product_name,'-') to find the hyphens. INSTR will help split the column. */

Select *
	,  CASE 
			WHEN (INSTR(product_name,"-") > 0)
				THEN rtrim(ltrim(substr(product_name,INSTR(product_name,"-")+1 )))
		ELSE 
			NULL
		END as product_type
FROM
	product;
	
/* 2. Filter the query to show any product_size value that contain a number with REGEXP. */

Select *
	,  CASE 
			WHEN (INSTR(product_name,"-") > 0)
				THEN rtrim(ltrim(substr(product_name,INSTR(product_name,"-")+1 )))
		ELSE 
			NULL
		END as product_type
FROM
	product
Where 
	product_size  REGEXP  '\d';

-- UNION
/* 1. Using a UNION, write a query that displays the market dates with the highest and lowest total sales.

HINT: There are a possibly a few ways to do this query, but if you're struggling, try the following: 
1) Create a CTE/Temp Table to find sales values grouped dates; 
2) Create another CTE/Temp table with a rank windowed function on the previous query to create 
"best day" and "worst day"; 
3) Query the second temp table twice, once for the best day, once for the worst day, 
with a UNION binding them. */


WITH best_worst_day as
(
WITH market_date_sales as
(
Select 
	market_date
	, Sum(quantity*cost_to_customer_per_qty) as total_sales
FROM
	customer_purchases
Group By market_date
order by total_sales desc
) 
select 
	market_date
	,total_sales
	,row_number() OVER (order by total_sales DESC) as best_day
	,row_number()  OVER( order by total_sales ASC) as worst_day
from market_date_sales

)

select 
	market_date
	, total_sales 
	, "best day" as best_worst_day
	from best_worst_day
where best_day = 1 

union 

select 
	market_date
	, total_sales 
	, "worst day" as best_worst_day
	from best_worst_day
where worst_day = 1; 

/*	
I have one doubt, why we need to use union where as we can use the below case sectin to find worst and best day as well.
, CASE 
		WHEN best_day = 1 THEN "best day"
		ELSE "worts day"
	END as sales_day
	from best_worst_day
where best_day = 1 or worst_day = 1;*/


/* SECTION 3 */

-- Cross Join
/*1. Suppose every vendor in the `vendor_inventory` table had 5 of each of their products to sell to **every** 
customer on record. How much money would each vendor make per product? 
Show this by vendor_name and product name, rather than using the IDs.

HINT: Be sure you select only relevant columns and rows. 
Remember, CROSS JOIN will explode your table rows, so CROSS JOIN should likely be a subquery. 
Think a bit about the row counts: how many distinct vendors, product names are there (x)?
How many customers are there (y). 
Before your final group by you should have the product of those two queries (x*y).  */
select
vendor_name
,product_name
, sum(quantity*original_price) as total_sales_each_customer_by_5_unit
from 
(
(Select  DISTINCT
	vi.vendor_id
	,vi.product_id
	,vendor_name
	,product_name
	, 5 as quantity
	, original_price
FROM
	vendor_inventory vi
	join vendor v
		on vi.vendor_id = v.vendor_id
	join product p 
		on vi.product_id = p.product_id
)  vendor_product
CROSS JOIN

 ( Select DISTINCT
	customer_id
	,customer_first_name || " " || customer_last_name as customer_name
FROM
	customer )  customer_list 
)  vendor_product_per_customer
group by vendor_product_per_customer.vendor_id, vendor_product_per_customer.product_id;

-- INSERT
/*1.  Create a new table "product_units". 
This table will contain only products where the `product_qty_type = 'unit'`. 
It should use all of the columns from the product table, as well as a new column for the `CURRENT_TIMESTAMP`.  
Name the timestamp column `snapshot_timestamp`. */


/** ********* NOTE : if you are executing at one go it will delete every row as Create Tables timestamp and new updated insert has the exact same time stamp...
SO I am Using strftime('%Y-%m-%d %H:%M:%f', 'now') instead of CURRENT_TIMESTAMP
***********************************************************************************************/
DROP TABLE IF EXISTS product_units;
CREATE TABLE IF NOT EXISTS product_units as
select *
, strftime('%Y-%m-%d %H:%M:%f', 'now') AS snapshot_timestamp
from 
	product
WHERE
	product_qty_type ="unit";
	
Select * from product_units order by product_id;


/*2. Using `INSERT`, add a new row to the product_units table (with an updated timestamp). 
This can be any product you desire (e.g. add another record for Apple Pie). */

INSERT into product_units values (10,"Eggs", "2 dozon",	7,	"unit",	strftime('%Y-%m-%d %H:%M:%f', 'now'));
Select * from product_units order by product_id;


-- DELETE
/* 1. Delete the older record for the whatever product you added. 

HINT: If you don't specify a WHERE clause, you are going to have a bad time.*/
/** ********* NOTE : if you are executing at one go it will delete every row as Create Tables timestamp and new updated insert has the exact same time stamp**/
DELETE from product_units where product_id = 10 and snapshot_timestamp not in (select max(snapshot_timestamp) from product_units);
Select * from product_units order by product_id;


-- UPDATE
/* 1.We want to add the current_quantity to the product_units table. 
First, add a new column, current_quantity to the table using the following syntax.

ALTER TABLE product_units
ADD current_quantity INT;

Then, using UPDATE, change the current_quantity equal to the last quantity value from the vendor_inventory details.

HINT: This one is pretty hard. 
First, determine how to get the "last" quantity per product. 
Second, coalesce null values to 0 (if you don't have null values, figure out how to rearrange your query so you do.) 
Third, SET current_quantity = (...your select statement...), remembering that WHERE can only accommodate one column. 
Finally, make sure you have a WHERE statement to update the right row, 
	you'll need to use product_units.product_id to refer to the correct row within the product_units table. 
When you have all of these components, you can run the update statement. */


ALTER TABLE product_units
ADD current_quantity INT;

select * from vendor_inventory ;

