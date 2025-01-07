# SQL FOR DATA ANALYSIS

-- lists the tables in the current database
show tables;

-- provides the description of the table specified
desc sales;


# CALCULATIONS IN QUERIES
-- Amount per box
SELECT
	SaleDate, Amount, Boxes, ROUND((Amount / Boxes), 2) AS 'Amount per box' 
FROM sales;



# IMPOSE CONDITION IN SELECT
-- WHERE clause

-- List all sales amount more than $10,000
SELECT * FROM sales
WHERE Amount > 10000
ORDER BY Amount DESC;


SELECT * FROM sales
WHERE GeoID = 'g1'
ORDER BY PID, amount DESC;


-- All sales having amount > 10,000 and year = 2022
SELECT * FROM sales
WHERE amount > 10000
	AND YEAR(SaleDate) = '2022'		-- or SaleDate >= '2022-01-01'		-> Date Format in MySQL is 'YY-MM-DD'
ORDER BY amount DESC;


-- All sales where number of boxes is from 0 to 50
SELECT * FROM sales
WHERE Boxes BETWEEN 0 AND 50		-- or boxes >0 AND boxes <= 50
ORDER BY Boxes;


-- All sales happening on a Friday
SELECT 
	SaleDate, Amount, Boxes, WEEKDAY(SaleDate) AS 'Day of week'
FROM sales
WHERE WEEKDAY(saledate) = 4;		-- WEEKDAY -> 0 = Monday, 1 = Tuesday, ..., 6 = Sunday



# USING MULTIPLE TABLES

-- View team Delish or Jucies
SELECT * FROM people
WHERE team IN ('Delish', 'Jucies');		-- or team = 'Delish' or team = 'Jucies'



# PATTERN MATCHING
-- LIKE operator

-- All salesperson whose name begin with 'B'
SELECT salesperson FROM people
WHERE Salesperson LIKE 'B%';


-- List of all people where 'b' is anywhere in their name
SELECT salesperson FROM people
WHERE Salesperson LIKE '%b%';


-- CASE operator
-- Adding amount category to column 
		-- (upto $1000 'under 1000', between $1000 to $5000 'under 5000', between $5000 to $10,000 'under 10000')
SELECT 
	SaleDate, Amount,
	CASE	WHEN amount <= 1000 THEN 'Under 1k'
			WHEN amount BETWEEN 1000 AND 5000 THEN 'Under 5k'
			WHEN amount BETWEEN 5000 AND 10000 THEN 'Under 10k'
			ELSE '10k or more'
	END AS 'Amount category'
FROM sales;



# JOINS

-- All sales data with salesperson name
SELECT 
	SaleDate, Amount, Salesperson
FROM sales s
JOIN people p
	ON p.spid = s.spid;



-- LEFT JOIN
-- Name of product that are being sold in a shipment
SELECT 
	SaleDate, Amount, Product
FROM sales s
LEFT JOIN products pr
	ON pr.pid = s.pid;
    
    

# JOIN MULTIPLE TABLES
-- Product name and salesperson in one view
SELECT 
	SaleDate, Amount, Salesperson, Product, Team
FROM sales s
JOIN people p
	ON p.spid = s.spid
JOIN products pr
	ON pr.pid = s.pid;
    
    
    
# CONDITIONS WITH JOINS
-- Product name and salesperson in one view where amount is less than $500 for a specific team
SELECT 
	s.SaleDate, s.Amount, p.Salesperson, pr.Product, p.Team
FROM sales s
JOIN people p
	ON p.spid = s.spid
JOIN products pr
	ON pr.pid = s.pid
WHERE s.Amount < 500
	AND p.Team = 'Delish';
    
    
-- The above query with salesperson who do not belong to any team
SELECT 
	s.SaleDate, s.Amount, p.Salesperson, pr.Product, p.Team
FROM sales s
JOIN people p
	ON p.spid = s.spid
