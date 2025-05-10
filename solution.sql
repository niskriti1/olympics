create database olympics;

use olympics;

select * from OLYMPICS_HISTORY;

select * from OLYMPICS_HISTORY_NOC_REGIONS;

-- 1) find The total Number of datas in the iolympics

select count(*) from OLYMPICS_HISTORY;

-- 2)  How many olympics games have been held?

select  count(distinct Games) from OLYMPICS_HISTORY;

-- 3) List down all Olympics games held so far

select distinct Games from OLYMPICS_HISTORY;

-- 4) Mention the total no of nations who participated in each olympics game?

select count(*) from(
	select NOC from OLYMPICS_HISTORY
	group by NOC
	having count(distinct Games)=51
) as no_of_countries;


-- 5) Which year saw the highest and lowest no of countries participating in Olympics

(
select Year,count(NOC) as numofcountries from OLYMPICS_HISTORY
group by Year
order by count(NOC) asc
limit 1
)
union
(
select Year,count(NOC) as numofcountries from OLYMPICS_HISTORY
group by Year
order by count(NOC) desc
limit 1
);

-- 6) Which nation has participated in all of the olympic games

select region from OLYMPICS_HISTORY as o
join OLYMPICS_HISTORY_NOC_REGIONS as oh on o.NOC =   oh.NOC
group by o.NOC,region
having count(distinct Games)=51;

-- 7) Identify the sport which was played in all summer olympics.

select sport from OLYMPICS_HISTORY
where Games like '%Summer%'
group by sport
having count(distinct Games)=(
	select count(distinct Games) 
	from OLYMPICS_HISTORY
	where Games like '%Summer%'
);

-- 8) Which Sports were just played only once in the olympics.

select sport 
from OLYMPICS_HISTORY
group by sport
having count(distinct Games)=1;

-- 9) Fetch the total no of sports played in each olympic games.

select Games,
count(distinct sport) as total_no_of_sports 
from OLYMPICS_HISTORY
group by Games;

-- 10) Fetch oldest athletes to win a gold medal

select distinct Name,Age 
from OLYMPICS_HISTORY
where Medal='Gold'
order by Age desc
limit 10;

-- 11) Find the Ratio of male and female athletes participated in all olympic games.

select sum(case when Sex='M' then 1 else 0 end)/sum(case when Sex='F' then 1 else 0 end) as 'M:F'  
from OLYMPICS_HISTORY;

-- 12) Top 5 athletes who have won the most gold medals.

select Name,count(Medal) as gold_medals  
from OLYMPICS_HISTORY
where Medal = 'Gold'
group by name
order by gold_medals desc
limit 5;

-- 13) Top 5 athletes who have won the most medals (gold/silver/bronze).

select Name,count(Medal) as medals  
from OLYMPICS_HISTORY
group by name
order by medals desc
limit 5;

-- 14) Top 5 most successful countries in olympics. Success is defined by no of medals won.

select region,count(Medal) as medals
from OLYMPICS_HISTORY as o
join OLYMPICS_HISTORY_NOC_REGIONS as oh on o.NOC = oh.NOC
group by o.NOC,region
order by medals desc
limit 5;

-- 15) List down total gold, silver and broze medals won by each country.

select region,
sum(case when Medal = 'Gold' then 1 else 0 end) as Gold,
sum(case when Medal = 'Silver' then 1 else 0 end) as Silver,
sum(case when Medal = 'Bronze' then 1 else 0 end) as Bronze
from OLYMPICS_HISTORY as o
join OLYMPICS_HISTORY_NOC_REGIONS as oh on o.NOC = oh.NOC
group by o.NOC,region
order by Gold desc,Silver desc,Bronze desc;

-- 16) List down total gold, silver and broze medals won by each country corresponding to each olympic games.

select region,
Games,
sum(case when Medal = 'Gold' then 1 else 0 end) as Gold,
sum(case when Medal = 'Silver' then 1 else 0 end) as Silver,
sum(case when Medal = 'Bronze' then 1 else 0 end) as Bronze
from OLYMPICS_HISTORY as o
join OLYMPICS_HISTORY_NOC_REGIONS as oh on o.NOC = oh.NOC
group by o.NOC,region,Games
order by Gold desc,Silver desc,Bronze desc;

-- 17) Identify which country won the most gold, most silver and most bronze medals in each olympic games.

