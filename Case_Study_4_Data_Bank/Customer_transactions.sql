-- 1.What is the unique count and total amount for each transaction type?
select txn_type, count(distinct customer_id) as no_of_cus_do_txn,  sum(txn_amount) 
from customer_transactions
group by txn_type;

-- 2.What is the average total historical deposit counts and amounts for all customers?
select count(txn_type) as total_deposit_txn, sum(txn_amount) as total_deposit_amount
from customer_transactions
where txn_type = 'deposit';

-- 3.For each month - how many Data Bank customers make more than 1 deposit 
-- and either 1 purchase or 1 withdrawal in a single month?
with count_deposit_withdrawal as (
	select customer_id, extract (month from txn_date) as month, 
		sum(case when txn_type = 'deposit' then 1 else 0 end) as count_deposit_txn,
		sum(case when txn_type = 'purchase' or txn_type = 'withdrawal' then 1 else 0 end) as count_purchase_withdraw_txn
	from customer_transactions
	group by customer_id, month
	order by customer_id
)
select month, count(customer_id)
from count_deposit_withdrawal
where count_deposit_txn>1 and count_purchase_withdraw_txn =1 
group by month;

-- 4.What is the closing balance for each customer at the end of the month?
with total_amount_deposit_withdrawal as (
	select customer_id, extract (month from txn_date) as month, 
		sum(case when txn_type = 'deposit' then txn_amount 
				when txn_type = 'purchase' or txn_type = 'withdrawal' then (-txn_amount)
			end) as total_amount_before_previous_mth
	from customer_transactions
	group by customer_id, month
	order by customer_id
)
select customer_id, month, 
sum(total_amount_before_previous_mth) over (partition by customer_id order by month) as closing_balance
from total_amount_deposit_withdrawal;

-- 5.What is the percentage of customers who increase their closing balance by more than 5%?
with total_amount_deposit_withdrawal as (
	select customer_id, extract (month from txn_date) as month, 
		sum(case when txn_type = 'deposit' then txn_amount 
				when txn_type = 'purchase' or txn_type = 'withdrawal' then (-txn_amount)
			end) as total_amount_before_previous_mth
	from customer_transactions
	group by customer_id, month
	order by customer_id
), 
current_mth_closing_balance as (
	select customer_id, month, total_amount_before_previous_mth,
	sum(total_amount_before_previous_mth) over (partition by customer_id order by month) as cur_mth_closing_balance
	from total_amount_deposit_withdrawal
),
previous_mth_closing_balance as (
	select customer_id, month,
		lag(cur_mth_closing_balance) over (partition by customer_id order by month) as pv_mth_closing_balance,
		cur_mth_closing_balance
	from current_mth_closing_balance
),
find_5_percent_increase as (
	select customer_id, month, cur_mth_closing_balance,
	round(case 
	        when pv_mth_closing_balance = 0 THEN 0 -- Prevent division by zero
	        else (cur_mth_closing_balance - pv_mth_closing_balance) * 100 / pv_mth_closing_balance
	    end, 2)
	 as five_percentage
	from previous_mth_closing_balance
	where pv_mth_closing_balance is not null 
),
no_of_cus_who_have_more_than_5_percent_increase as (
	select count(distinct customer_id) as five_percent_increase_cus
	from find_5_percent_increase
	where five_percentage > 5
),
no_of_customer as (
	select count(distinct customer_id) as total_customer
	from customer_transactions
)
select round(five_percent_increase_cus*100::numeric/total_customer::numeric,2) as percentage
from no_of_cus_who_have_more_than_5_percent_increase
join no_of_customer
on 1 =1 
