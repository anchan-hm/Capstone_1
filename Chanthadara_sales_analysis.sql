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

-- calculating the online revenue
SELECT SUM(SalesTotal) AS Online_Revenue,  -- taking the online revenue and adding it
		MIN(Date) AS O_Start_Date, -- grabbing from the oldest date
        MAX(Date) AS O_End_Date  -- grabbing from recent date
FROM online_sales
WHERE ShiptoState = 'Texas';
/* start date: 2011-01-01, end date: 2025-12-31, revenue = 4791279.34 */

-- calculating in store revenue
SELECT SUM(ss.Sale_Amount) AS InStore_Rev,  -- adding total revenue for in store
		MIN(ss.Transaction_Date) AS IS_Start_Date,  -- grabbing from oldest date
        MAX(ss.Transaction_Date) AS IS_End_Date -- grabbing from recent date
FROM store_sales AS ss -- alias
JOIN store_locations AS sl -- alias
	ON ss.Store_ID = sl.StoreId  -- joining on them to match IDs
WHERE sl.State = 'Texas';
/* start date: 2022-01-01, end date: 2025-12-31, revenue = 3417850.01 */

-- adding both to create the TOTAL revenue
SELECT SUM(Total_Revenue) AS Total_Revenue, -- TOTAL revenue for Texas
		MIN(Start_Date) AS Start_Date, -- grabbing oldest date from both tables
        MAX(End_Date) AS End_Date    -- grabbing recent date from both
FROM (SELECT SUM(ss.Sale_Amount)  -- creating subquery 
		AS Total_Revenue,
        MIN(ss.Transaction_Date)  -- TOTAL sales info for in store
        AS Start_Date,
        MAX(ss.Transaction_Date)
        AS End_Date
FROM store_sales AS ss
JOIN store_locations AS sl 
	ON ss.Store_ID = sl.StoreId
WHERE sl.State = 'Texas'
UNION ALL         -- stacking both tables
SELECT SUM(SalesTotal),
		MIN(Date),    -- TOTAL sales for online
        MAX(Date)
FROM online_sales
WHERE ShiptoState = 'Texas')
AS combined; -- combining them into one output
/* start date: 2022-01-01, end date: 2025-12-31, revenue = 8209129.35 */

/*========================================================================================*/

/* QUESTION 2: What is the month by month revenue breakdown for the sales territory? */

-- creating month by month sales
SELECT YEAR(Sale_Date) AS Year,  -- making year for sale
		MONTH(Sale_Date) AS Month,  -- making month for sale
        SUM(Revenue) AS Total_Revenue  -- adding the total revenue 
FROM (SELECT ss.Transaction_Date AS Sale_Date, -- renaming and grabbing in store sales
		ss.Sale_Amount AS revenue   -- having the amount of revenue of each sale
FROM store_sales AS ss
JOIN store_locations AS sl
	ON ss.Store_ID = sl.StoreId -- matching the IDs
WHERE sl.State = 'Texas'  -- ensuring that I look at only Texas
UNION ALL      -- stacking both online and in store sales
SELECT o.Date AS Sale_Date,   -- now grabbing online sale date
		o.SalesTotal AS Revenue
FROM online_sales AS o
WHERE o.ShiptoState = 'Texas')  -- making sure it is Texas
AS all_sales
GROUP BY YEAR(Sale_Date), MONTH(Sale_Date) -- grouping years and months
ORDER BY Year, Month;    -- sorting from oldest to newest
/* 130 RECORDS Returned */

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
FROM (SELECT 'Texas' AS Location, -- first part for Texas
		ss.Sale_Amount AS Revenue -- grabbing revenue for in store
FROM store_sales AS ss
JOIN store_locations AS sl
	ON ss.Store_ID = sl.StoreId
WHERE sl.State = 'Texas'
UNION ALL -- stacking in store and online
SELECT 'Texas' AS Location, -- last part for Texas
		o.SalesTotal AS Revenue -- grabbing revenue for online
FROM online_sales AS o
WHERE o.ShiptoState = 'Texas'
UNION ALL -- stacking Texas to the rest of South
SELECT m.Region AS Location, -- the South region
		ss.Sale_Amount AS Revenue -- in store revenues
FROM store_sales AS ss
JOIN store_locations AS sl
	ON ss.Store_ID = sl.StoreId
JOIN management AS m -- new alias to keep track
	ON sl.State = m.State -- joining state info from both tables
WHERE m.Region = (SELECT Region
				FROM management  -- ensuring to grab region
                WHERE State = 'Texas')
UNION ALL -- stacking to last part of South region
SELECT m.Region AS Location,
		o.SalesTotal AS Revenue -- grabbing online revenues
FROM online_sales AS o 
JOIN management AS m
	ON o.ShiptoState = m.State -- joining state from tables
WHERE m.Region = (SELECT Region
				FROM management
                WHERE State = 'Texas'))
AS combined -- combine into one table
GROUP BY Location;
/* Texas = 8209129.35, South = 15641639.89 */

/*===================================================================================*/

/* QUESTION 4: What is the number of transactions per month and average transaction
size by product category for the sales territory? */

-- finding the average sale amount for Texas
SELECT YEAR(Sale_Date) AS Year,  -- creating year of sale
		MONTH (Sale_Date) AS Month,  -- creating month of sale
        Category,     -- category of product
        COUNT(*) AS Number_of_Transactions,  -- counting transactions
        AVG(Revenue) AS Avg_Transaction -- average amount of sale
FROM (SELECT ss.Transaction_Date -- renaming and grabbing sales for in store
		AS Sale_Date,     -- date of sale
        ss.Sale_Amount
        AS Revenue,    -- sale amount
        c.Category
        AS Category -- category of product
FROM store_sales AS ss
JOIN store_locations AS sl
	ON ss.Store_ID = sl.StoreId -- matching store to location
JOIN products AS p -- new alias 
	ON ss.Prod_Num = p.ProdNum -- matching products from two tables
JOIN inventory_categories AS c -- new alias
	ON p.Categoryid = c.Categoryid -- pulling names for category
WHERE sl.State = 'Texas'
UNION ALL -- stacking in store to online
SELECT o.Date AS Sale_Date,  -- online sale date
		o.SalesTotal AS Revenue, -- online amount of sale
        c.Category AS Category -- category of product
FROM online_sales AS o
JOIN products AS p
	ON o.ProdNum = p.ProdNum -- matching products
JOIN inventory_categories AS c
	ON p.Categoryid = c.Categoryid -- pulling names for category
WHERE o.ShiptoState = 'Texas')
AS all_sales   -- combining all sales
GROUP BY YEAR(Sale_Date),
		MONTH(Sale_Date),
        Category
ORDER BY Year,
		Month,
        Category;
/* 288 RECORDS Returned */

/*==========================================================================================*/

/* QUESTION 5: Can you provide a ranking of in-store sales performance by each store in the 
sales territory, or a ranking of online sales performance by state 
within an online sales territory? */