(
SELECT Games, region, MedalCount,'Gold' as MedalType
FROM (
    SELECT o.Games,
           oh.region,
           COUNT(*) AS MedalCount,
           RANK() OVER (PARTITION BY o.Games ORDER BY COUNT(*) DESC) AS rnk
    FROM OLYMPICS_HISTORY o
    JOIN OLYMPICS_HISTORY_NOC_REGIONS oh ON o.NOC = oh.NOC
    WHERE o.Medal = 'Gold'
    GROUP BY o.Games, oh.region
) AS ranked
WHERE rnk = 1
ORDER BY Games
)
union 
(
SELECT Games, region, MedalCount,'Silver' as MedalType
FROM (
    SELECT o.Games,
           oh.region,
           COUNT(*) AS MedalCount,
           RANK() OVER (PARTITION BY o.Games ORDER BY COUNT(*) DESC) AS rnk
    FROM OLYMPICS_HISTORY o
    JOIN OLYMPICS_HISTORY_NOC_REGIONS oh ON o.NOC = oh.NOC
    WHERE o.Medal = 'Silver'
    GROUP BY o.Games, oh.region
) AS ranked
WHERE rnk = 1
ORDER BY Games
)
union 
(
SELECT Games, region, MedalCount,'Bronze' as MedalType
FROM (
    SELECT o.Games,
           oh.region,
           COUNT(*) AS MedalCount,
           RANK() OVER (PARTITION BY o.Games ORDER BY COUNT(*) DESC) AS rnk
    FROM OLYMPICS_HISTORY o
    JOIN OLYMPICS_HISTORY_NOC_REGIONS oh ON o.NOC = oh.NOC
    WHERE o.Medal = 'Bronze'
    GROUP BY o.Games, oh.region
) AS ranked
WHERE rnk = 1
ORDER BY Games
);

-- 18) Identify which country won the most gold, most silver, most bronze medals and the most medals in each olympic games.


select 'Gold' as Type,Games,region as Country,MedalCount
from (
	select Games,region,count(*) as MedalCount,
	rank() over( partition by Games order by count(*) desc) as rnk
	FROM OLYMPICS_HISTORY o
	JOIN OLYMPICS_HISTORY_NOC_REGIONS oh ON o.NOC = oh.NOC
	WHERE o.Medal = 'Gold'
	GROUP BY Games, region
) as gold
where rnk=1

union all

select 'Silver' as Type,Games,region as Country,MedalCount
from (
	select Games,region,count(*) as MedalCount,
	rank() over(partition by Games order by count(*) desc) as rnk
	FROM OLYMPICS_HISTORY o
	JOIN OLYMPICS_HISTORY_NOC_REGIONS oh ON o.NOC = oh.NOC
	WHERE o.Medal = 'Silver'
	GROUP BY Games, region
) as silver
where rnk=1

union all

select 'Bronze' as Type,Games,region as Country,MedalCount
from (
	select Games,region,count(*) as MedalCount,
	rank() over(partition by Games order by count(*) desc) as rnk
	FROM OLYMPICS_HISTORY o
	JOIN OLYMPICS_HISTORY_NOC_REGIONS oh ON o.NOC = oh.NOC
	WHERE o.Medal = 'Bronze'
	GROUP BY Games, region
) as bronze
where rnk=1

union all

select 'Total' as Type, Games,region as Country,MedalCount
from (
	select Games,region,count(*) as MedalCount,
	rank() over(partition by Games order by count(*) desc) as rnk
	from OLYMPICS_HISTORY o
	join OLYMPICS_HISTORY_NOC_REGIONS oh on o.NOC = oh.NOC
	where Medal in ('Gold', 'Silver', 'Bronze')
	group by Games, region
) as total
where rnk=1


order by Games, FIELD(Type, 'Gold', 'Silver', 'Bronze', 'Total');


-- 19) Which countries have never won gold medal but have won silver/bronze medals?

select distinct region,games
from OLYMPICS_HISTORY o
join OLYMPICS_HISTORY_NOC_REGIONS oh on o.NOC = oh.NOC
where Medal in ('Silver','Bronze')
and not exists (
	select 1 from OLYMPICS_HISTORY o2
    join OLYMPICS_HISTORY_NOC_REGIONS oh2 on o2.NOC = oh2.NOC
    where o.games=o2.games 
    and oh.region=oh2.region
    and o.Medal='Gold'
)
order by games,region;


-- 20) Break down all olympic games where india won medal for Hockey and how many medals in each olympic games

select games,count(Medal) as medalcount 
from OLYMPICS_HISTORY o 
join OLYMPICS_HISTORY_NOC_REGIONS oh on o.NOC = oh.NOC
where region='India' 
and sport='Hockey' 
and Medal in ('Gold','Silver','Bronze')
group by games
order by games;







