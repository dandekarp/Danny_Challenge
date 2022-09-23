----Week2 : Part D: Pricing and Ratings Solutions----

--1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes 
-- how much money has Pizza Runner made so far if there are no delivery fees?

SELECT SUM( 
           CASE
	       WHEN n.pizza_name = 'Meatlovers' 
               THEN 12
               ELSE 10
           END 
           ) AS total_earned
FROM  pizza_names AS n
JOIN  ##customer_orders AS c
ON    c.pizza_id = n.pizza_id
JOIN  ##runner_orders AS r
ON    c.order_id = r.order_id
WHERE r.pickup_time IS NOT NULL

--2. What if there was an additional $1 charge for any pizza extras?
--Add cheese is $1 extra

WITH price AS (
               SELECT c.record_id,
	              CASE 
		          WHEN n.pizza_name = 'Meatlovers' 
			  THEN 12
			  ELSE 10
	              END AS initial_price,
		      SUM(
		          CASE 
			  WHEN x.extras_id <> '' 
			  THEN 1
			  ELSE 0
		      END
		      ) AS extra_cost
		FROM  ##customer_orders AS c
		JOIN  pizza_names AS n
		ON    c.pizza_id = n.pizza_id
		JOIN  ##extras AS x
		ON    x.record_id = c.record_id
		JOIN  ##runner_orders AS r
                ON    c.order_id = r.order_id
                WHERE r.pickup_time IS NOT NULL
		GROUP BY c.record_id, n.pizza_name
		)
SELECT SUM(initial_price) + SUM(extra_cost) AS total_earned
FROM   price

--3.The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, 
--how would you design an additional table for this new dataset 
-- generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.

CREATE TABLE runner_ratings (
   order_id INT,
   rating INT,
   comment VARCHAR(160), 
   rating_date DATETIME
)

INSERT INTO runner_ratings 
VALUES (1, 5, 'perfect', '2020-01-01 20:00:00.000'),
       (2, 5, '', '2020-01-01 20:00:00.000'),
       (3, 3, 'runner got lost', '2020-01-03 02:02:00.000'),
       (4, 4, '', '2020-01-04 16:25:12.000'),
       (5, 2, 'came late and food was cold', '2020-01-08 23:03:00.000'),
       (7, 5, 'came sooner than expected', '2020-01-08 22:55:00.000'),
       (8, 4, '', '2020-01-10 01:00:00.000'),
       (10, 4, '', '2020-01-11 20:00:00.000') 

--4. Using your newly generated table - can you join all of the information together to form a table 
--which has the following information for successful deliveries?
--customer_id
--order_id
--runner_id
--rating
--order_time
--pickup_time
--Time between order and pickup
--Delivery duration
--Average speed
--Total number of pizzas

SELECT c.customer_id,
       c.order_id,
       r.runner_id,
       a.rating,
       c.order_time,
       r.pickup_time,
       DATEDIFF(MINUTE, c.order_time, r.pickup_time) AS time_between_order_and_pickup,
       r.duration_minutes AS delivery_duration,
       CAST(distance / duration_minutes * 60 AS DECIMAL(4,2)) AS speed_km_h ,
       COUNT(c.pizza_id) AS total_pizzas
FROM   ##customer_orders AS c
JOIN   ##runner_orders AS r
ON     c.order_id = r.order_id
JOIN   runner_ratings AS a
ON     r.order_id = a.order_id
GROUP  BY c.customer_id, c.order_id, r.runner_id, a.rating, c.order_time, r.pickup_time, r.duration_minutes, r.distance

