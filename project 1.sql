-- 1- write a query to print top 5 cities with highest spends and their percentage contribution of total credit card spends 

select top 5
     city as City,
     sum(amount) as Highest_Spends ,cast(100.0 *sum(amount)/
    (select sum(amount) from credit_card_transcations) as decimal (5,2)) as Percentage
from credit_card_transcations
group by city
order by Highest_Spends desc

-- 2- write a query to print highest spend month and amount spent in that month for each card type.
select * from credit_card_transcations

With cte1 as
    (select card_type, format(transaction_date,'yyyy-M') as Month, sum(amount) as Highest_Spend
    from credit_card_transcations
group by card_type, format(transaction_date,'yyyy-M')),

cte2 as
    (select *,
    rank() over (partition by card_type order by Highest_Spend desc, Month) as rank1
from cte1)

select * from cte2 
where rank1 = 1


-- 3- write a query to print the transaction details(all columns from the table) for each card type when
-- it reaches a cumulative of 1000000 total spends(We should have 4 rows in the o/p one for each card type)
-- not solved

with cte1 as

   (select *, sum(amount) over (partition by card_type order by transaction_date, transaction_id 
   rows between unbounded preceding and current row) as Total_Spend
from credit_card_transcations),

cte2 as
   (select *, rank() over (partition by card_type order by transaction_date, transaction_id, Total_Spend) as Rank_No
from cte1 where Total_Spend >=1000000)

select * from cte2
where Rank_No=1


-- 4- write a query to find city which had lowest percentage spend for gold card type

select top 1 city, sum(amount) as Total_Spend,
       sum(case when card_type = 'gold' then amount else 0 end) as Gold_Spend,
      (100.0*(sum(case when card_type = 'gold' then amount else 0 end))/sum(amount)) as Percentage
from credit_card_transcations

group by city
      having sum(case when card_type = 'gold' then amount else 0 end)>0
order by Percentage


-- 5- write a query to print 3 columns:  city, highest_expense_type , lowest_expense_type (example format : Delhi , bills, Fuel)

with cte1 as(
   	select city,exp_type, sum(amount) as total
    from credit_card_transcations
group by city,exp_type),

cte2 as(
      select *,
          rank() over (partition by city order by total desc) as rnk1,
          rank() over (partition by city order by total) as rnk2
from cte1)

select city,
       max(case when rnk1 = 1 then exp_type end) as high,
       max(case when rnk2 = 1 then exp_type end) as low
from cte2
group by city

-- 6- write a query to find percentage contribution of spends by females for each expense type.

SELECT 
    exp_type,
    ROUND(100.0 * SUM(CASE WHEN gender = 'F' THEN amount ELSE 0 END) / SUM(amount), 2) AS female_percentage
FROM 
    credit_card_transcations
GROUP BY 
    exp_type
	order by female_percentage;

-- 7- which card and expense type combination saw highest month over month growth in Jan-2014

with one as
      (select card_type, exp_type, FORMAT(transaction_date,'MMM-yyyy') as Month, sum(amount) as Total
      from credit_card_transcations
group by card_type, exp_type, FORMAT(transaction_date,'MMM-yyyy')),
two as(
     select *,
         lag(Total,1) over (partition by card_type, exp_type order by Month) as Previous
     from one)
select top 1 *, (Total- Previous) as Growth
from two
where Month = 'Jan-2014' and Previous is not null
order by Growth desc

with one as
      (select card_type, exp_type, datepart(year,transaction_date) yt
,datepart(month,transaction_date) mt, sum(amount) as Total
      from credit_card_transcations
group by card_type, exp_type, datepart(year,transaction_date)
,datepart(month,transaction_date)),
two as(
     select *,
         lag(Total,1) over (partition by card_type, exp_type order by yt,mt) as Previous
     from one)
select top 1 *, (Total- Previous) as Growth
from two
where Previous is not null and yt=2014 and mt=1 
order by Growth desc


-- 8- during weekends which city has highest total spend to total no of transcations ratio.

select * from credit_card_transcations

SELECT TOP 1
    city,
    SUM(amount) / COUNT(transaction_id) AS Ratio
FROM
    credit_card_transcations
WHERE
    FORMAT(transaction_date, 'dddd') IN ('Saturday', 'Sunday')
GROUP BY
    city
ORDER BY
    Ratio DESC;


	SELECT TOP 1
    city,
    SUM(amount) / COUNT(transaction_id) AS Ratio
FROM
    credit_card_transcations
WHERE
    Datepart(WEEKDAY,transaction_date) IN (1,7)
GROUP BY
    city
ORDER BY
    Ratio DESC;
-- 9- which city took least number of days to reach its 500th transaction after the first transaction in that city.

with own as
(select *,
ROW_NUMBER() over (partition by city order by transaction_date )  as new1
from credit_card_transcations)
, my as(
select city,
max(case when new1 = 1 then transaction_date end) as firstday,
max(case when new1 = 500 then transaction_date end) as lastday
from own
group by city)
select top 1 city,DATEDIFF(day,firstday,lastday) as total_days
from my 
where Lastday is not null
order by total_days








