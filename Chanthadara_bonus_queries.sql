USE sample_sales;  -- using schema

/*=====================================================================================================*/

/* SELECT, Filtering & Sorting */

/* QUESTION 1: Create a list of all transactions that took place on January 15, 2024, sorted by sale amount from
highest to lowest. */

-- list transactions on Jan 15, 2024
SELECT Transaction_Date AS Sale_Date,  
        Prod_Num AS ProdNum,   -- } info of in-store transaction
        Sale_Amount AS SaleAmount  -- amount per transaction
FROM store_sales  -- all in-store
WHERE Transaction_Date = '2024-01-15' -- ensuring precise date
UNION ALL -- stacking instore on online
SELECT Date AS Sale_Date,
		ProdNum,           -- } info of online transaction
        SalesTotal AS SaleAmount  -- amount per transaction
FROM online_sales
WHERE Date = '2024-01-15' -- matching date
ORDER BY SaleAmount DESC; -- ordering from highest to lowest
/* 310 RECORDS Returned */

/*========================================================================*/

/*QUESTION 2: Which transactions had a sale amount greater than $500? Display the transaction date, store ID,
product number, and sale amount. */

-- sale amount larger than $500
SELECT Transaction_Date AS Sale_Date,
		Prod_Num AS ProdNum,       -- } info of in-store transaction
        Sale_Amount AS SaleAmount  -- amount per transaction
FROM store_sales
WHERE Sale_Amount > 500  -- pull greater than $500
UNION ALL      -- stacking in-store to online
SELECT Date AS Sale_Date,
		ProdNum,        -- } info of online transaction
        SalesTotal AS SaleAmount  -- amount per transaction
FROM online_sales
WHERE SalesTotal > 500 -- matching to be greater than $500
ORDER BY SaleAmount DESC;
/* 49850 RECORDS Returned */

/*========================================================================*/

/* QUESTION 3: Find all products whose product number begins with the prefix 105250. What category do they
belong to? */

-- products beginning with 105250
SELECT p.ProdNum,
		p.Product,  -- } product info
        ic.Category  -- product category
FROM products AS p
JOIN inventory_categories AS ic
	ON p.CategoryID = ic.CategoryID -- matching the categories
WHERE p.ProdNum LIKE '105250%'; -- the prefix
/* Product: Realme Pad, Category: Technology & Accessories, ProdNum: 105250-IT */

/*=====================================================================================================*/

/* Aggregation */

/* QUESTION 4: What is the total sales revenue across all transactions? What is the average transaction amount? */

-- averaging ALL transactions
SELECT SUM(SaleAmount) AS Total_Revenue, -- pulling all transactions
		AVG(SaleAmount) AS Avg_Transaction -- averaging transactions
FROM (SELECT Sale_Amount AS SaleAmount
		FROM store_sales               -- } pulling in-store
UNION ALL  -- stacking in-store to online
SELECT SalesTotal AS SaleAmount
FROM online_sales)              -- } pulling online
AS all_sales;   -- putting all transactions together
/* Total Revenue = 113915957.75, Avg Transactions = 246.734759 */

/*========================================================================*/

/* QUESTION 5: How many transactions were recorded for each product category? Which category has the most
transactions? */

-- transactions per product category
SELECT ic.Category, -- category for products
		COUNT(*) AS Num_Transactions -- number of transactions
FROM (SELECT Prod_Num AS ProdNum
		FROM store_sales         -- } products from in-store
UNION ALL   -- stacking in-store to online
SELECT ProdNum
FROM online_sales)  -- } products from online
AS all_sales -- putting all transactions together
JOIN products AS p
	ON all_sales.ProdNum = p.ProdNum  -- matching the products
JOIN inventory_categories AS ic
	ON p.CategoryID = ic.CategoryID  -- pulling the categories
GROUP BY ic.Category   -- grouping each category
ORDER BY Num_Transactions DESC;  -- filtering highest to lowest
/* 6 RECORDS Returned */

/*========================================================================*/

/* QUESTION 6: Which store generated the highest total revenue? Which generated the lowest? */

-- total revenue per store
SELECT sl.StoreId,
		sl.StoreLocation,  -- } stores' info
        SUM(ss.Sale_Amount) AS Total_Revenue -- total revenue for each store
FROM store_sales AS ss
JOIN store_locations AS sl
	ON ss.Store_ID = sl.StoreId  -- matching stores
GROUP BY sl.StoreId,
		sl.StoreLocation -- grouping the stores
ORDER BY Total_Revenue DESC;  -- filtering highest to lowest
/* 111 RECORDS Returned */

/*========================================================================*/

/* QUESTION 7: What is the total revenue for each category, sorted from highest to lowest? */

-- total revenue for per category
SELECT ic.Category,
		SUM(all_sales.SaleAmount) AS Total_Revenue -- pulling total rev per category
FROM (SELECT Prod_Num AS ProdNum,
		Sale_Amount AS SaleAmount  -- } info from in-store
	FROM store_sales
UNION ALL   -- stacking in-store to online
SELECT ProdNum,
		SalesTotal AS SaleAmount  -- } info from online
	FROM online_sales)