JOIN products pr
	ON pr.pid = s.pid
WHERE s.Amount < 500
	AND p.Team = '';


-- The above query with salesperson from India or New Zealand
SELECT 
	s.SaleDate, s.Amount, p.Salesperson, pr.Product, p.Team
FROM sales s
JOIN people p
	ON p.spid = s.spid
JOIN products pr
	ON pr.pid = s.pid
JOIN geo g
	ON g.geoid = s.geoid
WHERE s.Amount < 500
	AND p.Team = ''
    AND g.geo IN ('India', 'New Zealand')
ORDER BY SaleDate;



# GROUP BY
-- Group by gives a pivot report
-- helps to see data at a higher level

-- Group sales data by Geoid
SELECT 
	GeoID, 
    sum(Amount) AS total_amount,
    ROUND(AVG(Amount), 2) AS avg_amount, 
    SUM(Boxes) AS number_of_boxes
FROM sales
GROUP BY GeoID;


-- Group sales data by country
SELECT 
	g.geo AS country, 
    sum(Amount) AS total_amount,
    ROUND(AVG(Amount), 2) AS avg_amount, 
    SUM(Boxes) AS number_of_boxes
FROM sales s
JOIN geo g
	ON g.GeoID = s.GeoID
GROUP BY s.GeoID;


-- Total amount coming from a Team and Product Category
SELECT
    pr.Category,
	p.Team,
    SUM(s.boxes) AS number_of_boxes,
	SUM(s.Amount) AS total_amount
FROM sales s
JOIN people p
	ON p.SPID = s.SPID
JOIN products pr
	ON pr.PID = s.PID
WHERE p.Team <> ''		-- data in the table is 'blank' and not 'NULL'
GROUP BY pr.Category, p.Team
ORDER BY pr.Category, p.Team;


-- Total amounts by top 10 products
SELECT
    pr.Product,
	SUM(s.Amount) AS total_amount
FROM sales s
JOIN products pr
	ON pr.pid = s.pid
GROUP BY s.PID
ORDER BY total_amount DESC 
LIMIT 10;


# INTERMEDIATE PROBLEMS
-- 1. Print details of shipments (sales) where amounts are > 2,000 and boxes are <100?
SELECT *
FROM sales
WHERE Amount > 2000
	AND Boxes < 100;


-- 2. How many shipments (sales) each of the sales persons had in the month of January 2022?
SELECT
	p.Salesperson, 
    COUNT(*) AS Shipment_count
    -- MONTHNAME(SaleDate), YEAR(SaleDate)
FROM sales s
JOIN people p
	ON p.SPID = s.SPID
WHERE MONTHNAME(SaleDate) = 'January'
	AND YEAR(SaleDate) = 2022
GROUP BY p.Salesperson;


-- 3. Which product sells more boxes? Milk Bars or Eclairs?
SELECT
	pr.Product,
    SUM(Boxes) AS total_boxes
FROM sales s
JOIN products pr
	ON pr.pid = s.pid		-- or WHERE pr.Product IN ('Milk Bars', 'Eclairs')
GROUP BY pr.Product
HAVING pr.Product = 'Milk Bars' 
	OR pr.Product = 'Eclairs'
ORDER BY total_boxes DESC;


-- 4. Which product sold more boxes in the first 7 days of February 2022? Milk Bars or Eclairs?
SELECT
	pr.Product,
    SUM(Boxes) AS total_boxes
FROM sales s
JOIN products pr
	ON pr.pid = s.pid	
WHERE pr.Product IN ('Milk Bars', 'Eclairs')
	AND SaleDate BETWEEN '2022-02-01' AND '2022-02-07'
GROUP BY pr.Product
ORDER BY total_boxes DESC;


-- 5. Which shipments had under 100 customers & under 100 boxes? Did any of them occur on Wednesday?
SELECT 
	*,
    CASE	WHEN WEEKDAY(SaleDate) = 2 THEN 'Yes'
			ELSE 'No'
	END AS 'Wednesday Shipment'
