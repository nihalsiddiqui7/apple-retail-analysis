--Basic data exploration 
select * from apple_category.category 
select * from apple_sales.sales limit 10
select * from apple_warranty.warranty limit 10
select * from apple_products.products limit 100
select * from apple_stores.stores 



--Performance Improvement as the data has ~1M records
create index sales_product_id on apple_sales.sales(product_id)
create index sales_store_id on apple_sales.sales(store_id)

explain analyze
select * from apple_sales.sales 
where store_id = 'ST-44'


--checking null values
select 
sum(case when sale_id is null then 1 else 0 end)
from apple_sales.sales s 


--second method to check null values
select * from apple_sales.sales  
where sale_id is null or product_id is null 
or quantity is null
or sale_date is null

--Q1-Now Lets Check the Number of stores in Each Country
select "Country"  , count("Store_ID" )
from apple_stores.stores  
group by "Country"
order by count("Store_ID" ) desc


--Q2-Calculate the number of units sold by each store and disply the store_id and store_name

select sum(s.quantity) as quantity_sold,
s.store_id ,
s2."Store_Name" 
from apple_sales.sales s 
join apple_stores.stores s2 
on s.store_id = s2."Store_ID" 
group by s.store_id, s2."Store_Name"  
order by quantity_sold desc




--Q3- Identify how many sales occured in december 2023
SELECT count(sale_id) as total_sales
FROM apple_sales.sales
WHERE TO_DATE(sale_date, 'DD-MM-YYYY')
      BETWEEN DATE '2023-12-01' AND DATE '2023-12-31';


--Q4- Determine store which never recieved any warranty claim

select count(*)  from apple_stores.stores
where "Store_ID"  not in (
	select distinct store_id
	from apple_sales.sales s
	right join warranty w 
	on s.sale_id = w.sale_id 
)

--USING CTE
WITH warr AS (
    SELECT DISTINCT s.store_id
    FROM apple_sales.sales s
    JOIN apple_warranty.warranty w
        ON s.sale_id = w.sale_id
)
SELECT DISTINCT s.store_id, s2."Store_Name"
FROM apple_sales.sales s
JOIN apple_stores.stores s2
    ON s.store_id = s2."Store_ID" 
WHERE s.store_id NOT IN (
    SELECT store_id FROM warr
);



--Q5-% of warranty claims marked as rejected
SELECT 
    ROUND(
        SUM(CASE WHEN repair_status = 'Rejected' THEN 1 ELSE 0 END) * 100.0
        / COUNT(*),
        2
    ) AS percent_rejected
FROM apple_warranty.warranty;



--Q6- Which store has the highest total units sold in the last year
SELECT store_id, store_name, total_sales
FROM (
    SELECT 
        s2."Store_ID" AS store_id,
        s2."Store_Name" AS store_name,
        SUM(s.quantity) AS total_sales,
        RANK() OVER (ORDER BY SUM(s.quantity) DESC) AS rnk
    FROM apple_sales.sales s
    JOIN apple_stores.stores s2
        ON s.store_id = s2."Store_ID"
    WHERE TO_DATE(s.sale_date, 'DD-MM-YYYY') >= (
        SELECT MAX(TO_DATE(sale_date, 'DD-MM-YYYY')) - INTERVAL '1 year'
        FROM apple_sales.sales
    )
    GROUP BY s2."Store_ID", s2."Store_Name"
) ranked
WHERE rnk = 1;



--Q7- Count the number of unique products sold in the last year

select count(distinct product_id)
from apple_sales.sales 
WHERE TO_DATE(sale_date, 'DD-MM-YYYY') >= (
        SELECT MAX(TO_DATE(sale_date, 'DD-MM-YYYY')) - INTERVAL '1 year'
        FROM apple_sales.sales
    )


--Q8- Find avg price of products in each category
    
select ROUND(AVG(p."Price" ),0) as avg_price, c.category_name
from apple_products.products p
join apple_category.category c
on p."Category_ID" = c.category_id 
group by 
p."Category_ID" , c.category_name 


--Q9- How many warranty claims were filed in 2024
SELECT COUNT(*)
FROM apple_warranty.warranty
WHERE claim_date BETWEEN DATE '2024-01-01' AND DATE '2024-12-31';