AS all_sales  -- combinding all stores
JOIN products AS p
	ON all_sales.ProdNum = p.ProdNum -- matching to products
JOIN inventory_categories AS ic
	ON p.CategoryID = ic.CategoryID  -- matching to categories
GROUP BY ic.Category   -- grouping per category
ORDER BY Total_Revenue DESC;   -- filtering highest to lowest
/* 6 RECORDS Returned */

/*========================================================================*/

/* QUESTION 8: Which stores had total revenue above $50,000? (Hint: you'll need HAVING.) */

-- total revenue above $50,000
SELECT sl.StoreId,
		sl.StoreLocation,  -- in-store info
        SUM(ss.Sale_Amount) AS Total_Revenue -- total rev per location
FROM store_sales AS ss
JOIN store_locations AS sl
	ON ss.Store_ID = sl.StoreId  -- matching stores
GROUP BY sl.StoreId,
		sl.StoreLocation -- grouping per store
HAVING SUM(ss.Sale_Amount) > 50000  -- above $50,000
ORDER BY Total_Revenue DESC;  -- filtering highest to lowest

/*=====================================================================================================*/

/* Joins */

/* QUESTION 9: Find all sales records where the category is either "Textbooks" or "Technology & Accessories." */

-- 'TextBooks' or 'Tech'
SELECT all_sales.ProdNum,
		all_sales.SaleAmount,  -- } sales info
        ic.Category
FROM (SELECT Prod_Num AS ProdNum,
		Sale_Amount AS SaleAmount  -- } in-store info
FROM store_sales
UNION ALL   -- stacking in-store to online
SELECT ProdNum,
		SalesTotal AS SaleAmount -- } online info
FROM online_sales)
AS all_sales  -- combinding
JOIN products AS p
	ON all_sales.ProdNum = p.ProdNum -- matching products
JOIN inventory_categories AS ic
	ON p.CategoryID = ic.CategoryID -- matching categories
WHERE ic.Category IN ('Textbooks', 'Technology & Accessories'); -- selected search
/* 152519 RECORDS Returned */

/*========================================================================*/

/* QUESTION 10: List all transactions where the sale amount was between $100 and $200, and the category was
"Textbooks." */

-- 'Textbooks' between $100 and $200
SELECT all_sales.ProdNum,
		all_sales.SaleAmount, -- product info
        ic.Category
FROM (SELECT Prod_Num AS ProdNum,
		Sale_Amount AS SaleAmount -- } in-store info
FROM store_sales
UNION ALL -- stacking in-store to online
SELECT ProdNum,
		SalesTotal AS SaleAmount -- } online info
FROM online_sales)
AS all_sales   -- combinding sales
JOIN products AS p
	ON all_sales.ProdNum = p.ProdNum -- pulling product
JOIN inventory_categories AS ic
	ON p.CategoryID = ic.CategoryID  -- pulling categories
WHERE ic.Category = 'Textbooks'  -- selected category
	AND all_sales.SaleAmount
    BETWEEN 100 AND 200;  -- range
/* 25943 RECORDS Returned */

/*========================================================================*/

/* QUESTION 11: Write a query that displays each store's total sales along with the city and state where that store is
located. */

-- sales with city and state
SELECT sl.StoreId, 
		sl.StoreLocation, -- } store info with state & city
        sl.State,
        SUM(ss.Sale_Amount) AS Total_Sales -- revenue per store
FROM store_sales AS ss
JOIN store_locations AS sl
	ON ss.Store_ID = sl.StoreId -- matching stores by ID
GROUP BY sl.StoreId,
		sl.StoreLocation, -- grouping per store
        sl.State 
ORDER BY Total_Sales DESC; -- sorting highest to lowest
/* 111 RECORDS Returned */

/*========================================================================*/

/* QUESTION 12: For each sale, display the transaction date, sale amount, city, state, and the name of the store
manager responsible for that state. */

-- manager, location and date per sale
SELECT ss.Transaction_Date AS TransactionDate,
		ss.Sale_Amount AS SaleAmount,
        sl.StoreLocation,        -- } staging all information 
        sl.State,
        m.SalesManager
FROM store_sales AS ss
JOIN store_locations AS sl
	ON ss.Store_ID = sl.StoreId  -- matching in-store locations
JOIN management AS m
	ON sl.State = m.State   -- matching managers per location
ORDER BY ss.Transaction_Date;   -- filtering by dates
/* 335129 RECORDS Returned */

/*========================================================================*/

/* QUESTION 13: Write a query that shows total sales by region. Which region generates the most revenue? */

-- region with most revenue
SELECT m.Region,   -- pulling regions
		SUM(ss.Sale_Amount) AS Total_Sales -- total rev by region
FROM store_sales AS ss
JOIN store_locations AS sl
	ON ss.Store_ID = sl.StoreId  -- matching stores by state
JOIN management AS m
	ON sl.State = m.State   -- matching state by region
GROUP BY m.Region   -- grouping each region
ORDER BY Total_Sales DESC;  -- sorting most to least rev
/* Most Revenue: Northeast = 24237526.98 total sales */

