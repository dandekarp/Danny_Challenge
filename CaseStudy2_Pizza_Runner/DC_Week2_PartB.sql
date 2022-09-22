----Week2 : Part b: Runner and Customer Experience Solutions----

--1.How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

set datefirst 1; -- to ensure Monday is set as 1st day of the week

select DATEPART(week,registration_date) as week,
count(runner_id) as runners_signed_up
from runners
group by DATEPART(week,registration_date)

--2.What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

SELECT r.runner_id,
       COUNT(DISTINCT r.pickup_time) AS total_pickups,
       CAST(AVG(CAST(DATEDIFF(MINUTE, c.order_time, r.pickup_time) AS DECIMAL)) AS DECIMAL(4,2)) AS average_time_mins
FROM   ##customer_orders AS c
JOIN   ##runner_orders AS r
ON     c.order_id = r.order_id
GROUP  BY r.runner_id

--3. Is there any relationship between the number of pizzas and how long the order takes to prepare?

with prep_time_by_order as (
select c.order_id, count(c.pizza_id) as no_of_pizzas,
cast(DATEDIFF(minute,c.order_time,r.pickup_time) as decimal) as prep_time
from ##customer_orders as c
join ##runner_orders as r
on c.order_id = r.order_id
group by c.order_id,c.order_time,r.pickup_time
)
select no_of_pizzas,
cast(avg(prep_time) as decimal(4,2)) as avg_total_prep_time,
cast(avg(prep_time)/no_of_pizzas as decimal(4,2)) as avg_prep_time_per_pizza
from prep_time_by_order
group by no_of_pizzas

--4. What was the average distance travelled for each customer?

SELECT c.customer_id,
       CAST(AVG(r.distance) AS DECIMAL (4,2)) AS average_distance_km
FROM   ##customer_orders AS c
JOIN   ##runner_orders AS r
ON     c.order_id = r.order_id
GROUP  BY c.customer_id

--5.What was the difference between the longest and shortest delivery times for all orders?

SELECT MAX(duration_minutes) AS longest_delivery_time_mins,
       MIN(duration_minutes) AS shortest_delivery_time_mins,
       MAX(duration_minutes) - MIN(duration_minutes) AS difference_mins
FROM   ##runner_orders

--6. What was the average speed for each runner for each delivery?

SELECT runner_id,
       order_id,
       distance_km,
       duration_minutes,
       CAST(distance_km / duration_minutes * 60 AS DECIMAL(4,2)) AS speed_km_h
FROM   ##runner_orders 
WHERE  distance_km IS NOT NULL
ORDER  BY runner_id, order_id

--6.1 Do you notice any trend for these values?

SELECT runner_id,
       order_id,
       distance_km,
       duration_minutes,
       DATEPART(HOUR,pickup_time) AS pickup_hour,
       DATENAME(WEEKDAY,pickup_time) AS pickup_weekday,
       CAST(distance_km / duration_minutes * 60 AS DECIMAL(4,2)) AS speed_km_h
FROM   ##runner_orders 
WHERE  distance_km IS NOT NULL
ORDER  BY runner_id, order_id

--7. What is the successful delivery percentage for each runner?

SELECT runner_id,
       COUNT(order_id) AS total_orders,
       COUNT(pickup_time) AS successful_deliveries,
       CAST(COUNT(pickup_time) AS FLOAT) / CAST(COUNT(order_id) AS FLOAT) * 100 AS successful_delivery_percentage
FROM   ##runner_orders
GROUP  BY runner_id