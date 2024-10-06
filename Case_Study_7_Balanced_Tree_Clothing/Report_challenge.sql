/*
Write a single SQL script that combines all of the previous questions into a scheduled 
report that the Balanced Tree team can run at the beginning of each month to calculate 
the previous month’s values.

Imagine that the Chief Financial Officer (which is also Danny) has asked for all of 
these questions at the end of every month.

He first wants you to generate the data for January only - but then he also wants you to 
demonstrate that you can easily run the samne analysis for February without many changes 
(if at all).

Feel free to split up your final outputs into as many tables as you need - but be sure 
to explicitly reference which table outputs relate to which question for full marks :)
*/

-- table with net_revenue, percentage split of revenue by 'product for each segment', 'segment for each category'
CREATE TABLE revenue_analysis_by_month AS
WITH rev_per_prod_in_seg AS (
    SELECT segment_name, product_name, extract(month from start_txn_time) as month,
           ROUND(SUM(qty * s.price * (1 - discount / 100.0)), 2) AS total_rev_per_prod
    FROM sales AS s
    JOIN product_details AS pd ON s.prod_id = pd.product_id
    GROUP BY segment_name, product_name, month
),
rev_per_seg AS (
    SELECT segment_name, extract(month from start_txn_time) as month,
           ROUND(SUM(qty * s.price * (1 - discount / 100.0)), 2) AS total_rev_in_seg
    FROM sales AS s
    JOIN product_details AS pd ON s.prod_id = pd.product_id
    GROUP BY segment_name, month
),
percentage_prod_in_seg AS (
    SELECT rs.segment_name, product_name, total_rev_per_prod, rs.month,
           ROUND(100.0 * total_rev_per_prod / total_rev_in_seg, 2) AS percentage_prod_in_seg
    FROM rev_per_prod_in_seg AS rs
    JOIN rev_per_seg AS ps ON rs.segment_name = ps.segment_name AND rs.month = ps.month
),
rev_per_cat AS (
    SELECT category_name, extract(month from start_txn_time) as month,
           ROUND(SUM(qty * s.price * (1 - discount / 100.0)), 2) AS total_rev_in_cat
    FROM sales AS s
    JOIN product_details AS pd ON s.prod_id = pd.product_id
    GROUP BY category_name, month
),
rev_per_seg_in_cat AS (
    SELECT category_name, segment_name, extract(month from start_txn_time) as month,
           ROUND(SUM(qty * s.price * (1 - discount / 100.0)), 2) AS total_rev_per_seg
    FROM sales AS s
    JOIN product_details AS pd ON s.prod_id = pd.product_id
    GROUP BY category_name, segment_name, month
),
percentage_seg_in_cat AS (
    SELECT sc.category_name, segment_name, total_rev_per_seg, sc.month,
           ROUND(100.0 * total_rev_per_seg / total_rev_in_cat, 2) AS percentage_seg_in_cat
    FROM rev_per_seg_in_cat AS sc
    JOIN rev_per_cat AS pc ON sc.category_name = pc.category_name AND sc.month = pc.month
    ORDER BY category_name, percentage_seg_in_cat DESC
),
total_rev AS (
    SELECT extract(month from start_txn_time) as month,
           ROUND(SUM(qty * price * (1 - discount / 100.0)), 2) AS total_rev
    FROM sales
    GROUP BY month
),
percentage_per_cat AS (
    SELECT category_name, total_rev_in_cat, r.month,
           ROUND(100.0 * total_rev_in_cat / total_rev, 2) AS percentage_per_cat
    FROM rev_per_cat AS r
    JOIN total_rev AS t ON r.month = t.month
)
SELECT c.month, c.category_name, ps.segment_name, product_name,
       total_rev_per_seg AS total_rev_per_seg_in_cat,
       total_rev_per_prod AS total_rev_per_prod_in_seg,
       percentage_prod_in_seg, percentage_seg_in_cat, percentage_per_cat
FROM percentage_prod_in_seg AS ps
JOIN percentage_seg_in_cat AS sc ON ps.segment_name = sc.segment_name AND ps.month = sc.month
JOIN percentage_per_cat AS c ON sc.category_name = c.category_name AND sc.month = c.month
WHERE c.month = 1 -- change to a desire month
ORDER BY category_name, total_rev_per_prod_in_seg DESC;

-- table with top selling product by segment
create table top_selling_product_by_month as 
	with cal_net_rev_prod_in_seg as (
		select extract(month from start_txn_time) as month, segment_name, product_name, 
		round(sum(qty*s.price*(1-discount/100.0)),2) as net_rev_prod_in_seg,
		dense_rank() over (partition by segment_name 
							order by extract(month from start_txn_time) asc, round(sum(qty*s.price*(1-discount/100.0)),2) desc
		) as prod_in_seg_rk
		from sales as s
		join product_details as pd on s.prod_id = pd.product_id
		group by segment_name, product_name, month
	)
	select month, segment_name, product_name, net_rev_prod_in_seg, prod_in_seg_rk as rk
	from cal_net_rev_prod_in_seg 
	where month=1; -- change to desire month
