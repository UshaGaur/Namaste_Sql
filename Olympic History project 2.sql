--1 which team has won the maximum gold medals over the years.

select top 1 a.team, count(ae.medal) as Gold_Medal_Count from athletes a
inner join athlete_events ae on a.id = ae.athlete_id
where medal = 'Gold'
group by a.team
order by Gold_Medal_Count desc

--sol 2
select top 1  team,count(distinct event) as cnt from athlete_events ae
inner join athletes a on ae.athlete_id=a.id
where medal='Gold'
group by team
order by cnt desc

--2 for each team print total silver medals and year in which they won maximum silver medal..output 3 columns
-- team,total_silver_medals, year_of_max_silver

select a.team,ae.year,count(ae.medal) as total_medal
from athletes a left join athlete_events ae on a.id = ae.athlete_id
where medal = 'Silver' and team = 'Argentina'
group by a.team,ae.year

with cte1 as(
select a.team,ae.year,count(ae.medal) as total_medal,
rank() over (partition by team order by count(ae.medal) desc) as nw
from athletes a left join athlete_events ae on a.id = ae.athlete_id
where medal = 'Silver'
group by a.team,ae.year)
select team, sum(total_medal),
max(case when nw = 1 then year end) as max_medal_year
from cte1
group by team

-- sol 2
with cte as (
select a.team,ae.year , count(distinct event) as silver_medals
,rank() over(partition by team order by count(distinct event) desc) as rn
from athlete_events ae
inner join athletes a on ae.athlete_id=a.id
where medal='Silver'
group by a.team,ae.year)
select team,sum(silver_medals) as total_silver_medals, max(case when rn=1 then year end) as  year_of_max_silver
from cte
group by team;


--3 which player has won maximum gold medals amongst the players which have won only gold medal
-- (never won silver or bronze) over the years

with cte1 as(
select a.name,ae.medal
from athletes a
left join athlete_events ae on a.id = ae.athlete_id
where medal != 'NA')

select top 1 name, count(medal)
from cte1
where name not in (select distinct name from cte1 where medal in ('Silver','Bronze')) and medal = 'gold'
group by name
order by count(medal) desc


--4 in each year which player has won maximum gold medal . Write a query to print year,player name 
--and no of golds won in that year. In case of a tie print comma separated player names.

WITH cte1 AS (
    SELECT ae.year, a.name, COUNT(*) AS Total_gold
    FROM athletes a
    LEFT JOIN athlete_events ae ON a.id = ae.athlete_id
    WHERE ae.medal = 'Gold'
    GROUP BY ae.year, a.name
),
cte2 AS (
    SELECT *,
           RANK() OVER (PARTITION BY year ORDER BY Total_gold DESC) AS new
    FROM cte1
)
SELECT year, Total_gold, STRING_AGG(name, ', ') AS Name1
FROM cte2
WHERE new = 1
GROUP BY year, Total_gold
ORDER BY year;


--5 in which event and year India has won its first gold medal,first silver medal and first bronze medal
--print 3 columns medal,year,sport

select * from athletes

with cte1 as (
SELECT ae.event,ae.year,ae.sport,ae.medal,row_number() over (partition by medal order by year) as new
    FROM athletes a
    LEFT JOIN athlete_events ae ON a.id = ae.athlete_id
    where team = 'India' and medal != 'NA'
	group by ae.event,ae.year,ae.sport,ae.medal)

select medal,year,sport from cte1
where new = 1

-- solu2
select distinct * from (
select medal,year,event,rank() over(partition by medal order by year) rn
from athlete_events ae
inner join athletes a on ae.athlete_id=a.id
where team='India' and medal != 'NA'
) A
where rn=1


--6 find players who won gold medal in summer and winter olympics both.

SELECT a.name
FROM athletes a
    LEFT JOIN athlete_events ae ON a.id = ae.athlete_id
    where medal = 'Gold'
	group by a.name
	having count(distinct ae.season)=2


--7 find players who won gold, silver and bronze medal in a single olympics. print player name along with year.

 with cte1 as(
SELECT a.name,ae.medal,ae.year
FROM athletes a
    LEFT JOIN athlete_events ae ON a.id = ae.athlete_id
	where medal != 'NA'
	group by a.name,ae.medal,ae.year)
select name,year
from cte1
group by name,year
having count(distinct medal) = 3

-- sol2
select year,name
from athlete_events ae
inner join athletes a on ae.athlete_id=a.id
where medal != 'NA'
group by year,name having count(distinct medal)=3

--8 find players who have won gold medals in consecutive 3 summer olympics in the same event. Consider only olympics 2000 onwards. 
--Assume summer olympics happens every 4 year starting 2000. print player name and event name.

with cte1 as(
SELECT a.name,ae.year,ae.event
FROM athletes a
    LEFT JOIN athlete_events ae ON a.id = ae.athlete_id
	where year >= 2000 and medal = 'Gold' and season = 'summer'
	group by a.name,ae.year,ae.event)
, cte2 as(
select *, lag(year,1) over(partition by name,event order by year ) as prev_year
, lead(year,1) over(partition by name,event order by year ) as next_year
from cte1)
select * from cte2
where year=prev_year+4 and year=next_year-4


-- sol 2
with cte as (
select name,year,event
from athlete_events ae
inner join athletes a on ae.athlete_id=a.id
where year >=2000 and season='Summer'and medal = 'Gold'
group by name,year,event)
select * from
(select *, lag(year,1) over(partition by name,event order by year ) as prev_year
, lead(year,1) over(partition by name,event order by year ) as next_year
from cte) A
where year=prev_year+4 and year=next_year-4





	



   








