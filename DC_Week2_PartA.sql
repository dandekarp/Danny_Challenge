----Week2 : Part A : Pizza Metrics Solutions----

--1. How many pizzas were ordered?
select count(pizza_id) as Total_Pizzas
from ##customer_orders

--2. How many unique customer orders were made?
select count(distinct(order_id)) as Unique_Customer_Orders
from ##customer_orders

--3. How many successful orders were delivered by each runner?
select runner_id, count(pickup_time) as successful_orders
from ##runner_orders
group by runner_id

--4.How many of each type of pizza was delivered?

select pn.pizza_name,
count(ro.pickup_time) as total_delivered
from ##customer_orders co
join pizza_names pn
on co.pizza_id = pn.pizza_id
join ##runner_orders ro
on co.order_id = ro.order_id
group by pn.pizza_name

select * from ##customer_orders
select * from pizza_names
select * from ##runner_orders