FROM sales
WHERE Customers < 100
	AND Boxes < 100;


# HARD PROBLEMS
-- 1. What are the names of salespersons who had at least one shipment (sale) in the first 7 days of January 2022?
SELECT 
	p.SalesPerson,
    COUNT(*) AS shipment_count
FROM sales s
JOIN people p
	ON p.SPID = s.SPID
WHERE SaleDate BETWEEN '2022-01-01' AND '2022-01-10'
GROUP BY s.SPID
HAVING shipment_count >= 1
ORDER BY 2;


-- 2. Which salespersons did not make any shipments in the first 7 days of January 2022?
SELECT
	p.Salesperson
FROM people p
WHERE p.SPID NOT IN (
					SELECT DISTINCT s.SPID FROM sales s
					WHERE s.SaleDate BETWEEN '2022-01-01' AND '2022-01-07'
                    )
;


-- 3. How many times we shipped more than 1,000 boxes in each month?
SELECT 
	YEAR(saledate) AS `year`,
    MONTHNAME(saledate) AS `month`,
    COUNT(*) AS shipment_count
FROM sales
WHERE boxes > 1000
GROUP BY `year`, `month`
ORDER BY `year`, `month`;


-- 4. Did we ship at least one box of ‘After Nines’ to ‘New Zealand’ on all the months?
SELECT YEAR(SaleDate) `Year`,
	MONTH(SaleDate) `Month`,
    SUM(boxes)
FROM sales s
JOIN products pr
	ON pr.PID = s.PID
JOIN geo g
	ON g.GeoID = s.GeoID
WHERE Product = 'After Nines' 
	AND Geo = 'New Zealand'
GROUP BY `Year`, `Month`
ORDER BY `Year`, `Month`;


SELECT YEAR(SaleDate) `Year`,
	MONTH(SaleDate) `Month`,
    CASE	WHEN SUM(boxes) > 1 THEN 'Yes'
			ELSE 'No'
	END AS Status
FROM sales s
JOIN products pr
	ON pr.PID = s.PID
JOIN geo g
	ON g.GeoID = s.GeoID
WHERE Product = 'After Nines' 
	AND Geo = 'New Zealand'
GROUP BY `Year`, `Month`
ORDER BY `Year`, `Month`;


-- 5. India or Australia? Who buys more chocolate boxes on a monthly basis?
SELECT YEAR(SaleDate) `Year`,
	MONTH(SaleDate) `Month`,
    SUM(Boxes),
    g.Geo
FROM sales s
JOIN geo g
	ON g.GeoID = s.GeoID
WHERE g.Geo IN ('India', 'Australia')
GROUP BY g.Geo, `Year`, `Month`
ORDER BY `Year`, `Month`;


WITH cte1 AS (
	SELECT YEAR(SaleDate) `Year`,
		MONTH(SaleDate) `Month`,
		SUM(Boxes) AS India_Boxes
	FROM sales s
	JOIN geo g
		ON g.GeoID = s.GeoID
	WHERE g.Geo = 'India'
    GROUP BY Year, Month
),
cte2 AS (
    	SELECT YEAR(SaleDate) `Year`,
		MONTH(SaleDate) `Month`,
		SUM(Boxes) AS Australia_Boxes
	FROM sales s
	JOIN geo g
		ON g.GeoID = s.GeoID
	WHERE g.Geo = 'Australia'
    GROUP BY Year, Month
)
SELECT 
	cte1.Year, cte1.Month,
	CASE 	WHEN India_Boxes>Australia_Boxes THEN 'India'
			ELSE 'Australia'
	END AS country
FROM cte1
JOIN cte2
	ON cte1.Year = cte2.Year
    AND cte1.Month = cte2.Month
ORDER BY cte1.Year, cte1.Month;








