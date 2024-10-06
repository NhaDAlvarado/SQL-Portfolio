/* To test out a few different hypotheses - the Data Bank team wants to run an experiment 
where different groups of customers would be allocated data using 3 different options:
	Option 1: data is allocated based off the amount of money at the end of the previous month
	Option 2: data is allocated on the average amount of money kept in the account in the previous 30 days
	Option 3: data is updated real-time
For this multi-part challenge question - you have been requested to generate 
the following data elements to help the Data Bank team estimate how much data 
will need to be provisioned for each option:
	running customer balance column that includes the impact each transaction
	customer balance at the end of each month
	minimum, average and maximum values of the running balance for each customer
Using all of the data available - how much data would have been required 
for each option on a monthly basis?
select * from customer_transactions
order by customer_id 
*/

-- running customer balance column that includes the impact each transaction
select customer_id, extract (month from txn_date) as month, txn_type,
		sum(case when txn_type = 'deposit' then txn_amount 
				when txn_type = 'purchase' or txn_type = 'withdrawal' then (-txn_amount)
			end) as total_amount_per_txn_type_per_month
	from customer_transactions
	group by customer_id, month, txn_type
	order by customer_id;

-- customer balance at the end of each month	
with total_amount_deposit_withdrawal as (
	select customer_id, extract (month from txn_date) as month,
		sum(case when txn_type = 'deposit' then txn_amount 
				when txn_type = 'purchase' or txn_type = 'withdrawal' then (-txn_amount)
			end) as total_amount_per_txn_type_per_month
	from customer_transactions
	group by customer_id, month
	order by customer_id
)
select customer_id, month,total_amount_per_txn_type_per_month,
sum(total_amount_per_txn_type_per_month) over (partition by customer_id order by month) as running_balance_after_each_txn
from total_amount_deposit_withdrawal;

-- minimum, average and maximum values of the running balance for each customer
with total_amount_deposit_withdrawal as (
	select customer_id, extract (month from txn_date) as month,
		sum(case when txn_type = 'deposit' then txn_amount 
				when txn_type = 'purchase' or txn_type = 'withdrawal' then (-txn_amount)
			end) as total_amount_per_month
	from customer_transactions
	group by customer_id, month
	order by customer_id
), 
running_balance as (
	select customer_id, month,total_amount_per_month,
	sum(total_amount_per_month) over (partition by customer_id order by month) as running_balance
	from total_amount_deposit_withdrawal
)
select customer_id, 
	min(running_balance) as min_running_total,
	round(avg(running_balance),2) as avg_running_total,
	max(running_balance) as max_running_total	
from running_balance
group by customer_id;

-- Option 1: data is allocated based off the amount of money at the end of the previous month
with total_amount_deposit_withdrawal as (
	select customer_id, extract (month from txn_date) as month,
		sum(case when txn_type = 'deposit' then txn_amount 
				when txn_type = 'purchase' or txn_type = 'withdrawal' then (-txn_amount)
			end) as total_amount_per_txn_type_per_month
	from customer_transactions
	group by customer_id, month
	order by customer_id
),
running_balance as (
	select customer_id, month,total_amount_per_txn_type_per_month,
	sum(total_amount_per_txn_type_per_month) over (partition by customer_id order by month) as running_balance
	from total_amount_deposit_withdrawal
),
previous_running_balance as (
	select customer_id, month,total_amount_per_txn_type_per_month, running_balance,
	lag(running_balance) over (partition by customer_id order by month) as pv_mth_balance
	from running_balance
)
select month, sum(pv_mth_balance)
from previous_running_balance
group by month
order by month;
/*
It was observed that each month's data allotment, which was dependent on 
the balance from the previous month, produced negative figures. 
Customers that had a negative balance the month before were the cause of this.
Still, it is not possible for these clients to be assigned a negative amount 
of data storage for upcoming months.
*/

-- Option 2: data is allocated on the average amount of money kept in the account in the previous 30 days
with total_amount_deposit_withdrawal as (
	select customer_id, extract (month from txn_date) as month,
		sum(case when txn_type = 'deposit' then txn_amount 
				when txn_type = 'purchase' or txn_type = 'withdrawal' then (-txn_amount)
			end) as total_amount_per_txn_type_per_month
	from customer_transactions
	group by customer_id, month
	order by customer_id
),
running_balance as (
	select customer_id, month,total_amount_per_txn_type_per_month,
	sum(total_amount_per_txn_type_per_month) over (partition by customer_id order by month) as running_balance
	from total_amount_deposit_withdrawal
),
previous_running_balance as (
	select customer_id, month,total_amount_per_txn_type_per_month, running_balance,
	round(avg(running_balance) over (partition by customer_id ),2) as avg_balance
	from running_balance
)
select month, 
	sum(case when avg_balance <0 then 0 else avg_balance end) as total_data_by_month
from previous_running_balance
group by month
order by month;
/* It makes no sense to allocate these clients a negative quantity of data storage 
for the next few months based on the first option. Customers with a balance from 
the previous month that was negative were assumed to receive a data storage allocation 
of 0 for the next month.
Taking the assumption into account, the outer query was changed to give clients 
with a balance of less than zero for the previous month 0 data storage.
*/

-- Option 3: data is updated real-time
with total_amount_deposit_withdrawal as (
	select customer_id, extract (month from txn_date) as month,
		sum(case when txn_type = 'deposit' then txn_amount 
				when txn_type = 'purchase' or txn_type = 'withdrawal' then (-txn_amount)
			end) as total_amount_per_txn_type_per_month
	from customer_transactions
	group by customer_id, month
	order by customer_id
),
running_balance as (
	select customer_id, month,total_amount_per_txn_type_per_month,
	sum(total_amount_per_txn_type_per_month) over (partition by customer_id order by month) as running_balance
	from total_amount_deposit_withdrawal
)
select month, 
	sum(case when running_balance <0 then 0 else running_balance end) as total_data_by_month
from running_balance
group by month
order by month