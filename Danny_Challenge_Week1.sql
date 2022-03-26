create database Danny_Challenge;

CREATE SCHEMA dannys_diner;
SET search_path = dannys_diner;

CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');

select * from members
select * from menu
select * from sales

--What is the total amount each customer spent at the restaurant?

select s.customer_id, sum(m.price) as Total_Amount_Spend
from menu m join sales s on m.product_id = s.product_id
group by s.customer_id

--How many days has each customer visited the restaurant?

select s.customer_id, count(distinct s.order_date) as No_Of_Days
from menu m join sales s on m.product_id = s.product_id
group by s.customer_id;

--What was the first item from the menu purchased by each customer?

With purchase_order_rank as (
select s.customer_id, s.order_date,m.product_name,
DENSE_RANK () OVER (PARTITION BY s.customer_id ORDER BY s.order_date) as rank
from sales s join menu m 
on s.product_id = m.product_id
group by s.customer_id,s.order_date,m.product_name
)
select customer_id,product_name as First_Product_Purchased, order_date
from purchase_order_rank
where rank=1

--What is the most purchased item on the menu and how many times was it purchased by all customers?

select top 1
m.product_name, count(s.product_id) as most_purchased_item
from sales s join menu m 
on s.product_id = m.product_id
group by m.product_name
order by count(s.product_id) DESC

--Which item was the most popular for each customer?

With most_popular_product as (
select s.customer_id, m.product_name, count(s.product_id) as times_purchased,
DENSE_RANK () OVER (PARTITION BY s.customer_id ORDER BY count(s.product_id) desc) as rank
from sales s join menu m
on s.product_id = m.product_id
group by s.customer_id, m.product_name
)
select customer_id, product_name as Fav_Item, times_purchased
from most_popular_product
where rank = 1

--Which item was purchased first by the customer after they became a member?

With First_Item_Purchased as (
select s.customer_id, s.order_date, m.product_name, mem.join_date,
DENSE_RANK () OVER (PARTITION BY s.customer_id order by s.order_date) as rank
from sales s join menu m 
on s.product_id = m.product_id
join members mem
on s.customer_id = mem.customer_id
where s.order_date >= mem.join_date
)
select customer_id, product_name as First_Product_Purchased, join_date, order_date
from First_Item_Purchased
where rank = 1

--Which item was purchased just before the customer became a member?

With Item_Purchased_Before as (
select s.customer_id, s.order_date, m.product_name, mem.join_date,
DENSE_RANK () OVER (PARTITION BY s.customer_id order by s.order_date DESC) as rank
from sales s join menu m 
on s.product_id = m.product_id
join members mem
on s.customer_id = mem.customer_id
where s.order_date < mem.join_date
)
select customer_id, product_name as Last_Item_Purchased, join_date, order_date
from Item_Purchased_Before
where rank = 1

--What is the total items and amount spent for each member before they became a member?

select s.customer_id,count(m.product_id) as Total_Items, sum(m.price) as Amount
from sales s join menu m
on s.product_id = m.product_id
join members mem 
on s.customer_id = mem.customer_id
where s.order_date < mem.join_date
group by s.customer_id

--If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

select s.customer_id, sum (case 
when m.product_name = 'sushi' 
then m.price * 20 
else m.price * 10 
end) as Total_Points_Earned
from sales s join menu m
on s.product_id = m.product_id
group by s.customer_id;

--In the first week after a customer joins the program (including their join date) they earn 2x points on all items,
--not just sushi - how many points do customer A and B have at the end of January?

with 
first_joining_week as (
select s.customer_id, sum(m.price * 20) as first_joining_points
from sales s join menu m
on s.product_id = m.product_id
join members mem on s.customer_id = mem.customer_id
where s.order_date between mem.join_date and  dateadd(DAY,7,mem.join_date)
group by s.customer_id
),
normal_week as (
select s.customer_id, sum(case when m.product_name = 'sushi' then m.price*20 else m.price*10 end) as january_points
from sales s join menu m
on s.product_id = m.product_id
join members mem on s.customer_id = mem.customer_id
where month(s.order_date) = 1 and 
s.order_date not between mem.join_date and DATEADD(day,7,mem.join_date)
group by s.customer_id
)
select i.customer_id, i.first_joining_points + j.january_points as Total_Points
from first_joining_week i join normal_week j 
on i.customer_id = j.customer_id