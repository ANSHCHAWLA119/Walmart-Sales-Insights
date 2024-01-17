
CREATE DATABASE IF NOT EXISTS WalmartSales;
USE WalmartSales;
create table if NOT exists sales1(
	invoice_id varchar(30) NOT NULL PRIMARY KEY,
    branch varchar(5) NOT NULL,
	city Varchar(30) Not NULL,
    customer_type Varchar(30) Not NUll, 
    gender Varchar(10) Not NuLL,
    product_line  varchar(100) not null,
    unit_price Decimal(10,2) not null,
	quantity  int not null,
    VAT float(6,4) NOT null,
    total Decimal(12, 4)  Not null,
    date DATETIME not null,
    time TIME not NULL,
    payment_method Varchar(20) not null,
    cogs Decimal(10,2) NOT NULL,
    gross_margin_pct FLOAT(11,9),
    gross_income decimal(12,4) not null,
    rating float(2,1) not null
);
Select * from sales1;
 ----- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------- -----
  ----- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------- -----
 ----- ----------------------------------------------------------------FEATURE ENGINEERING--------------------------------------------------------------------------------------- -----
  ----- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------- -----
 ----- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------- -----
USE walmartsales;


-- ADD TIME COLUMN-- 
alter table sales1 
drop column Day_of_time;
alter table sales1 ADD COLUMN Day_of_time varchar(20);
UPDATE sales1
SET Day_of_time = (
	CASE
		WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
    END
);

 

--  ADD DAYNAME COLUMN -- 
-- Step 1: Add a new column to the table
ALTER TABLE sales1
ADD COLUMN day_name VARCHAR(10);

-- Step 2: Update the values in the new column based on the day names from the 'date' column
UPDATE sales1
SET day_name = DAYNAME(date);


-- Step 3: Verify the changes
SELECT monthname(date)
FROM sales1;
 
 ALTER TABLE sales1 
 ADD column month_name VARCHAR(20);

UPDATE sales1
SET month_name = monthname(date);
 
Select * from sales1;


-- How many unique cities does the data have?

Select distinct(city) from sales1;

-- In which city is each branch?-- 

Select distinct(branch) , city from sales1;

-- Product Based Question-- 

-- How many unique product lines does the data have?-- 

ALTER  Table sales1 
Rename column  product_line to product_category;

Select distinct(product_category) from sales1;

-- What is the most common payment method?-- 

Select payment_method , Count(payment_method) from sales1 
group by(payment_method)
Order by payment_method ASC
limit 1;

-- What is the most selling product line?-- 

SELECT product_category, sum(quantity) AS max_quantity
FROM sales1
GROUP BY product_category
HAVING SUM(quantity)
order by  max_quantity desc
limit 5;


-- What is the total revenue by month?-- 

SELECT SUM(total) AS total_sales, month_name
FROM sales1
GROUP BY month_name;


-- What month had the largest COGS?--  

Select month_name , SUM(cogs)
from sales1
group by month_name
Order by sum(cogs)
 desc  ;
 
-- What is the city with the largest revenue?

select city , Sum(total) from sales1
Group by city
order by sum(total) DESC 
limit 1 ;


-- What product line had the largest VAT?

select  product_category , Sum(VAT) from sales1
Group by product_category
order by sum(VAT) DESC 
limit 1 ;


-- Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales-- 

SELECT product_category,
       (CASE WHEN cogs >= AVG(cogs) THEN 'Good' ELSE 'Bad' END) AS category_status
FROM sales1
product_category ,
cogs
;
ALTER table sales1 add column Categories varchar(10);
UPDATE  sales1
set Categories = (SELECT CASE WHEN cogs >= avg_cogs THEN 'Good' ELSE 'Bad' END
    FROM (SELECT AVG(cogs) AS avg_cogs FROM sales1) AS subquery);

-- Which branch sold more products than average product sold?

Select branch , sum(quantity) from sales1
 Group by branch 
 having sum(quantity) > (select avg(quantity) from sales1);
 
--  What is the most common product line by gender

Select gender , product_category , count(gender) as cnt from sales1
group by gender , product_category;

-- What is the average rating of each product line?

SELECT
	ROUND(AVG(rating), 2) as avg_rating,
    product_category
FROM sales1
GROUP BY product_category
ORDER BY avg_rating DESC;


-- Number of sales made in each time of the day per weekday

select sum(quantity) as num_sales , Day_of_time from sales1 
group by Day_of_time
order by sum(quantity) desc;


-- Which of the customer types brings the most revenue?

Select  customer_type, sum(total) as revenue from sales1 
group by customer_type
order by revenue desc; 

-- Which city has the largest tax percent/ VAT (Value Added Tax)?

Select city , sum(VAT) as total_vat from sales1
group by city 
order by total_vat desc
limit 1;


-- Which customer type pays the most in VAT?

Select  customer_type, sum(VAT) as revenue_vat from sales1 
group by customer_type
order by revenue_vat desc; 


-- How many unique customer types does the data have?

Select distinct(customer_type) from sales1;

-- How many unique payment methods does the -- data have?

Select distinct(payment_method) from sales1;

-- What is the most common customer type?

Select customer_type, count(customer_type) from sales1
group by(customer_type)  order by customer_type asc;

-- Which customer type buys the most?

Select customer_type , sum(quantity) as quantity_bought from sales1
group by(customer_type) 
order by customer_type asc ;

-- What is the gender of most of the customers?
select customer_type , gender , 
count(gender) as cnt from sales1
group by customer_type , gender;

-- Which customer_type male like the most?


SELECT
    customer_type,
    COUNT(*) AS male_count
FROM
    sales1
WHERE
    gender = 'Male'
GROUP BY
    customer_type
ORDER BY
    male_count DESC
LIMIT 3;

-- What is the gender distribution per branch?
select branch , gender , 
count(*) as cnt from sales1
where branch ="C"
group by gender;

-- Which time of the day do customers give most ratings?

Select Day_of_time , avg(rating) as rate from sales1
group by Day_of_time
order by rate asc ;

SELECT
	day_name,
	AVG(rating) AS avg_rating
FROM sales1
GROUP BY day_name 
ORDER BY avg_rating DESC;


-- Which day of the week has the best average ratings per branch?

SELECT 
	day_name,
	COUNT(day_name) total_sales
FROM sales1
WHERE branch = "C"
GROUP BY day_name
ORDER BY total_sales DESC;  

-- Number of sales made in each time of the day per weekday 
SELECT
	Day_of_time,
	COUNT(*) AS total_sales
FROM sales1
WHERE day_name = "Sunday"
GROUP BY Day_of_time
ORDER BY total_sales DESC;
-- Evenings experience most sales, the stores are 
-- filled during the evening hours


-- Which of the customer types brings the most revenue?

SELECT
	customer_type,
	SUM(total) AS total_revenue
FROM sales1
GROUP BY customer_type
ORDER BY total_revenue;


-- END OF REPORT-- 
