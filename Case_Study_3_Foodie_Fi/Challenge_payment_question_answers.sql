-- The Foodie-Fi team wants you to create a new payments table for the year 2020 
-- that includes amounts paid by each customer in the subscriptions table 
-- with the following requirements:
	-- monthly payments always occur on the same day of month 
		--as the original start_date of any monthly paid plan
	-- upgrades from basic to monthly or pro plans are reduced 
		--by the current paid amount in that month and start immediately
	-- upgrades from pro monthly to pro annual are paid at the end 
		--of the current billing period and also starts at the end of the month period
	-- once a customer churns they will no longer make payments

with cte as (
	SELECT customer_id, s.plan_id, plan_name, 
       generate_series(start_date,
                       CASE
                           WHEN plan_name IN ('basic monthly', 'pro monthly') THEN start_date + INTERVAL '1 month'
                           WHEN plan_name = 'pro annual' THEN start_date + INTERVAL '1 year'
                           ELSE start_date
                       END,
                       '1 month'::interval) as payment_date
,
       (CASE
           WHEN plan_name IN ('basic monthly', 'pro monthly') THEN price
           WHEN plan_name = 'pro annual' THEN round(price / 12,2)
           ELSE 0
       END) as amount
FROM subscriptions as s
JOIN plans as p ON s.plan_id = p.plan_id
WHERE start_date < '2021-01-01'
  AND s.plan_id NOT IN (0, 4)
order by customer_id
)
select customer_id, plan_id, plan_name, payment_date, amount,
	rank() over (partition by customer_id order by payment_date ) as payment_order
from cte