/*========================================================================*/

/* QUESTION 14: For states that have a preferred shipper listed in Shipper_List, show the total sales alongside the
preferred shipper and volume discount. */

-- sales with shipper and discount
SELECT sl.State,
		SUM(ss.Sale_Amount) AS Total_Sales, -- revenue per state
        sh.PreferredShipper,   -- grabbing preferred shipper
        sh.VolumeDiscount   -- discount from shipper
FROM store_sales AS ss
JOIN store_locations AS sl
	ON ss.Store_ID = sl.StoreId  -- matching store locations
JOIN Shipper_List AS sh
	ON sl.State = sh.ShiptoState  -- matching shipper to states
GROUP BY sl.State,
		sh.PreferredShipper,  -- grouping shipper info together
        sh.VolumeDiscount
ORDER BY Total_Sales DESC;      -- sorting highest revenue
/* 10 RECORDS Returned */

/*========================================================================*/

/* QUESTION 15: Are there any states with sales data that do not appear in Shipper_List? */

-- states with sales but not on shipper list
SELECT DISTINCT sl.State  -- no duplicates
FROM store_sales AS ss
JOIN store_locations AS sl
	ON ss.Store_ID = sl.StoreId -- matching state sales
LEFT JOIN Shipper_List AS sh -- pulling more from shipper info
	ON sl.State = sh.ShiptoState -- matching shipper to state
WHERE sh.ShiptoState IS NULL  -- state sales not present in shipper list
ORDER BY sl.State;   -- sorting from largest sale to least
/* 0 RECORDS Returned, indicating that all state sales are present */

/*========================================================================*/

/* QUESTION 16: Display total revenue by regional director. */

-- Regional director per total revenue
SELECT m.RegionalDirector,
		SUM(ss.Sale_Amount) AS Total_Revenue -- total revenue per region
FROM store_sales AS ss
JOIN store_locations AS sl
	ON ss.Store_ID = sl.StoreId  -- matching store locations
JOIN management AS m
	ON sl.State = m.State  -- matching directors to locations
GROUP BY m.RegionalDirector
ORDER BY Total_Revenue DESC;  -- sorting highest revenue to lowest
/* 4 RECORDS Returned */

/*=====================================================================================================*/

/* Subqueries */

/* QUESTION 17: Using a subquery, find all transactions from stores located in Texas. */

-- Texas stores' transactions
SELECT * FROM store_sales
WHERE Store_ID
IN (SELECT StoreId  
	FROM store_locations  -- } pulling store location IDs
    WHERE State = 'Texas'); -- specify Texas locations
/* 24212 RECORDS Returned */

/*========================================================================*/

/* QUESTION 18: Which stores had total sales above the average store revenue? (Hint: use a subquery to calculate the
average first.) */

-- store sales above average revenue
SELECT sl.StoreId,
		sl.StoreLocation,     -- } pulling store info
        SUM(ss.Sale_Amount) AS Total_Revenue
FROM store_sales AS ss
JOIN store_locations AS sl
	ON ss.Store_ID = sl.StoreId -- matching store locations
GROUP BY sl.StoreId,
		sl.StoreLocation -- } grouping per store
HAVING SUM(ss.Sale_Amount) >
		(SELECT AVG(Store_Total) -- avg rev per store
FROM (SELECT Store_ID,
		SUM(Sale_Amount) AS Store_Total -- } total rev per store
        FROM store_sales
GROUP BY Store_ID) AS store_sales) -- putthing all together
ORDER BY Total_Revenue DESC; -- sorting highest to lowest 
/* 12 RECORDS Returned */

/*========================================================================*/

/* QUESTION 19: Find the top 5 highest-grossing stores, then use that result to look up their city and state from
Store_Locations. */

-- top 5 high-gross stores
SELECT sl.StoreId,
		sl.StoreLocation,  -- } pulling store onfo
        sl.State, 
        totals.Total_Revenue
FROM (SELECT Store_ID,
		SUM(Sale_Amount) AS Total_Revenue -- total rev per store
FROM store_sales
GROUP BY Store_ID  -- grouping per stores
ORDER BY Total_Revenue DESC LIMIT 5) -- pulling top 5
AS totals
JOIN store_locations AS sl
	ON totals.Store_ID = sl.StoreId -- } matching locations to stores
ORDER BY totals.Total_Revenue DESC;  -- sorting top 5
/* 5 RECORDS Returned */

/*========================================================================*/

/* QUESTION 20: Write a query using a subquery to find all sales records from stores managed by the Northeast
region's store managers. */

-- Northeast stores records
SELECT ss.Transaction_Date,
		ss.Store_ID,      -- } pulling in-store info
        ss.Prod_Num,
        ss.Sale_Amount
FROM store_sales AS ss
WHERE ss.Store_ID
	IN (SELECT sl.StoreId     -- pulling in-store (Northeast)
		FROM store_locations AS sl
        WHERE sl.State
	IN (SELECT State
		FROM management  -- pulling managers in location
        WHERE Region = 'Northeast')); -- ensuring region
/* 182914 RECORDS Returned */