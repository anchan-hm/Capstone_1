USE sample_sales; -- using schema

/*=============================================================================================*/

/*QUESTION 1: What is total revenue overall for sales in the assigned territory, 
plus the start date and end date that tell you what period the data covers?*/

-- specific info of manager for Texas to have quick access
SELECT State,
		Region,      -- including all columns from table
        SalesManager,
        RegionalDirector
FROM management      -- table that has manager info
WHERE State = 'Texas';  -- the state that my manager is
/* Texas, South, Jeff "Howdy" Richards, Andy Gisselquist*/

-- calculating in store revenue
SELECT SUM(ss.Sale_Amount) AS InStore_Rev,  -- adding total revenue for in store
		MIN(ss.Transaction_Date) AS IS_Start_Date,  -- grabbing from oldest date
        MAX(ss.Transaction_Date) AS IS_End_Date -- grabbing from recent date
FROM store_sales AS ss -- alias
JOIN store_locations AS sl -- alias
	ON ss.Store_ID = sl.StoreId  -- joining on them to match IDs
WHERE sl.State = 'Texas';
/* start date: 2022-01-01, end date: 2025-12-31, revenue = 3417850.01 */

/*========================================================================================*/

/* QUESTION 2: What is the month by month revenue breakdown for the sales territory? */

-- creating month by month sales
SELECT YEAR(ss.Transaction_Date) AS Year,  -- making year for sale
		MONTH(ss.Transaction_Date) AS Month,  -- making month for sale
        SUM(ss.Sale_Amount) AS Total_Revenue  -- adding the total revenue 
FROM store_sales AS ss
JOIN store_locations AS sl
	ON ss.Store_ID = sl.StoreId -- matching the IDs
WHERE sl.State = 'Texas'  -- ensuring that I look at only Texas
GROUP BY YEAR(ss.Transaction_Date), MONTH(ss.Transaction_Date) -- grouping years and months
ORDER BY Year, Month;    -- sorting from oldest to newest
/* 48 RECORDS Returned */

/*=====================================================================================*/

/* QUESTION 3: Provide a comparison of total revenue for the specific sales territory
and the region it belongs to. */

-- region that Texas is in
SELECT Region  -- column name
FROM management  -- table
WHERE State = 'Texas';  -- making sure it's Texas
/* Region = South */

-- Texas compared to whole region
SELECT Location,  --  will be either Texas or South
		SUM(Revenue)  -- revenue of each
		AS Total_Revenue  -- total of each
FROM (SELECT 'Texas' AS Location, -- locating revenue for Texas
		ss.Sale_Amount AS Revenue -- grabbing revenue in store (Texas)
FROM store_sales AS ss
JOIN store_locations AS sl
	ON ss.Store_ID = sl.StoreId
WHERE sl.State = 'Texas'
UNION ALL -- stacking in store revenue (Texas/South)
SELECT m.Region AS Location, -- locating revenue for South
		ss.Sale_Amount AS Revenue -- grabbing revenue for South
FROM store_sales AS ss
JOIN store_locations AS sl
	ON ss.Store_ID = sl.StoreId
JOIN management AS m 
	ON sl.State = m.State  -- joining each store to region
WHERE m.Region =(SELECT Region
				FROM management
                WHERE State = 'Texas'))
AS combined
GROUP BY Location;
/* Texas = 3417850.01, South = 7996850.12 */

/*===================================================================================*/

/* QUESTION 4: What is the number of transactions per month and average transaction
size by product category for the sales territory? */

-- finding the average sale amount for Texas
SELECT YEAR(ss.Transaction_Date) AS Year,  -- creating year of sale
		MONTH (ss.Transaction_Date) AS Month,  -- creating month of sale
        ic.Category AS Category,     -- category of product
        COUNT(*) AS Number_of_Transactions,  -- counting transactions
        AVG(ss.Sale_Amount) AS Avg_Transaction -- average amount of sale
FROM store_sales AS ss
JOIN store_locations AS sl
	ON ss.Store_ID = sl.StoreId -- matching store to location
JOIN products AS p -- new alias 
	ON ss.Prod_Num = p.ProdNum -- matching products from two tables
JOIN inventory_categories AS ic -- new alias
	ON p.Categoryid = ic.Categoryid -- pulling names for category
WHERE sl.State = 'Texas'
GROUP BY YEAR(ss.Transaction_Date),
		MONTH(ss.Transaction_Date),  -- grouping
        ic.Category
ORDER BY Year, Month, Category;  -- clean order
/* 288 RECORDS Returned */

/*==========================================================================================*/

/* QUESTION 5: Can you provide a ranking of in-store sales performance by each store in the 
sales territory, or a ranking of online sales performance by state 
within an online sales territory? */

-- pulling in stores' sales performance
SELECT sl.StoreId,     -- establishing store IDs
		sl.StoreLocation,  -- location of each store
        SUM(ss.Sale_Amount) AS Total_Revenue -- grabbing total revenue for each store
FROM store_sales AS ss
JOIN store_locations AS sl
	ON ss.Store_ID = sl.StoreId  -- matching the stores to sales
WHERE sl.State = 'Texas'   -- ensuring the stores are in my territory
GROUP BY sl.StoreId, sl.StoreLocation  -- grouping total revenue to their stores
ORDER BY Total_revenue DESC;  -- ranking by ordering highest to lowest
/* 11 RECORDS Returned */

/*==============================================================================================*/

/* QUESTION 6: What is your recommendation for where to focus sales attention in the next quarter? */

/* Based on previous questions, I would recommend focusing on Beaumont location, because
it is ranked first in Texas for revenue. I came to this conclusion because, there was a large gap
between first and second place (question 5); displaying that the other stores are being greatly 
outperformed, and that the Beaumont location is doing something right. When comparing Texas to the 
rest of the South region, Texas' numbers are less than half of the South (question 3). We can also
look into Technology & Accessories, because they have the highest average of transactions of
products (question 4) in Texas. Reviewing the yearly/monthly revenue for Texas (question 2), I have
discovered that throughout the year it is steady and increases each year; allowing an opportunity to
focus on using methods that work for Beaumont on other stores can potentially help improve revenue 
for the state. */