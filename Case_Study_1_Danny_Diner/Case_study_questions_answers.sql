--1. What is the total amount each customer spent at the restaurant?
select customer_id, sum(price) as total_amount 
from sales as s
join menu as m
on s.product_id = m.product_id
group by customer_id
order by customer_id;

--2. How many days has each customer visited the restaurant?
select customer_id, count(distinct order_date) as total_date
from sales
group by customer_id;

--3. What was the first item from the menu purchased by each customer?
with first_order_cte as (
	select customer_id, product_name, order_date,
	dense_rank() over (partition by customer_id order by order_date) as first_order
	from sales as s
	join menu as m
	on s.product_id = m.product_id
	)
select customer_id, 
	string_agg(product_name::text, ', ') AS product_names, 
	order_date
from first_order_cte
where first_order =1
group by customer_id, order_date;

--4. What is the most purchased item on the menu and how many times was it purchased by all customers?
select product_name, count(product_name) as no_of_order
from sales as s
join menu as m
on s.product_id = m.product_id
group by product_name
order by no_of_order desc
limit 1;

--5. Which item was the most popular for each customer?
select customer_id, product_name,
count(product_name) as no_of_order
from sales as s
join menu as m
on s.product_id = m.product_id
group by customer_id, product_name
order by customer_id asc, no_of_order desc;

--6. Which item was purchased first by the customer after they became a member?
with member_1st_order as (
	select s.customer_id, product_name, order_date, join_date,
	rank() over (partition by s.customer_id order by order_date) as rank
	from sales as s
	join menu as m on s.product_id = m.product_id
	join members as me on s.customer_id = me.customer_id
	where order_date > join_date
)
select customer_id, product_name, order_date, join_date
from member_1st_order
where rank =1;

--7. Which item was purchased just before the customer became a member?
with order_right_before_become_a_member as (
	select s.customer_id, product_name, order_date, join_date,
	rank() over (partition by s.customer_id order by order_date desc) as rank
	from sales as s
	join menu as m on s.product_id = m.product_id
	join members as me on s.customer_id = me.customer_id
	where order_date <= join_date
)
select customer_id, product_name, order_date, join_date
from order_right_before_become_a_member
where rank =1;

--8. What is the total items and amount spent for each member before they became a member?
select s.customer_id, sum(price) as total_spend
from sales as s
join menu as m on s.product_id = m.product_id
join members as me on s.customer_id = me.customer_id
where order_date < join_date
group by s.customer_id;

--9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier
-- how many points would each customer have?
with points_break_down_per_cus as (
	select s.customer_id,
	sum(case when product_name = 'sushi' then 20*price else 0 end) as double_points,
	sum(case when product_name in ('curry', 'ramen') then 10*price else 0 end) as normal_points	
	from sales as s
	join menu as m on s.product_id = m.product_id
	group by s.customer_id
)
select customer_id, 
(double_points + normal_points) as total_points
from points_break_down_per_cus
order by customer_id;

--10. In the first week after a customer joins the program (including their join date) 
--they earn 2x points on all items, not just sushi  
--how many points do customer A and B have at the end of January?
with week_1_as_a_member as (
	select s.customer_id, 
	sum(price)*20 as points_in_1st_week
	from sales as s
	join menu as m on s.product_id = m.product_id
	join members as me on s.customer_id = me.customer_id
	where order_date between join_date and (join_date +7)
	group by s.customer_id
	order by customer_id
),
points_after_1st_week as (
	select s.customer_id, 
	sum(case when product_name = 'sushi' then 20*price else 0 end) as double_points,
	sum(case when product_name in ('curry', 'ramen') then 10*price else 0 end) as normal_points	
	from sales as s
	join menu as m on s.product_id = m.product_id
	join members as me on s.customer_id = me.customer_id
	and order_date between '2021-01-01' and '2021-01-31'
	where order_date > join_date + INTERVAL '7 days'
	group by s.customer_id
)
select w.customer_id, points_in_1st_week, 
	(double_points +normal_points) as point_after_1st_week
from week_1_as_a_member as w
full join points_after_1st_week as p
on w.customer_id = p.customer_id;

-- BONUS QUESTION
--1. Join All The Things
select s.customer_id, order_date, join_date, product_name, price,
(case
	when join_date is null then 'N'
	when order_date < join_date then 'N'
	else 'Y'
end) as member
from sales as s
full join menu as m on s.product_id = m.product_id
full join members as me on s.customer_id = me.customer_id
order by s.customer_id, order_date;

--2. Rank All The Things
with join_all_tables as (
	select s.customer_id, order_date, join_date, product_name, price,
	(case
		when join_date is null then 'N'
		when order_date < join_date then 'N'
		else 'Y'
	end) as member
	from sales as s
	full join menu as m on s.product_id = m.product_id
	full join members as me on s.customer_id = me.customer_id
	order by s.customer_id, order_date
),
ranked_data as (
	select customer_id, order_date, join_date, product_name, price, member,
	dense_rank() over (partition by customer_id order by order_date asc) as ranking
	from join_all_tables
)
select customer_id, order_date, product_name, price, member,
(case when member = 'N' then null
	else ranking
end) as ranking
from ranked_data;


