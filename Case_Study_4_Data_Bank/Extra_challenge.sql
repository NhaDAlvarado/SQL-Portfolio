/*Data Bank wants to try another option which is a bit more difficult to implement 
they want to calculate data growth using an interest calculation, 
just like in a traditional savings account you might have with a bank.

If the annual interest rate is set at 6% and the Data Bank team wants to reward 
its customers by increasing their data allocation based off the interest calculated 
on a daily basis at the end of each day, how much data would be required for this 
option on a monthly basis?

Special notes:

Data Bank wants an initial calculation which does not allow for compounding interest, 
however they may also be interested in a daily compounding interest calculation so you 
can try to perform this calculation if you have the stamina!
*/
with total_amount_deposit_withdrawal as (
	select customer_id, txn_date,
	date_trunc('month', txn_date) as month_start_date,
   	 extract(day from (date_trunc('month', txn_date) + interval '1 month' - interval '1 day')) as days_in_month,
   	 extract(day from (date_trunc('month', txn_date) + interval '1 month' - interval '1 day')) 
	- extract(day from txn_date) AS day_interval,
		sum(case when txn_type = 'deposit' then txn_amount 
				when txn_type = 'purchase' or txn_type = 'withdrawal' then (-txn_amount)
			end) as total_amount_per_txn_type_per_date
	from customer_transactions
	group by customer_id, txn_date
	order by customer_id
),
running_balance as (
	select customer_id, txn_date,total_amount_per_txn_type_per_date, day_interval,
	sum(total_amount_per_txn_type_per_date) over (partition by customer_id order by txn_date) as date_running_balance
	from total_amount_deposit_withdrawal
),
running_balance_with_interest as (
	select customer_id, extract(month from txn_date) as month,total_amount_per_txn_type_per_date,day_interval,
	date_running_balance,
	round(date_running_balance*(0.06/365)*day_interval,2) as interest_amount_per_date_txn
	from running_balance
)
select month, 
	sum(case when interest_amount_per_date_txn<0 then 0 else interest_amount_per_date_txn
	end) as interest_data_per_month
from running_balance_with_interest
group by month
order by month
