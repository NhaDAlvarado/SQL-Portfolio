/*
Use a single SQL query to transform the product_hierarchy and product_prices datasets 
to the product_details table.

Hint: you may want to consider using a recursive CTE to solve this problem!
*/
WITH cte AS
(SELECT ph.id AS style_id, 
        ph.level_text AS style_name, 
        ph1.id AS segment_id, 
        ph1.level_text AS segment_name,
        ph1.parent_id AS category_id,
        ph2.level_text AS category_name
FROM product_hierarchy ph
LEFT JOIN product_hierarchy ph1 ON ph.parent_id=ph1.id
LEFT JOIN product_hierarchy ph2 ON ph1.parent_id=ph2.id
WHERE ph.id BETWEEN 7 AND 18)

SELECT pp.product_id,
       pp.price,
       CONCAT(cte.style_name, ' ', cte.segment_name, ' - ', cte.category_name) AS product_name,
       cte.category_id,
       cte.segment_id,
       cte.style_id,
       cte.category_name,
       cte.segment_name,
       cte.style_name
FROM product_prices as pp
LEFT JOIN cte ON pp.id = cte.style_id;