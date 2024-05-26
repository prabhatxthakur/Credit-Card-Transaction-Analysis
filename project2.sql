SELECT * FROM credit_card_transcations;

-- 1. write a query to print top 5 cities with highest spends 

with cte1 as 
(select city, SUM(amount) as total_spend
FROM credit_card_transcations
GROUP BY city),
cte2 as (SELECT SUM(total_spend) as total from cte1)
SELECT cte1.*, (cte1.total_spend/cte2.total)*100 as percent
FROM cte1
INNER JOIN cte2 ON 1=1
order by total_spend DESC
LIMIT 5;

-- altering ---------------------
ALTER TABLE credit_card_transcations
MODIFY COLUMN transaction_date DATE;

UPDATE credit_card_transcations
SET transaction_date = DATE_FORMAT(STR_TO_DATE(transaction_date, '%d-%b-%y'), '%Y-%m-%d');
-- ------------------------------- 
 -- 2. write a query to print highest spend month and amount spent in that month for each card type
 
with cte1 as (
SELECT card_type, monthname(transaction_date) as month,  SUM(amount) as  amount
FROM credit_card_transcations
GROUP BY  monthname(transaction_date), card_type
ORDER BY month), 
cte2 as 
(SELECT *,
row_number() OVER( partition by card_type ORDER BY amount DESC) as rn
FROM cte1)
SELECT * FROM cte2
WHERE rn=1;


-- 3. write a query to print the transaction details(all columns from the table) for each card type when it reaches a cumulative of  1,000,000 total spends

with cte1 as 
(SELECT *,SUM(amount) OVER (partition by card_type Order By transaction_date, transaction_id) as cumulative_amount
FROM credit_card_transcations),
cte2 as (SELECT *, row_number() OVER (Partition by card_type order by cumulative_amount) rn
FROM cte1 where cumulative_amount >= 1000000)
SELECT * FROM cte2
where rn=1;

-- 4. write a query to find city which had lowest percentage spend for gold card type

with cte1 as(
SELECT city, card_type, SUM(amount) as amount, SUM(case when card_type = 'gold' then amount end) as gold_amount
FROM credit_card_transcations
group by city, card_type
order by city, card_type)
SELECT city, (sum(gold_amount)/sum(amount))*100 percent
FROM cte1
Group BY city
Having percent is NOT NULL
order by percent
LIMIT 1;

-- 5. select distinct exp_type from credit_card_transcations

with cte as (
select city,exp_type, sum(amount) as total_amount from credit_card_transcations
group by city,exp_type),
cte2 as (select *
,rank() over(partition by city order by total_amount desc) rn_desc
,rank() over(partition by city order by total_amount asc) rn_asc
from cte) 
select
city , max(case when rn_asc=1 then exp_type end) as lowest_exp_type
, min(case when rn_desc=1 then exp_type end) as highest_exp_type
from cte2 
group by city;

-- 6. write a query to find percentage contribution of spends by females for each expense type

with cte1 as (
SELECT exp_type, SUM(amount) as total, SUM(case when gender = 'F' then amount end) as female_total
FROM credit_card_transcations
group by exp_type)
SELECT exp_type, (female_total/total)*100 percent
FROM cte1;





