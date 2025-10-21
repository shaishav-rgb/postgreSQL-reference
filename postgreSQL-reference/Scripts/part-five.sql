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
--The BOOL_AND() function returns true if all values in the group are true, or false otherwise. Returns null if all positions are null
select bool_and( position=1000) from results;


create table boolandtests(id int primary key generated always  as identity,name text not null, position int, county int, group_id int not null);


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

--in bool_and():
--{true,true,null}=true, ignores null and considers other values as normal
--{TRUE, FALSE, NULL}=false, if any one is false then it is false
--{null,null,null}=null, if all null then null
select count(*) from boolandtests group by group_id
having bool_and(position=1) is true;

--here, no null value is there. null value becomes false here
--{true,true,null} becomes {true,true,false}=false,
--{TRUE, FALSE, NULL}={TRUE, FALSE, false}=false,
--{null,null,null}={false,false,false}=false,
select count(*) from boolandtests group by group_id
having bool_and(position is not distinct from 1) is true;

--Multiple updates with many statements;
update boolandtests set county=110 where id=1;
update boolandtests set county=115 where id=3;
update boolandtests set county=140 where id=11;
update boolandtests set county=150 where id=14;

--Single update statement
UPDATE boolandtests
SET county = CASE id
    WHEN 1 THEN 110
    WHEN 3 THEN 115
    WHEN 11 THEN 140
    WHEN 14 THEN 150
END
WHERE id IN (1, 3, 11, 14);

--Single update Statement
update boolandtests bt set county=dummy.county from (values (1,110),(3,115),(11,140),(14,150)) as dummy(id,county) where dummy.id=bt.id;

--These both are same as having only look for true values and filters out null value, no need for "is true"
select array_agg(county) from boolandtests group by group_id having max(county)>100; 
select count(*) from boolandtests group by group_id having max(county)>100 is true; 

--max(all null position) is null
select count(*) from boolandtests group by group_id having max(position) is null;
--max(All null position)>100000 is null
select count(*) from boolandtests group by group_id having max(position)>100000 is null;

select * from boolandtests;

--Gives null
select max(null);
--Gives null
select null>100;

--Gives 0
select count(null);
--count * will also count null column as 1, this gives 1
select count(*);

--Count(*) will not ignore null and count it as 1
select count(*) from (values (1,null),(3,115),(11,140),(14,150)) as salary(id,money);
--These two queries produce same result. Count(column_name) count null as 0
select count(money) from (values (1,null),(3,115),(11,140),(14,150)) as salary(id,money);
select count(*) filter(where salary.money is not null) from (values (1,null),(3,115),(11,140),(14,150)) as salary(id,money);

select count(*) filter(where salary.money >0)  from (values (1,null),(3,115),(11,140),(14,150)) as salary(id,money);

--text processing
with categories(id, categories) as
(
select id,
regexp_split_to_array(
regexp_split_to_table(themes, ','),
' > ')
as categories
from opendata.archives_planete
)
select id,
categories[1] as category,
categories[2] as subcategory
from categories
where id = 'IF39599';

--code, forename, surname are functionally dependent on driverid
--PostgreSQL accepts this because the extra columns are uniquely determined.
--You’ll see only one code and one name per driver.
select year,
drivers.code,
format('%s %s', forename, surname) as name,
count(*)
from results
join races using(raceid)
join drivers using(driverid)
where grid = 1
and position = 1
group by year, drivers.driverid
order by count desc
limit 10;

create extension "uuid-ossp";

select uuid_generate_v4()
from generate_series(1, 10) as t(x);

select pg_column_size(uuid 'fbb850cc-dd26-4904-96ef-15ad8dfaff07')
as uuid_bytes,
pg_column_size('fbb850cc-dd26-4904-96ef-15ad8dfaff07')
as uuid_string_bytes;

select pg_column_size(timestamp without time zone 'now'),
pg_column_size(timestamp with time zone 'now');

--function calculation result alias
select extract(year from ats) as year,
count(*) filter(where project = 'postgresql') as postgresql,
count(*) filter(where project = 'pgloader') as pgloader
from commitlog
group by year
order by year;

create table hashtag (
  id serial primary key,
  hashtags text[]
);

insert into hashtag (hashtags) values
  (array['fun','summer','travel']),
  (array['fun','food']),
  (array['travel','adventure','fun']),
  (array['coding','tech','fun']),
  (array['music','party','fun']),
  (array['summer','beach','travel']),
  (array['adventure','mountains']),
  (array['food','cooking','fun']),
  (array['travel','photography']),
  (array['tech','ai','coding']);

select * from hashtag;


select tag, count(*)
from hashtag, unnest(hashtags) as t(tag)
group by tag
order by count desc
limit 10;

--shorthand command
table results limit 10;

--create enum
create type color_t as enum('blue', 'red', 'gray', 'black');

--create composite type
begin;
drop type if exists rate_t cascade;
create type rate_t as
(
currency text,
validity daterange,
value
 numeric
);
create table rate of rate_t
(
exclude using gist (currency with =,
validity with &&)
);
insert into rate(currency, validity, value)
select currency, validity, rate
from rates;
commit;



