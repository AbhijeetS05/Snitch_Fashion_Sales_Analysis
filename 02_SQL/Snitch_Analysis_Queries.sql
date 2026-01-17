-- UPDATING FORMATS/DATA TYPES
update snitch_sales
SET ORDER_DATE = str_to_date(ORDER_DATE, '%d-%m-%Y');

alter table snitch_sales
modify column Order_Date date;

alter table snitch_sales
modify Discount_Percentage DECIMAL(10,2);

-- Show all records from the dataset.
select * from SNITCH_SALES;

-- Display distinct product categories available.
select distinct PRODUCT_CATEGORY
FROM snitch_sales;

-- Find total number of orders.
select count(Order_ID)
from snitch_sales;

-- Find total units sold.
select sum(Units_Sold)
from snitch_sales;

-- List all unique customer segments (B2B/B2C).
select distinct Segment
FROM snitch_sales;

select Segment, count(distinct Order_ID) AS no_of_customers
FROM snitch_sales
group by Segment;

-- Show all orders placed in a specific year.
SELECT *
FROM Snitch_Sales
WHERE year(ORDER_DATE) = 2023;

-- Find orders where discount is 0.
SELECT *
FROM Snitch_Sales
WHERE Discount_Percentage = 0;

-- List products with unit_price greater than 2000
select	Product_Category, Product_Name, Unit_Price
from snitch_sales
where Unit_Price > 2000;

-- Count number of orders per category.
select Product_Category,
count(Order_ID) AS total_orders
from snitch_sales
group by Product_Category;

-- Show top 10 most expensive products.
select Product_Category, Product_Name, Unit_Price
from (select *, 
           dense_rank() OVER(order by Unit_Price desc) AS EXP
           from snitch_sales)T
where EXP < 11
order by Unit_Price desc;

-- Total sales amount per category.
SELECT
    Product_Category,
    round(sum(Sales_Amount),2) AS total_sales_amount
FROM snitch_sales
GROUP BY Product_Category;


-- Total profit per category.
SELECT
    Product_Category,
    round(sum(Net_Profit_Loss),2) AS Net_Profit_Loss
FROM snitch_sales
GROUP BY Product_Category;

-- Average discount per category.
SELECT
    Product_Category,
    round(AVG(Discount_Percentage),2) AS Average_Disc
FROM snitch_sales
GROUP BY Product_Category;

-- Total units sold per segment.
select Segment, count(Units_Sold) as Units
from snitch_sales
group by Segment;

-- Monthly total sales.
select DATE_FORMAT(order_date, '%Y-%m') as Month, sum(Sales_Amount) as 'Monthy total sales'
from snitch_sales
group by Order_Date;

-- Year-wise total profit.
select year(order_date) as 'Year', round(sum(Net_Profit_Loss),2) as 'total profit'
from snitch_sales
group by year(order_date);

-- Category with highest revenue.
select Product_Category, round(sum(Net_Profit_Loss),2) as Total_Revenue
from snitch_sales
group by Product_Category
order by Total_Revenue desc
limit 1;

-- Category with maximum loss
select Product_Category, round(sum(Net_Profit_Loss),2) as Total_Revenue
from snitch_sales
where Net_Profit_Loss < 0
group by Product_Category
order by  Total_Revenue
limit 1;

-- Top 3 products per category by Net_Profit_Loss
select Product_Category, rnk, Product_Name, round(total_profit,2) total_profit
from (
      select Product_Category, Product_Name,  
      sum(Net_Profit_Loss) as total_profit,
      dense_rank() over(partition by Product_Category order by sum(Net_Profit_Loss) desc) rnk
      from snitch_sales
      group by Product_Category, Product_Name
      ) temp
where rnk <= 3
order by Product_Category, rnk;

-- Low-sales but high-discount products
WITH product_metrics as(
select 
     Product_Name, sum(Units_Sold) as total_units_sold,
     avg(Discount_Percentage) as avg_discount
from snitch_sales
group by Product_Name),
benchmarks as(
select 
     avg(total_units_sold) as avg_units_sold,
     avg(avg_discount) as avg_discount
from product_metrics)

select P.Product_Name, P.total_Units_Sold, round(P.avg_discount,2) as avg_discount
from product_metrics P
cross join benchmarks b
where 
    p.total_units_sold < b.avg_units_sold
    and p.avg_discount > b.avg_discount
order by p.avg_discount desc;

-- Products contributing to top 20% revenue (Pareto)
with product_revenue as( 
	select Product_Name, sum(Net_Profit_Loss) as total_revenue
    from snitch_sales
    group by Product_Name),
ranked_products as(
     select Product_Name, total_revenue,
     sum(total_revenue) over (order by total_revenue desc) as cumulative_revenue,
     sum(total_revenue) over () as overall_revenue
     from product_revenue)

select 
     Product_Name, round(total_revenue,2) total_revenue, round(cumulative_revenue,2) cumulative_revenue,
     round(cumulative_revenue / overall_revenue,2) AS cumulative_percentage
from ranked_products
where cumulative_revenue / overall_revenue <= 0.20
order by total_revenue desc;















