select * from drivers;
select * from results;
select * from races;
select * from constructors;
select * from status;
select * from seasons;

select code, forename, surname,
count(*) as wins
from
 drivers
join results using(driverid)
where position = 1
group by driverid
order by wins desc
limit 3;

--both these queries give the same result, in the first query "and" is on join condition whereas in the second query there is a sub query
--Query 1
select date, name, drivers.surname as winner
from races
left join results
on results.raceid = races.raceid
and results.position = 1
left join drivers using(driverid)
where date >= date '2017-04-01'
and date < date '2017-04-01'
+ 3 * interval '1 month';
--Query 2
select date, name, drivers.surname as winner
from races
left join
( select raceid, driverid
from results
where position = 1
)
as winners using(raceid)
left join drivers using(driverid)
where date >= date '2017-04-01'
and date < date '2017-04-01'
+ 3 * interval '1 month';

select forename,
surname,
constructors.name as constructor,
count(*) as races,
count(distinct status) as reasons
from drivers
join results using(driverid)
join races using(raceid)
join status using(statusid)
join constructors using(constructorid)
where date >= date '1978-01-01'
and date < date '1978-01-01' + interval '1 year'
and not exists
(
select 1
from results r
where position is not null
and r.driverid = drivers.driverid
and r.resultid = results.resultid
)
group by constructors.name, driverid
order by count(*) desc;

explain (costs off)
select year, url
from seasons
order by year desc
limit 3;

--order clause woth multiple condition and expressions
select drivers.code, drivers.surname,
position,
laps,
status
from results
join drivers using(driverid)
join status using(statusid)
where raceid = 972
order by position nulls last,
laps desc,
case when status = 'Power Unit'
then 1
else 2
end;

--Adding postition column and indexing that column
alter table f1db.circuits add column position point;
update f1db.circuits set position = point(lng,lat);
create index on f1db.circuits using gist(position);

explain (costs off, buffers, analyze)
select name, location, country
from circuits
order by position <-> point(2.349014, 48.864716)
limit 10;

--Lateral join
with decades as
(
select extract('year' from date_trunc('decade', date)) as decade
from races
group by decade
)
select decade,
rank() over(partition by decade
order by wins desc)
as rank,
forename, surname, wins
from decades
left join lateral
(
select code, forename, surname, count(*) as wins
from drivers
join results
on results.driverid = drivers.driverid
and results.position = 1
join races using(raceid)
where
 extract('year' from date_trunc('decade', races.date))
= decades.decade
group by decades.decade, drivers.driverid
order by wins desc
limit 3
)
as winners on true
order by decade asc, wins desc;

--Groupby
select extract('year' from date_trunc('decade',date)) as decade,count(*)
from races
group by decade
order by decade;

select distinct on (driverid)
forename, surname
from results
join drivers using(driverid)
where position = 1;
--using distinct as a function in aggregate function
select count(distinct(driverid))
from results
join drivers using(driverid)
where position = 1;

--Can use forname and surname here as they have functional dependency
--Functional dependency here:
--driverid is the primary key (or at least unique) in drivers.
--forename and surname depend uniquely on driverid.
--That is: given a driverid, there is exactly one forename + surname.
select forename, surname
from results join drivers using(driverid)
where position = 1
group by drivers.driverid;

select * from results;
select * from drivers;