--Q10- for each store, identify the best-selling day based on highest quantity sold
SELECT store_id, best_day, total_sold
FROM (
    SELECT
        s.store_id,
        EXTRACT(
            DAY FROM
            CASE
                WHEN s.sale_date LIKE '____-__-__'
                    THEN TO_DATE(s.sale_date, 'YYYY-MM-DD')
                ELSE TO_DATE(s.sale_date, 'DD-MM-YYYY')
            END
        ) AS best_day,
        SUM(s.quantity) AS total_sold,
        RANK() OVER (
            PARTITION BY s.store_id
            ORDER BY SUM(s.quantity) DESC
        ) AS rnk
    FROM apple_sales.sales s
    GROUP BY
        s.store_id,
        CASE
            WHEN s.sale_date LIKE '____-__-__'
                THEN TO_DATE(s.sale_date, 'YYYY-MM-DD')
            ELSE TO_DATE(s.sale_date, 'DD-MM-YYYY')
        END
) ranked
WHERE rnk = 1;



--Least selling product in each country based on total units sold
with product_rank as 
(select s2."Country" ,p."Product_Name" ,sum(quantity) as total_qty_sold,
rank() over(partition by s2."Country" order by sum(quantity) ) as rnk
from apple_sales.sales s 
join apple_stores.stores s2 
on s.store_id = s2."Store_ID" 
join apple_products.products p 
on s.product_id = p."Product_ID" 
group by 1,2)

select * from product_rank
where rnk = 1



--YoY Growth for each Country
WITH yearly_revenue AS (
    SELECT
        s.store_id,
        EXTRACT(
            YEAR FROM
            CASE
                WHEN s.sale_date LIKE '____-__-__'
                    THEN TO_DATE(s.sale_date, 'YYYY-MM-DD')
                ELSE TO_DATE(s.sale_date, 'DD-MM-YYYY')
            END
        ) AS sales_year,
        SUM(s.quantity * p."Price" ) AS total_revenue
    FROM apple_sales.sales s
    JOIN apple_products.products p
        ON s.product_id = p."Product_ID" 
    GROUP BY
        s.store_id,
        EXTRACT(
            YEAR FROM
            CASE
                WHEN s.sale_date LIKE '____-__-__'
                    THEN TO_DATE(s.sale_date, 'YYYY-MM-DD')
                ELSE TO_DATE(s.sale_date, 'DD-MM-YYYY')
            END
        )
)
SELECT
    store_id,
    sales_year,
    total_revenue,
    LAG(total_revenue) OVER (
        PARTITION BY store_id
        ORDER BY sales_year
    ) AS prev_year_revenue,
    ROUND(
        (total_revenue - LAG(total_revenue) OVER (
            PARTITION BY store_id
            ORDER BY sales_year
        )) * 100.0
        / NULLIF(
            LAG(total_revenue) OVER (
                PARTITION BY store_id
                ORDER BY sales_year
            ), 0
        ),
        2
    ) AS yoy_growth_percent
FROM yearly_revenue
ORDER BY store_id, sales_year;



--Q.Write a query to calculate the monthly running total of sales for each store over the past four years and compare trends during this period.
WITH normalized_sales AS (
    SELECT
        s.store_id,
        DATE_TRUNC(
            'month',
            CASE
                WHEN s.sale_date LIKE '____-__-__'
                    THEN TO_DATE(s.sale_date, 'YYYY-MM-DD')
                ELSE TO_DATE(s.sale_date, 'DD-MM-YYYY')
            END
        ) AS sales_month,
        s.quantity * p."Price"  AS revenue
    FROM apple_sales.sales s
    JOIN apple_products.products p
        ON s.product_id = p."Product_ID" 
),
filtered_sales AS (
    SELECT *
    FROM normalized_sales
    WHERE sales_month >= (
        SELECT MAX(sales_month) - INTERVAL '4 years'
        FROM normalized_sales
    )
),
monthly_sales AS (
    SELECT
        store_id,
        sales_month,
        SUM(revenue) AS monthly_revenue
    FROM filtered_sales
    GROUP BY store_id, sales_month
)
SELECT
    store_id,
    sales_month,
    monthly_revenue,
    SUM(monthly_revenue) OVER (
        PARTITION BY store_id
        ORDER BY sales_month
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total_revenue
FROM monthly_sales
ORDER BY store_id, sales_month;



