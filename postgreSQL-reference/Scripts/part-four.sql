select * from drivers;
select * from results;
select * from races;
select * from constructors;

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



