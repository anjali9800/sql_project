-- Create Database
CREATE DATABASE pizzasales
USE pizzasales


-- Create pizzas table
CREATE TABLE pizzas1 (
    pizza_id INT,
    pizza_type_id varchar(50),
	size varchar(10),
	price float
)

alter table pizzas1
alter column pizza_id varchar(50);

select * from pizzas1

-- Create pizza_type table
CREATE TABLE pizza_type (
    pizza_type_id varchar(50),
	name varchar(50),
	category varchar(50),
	ingredients varchar(50)
)


-- Create orders table
CREATE TABLE Orders (
    order_id int,
	date date,
	time time
)


-- Create order_details table
CREATE TABLE Orders_details (
   order_details_id int,
   order_id int,
   pizza_id varchar(50),
   quantity int
)


alter table pizza_type
alter column ingredients varchar(500);


select * from pizzas1
select * from pizza_type
select * from Orders
select * from Orders_details



-- Import Data into pizzas1 Table
BULK INSERT pizzas1
FROM 'C:\Users\anjal\power bi\pizza_sales\pizzas.csv'
WITH (
    FIELDTERMINATOR = ',',  
    ROWTERMINATOR = '\n',  
    FIRSTROW = 2            
)



-- Import Data into pizza_type Table
BULK INSERT pizza_type
FROM 'C:\Users\anjal\power bi\pizza_sales\pizza_types.csv'
WITH (
    FIELDTERMINATOR = ',', 
    ROWTERMINATOR = '\n',   
    FIRSTROW = 2            
)



-- Import Data into Orders Table
BULK INSERT Orders
FROM 'C:\Users\anjal\power bi\pizza_sales\Orders.csv'
WITH (
    FIELDTERMINATOR = ',', 
    ROWTERMINATOR = '\n',  
    FIRSTROW = 2           
)



-- Import Data into Order_details Table
BULK INSERT Orders_details
FROM 'C:\Users\anjal\power bi\pizza_sales\Order_details.csv'
WITH (
    FIELDTERMINATOR = ',',  
    ROWTERMINATOR = '\n',   
    FIRSTROW = 2           
)



-----QUERIES-----

--BASIC QUERIES--
--(1)Retrieve the total number of orders placed:
select count(*) as total_orders from Orders;


--(2)Calculate the total revenue generated from pizza sales:
select round(sum(O.quantity * p.price),2) as total_sales
from Orders_details O
join pizzas1 p
on p.pizza_id = o.pizza_id;


--(3)Identify the highest-priced pizza:
select TOP 1 p.name, piz.price
from pizza_type p
join pizzas1 piz
on p.pizza_type_id = piz.pizza_type_id
order by piz.price desc;


--(4)Identify the most common pizza size ordered:
select top 1 p.size as most_common_size, count(o.order_details_id) as order_count
from pizzas1 p
join Orders_details o
on p.pizza_id = o.pizza_id
group by p.size
order by order_count desc;


--(5)List the top 5 most ordered pizza types along with their quantities:
select top 5 piz.name, sum(o.quantity) as total_quantity
from pizza_type piz
join pizzas1 p
on piz.pizza_type_id = p.pizza_type_id
join Orders_details o
on o.pizza_id = p.pizza_id
group by piz.name
order by total_quantity desc;


--INTERMEDIATE QUERIES--
--(1)Join the necessary tables to find the total quantity of each pizza category ordered
select piz.category,sum(o.quantity) as total_quantity
from pizza_type piz
join pizzas1 p
on piz.pizza_type_id = p.pizza_type_id
join Orders_details o
on o.pizza_id = p.pizza_id
group by piz.category
order by total_quantity desc;


--(2)Determine the distribution of orders by hour of the day
select datepart(hour,time) as order_hour ,count(order_id) as order_count from Orders
group by datepart(hour,time)
order by order_hour asc;


--(3)Join relevant tables to find the category-wise distribution of pizzas
select category,count(name) as total_count from pizza_type
group by category
order by category desc;


--(4)Group the orders by date and calculate the average number of pizzas ordered per day
select round(avg(total_quantity),0) as avg_pizza_quantity_per_day from
(select o.date,sum(ord.quantity) as total_quantity
from Orders o
join Orders_details ord
on o.order_id = ord.order_id
group by o.date) as order_quantity;


--(5)Determine the top 3 most ordered pizza types based on revenue
select top 3 piz.name, round(sum(ord.quantity * p.price),0) as revenue
from pizza_type piz
join pizzas1 p
on p.pizza_type_id = piz.pizza_type_id
join Orders_details ord
on ord.pizza_id = p.pizza_id
group by piz.name
order by revenue desc;


--ADVANCE QUERIES--
--(1)Calculate the percentage contribution of each pizza type to total revenue
with total_revenue_cte as (select SUM(ord.quantity * p.price) as total_revenue
from Orders_details ord
join pizzas1 p
on p.pizza_id = ord.pizza_id)
select piz.category,
round(sum(ord.quantity * p.price) * 100 / tr.total_revenue, 2) as revenue_percentage
from pizza_type piz
join pizzas1 p on piz.pizza_type_id = p.pizza_type_id
join Orders_details ord on ord.pizza_id = p.pizza_id
cross join total_revenue_cte tr
group by piz.category, tr.total_revenue
order by revenue_percentage desc;


--(2)Analyze the cumulative revenue generated over time
select date, sum(revenue) over(order by date) as cumulative_revenue
from 
(select O.date,round(sum(ord.quantity * p.price),2) as revenue
from Orders_details ord
join pizzas1 p
on ord.pizza_id = p.pizza_id
join Orders o
on o.order_id = ord.order_id
group by o.date) as sales_cte
order by date asc;


--(3)Determine the top 3 most ordered pizza types based on revenue for each pizza category
select top 3 name, category,revenue
from
(select piz.name, piz.category, round(sum(ord.quantity * p.price),0) as revenue
from pizza_type piz
join pizzas1 p
on piz.pizza_type_id = p.pizza_type_id
join Orders_details ord
on ord.pizza_id = p.pizza_id
group by piz.name,piz.category) as cte
order by revenue desc;