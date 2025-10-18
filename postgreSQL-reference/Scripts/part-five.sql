--error as no such leap year
select date '2010-02-29';
--selected as text so no error
select '2010-02-29';
--error as no such leap year
select '2010-02-29'::date;
--type is unknown
select  pg_typeof('2010-02-29');

--date(...), timestamp(...), time(...), etc. are type constructor functions — they exist as shorthand to cast strings into those specific types.
--But there is no text() constructor — because text is already the “default catch-all” type in Postgres.
select date(date '0001-01-01' + x * interval '1 day')
from generate_series (-2, 1) as t(x);

--Gives type as date
select pg_typeof(date(date '0001-01-01' + x * interval '1 day'))
from generate_series (-2, 1) as t(x);

--"Allballs" is slang for "all zeros" because zeros look like balls.
--You hear it sometimes in environments that use a 24-hour clock
select date 'today' + time 'allballs' as midnight;

--Bigint and integer
select pg_typeof(driverid), pg_typeof(1) from drivers limit 1;
--Integer
select pg_typeof(1);

select
year,
format('%s %s', forename, surname) as name,
count(*) as ran,
count(*) filter(where position = 1) as won,
count(*) filter(where position is not null) as finished,
sum(points) as points
from races
 join results using(raceid)
join drivers using(driverid)
group by year, drivers.driverid
having bool_and(position = 1) is true
order by year, points desc;

select year,
format('%s %s', forename, surname) as name,
count(*) as ran,
count(*) filter(where position = 1) as won,
count(*) filter(where position is not null) as finished,
sum(points) as points
from races
 join results using(raceid)
join drivers using(driverid)
group by year, drivers.driverid
having bool_and(position is not distinct from 1) is true
order by year, points desc;

--returns false when result is null
--The BOOL_AND() function returns true if all values in the group are true, or false otherwise.
select bool_and( position=1000) from results;

select * from results where position is null;
select * from results where position =1;
select * from results where position is not distinct from 1;

create table boolandtests(id int primary key generated always  as identity,name text not null, position int, county int, group_id int not null);

alter table boolandtests add column group_id int not null;

insert into boolandtests (name, position, county, group_id) values
('Alice', 1, 10, 1),
('Bob', 1, null, 1),
('Charlie', null, 15, 1),
('Diana', 1, 20, 2),
('Ethan', null, null, 2),
('Fiona', 3, 25, 2),
('George', 1, null, 3),
('Hannah', null, 30, 3),
('Ian', 1, 35, 3),
('Julia', 2, null, 3),
('Kevin', 1, 40, 1),
('Laura', null, 45, 2),
('Mike', 2, null, 3),
('Nina', 1, 50, 1),
('Oscar', null, null, 2);

select count(*) from boolandtests group by group_id
having bool_and(position=1);

select count(*) from boolandtests group by group_id
having bool_and(position is not distinct from 1);

update boolandtests set county=110 where id=1;
update boolandtests set county=115 where id=3;
update boolandtests set county=140 where id=11;
update boolandtests set county=150 where id=14;

UPDATE boolandtests
SET county = CASE id
    WHEN 1 THEN 110
    WHEN 3 THEN 115
    WHEN 11 THEN 140
    WHEN 14 THEN 150
END
WHERE id IN (1, 3, 11, 14);

update boolandtests bt set bt.county=dummy.county from (values (1,110),(3,115),(11,140),(14,150)) as dummy(id,county) where dummy.id=bt.id;

update boolandtests bt set county=dummy.county from (values (1,110),(3,115),(11,140),(14,150)) as dummy(id,county) where dummy.id=bt.id;

select count(*) from boolandtests group by group_id having max(county)>100; 

select * from boolandtests;




