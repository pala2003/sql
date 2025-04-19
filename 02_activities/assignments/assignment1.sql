/* ASSIGNMENT 1 */
/* SECTION 2 */


--SELECT
/* 1. Write a query that returns everything in the customer table. */

Select * 
from customer;



/* 2. Write a query that displays all of the columns and 10 rows from the cus- tomer table, 
sorted by customer_last_name, then customer_first_ name. */

select customer_id, customer_first_name, customer_last_name, customer_postal_code
from customer 
order by  customer_last_name, customer_first_name
limit 10;

--WHERE
/* 1. Write a query that returns all customer purchases of product IDs 4 and 9. */
-- option 1
select * from 
customer_purchases
where product_id = 4 or product_id = 9;

-- option 2

select * from 
customer_purchases
where product_id in (4,9);

/*2. Write a query that returns all customer purchases and a new calculated column 'price' (quantity * cost_to_customer_per_qty), 
filtered by vendor IDs between 8 and 10 (inclusive) using either:
	1.  two conditions using AND
	2.  one condition using BETWEEN
*/
-- option 1
/*
the below one is all customer purchases with respect to a product. So, I use SUM
*/
Select DISTINCT c.customer_id, c.customer_first_name || " "  || c.customer_last_name as customer_name , p.product_name , sum((quantity * cost_to_customer_per_qty)) as price
from customer c INNER JOIN
customer_purchases cp on c.customer_id = cp.customer_id
INNER JOIN product p on cp.product_id = p.product_id
where cp.vendor_id >= 8 and cp.vendor_id <= 10
Group by  c.customer_id, cp.product_id 
order by c.customer_id;

/*
the below one is all customer purchases with respect total purchase. So, I use SUM
*/
Select  c.customer_id, c.customer_first_name || " "  || c.customer_last_name as customer_name, sum((quantity * cost_to_customer_per_qty) ) as price
from customer c INNER JOIN
customer_purchases cp on c.customer_id = cp.customer_id
where cp.vendor_id >= 8 and cp.vendor_id <= 10
Group by  c.customer_id
order by c.customer_id;


-- option 2

Select DISTINCT c.customer_id, c.customer_first_name || " "  || c.customer_last_name as customer_name , p.product_name , sum((quantity * cost_to_customer_per_qty)) as price
from customer c INNER JOIN
customer_purchases cp on c.customer_id = cp.customer_id
INNER JOIN product p on cp.product_id = p.product_id
where cp.vendor_id  BETWEEN 8 AND 10
Group by  c.customer_id, cp.product_id 
order by c.customer_id;

Select  c.customer_id, c.customer_first_name || " "  || c.customer_last_name as customer_name, sum((quantity * cost_to_customer_per_qty) ) as price
from customer c INNER JOIN
customer_purchases cp on c.customer_id = cp.customer_id
where cp.vendor_id  BETWEEN 8 AND 10
Group by  c.customer_id
order by c.customer_id;

--CASE
/* 1. Products can be sold by the individual unit or by bulk measures like lbs. or oz. 
Using the product table, write a query that outputs the product_id and product_name
columns and add a column called prod_qty_type_condensed that displays the word “unit” 
if the product_qty_type is “unit,” and otherwise displays the word “bulk.” */
Select product_id, product_name, 
case 
	when product_qty_type = 'unit' then "unit"
	else "bulk"
	end as prod_qty_type_condensed

from product 
order by product_id;


/* 2. We want to flag all of the different types of pepper products that are sold at the market. 
add a column to the previous query called pepper_flag that outputs a 1 if the product_name 
contains the word “pepper” (regardless of capitalization), and otherwise outputs 0. */
Select product_id, product_name, 
CASE 
	WHEN product_qty_type = 'unit' THEN "unit"
	ELSE "bulk"
	END as prod_qty_type_condensed,
CASE
	WHEN lower(product_name) like '%pepper%' THEN 1
	ELSE 0 
	END as pepper_flag
from product 
order by product_id;


--JOIN
/* 1. Write a query that INNER JOINs the vendor table to the vendor_booth_assignments table on the 
vendor_id field they both have in common, and sorts the result by vendor_name, then market_date. */

SELECT DISTINCT v.vendor_id, v.vendor_name, v.vendor_type, vbs.market_date

from vendor  v INNER JOIN
vendor_booth_assignments vbs
on v.vendor_id = vbs.vendor_id
order by v.vendor_name, vbs.market_date;



/* SECTION 3 */

-- AGGREGATE
/* 1. Write a query that determines how many times each vendor has rented a booth 
at the farmer’s market by counting the vendor booth assignments per vendor_id. */

SELECT DISTINCT v.vendor_id, v.vendor_name,  vbs.booth_number, count(*) as count_rent

from vendor  v INNER JOIN
vendor_booth_assignments vbs
on v.vendor_id = vbs.vendor_id
group by v.vendor_id, vbs.booth_number
order by v.vendor_name,vbs.booth_number;

/* 2. The Farmer’s Market Customer Appreciation Committee wants to give a bumper 
sticker to everyone who has ever spent more than $2000 at the market. Write a query that generates a list 
of customers for them to give stickers to, sorted by last name, then first name. 

HINT: This query requires you to join two tables, use an aggregate function, and use the HAVING keyword. */

Select  c.customer_id, c.customer_first_name , c.customer_last_name as customer_name, round(sum((quantity * cost_to_customer_per_qty) ),2) as price
from customer c INNER JOIN
customer_purchases cp on c.customer_id = cp.customer_id
Group by  c.customer_id
having  price > 2000
order by c.customer_last_name, c.customer_first_name ;



--Temp Table
/* 1. Insert the original vendor table into a temp.new_vendor and then add a 10th vendor: 
Thomass Superfood Store, a Fresh Focused store, owned by Thomas Rosenthal

HINT: This is two total queries -- first create the table from the original, then insert the new 10th vendor. 
When inserting the new vendor, you need to appropriately align the columns to be inserted 
(there are five columns to be inserted, I've given you the details, but not the syntax) 

-> To insert the new row use VALUES, specifying the value you want for each column:
VALUES(col1,col2,col3,col4,col5) 
*/

DROP TABLE IF EXISTS temp.new_vendor;

CREATE TEMP TABLE  temp.new_vendor as
Select * from vendor;

INSERT INTO  temp.new_vendor(vendor_id,vendor_name,vendor_type, vendor_owner_first_name, vendor_owner_last_name)
VALUES(10,"Thomass Superfood Store","A Fresh Focused store","Thomas","Rosenthal");

select * from temp.new_vendor;

-- Date
/*1. Get the customer_id, month, and year (in separate columns) of every purchase in the customer_purchases table.

HINT: you might need to search for strfrtime modifers sqlite on the web to know what the modifers for month 
and year are! */

Select customer_id, transaction_time, STRFTIME('%m',market_date) as Month, STRFTIME('%Y',market_date) as Year, product_id, quantity
from customer_purchases
order by customer_id;

/* 2. Using the previous query as a base, determine how much money each customer spent in April 2022. 
Remember that money spent is quantity*cost_to_customer_per_qty. 

HINTS: you will need to AGGREGATE, GROUP BY, and filter...
but remember, STRFTIME returns a STRING for your WHERE statement!! */

Select customer_id, STRFTIME('%m',market_date) as Month, STRFTIME('%Y',market_date) as Year, round(sum(quantity*cost_to_customer_per_qty),2) as total_purchase
from customer_purchases
group by customer_id, Month, Year
having Month = "04" and Year = "2022"
order by customer_id;

