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

--5.How many Vegetarian and Meatlovers were ordered by each customer?

SELECT c.customer_id,
       SUM(CASE 
               WHEN p.pizza_name LIKE'%Meatlovers%' 
               THEN 1
               ELSE 0
           END) AS meatlovers,
       SUM(CASE 
               WHEN p.pizza_name LIKE'%Vegetarian%' 
               THEN 1
               ELSE 0
           END) AS vegetarian
FROM   ##customer_orders AS c
JOIN   pizza_names AS p
ON     c.pizza_id = p.pizza_id
GROUP  BY c.customer_id

--6. What was the maximum number of pizzas delivered in a single order?

select top 1 
c.order_id, count(c.pizza_id) as total_pizza_delivered
from ##customer_orders as c
join ##runner_orders as r
on c.order_id = r.order_id
where r.pickup_time is not null 
group by c.order_id
order by total_pizza_delivered desc

--7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

SELECT c.customer_id,
       SUM(CASE 
               WHEN c.eclusions <> '' OR c.extras <> ''
               THEN 1
               ELSE 0
           END) AS at_least_1_change,
       SUM(CASE 
               WHEN c.eclusions = '' AND c.extras = ''
               THEN 1
               ELSE 0
           END) AS no_changes
FROM   ##customer_orders AS c
JOIN   ##runner_orders AS r
ON     c.order_id = r.order_id
WHERE  r.pickup_time IS NOT NULL
GROUP  BY customer_id

--8. How many pizzas were delivered that had both exclusions and extras?

select
sum(case when c.eclusions <> '' and c.extras <> ''
		then 1
		else 0 end) as exclusions_and_extras
from ##customer_orders as c
join ##runner_orders as r
on c.order_id = r.order_id
where r.pickup_time is not null

--9. What was the total volume of pizzas ordered for each hour of the day?

select DATEPART(hour,order_time) as hour,
count(pizza_id) as pizza_ordered_hourly
from ##customer_orders
group by DATEPART(hour,order_time)
order by pizza_ordered_hourly desc

--10. What was the volume of orders for each day of the week?

select DATEPART(WEEKDAY,order_time) as weekday_name,
count(pizza_id) as pizza_ordered
from ##customer_orders
group by DATEPART(weekday,order_time)
order by pizza_ordered desc
